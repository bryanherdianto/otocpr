/*
 * Host / PlatformIO-native test suite for the NEO-6M NMEA simulation engine.
 * Can be executed via:
 *   - PlatformIO:  pio test -e native
 *   - Direct GCC:  gcc -Ilib/Neo6mNmea lib/Neo6mNmea/neo6m_nmea.c test/test_neo6m_nmea/test_main.c -lm -o test_nmea
 */
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "neo6m_nmea.h"

static double parse_nmea_coord(const char *field, char hemi) {
  double raw = atof(field);
  int deg = (int)(raw / 100.0);
  double minutes = raw - deg * 100.0;
  double dec = deg + minutes / 60.0;
  if (hemi == 'S' || hemi == 'W') dec = -dec;
  return dec;
}

/* Validate every NMEA sentence in `burst` for framing, <=82-byte length, and XOR checksum. */
static int validate_nmea_burst(const char *burst) {
  int count = 0;
  const char *p = burst;
  while (*p) {
    assert(*p == '$');
    const char *eol = strstr(p, "\r\n");
    assert(eol != NULL);
    size_t line_len = (size_t)(eol - p) + 2;
    assert(line_len <= 82); /* NMEA 0183 max sentence length including CRLF */

    const char *star = memchr(p, '*', (size_t)(eol - p));
    assert(star != NULL && (eol - star) == 3);

    uint8_t expected = 0;
    for (const char *q = p + 1; q < star; q++) expected ^= (uint8_t)*q;

    char hex[3] = {star[1], star[2], '\0'};
    unsigned parsed = (unsigned)strtoul(hex, NULL, 16);
    if (expected != parsed) {
      fprintf(stderr, "Checksum mismatch: got %02X expected %02X in %.*s\n",
              parsed, expected, (int)(eol - p), p);
      assert(expected == parsed);
    }

    count++;
    p = eol + 2;
  }
  return count;
}

int main(void) {
  neo6m_sim_config_t cfg;
  neo6m_sim_inputs_t in;
  neo6m_sim_t sim;
  char burst[NEO6M_BURST_MAX];

  neo6m_sim_default_config(&cfg);
  neo6m_sim_default_inputs(&in);
  neo6m_sim_init(&sim, &cfg);

  /* 1. Cold start: t = 1000 ms (< ttff_ms = 2000 ms) -> valid NMEA, no fix yet */
  size_t n = neo6m_sim_step(&sim, 1000, &in, burst, sizeof(burst));
  assert(n > 0);
  int sentences = validate_nmea_burst(burst);
  assert(sentences >= 6);
  assert(sim.fix_type == 1);
  assert(strstr(burst, "$GPRMC,") != NULL);
  assert(strstr(burst, ",V,") != NULL);

  /* 2. At t = 2000 ms (>= ttff_ms) -> 3D fix acquired in Jakarta! */
  n = neo6m_sim_step(&sim, 1000, &in, burst, sizeof(burst));
  assert(n > 0);
  validate_nmea_burst(burst);
  assert(sim.fix_type == 3);
  assert(strstr(burst, ",A,") != NULL);

  /* Parse $GPRMC line and check decoded coordinates & date */
  char copy[NEO6M_BURST_MAX];
  memcpy(copy, burst, n + 1);
  char *rmc = strstr(copy, "$GPRMC,");
  assert(rmc != NULL);
  char *rmc_end = strstr(rmc, "*");
  *rmc_end = '\0';

  char *fields[16] = {0};
  int nf = 0;
  char *cur = rmc;
  while (nf < 16) {
    fields[nf++] = cur;
    char *comma = strchr(cur, ',');
    if (!comma) break;
    *comma = '\0';
    cur = comma + 1;
  }
  assert(nf >= 10);
  assert(strcmp(fields[2], "A") == 0);
  double lat0 = parse_nmea_coord(fields[3], fields[4][0]);
  double lon0 = parse_nmea_coord(fields[5], fields[6][0]);
  assert(fabs(lat0 - cfg.start_lat_deg) < 0.001);
  assert(fabs(lon0 - cfg.start_lon_deg) < 0.001);
  assert(strcmp(fields[9], "311026") == 0); /* 31 Oct 2026 */

  /* 3. Advance 30 seconds moving NE at 36 km/h (10 m/s -> ~300 m) */
  in.speed_kmh = 36.0;
  in.course_deg = 45.0;
  for (int i = 0; i < 30; i++) {
    n = neo6m_sim_step(&sim, 1000, &in, burst, sizeof(burst));
    validate_nmea_burst(burst);
  }
  assert(sim.reported_lat_deg > lat0 + 0.0015);
  assert(sim.reported_lon_deg > lon0 + 0.0015);

  /* 4. 2D fix with 3 satellites, no fix with 2 satellites, no fix with signal lost */
  in.sats_used = 3;
  neo6m_sim_step(&sim, 1000, &in, burst, sizeof(burst));
  validate_nmea_burst(burst);
  assert(sim.fix_type == 2);

  in.sats_used = 2;
  neo6m_sim_step(&sim, 1000, &in, burst, sizeof(burst));
  validate_nmea_burst(burst);
  assert(sim.fix_type == 1);

  in.sats_used = 8;
  in.signal = false;
  neo6m_sim_step(&sim, 1000, &in, burst, sizeof(burst));
  validate_nmea_burst(burst);
  assert(sim.fix_type == 1);

  printf("[PASS] All NEO-6M NMEA simulation tests passed! Sample epoch:\n");
  in.signal = true;
  neo6m_sim_step(&sim, 1000, &in, burst, sizeof(burst));
  validate_nmea_burst(burst);
  printf("%s", burst);
  return 0;
}
