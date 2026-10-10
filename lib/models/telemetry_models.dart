/// Telemetry Data Models for OtoCPR
/// Representing real-time sensor streams from the ESP32 Hub and Actuator,
/// integrated GPS module telemetry, Edge AI diagnostics, and machine logs.
library;

class Esp32Telemetry {
  final double instantForce; // N
  final double peakForce; // N
  final double positionAngle; // Degrees (0-360)
  final double motorSpeed; // RPM
  final String direction; // 'CW' or 'CCW'
  final int compressionCount; // CYC
  final double compressionDepth; // CM
  final double compressionRate; // CPM
  final double motorTemp; // °C
  final double batteryPct; // %
  final bool recoilOk; // Recoil status
  final bool isConnected;
  final String deviceStatus; // 'Connected', 'Standby', 'Fault'
  final bool anomalyFlag;
  final DateTime timestamp;

  const Esp32Telemetry({
    this.instantForce = 68.5,
    this.peakForce = 94.2,
    this.positionAngle = 142.5,
    this.motorSpeed = 108.0,
    this.direction = 'CW',
    this.compressionCount = 842,
    this.compressionDepth = 4.7,
    this.compressionRate = 108.0,
    this.motorTemp = 42.5,
    this.batteryPct = 96.0,
    this.recoilOk = true,
    this.isConnected = true,
    this.deviceStatus = 'Connected',
    this.anomalyFlag = false,
    required this.timestamp,
  });

  factory Esp32Telemetry.initial() {
    return Esp32Telemetry(timestamp: DateTime.now());
  }

