import 'package:flutter_test/flutter_test.dart';
import 'package:auto_cpr/services/telemetry_repository.dart';

void main() {
  test('TelemetryRepository.ingestFirmwareCsvLine parses 14-column Wokwi/BLE CSV', () async {
    final repo = TelemetryRepository.instance;

    // Header row and human-readable log lines should be ignored cleanly.
    expect(
      repo.ingestFirmwareCsvLine(
        'Time(ms),Set_RPM,Actual_RPM,PWM,Raw_Counts,Freq_Hz,LoadCell,GPS_Fix,Latitude,Longitude,Satellites,Speed_kmh,Altitude_m,GPS_UTC',
      ),
      isFalse,
    );
    expect(repo.ingestFirmwareCsvLine('Latitude: -6.208800'), isFalse);

    // 14-column firmware telemetry row from Wokwi (:4000) or BLE GATT notify.
    final parsed = repo.ingestFirmwareCsvLine(
      '4200,110.0,108.5,142,24,120.00,65.20,1,-6.208765,106.845612,9,18.40,12.5,2026-11-07 01:15:04',
    );

    expect(parsed, isTrue);
    expect(repo.esp32.motorSpeed, closeTo(108.5, 0.01));
    expect(repo.esp32.compressionRate, closeTo(108.5, 0.01));
    expect(repo.esp32.instantForce, closeTo(65.2, 0.01));
    expect(repo.esp32.isConnected, isTrue);

    expect(repo.location.isGpsLocked, isTrue);
    expect(repo.location.latitude, closeTo(-6.208765, 1e-6));
    expect(repo.location.longitude, closeTo(106.845612, 1e-6));
    expect(repo.location.satellites, equals(9));
    expect(repo.location.speed, closeTo(18.4, 0.01));
    expect(repo.location.altitude, closeTo(12.5, 0.01));

    repo.disconnectEsp32();
    await repo.disposeStreams();
  });
}
