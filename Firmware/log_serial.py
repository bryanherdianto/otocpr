import serial
import csv
import time

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

def main():
    print(f"Connecting to {SERIAL_PORT} at {BAUD_RATE} baud...")
    
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
    except Exception as e:
        print(f"\n[ERROR] Could not open serial port: {e}")
        print("Please check that the SERIAL_PORT variable matches your ESP32 port.")
        return

    print(f"Successfully connected! Logging data to -> {OUTPUT_FILE}")
    print("Press Ctrl+C to stop logging and save.\n")

    # Open the CSV file in write mode
    with open(OUTPUT_FILE, 'w', newline='') as f:
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
            print(f"\n\nLogging stopped by user. Data successfully saved to {OUTPUT_FILE}")
            
        finally:
            ser.close()

if __name__ == '__main__':
    main()
