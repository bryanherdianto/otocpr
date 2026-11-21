// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TelemetrySessionsTable extends TelemetrySessions
    with TableInfo<$TelemetrySessionsTable, TelemetrySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TelemetrySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sampleCountMeta = const VerificationMeta(
    'sampleCount',
  );
  @override
  late final GeneratedColumn<int> sampleCount = GeneratedColumn<int>(
    'sample_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxPeakForceMeta = const VerificationMeta(
    'maxPeakForce',
  );
  @override
  late final GeneratedColumn<double> maxPeakForce = GeneratedColumn<double>(
    'max_peak_force',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalCompressionsMeta = const VerificationMeta(
    'totalCompressions',
  );
  @override
  late final GeneratedColumn<int> totalCompressions = GeneratedColumn<int>(
    'total_compressions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    source,
    deviceId,
    startedAt,
    endedAt,
    sampleCount,
    maxPeakForce,
    totalCompressions,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'telemetry_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TelemetrySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('sample_count')) {
      context.handle(
        _sampleCountMeta,
        sampleCount.isAcceptableOrUnknown(
          data['sample_count']!,
          _sampleCountMeta,
        ),
      );
    }
    if (data.containsKey('max_peak_force')) {
      context.handle(
        _maxPeakForceMeta,
        maxPeakForce.isAcceptableOrUnknown(
          data['max_peak_force']!,
          _maxPeakForceMeta,
        ),
      );
    }
    if (data.containsKey('total_compressions')) {
      context.handle(
        _totalCompressionsMeta,
        totalCompressions.isAcceptableOrUnknown(
          data['total_compressions']!,
          _totalCompressionsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TelemetrySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TelemetrySession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      sampleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count'],
      )!,
      maxPeakForce: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_peak_force'],
      )!,
      totalCompressions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_compressions'],
      )!,
    );
  }

  @override
  $TelemetrySessionsTable createAlias(String alias) {
    return $TelemetrySessionsTable(attachedDatabase, alias);
  }
}

class TelemetrySession extends DataClass
    implements Insertable<TelemetrySession> {
  final int id;
  final String source;
  final String deviceId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int sampleCount;
  final double maxPeakForce;
  final int totalCompressions;
  const TelemetrySession({
    required this.id,
    required this.source,
    required this.deviceId,
    required this.startedAt,
    this.endedAt,
    required this.sampleCount,
    required this.maxPeakForce,
    required this.totalCompressions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source'] = Variable<String>(source);
    map['device_id'] = Variable<String>(deviceId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['sample_count'] = Variable<int>(sampleCount);
    map['max_peak_force'] = Variable<double>(maxPeakForce);
    map['total_compressions'] = Variable<int>(totalCompressions);
    return map;
  }

  TelemetrySessionsCompanion toCompanion(bool nullToAbsent) {
    return TelemetrySessionsCompanion(
      id: Value(id),
      source: Value(source),
      deviceId: Value(deviceId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      sampleCount: Value(sampleCount),
      maxPeakForce: Value(maxPeakForce),
      totalCompressions: Value(totalCompressions),
    );
  }

  factory TelemetrySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TelemetrySession(
      id: serializer.fromJson<int>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      sampleCount: serializer.fromJson<int>(json['sampleCount']),
      maxPeakForce: serializer.fromJson<double>(json['maxPeakForce']),
      totalCompressions: serializer.fromJson<int>(json['totalCompressions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'source': serializer.toJson<String>(source),
      'deviceId': serializer.toJson<String>(deviceId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'sampleCount': serializer.toJson<int>(sampleCount),
      'maxPeakForce': serializer.toJson<double>(maxPeakForce),
      'totalCompressions': serializer.toJson<int>(totalCompressions),
    };
  }

  TelemetrySession copyWith({
    int? id,
    String? source,
    String? deviceId,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? sampleCount,
    double? maxPeakForce,
    int? totalCompressions,
  }) => TelemetrySession(
    id: id ?? this.id,
    source: source ?? this.source,
    deviceId: deviceId ?? this.deviceId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    sampleCount: sampleCount ?? this.sampleCount,
    maxPeakForce: maxPeakForce ?? this.maxPeakForce,
    totalCompressions: totalCompressions ?? this.totalCompressions,
  );
  TelemetrySession copyWithCompanion(TelemetrySessionsCompanion data) {
    return TelemetrySession(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      sampleCount: data.sampleCount.present
          ? data.sampleCount.value
          : this.sampleCount,
      maxPeakForce: data.maxPeakForce.present
          ? data.maxPeakForce.value
          : this.maxPeakForce,
      totalCompressions: data.totalCompressions.present
          ? data.totalCompressions.value
          : this.totalCompressions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TelemetrySession(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('deviceId: $deviceId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('maxPeakForce: $maxPeakForce, ')
          ..write('totalCompressions: $totalCompressions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    source,
    deviceId,
    startedAt,
    endedAt,
    sampleCount,
    maxPeakForce,
    totalCompressions,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TelemetrySession &&
          other.id == this.id &&
          other.source == this.source &&
          other.deviceId == this.deviceId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.sampleCount == this.sampleCount &&
          other.maxPeakForce == this.maxPeakForce &&
          other.totalCompressions == this.totalCompressions);
}

class TelemetrySessionsCompanion extends UpdateCompanion<TelemetrySession> {
  final Value<int> id;
  final Value<String> source;
  final Value<String> deviceId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> sampleCount;
  final Value<double> maxPeakForce;
  final Value<int> totalCompressions;
  const TelemetrySessionsCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.maxPeakForce = const Value.absent(),
    this.totalCompressions = const Value.absent(),
  });
  TelemetrySessionsCompanion.insert({
    this.id = const Value.absent(),
    required String source,
    required String deviceId,
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.maxPeakForce = const Value.absent(),
    this.totalCompressions = const Value.absent(),
  }) : source = Value(source),
       deviceId = Value(deviceId);
  static Insertable<TelemetrySession> custom({
    Expression<int>? id,
    Expression<String>? source,
    Expression<String>? deviceId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? sampleCount,
    Expression<double>? maxPeakForce,
    Expression<int>? totalCompressions,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (deviceId != null) 'device_id': deviceId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (sampleCount != null) 'sample_count': sampleCount,
      if (maxPeakForce != null) 'max_peak_force': maxPeakForce,
      if (totalCompressions != null) 'total_compressions': totalCompressions,
    });
  }

  TelemetrySessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? source,
    Value<String>? deviceId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? sampleCount,
    Value<double>? maxPeakForce,
    Value<int>? totalCompressions,
  }) {
    return TelemetrySessionsCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      deviceId: deviceId ?? this.deviceId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      sampleCount: sampleCount ?? this.sampleCount,
      maxPeakForce: maxPeakForce ?? this.maxPeakForce,
      totalCompressions: totalCompressions ?? this.totalCompressions,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
    }
    if (maxPeakForce.present) {
      map['max_peak_force'] = Variable<double>(maxPeakForce.value);
    }
    if (totalCompressions.present) {
      map['total_compressions'] = Variable<int>(totalCompressions.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TelemetrySessionsCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('deviceId: $deviceId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('maxPeakForce: $maxPeakForce, ')
          ..write('totalCompressions: $totalCompressions')
          ..write(')'))
        .toString();
  }
}

class $TelemetrySamplesTable extends TelemetrySamples
    with TableInfo<$TelemetrySamplesTable, TelemetrySample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TelemetrySamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES telemetry_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firmwareTimeMsMeta = const VerificationMeta(
    'firmwareTimeMs',
  );
  @override
  late final GeneratedColumn<int> firmwareTimeMs = GeneratedColumn<int>(
    'firmware_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setRpmMeta = const VerificationMeta('setRpm');
  @override
  late final GeneratedColumn<double> setRpm = GeneratedColumn<double>(
    'set_rpm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualRpmMeta = const VerificationMeta(
    'actualRpm',
  );
  @override
  late final GeneratedColumn<double> actualRpm = GeneratedColumn<double>(
    'actual_rpm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pwmMeta = const VerificationMeta('pwm');
  @override
  late final GeneratedColumn<int> pwm = GeneratedColumn<int>(
    'pwm',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawCountsMeta = const VerificationMeta(
    'rawCounts',
  );
  @override
  late final GeneratedColumn<int> rawCounts = GeneratedColumn<int>(
    'raw_counts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _freqHzMeta = const VerificationMeta('freqHz');
  @override
  late final GeneratedColumn<double> freqHz = GeneratedColumn<double>(
    'freq_hz',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loadCellRawMeta = const VerificationMeta(
    'loadCellRaw',
  );
  @override
  late final GeneratedColumn<double> loadCellRaw = GeneratedColumn<double>(
    'load_cell_raw',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instantForceMeta = const VerificationMeta(
    'instantForce',
  );
  @override
  late final GeneratedColumn<double> instantForce = GeneratedColumn<double>(
    'instant_force',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peakForceMeta = const VerificationMeta(
    'peakForce',
  );
  @override
  late final GeneratedColumn<double> peakForce = GeneratedColumn<double>(
    'peak_force',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionAngleMeta = const VerificationMeta(
    'positionAngle',
  );
  @override
  late final GeneratedColumn<double> positionAngle = GeneratedColumn<double>(
    'position_angle',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _compressionCountMeta = const VerificationMeta(
    'compressionCount',
  );
  @override
  late final GeneratedColumn<int> compressionCount = GeneratedColumn<int>(
    'compression_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _compressionDepthMeta = const VerificationMeta(
    'compressionDepth',
  );
  @override
  late final GeneratedColumn<double> compressionDepth = GeneratedColumn<double>(
    'compression_depth',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _motorTempMeta = const VerificationMeta(
    'motorTemp',
  );
  @override
  late final GeneratedColumn<double> motorTemp = GeneratedColumn<double>(
    'motor_temp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recoilOkMeta = const VerificationMeta(
    'recoilOk',
  );
  @override
  late final GeneratedColumn<bool> recoilOk = GeneratedColumn<bool>(
    'recoil_ok',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recoil_ok" IN (0, 1))',
    ),
  );
  static const VerificationMeta _anomalyFlagMeta = const VerificationMeta(
    'anomalyFlag',
  );
  @override
  late final GeneratedColumn<bool> anomalyFlag = GeneratedColumn<bool>(
    'anomaly_flag',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("anomaly_flag" IN (0, 1))',
    ),
  );
  static const VerificationMeta _gpsFixMeta = const VerificationMeta('gpsFix');
  @override
  late final GeneratedColumn<bool> gpsFix = GeneratedColumn<bool>(
    'gps_fix',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("gps_fix" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _satellitesMeta = const VerificationMeta(
    'satellites',
  );
  @override
  late final GeneratedColumn<int> satellites = GeneratedColumn<int>(
    'satellites',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedKmhMeta = const VerificationMeta(
    'speedKmh',
  );
  @override
  late final GeneratedColumn<double> speedKmh = GeneratedColumn<double>(
    'speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altitudeMMeta = const VerificationMeta(
    'altitudeM',
  );
  @override
  late final GeneratedColumn<double> altitudeM = GeneratedColumn<double>(
    'altitude_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsUtcMeta = const VerificationMeta('gpsUtc');
  @override
  late final GeneratedColumn<String> gpsUtc = GeneratedColumn<String>(
    'gps_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    recordedAt,
    source,
    firmwareTimeMs,
    setRpm,
    actualRpm,
    pwm,
    rawCounts,
    freqHz,
    loadCellRaw,
    instantForce,
    peakForce,
    positionAngle,
    direction,
    compressionCount,
    compressionDepth,
    motorTemp,
    recoilOk,
    anomalyFlag,
    gpsFix,
    latitude,
    longitude,
    satellites,
    speedKmh,
    altitudeM,
    gpsUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'telemetry_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<TelemetrySample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('firmware_time_ms')) {
      context.handle(
        _firmwareTimeMsMeta,
        firmwareTimeMs.isAcceptableOrUnknown(
          data['firmware_time_ms']!,
          _firmwareTimeMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firmwareTimeMsMeta);
    }
    if (data.containsKey('set_rpm')) {
      context.handle(
        _setRpmMeta,
        setRpm.isAcceptableOrUnknown(data['set_rpm']!, _setRpmMeta),
      );
    } else if (isInserting) {
      context.missing(_setRpmMeta);
    }
    if (data.containsKey('actual_rpm')) {
      context.handle(
        _actualRpmMeta,
        actualRpm.isAcceptableOrUnknown(data['actual_rpm']!, _actualRpmMeta),
      );
    } else if (isInserting) {
      context.missing(_actualRpmMeta);
    }
    if (data.containsKey('pwm')) {
      context.handle(
        _pwmMeta,
        pwm.isAcceptableOrUnknown(data['pwm']!, _pwmMeta),
      );
    } else if (isInserting) {
      context.missing(_pwmMeta);
    }
    if (data.containsKey('raw_counts')) {
      context.handle(
        _rawCountsMeta,
        rawCounts.isAcceptableOrUnknown(data['raw_counts']!, _rawCountsMeta),
      );
    } else if (isInserting) {
      context.missing(_rawCountsMeta);
    }
    if (data.containsKey('freq_hz')) {
      context.handle(
        _freqHzMeta,
        freqHz.isAcceptableOrUnknown(data['freq_hz']!, _freqHzMeta),
      );
    } else if (isInserting) {
      context.missing(_freqHzMeta);
    }
    if (data.containsKey('load_cell_raw')) {
      context.handle(
        _loadCellRawMeta,
        loadCellRaw.isAcceptableOrUnknown(
          data['load_cell_raw']!,
          _loadCellRawMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_loadCellRawMeta);
    }
    if (data.containsKey('instant_force')) {
      context.handle(
        _instantForceMeta,
        instantForce.isAcceptableOrUnknown(
          data['instant_force']!,
          _instantForceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instantForceMeta);
    }
    if (data.containsKey('peak_force')) {
      context.handle(
        _peakForceMeta,
        peakForce.isAcceptableOrUnknown(data['peak_force']!, _peakForceMeta),
      );
    } else if (isInserting) {
      context.missing(_peakForceMeta);
    }
    if (data.containsKey('position_angle')) {
      context.handle(
        _positionAngleMeta,
        positionAngle.isAcceptableOrUnknown(
          data['position_angle']!,
          _positionAngleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positionAngleMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('compression_count')) {
      context.handle(
        _compressionCountMeta,
        compressionCount.isAcceptableOrUnknown(
          data['compression_count']!,
          _compressionCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compressionCountMeta);
    }
    if (data.containsKey('compression_depth')) {
      context.handle(
        _compressionDepthMeta,
        compressionDepth.isAcceptableOrUnknown(
          data['compression_depth']!,
          _compressionDepthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compressionDepthMeta);
    }
    if (data.containsKey('motor_temp')) {
      context.handle(
        _motorTempMeta,
        motorTemp.isAcceptableOrUnknown(data['motor_temp']!, _motorTempMeta),
      );
    } else if (isInserting) {
      context.missing(_motorTempMeta);
    }
    if (data.containsKey('recoil_ok')) {
      context.handle(
        _recoilOkMeta,
        recoilOk.isAcceptableOrUnknown(data['recoil_ok']!, _recoilOkMeta),
      );
    } else if (isInserting) {
      context.missing(_recoilOkMeta);
    }
    if (data.containsKey('anomaly_flag')) {
      context.handle(
        _anomalyFlagMeta,
        anomalyFlag.isAcceptableOrUnknown(
          data['anomaly_flag']!,
          _anomalyFlagMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anomalyFlagMeta);
    }
    if (data.containsKey('gps_fix')) {
      context.handle(
        _gpsFixMeta,
        gpsFix.isAcceptableOrUnknown(data['gps_fix']!, _gpsFixMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('satellites')) {
      context.handle(
        _satellitesMeta,
        satellites.isAcceptableOrUnknown(data['satellites']!, _satellitesMeta),
      );
    }
    if (data.containsKey('speed_kmh')) {
      context.handle(
        _speedKmhMeta,
        speedKmh.isAcceptableOrUnknown(data['speed_kmh']!, _speedKmhMeta),
      );
    }
    if (data.containsKey('altitude_m')) {
      context.handle(
        _altitudeMMeta,
        altitudeM.isAcceptableOrUnknown(data['altitude_m']!, _altitudeMMeta),
      );
    }
    if (data.containsKey('gps_utc')) {
      context.handle(
        _gpsUtcMeta,
        gpsUtc.isAcceptableOrUnknown(data['gps_utc']!, _gpsUtcMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TelemetrySample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TelemetrySample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      firmwareTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}firmware_time_ms'],
      )!,
      setRpm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}set_rpm'],
      )!,
      actualRpm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_rpm'],
      )!,
      pwm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pwm'],
      )!,
      rawCounts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}raw_counts'],
      )!,
      freqHz: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}freq_hz'],
      )!,
      loadCellRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}load_cell_raw'],
      )!,
      instantForce: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}instant_force'],
      )!,
      peakForce: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_force'],
      )!,
      positionAngle: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position_angle'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      compressionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}compression_count'],
      )!,
      compressionDepth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}compression_depth'],
      )!,
      motorTemp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}motor_temp'],
      )!,
      recoilOk: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recoil_ok'],
      )!,
      anomalyFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}anomaly_flag'],
      )!,
      gpsFix: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}gps_fix'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      satellites: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}satellites'],
      ),
      speedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_kmh'],
      ),
      altitudeM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude_m'],
      ),
      gpsUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gps_utc'],
      ),
    );
  }

  @override
  $TelemetrySamplesTable createAlias(String alias) {
    return $TelemetrySamplesTable(attachedDatabase, alias);
  }
}

