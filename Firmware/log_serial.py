import serial
import csv
import time
import argparse

# ==========================================
# CONFIGURATION
# ==========================================
# Change this to match your ESP32's COM port
# On Mac, it usually looks like '/dev/cu.usbserial-1410' or '/dev/cu.SLAB_USBtoUART'
# On Windows, it looks like 'COM3'
SERIAL_PORT = '/dev/cu.usbserial-0001' 
BAUD_RATE = 115200
OUTPUT_FILE = 'motor_data_log.csv'
# ==========================================

WOKWI_RFC2217_URL = 'rfc2217://localhost:4000?ign_set_control'

def parse_args():
    parser = argparse.ArgumentParser(description="Log Auto-CPR + NEO-6M GPS telemetry CSV from ESP32 or Wokwi.")
    parser.add_argument('--port', default=SERIAL_PORT, help='Serial port (e.g. COM3) or pyserial URL')
    parser.add_argument('--wokwi', action='store_true', help='Connect to Wokwi VS Code RFC2217 server (localhost:4000)')
    parser.add_argument('--baud', type=int, default=BAUD_RATE, help='Baud rate (default: 115200)')
    parser.add_argument('--output', default=OUTPUT_FILE, help='CSV output file path')
    return parser.parse_args()

def main():
    args = parse_args()
    port = WOKWI_RFC2217_URL if args.wokwi else args.port
    baud = args.baud
    output_file = args.output

    print(f"Connecting to {port} at {baud} baud...")
    
    try:
        if '://' in port:
            ser = serial.serial_for_url(port, baudrate=baud, timeout=1)
        else:
            ser = serial.Serial(port, baud, timeout=1)
    except Exception as e:
        print(f"\n[ERROR] Could not open serial port: {e}")
        print("Please check that the SERIAL_PORT variable matches your ESP32 port.")
        return

    print(f"Successfully connected! Logging data to -> {output_file}")
    print("Press Ctrl+C to stop logging and save.\n")

    # Open the CSV file in write mode
    with open(output_file, 'w', newline='') as f:
        writer = csv.writer(f)
        
        try:
            while True:
                # Check if there's data waiting in the serial buffer
                if ser.in_waiting > 0:
                    # Read the line, decode it, and strip any whitespace/newlines
                    line = ser.readline().decode('utf-8', errors='ignore').strip()
                    
                    if line:
                        print(line) # Print to console so you can watch it
                        
                        # Split by comma and save to the CSV file
                        data_row = line.split(',')
                        writer.writerow(data_row)
                        
                        # Force write to disk immediately so we don't lose data if it crashes
                        f.flush() 
                        
        except KeyboardInterrupt:
            print(f"\n\nLogging stopped by user. Data successfully saved to {output_file}")
            
        finally:
            ser.close()

if __name__ == '__main__':
    main()
