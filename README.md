# OtoCPR

An adaptive mechanical chest compression device (**Auto-CPR**) designed for infants. It uses dual-feedback closed-loop control (motor encoder for depth + load cell for force) and pairs with a Flutter companion app for real-time monitoring.

## Project Structure

- **`Hardware/`** — Electronic schematics, pin mappings, and Bill of Materials (`BOM.md`).
- **`Firmware/`** — Microcontroller code (ESP32-C3) built and tested with PlatformIO to control the motor, sensors, and OLED display.
- **`lib/`** — Source code for the Flutter mobile/desktop monitoring application.
- **`assets/`** — Images, icons, and static files used by the Flutter app.
- **`test/`** — Automated tests for the Flutter app.
- **`android/`, `ios/`, `windows/`, `macos/`, `linux/`, `web/`** — Platform-specific build files for running the Flutter app on different devices.
