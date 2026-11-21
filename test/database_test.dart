import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auto_cpr/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  TelemetrySamplesCompanion sampleCompanion({
    required int sessionId,
    required DateTime recordedAt,
    required int firmwareTimeMs,
    required double instantForce,
    required double peakForce,
    int compressionCount = 10,
  }) {
    return TelemetrySamplesCompanion.insert(
      sessionId: Value(sessionId),
      recordedAt: Value(recordedAt),
      source: 'Wokwi RFC2217 (127.0.0.1:4000)',
      firmwareTimeMs: firmwareTimeMs,
      setRpm: 110.0,
      actualRpm: 108.5,
      pwm: 142,
      rawCounts: 24,
      freqHz: 120.0,
      loadCellRaw: instantForce,
      instantForce: instantForce,
      peakForce: peakForce,
      positionAngle: 142.5,
      direction: 'CW',
      compressionCount: compressionCount,
      compressionDepth: 4.7,
      motorTemp: 42.5,
      recoilOk: instantForce <= 95.0,
      anomalyFlag: instantForce > 95.0,
      gpsFix: const Value(true),
      latitude: const Value(-6.208765),
      longitude: const Value(106.845612),
      satellites: const Value(9),
      speedKmh: const Value(18.4),
      altitudeM: const Value(12.5),
      gpsUtc: const Value('2026-11-07 01:15:04'),
    );
  }

  test('Sessions, samples, logs, and clearAllTelemetryData work with Drift', () async {
    expect(await db.countSessions(), 0);
    expect(await db.countSamples(), 0);
    expect(await db.countLogs(), 0);

    final t0 = DateTime(2026, 11, 7, 1, 15, 0);
    final sessionId = await db.createSession(
      source: 'Wokwi RFC2217 (127.0.0.1:4000)',
      deviceId: '127.0.0.1:4000',
      startedAt: t0,
    );
    expect(sessionId, greaterThan(0));
    expect(await db.countSessions(), 1);

    await db.insertSample(
      sampleCompanion(
        sessionId: sessionId,
        recordedAt: t0,
        firmwareTimeMs: 4000,
        instantForce: 65.2,
        peakForce: 94.2,
        compressionCount: 842,
      ),
    );

    await db.insertSamplesBatch([
      sampleCompanion(
        sessionId: sessionId,
        recordedAt: t0.add(const Duration(seconds: 1)),
        firmwareTimeMs: 4200,
        instantForce: 72.0,
        peakForce: 94.2,
        compressionCount: 843,
      ),
      sampleCompanion(
        sessionId: sessionId,
        recordedAt: t0.add(const Duration(seconds: 2)),
        firmwareTimeMs: 4400,
        instantForce: 98.4,
        peakForce: 98.4,
        compressionCount: 844,
      ),
    ]);

    expect(await db.countSamples(), 3);

    // getRecentSamples returns chronological ASC order.
    final recentSamples = await db.getRecentSamples();
    expect(recentSamples.length, 3);
    expect(recentSamples.map((s) => s.firmwareTimeMs), [4000, 4200, 4400]);

    // getLatestSample returns newest sample.
    final latest = await db.getLatestSample();
    expect(latest, isNotNull);
    expect(latest!.firmwareTimeMs, 4400);
    expect(latest.instantForce, closeTo(98.4, 0.01));
    expect(latest.anomalyFlag, isTrue);

    // Insert logs and verify DESC ordering.
    await db.insertLogsBatch([
      TelemetryLogsCompanion.insert(
        sessionId: Value(sessionId),
        name: 'L0001_esp32.json',
        timeLabel: '01:15:00',
        sizeLabel: '0.5 KB',
        status: 'Normal',
        isDerate: false,
        category: 'ESP32',
        source: 'Wokwi RFC2217 (127.0.0.1:4000)',
        preview: '{"rpm": 108.5}',
        fullJson: '{"event":"LIVE_TELEMETRY"}',
        createdAt: Value(t0),
      ),
      TelemetryLogsCompanion.insert(
        sessionId: Value(sessionId),
        name: 'L0002_inference.json',
        timeLabel: '01:15:02',
        sizeLabel: '0.6 KB',
        status: 'Derate',
        isDerate: true,
        category: 'AI',
        source: 'Wokwi RFC2217 (127.0.0.1:4000)',
        preview: '{"classification":"Elevated Compression Force"}',
        fullJson: '{"event":"OVERFORCE_WARNING"}',
        createdAt: Value(t0.add(const Duration(seconds: 2))),
      ),
    ]);
    expect(await db.countLogs(), 2);

    final recentLogs = await db.getRecentLogs();
    expect(recentLogs.map((l) => l.name), [
      'L0002_inference.json',
      'L0001_esp32.json',
    ]);

    await db.updateSessionStats(
      sessionId,
      sampleCount: 3,
      maxPeakForce: 98.4,
      totalCompressions: 844,
      endedAt: t0.add(const Duration(seconds: 2)),
    );
    final sessions = await db.getRecentSessions();
    expect(sessions.length, 1);
    expect(sessions.first.sampleCount, 3);
    expect(sessions.first.maxPeakForce, closeTo(98.4, 0.01));
    expect(sessions.first.totalCompressions, 844);
    expect(sessions.first.endedAt, isNotNull);

    await db.clearAllTelemetryData();
    expect(await db.countSamples(), 0);
    expect(await db.countLogs(), 0);
    expect(await db.countSessions(), 0);
  });
}
