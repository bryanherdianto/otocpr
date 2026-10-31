/*
 * neo6m_nmea.h - u-blox NEO-6M NMEA sentence generator (plain C99).
 *
 * This module models the default NMEA output of a u-blox NEO-6M GPS receiver
 * (NMEA 0183 v2.3, "GP" talker, 9600 baud, 1 Hz):
 *
 *     $GPRMC, $GPVTG, $GPGGA, $GPGSA, $GPGSV (x N), $GPGLL
 *
 * It is intentionally written in portable C with no Arduino / Wokwi
 * dependencies so the SAME source file is used by:
 *
 *   1. The ESP32 firmware (PlatformIO env "esp32doit-devkit-v1-gps-sim"),
 *      where it acts as an in-firmware NEO-6M emulator.
 *   2. The Wokwi custom chip (Firmware/chips/neo6m.chip.c), where it drives a
 *      virtual NEO-6M part that talks to the ESP32 over a real (simulated) UART.
 *   3. Host-side unit tests (Firmware/test/host/).
 *
 * Behaviour that is modelled:
 *   - Cold start: no fix until `ttff_ms` has elapsed (time becomes known at
 *     ttff/2, just like a real receiver that decodes time before position).
 *   - Signal loss (sky blocked) and low satellite count (<3 = no fix,
 *     3 = 2D fix, >=4 = 3D fix).
 *   - Movement with a given ground speed / course (great-circle approximation).
 *   - Bounded random-walk position jitter (typical +-2..3 m of a NEO-6M).
 *   - Satellite constellation with slowly drifting azimuth / elevation / SNR.
 *   - Correct NMEA checksums and ddmm.mmmmm coordinate formatting.
 */
#ifndef NEO6M_NMEA_H
#define NEO6M_NMEA_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define NEO6M_MAX_SATS 12
/* Worst-case size of one output epoch (6 sentence types, 3 GSV lines). */
#define NEO6M_BURST_MAX 1024

/* Static configuration, set once at power-up. */
typedef struct {
  double start_lat_deg;     /* Initial latitude  (+N / -S)              */
  double start_lon_deg;     /* Initial longitude (+E / -W)              */
  double altitude_m;        /* Altitude above mean sea level            */
  double geoid_sep_m;       /* Geoid separation reported in $GPGGA      */
  uint32_t start_utc_epoch; /* UTC time at power-up (UNIX seconds)      */
  uint32_t ttff_ms;         /* Time-to-first-fix after power-up         */
  uint32_t seed;            /* PRNG seed (constellation + jitter)       */
} neo6m_sim_config_t;

/* Live inputs - may be changed between steps (e.g. Wokwi chip controls). */
typedef struct {
  double speed_kmh;   /* Ground speed                                   */
  double course_deg;  /* Heading, 0 = North, 90 = East                  */
  uint8_t sats_used;  /* Satellites used in the solution (0..12)        */
  bool signal;        /* false = antenna blocked / indoors              */
  double noise_m;     /* Max. position jitter radius in metres          */
} neo6m_sim_inputs_t;

typedef struct {
  uint8_t prn;
  uint8_t elevation; /* degrees 0..90   */
  uint16_t azimuth;  /* degrees 0..359  */
  uint8_t snr;       /* dB-Hz, 0 = not tracked */
} neo6m_sv_t;

/* Internal state. Treat as opaque; read-only access is fine. */
typedef struct {
  neo6m_sim_config_t cfg;
  double lat_deg; /* true (noise free) position */
  double lon_deg;
  double jitter_n_m; /* current jitter offset, metres north */
  double jitter_e_m; /* current jitter offset, metres east  */
  uint64_t elapsed_ms;
  uint32_t rng;
  bool time_known;
  uint8_t fix_type; /* 1 = no fix, 2 = 2D, 3 = 3D (as in $GPGSA) */
  uint8_t sats_used;
  uint8_t sats_in_view;
  double hdop;
  double reported_lat_deg;
  double reported_lon_deg;
  double reported_speed_kmh;
  double reported_course_deg;
  neo6m_sv_t sv[NEO6M_MAX_SATS];
} neo6m_sim_t;

void neo6m_sim_default_config(neo6m_sim_config_t *cfg);
void neo6m_sim_default_inputs(neo6m_sim_inputs_t *in);
void neo6m_sim_init(neo6m_sim_t *sim, const neo6m_sim_config_t *cfg);

/*
 * Advance the model by `dt_ms` and write one complete NMEA epoch (all
 * sentences, CR/LF terminated) into `out`. Returns the number of bytes
 * written (excluding the terminating NUL). `out` should be at least
 * NEO6M_BURST_MAX bytes.
 */
size_t neo6m_sim_step(neo6m_sim_t *sim, uint32_t dt_ms,
                      const neo6m_sim_inputs_t *in, char *out, size_t out_size);

/* XOR checksum of everything between '$' and '*' (body without them). */
uint8_t neo6m_nmea_checksum(const char *body);

#ifdef __cplusplus
}
#endif

#endif /* NEO6M_NMEA_H */
