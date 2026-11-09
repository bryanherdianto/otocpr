#include <Arduino.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <HX711.h>

// --- NEO-6M GPS (UART2) ---
// Build-time switches (set in platformio.ini -> build_flags):
//   ENABLE_GPS=0        -> compile the original firmware with no GPS at all
//   GPS_USE_EMULATOR=1  -> use the in-firmware NEO-6M emulator instead of a
//                          physical module (no GPS hardware required)
//   GPS_ECHO_NMEA=1     -> mirror the raw NMEA stream to Serial (debug only,
//                          breaks the CSV output)
//   WOKWI_SIMULATION=1  -> set by the [env:wokwi] build (Wokwi simulator)
#ifndef ENABLE_GPS
#define ENABLE_GPS 1
#endif
#ifndef GPS_USE_EMULATOR
#define GPS_USE_EMULATOR 0
#endif
#ifndef GPS_ECHO_NMEA
#define GPS_ECHO_NMEA 0
#endif
#ifndef GPS_HUMAN_LOG
#define GPS_HUMAN_LOG 0
#endif
#ifndef LCD_CYCLE_GPS
#define LCD_CYCLE_GPS 1
#endif
#ifndef ENABLE_BLE
#define ENABLE_BLE 0
#endif

#if ENABLE_BLE
#include "ble_telemetry.h"
OtoCprBleTelemetry bleTelemetry;
#endif

#if ENABLE_GPS
#include "gps_neo6m.h"

// NEO-6M module header mapping (GY-NEO6MV2):
// VCC -> 3.3V or 5V
// GND -> GND
// TX  -> Pin 16 (ESP32 RX2)
// RX  -> Pin 17 (ESP32 TX2)
const int GPS_RX_PIN = 16;       // ESP32 receives on this pin (module TX)
const int GPS_TX_PIN = 17;       // ESP32 transmits on this pin (module RX)
const uint32_t GPS_BAUD = 9600;  // NEO-6M factory default
Neo6mGps gps;

// Emulator defaults (only used when GPS_USE_EMULATOR=1); override with -D flags.
#ifndef GPS_SIM_LAT
#define GPS_SIM_LAT -6.2088
#endif
#ifndef GPS_SIM_LON
#define GPS_SIM_LON 106.8456
#endif
#ifndef GPS_SIM_SPEED_KMH
#define GPS_SIM_SPEED_KMH 18.0
#endif
#ifndef GPS_SIM_COURSE_DEG
#define GPS_SIM_COURSE_DEG 25.9
#endif
#ifndef GPS_SIM_SATS
#define GPS_SIM_SATS 8
#endif
#endif // ENABLE_GPS

// --- Load Cell Pins (HX711) ---
const int LOADCELL_DOUT_PIN = 19; // Connect to DT
const int LOADCELL_SCK_PIN = 18;  // Connect to SCK
HX711 scale;
float loadCellValue = 0.0;

// --- LCD Display Pins (I2C) ---
// By default, the ESP32 uses the following pins for I2C:
// SDA -> Pin 21
// SCL -> Pin 22
// Set the LCD address to 0x27 for a 20 chars and 4 line display
LiquidCrystal_I2C lcd(0x27, 20, 4);

// --- IBT_2 Motor Driver Pins ---
// Board Header mapping:
// VCC  -> 5V or 3.3V
// GND  -> GND
// R_IS -> Not Connected (Current Sense)
// L_IS -> Not Connected (Current Sense)
// R_EN & L_EN -> Pin 27 (Connect both to this pin)
// RPWM -> Pin 25
// LPWM -> Pin 26
const int motorR_PWM = 25;
const int motorL_PWM = 26;
const int motorEnable = 27;

const int encoderChA = 32; 
const int encoderChB = 33; 

// --- Motor & Encoder Variables ---
volatile int encoder_pos = 0; 
float countSpeed_PPM;
float gearRatio = 65.0;  // Adjust if your motor's gear ratio is different
float encoderPPR = 11.0; // Based on the RoboticX spec (11 PPR)
float encoderSpeedRPM;   
float gearBoxoutputSpeedRPM; 
int rawEncoderCounts = 0;
float rawFrequencyHz = 0.0;

