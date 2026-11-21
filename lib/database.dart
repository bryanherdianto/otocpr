import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Persisted telemetry recording session (e.g. a Wokwi or BLE streaming run).
class TelemetrySessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get source => text()();
  TextColumn get deviceId => text()();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get sampleCount => integer().withDefault(const Constant(0))();
  RealColumn get maxPeakForce => real().withDefault(const Constant(0.0))();
  IntColumn get totalCompressions =>
      integer().withDefault(const Constant(0))();
}

/// Individual firmware CSV telemetry sample captured from Wokwi or ESP32 BLE.
@TableIndex(name: 'idx_samples_recorded_at', columns: {#recordedAt})
class TelemetrySamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().nullable().references(
        TelemetrySessions,
        #id,
        onDelete: KeyAction.cascade,
      )();
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get source => text()();
  IntColumn get firmwareTimeMs => integer()();
  RealColumn get setRpm => real()();
  RealColumn get actualRpm => real()();
  IntColumn get pwm => integer()();
  IntColumn get rawCounts => integer()();
  RealColumn get freqHz => real()();
  RealColumn get loadCellRaw => real()();
  RealColumn get instantForce => real()();
  RealColumn get peakForce => real()();
  RealColumn get positionAngle => real()();
  TextColumn get direction => text()();
  IntColumn get compressionCount => integer()();
  RealColumn get compressionDepth => real()();
  RealColumn get motorTemp => real()();
  BoolColumn get recoilOk => boolean()();
  BoolColumn get anomalyFlag => boolean()();
  BoolColumn get gpsFix => boolean().withDefault(const Constant(false))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get satellites => integer().nullable()();
  RealColumn get speedKmh => real().nullable()();
  RealColumn get altitudeM => real().nullable()();
  TextColumn get gpsUtc => text().nullable()();
}

/// Structured ESP32 and Edge AI diagnostic log entries generated during streams.
@TableIndex(name: 'idx_logs_created_at', columns: {#createdAt})
class TelemetryLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().nullable().references(
        TelemetrySessions,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get name => text()();
  TextColumn get timeLabel => text()();
  TextColumn get sizeLabel => text()();
  TextColumn get status => text()();
  BoolColumn get isDerate => boolean()();
  TextColumn get category => text()();
  TextColumn get source => text()();
  TextColumn get preview => text()();
  TextColumn get fullJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [TelemetrySessions, TelemetrySamples, TelemetryLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'otocpr_telemetry_db');
  }

  /// Creates a new telemetry session row and returns its primary key.
  Future<int> createSession({
    required String source,
    required String deviceId,
    DateTime? startedAt,
  }) {
    return into(telemetrySessions).insert(
      TelemetrySessionsCompanion.insert(
        source: source,
        deviceId: deviceId,
        startedAt: startedAt != null ? Value(startedAt) : const Value.absent(),
      ),
    );
  }

  /// Updates aggregate counters and/or completion timestamp for a session.
  Future<void> updateSessionStats(
    int sessionId, {
    int? sampleCount,
    double? maxPeakForce,
    int? totalCompressions,
    DateTime? endedAt,
  }) async {
    await (update(telemetrySessions)..where((t) => t.id.equals(sessionId)))
        .write(
      TelemetrySessionsCompanion(
        sampleCount:
            sampleCount != null ? Value(sampleCount) : const Value.absent(),
        maxPeakForce:
            maxPeakForce != null ? Value(maxPeakForce) : const Value.absent(),
        totalCompressions: totalCompressions != null
            ? Value(totalCompressions)
            : const Value.absent(),
        endedAt: endedAt != null ? Value(endedAt) : const Value.absent(),
      ),
    );
  }

  /// Returns the most recent recording sessions ordered newest-first.
  Future<List<TelemetrySession>> getRecentSessions({int limit = 20}) {
    return (select(telemetrySessions)
          ..orderBy([
            (t) => OrderingTerm.desc(t.startedAt),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(limit))
        .get();
  }

  /// Returns total persisted session count.
  Future<int> countSessions() =>
      _countRows(telemetrySessions, telemetrySessions.id);

  /// Inserts a single telemetry sample row.
  Future<int> insertSample(TelemetrySamplesCompanion entry) {
    return into(telemetrySamples).insert(entry);
  }

  /// Inserts multiple telemetry sample rows inside a single Drift batch.
  Future<void> insertSamplesBatch(List<TelemetrySamplesCompanion> entries) {
    if (entries.isEmpty) return Future<void>.value();
    return batch((b) => b.insertAll(telemetrySamples, entries));
  }

  /// Returns up to [limit] most recent samples ordered chronologically (ASC).
  Future<List<TelemetrySample>> getRecentSamples({int limit = 4500}) async {
    final rows = await (select(telemetrySamples)
          ..orderBy([
            (t) => OrderingTerm.desc(t.recordedAt),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(limit))
        .get();
    return rows.reversed.toList();
  }

  /// Returns the most recently recorded telemetry sample, if any.
  Future<TelemetrySample?> getLatestSample() {
    return (select(telemetrySamples)
          ..orderBy([
            (t) => OrderingTerm.desc(t.recordedAt),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Returns total persisted telemetry sample count.
  Future<int> countSamples() =>
      _countRows(telemetrySamples, telemetrySamples.id);

  /// Inserts a single machine log row.
  Future<int> insertLog(TelemetryLogsCompanion entry) {
    return into(telemetryLogs).insert(entry);
  }

  /// Inserts multiple machine log rows inside a single Drift batch.
  Future<void> insertLogsBatch(List<TelemetryLogsCompanion> entries) {
    if (entries.isEmpty) return Future<void>.value();
    return batch((b) => b.insertAll(telemetryLogs, entries));
  }

  /// Returns up to [limit] machine logs ordered newest-first (DESC).
  Future<List<TelemetryLog>> getRecentLogs({int limit = 200}) {
    return (select(telemetryLogs)
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(limit))
        .get();
  }

  /// Returns total persisted machine log count.
  Future<int> countLogs() => _countRows(telemetryLogs, telemetryLogs.id);

  /// Deletes all persisted samples, logs, and sessions inside a transaction.
  Future<void> clearAllTelemetryData() {
    return transaction(() async {
      await delete(telemetrySamples).go();
      await delete(telemetryLogs).go();
      await delete(telemetrySessions).go();
    });
  }

  Future<int> _countRows(
    ResultSetImplementation<HasResultSet, dynamic> table,
    GeneratedColumn<int> idCol,
  ) async {
    final countExp = idCol.count();
    final query = selectOnly(table)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }
}
