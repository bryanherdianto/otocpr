import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/telemetry_models.dart';

/// Connection status states for the ESP32 carrier hub adhering to standard IoT recommendations
enum Esp32ConnectionStatus {
  disconnected,
  searching, // Phase 2: Handshake step 1 ("Searching for [Device]...")
  connecting, // Phase 2: Handshake step 2 ("Connecting...")
  connected, // Phase 2: Active ("Connected")
  timeout, // Safety Fallback: 5-10s timeout ("Could not find [Device]. Make sure it is powered on.")
}

/// Central Telemetry Repository for OtoCPR.
/// Acts as the single source of truth for ESP32 hardware telemetry,
/// GPS navigation module data, Edge AI diagnostics, and machine logs.
///
/// Implements the standard hybrid two-phase BLE flow:
/// - Phase 1: Guided Discovery (Filtered by Service UUID, Proximity RSSI sorting, Friendly labels, QR/NFC bypass)
/// - Phase 2: Daily Use (1-Tap direct reconnect to cached peripheral, transparent state handshake)
/// - Safety Fallback: 5-10s scan timeout with clear warning & [Scan for New Device] CTA
class TelemetryRepository {
  TelemetryRepository._() {
    _startLiveSimulation();
  }
  static final TelemetryRepository instance = TelemetryRepository._();

  static const String otoCprServiceUuid = '4FAFC201-1FB5-459E-8FCC-C5C9C331914B';

  Timer? _liveStreamTimer;
  Timer? _handshakeTimer;
  final math.Random _random = math.Random();

  // Reactive state notifiers
  final ValueNotifier<Esp32Telemetry> esp32Notifier = ValueNotifier(Esp32Telemetry.initial());
  final ValueNotifier<AiDiagnosticsData> aiDiagnosticsNotifier = ValueNotifier(AiDiagnosticsData.initial());
  final ValueNotifier<DeviceLocationData> locationNotifier = ValueNotifier(const DeviceLocationData());
  final ValueNotifier<List<TelemetryLogItem>> logsNotifier = ValueNotifier(_initialLogs);
  final ValueNotifier<Esp32ConnectionStatus> connectionStatusNotifier =
      ValueNotifier(Esp32ConnectionStatus.connected);

  // BLE Two-Phase State Notifiers
  final ValueNotifier<BleDeviceModel?> pairedDeviceNotifier = ValueNotifier<BleDeviceModel?>(
    const BleDeviceModel(
      id: '24:DC:C3:A8:14:02',
      name: 'OtoCPR Unit 01',
      rssi: -54,
      serviceUuid: otoCprServiceUuid,
      isPaired: true,
    ),
  );
  final ValueNotifier<List<BleDeviceModel>> discoveredDevicesNotifier =
      ValueNotifier<List<BleDeviceModel>>([]);
  final ValueNotifier<bool> isScanningDiscoveryNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> connectionFeedbackNotifier = ValueNotifier<String>('Connected');

  // Convenient Getters for snapshot values
  Esp32Telemetry get esp32 => esp32Notifier.value;
  AiDiagnosticsData get aiDiagnostics => aiDiagnosticsNotifier.value;
  DeviceLocationData get location => locationNotifier.value;
  List<TelemetryLogItem> get logs => logsNotifier.value;
  Esp32ConnectionStatus get connectionStatus => connectionStatusNotifier.value;
  bool get isConnected => connectionStatus == Esp32ConnectionStatus.connected;
  BleDeviceModel? get pairedDevice => pairedDeviceNotifier.value;

  // Mutation / Integration hooks
  void updateEsp32(Esp32Telemetry data) {
    esp32Notifier.value = data;
  }

  void updateAiDiagnostics(AiDiagnosticsData data) {
    aiDiagnosticsNotifier.value = data;
  }

  void updateLocation(DeviceLocationData data) {
    locationNotifier.value = data;
  }

  /// Hook for ESP32 GPS Module (NMEA parsing / UART telemetry injection)
  void updateGpsData({
    required double latitude,
    required double longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? hdop,
    int? satellites,
    bool? isGpsLocked,
    String? fixType,
    String? locationLabel,
  }) {
    locationNotifier.value = location.copyWith(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      speed: speed,
      heading: heading,
      hdop: hdop,
      satellites: satellites,
      isGpsLocked: isGpsLocked,
      fixType: fixType,
      locationLabel: locationLabel,
      lastFixTime: DateTime.now(),
    );
  }

