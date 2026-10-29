#include <Arduino.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <HX711.h>

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
  Serial.println("Time(ms),Set_RPM,Actual_RPM,PWM,Raw_Counts,Freq_Hz,LoadCell");

  // Load Cell setup
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  scale.set_scale(); // Set calibration factor here later
  scale.tare();      // Auto-zero

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
    Serial.println(loadCellValue);
    
    // Update LCD
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
  
  driveMotor(motorPWM, true); // Change to 'false' for CCW rotation
}