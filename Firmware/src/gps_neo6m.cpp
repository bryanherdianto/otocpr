/*
 * gps_neo6m.cpp - NEO-6M GPS driver for the Auto-CPR firmware.
 */
#include "gps_neo6m.h"

void Neo6mGps::beginUart(HardwareSerial &port, int8_t rxPin, int8_t txPin, uint32_t baud) {
  source_ = Source::Uart;
  port_ = &port;
  // NMEA bursts are ~500 bytes/s; give the driver room while the LCD/I2C
  // or HX711 code keeps the loop busy.
  port_->setRxBufferSize(1024);
  port_->begin(baud, SERIAL_8N1, rxPin, txPin);
}

void Neo6mGps::beginEmulator(const neo6m_sim_config_t &cfg, const neo6m_sim_inputs_t &inputs,
                             uint32_t baud, uint32_t rateMs) {
  source_ = Source::Emulator;
  neo6m_sim_init(&sim_, &cfg);
  simIn_ = inputs;
  rateMs_ = rateMs ? rateMs : 1000;
  bytesPerSec_ = baud / 10 ? baud / 10 : 960;
  burstLen_ = burstPos_ = 0;
  lastEpochMs_ = millis();
}

void Neo6mGps::feed(char c) {
  gps_.encode(c);
  lastByteMs_ = millis();
  anyByte_ = true;
  if (echo_) echo_->write(c);
}

void Neo6mGps::updateEmulator() {
  const uint32_t now = millis();

  if (now - lastEpochMs_ >= rateMs_) {
    // Flush the remainder of the previous burst so no sentence is cut.
    while (burstPos_ < burstLen_) feed(burst_[burstPos_++]);

    // Keep simulated time locked to the update rate; resync if we fell far behind.
    if (now - lastEpochMs_ > 5 * rateMs_) lastEpochMs_ = now - rateMs_;
    lastEpochMs_ += rateMs_;

    burstLen_ = neo6m_sim_step(&sim_, rateMs_, &simIn_, burst_, sizeof(burst_));
    burstPos_ = 0;
    burstStartUs_ = micros();
  }

  // Deliver bytes at the real UART byte rate, like a physical module would.
  if (burstPos_ < burstLen_) {
    uint64_t due = (uint64_t)(micros() - burstStartUs_) * bytesPerSec_ / 1000000ULL;
    if (due > burstLen_) due = burstLen_;
    while (burstPos_ < due) feed(burst_[burstPos_++]);
  }
}

void Neo6mGps::update() {
  switch (source_) {
  case Source::Uart:
    while (port_->available() > 0) feed((char)port_->read());
    break;
  case Source::Emulator:
    updateEmulator();
    break;
  default:
    break;
  }
}

bool Neo6mGps::hasFix() {
  return gps_.location.isValid() && gps_.location.age() < 2000;
}

bool Neo6mGps::isAlive() const {
  return anyByte_ && (millis() - lastByteMs_) < 3000;
}

double Neo6mGps::latitude() { return gps_.location.isValid() ? gps_.location.lat() : 0.0; }
double Neo6mGps::longitude() { return gps_.location.isValid() ? gps_.location.lng() : 0.0; }
double Neo6mGps::altitudeMeters() { return gps_.altitude.isValid() ? gps_.altitude.meters() : 0.0; }
double Neo6mGps::speedKmph() { return gps_.speed.isValid() ? gps_.speed.kmph() : 0.0; }
double Neo6mGps::courseDeg() { return gps_.course.isValid() ? gps_.course.deg() : 0.0; }
uint32_t Neo6mGps::satellites() { return gps_.satellites.isValid() ? gps_.satellites.value() : 0; }
double Neo6mGps::hdop() { return gps_.hdop.isValid() ? gps_.hdop.hdop() : 99.99; }

bool Neo6mGps::hasDateTime() {
  return gps_.date.isValid() && gps_.time.isValid() && gps_.date.year() >= 2020;
}

void Neo6mGps::formatUtcDateTime(char *buf, size_t cap) {
  if (!cap) return;
  if (!hasDateTime()) {
    snprintf(buf, cap, "INVALID");
    return;
  }
  snprintf(buf, cap, "%04u-%02u-%02uT%02u:%02u:%02uZ",
           (unsigned)gps_.date.year(),
           (unsigned)gps_.date.month(),
           (unsigned)gps_.date.day(),
           (unsigned)gps_.time.hour(),
           (unsigned)gps_.time.minute(),
           (unsigned)gps_.time.second());
}