  void addLog(TelemetryLogItem log) {
    logsNotifier.value = [log, ...logsNotifier.value];
  }

  // =========================================================================
  // PHASE 1: FIRST-TIME SETUP (GUIDED DISCOVERY & FILTERED PICKER)
  // =========================================================================

  /// Starts filtered discovery scan.
  /// Strictly filters by hardware Service UUID (hides ambient headphones/trackers),
  /// and sorts candidate devices by Proximity (RSSI descending).
  void startDiscoveryScan() {
    isScanningDiscoveryNotifier.value = true;
    discoveredDevicesNotifier.value = [];

    // Simulate progressive discovery with Proximity (RSSI) sorting
    Timer(const Duration(milliseconds: 600), () {
      if (!isScanningDiscoveryNotifier.value) return;

      final candidates = [
        BleDeviceModel(
          id: '24:DC:C3:A8:14:02',
          name: pairedDevice?.id == '24:DC:C3:A8:14:02'
              ? (pairedDevice?.name ?? 'OtoCPR Unit 01')
              : 'OtoCPR Unit 01',
          rssi: -52, // Strongest signal (closest to phone)
          serviceUuid: otoCprServiceUuid,
          isPaired: pairedDevice?.id == '24:DC:C3:A8:14:02',
          lastSeen: DateTime.now(),
        ),
        const BleDeviceModel(
          id: '24:DC:C3:A8:92:1B',
          name: 'OtoCPR Unit 04',
          rssi: -68,
          serviceUuid: otoCprServiceUuid,
          lastSeen: null,
        ),
        const BleDeviceModel(
          id: '24:DC:C3:A8:FF:41',
          name: 'OtoCPR Unit 09',
          rssi: -84,
          serviceUuid: otoCprServiceUuid,
          lastSeen: null,
        ),
      ];

      // Proximity Sorting (RSSI): Highest dBm (closest) sits at top
      candidates.sort((a, b) => b.rssi.compareTo(a.rssi));
      discoveredDevicesNotifier.value = candidates;
    });
  }

  void stopDiscoveryScan() {
    isScanningDiscoveryNotifier.value = false;
  }

  /// Pairs and caches the chosen peripheral identifier (Phase 1 completion -> Phase 2 connection)
  Future<void> pairAndConnect(BleDeviceModel device) async {
    stopDiscoveryScan();
    pairedDeviceNotifier.value = device.copyWith(isPaired: true);
    await oneTapReconnect();
  }

  /// Zero-Friction Pairing Alternative: QR Code or NFC Tag payload bypass
  Future<void> pairViaQrOrNfc({String unitLabel = 'OtoCPR Unit 01 (NFC Tag)'}) async {
    stopDiscoveryScan();
    const qrDevice = BleDeviceModel(
      id: '24:DC:C3:A8:14:02',
      name: 'OtoCPR Unit 01',
      rssi: -45, // Immediate zero-distance tap
      serviceUuid: otoCprServiceUuid,
      isPaired: true,
    );
    pairedDeviceNotifier.value = qrDevice;
    await oneTapReconnect();
  }

  /// Rename paired device to friendly label
  void renamePairedDevice(String newName) {
    if (pairedDevice != null && newName.trim().isNotEmpty) {
      pairedDeviceNotifier.value = pairedDevice!.copyWith(name: newName.trim());
    }
  }

  /// Clear paired device cache
  void unpairDevice() {
    disconnectEsp32();
    pairedDeviceNotifier.value = null;
  }

  // =========================================================================
  // PHASE 2: DAILY USE (1-TAP RECONNECTION & TRANSPARENT HANDSHAKE)
  // WITH ESSENTIAL SAFETY FALLBACK (5-10s TIMEOUT)
  // =========================================================================