// --- PID & Speed Control Variables ---
int motorSetSpeed = 100; // Desired motor speed in RPM
int motorPWM = 0;
double error = 0;
double error_I = 0;
double error_D = 0;
double past_error = 0;
const float Kp = 2.0;  
const float Ki = 1.0;     
const float Kd = 0.0;  

// --- Timer Variables ---
unsigned long timeStamp = 0;
unsigned long timeElapsed = 0; 
int sampleRate = 200; // Speed measurement calculation rate in ms

portMUX_TYPE mux = portMUX_INITIALIZER_UNLOCKED;

// --- ESP32 PWM Channels (For backward compatibility) ---
const int rPwmChannel = 0;
const int lPwmChannel = 1;
const int pwmFreq = 5000;
const int pwmResolution = 8;

// ISR must be in IRAM for ESP32
void IRAM_ATTR encoderISR()
{   
  portENTER_CRITICAL_ISR(&mux);
  if (digitalRead(encoderChB) == HIGH) {
    encoder_pos++;
  } else {
    encoder_pos--;
  }  
  portEXIT_CRITICAL_ISR(&mux);
}

void setup()
{
  Serial.begin(115200);  
  
  // Print CSV Header
  Serial.print("Time(ms),Set_RPM,Actual_RPM,PWM,Raw_Counts,Freq_Hz,LoadCell");
#if ENABLE_GPS
  // Extra GPS columns are appended so existing CSV consumers keep working.
  Serial.print(",GPS_Fix,Latitude,Longitude,Satellites,Speed_kmh,Altitude_m,GPS_UTC");
#endif
  Serial.println();

#if ENABLE_GPS
  // GPS setup (started early so the module/emulator can begin acquiring)
#if GPS_USE_EMULATOR
  neo6m_sim_config_t gpsCfg;
  neo6m_sim_default_config(&gpsCfg);
  gpsCfg.start_lat_deg = GPS_SIM_LAT;
  gpsCfg.start_lon_deg = GPS_SIM_LON;
  gpsCfg.seed = (uint32_t)esp_random();
  neo6m_sim_inputs_t gpsIn;
  neo6m_sim_default_inputs(&gpsIn);
  gpsIn.speed_kmh = GPS_SIM_SPEED_KMH;
  gpsIn.course_deg = GPS_SIM_COURSE_DEG;
  gpsIn.sats_used = GPS_SIM_SATS;
  gps.beginEmulator(gpsCfg, gpsIn, GPS_BAUD);
#else
  gps.beginUart(Serial2, GPS_RX_PIN, GPS_TX_PIN, GPS_BAUD);
#endif
#if GPS_ECHO_NMEA
  gps.setEcho(&Serial);
#endif
#endif // ENABLE_GPS

#if ENABLE_BLE
  // Wireless BLE UART setup (for real ESP32 hardware -> Flutter app)
  bleTelemetry.begin("OtoCPR Unit 01");
#endif

  // Load Cell setup
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  scale.set_scale(); // Set calibration factor here later
  if (scale.wait_ready_timeout(1000)) {
    scale.tare();      // Auto-zero
  }

  // Initialize LCD
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("ESP32 Motor Control");
  lcd.setCursor(0, 1);
  lcd.print("Initializing...");
  delay(1000);
  lcd.clear();

  // Encoder setup
  pinMode(encoderChA, INPUT_PULLUP);  
  pinMode(encoderChB, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(encoderChA), encoderISR, RISING);

  // Motor driver setup
  pinMode(motorEnable, OUTPUT);
  digitalWrite(motorEnable, HIGH); // Enable both R_EN and L_EN

  // Initialize PWM channels (Handles both old and new ESP32 Cores)
#if ESP_ARDUINO_VERSION_MAJOR >= 3
  analogWriteFrequency(pwmFreq);
  analogWriteResolution(pwmResolution);
  pinMode(motorR_PWM, OUTPUT);
  pinMode(motorL_PWM, OUTPUT);
#else
  ledcSetup(rPwmChannel, pwmFreq, pwmResolution);
  ledcAttachPin(motorR_PWM, rPwmChannel);
  
  ledcSetup(lPwmChannel, pwmFreq, pwmResolution);
  ledcAttachPin(motorL_PWM, lPwmChannel);
#endif
}

