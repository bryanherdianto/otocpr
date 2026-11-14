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

    expect(repo.logs.first.category, anyOf('ESP32', 'AI'));
    expect(repo.logs.any((l) => l.name.startsWith('L0001_')), isTrue);
    expect(repo.aiDiagnostics.classification, equals('Optimal Compression Dynamics'));
    expect(repo.aiDiagnostics.rawJson, contains('"motor_rpm": 108.5'));

    // Feed an out-of-range force (90 N > 80 N target max) and rate (90 RPM < 100 target min)
    // to verify dynamic Mean Value and Efficiency (%) computation.
    repo.ingestFirmwareCsvLine(
      '4400,110.0,90.0,142,24,120.00,90.00,1,-6.208765,106.845612,9,18.40,12.5,2026-11-07 01:15:04',
    );
    final forceSeries = repo.getMetricHistory('Instantaneous Force', timeframeIndex: 0);
    expect(forceSeries.meanValue, equals('77.6')); // (65.2 + 90.0) / 2
    expect(forceSeries.efficiency, equals('50%')); // 1 of 2 samples in 50..80 N

    final rateSeries = repo.getMetricHistory('Compression Rate', timeframeIndex: 0);
    expect(rateSeries.meanValue, equals('99.3')); // (108.5 + 90.0) / 2
    expect(rateSeries.efficiency, equals('50%')); // 1 of 2 samples in 100..120 CPM

    repo.disconnectEsp32();
    await repo.disposeStreams();
  });
}
