/*
 * neo6m_nmea.c - u-blox NEO-6M NMEA sentence generator (plain C99).
 * See neo6m_nmea.h for an overview.
 */
#include "neo6m_nmea.h"

#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#define NEO6M_PI 3.14159265358979323846
#define DEG2RAD (NEO6M_PI / 180.0)
#define RAD2DEG (180.0 / NEO6M_PI)
#define EARTH_RADIUS_M 6371008.8
#define KMH_TO_KNOTS 0.539956803

/* ------------------------------------------------------------------------ */
/* Small helpers                                                            */
/* ------------------------------------------------------------------------ */

static uint32_t rng_next(uint32_t *s) {
  /* xorshift32 - tiny, deterministic, good enough for jitter. */
  uint32_t x = *s ? *s : 0x6D2B79F5u;
  x ^= x << 13;
  x ^= x >> 17;
  x ^= x << 5;
  *s = x;
  return x;
}

/* Uniform in [-1, 1). */
static double rng_sym(uint32_t *s) {
  return ((double)(rng_next(s) >> 8) / 8388608.0) - 1.0;
}

/* Uniform integer in [lo, hi]. */
static int rng_range(uint32_t *s, int lo, int hi) {
  return lo + (int)(rng_next(s) % (uint32_t)(hi - lo + 1));
}

static double clampd(double v, double lo, double hi) {
  return v < lo ? lo : (v > hi ? hi : v);
}

uint8_t neo6m_nmea_checksum(const char *body) {
  uint8_t cs = 0;
  while (*body) cs ^= (uint8_t)*body++;
  return cs;
}

/* Append "$<body>*CS\r\n" to out[*pos]. Body is built with printf format. */
static void emit(char *out, size_t cap, size_t *pos, const char *fmt, ...) {
  char body[128];
  va_list ap;
  va_start(ap, fmt);
  vsnprintf(body, sizeof(body), fmt, ap);
  va_end(ap);

  if (*pos >= cap) return;
  int n = snprintf(out + *pos, cap - *pos, "$%s*%02X\r\n", body,
                   neo6m_nmea_checksum(body));
  if (n < 0) return;
  if ((size_t)n >= cap - *pos) {
    /* Truncated: drop the partial sentence entirely. */
    out[*pos] = '\0';
    return;
  }
  *pos += (size_t)n;
}

/* Degrees -> "ddmm.mmmmm,N" (lat) or "dddmm.mmmmm,E" (lon). */
static void format_coord(char *buf, size_t cap, double deg, bool is_lat) {
  char hemi = is_lat ? (deg < 0 ? 'S' : 'N') : (deg < 0 ? 'W' : 'E');
  double a = fabs(deg);
  if (a > (is_lat ? 90.0 : 180.0)) a = is_lat ? 90.0 : 180.0;
  /* Work in integer units of 1e-5 arc-minutes (max 1.08e9, fits in 32-bit long)
   * to avoid "59.999995 -> 60.00000" rounding rollover and %lld portability issues. */
  long units = (long)(a * 60.0 * 100000.0 + 0.5);
  long d = units / 6000000L;
  long rem = units % 6000000L;
  long m = rem / 100000L;
  long frac = rem % 100000L;
  if (is_lat)
    snprintf(buf, cap, "%02ld%02ld.%05ld,%c", d, m, frac, hemi);
  else
    snprintf(buf, cap, "%03ld%02ld.%05ld,%c", d, m, frac, hemi);
}

/* UNIX days -> civil date (Howard Hinnant's algorithm). */
static void civil_from_days(long long z, int *y, unsigned *m, unsigned *d) {
  z += 719468;
  long long era = (z >= 0 ? z : z - 146096) / 146097;
  unsigned doe = (unsigned)(z - era * 146097);
  unsigned yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
  long long yy = (long long)yoe + era * 400;
  unsigned doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
  unsigned mp = (5 * doy + 2) / 153;
  *d = doy - (153 * mp + 2) / 5 + 1;
  *m = mp < 10 ? mp + 3 : mp - 9;
  *y = (int)(yy + (*m <= 2));
}

/* ------------------------------------------------------------------------ */
/* Public API                                                               */
/* ------------------------------------------------------------------------ */

void neo6m_sim_default_config(neo6m_sim_config_t *cfg) {
  memset(cfg, 0, sizeof(*cfg));
  cfg->start_lat_deg = -6.2088;   /* Jakarta (same default as the Flutter app) */
  cfg->start_lon_deg = 106.8456;
  cfg->altitude_m = 8.0;
  cfg->geoid_sep_m = 2.0;
  cfg->start_utc_epoch = 1793404800u; /* 2026-10-31 00:00:00 UTC */
  cfg->ttff_ms = 2000;
  cfg->seed = 0xC0FFEEu;
}

void neo6m_sim_default_inputs(neo6m_sim_inputs_t *in) {
  memset(in, 0, sizeof(*in));
  in->speed_kmh = 18.0;   /* Ambulance transit speed (~9.7 knots) */
  in->course_deg = 25.9;
  in->sats_used = 8;
  in->signal = true;
  in->noise_m = 1.5;
}