void getSpeed()
{  
  int current_pos;
  
  portENTER_CRITICAL(&mux);
  current_pos = encoder_pos;
  encoder_pos = 0; 
  portEXIT_CRITICAL(&mux);

  rawEncoderCounts = current_pos;
  rawFrequencyHz = 1000.0 * (float)current_pos / timeElapsed; // Pulses per second (Hz)

  countSpeed_PPM = 1000.0 * 60.0 * (float)current_pos / timeElapsed; 
  encoderSpeedRPM = countSpeed_PPM / encoderPPR; 
  gearBoxoutputSpeedRPM = encoderSpeedRPM / gearRatio; 
}

void computePID()
{
  error = motorSetSpeed - gearBoxoutputSpeedRPM;
  error_I = error_I + error;
  error_D = past_error - error;
  past_error = error;
  
  if (error_I > 200) error_I = 0; // limit integral windup
  
  motorPWM = Kp * error + Ki * error_I + Kd * error_D;
  
  if (motorPWM >= 255) motorPWM = 255;
  else if (motorPWM <= 0) motorPWM = 0;
}

void driveMotor(int pwm, bool clockwise)
{
#if ESP_ARDUINO_VERSION_MAJOR >= 3
  if (clockwise) {
    analogWrite(motorL_PWM, 0);
    analogWrite(motorR_PWM, pwm);
  } else {
    analogWrite(motorR_PWM, 0);
    analogWrite(motorL_PWM, pwm);
  }
#else
  if (clockwise) {
    ledcWrite(lPwmChannel, 0);
    ledcWrite(rPwmChannel, pwm);
  } else {
    ledcWrite(rPwmChannel, 0);
    ledcWrite(lPwmChannel, pwm);
  }
#endif
}