  /// 1-Tap Reconnection directly targeting cached peripheral identifier
  /// [simulateHardwareOff]: Optional flag to demonstrate safety fallback timeout
  Future<void> oneTapReconnect({bool simulateHardwareOff = false}) async {
    final target = pairedDevice;
    if (target == null) {
      // If no device is saved, launch Phase 1 discovery
      startDiscoveryScan();
      return;
    }

    _handshakeTimer?.cancel();

    // Step 1: Searching for target cached identifier
    connectionStatusNotifier.value = Esp32ConnectionStatus.searching;
    connectionFeedbackNotifier.value = 'Searching for ${target.name}...';

    if (simulateHardwareOff) {
      // Essential Safety Fallback: 6-second timeout if hardware is off / uncharged
      _handshakeTimer = Timer(const Duration(seconds: 6), () {
        connectionStatusNotifier.value = Esp32ConnectionStatus.timeout;
        connectionFeedbackNotifier.value =
            'Could not find ${target.name}. Make sure it is powered on.';
      });
      return;
    }

    // Step 2: Handshake - Connecting
    await Future.delayed(const Duration(milliseconds: 1100));
    if (connectionStatusNotifier.value != Esp32ConnectionStatus.searching) return;

    connectionStatusNotifier.value = Esp32ConnectionStatus.connecting;
    connectionFeedbackNotifier.value = 'Connecting to ${target.name}...';

    // Step 3: Connected
    await Future.delayed(const Duration(milliseconds: 900));
    if (connectionStatusNotifier.value != Esp32ConnectionStatus.connecting) return;

    connectionStatusNotifier.value = Esp32ConnectionStatus.connected;
    connectionFeedbackNotifier.value = 'Connected';
    esp32Notifier.value = esp32.copyWith(
      isConnected: true,
      deviceStatus: 'Connected',
      timestamp: DateTime.now(),
    );
    _startLiveSimulation();
  }

  void disconnectEsp32() {
    _handshakeTimer?.cancel();
    _stopLiveSimulation();
    connectionStatusNotifier.value = Esp32ConnectionStatus.disconnected;
    connectionFeedbackNotifier.value = 'Disconnected';
    esp32Notifier.value = esp32.copyWith(
      isConnected: false,
      deviceStatus: 'Standby',
      instantForce: 0.0,
      timestamp: DateTime.now(),
    );
  }

  Future<void> toggleConnection() async {
    if (isConnected) {
      disconnectEsp32();
    } else {
      await oneTapReconnect();
    }
  }

  void _startLiveSimulation() {
    _liveStreamTimer?.cancel();
    _liveStreamTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!isConnected) {
        timer.cancel();
        return;
      }

      // Small realistic live perturbations representing 500Hz sensor telemetry
      final forceJitter = (_random.nextDouble() * 4.0) - 2.0; // +/- 2N
      final newInstantForce = (68.5 + forceJitter).clamp(55.0, 78.0);
      final newAngle = (esp32.positionAngle + 24.0) % 360.0;
      final newCount = esp32.compressionCount + 1;
      final speedJitter = (_random.nextDouble() * 2.0) - 1.0;
      final newSpeed = (108.0 + speedJitter).clamp(100.0, 115.0);

      esp32Notifier.value = esp32.copyWith(
        instantForce: double.parse(newInstantForce.toStringAsFixed(1)),
        positionAngle: double.parse(newAngle.toStringAsFixed(1)),
        motorSpeed: double.parse(newSpeed.toStringAsFixed(1)),
        compressionCount: newCount,
        timestamp: DateTime.now(),
      );

