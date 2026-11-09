/*
 * ble_telemetry.h - Wireless BLE UART Telemetry Transmitter for Auto-CPR.
 *
 * Uses the same Service UUID configured in the Flutter app's TelemetryRepository:
 *   Service UUID:           4FAFC201-1FB5-459E-8FCC-C5C9C331914B
 *   TX Characteristic UUID: BEB5483E-36E1-4688-B7F5-EA07361B26A8 (Notify / Read)
 *
 * Streams the exact same 14-column CSV telemetry line over BLE notifications
 * that the firmware prints to Serial (and Wokwi streams over TCP :4000).
 * That way, zero parser or UI changes are needed in Flutter when moving from
 * Wokwi simulation to wireless physical ESP32 testing.
 */
#pragma once

#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define OTOCPR_BLE_SERVICE_UUID        "4FAFC201-1FB5-459E-8FCC-C5C9C331914B"
#define OTOCPR_BLE_CHARACTERISTIC_UUID "BEB5483E-36E1-4688-B7F5-EA07361B26A8"

class OtoCprBleTelemetry : public BLEServerCallbacks {
public:
  void begin(const char *deviceName = "OtoCPR Unit 01") {
    BLEDevice::init(deviceName);
    BLEDevice::setMTU(247); // Allow full ~120-byte CSV line in a single BLE packet

    server_ = BLEDevice::createServer();
    server_->setCallbacks(this);

    BLEService *service = server_->createService(OTOCPR_BLE_SERVICE_UUID);
    txChar_ = service->createCharacteristic(
        OTOCPR_BLE_CHARACTERISTIC_UUID,
        BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);
    txChar_->addDescriptor(new BLE2902());

    service->start();

    BLEAdvertising *advertising = BLEDevice::getAdvertising();
    advertising->addServiceUUID(OTOCPR_BLE_SERVICE_UUID);
    advertising->setScanResponse(true);
    advertising->setMinPreferred(0x06);
    BLEDevice::startAdvertising();
  }

  void notifyLine(const char *csvLine) {
    if (!clientConnected_ || !txChar_ || !csvLine) return;
    txChar_->setValue((uint8_t *)csvLine, strlen(csvLine));
    txChar_->notify();
  }

  bool isConnected() const { return clientConnected_; }

  void onConnect(BLEServer *pServer) override {
    (void)pServer;
    clientConnected_ = true;
  }

  void onDisconnect(BLEServer *pServer) override {
    clientConnected_ = false;
    // Immediately resume advertising for 1-Tap Reconnect from the Flutter app
    if (pServer) {
      pServer->startAdvertising();
    }
  }

private:
  BLEServer *server_ = nullptr;
  BLECharacteristic *txChar_ = nullptr;
  volatile bool clientConnected_ = false;
};