void loop()
{
  // Non-blocking Load Cell read
  if (scale.is_ready()) {
    loadCellValue = scale.get_units(1); // Read once without blocking the loop
  }

#if ENABLE_GPS
  // Non-blocking GPS read (drains UART2 / runs the emulator)
  gps.update();
#endif

  timeElapsed = millis() - timeStamp; 
  if (timeElapsed >= sampleRate)
  {
    getSpeed();
    computePID();
    
    timeStamp = millis();
    
    // Output formatted as CSV
    Serial.print(millis());
    Serial.print(",");
    Serial.print(motorSetSpeed);
    Serial.print(",");
    Serial.print(gearBoxoutputSpeedRPM);
    Serial.print(",");
    Serial.print(motorPWM);
    Serial.print(",");
    Serial.print(rawEncoderCounts);
    Serial.print(",");
    Serial.print(rawFrequencyHz);
    Serial.print(",");
    Serial.print(loadCellValue);
#if ENABLE_GPS
    Serial.print(",");
    Serial.print(gps.hasFix() ? 1 : 0);
    Serial.print(",");
    Serial.print(gps.latitude(), 6);
    Serial.print(",");
    Serial.print(gps.longitude(), 6);
    Serial.print(",");
    Serial.print(gps.satellites());
    Serial.print(",");
    Serial.print(gps.speedKmph(), 2);
    Serial.print(",");
    Serial.print(gps.altitudeMeters(), 1);
    Serial.print(",");
    char utcBuf[24];
    gps.formatUtcDateTime(utcBuf, sizeof(utcBuf));
    Serial.print(utcBuf);
#endif
    Serial.println();

#if ENABLE_BLE
    if (bleTelemetry.isConnected()) {
      char bleLine[192];
#if ENABLE_GPS
      snprintf(bleLine, sizeof(bleLine),
               "%lu,%d,%.2f,%d,%d,%.2f,%.2f,%d,%.6f,%.6f,%lu,%.2f,%.1f,%s
",
               millis(), motorSetSpeed, gearBoxoutputSpeedRPM, motorPWM,
               rawEncoderCounts, rawFrequencyHz, loadCellValue,
               gps.hasFix() ? 1 : 0, gps.latitude(), gps.longitude(),
               (unsigned long)gps.satellites(), gps.speedKmph(),
               gps.altitudeMeters(), utcBuf);
#else
      snprintf(bleLine, sizeof(bleLine), "%lu,%d,%.2f,%d,%d,%.2f,%.2f
",
               millis(), motorSetSpeed, gearBoxoutputSpeedRPM, motorPWM,
               rawEncoderCounts, rawFrequencyHz, loadCellValue);
#endif
      bleTelemetry.notifyLine(bleLine);
    }
#endif

#if ENABLE_GPS && GPS_HUMAN_LOG
    static unsigned long lastGpsPrintMs = 0;
    if (millis() - lastGpsPrintMs >= 1000) {
      lastGpsPrintMs = millis();
      if (millis() > 5000 && gps.charsProcessed() < 10) {
        Serial.println(F("[GPS] No GPS data received: check wiring"));
      } else if (gps.hasFix()) {
        Serial.print(F("[GPS] Lat: "));
        Serial.print(gps.latitude(), 6);
        Serial.print(F(" | Lon: "));
        Serial.print(gps.longitude(), 6);
        Serial.print(F(" | Alt: "));
        Serial.print(gps.altitudeMeters(), 1);
        Serial.print(F(" m | Spd: "));
        Serial.print(gps.speedKmph(), 1);
        Serial.print(F(" km/h | Sats: "));
        Serial.print(gps.satellites());
        Serial.print(F(" | UTC: "));
        Serial.println(utcBuf);
      } else {
        Serial.println(F("[GPS] Acquiring satellite fix..."));
      }
    }
#endif
    
    // Update LCD
#if ENABLE_GPS && LCD_CYCLE_GPS
    bool showGpsPage = ((millis() / 4000) % 2 == 1);
    static bool prevGpsPage = false;
    if (showGpsPage != prevGpsPage) {
      lcd.clear();
      prevGpsPage = showGpsPage;
    }
    if (showGpsPage) {
      char line[21];
      if (!gps.isAlive()) {
        snprintf(line, sizeof(line), "%-20s", "GPS: Check Wiring");
      } else if (gps.hasFix()) {
        snprintf(line, sizeof(line), "GPS:FIX Sats:%-2lu     ", (unsigned long)gps.satellites());
      } else {
        snprintf(line, sizeof(line), "%-20s", "GPS: Searching...");
      }
      lcd.setCursor(0, 0);
      lcd.print(line);

      if (gps.hasFix()) {
        snprintf(line, sizeof(line), "Lat:%12.6f    ", gps.latitude());
        lcd.setCursor(0, 1);
        lcd.print(line);

        snprintf(line, sizeof(line), "Lon:%12.6f    ", gps.longitude());
        lcd.setCursor(0, 2);
        lcd.print(line);

        snprintf(line, sizeof(line), "V:%5.1fkmh A:%4.0fm  ", gps.speedKmph(), gps.altitudeMeters());
        lcd.setCursor(0, 3);
        lcd.print(line);
      } else {
        snprintf(line, sizeof(line), "RX Bytes:%-10lu ", (unsigned long)gps.charsProcessed());
        lcd.setCursor(0, 1);
        lcd.print(line);
        lcd.setCursor(0, 2);
        lcd.print("Waiting for 3D lock ");
        lcd.setCursor(0, 3);
        lcd.print("UART2 9600 8N1      ");
      }
    } else
#endif
    {
    // Line 0: Setpoint
    lcd.setCursor(0, 0);
    lcd.print("Setpoint: ");
    lcd.print(motorSetSpeed);
    lcd.print("    "); 
    
    // Line 1: Stopwatch (MM:SS)
    unsigned long totalSeconds = millis() / 1000;
    unsigned long minutes = totalSeconds / 60;
    unsigned long seconds = totalSeconds % 60;
    
    lcd.setCursor(0, 1);
    lcd.print("Stopwatch:");
    if (minutes < 10) lcd.print("0");
    lcd.print(minutes);
    lcd.print(":");
    if (seconds < 10) lcd.print("0");
    lcd.print(seconds);
    lcd.print("   "); 
    
    // Line 2: Actual RPM
    lcd.setCursor(0, 2);
    lcd.print("Act RPM:  ");
    lcd.print(gearBoxoutputSpeedRPM, 1); 
    lcd.print("    ");
    
    // Line 3: PWM Output
    lcd.setCursor(0, 3);
    lcd.print("PWM Out:  ");
    lcd.print(motorPWM);
    lcd.print("    ");
    }
  }
  
  driveMotor(motorPWM, true); // Change to 'false' for CCW rotation
}