      // Micro GPS drift to simulate active GPS satellite reception
      if (_random.nextInt(3) == 0) {
        final latDrift = (_random.nextDouble() - 0.5) * 0.00004;
        final lngDrift = (_random.nextDouble() - 0.5) * 0.00004;
        locationNotifier.value = location.copyWith(
          latitude: location.latitude + latDrift,
          longitude: location.longitude + lngDrift,
          lastFixTime: DateTime.now(),
        );
      }
    });
  }

  void _stopLiveSimulation() {
    _liveStreamTimer?.cancel();
    _liveStreamTimer = null;
  }

  /// Provides dynamic historical metric series and statistics for any requested metric
  MetricHistorySeries getMetricHistory(String title, {int timeframeIndex = 0}) {
    final cleanTitle = title.trim().toLowerCase();

    if (cleanTitle.contains('instant') || cleanTitle.contains('instantaneous')) {
      final val = esp32.instantForce;
      return MetricHistorySeries(
        title: 'Instantaneous Force',
        unit: 'N',
        currentValue: val.toStringAsFixed(1),
        targetRange: '50 - 80',
        meanValue: '64.8',
        efficiency: '95%',
        chartPoints: [50, 56, 62, 68, 72, 65, 63, 67, 70, val, 66, val],
        description: 'Real-time normal force vector reported by the piezoelectric load cell on the robotic actuator plunger.',
      );
    } else if (cleanTitle.contains('peak')) {
      final val = esp32.peakForce;
      return MetricHistorySeries(
        title: 'Peak Force',
        unit: 'N',
        currentValue: val.toStringAsFixed(1),
        targetRange: '85 - 100',
        meanValue: '93.1',
        efficiency: '98%',
        chartPoints: [82, 88, 92, 94, 96, 93, 94.2, 95, val, 93, val],
        description: 'Maximum compressive peak force reached at the bottom of the stroke trajectory before the release phase.',
      );
    } else if (cleanTitle.contains('depth')) {
      final val = esp32.compressionDepth;
      return MetricHistorySeries(
        title: 'Compression Depth',
        unit: 'CM',
        currentValue: val.toStringAsFixed(1),
        targetRange: '4.0 - 5.0',
        meanValue: '4.7',
        efficiency: '98%',
        chartPoints: [3.8, 4.1, 4.3, 4.6, 4.8, 4.7, 4.5, 4.6, 4.8, val, 4.7, val],
        description: 'Physical displacement depth of the mechanical actuator stroke calibrated for pediatric resuscitation.',
      );
    } else if (cleanTitle.contains('rate') || cleanTitle.contains('cpm')) {
      final val = esp32.compressionRate;
      return MetricHistorySeries(
        title: 'Compression Rate',
        unit: 'CPM',
        currentValue: val.toStringAsFixed(0),
        targetRange: '100 - 120',
        meanValue: '108.0',
        efficiency: '96%',
        chartPoints: [96, 102, 106, 108, 108, 107, 109, 108, val, 108, val],
        description: 'Stroke cadence delivered by the BLDC motor drive shaft, synced to AHA 2020 pediatric guidelines (100-120 CPM).',
      );
    } else if (cleanTitle.contains('speed') || cleanTitle.contains('rpm')) {
      final val = esp32.motorSpeed;
      return MetricHistorySeries(
        title: 'Motor Speed',
        unit: 'RPM',
        currentValue: val.toStringAsFixed(0),
        targetRange: '100 - 120',
        meanValue: '108.0',
        efficiency: '97%',
        chartPoints: [96, 102, 106, 108, 108, 107, 109, 108, val, 108, val],
        description: 'Rotational velocity of the BLDC motor drive shaft, synced through the closed-loop PID servo controller.',
      );
    } else if (cleanTitle.contains('angle') || cleanTitle.contains('position')) {
      final val = esp32.positionAngle;
      return MetricHistorySeries(
        title: 'Position Angle',
        unit: '°',
        currentValue: val.toStringAsFixed(1),
        targetRange: '0 - 360',
        meanValue: '180.0',
        efficiency: '99%',
        chartPoints: [30, 60, 90, 120, 142.5, 180, 240, 300, 340, val],
        description: 'Absolute optical encoder angle tracking the cam mechanism position across each compression cycle.',
      );
    } else if (cleanTitle.contains('direction')) {
      return MetricHistorySeries(
        title: 'Motor Direction',
        unit: '',
        currentValue: esp32.direction,
        targetRange: 'CW',
        meanValue: 'CW',
        efficiency: '100%',
        chartPoints: [1, 1, 1, 1, 1, 1],
        description: 'Rotation direction of the BLDC actuator shaft (Clockwise / Counter-Clockwise).',
      );
    } else if (cleanTitle.contains('count')) {
      return MetricHistorySeries(
        title: 'Compression Count',
        unit: 'CYC',
        currentValue: '${esp32.compressionCount}',
        targetRange: '> 0',
        meanValue: '${esp32.compressionCount}',
        efficiency: '100%',
        chartPoints: [100, 250, 400, 550, 700, esp32.compressionCount.toDouble()],
        description: 'Total cumulative CPR compression cycles completed by the robot in the active protocol.',
      );
    } else if (cleanTitle.contains('temp')) {
      final val = esp32.motorTemp;
      return MetricHistorySeries(
        title: 'Motor Temperature',
        unit: '°C',
        currentValue: val.toStringAsFixed(1),
        targetRange: '< 55.0',
        meanValue: '41.8',
        efficiency: '94%',
        chartPoints: [32, 35, 38, 40, 42, val],
        description: 'Thermal probe reading at the BLDC motor stator core. Monitored for automated derate protection.',
      );
    } else {
      return MetricHistorySeries(
        title: title,
        unit: '',
        currentValue: '98',
        targetRange: '80 - 110',
        meanValue: '94.2',
        efficiency: '96%',
        chartPoints: [45, 60, 75, 90, 98, 88, 70, 95, 105, 98, 85, 92, 100, 96, 98],
        description: 'Detailed telemetry metric telemetry stream for $title.',
      );
    }
  }

  static final List<TelemetryLogItem> _initialLogs = [
    const TelemetryLogItem(
      name: 'W043_supervisor.json',
      time: '12:36:34',
      size: '1.1 KB',
      status: 'Derate',
      isDerate: true,
      category: 'ESP32',
      preview: '{\n  "event": "MOTOR_THERMAL_DERATE",\n  "temp_c": 54.2,\n  "action": "THROTTLE_RPM_TO_100",\n  "status": "SAFE"\n}',
      fullJson: '''{
  "event": "MOTOR_THERMAL_DERATE",
  "timestamp": "2026-09-25T12:36:34.120Z",
  "device_id": "ESP32-C3-SUPERVISOR-01",
  "subsystem": "ACTUATOR_DRIVE",
  "temperature": {
    "motor_coil_c": 54.2,
    "driver_mosfet_c": 49.8,
    "ambient_c": 28.1,
    "derate_threshold_c": 52.0
  },
  "action": {
    "throttle_rpm_to": 100,
    "pwm_duty_cycle_pct": 74.5,
    "recovery_strategy": "ACTIVE_COOLING_MONITOR",
    "status": "SAFE"
  },
  "diagnostics": {
    "operating_hours": 142.8,
    "fault_code": "WARN_TEMP_T1",
    "fail_safe_engaged": false
  }
}''',
    ),
    const TelemetryLogItem(
      name: 'W041_inference.json',
      time: '12:36:14',
      size: '2.3 KB',
      status: 'Normal',
      isDerate: false,
      category: 'AI',
      preview: '{\n  "event": "NOMINAL_CYCLE",\n  "depth_cm": 4.7,\n  "force_n": 94.2,\n  "compression_rate": 108,\n  "recoil": "COMPLETE"\n}',
      fullJson: '''{
  "event": "NOMINAL_CYCLE",
  "timestamp": "2026-09-25T12:36:14.882Z",
  "model": "OtoCPR-Edge-v2.1",
  "inference_id": "INF-20260925-041",
  "compression": {
    "depth_cm": 4.7,
    "depth_target_cm": [4.0, 5.0],
    "force_n": 94.2,
    "instant_force_n": 68.5,
    "compression_rate_cpm": 108,
    "target_rate_cpm": [100, 120],
    "recoil": "COMPLETE",
    "recoil_residual_n": 0.2
  },
  "quality_score": {
    "overall": 98.4,
    "depth_accuracy": 0.991,
    "rate_accuracy": 0.980,
    "recoil_accuracy": 0.982
  },
  "status": "NORMAL"
}''',
    ),
    const TelemetryLogItem(
      name: 'W040_supervisor.json',
      time: '12:35:54',
      size: '1.1 KB',
      status: 'Derate',
      isDerate: true,
      category: 'ESP32',
      preview: '{\n  "event": "OVERFORCE_WARNING",\n  "load_peak_n": 98.6,\n  "threshold_n": 95.0,\n  "recoil_adjustment": -2.0\n}',
      fullJson: '''{
  "event": "OVERFORCE_WARNING",
  "timestamp": "2026-09-25T12:35:54.015Z",
  "device_id": "ESP32-C3-SUPERVISOR-01",
  "subsystem": "LOAD_CELL_ARRAY",
  "force_telemetry": {
    "load_peak_n": 98.6,
    "threshold_n": 95.0,
    "differential_n": 3.6,
    "sample_rate_hz": 500
  },
  "mitigation": {
    "recoil_adjustment": -2.0,
    "stroke_limit_mm": 48.5,
    "auto_trim_applied": true
  },
  "safety_interlock": {
    "state": "ENGAGED_ADAPTIVE",
    "override_active": false
  }
}''',
    ),
    const TelemetryLogItem(
      name: 'W039_gps_telemetry.json',
      time: '12:35:34',
      size: '1.4 KB',
      status: 'Normal',
      isDerate: false,
      category: 'ESP32',
      preview: '{\n  "event": "GPS_NMEA_FIX",\n  "fix_type": "3D_FIX",\n  "satellites": 9,\n  "hdop": 1.1\n}',
      fullJson: '''{
  "event": "GPS_NMEA_FIX",
  "timestamp": "2026-09-25T12:35:34.450Z",
  "device_id": "ESP32-C3-CARRIER-01",
  "subsystem": "NEO6M_GPS_UART",
  "navigation": {
    "fix_type": "3D_FIX",
    "is_locked": true,
    "latitude": -6.20882,
    "longitude": 106.84561,
    "altitude_m": 14.2,
    "speed_kmh": 0.4,
    "heading_deg": 182.5,
    "satellites_tracked": 9,
    "hdop": 1.15
  },
  "status": "NORMAL"
}''',
    ),
    const TelemetryLogItem(
      name: 'W038_supervisor.json',
      time: '12:35:14',
      size: '1.1 KB',
      status: 'Derate',
      isDerate: true,
      category: 'ESP32',
      preview: '{\n  "event": "SHAFT_ENCODER_SYNC",\n  "jitter_us": 12,\n  "calibrated": true\n}',
      fullJson: '''{
  "event": "SHAFT_ENCODER_SYNC",
  "timestamp": "2026-09-25T12:35:14.200Z",
  "device_id": "ESP32-C3-SUPERVISOR-01",
  "subsystem": "OPTICAL_ENCODER",
  "encoder_metrics": {
    "jitter_us": 12,
    "quadrature_pulses_per_rev": 2048,
    "zero_index_offset_deg": 1.42,
    "calibrated": true
  },
  "motor_alignment": {
    "sync_lock": true,
    "phase_drift_deg": 0.04
  }
}''',
    ),
    const TelemetryLogItem(
      name: 'W037_inference.json',
      time: '12:34:54',
      size: '2.3 KB',
      status: 'Normal',
      isDerate: false,
      category: 'AI',
      preview: '{\n  "event": "CYCLE_START",\n  "protocol": "PEDIATRIC_AHA_2020",\n  "target_cpm": 110\n}',
      fullJson: '''{
  "event": "CYCLE_START",
  "protocol": "PEDIATRIC_AHA_2020",
  "timestamp": "2026-09-25T12:34:54.000Z",
  "session_id": "SESS-PEDS-2026-0037",
  "firmware": "OtoCPR-v2.1.4-Release",
  "parameters": {
    "target_cpm": 110,
    "target_cpm_min": 100,
    "target_cpm_max": 120,
    "target_depth_cm": 4.5,
    "recoil_threshold_n": 0.5,
    "duty_cycle_pct": 50,
    "ratio": "15:2",
    "patient_type": "PEDIATRIC_INFANT"
  },
  "preflight_status": {
    "actuator_calibrated": true,
    "load_cell_zeroed": true,
    "thermal_headroom_c": 31.8,
    "ble_rssi_dbm": -48,
    "battery_soc_pct": 94
  },
  "safety_limits": {
    "max_depth_cm": 5.0,
    "max_force_n": 100.0,
    "thermal_cutoff_c": 65.0
  }
}''',
    ),
  ];
}