class TelemetrySample extends DataClass implements Insertable<TelemetrySample> {
  final int id;
  final int? sessionId;
  final DateTime recordedAt;
  final String source;
  final int firmwareTimeMs;
  final double setRpm;
  final double actualRpm;
  final int pwm;
  final int rawCounts;
  final double freqHz;
  final double loadCellRaw;
  final double instantForce;
  final double peakForce;
  final double positionAngle;
  final String direction;
  final int compressionCount;
  final double compressionDepth;
  final double motorTemp;
  final bool recoilOk;
  final bool anomalyFlag;
  final bool gpsFix;
  final double? latitude;
  final double? longitude;
  final int? satellites;
  final double? speedKmh;
  final double? altitudeM;
  final String? gpsUtc;
  const TelemetrySample({
    required this.id,
    this.sessionId,
    required this.recordedAt,
    required this.source,
    required this.firmwareTimeMs,
    required this.setRpm,
    required this.actualRpm,
    required this.pwm,
    required this.rawCounts,
    required this.freqHz,
    required this.loadCellRaw,
    required this.instantForce,
    required this.peakForce,
    required this.positionAngle,
    required this.direction,
    required this.compressionCount,
    required this.compressionDepth,
    required this.motorTemp,
    required this.recoilOk,
    required this.anomalyFlag,
    required this.gpsFix,
    this.latitude,
    this.longitude,
    this.satellites,
    this.speedKmh,
    this.altitudeM,
    this.gpsUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['source'] = Variable<String>(source);
    map['firmware_time_ms'] = Variable<int>(firmwareTimeMs);
    map['set_rpm'] = Variable<double>(setRpm);
    map['actual_rpm'] = Variable<double>(actualRpm);
    map['pwm'] = Variable<int>(pwm);
    map['raw_counts'] = Variable<int>(rawCounts);
    map['freq_hz'] = Variable<double>(freqHz);
    map['load_cell_raw'] = Variable<double>(loadCellRaw);
    map['instant_force'] = Variable<double>(instantForce);
    map['peak_force'] = Variable<double>(peakForce);
    map['position_angle'] = Variable<double>(positionAngle);
    map['direction'] = Variable<String>(direction);
    map['compression_count'] = Variable<int>(compressionCount);
    map['compression_depth'] = Variable<double>(compressionDepth);
    map['motor_temp'] = Variable<double>(motorTemp);
    map['recoil_ok'] = Variable<bool>(recoilOk);
    map['anomaly_flag'] = Variable<bool>(anomalyFlag);
    map['gps_fix'] = Variable<bool>(gpsFix);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || satellites != null) {
      map['satellites'] = Variable<int>(satellites);
    }
    if (!nullToAbsent || speedKmh != null) {
      map['speed_kmh'] = Variable<double>(speedKmh);
    }
    if (!nullToAbsent || altitudeM != null) {
      map['altitude_m'] = Variable<double>(altitudeM);
    }
    if (!nullToAbsent || gpsUtc != null) {
      map['gps_utc'] = Variable<String>(gpsUtc);
    }
    return map;
  }