void neo6m_sim_init(neo6m_sim_t *sim, const neo6m_sim_config_t *cfg) {
  memset(sim, 0, sizeof(*sim));
  sim->cfg = *cfg;
  sim->lat_deg = cfg->start_lat_deg;
  sim->lon_deg = cfg->start_lon_deg;
  sim->rng = cfg->seed ? cfg->seed : 1u;
  sim->fix_type = 1;
  sim->hdop = 99.99;

  /* Build a random but plausible constellation with unique PRNs (1..32). */
  uint32_t used_mask = 0;
  for (int i = 0; i < NEO6M_MAX_SATS; i++) {
    int prn;
    do {
      prn = rng_range(&sim->rng, 1, 32);
    } while (used_mask & (1u << (prn - 1)));
    used_mask |= 1u << (prn - 1);
    sim->sv[i].prn = (uint8_t)prn;
    /* Earlier entries get higher elevation -> they are the "used" ones. */
    sim->sv[i].elevation = (uint8_t)clampd(85 - i * 6 + rng_range(&sim->rng, -4, 4), 5, 89);
    sim->sv[i].azimuth = (uint16_t)rng_range(&sim->rng, 0, 359);
    sim->sv[i].snr = 0;
  }
}

static void update_constellation(neo6m_sim_t *sim, const neo6m_sim_inputs_t *in,
                                 bool acquiring) {
  uint8_t used = in->sats_used > NEO6M_MAX_SATS ? NEO6M_MAX_SATS : in->sats_used;

  if (!in->signal) {
    sim->sats_in_view = 0;
  } else {
    uint8_t view = (uint8_t)(used + 3);
    if (view > NEO6M_MAX_SATS) view = NEO6M_MAX_SATS;
    sim->sats_in_view = view;
  }

  for (int i = 0; i < NEO6M_MAX_SATS; i++) {
    neo6m_sv_t *sv = &sim->sv[i];
    /* Slow drift so the sky view looks alive. */
    if ((rng_next(&sim->rng) & 7u) == 0) sv->azimuth = (uint16_t)((sv->azimuth + 1) % 360);
    if (i >= sim->sats_in_view) {
      sv->snr = 0;
    } else if (acquiring) {
      sv->snr = 0; /* in view (from almanac) but not yet tracked */
    } else if (i < used) {
      int snr = (sv->snr ? sv->snr : 40) + rng_range(&sim->rng, -1, 1);
      sv->snr = (uint8_t)clampd(snr, 32, 49);
    } else {
      sv->snr = (uint8_t)rng_range(&sim->rng, 12, 22); /* weak, not used */
    }
  }
}

