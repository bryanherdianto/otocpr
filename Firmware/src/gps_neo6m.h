/*
 * gps_neo6m.h - NEO-6M GPS driver for the Auto-CPR firmware.
 *
 * Two data sources share the same TinyGPS++ parser and the same public API:
 *
 *   Neo6mGps::Source::Uart      - a real NEO-6M (or the Wokwi "chip-neo6m"
 *                                 custom part) connected to a HardwareSerial.
 *   Neo6mGps::Source::Emulator  - an in-firmware NEO-6M emulator that
 *                                 generates the exact same NMEA stream
 *                                 (see lib/Neo6mNmea) and feeds it to the
 *                                 parser at the real 9600-baud byte rate.
 *                                 No GPS hardware is needed.
 */
#pragma once

#include <Arduino.h>
#include <TinyGPSPlus.h>

#include "neo6m_nmea.h"

class Neo6mGps {
public:
  enum class Source { None, Uart, Emulator };

  // Real module (or Wokwi custom chip) on a hardware UART.
  void beginUart(HardwareSerial &port, int8_t rxPin, int8_t txPin, uint32_t baud = 9600);

  // In-firmware emulator. `rateMs` = navigation update period (NEO-6M default 1000 ms).
  void beginEmulator(const neo6m_sim_config_t &cfg, const neo6m_sim_inputs_t &inputs,
                     uint32_t baud = 9600, uint32_t rateMs = 1000);

  // Call as often as possible from loop(); never blocks.
  void update();

  // Optional: mirror every raw NMEA byte to a stream (debugging).
  void setEcho(Stream *stream) { echo_ = stream; }

  // Live emulator inputs (speed, course, satellites, signal...). Only
  // meaningful when the source is Emulator.
  neo6m_sim_inputs_t &emulatorInputs() { return simIn_; }

  Source source() const { return source_; }

  // --- Navigation data --------------------------------------------------
  bool hasFix();              // valid location updated within the last 2 s
  bool isAlive() const;       // any NMEA byte received within the last 3 s
  double latitude();          // degrees, +N
  double longitude();         // degrees, +E
  double altitudeMeters();
  double speedKmph();
  double courseDeg();
  uint32_t satellites();
  double hdop();
  bool hasDateTime();
  void formatUtcDateTime(char *buf, size_t cap);

  // Diagnostics
  uint32_t charsProcessed() const { return gps_.charsProcessed(); }
  uint32_t sentencesWithFix() const { return gps_.sentencesWithFix(); }
  uint32_t failedChecksum() const { return gps_.failedChecksum(); }

  TinyGPSPlus &parser() { return gps_; }

private:
  void feed(char c);
  void updateEmulator();

  TinyGPSPlus gps_;
  Source source_ = Source::None;
  HardwareSerial *port_ = nullptr;
  Stream *echo_ = nullptr;
  uint32_t lastByteMs_ = 0;
  bool anyByte_ = false;

  // Emulator state
  neo6m_sim_t sim_{};
  neo6m_sim_inputs_t simIn_{};
  char burst_[NEO6M_BURST_MAX];
  size_t burstLen_ = 0;
  size_t burstPos_ = 0;
  uint32_t burstStartUs_ = 0;
  uint32_t lastEpochMs_ = 0;
  uint32_t rateMs_ = 1000;
  uint32_t bytesPerSec_ = 960; // 9600 baud, 8N1 = 10 bits/byte
};
