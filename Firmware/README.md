# Auto-CPR ESP32 Firmware & NEO-6M GPS Simulation

This directory contains the PlatformIO firmware for the Auto-CPR microcontroller (DOIT ESP32 DevKit V1) extended with **u-blox NEO-6M GPS** telemetry, an in-firmware NMEA 0183 v2.3 emulator, and a complete **Wokwi** circuit + custom WebAssembly GPS chip simulation.

All original motor PID speed control, quadrature encoder ISR, HX711 load cell, I2C 20x4 LCD, and CSV serial telemetry features remain intact and can also be built in legacy mode (`-DENABLE_GPS=0`).

## Hardware & Wokwi Pin Mapping

| Peripheral             | Module Pin      | ESP32 Pin             | Notes                          |
| :--------------------- | :-------------- | :-------------------- | :----------------------------- |
| **NEO-6M GPS**         | `VCC` / `GND`   | `3V3` / `GND`         | 9600 baud, 8N1, 1 Hz NMEA      |
| **NEO-6M GPS**         | `TX`            | `GPIO 16` (`RX2`)     | Module TX -> ESP32 UART2 RX    |
| **NEO-6M GPS**         | `RX`            | `GPIO 17` (`TX2`)     | Module RX <- ESP32 UART2 TX    |
| **HX711 Load Cell**    | `DT` / `SCK`    | `GPIO 19` / `GPIO 18` | Non-blocking sample read       |
| **20x4 I2C LCD**       | `SDA` / `SCL`   | `GPIO 21` / `GPIO 22` | I2C address `0x27`             |
| **IBT_2 Motor Driver** | `RPWM` / `LPWM` | `GPIO 25` / `GPIO 26` | 5 kHz, 8-bit PWM               |
| **IBT_2 Motor Driver** | `R_EN` & `L_EN` | `GPIO 27`             | Active HIGH                    |
| **Motor Encoder**      | `ChA` / `ChB`   | `GPIO 32` / `GPIO 33` | Interrupt on `ChA` rising edge |

## PlatformIO Build Environments (`platformio.ini`)

Run commands from the `Firmware/` directory (or pass `-d Firmware` from the repository root):

1. **`esp32doit-devkit-v1` (Default — Hardware & Wokwi)**
   Reads NMEA sentences from UART2 (`Serial2`, `RX2=16`, `TX2=17`, `9600` baud) using `TinyGPSPlus`. Works identically with a physical NEO-6M module **and** with the `chip-gps-neo6m` custom chip inside Wokwi.

   ```powershell
   pio run -e esp32doit-devkit-v1
   ```

2. **`esp32doit-devkit-v1-gps-sim` (PlatformIO In-Firmware NEO-6M Emulator)**
   Runs the full NEO-6M NMEA 0183 v2.3 generator (`$GPRMC`, `$GPVTG`, `$GPGGA`, `$GPGSA`, `$GPGSV`, `$GPGLL`) inside the ESP32 firmware at 9600-baud byte pacing (`-DGPS_USE_EMULATOR=1`) and feeds `TinyGPSPlus`—no external GPS module required.

   ```powershell
   pio run -e esp32doit-devkit-v1-gps-sim -t upload -t monitor
   ```

3. **`esp32doit-devkit-v1-legacy` (Original Firmware Mode)**
   Compiles with `-DENABLE_GPS=0` for the exact pre-GPS CSV header and 4-line LCD behavior.

   ```powershell
   pio run -e esp32doit-devkit-v1-legacy
   ```

4. **`native` (Desktop Host NMEA Simulation & Unit Tests)**
   Runs the C99 NEO-6M NMEA simulation engine and checksum/trajectory test suite natively on your computer.
   ```powershell
   pio test -e native
   ```

## Running the Simulation in Wokwi for VS Code

1. Ensure `esp32doit-devkit-v1` is built (`Firmware/.pio/build/esp32doit-devkit-v1/firmware.bin` and `firmware.elf`).
2. Open [`Firmware/diagram.json`](./diagram.json) in VS Code (or press `F1` -> **Wokwi: Select Config File** and choose `Firmware/wokwi.toml`, then `F1` -> **Wokwi: Start Simulator**).
3. Click the green **Start Simulation** play button:
   - **Serial Monitor** streams 115200-baud CSV rows every 200 ms:
     ```text
     Time(ms),Set_RPM,Actual_RPM,PWM,Raw_Counts,Freq_Hz,LoadCell,GPS_Fix,Latitude,Longitude,Satellites,Speed_kmh,Altitude_m,GPS_UTC
     ```
   - **20x4 I2C LCD** alternates every 4 seconds between the original Motor PID page (`Setpoint`, `Stopwatch`, `Act RPM`, `PWM Out`) and the live NEO-6M GPS page (`GPS:FIX Sats`, `Lat`, `Lon`, `V` & `A`).
   - **Click the `gps-neo6m` chip** during simulation to open live sliders for **Speed (km/h)**, **Heading (deg)**, **Satellites Used**, and **Antenna Signal** (set Signal to `0` or Satellites `< 3` to simulate losing satellite lock).
   - Interact with the **HX711 Load Cell** weight slider and **KY-040 Rotary Encoder** to test load cell readings and closed-loop PID motor response alongside GPS.

## Logging Telemetry CSV (`log_serial.py`)

- **From Wokwi VS Code** (via `rfc2217ServerPort = 4000` in `wokwi.toml` while the simulator is running):
  ```powershell
  python log_serial.py --wokwi
  ```
- **From a physical ESP32 COM port:**
  ```powershell
  python log_serial.py --port COM3
  ```

## Rebuilding the Custom Wokwi GPS Chip (`chips/gps-neo6m.chip.wasm`)

A precompiled `chips/gps-neo6m.chip.wasm` binary is already included. If you edit [`chips/gps-neo6m.chip.c`](./chips/gps-neo6m.chip.c) or [`lib/Neo6mNmea/neo6m_nmea.c`](./lib/Neo6mNmea/neo6m_nmea.c), recompile with [Wokwi CLI](https://docs.wokwi.com/wokwi-ci/cli-installation):

```powershell
wokwi-cli chip compile chips/gps-neo6m.chip.c lib/Neo6mNmea/neo6m_nmea.c -o chips/gps-neo6m.chip.wasm
```
