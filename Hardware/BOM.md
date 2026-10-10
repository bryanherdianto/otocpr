# Prototipe Alat Kompresi Dada Mekanik (Auto-CPR) Adaptif untuk Bayi dengan Kendali Lup Tertutup Feedback Ganda

## Bill of Materials (BOM) - Tokopedia / Shopee Indonesia

| Function | Part / IC | Package | Online Shop Link | Price (IDR) |
| :--- | :--- | :--- | :--- | :--- |
| Main MCU | ESP32-C3 DevKit / SuperMini | Board Module | | |
| Buck Regulator (24V to 5V) | XL4015E1 | TO-263-5L | [IC XL4015E1](https://tk.tokopedia.com/ZSqP4fS6G/) ( minimum of 10) | Rp 80,000 |
| Motor Driver (24V) | L298N | Multiwatt15 (ZIP-15) | [IC L298N](https://tk.tokopedia.com/ZSqPV7d5P/) | Rp 8,550 |
| Level Shifter (5V to 3.3V) | BSS138 (2x) | SOT-23 | [MOSFET BSS138](https://tk.tokopedia.com/ZSqPqqVRH/) | Rp 2,295 |
| Load Cell ADC | HX711 | SOP-16 | [Load Cell HX711](https://blibli.onelink.me/GNtk/tysv52lx) | Rp 52,500 |
| Display | 0.96" OLED I2C | Module | [OLED 0.96 I2C](https://tk.tokopedia.com/ZSqPbW55p/) | Rp 30,200 |
| Push Button | Tactile Switch 6x6x5 mm | SMD/DIP | [Tact Switch 6x6x5](https://tk.tokopedia.com/ZSqPgjgp7/) | Rp 400 |
|Fuse Holder|Fuse holder set 5x20mm|Module|[Fuse Holder](https://tk.tokopedia.com/ZSqtnY6En/)|Rp 1,000|
|Fuse|Fuse 3A|Fuse 3A|[Fuse](https://tk.tokopedia.com/ZSqPpSqhE/)|Rp 3,000|
|Switch|Switch||[Switch](https://tk.tokopedia.com/ZSqtntPNp/)(Minimum of 5)|Rp 8,000|
|Capacitor 220uF/50V|||[Capacitor 220uF](https://tk.tokopedia.com/ZSqtGnkRK/)|Rp1,500|
|Capacitor 330uF/25V|||[Capacitor 330uF](https://tk.tokopedia.com/ZSqtGnCNC/)|Rp2,500|
|Capacitor Non-Polarized 1uF/50V|||[Capacitor 1uF](https://tk.tokopedia.com/ZSqttY7Un/)|Rp12,000|
|Total|||||
---



## ESP32-C3 Pin Allocation Table

| ESP32-C3 Pin | Connected Peripheral | Function | Logic Level |
| :--- | :--- | :--- | :--- |
| **5V** | Buck Converter Output | 5V Main Power Input | 5V |
| **3.3V** | Level Shifter LV / HX711 DVDD | 3.3V Reference Rail | 3.3V |
| **GND** | System Ground Rail | Common Ground | 0V |
| **GPIO 0** | L298N IN1 | Motor Direction / PWM Signal 1 | 3.3V |
| **GPIO 1** | L298N IN2 | Motor Direction / PWM Signal 2 | 3.3V |
| **GPIO 2** | Level Shifter LV1 | Encoder Phase A Input | 3.3V |
| **GPIO 3** | Level Shifter LV2 | Encoder Phase B Input | 3.3V |
| **GPIO 4** | HX711 DT | Load Cell Serial Data | 3.3V |
| **GPIO 5** | HX711 SCK | Load Cell Serial Clock | 3.3V |
| **GPIO 6** | OLED Display SDA | I2C Data Line | 3.3V |
| **GPIO 7** | OLED Display SCL | I2C Clock Line | 3.3V |
| **GPIO 8** | Tactile Switch | User Input (Active LOW) | 3.3V |

---

## Complete Schematic Netlist & Connections

### 1. Power Section (24V Battery Input & 5V Buck Regulator)
* **24V Power Input (J1 Terminal):**
  * Pin 1 (24V+) -> Fuse Holder Pin 1 -> Fuse (3A) -> Fuse Holder Pin 2 -> Power Switch Pin 1 -> Power Switch Pin 2 -> SS34 Diode (Anode) -> SS34 Diode (Cathode) -> XL4015 Pin 1 (VIN) & L298N Pin 4 (VS)
  * Pin 2 (GND) -> Common System GND Rail
* **XL4015 Buck Regulator Circuit:**
  * Pin 1 (VIN) -> 24V Input (post-switch); 100uF/50V capacitor to GND
  * Pin 2 (SW) -> 33uH SMD Power Inductor -> +5V Rail; SS34 Schottky Diode to GND
  * Pin 3 (GND) -> Common GND
  * Pin 4 (FB) -> Output Feedback Resistor Network to set 5.0V output
  * Pin 5 (ON/OFF) -> Tied to GND (Always Enabled)
  * **+5V Output Rail:** Supplies ESP32 5V Pin, L298N VSS (Pin 9), Motor Encoder VCC, OLED Display VCC, and HX711 AVDD

### 2. Motor Driver Circuit (L298N Multiwatt15)
* **L298N IC Connections:**
  * Pin 1 (SEN_A) -> Connect directly to System GND
  * Pin 2 (OUT1) -> Motor Terminal 1 (with 1x SS34 diode to 24V Rail [Cathode] and 1x SS34 diode to GND [Anode])
  * Pin 3 (OUT2) -> Motor Terminal 2 (with 1x SS34 diode to 24V Rail [Cathode] and 1x SS34 diode to GND [Anode])
  * Pin 4 (VS) -> 24V Switched Power Rail (with 100uF low-ESR electrolytic + 0.1uF ceramic capacitor in parallel to GND)
  * Pin 5 (IN1) -> ESP32-C3 GPIO 0
  * Pin 6 (ENA) -> Tied directly to +5V Rail (Enables Driver Channel A)
  * Pin 7 (IN2) -> ESP32-C3 GPIO 1
  * Pin 8 (GND) -> System GND
  * Pin 9 (VSS) -> +5V Logic Power Rail (with 0.1uF bypass capacitor to GND)
  * Pin 10 (IN3) -> Tied to GND (Unused Channel B)
  * Pin 11 (ENB) -> Tied to GND (Disables Channel B)
  * Pin 12 (IN4) -> Tied to GND (Unused Channel B)
  * Pin 13 (OUT3) -> Unconnected / Floating
  * Pin 14 (OUT4) -> Unconnected / Floating
  * Pin 15 (SEN_B) -> Tied to GND

### 3. Encoder Level Shifter (5V to 3.3V Dual Channel - BSS138)
* **Channel 1 (Encoder Phase A):**
  * BSS138-1 Gate -> Connected to +3.3V Rail
  * BSS138-1 Source (LV) -> ESP32-C3 GPIO 2 + 10k Ohm pull-up to 3.3V
  * BSS138-1 Drain (HV) -> Motor Encoder Signal A Output + 10k Ohm pull-up to +5V
* **Channel 2 (Encoder Phase B):**
  * BSS138-2 Gate -> Connected to +3.3V Rail
  * BSS138-2 Source (LV) -> ESP32-C3 GPIO 3 + 10k Ohm pull-up to 3.3V
  * BSS138-2 Drain (HV) -> Motor Encoder Signal B Output + 10k Ohm pull-up to +5V

### 4. Load Cell Amplifier Circuit (HX711 SOP-16)
* **HX711 Connections:**
  * Pin 1 (VSUP) -> Collector of S8550 PNP Transistor
  * Pin 2 (BASE) -> Base of S8550 PNP Transistor
  * Pin 3 (AVDD) -> Analog Power Input (+5V from Transistor filter network)
  * Pin 4 (VBG) -> 0.1uF Capacitor to AGND
  * Pin 5 (AGND) -> Analog Ground Rail
  * Pin 6 (RATE) -> GND (Selects 10Hz sample rate for high stability)
  * Pin 7 (INP1) -> Load Cell Signal Positive (A+)
  * Pin 8 (INN1) -> Load Cell Signal Negative (A-)
  * Pin 9 (INP2) -> GND
  * Pin 10 (INN2) -> GND
  * Pin 11 (PD_SCK) -> ESP32-C3 GPIO 5
  * Pin 12 (DOUT) -> ESP32-C3 GPIO 4
  * Pin 13 (XO) -> Unconnected / Floating
  * Pin 14 (XI) -> GND
  * Pin 15 (GND) -> System GND
  * Pin 16 (DVDD) -> +3.3V Rail (Sets DT/SCK logic to 3.3V for direct ESP32-C3 safety)
* **Load Cell Connector (J2 - 4 Pin Header):**
  * Pin 1 (E+) -> HX711 Excitation Voltage Output
  * Pin 2 (E-) -> HX711 Excitation Ground
  * Pin 3 (A+) -> Load Cell Signal (+)
  * Pin 4 (A-) -> Load Cell Signal (-)

### 5. Display & User Switch
* **OLED Display Header (0.96" I2C):**
  * Pin 1 (GND) -> System GND
  * Pin 2 (VCC) -> +5V Rail (or +3.3V depending on module specs)
  * Pin 3 (SCK/SCL) -> ESP32-C3 GPIO 7 + 4.7k Ohm pull-up to 3.3V
  * Pin 4 (SDA) -> ESP32-C3 GPIO 6 + 4.7k Ohm pull-up to 3.3V
* **User Push Button:**
  * Terminal 1 -> ESP32-C3 GPIO 8 + 10k Ohm pull-up to 3.3V
  * Terminal 2 -> System GND