size_t neo6m_sim_step(neo6m_sim_t *sim, uint32_t dt_ms,
                      const neo6m_sim_inputs_t *in, char *out, size_t cap) {
  size_t pos = 0;
  if (cap == 0) return 0;
  out[0] = '\0';

  sim->elapsed_ms += dt_ms;
  const double dt = dt_ms / 1000.0;

  /* ---- 1. Ground truth motion (happens regardless of fix) ------------- */
  double v_ms = in->speed_kmh / 3.6;
  if (v_ms > 0.0) {
    double d = v_ms * dt;
    double crs = in->course_deg * DEG2RAD;
    sim->lat_deg += (d * cos(crs)) / EARTH_RADIUS_M * RAD2DEG;
    sim->lat_deg = clampd(sim->lat_deg, -89.9999, 89.9999);
    double coslat = cos(sim->lat_deg * DEG2RAD);
    sim->lon_deg += (d * sin(crs)) / (EARTH_RADIUS_M * coslat) * RAD2DEG;
    if (sim->lon_deg > 180.0) sim->lon_deg -= 360.0;
    if (sim->lon_deg < -180.0) sim->lon_deg += 360.0;
  }

  /* ---- 2. Receiver state ---------------------------------------------- */
  bool acquiring = sim->elapsed_ms < sim->cfg.ttff_ms;
  if (in->signal && sim->elapsed_ms >= sim->cfg.ttff_ms / 2) sim->time_known = true;

  update_constellation(sim, in, acquiring);

  uint8_t used = in->sats_used > NEO6M_MAX_SATS ? NEO6M_MAX_SATS : in->sats_used;
  if (!in->signal || acquiring || used < 3) {
    sim->fix_type = 1;
    sim->sats_used = 0;
    sim->hdop = 99.99;
  } else {
    sim->fix_type = used >= 4 ? 3 : 2;
    sim->sats_used = used;
    sim->hdop = 0.7 + 6.0 / used + rng_sym(&sim->rng) * 0.05;
  }
  const bool fix = sim->fix_type >= 2;

  if (fix) {
    double n = in->noise_m > 0 ? in->noise_m : 0.0;
    sim->jitter_n_m = clampd(sim->jitter_n_m + rng_sym(&sim->rng) * n * 0.3, -n, n);
    sim->jitter_e_m = clampd(sim->jitter_e_m + rng_sym(&sim->rng) * n * 0.3, -n, n);
    sim->reported_lat_deg = sim->lat_deg + (sim->jitter_n_m / EARTH_RADIUS_M) * RAD2DEG;
    sim->reported_lon_deg =
        sim->lon_deg + (sim->jitter_e_m / (EARTH_RADIUS_M * cos(sim->lat_deg * DEG2RAD))) * RAD2DEG;
    /* A stationary NEO-6M still reports a few mm/s of "speed". */
    sim->reported_speed_kmh = fabs(in->speed_kmh + rng_sym(&sim->rng) * 0.05);
    sim->reported_course_deg = fmod(in->course_deg + 360.0, 360.0);
  }

  /* ---- 3. Time strings -------------------------------------------------- */
  char tbuf[16] = "";
  char dbuf[8] = "";
  if (sim->time_known) {
    uint64_t t_ms = (uint64_t)sim->cfg.start_utc_epoch * 1000u + sim->elapsed_ms;
    uint64_t secs = t_ms / 1000u;
    unsigned cs = (unsigned)((t_ms % 1000u) / 10u);
    long long days = (long long)(secs / 86400u);
    unsigned sod = (unsigned)(secs % 86400u);
    int y;
    unsigned mo, d;
    civil_from_days(days, &y, &mo, &d);
    snprintf(tbuf, sizeof(tbuf), "%02u%02u%02u.%02u", sod / 3600u, (sod / 60u) % 60u,
             sod % 60u, cs);
    snprintf(dbuf, sizeof(dbuf), "%02u%02u%02d", d, mo, y % 100);
  }

  char lat[20], lon[20];
  format_coord(lat, sizeof(lat), sim->reported_lat_deg, true);
  format_coord(lon, sizeof(lon), sim->reported_lon_deg, false);
  double knots = sim->reported_speed_kmh * KMH_TO_KNOTS;

  /* ---- 4. Sentences, in NEO-6M default order -------------------------- */
  /* RMC */
  if (fix)
    emit(out, cap, &pos, "GPRMC,%s,A,%s,%s,%.3f,%.2f,%s,,,A", tbuf, lat, lon, knots,
         sim->reported_course_deg, dbuf);
  else
    emit(out, cap, &pos, "GPRMC,%s,V,,,,,,,%s,,,N", tbuf, dbuf);

  /* VTG */
  if (fix)
    emit(out, cap, &pos, "GPVTG,%.2f,T,,M,%.3f,N,%.3f,K,A", sim->reported_course_deg, knots,
         sim->reported_speed_kmh);
  else
    emit(out, cap, &pos, "GPVTG,,,,,,,,,N");

  /* GGA */
  if (fix)
    emit(out, cap, &pos, "GPGGA,%s,%s,%s,1,%02u,%.2f,%.1f,M,%.1f,M,,", tbuf, lat, lon,
         sim->sats_used, sim->hdop, sim->cfg.altitude_m + rng_sym(&sim->rng) * 0.5,
         sim->cfg.geoid_sep_m);
  else
    emit(out, cap, &pos, "GPGGA,%s,,,,,0,00,99.99,,,,,,", tbuf);

  /* GSA */
  {
    char body[128];
    int n = snprintf(body, sizeof(body), "GPGSA,A,%u", sim->fix_type);
    for (int i = 0; i < 12; i++) {
      if (fix && i < sim->sats_used)
        n += snprintf(body + n, sizeof(body) - n, ",%02u", sim->sv[i].prn);
      else
        n += snprintf(body + n, sizeof(body) - n, ",");
    }
    if (fix)
      snprintf(body + n, sizeof(body) - n, ",%.2f,%.2f,%.2f", sim->hdop * 1.4, sim->hdop,
               sim->hdop * 1.1);
    else
      snprintf(body + n, sizeof(body) - n, ",99.99,99.99,99.99");
    emit(out, cap, &pos, "%s", body);
  }

  /* GSV (4 satellites per sentence) */
  if (sim->sats_in_view == 0) {
    emit(out, cap, &pos, "GPGSV,1,1,00");
  } else {
    unsigned total = (sim->sats_in_view + 3u) / 4u;
    for (unsigned msg = 0; msg < total; msg++) {
      char body[128];
      int n = snprintf(body, sizeof(body), "GPGSV,%u,%u,%02u", total, msg + 1,
                       sim->sats_in_view);
      for (unsigned k = 0; k < 4; k++) {
        unsigned i = msg * 4 + k;
        if (i >= sim->sats_in_view) break;
        const neo6m_sv_t *sv = &sim->sv[i];
        if (sv->snr)
          n += snprintf(body + n, sizeof(body) - n, ",%02u,%02u,%03u,%02u", sv->prn,
                        sv->elevation, sv->azimuth, sv->snr);
        else
          n += snprintf(body + n, sizeof(body) - n, ",%02u,%02u,%03u,", sv->prn,
                        sv->elevation, sv->azimuth);
      }
      emit(out, cap, &pos, "%s", body);
    }
  }

  /* GLL */
  if (fix)
    emit(out, cap, &pos, "GPGLL,%s,%s,%s,A,A", lat, lon, tbuf);
  else
    emit(out, cap, &pos, "GPGLL,,,,,%s,V,N", tbuf);

  return pos;
}