  Esp32Telemetry copyWith({
    double? instantForce,
    double? peakForce,
    double? positionAngle,
    double? motorSpeed,
    String? direction,
    int? compressionCount,
    double? compressionDepth,
    double? compressionRate,
    double? motorTemp,
    double? batteryPct,
    bool? recoilOk,
    bool? isConnected,
    String? deviceStatus,
    bool? anomalyFlag,
    DateTime? timestamp,
  }) {
    return Esp32Telemetry(
      instantForce: instantForce ?? this.instantForce,
      peakForce: peakForce ?? this.peakForce,
      positionAngle: positionAngle ?? this.positionAngle,
      motorSpeed: motorSpeed ?? this.motorSpeed,
      direction: direction ?? this.direction,
      compressionCount: compressionCount ?? this.compressionCount,
      compressionDepth: compressionDepth ?? this.compressionDepth,
      compressionRate: compressionRate ?? this.compressionRate,
      motorTemp: motorTemp ?? this.motorTemp,
      batteryPct: batteryPct ?? this.batteryPct,
      recoilOk: recoilOk ?? this.recoilOk,
      isConnected: isConnected ?? this.isConnected,
      deviceStatus: deviceStatus ?? this.deviceStatus,
      anomalyFlag: anomalyFlag ?? this.anomalyFlag,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'instant_force': instantForce,
        'peak_force': peakForce,
        'position_angle': positionAngle,
        'motor_speed': motorSpeed,
        'direction': direction,
        'compression_count': compressionCount,
        'compression_depth': compressionDepth,
        'compression_rate': compressionRate,
        'motor_temp': motorTemp,
        'battery_pct': batteryPct,
        'recoil_ok': recoilOk,
        'is_connected': isConnected,
        'device_status': deviceStatus,
        'anomaly_flag': anomalyFlag,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Esp32Telemetry.fromJson(Map<String, dynamic> json) {
    return Esp32Telemetry(
      instantForce: (json['instant_force'] as num?)?.toDouble() ?? 0.0,
      peakForce: (json['peak_force'] as num?)?.toDouble() ?? 0.0,
      positionAngle: (json['position_angle'] as num?)?.toDouble() ?? 0.0,
      motorSpeed: (json['motor_speed'] as num?)?.toDouble() ?? 0.0,
      direction: json['direction'] as String? ?? 'CW',
      compressionCount: json['compression_count'] as int? ?? 0,
      compressionDepth: (json['compression_depth'] as num?)?.toDouble() ?? 4.7,
      compressionRate: (json['compression_rate'] as num?)?.toDouble() ?? 108.0,
      motorTemp: (json['motor_temp'] as num?)?.toDouble() ?? 42.5,
      batteryPct: (json['battery_pct'] as num?)?.toDouble() ?? 96.0,
      recoilOk: json['recoil_ok'] as bool? ?? true,
      isConnected: json['is_connected'] as bool? ?? true,
      deviceStatus: json['device_status'] as String? ?? 'Connected',
      anomalyFlag: json['anomaly_flag'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

class AiDiagnosticsData {
  final double confidence; // e.g. 98.4
  final String classification;
  final String guidelineSubtitle;
  final String diagnosticInsight;
  final double tidalVolume; // ML
  final double strokeForce; // N
  final double recoilResidual; // N
  final double fatigueDrift; // %
  final double sessionHealthIndex; // %
  final String rawJson;

  const AiDiagnosticsData({
    this.confidence = 98.4,
    this.classification = 'Optimal Compression Dynamics',
    this.guidelineSubtitle = 'Pediatric rhythm & recoil thresholds verified',
    this.diagnosticInsight =
        'Current chest depression rate matches pediatric guideline AHA 2020 (100-120 CPM). Recoil pressure remains below the 0.5N residual resistance ceiling, maximizing coronary perfusion and avoiding barotrauma.',
    this.tidalVolume = 98.0,
    this.strokeForce = 94.2,
    this.recoilResidual = 0.2,
    this.fatigueDrift = 1.2,
    this.sessionHealthIndex = 99.2,
    required this.rawJson,
  });

  factory AiDiagnosticsData.initial() {
    return const AiDiagnosticsData(
      rawJson: '''{
  "timestamp": "2026-09-25T12:36:14Z",
  "device_id": "ESP32-C3-CARRIER-01",
  "model_version": "OtoCPR-Edge-v2.1",
  "inference": {
    "classification": "Optimal Compression Dynamics",
    "confidence": 0.984,
    "metrics": {
      "instant_force_N": 68.5,
      "peak_force_N": 94.2,
      "motor_rpm": 108.0,
      "shaft_angle_deg": 142.5,
      "ventilation_ml": 98.0,
      "recoil_ok": true
    },
    "anomaly_flag": false
  }
}''',
    );
  }

  AiDiagnosticsData copyWith({
    double? confidence,
    String? classification,
    String? guidelineSubtitle,
    String? diagnosticInsight,
    double? tidalVolume,
    double? strokeForce,
    double? recoilResidual,
    double? fatigueDrift,
    double? sessionHealthIndex,
    String? rawJson,
  }) {
    return AiDiagnosticsData(
      confidence: confidence ?? this.confidence,
      classification: classification ?? this.classification,
      guidelineSubtitle: guidelineSubtitle ?? this.guidelineSubtitle,
      diagnosticInsight: diagnosticInsight ?? this.diagnosticInsight,
      tidalVolume: tidalVolume ?? this.tidalVolume,
      strokeForce: strokeForce ?? this.strokeForce,
      recoilResidual: recoilResidual ?? this.recoilResidual,
      fatigueDrift: fatigueDrift ?? this.fatigueDrift,
      sessionHealthIndex: sessionHealthIndex ?? this.sessionHealthIndex,
      rawJson: rawJson ?? this.rawJson,
    );
  }
}

class DeviceLocationData {
  final double latitude;
  final double longitude;
  final double altitude; // meters above sea level
  final double speed; // km/h
  final double heading; // degrees (0-360)
  final double hdop; // Horizontal Dilution of Precision
  final int satellites; // number of locked satellites
  final bool isGpsLocked; // true if fix acquired
  final String fixType; // '3D Fix', '2D Fix', 'No Fix'
  final String locationLabel;
  final DateTime? lastFixTime;

  const DeviceLocationData({
    this.latitude = -6.2088,
    this.longitude = 106.8456,
    this.altitude = 14.2,
    this.speed = 0.4,
    this.heading = 182.5,
    this.hdop = 1.1,
    this.satellites = 9,
    this.isGpsLocked = true,
    this.fixType = '3D Fix',
    this.locationLabel = 'Jakarta, Indonesia',
    this.lastFixTime,
  });

  DeviceLocationData copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? hdop,
    int? satellites,
    bool? isGpsLocked,
    String? fixType,
    String? locationLabel,
    DateTime? lastFixTime,
  }) {
    return DeviceLocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      hdop: hdop ?? this.hdop,
      satellites: satellites ?? this.satellites,
      isGpsLocked: isGpsLocked ?? this.isGpsLocked,
      fixType: fixType ?? this.fixType,
      locationLabel: locationLabel ?? this.locationLabel,
      lastFixTime: lastFixTime ?? this.lastFixTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'speed': speed,
        'heading': heading,
        'hdop': hdop,
        'satellites': satellites,
        'is_gps_locked': isGpsLocked,
        'fix_type': fixType,
        'location_label': locationLabel,
        'last_fix_time': lastFixTime?.toIso8601String(),
      };

  factory DeviceLocationData.fromJson(Map<String, dynamic> json) {
    return DeviceLocationData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? -6.2088,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 106.8456,
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      hdop: (json['hdop'] as num?)?.toDouble() ?? 99.9,
      satellites: json['satellites'] as int? ?? 0,
      isGpsLocked: json['is_gps_locked'] as bool? ?? false,
      fixType: json['fix_type'] as String? ?? 'No Fix',
      locationLabel: json['location_label'] as String? ?? 'Unknown',
      lastFixTime: json['last_fix_time'] != null
          ? DateTime.parse(json['last_fix_time'] as String)
          : null,
    );
  }
}

class TelemetryLogItem {
  final String name;
  final String time;
  final String size;
  final String status;
  final bool isDerate;
  final String category; // 'ESP32', 'AI'
  final String preview;
  final String fullJson;

  const TelemetryLogItem({
    required this.name,
    required this.time,
    required this.size,
    required this.status,
    required this.isDerate,
    required this.category,
    required this.preview,
    required this.fullJson,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'time': time,
        'size': size,
        'status': status,
        'isDerate': isDerate,
        'category': category,
        'preview': preview,
        'fullJson': fullJson,
      };

  factory TelemetryLogItem.fromMap(Map<String, dynamic> map) {
    return TelemetryLogItem(
      name: map['name'] as String,
      time: map['time'] as String,
      size: map['size'] as String,
      status: map['status'] as String,
      isDerate: map['isDerate'] as bool,
      category: map['category'] as String? ?? 'ESP32',
      preview: map['preview'] as String,
      fullJson: map['fullJson'] as String? ?? map['preview'] as String,
    );
  }
}

class MetricHistorySeries {
  final String title;
  final String unit;
  final String currentValue;
  final String targetRange;
  final String meanValue;
  final String efficiency;
  final List<double> chartPoints;
  final String description;

  const MetricHistorySeries({
    required this.title,
    required this.unit,
    required this.currentValue,
    required this.targetRange,
    required this.meanValue,
    required this.efficiency,
    required this.chartPoints,
    required this.description,
  });
}

/// Discovered / Paired Bluetooth Low Energy peripheral model
class BleDeviceModel {
  final String id; // MAC on Android / UUID on iOS
  final String name; // User-friendly label (e.g., "OtoCPR-Unit #01")
  final int rssi; // Signal strength in dBm (for proximity sorting)
  final String serviceUuid; // Hardware advertised Service UUID
  final bool isPaired;
  final DateTime? lastSeen;

  const BleDeviceModel({
    required this.id,
    required this.name,
    required this.rssi,
    required this.serviceUuid,
    this.isPaired = false,
    this.lastSeen,
  });

  BleDeviceModel copyWith({
    String? id,
    String? name,
    int? rssi,
    String? serviceUuid,
    bool? isPaired,
    DateTime? lastSeen,
  }) {
    return BleDeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      serviceUuid: serviceUuid ?? this.serviceUuid,
      isPaired: isPaired ?? this.isPaired,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