  TelemetrySamplesCompanion toCompanion(bool nullToAbsent) {
    return TelemetrySamplesCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      recordedAt: Value(recordedAt),
      source: Value(source),
      firmwareTimeMs: Value(firmwareTimeMs),
      setRpm: Value(setRpm),
      actualRpm: Value(actualRpm),
      pwm: Value(pwm),
      rawCounts: Value(rawCounts),
      freqHz: Value(freqHz),
      loadCellRaw: Value(loadCellRaw),
      instantForce: Value(instantForce),
      peakForce: Value(peakForce),
      positionAngle: Value(positionAngle),
      direction: Value(direction),
      compressionCount: Value(compressionCount),
      compressionDepth: Value(compressionDepth),
      motorTemp: Value(motorTemp),
      recoilOk: Value(recoilOk),
      anomalyFlag: Value(anomalyFlag),
      gpsFix: Value(gpsFix),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      satellites: satellites == null && nullToAbsent
          ? const Value.absent()
          : Value(satellites),
      speedKmh: speedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(speedKmh),
      altitudeM: altitudeM == null && nullToAbsent
          ? const Value.absent()
          : Value(altitudeM),
      gpsUtc: gpsUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsUtc),
    );
  }

  factory TelemetrySample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TelemetrySample(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      source: serializer.fromJson<String>(json['source']),
      firmwareTimeMs: serializer.fromJson<int>(json['firmwareTimeMs']),
      setRpm: serializer.fromJson<double>(json['setRpm']),
      actualRpm: serializer.fromJson<double>(json['actualRpm']),
      pwm: serializer.fromJson<int>(json['pwm']),
      rawCounts: serializer.fromJson<int>(json['rawCounts']),
      freqHz: serializer.fromJson<double>(json['freqHz']),
      loadCellRaw: serializer.fromJson<double>(json['loadCellRaw']),
      instantForce: serializer.fromJson<double>(json['instantForce']),
      peakForce: serializer.fromJson<double>(json['peakForce']),
      positionAngle: serializer.fromJson<double>(json['positionAngle']),
      direction: serializer.fromJson<String>(json['direction']),
      compressionCount: serializer.fromJson<int>(json['compressionCount']),
      compressionDepth: serializer.fromJson<double>(json['compressionDepth']),
      motorTemp: serializer.fromJson<double>(json['motorTemp']),
      recoilOk: serializer.fromJson<bool>(json['recoilOk']),
      anomalyFlag: serializer.fromJson<bool>(json['anomalyFlag']),
      gpsFix: serializer.fromJson<bool>(json['gpsFix']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      satellites: serializer.fromJson<int?>(json['satellites']),
      speedKmh: serializer.fromJson<double?>(json['speedKmh']),
      altitudeM: serializer.fromJson<double?>(json['altitudeM']),
      gpsUtc: serializer.fromJson<String?>(json['gpsUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int?>(sessionId),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'source': serializer.toJson<String>(source),
      'firmwareTimeMs': serializer.toJson<int>(firmwareTimeMs),
      'setRpm': serializer.toJson<double>(setRpm),
      'actualRpm': serializer.toJson<double>(actualRpm),
      'pwm': serializer.toJson<int>(pwm),
      'rawCounts': serializer.toJson<int>(rawCounts),
      'freqHz': serializer.toJson<double>(freqHz),
      'loadCellRaw': serializer.toJson<double>(loadCellRaw),
      'instantForce': serializer.toJson<double>(instantForce),
      'peakForce': serializer.toJson<double>(peakForce),
      'positionAngle': serializer.toJson<double>(positionAngle),
      'direction': serializer.toJson<String>(direction),
      'compressionCount': serializer.toJson<int>(compressionCount),
      'compressionDepth': serializer.toJson<double>(compressionDepth),
      'motorTemp': serializer.toJson<double>(motorTemp),
      'recoilOk': serializer.toJson<bool>(recoilOk),
      'anomalyFlag': serializer.toJson<bool>(anomalyFlag),
      'gpsFix': serializer.toJson<bool>(gpsFix),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'satellites': serializer.toJson<int?>(satellites),
      'speedKmh': serializer.toJson<double?>(speedKmh),
      'altitudeM': serializer.toJson<double?>(altitudeM),
      'gpsUtc': serializer.toJson<String?>(gpsUtc),
    };
  }

  TelemetrySample copyWith({
    int? id,
    Value<int?> sessionId = const Value.absent(),
    DateTime? recordedAt,
    String? source,
    int? firmwareTimeMs,
    double? setRpm,
    double? actualRpm,
    int? pwm,
    int? rawCounts,
    double? freqHz,
    double? loadCellRaw,
    double? instantForce,
    double? peakForce,
    double? positionAngle,
    String? direction,
    int? compressionCount,
    double? compressionDepth,
    double? motorTemp,
    bool? recoilOk,
    bool? anomalyFlag,
    bool? gpsFix,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<int?> satellites = const Value.absent(),
    Value<double?> speedKmh = const Value.absent(),
    Value<double?> altitudeM = const Value.absent(),
    Value<String?> gpsUtc = const Value.absent(),
  }) => TelemetrySample(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    recordedAt: recordedAt ?? this.recordedAt,
    source: source ?? this.source,
    firmwareTimeMs: firmwareTimeMs ?? this.firmwareTimeMs,
    setRpm: setRpm ?? this.setRpm,
    actualRpm: actualRpm ?? this.actualRpm,
    pwm: pwm ?? this.pwm,
    rawCounts: rawCounts ?? this.rawCounts,
    freqHz: freqHz ?? this.freqHz,
    loadCellRaw: loadCellRaw ?? this.loadCellRaw,
    instantForce: instantForce ?? this.instantForce,
    peakForce: peakForce ?? this.peakForce,
    positionAngle: positionAngle ?? this.positionAngle,
    direction: direction ?? this.direction,
    compressionCount: compressionCount ?? this.compressionCount,
    compressionDepth: compressionDepth ?? this.compressionDepth,
    motorTemp: motorTemp ?? this.motorTemp,
    recoilOk: recoilOk ?? this.recoilOk,
    anomalyFlag: anomalyFlag ?? this.anomalyFlag,
    gpsFix: gpsFix ?? this.gpsFix,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    satellites: satellites.present ? satellites.value : this.satellites,
    speedKmh: speedKmh.present ? speedKmh.value : this.speedKmh,
    altitudeM: altitudeM.present ? altitudeM.value : this.altitudeM,
    gpsUtc: gpsUtc.present ? gpsUtc.value : this.gpsUtc,
  );
  TelemetrySample copyWithCompanion(TelemetrySamplesCompanion data) {
    return TelemetrySample(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      source: data.source.present ? data.source.value : this.source,
      firmwareTimeMs: data.firmwareTimeMs.present
          ? data.firmwareTimeMs.value
          : this.firmwareTimeMs,
      setRpm: data.setRpm.present ? data.setRpm.value : this.setRpm,
      actualRpm: data.actualRpm.present ? data.actualRpm.value : this.actualRpm,
      pwm: data.pwm.present ? data.pwm.value : this.pwm,
      rawCounts: data.rawCounts.present ? data.rawCounts.value : this.rawCounts,
      freqHz: data.freqHz.present ? data.freqHz.value : this.freqHz,
      loadCellRaw: data.loadCellRaw.present
          ? data.loadCellRaw.value
          : this.loadCellRaw,
      instantForce: data.instantForce.present
          ? data.instantForce.value
          : this.instantForce,
      peakForce: data.peakForce.present ? data.peakForce.value : this.peakForce,
      positionAngle: data.positionAngle.present
          ? data.positionAngle.value
          : this.positionAngle,
      direction: data.direction.present ? data.direction.value : this.direction,
      compressionCount: data.compressionCount.present
          ? data.compressionCount.value
          : this.compressionCount,
      compressionDepth: data.compressionDepth.present
          ? data.compressionDepth.value
          : this.compressionDepth,
      motorTemp: data.motorTemp.present ? data.motorTemp.value : this.motorTemp,
      recoilOk: data.recoilOk.present ? data.recoilOk.value : this.recoilOk,
      anomalyFlag: data.anomalyFlag.present
          ? data.anomalyFlag.value
          : this.anomalyFlag,
      gpsFix: data.gpsFix.present ? data.gpsFix.value : this.gpsFix,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      satellites: data.satellites.present
          ? data.satellites.value
          : this.satellites,
      speedKmh: data.speedKmh.present ? data.speedKmh.value : this.speedKmh,
      altitudeM: data.altitudeM.present ? data.altitudeM.value : this.altitudeM,
      gpsUtc: data.gpsUtc.present ? data.gpsUtc.value : this.gpsUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TelemetrySample(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('source: $source, ')
          ..write('firmwareTimeMs: $firmwareTimeMs, ')
          ..write('setRpm: $setRpm, ')
          ..write('actualRpm: $actualRpm, ')
          ..write('pwm: $pwm, ')
          ..write('rawCounts: $rawCounts, ')
          ..write('freqHz: $freqHz, ')
          ..write('loadCellRaw: $loadCellRaw, ')
          ..write('instantForce: $instantForce, ')
          ..write('peakForce: $peakForce, ')
          ..write('positionAngle: $positionAngle, ')
          ..write('direction: $direction, ')
          ..write('compressionCount: $compressionCount, ')
          ..write('compressionDepth: $compressionDepth, ')
          ..write('motorTemp: $motorTemp, ')
          ..write('recoilOk: $recoilOk, ')
          ..write('anomalyFlag: $anomalyFlag, ')
          ..write('gpsFix: $gpsFix, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('satellites: $satellites, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('gpsUtc: $gpsUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sessionId,
    recordedAt,
    source,
    firmwareTimeMs,
    setRpm,
    actualRpm,
    pwm,
    rawCounts,
    freqHz,
    loadCellRaw,
    instantForce,
    peakForce,
    positionAngle,
    direction,
    compressionCount,
    compressionDepth,
    motorTemp,
    recoilOk,
    anomalyFlag,
    gpsFix,
    latitude,
    longitude,
    satellites,
    speedKmh,
    altitudeM,
    gpsUtc,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TelemetrySample &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.recordedAt == this.recordedAt &&
          other.source == this.source &&
          other.firmwareTimeMs == this.firmwareTimeMs &&
          other.setRpm == this.setRpm &&
          other.actualRpm == this.actualRpm &&
          other.pwm == this.pwm &&
          other.rawCounts == this.rawCounts &&
          other.freqHz == this.freqHz &&
          other.loadCellRaw == this.loadCellRaw &&
          other.instantForce == this.instantForce &&
          other.peakForce == this.peakForce &&
          other.positionAngle == this.positionAngle &&
          other.direction == this.direction &&
          other.compressionCount == this.compressionCount &&
          other.compressionDepth == this.compressionDepth &&
          other.motorTemp == this.motorTemp &&
          other.recoilOk == this.recoilOk &&
          other.anomalyFlag == this.anomalyFlag &&
          other.gpsFix == this.gpsFix &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.satellites == this.satellites &&
          other.speedKmh == this.speedKmh &&
          other.altitudeM == this.altitudeM &&
          other.gpsUtc == this.gpsUtc);
}

class TelemetrySamplesCompanion extends UpdateCompanion<TelemetrySample> {
  final Value<int> id;
  final Value<int?> sessionId;
  final Value<DateTime> recordedAt;
  final Value<String> source;
  final Value<int> firmwareTimeMs;
  final Value<double> setRpm;
  final Value<double> actualRpm;
  final Value<int> pwm;
  final Value<int> rawCounts;
  final Value<double> freqHz;
  final Value<double> loadCellRaw;
  final Value<double> instantForce;
  final Value<double> peakForce;
  final Value<double> positionAngle;
  final Value<String> direction;
  final Value<int> compressionCount;
  final Value<double> compressionDepth;
  final Value<double> motorTemp;
  final Value<bool> recoilOk;
  final Value<bool> anomalyFlag;
  final Value<bool> gpsFix;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int?> satellites;
  final Value<double?> speedKmh;
  final Value<double?> altitudeM;
  final Value<String?> gpsUtc;
  const TelemetrySamplesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.firmwareTimeMs = const Value.absent(),
    this.setRpm = const Value.absent(),
    this.actualRpm = const Value.absent(),
    this.pwm = const Value.absent(),
    this.rawCounts = const Value.absent(),
    this.freqHz = const Value.absent(),
    this.loadCellRaw = const Value.absent(),
    this.instantForce = const Value.absent(),
    this.peakForce = const Value.absent(),
    this.positionAngle = const Value.absent(),
    this.direction = const Value.absent(),
    this.compressionCount = const Value.absent(),
    this.compressionDepth = const Value.absent(),
    this.motorTemp = const Value.absent(),
    this.recoilOk = const Value.absent(),
    this.anomalyFlag = const Value.absent(),
    this.gpsFix = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.satellites = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.altitudeM = const Value.absent(),
    this.gpsUtc = const Value.absent(),
  });
  TelemetrySamplesCompanion.insert({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    required String source,
    required int firmwareTimeMs,
    required double setRpm,
    required double actualRpm,
    required int pwm,
    required int rawCounts,
    required double freqHz,
    required double loadCellRaw,
    required double instantForce,
    required double peakForce,
    required double positionAngle,
    required String direction,
    required int compressionCount,
    required double compressionDepth,
    required double motorTemp,
    required bool recoilOk,
    required bool anomalyFlag,
    this.gpsFix = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.satellites = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.altitudeM = const Value.absent(),
    this.gpsUtc = const Value.absent(),
  }) : source = Value(source),
       firmwareTimeMs = Value(firmwareTimeMs),
       setRpm = Value(setRpm),
       actualRpm = Value(actualRpm),
       pwm = Value(pwm),
       rawCounts = Value(rawCounts),
       freqHz = Value(freqHz),
       loadCellRaw = Value(loadCellRaw),
       instantForce = Value(instantForce),
       peakForce = Value(peakForce),
       positionAngle = Value(positionAngle),
       direction = Value(direction),
       compressionCount = Value(compressionCount),
       compressionDepth = Value(compressionDepth),
       motorTemp = Value(motorTemp),
       recoilOk = Value(recoilOk),
       anomalyFlag = Value(anomalyFlag);
  static Insertable<TelemetrySample> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<DateTime>? recordedAt,
    Expression<String>? source,
    Expression<int>? firmwareTimeMs,
    Expression<double>? setRpm,
    Expression<double>? actualRpm,
    Expression<int>? pwm,
    Expression<int>? rawCounts,
    Expression<double>? freqHz,
    Expression<double>? loadCellRaw,
    Expression<double>? instantForce,
    Expression<double>? peakForce,
    Expression<double>? positionAngle,
    Expression<String>? direction,
    Expression<int>? compressionCount,
    Expression<double>? compressionDepth,
    Expression<double>? motorTemp,
    Expression<bool>? recoilOk,
    Expression<bool>? anomalyFlag,
    Expression<bool>? gpsFix,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? satellites,
    Expression<double>? speedKmh,
    Expression<double>? altitudeM,
    Expression<String>? gpsUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (source != null) 'source': source,
      if (firmwareTimeMs != null) 'firmware_time_ms': firmwareTimeMs,
      if (setRpm != null) 'set_rpm': setRpm,
      if (actualRpm != null) 'actual_rpm': actualRpm,
      if (pwm != null) 'pwm': pwm,
      if (rawCounts != null) 'raw_counts': rawCounts,
      if (freqHz != null) 'freq_hz': freqHz,
      if (loadCellRaw != null) 'load_cell_raw': loadCellRaw,
      if (instantForce != null) 'instant_force': instantForce,
      if (peakForce != null) 'peak_force': peakForce,
      if (positionAngle != null) 'position_angle': positionAngle,
      if (direction != null) 'direction': direction,
      if (compressionCount != null) 'compression_count': compressionCount,
      if (compressionDepth != null) 'compression_depth': compressionDepth,
      if (motorTemp != null) 'motor_temp': motorTemp,
      if (recoilOk != null) 'recoil_ok': recoilOk,
      if (anomalyFlag != null) 'anomaly_flag': anomalyFlag,
      if (gpsFix != null) 'gps_fix': gpsFix,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (satellites != null) 'satellites': satellites,
      if (speedKmh != null) 'speed_kmh': speedKmh,
      if (altitudeM != null) 'altitude_m': altitudeM,
      if (gpsUtc != null) 'gps_utc': gpsUtc,
    });
  }

  TelemetrySamplesCompanion copyWith({
    Value<int>? id,
    Value<int?>? sessionId,
    Value<DateTime>? recordedAt,
    Value<String>? source,
    Value<int>? firmwareTimeMs,
    Value<double>? setRpm,
    Value<double>? actualRpm,
    Value<int>? pwm,
    Value<int>? rawCounts,
    Value<double>? freqHz,
    Value<double>? loadCellRaw,
    Value<double>? instantForce,
    Value<double>? peakForce,
    Value<double>? positionAngle,
    Value<String>? direction,
    Value<int>? compressionCount,
    Value<double>? compressionDepth,
    Value<double>? motorTemp,
    Value<bool>? recoilOk,
    Value<bool>? anomalyFlag,
    Value<bool>? gpsFix,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<int?>? satellites,
    Value<double?>? speedKmh,
    Value<double?>? altitudeM,
    Value<String?>? gpsUtc,
  }) {
    return TelemetrySamplesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      recordedAt: recordedAt ?? this.recordedAt,
      source: source ?? this.source,
      firmwareTimeMs: firmwareTimeMs ?? this.firmwareTimeMs,
      setRpm: setRpm ?? this.setRpm,
      actualRpm: actualRpm ?? this.actualRpm,
      pwm: pwm ?? this.pwm,
      rawCounts: rawCounts ?? this.rawCounts,
      freqHz: freqHz ?? this.freqHz,
      loadCellRaw: loadCellRaw ?? this.loadCellRaw,
      instantForce: instantForce ?? this.instantForce,
      peakForce: peakForce ?? this.peakForce,
      positionAngle: positionAngle ?? this.positionAngle,
      direction: direction ?? this.direction,
      compressionCount: compressionCount ?? this.compressionCount,
      compressionDepth: compressionDepth ?? this.compressionDepth,
      motorTemp: motorTemp ?? this.motorTemp,
      recoilOk: recoilOk ?? this.recoilOk,
      anomalyFlag: anomalyFlag ?? this.anomalyFlag,
      gpsFix: gpsFix ?? this.gpsFix,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      satellites: satellites ?? this.satellites,
      speedKmh: speedKmh ?? this.speedKmh,
      altitudeM: altitudeM ?? this.altitudeM,
      gpsUtc: gpsUtc ?? this.gpsUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (firmwareTimeMs.present) {
      map['firmware_time_ms'] = Variable<int>(firmwareTimeMs.value);
    }
    if (setRpm.present) {
      map['set_rpm'] = Variable<double>(setRpm.value);
    }
    if (actualRpm.present) {
      map['actual_rpm'] = Variable<double>(actualRpm.value);
    }
    if (pwm.present) {
      map['pwm'] = Variable<int>(pwm.value);
    }
    if (rawCounts.present) {
      map['raw_counts'] = Variable<int>(rawCounts.value);
    }
    if (freqHz.present) {
      map['freq_hz'] = Variable<double>(freqHz.value);
    }
    if (loadCellRaw.present) {
      map['load_cell_raw'] = Variable<double>(loadCellRaw.value);
    }
    if (instantForce.present) {
      map['instant_force'] = Variable<double>(instantForce.value);
    }
    if (peakForce.present) {
      map['peak_force'] = Variable<double>(peakForce.value);
    }
    if (positionAngle.present) {
      map['position_angle'] = Variable<double>(positionAngle.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (compressionCount.present) {
      map['compression_count'] = Variable<int>(compressionCount.value);
    }
    if (compressionDepth.present) {
      map['compression_depth'] = Variable<double>(compressionDepth.value);
    }
    if (motorTemp.present) {
      map['motor_temp'] = Variable<double>(motorTemp.value);
    }
    if (recoilOk.present) {
      map['recoil_ok'] = Variable<bool>(recoilOk.value);
    }
    if (anomalyFlag.present) {
      map['anomaly_flag'] = Variable<bool>(anomalyFlag.value);
    }
    if (gpsFix.present) {
      map['gps_fix'] = Variable<bool>(gpsFix.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (satellites.present) {
      map['satellites'] = Variable<int>(satellites.value);
    }
    if (speedKmh.present) {
      map['speed_kmh'] = Variable<double>(speedKmh.value);
    }
    if (altitudeM.present) {
      map['altitude_m'] = Variable<double>(altitudeM.value);
    }
    if (gpsUtc.present) {
      map['gps_utc'] = Variable<String>(gpsUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TelemetrySamplesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('source: $source, ')
          ..write('firmwareTimeMs: $firmwareTimeMs, ')
          ..write('setRpm: $setRpm, ')
          ..write('actualRpm: $actualRpm, ')
          ..write('pwm: $pwm, ')
          ..write('rawCounts: $rawCounts, ')
          ..write('freqHz: $freqHz, ')
          ..write('loadCellRaw: $loadCellRaw, ')
          ..write('instantForce: $instantForce, ')
          ..write('peakForce: $peakForce, ')
          ..write('positionAngle: $positionAngle, ')
          ..write('direction: $direction, ')
          ..write('compressionCount: $compressionCount, ')
          ..write('compressionDepth: $compressionDepth, ')
          ..write('motorTemp: $motorTemp, ')
          ..write('recoilOk: $recoilOk, ')
          ..write('anomalyFlag: $anomalyFlag, ')
          ..write('gpsFix: $gpsFix, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('satellites: $satellites, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('gpsUtc: $gpsUtc')
          ..write(')'))
        .toString();
  }
}

class $TelemetryLogsTable extends TelemetryLogs
    with TableInfo<$TelemetryLogsTable, TelemetryLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TelemetryLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES telemetry_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeLabelMeta = const VerificationMeta(
    'timeLabel',
  );
  @override
  late final GeneratedColumn<String> timeLabel = GeneratedColumn<String>(
    'time_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeLabelMeta = const VerificationMeta(
    'sizeLabel',
  );
  @override
  late final GeneratedColumn<String> sizeLabel = GeneratedColumn<String>(
    'size_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDerateMeta = const VerificationMeta(
    'isDerate',
  );
  @override
  late final GeneratedColumn<bool> isDerate = GeneratedColumn<bool>(
    'is_derate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_derate" IN (0, 1))',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previewMeta = const VerificationMeta(
    'preview',
  );
  @override
  late final GeneratedColumn<String> preview = GeneratedColumn<String>(
    'preview',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullJsonMeta = const VerificationMeta(
    'fullJson',
  );
  @override
  late final GeneratedColumn<String> fullJson = GeneratedColumn<String>(
    'full_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    name,
    timeLabel,
    sizeLabel,
    status,
    isDerate,
    category,
    source,
    preview,
    fullJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'telemetry_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TelemetryLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('time_label')) {
      context.handle(
        _timeLabelMeta,
        timeLabel.isAcceptableOrUnknown(data['time_label']!, _timeLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_timeLabelMeta);
    }
    if (data.containsKey('size_label')) {
      context.handle(
        _sizeLabelMeta,
        sizeLabel.isAcceptableOrUnknown(data['size_label']!, _sizeLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeLabelMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('is_derate')) {
      context.handle(
        _isDerateMeta,
        isDerate.isAcceptableOrUnknown(data['is_derate']!, _isDerateMeta),
      );
    } else if (isInserting) {
      context.missing(_isDerateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('preview')) {
      context.handle(
        _previewMeta,
        preview.isAcceptableOrUnknown(data['preview']!, _previewMeta),
      );
    } else if (isInserting) {
      context.missing(_previewMeta);
    }
    if (data.containsKey('full_json')) {
      context.handle(
        _fullJsonMeta,
        fullJson.isAcceptableOrUnknown(data['full_json']!, _fullJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_fullJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TelemetryLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TelemetryLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      timeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_label'],
      )!,
      sizeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size_label'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isDerate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_derate'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      preview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preview'],
      )!,
      fullJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TelemetryLogsTable createAlias(String alias) {
    return $TelemetryLogsTable(attachedDatabase, alias);
  }
}

class TelemetryLog extends DataClass implements Insertable<TelemetryLog> {
  final int id;
  final int? sessionId;
  final String name;
  final String timeLabel;
  final String sizeLabel;
  final String status;
  final bool isDerate;
  final String category;
  final String source;
  final String preview;
  final String fullJson;
  final DateTime createdAt;
  const TelemetryLog({
    required this.id,
    this.sessionId,
    required this.name,
    required this.timeLabel,
    required this.sizeLabel,
    required this.status,
    required this.isDerate,
    required this.category,
    required this.source,
    required this.preview,
    required this.fullJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['name'] = Variable<String>(name);
    map['time_label'] = Variable<String>(timeLabel);
    map['size_label'] = Variable<String>(sizeLabel);
    map['status'] = Variable<String>(status);
    map['is_derate'] = Variable<bool>(isDerate);
    map['category'] = Variable<String>(category);
    map['source'] = Variable<String>(source);
    map['preview'] = Variable<String>(preview);
    map['full_json'] = Variable<String>(fullJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TelemetryLogsCompanion toCompanion(bool nullToAbsent) {
    return TelemetryLogsCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      name: Value(name),
      timeLabel: Value(timeLabel),
      sizeLabel: Value(sizeLabel),
      status: Value(status),
      isDerate: Value(isDerate),
      category: Value(category),
      source: Value(source),
      preview: Value(preview),
      fullJson: Value(fullJson),
      createdAt: Value(createdAt),
    );
  }

  factory TelemetryLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TelemetryLog(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      name: serializer.fromJson<String>(json['name']),
      timeLabel: serializer.fromJson<String>(json['timeLabel']),
      sizeLabel: serializer.fromJson<String>(json['sizeLabel']),
      status: serializer.fromJson<String>(json['status']),
      isDerate: serializer.fromJson<bool>(json['isDerate']),
      category: serializer.fromJson<String>(json['category']),
      source: serializer.fromJson<String>(json['source']),
      preview: serializer.fromJson<String>(json['preview']),
      fullJson: serializer.fromJson<String>(json['fullJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int?>(sessionId),
      'name': serializer.toJson<String>(name),
      'timeLabel': serializer.toJson<String>(timeLabel),
      'sizeLabel': serializer.toJson<String>(sizeLabel),
      'status': serializer.toJson<String>(status),
      'isDerate': serializer.toJson<bool>(isDerate),
      'category': serializer.toJson<String>(category),
      'source': serializer.toJson<String>(source),
      'preview': serializer.toJson<String>(preview),
      'fullJson': serializer.toJson<String>(fullJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TelemetryLog copyWith({
    int? id,
    Value<int?> sessionId = const Value.absent(),
    String? name,
    String? timeLabel,
    String? sizeLabel,
    String? status,
    bool? isDerate,
    String? category,
    String? source,
    String? preview,
    String? fullJson,
    DateTime? createdAt,
  }) => TelemetryLog(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    name: name ?? this.name,
    timeLabel: timeLabel ?? this.timeLabel,
    sizeLabel: sizeLabel ?? this.sizeLabel,
    status: status ?? this.status,
    isDerate: isDerate ?? this.isDerate,
    category: category ?? this.category,
    source: source ?? this.source,
    preview: preview ?? this.preview,
    fullJson: fullJson ?? this.fullJson,
    createdAt: createdAt ?? this.createdAt,
  );
  TelemetryLog copyWithCompanion(TelemetryLogsCompanion data) {
    return TelemetryLog(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      name: data.name.present ? data.name.value : this.name,
      timeLabel: data.timeLabel.present ? data.timeLabel.value : this.timeLabel,
      sizeLabel: data.sizeLabel.present ? data.sizeLabel.value : this.sizeLabel,
      status: data.status.present ? data.status.value : this.status,
      isDerate: data.isDerate.present ? data.isDerate.value : this.isDerate,
      category: data.category.present ? data.category.value : this.category,
      source: data.source.present ? data.source.value : this.source,
      preview: data.preview.present ? data.preview.value : this.preview,
      fullJson: data.fullJson.present ? data.fullJson.value : this.fullJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TelemetryLog(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('name: $name, ')
          ..write('timeLabel: $timeLabel, ')
          ..write('sizeLabel: $sizeLabel, ')
          ..write('status: $status, ')
          ..write('isDerate: $isDerate, ')
          ..write('category: $category, ')
          ..write('source: $source, ')
          ..write('preview: $preview, ')
          ..write('fullJson: $fullJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    name,
    timeLabel,
    sizeLabel,
    status,
    isDerate,
    category,
    source,
    preview,
    fullJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TelemetryLog &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.name == this.name &&
          other.timeLabel == this.timeLabel &&
          other.sizeLabel == this.sizeLabel &&
          other.status == this.status &&
          other.isDerate == this.isDerate &&
          other.category == this.category &&
          other.source == this.source &&
          other.preview == this.preview &&
          other.fullJson == this.fullJson &&
          other.createdAt == this.createdAt);
}

class TelemetryLogsCompanion extends UpdateCompanion<TelemetryLog> {
  final Value<int> id;
  final Value<int?> sessionId;
  final Value<String> name;
  final Value<String> timeLabel;
  final Value<String> sizeLabel;
  final Value<String> status;
  final Value<bool> isDerate;
  final Value<String> category;
  final Value<String> source;
  final Value<String> preview;
  final Value<String> fullJson;
  final Value<DateTime> createdAt;
  const TelemetryLogsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.name = const Value.absent(),
    this.timeLabel = const Value.absent(),
    this.sizeLabel = const Value.absent(),
    this.status = const Value.absent(),
    this.isDerate = const Value.absent(),
    this.category = const Value.absent(),
    this.source = const Value.absent(),
    this.preview = const Value.absent(),
    this.fullJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TelemetryLogsCompanion.insert({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    required String name,
    required String timeLabel,
    required String sizeLabel,
    required String status,
    required bool isDerate,
    required String category,
    required String source,
    required String preview,
    required String fullJson,
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       timeLabel = Value(timeLabel),
       sizeLabel = Value(sizeLabel),
       status = Value(status),
       isDerate = Value(isDerate),
       category = Value(category),
       source = Value(source),
       preview = Value(preview),
       fullJson = Value(fullJson);
  static Insertable<TelemetryLog> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? name,
    Expression<String>? timeLabel,
    Expression<String>? sizeLabel,
    Expression<String>? status,
    Expression<bool>? isDerate,
    Expression<String>? category,
    Expression<String>? source,
    Expression<String>? preview,
    Expression<String>? fullJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (name != null) 'name': name,
      if (timeLabel != null) 'time_label': timeLabel,
      if (sizeLabel != null) 'size_label': sizeLabel,
      if (status != null) 'status': status,
      if (isDerate != null) 'is_derate': isDerate,
      if (category != null) 'category': category,
      if (source != null) 'source': source,
      if (preview != null) 'preview': preview,
      if (fullJson != null) 'full_json': fullJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TelemetryLogsCompanion copyWith({
    Value<int>? id,
    Value<int?>? sessionId,
    Value<String>? name,
    Value<String>? timeLabel,
    Value<String>? sizeLabel,
    Value<String>? status,
    Value<bool>? isDerate,
    Value<String>? category,
    Value<String>? source,
    Value<String>? preview,
    Value<String>? fullJson,
    Value<DateTime>? createdAt,
  }) {
    return TelemetryLogsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      name: name ?? this.name,
      timeLabel: timeLabel ?? this.timeLabel,
      sizeLabel: sizeLabel ?? this.sizeLabel,
      status: status ?? this.status,
      isDerate: isDerate ?? this.isDerate,
      category: category ?? this.category,
      source: source ?? this.source,
      preview: preview ?? this.preview,
      fullJson: fullJson ?? this.fullJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (timeLabel.present) {
      map['time_label'] = Variable<String>(timeLabel.value);
    }
    if (sizeLabel.present) {
      map['size_label'] = Variable<String>(sizeLabel.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isDerate.present) {
      map['is_derate'] = Variable<bool>(isDerate.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (preview.present) {
      map['preview'] = Variable<String>(preview.value);
    }
    if (fullJson.present) {
      map['full_json'] = Variable<String>(fullJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TelemetryLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('name: $name, ')
          ..write('timeLabel: $timeLabel, ')
          ..write('sizeLabel: $sizeLabel, ')
          ..write('status: $status, ')
          ..write('isDerate: $isDerate, ')
          ..write('category: $category, ')
          ..write('source: $source, ')
          ..write('preview: $preview, ')
          ..write('fullJson: $fullJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TelemetrySessionsTable telemetrySessions =
      $TelemetrySessionsTable(this);
  late final $TelemetrySamplesTable telemetrySamples = $TelemetrySamplesTable(
    this,
  );
  late final $TelemetryLogsTable telemetryLogs = $TelemetryLogsTable(this);
  late final Index idxSamplesRecordedAt = Index(
    'idx_samples_recorded_at',
    'CREATE INDEX idx_samples_recorded_at ON telemetry_samples (recorded_at)',
  );
  late final Index idxLogsCreatedAt = Index(
    'idx_logs_created_at',
    'CREATE INDEX idx_logs_created_at ON telemetry_logs (created_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    telemetrySessions,
    telemetrySamples,
    telemetryLogs,
    idxSamplesRecordedAt,
    idxLogsCreatedAt,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'telemetry_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('telemetry_samples', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'telemetry_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('telemetry_logs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TelemetrySessionsTableCreateCompanionBuilder =
    TelemetrySessionsCompanion Function({
      Value<int> id,
      required String source,
      required String deviceId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> sampleCount,
      Value<double> maxPeakForce,
      Value<int> totalCompressions,
    });
typedef $$TelemetrySessionsTableUpdateCompanionBuilder =
    TelemetrySessionsCompanion Function({
      Value<int> id,
      Value<String> source,
      Value<String> deviceId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> sampleCount,
      Value<double> maxPeakForce,
      Value<int> totalCompressions,
    });

final class $$TelemetrySessionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TelemetrySessionsTable,
          TelemetrySession
        > {
  $$TelemetrySessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TelemetrySamplesTable, List<TelemetrySample>>
  _telemetrySamplesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.telemetrySamples,
    aliasName: 'telemetry_sessions__id__telemetry_samples__session_id',
  );

  $$TelemetrySamplesTableProcessedTableManager get telemetrySamplesRefs {
    final manager = $$TelemetrySamplesTableTableManager(
      $_db,
      $_db.telemetrySamples,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _telemetrySamplesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TelemetryLogsTable, List<TelemetryLog>>
  _telemetryLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.telemetryLogs,
    aliasName: 'telemetry_sessions__id__telemetry_logs__session_id',
  );

  $$TelemetryLogsTableProcessedTableManager get telemetryLogsRefs {
    final manager = $$TelemetryLogsTableTableManager(
      $_db,
      $_db.telemetryLogs,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_telemetryLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TelemetrySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TelemetrySessionsTable> {
  $$TelemetrySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxPeakForce => $composableBuilder(
    column: $table.maxPeakForce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCompressions => $composableBuilder(
    column: $table.totalCompressions,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> telemetrySamplesRefs(
    Expression<bool> Function($$TelemetrySamplesTableFilterComposer f) f,
  ) {
    final $$TelemetrySamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.telemetrySamples,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TelemetrySamplesTableFilterComposer(
            $db: $db,
            $table: $db.telemetrySamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> telemetryLogsRefs(
    Expression<bool> Function($$TelemetryLogsTableFilterComposer f) f,
  ) {
    final $$TelemetryLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.telemetryLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TelemetryLogsTableFilterComposer(
            $db: $db,
            $table: $db.telemetryLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TelemetrySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TelemetrySessionsTable> {
  $$TelemetrySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxPeakForce => $composableBuilder(
    column: $table.maxPeakForce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCompressions => $composableBuilder(
    column: $table.totalCompressions,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TelemetrySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TelemetrySessionsTable> {
  $$TelemetrySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxPeakForce => $composableBuilder(
    column: $table.maxPeakForce,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCompressions => $composableBuilder(
    column: $table.totalCompressions,
    builder: (column) => column,
  );

  Expression<T> telemetrySamplesRefs<T extends Object>(
    Expression<T> Function($$TelemetrySamplesTableAnnotationComposer a) f,
  ) {
    final $$TelemetrySamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.telemetrySamples,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TelemetrySamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.telemetrySamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> telemetryLogsRefs<T extends Object>(
    Expression<T> Function($$TelemetryLogsTableAnnotationComposer a) f,
  ) {
    final $$TelemetryLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.telemetryLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TelemetryLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.telemetryLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TelemetrySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TelemetrySessionsTable,
          TelemetrySession,
          $$TelemetrySessionsTableFilterComposer,
          $$TelemetrySessionsTableOrderingComposer,
          $$TelemetrySessionsTableAnnotationComposer,
          $$TelemetrySessionsTableCreateCompanionBuilder,
          $$TelemetrySessionsTableUpdateCompanionBuilder,
          (TelemetrySession, $$TelemetrySessionsTableReferences),
          TelemetrySession,
          PrefetchHooks Function({
            bool telemetrySamplesRefs,
            bool telemetryLogsRefs,
          })
        > {
  $$TelemetrySessionsTableTableManager(
    _$AppDatabase db,
    $TelemetrySessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TelemetrySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TelemetrySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TelemetrySessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
                Value<double> maxPeakForce = const Value.absent(),
                Value<int> totalCompressions = const Value.absent(),
              }) => TelemetrySessionsCompanion(
                id: id,
                source: source,
                deviceId: deviceId,
                startedAt: startedAt,
                endedAt: endedAt,
                sampleCount: sampleCount,
                maxPeakForce: maxPeakForce,
                totalCompressions: totalCompressions,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String source,
                required String deviceId,
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
                Value<double> maxPeakForce = const Value.absent(),
                Value<int> totalCompressions = const Value.absent(),
              }) => TelemetrySessionsCompanion.insert(
                id: id,
                source: source,
                deviceId: deviceId,
                startedAt: startedAt,
                endedAt: endedAt,
                sampleCount: sampleCount,
                maxPeakForce: maxPeakForce,
                totalCompressions: totalCompressions,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TelemetrySessionsTable, TelemetrySession>(table),
                  $$TelemetrySessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({telemetrySamplesRefs = false, telemetryLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (telemetrySamplesRefs) db.telemetrySamples,
                    if (telemetryLogsRefs) db.telemetryLogs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (telemetrySamplesRefs)
                        await $_getPrefetchedData<
                          TelemetrySession,
                          $TelemetrySessionsTable,
                          TelemetrySample
                        >(
                          currentTable: table,
                          referencedTable: $$TelemetrySessionsTableReferences
                              ._telemetrySamplesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TelemetrySessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).telemetrySamplesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (telemetryLogsRefs)
                        await $_getPrefetchedData<
                          TelemetrySession,
                          $TelemetrySessionsTable,
                          TelemetryLog
                        >(
                          currentTable: table,
                          referencedTable: $$TelemetrySessionsTableReferences
                              ._telemetryLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TelemetrySessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).telemetryLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TelemetrySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TelemetrySessionsTable,
      TelemetrySession,
      $$TelemetrySessionsTableFilterComposer,
      $$TelemetrySessionsTableOrderingComposer,
      $$TelemetrySessionsTableAnnotationComposer,
      $$TelemetrySessionsTableCreateCompanionBuilder,
      $$TelemetrySessionsTableUpdateCompanionBuilder,
      (TelemetrySession, $$TelemetrySessionsTableReferences),
      TelemetrySession,
      PrefetchHooks Function({
        bool telemetrySamplesRefs,
        bool telemetryLogsRefs,
      })
    >;
typedef $$TelemetrySamplesTableCreateCompanionBuilder =
    TelemetrySamplesCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      Value<DateTime> recordedAt,
      required String source,
      required int firmwareTimeMs,
      required double setRpm,
      required double actualRpm,
      required int pwm,
      required int rawCounts,
      required double freqHz,
      required double loadCellRaw,
      required double instantForce,
      required double peakForce,
      required double positionAngle,
      required String direction,
      required int compressionCount,
      required double compressionDepth,
      required double motorTemp,
      required bool recoilOk,
      required bool anomalyFlag,
      Value<bool> gpsFix,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int?> satellites,
      Value<double?> speedKmh,
      Value<double?> altitudeM,
      Value<String?> gpsUtc,
    });
typedef $$TelemetrySamplesTableUpdateCompanionBuilder =
    TelemetrySamplesCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      Value<DateTime> recordedAt,
      Value<String> source,
      Value<int> firmwareTimeMs,
      Value<double> setRpm,
      Value<double> actualRpm,
      Value<int> pwm,
      Value<int> rawCounts,
      Value<double> freqHz,
      Value<double> loadCellRaw,
      Value<double> instantForce,
      Value<double> peakForce,
      Value<double> positionAngle,
      Value<String> direction,
      Value<int> compressionCount,
      Value<double> compressionDepth,
      Value<double> motorTemp,
      Value<bool> recoilOk,
      Value<bool> anomalyFlag,
      Value<bool> gpsFix,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int?> satellites,
      Value<double?> speedKmh,
      Value<double?> altitudeM,
      Value<String?> gpsUtc,
    });

final class $$TelemetrySamplesTableReferences
    extends
        BaseReferences<_$AppDatabase, $TelemetrySamplesTable, TelemetrySample> {
  $$TelemetrySamplesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TelemetrySessionsTable _sessionIdTable(_$AppDatabase db) => db
      .telemetrySessions
      .createAlias('telemetry_samples__session_id__telemetry_sessions__id');

  $$TelemetrySessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<int>('session_id');
    if ($_column == null) return null;
    final manager = $$TelemetrySessionsTableTableManager(
      $_db,
      $_db.telemetrySessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TelemetrySamplesTableFilterComposer
    extends Composer<_$AppDatabase, $TelemetrySamplesTable> {
  $$TelemetrySamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firmwareTimeMs => $composableBuilder(
    column: $table.firmwareTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get setRpm => $composableBuilder(
    column: $table.setRpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualRpm => $composableBuilder(
    column: $table.actualRpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pwm => $composableBuilder(
    column: $table.pwm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rawCounts => $composableBuilder(
    column: $table.rawCounts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get freqHz => $composableBuilder(
    column: $table.freqHz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get loadCellRaw => $composableBuilder(
    column: $table.loadCellRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get instantForce => $composableBuilder(
    column: $table.instantForce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakForce => $composableBuilder(
    column: $table.peakForce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get positionAngle => $composableBuilder(
    column: $table.positionAngle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get compressionCount => $composableBuilder(
    column: $table.compressionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get compressionDepth => $composableBuilder(
    column: $table.compressionDepth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get motorTemp => $composableBuilder(
    column: $table.motorTemp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recoilOk => $composableBuilder(
    column: $table.recoilOk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get anomalyFlag => $composableBuilder(
    column: $table.anomalyFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get gpsFix => $composableBuilder(
    column: $table.gpsFix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get satellites => $composableBuilder(
    column: $table.satellites,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedKmh => $composableBuilder(
    column: $table.speedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gpsUtc => $composableBuilder(
    column: $table.gpsUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$TelemetrySessionsTableFilterComposer get sessionId {
    final $$TelemetrySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.telemetrySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TelemetrySessionsTableFilterComposer(
            $db: $db,
            $table: $db.telemetrySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TelemetrySamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $TelemetrySamplesTable> {
  $$TelemetrySamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firmwareTimeMs => $composableBuilder(
    column: $table.firmwareTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get setRpm => $composableBuilder(
    column: $table.setRpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualRpm => $composableBuilder(
    column: $table.actualRpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pwm => $composableBuilder(
    column: $table.pwm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rawCounts => $composableBuilder(
    column: $table.rawCounts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get freqHz => $composableBuilder(
    column: $table.freqHz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get loadCellRaw => $composableBuilder(
    column: $table.loadCellRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get instantForce => $composableBuilder(
    column: $table.instantForce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakForce => $composableBuilder(
    column: $table.peakForce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get positionAngle => $composableBuilder(
    column: $table.positionAngle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get compressionCount => $composableBuilder(
    column: $table.compressionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get compressionDepth => $composableBuilder(
    column: $table.compressionDepth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get motorTemp => $composableBuilder(
    column: $table.motorTemp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recoilOk => $composableBuilder(
    column: $table.recoilOk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get anomalyFlag => $composableBuilder(
    column: $table.anomalyFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get gpsFix => $composableBuilder(
    column: $table.gpsFix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get satellites => $composableBuilder(
    column: $table.satellites,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedKmh => $composableBuilder(
    column: $table.speedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gpsUtc => $composableBuilder(
    column: $table.gpsUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$TelemetrySessionsTableOrderingComposer get sessionId {
    final $$TelemetrySessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.telemetrySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TelemetrySessionsTableOrderingComposer(
            $db: $db,
            $table: $db.telemetrySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TelemetrySamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TelemetrySamplesTable> {
  $$TelemetrySamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get firmwareTimeMs => $composableBuilder(
    column: $table.firmwareTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get setRpm =>
      $composableBuilder(column: $table.setRpm, builder: (column) => column);

  GeneratedColumn<double> get actualRpm =>
      $composableBuilder(column: $table.actualRpm, builder: (column) => column);

  GeneratedColumn<int> get pwm =>
      $composableBuilder(column: $table.pwm, builder: (column) => column);

  GeneratedColumn<int> get rawCounts =>
      $composableBuilder(column: $table.rawCounts, builder: (column) => column);

  GeneratedColumn<double> get freqHz =>
      $composableBuilder(column: $table.freqHz, builder: (column) => column);

  GeneratedColumn<double> get loadCellRaw => $composableBuilder(
    column: $table.loadCellRaw,
    builder: (column) => column,
  );

  GeneratedColumn<double> get instantForce => $composableBuilder(
    column: $table.instantForce,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peakForce =>
      $composableBuilder(column: $table.peakForce, builder: (column) => column);

  GeneratedColumn<double> get positionAngle => $composableBuilder(
    column: $table.positionAngle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get compressionCount => $composableBuilder(
    column: $table.compressionCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get compressionDepth => $composableBuilder(
    column: $table.compressionDepth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get motorTemp =>
      $composableBuilder(column: $table.motorTemp, builder: (column) => column);

  GeneratedColumn<bool> get recoilOk =>
      $composableBuilder(column: $table.recoilOk, builder: (column) => column);

  GeneratedColumn<bool> get anomalyFlag => $composableBuilder(
    column: $table.anomalyFlag,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get gpsFix =>
      $composableBuilder(column: $table.gpsFix, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get satellites => $composableBuilder(
    column: $table.satellites,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speedKmh =>
      $composableBuilder(column: $table.speedKmh, builder: (column) => column);

  GeneratedColumn<double> get altitudeM =>
      $composableBuilder(column: $table.altitudeM, builder: (column) => column);

  GeneratedColumn<String> get gpsUtc =>
      $composableBuilder(column: $table.gpsUtc, builder: (column) => column);

  $$TelemetrySessionsTableAnnotationComposer get sessionId {
    final $$TelemetrySessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.telemetrySessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TelemetrySessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.telemetrySessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TelemetrySamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TelemetrySamplesTable,
          TelemetrySample,
          $$TelemetrySamplesTableFilterComposer,
          $$TelemetrySamplesTableOrderingComposer,
          $$TelemetrySamplesTableAnnotationComposer,
          $$TelemetrySamplesTableCreateCompanionBuilder,
          $$TelemetrySamplesTableUpdateCompanionBuilder,
          (TelemetrySample, $$TelemetrySamplesTableReferences),
          TelemetrySample,
          PrefetchHooks Function({bool sessionId})
        > {
  $$TelemetrySamplesTableTableManager(
    _$AppDatabase db,
    $TelemetrySamplesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TelemetrySamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TelemetrySamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TelemetrySamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> firmwareTimeMs = const Value.absent(),
                Value<double> setRpm = const Value.absent(),
                Value<double> actualRpm = const Value.absent(),
                Value<int> pwm = const Value.absent(),
                Value<int> rawCounts = const Value.absent(),
                Value<double> freqHz = const Value.absent(),
                Value<double> loadCellRaw = const Value.absent(),
                Value<double> instantForce = const Value.absent(),
                Value<double> peakForce = const Value.absent(),
                Value<double> positionAngle = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int> compressionCount = const Value.absent(),
                Value<double> compressionDepth = const Value.absent(),
                Value<double> motorTemp = const Value.absent(),
                Value<bool> recoilOk = const Value.absent(),
                Value<bool> anomalyFlag = const Value.absent(),
                Value<bool> gpsFix = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int?> satellites = const Value.absent(),
                Value<double?> speedKmh = const Value.absent(),
                Value<double?> altitudeM = const Value.absent(),
                Value<String?> gpsUtc = const Value.absent(),
              }) => TelemetrySamplesCompanion(
                id: id,
                sessionId: sessionId,
                recordedAt: recordedAt,
                source: source,
                firmwareTimeMs: firmwareTimeMs,
                setRpm: setRpm,
                actualRpm: actualRpm,
                pwm: pwm,
                rawCounts: rawCounts,
                freqHz: freqHz,
                loadCellRaw: loadCellRaw,
                instantForce: instantForce,
                peakForce: peakForce,
                positionAngle: positionAngle,
                direction: direction,
                compressionCount: compressionCount,
                compressionDepth: compressionDepth,
                motorTemp: motorTemp,
                recoilOk: recoilOk,
                anomalyFlag: anomalyFlag,
                gpsFix: gpsFix,
                latitude: latitude,
                longitude: longitude,
                satellites: satellites,
                speedKmh: speedKmh,
                altitudeM: altitudeM,
                gpsUtc: gpsUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                required String source,
                required int firmwareTimeMs,
                required double setRpm,
                required double actualRpm,
                required int pwm,
                required int rawCounts,
                required double freqHz,
                required double loadCellRaw,
                required double instantForce,
                required double peakForce,
                required double positionAngle,
                required String direction,
                required int compressionCount,
                required double compressionDepth,
                required double motorTemp,
                required bool recoilOk,
                required bool anomalyFlag,
                Value<bool> gpsFix = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int?> satellites = const Value.absent(),
                Value<double?> speedKmh = const Value.absent(),
                Value<double?> altitudeM = const Value.absent(),
                Value<String?> gpsUtc = const Value.absent(),
              }) => TelemetrySamplesCompanion.insert(
                id: id,
                sessionId: sessionId,
                recordedAt: recordedAt,
                source: source,
                firmwareTimeMs: firmwareTimeMs,
                setRpm: setRpm,
                actualRpm: actualRpm,
                pwm: pwm,
                rawCounts: rawCounts,
                freqHz: freqHz,
                loadCellRaw: loadCellRaw,
                instantForce: instantForce,
                peakForce: peakForce,
                positionAngle: positionAngle,
                direction: direction,
                compressionCount: compressionCount,
                compressionDepth: compressionDepth,
                motorTemp: motorTemp,
                recoilOk: recoilOk,
                anomalyFlag: anomalyFlag,
                gpsFix: gpsFix,
                latitude: latitude,
                longitude: longitude,
                satellites: satellites,
                speedKmh: speedKmh,
                altitudeM: altitudeM,
                gpsUtc: gpsUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TelemetrySamplesTable, TelemetrySample>(table),
                  $$TelemetrySamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$TelemetrySamplesTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$TelemetrySamplesTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TelemetrySamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TelemetrySamplesTable,
      TelemetrySample,
      $$TelemetrySamplesTableFilterComposer,
      $$TelemetrySamplesTableOrderingComposer,
      $$TelemetrySamplesTableAnnotationComposer,
      $$TelemetrySamplesTableCreateCompanionBuilder,
      $$TelemetrySamplesTableUpdateCompanionBuilder,
      (TelemetrySample, $$TelemetrySamplesTableReferences),
      TelemetrySample,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$TelemetryLogsTableCreateCompanionBuilder =
    TelemetryLogsCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      required String name,
      required String timeLabel,
      required String sizeLabel,
      required String status,
      required bool isDerate,
      required String category,
      required String source,
      required String preview,
      required String fullJson,
      Value<DateTime> createdAt,
    });
typedef $$TelemetryLogsTableUpdateCompanionBuilder =
    TelemetryLogsCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      Value<String> name,
      Value<String> timeLabel,
      Value<String> sizeLabel,
      Value<String> status,
      Value<bool> isDerate,
      Value<String> category,
      Value<String> source,
      Value<String> preview,
      Value<String> fullJson,
      Value<DateTime> createdAt,
    });

final class $$TelemetryLogsTableReferences
    extends BaseReferences<_$AppDatabase, $TelemetryLogsTable, TelemetryLog> {
  $$TelemetryLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TelemetrySessionsTable _sessionIdTable(_$AppDatabase db) => db
      .telemetrySessions
      .createAlias('telemetry_logs__session_id__telemetry_sessions__id');

  $$TelemetrySessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<int>('session_id');
    if ($_column == null) return null;
    final manager = $$TelemetrySessionsTableTableManager(
      $_db,
      $_db.telemetrySessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TelemetryLogsTableFilterComposer
    extends Composer<_$AppDatabase, $TelemetryLogsTable> {
  $$TelemetryLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeLabel => $composableBuilder(
    column: $table.timeLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sizeLabel => $composableBuilder(
    column: $table.sizeLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDerate => $composableBuilder(
    column: $table.isDerate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preview => $composableBuilder(
    column: $table.preview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullJson => $composableBuilder(
    column: $table.fullJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TelemetrySessionsTableFilterComposer get sessionId {
    final $$TelemetrySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.telemetrySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TelemetrySessionsTableFilterComposer(
            $db: $db,
            $table: $db.telemetrySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TelemetryLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $TelemetryLogsTable> {
  $$TelemetryLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeLabel => $composableBuilder(
    column: $table.timeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sizeLabel => $composableBuilder(
    column: $table.sizeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDerate => $composableBuilder(
    column: $table.isDerate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preview => $composableBuilder(
    column: $table.preview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullJson => $composableBuilder(
    column: $table.fullJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TelemetrySessionsTableOrderingComposer get sessionId {
    final $$TelemetrySessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.telemetrySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TelemetrySessionsTableOrderingComposer(
            $db: $db,
            $table: $db.telemetrySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TelemetryLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TelemetryLogsTable> {
  $$TelemetryLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get timeLabel =>
      $composableBuilder(column: $table.timeLabel, builder: (column) => column);

  GeneratedColumn<String> get sizeLabel =>
      $composableBuilder(column: $table.sizeLabel, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isDerate =>
      $composableBuilder(column: $table.isDerate, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get preview =>
      $composableBuilder(column: $table.preview, builder: (column) => column);

  GeneratedColumn<String> get fullJson =>
      $composableBuilder(column: $table.fullJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TelemetrySessionsTableAnnotationComposer get sessionId {
    final $$TelemetrySessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.telemetrySessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TelemetrySessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.telemetrySessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TelemetryLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TelemetryLogsTable,
          TelemetryLog,
          $$TelemetryLogsTableFilterComposer,
          $$TelemetryLogsTableOrderingComposer,
          $$TelemetryLogsTableAnnotationComposer,
          $$TelemetryLogsTableCreateCompanionBuilder,
          $$TelemetryLogsTableUpdateCompanionBuilder,
          (TelemetryLog, $$TelemetryLogsTableReferences),
          TelemetryLog,
          PrefetchHooks Function({bool sessionId})
        > {
  $$TelemetryLogsTableTableManager(_$AppDatabase db, $TelemetryLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TelemetryLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TelemetryLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TelemetryLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> timeLabel = const Value.absent(),
                Value<String> sizeLabel = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isDerate = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> preview = const Value.absent(),
                Value<String> fullJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TelemetryLogsCompanion(
                id: id,
                sessionId: sessionId,
                name: name,
                timeLabel: timeLabel,
                sizeLabel: sizeLabel,
                status: status,
                isDerate: isDerate,
                category: category,
                source: source,
                preview: preview,
                fullJson: fullJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                required String name,
                required String timeLabel,
                required String sizeLabel,
                required String status,
                required bool isDerate,
                required String category,
                required String source,
                required String preview,
                required String fullJson,
                Value<DateTime> createdAt = const Value.absent(),
              }) => TelemetryLogsCompanion.insert(
                id: id,
                sessionId: sessionId,
                name: name,
                timeLabel: timeLabel,
                sizeLabel: sizeLabel,
                status: status,
                isDerate: isDerate,
                category: category,
                source: source,
                preview: preview,
                fullJson: fullJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TelemetryLogsTable, TelemetryLog>(table),
                  $$TelemetryLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$TelemetryLogsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$TelemetryLogsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TelemetryLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TelemetryLogsTable,
      TelemetryLog,
      $$TelemetryLogsTableFilterComposer,
      $$TelemetryLogsTableOrderingComposer,
      $$TelemetryLogsTableAnnotationComposer,
      $$TelemetryLogsTableCreateCompanionBuilder,
      $$TelemetryLogsTableUpdateCompanionBuilder,
      (TelemetryLog, $$TelemetryLogsTableReferences),
      TelemetryLog,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TelemetrySessionsTableTableManager get telemetrySessions =>
      $$TelemetrySessionsTableTableManager(_db, _db.telemetrySessions);
  $$TelemetrySamplesTableTableManager get telemetrySamples =>
      $$TelemetrySamplesTableTableManager(_db, _db.telemetrySamples);
  $$TelemetryLogsTableTableManager get telemetryLogs =>
      $$TelemetryLogsTableTableManager(_db, _db.telemetryLogs);
}
