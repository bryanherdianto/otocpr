# OtoCPR ESP32 Firmware

This folder contains the PlatformIO firmware for the DOIT ESP32 DevKit V1. It runs motor control, load cell reading, a 20x4 LCD display, NEO-6M GPS tracking, and a Wokwi simulation.

## Pin Mapping

| Part               | Module Pin    | ESP32 Pin         | Notes                        |
| :----------------- | :------------ | :---------------- | :--------------------------- |
| NEO-6M GPS         | VCC / GND     | 3V3 / GND         | Power and ground             |
| NEO-6M GPS         | TX            | GPIO 16 (RX2)     | Module TX to ESP32 RX2       |
| NEO-6M GPS         | RX            | GPIO 17 (TX2)     | Module RX to ESP32 TX2       |
| HX711 Load Cell    | DT / SCK      | GPIO 19 / GPIO 18 | Weight sensor data and clock |
| 20x4 I2C LCD       | SDA / SCL     | GPIO 21 / GPIO 22 | Display at I2C address 0x27  |
| IBT_2 Motor Driver | RPWM / LPWM   | GPIO 25 / GPIO 26 | Motor speed PWM              |
| IBT_2 Motor Driver | R_EN and L_EN | GPIO 27           | Motor enable (active HIGH)   |
| Motor Encoder      | ChA / ChB     | GPIO 32 / GPIO 33 | Encoder channels A and B     |

## Build Environments

Run PlatformIO commands from the Firmware folder, or add -d Firmware from the repo root.

### esp32doit-devkit-v1 (Default)

Used for both real hardware and Wokwi. Reads GPS data over Serial2 (GPIO 16 and 17).

```powershell
pio run -e esp32doit-devkit-v1
```

### esp32doit-devkit-v1-gps-sim

Simulates a NEO-6M GPS module inside the ESP32 so no external GPS hardware is needed.

```powershell
pio run -e esp32doit-devkit-v1-gps-sim -t upload -t monitor
```

### esp32doit-devkit-v1-ble

Turns on Bluetooth (BLE) as OtoCPR Unit 01 and sends the same CSV data wirelessly to the Flutter app.

```powershell
pio run -e esp32doit-devkit-v1-ble -t upload -t monitor
```

### esp32doit-devkit-v1-legacy

Builds the original firmware without GPS (-DENABLE_GPS=0).

```powershell
pio run -e esp32doit-devkit-v1-legacy
```

### native

Runs the GPS simulation tests on your computer.

```powershell
pio test -e native
```

## Running in Wokwi (VS Code)

1. Build the default environment first (pio run -e esp32doit-devkit-v1).
2. Open [diagram.json](./diagram.json) in VS Code, or press F1, run Wokwi: Select Config File to pick [wokwi.toml](./wokwi.toml), then run Wokwi: Start Simulator.
3. Click Start Simulation.
   - Serial Monitor prints a 14-column CSV line every 200 ms:
     ```text
     Time(ms),Set_RPM,Actual_RPM,PWM,Raw_Counts,Freq_Hz,LoadCell,GPS_Fix,Latitude,Longitude,Satellites,Speed_kmh,Altitude_m,GPS_UTC
     ```
   - The 20x4 LCD switches every 4 seconds between the motor screen and the GPS screen.
   - Click the gps-neo6m chip to adjust speed, heading, satellites, and signal strength. Set signal to 0 or satellites below 3 to test losing GPS lock.
   - Use the HX711 weight slider and rotary encoder to test the load cell and motor control.

## Saving CSV Logs

From Wokwi while the simulation is running:

```powershell
python log_serial.py --wokwi
```

From a physical ESP32 over USB:

```powershell
python log_serial.py --port COM3
```

## Connecting to the Flutter App

Both Wokwi and Bluetooth send the same CSV data into [telemetry_repository.dart](../lib/services/telemetry_repository.dart).

With Wokwi:

1. Start the Wokwi simulation in VS Code (opens local port 4000).
2. Run the Flutter app (Windows or Android).
3. In the Robotic System card, open the menu and choose Connect Wokwi Simulator (:4000), or pair OtoCPR Wokwi Simulator.

With physical hardware over Bluetooth:

1. Flash the BLE build:
   ```powershell
   pio run -e esp32doit-devkit-v1-ble -t upload
   ```
2. Pass the Bluetooth stream to TelemetryRepository.instance.attachBleCharacteristicStream(stream) in the app.

## Rebuilding the Wokwi GPS Chip

A compiled chips/gps-neo6m.chip.wasm file is already included. If you edit [chips/gps-neo6m.chip.c](./chips/gps-neo6m.chip.c) or [lib/Neo6mNmea/neo6m_nmea.c](./lib/Neo6mNmea/neo6m_nmea.c), rebuild it with [Wokwi CLI](https://docs.wokwi.com/wokwi-ci/cli-installation):

```powershell
wokwi-cli chip compile chips/gps-neo6m.chip.c lib/Neo6mNmea/neo6m_nmea.c -o chips/gps-neo6m.chip.wasm
```
