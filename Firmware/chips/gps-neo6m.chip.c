/*
 * gps-neo6m.chip.c - Wokwi Custom Chip simulating a u-blox NEO-6M GPS module.
 *
 * Streams standard NMEA 0183 v2.3 sentences ($GPRMC, $GPVTG, $GPGGA, $GPGSA,
 * $GPGSV, $GPGLL) over 9600-baud UART TX at 1 Hz using the shared Neo6mNmea
 * simulation engine (../lib/Neo6mNmea/neo6m_nmea.c).
 *
 * Interactive controls (defined in gps-neo6m.chip.json) allow live tuning of:
 *   - speedKmh   (0..120 km/h)
 *   - courseDeg  (0..359 deg)
 *   - satellites (0..12)
 *   - signal     (0 = lost / indoors, 1 = clear sky)
 */
#include "wokwi-api.h"
#include "../lib/Neo6mNmea/neo6m_nmea.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define UPDATE_PERIOD_US 1000000u /* 1 Hz (NEO-6M factory default) */

typedef struct {
  uart_dev_t uart;
  pin_t vcc_pin;
  pin_t gnd_pin;
  uint32_t attr_speed_kmh;
  uint32_t attr_course_deg;
  uint32_t attr_satellites;
  uint32_t attr_signal;

  neo6m_sim_t sim;
  char tx_buf[NEO6M_BURST_MAX];
  size_t tx_len;
  size_t tx_pos;
  bool tx_busy;
} chip_state_t;

static void send_next_chunk(chip_state_t *chip) {
  if (chip->tx_pos >= chip->tx_len) {
    chip->tx_busy = false;
    return;
  }

  /* Send one NMEA sentence (<= 82 bytes) per uart_write call for clean FIFO pacing. */
  const char *start = chip->tx_buf + chip->tx_pos;
  size_t rem = chip->tx_len - chip->tx_pos;
  const char *lf = (const char *)memchr(start, '\n', rem);
  size_t chunk = lf ? (size_t)(lf - start + 1) : rem;

  if (uart_write(chip->uart, (uint8_t *)start, (uint32_t)chunk)) {
    chip->tx_pos += chunk;
    chip->tx_busy = true;
  } else {
    chip->tx_busy = false;
  }
}

static void on_uart_write_done(void *user_data) {
  chip_state_t *chip = (chip_state_t *)user_data;
  send_next_chunk(chip);
}

static void on_uart_rx_data(void *user_data, uint8_t byte) {
  /* Real NEO-6M accepts UBX/NMEA config bytes on RX; silently consume them. */
  (void)user_data;
  (void)byte;
}

static void on_timer_tick(void *user_data) {
  chip_state_t *chip = (chip_state_t *)user_data;

  neo6m_sim_inputs_t in;
  neo6m_sim_default_inputs(&in);
  in.speed_kmh = (double)attr_read_float(chip->attr_speed_kmh);
  in.course_deg = (double)attr_read_float(chip->attr_course_deg);
  in.sats_used = (uint8_t)attr_read(chip->attr_satellites);
  in.signal = attr_read(chip->attr_signal) != 0;

  chip->tx_len = neo6m_sim_step(&chip->sim, 1000, &in, chip->tx_buf, sizeof(chip->tx_buf));
  chip->tx_pos = 0;
  if (!chip->tx_busy && chip->tx_len > 0) {
    send_next_chunk(chip);
  }
}

void chip_init(void) {
  chip_state_t *chip = (chip_state_t *)calloc(1, sizeof(chip_state_t));

  chip->vcc_pin = pin_init("VCC", INPUT);
  chip->gnd_pin = pin_init("GND", INPUT);

  uint32_t attr_lat = attr_init_float("latitude", -6.2088f);
  uint32_t attr_lon = attr_init_float("longitude", 106.8456f);
  uint32_t attr_alt = attr_init_float("altitude", 8.0f);
  uint32_t attr_ttff = attr_init("ttffMs", 2000u);

  chip->attr_speed_kmh = attr_init_float("speedKmh", 18.0f);
  chip->attr_course_deg = attr_init_float("courseDeg", 25.9f);
  chip->attr_satellites = attr_init("satellites", 8u);
  chip->attr_signal = attr_init("signal", 1u);

  neo6m_sim_config_t cfg;
  neo6m_sim_default_config(&cfg);
  cfg.start_lat_deg = (double)attr_read_float(attr_lat);
  cfg.start_lon_deg = (double)attr_read_float(attr_lon);
  cfg.altitude_m = (double)attr_read_float(attr_alt);
  cfg.ttff_ms = attr_read(attr_ttff);
  neo6m_sim_init(&chip->sim, &cfg);

  const uart_config_t uart_cfg = {
      .tx = pin_init("TX", INPUT_PULLUP),
      .rx = pin_init("RX", INPUT),
      .baud_rate = 9600,
      .rx_data = on_uart_rx_data,
      .write_done = on_uart_write_done,
      .user_data = chip,
  };
  chip->uart = uart_init(&uart_cfg);

  const timer_config_t timer_cfg = {
      .callback = on_timer_tick,
      .user_data = chip,
  };
  timer_t timer = timer_init(&timer_cfg);
  timer_start(timer, UPDATE_PERIOD_US, true);

  printf("NEO-6M GPS Custom Chip initialized (9600 8N1, 1 Hz)\n");
}
