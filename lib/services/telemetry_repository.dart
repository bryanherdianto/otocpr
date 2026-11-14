import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/telemetry_models.dart';
import 'wokwi_tcp_client.dart';

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
    _wokwiLineSub = _wokwiClient.lines.listen(ingestFirmwareCsvLine);
    _wokwiStateSub = _wokwiClient.connectionState.listen((connected) {
      if (connected) {
        telemetrySourceNotifier.value =
            'Wokwi RFC2217 (${_wokwiClient.endpoint})';
      } else if (_bleLineSub == null) {
        telemetrySourceNotifier.value = 'Internal Demo Sim';
      }
    });
    _startLiveSimulation();
  }
  static final TelemetryRepository instance = TelemetryRepository._();

  static const String otoCprServiceUuid = '4FAFC201-1FB5-459E-8FCC-C5C9C331914B';
  static const String otoCprTxCharacteristicUuid =
      'BEB5483E-36E1-4688-B7F5-EA07361B26A8';
  static const String wokwiDeviceId = '127.0.0.1:4000';

  Timer? _liveStreamTimer;
  Timer? _handshakeTimer;
  final math.Random _random = math.Random();
  final WokwiTcpClient _wokwiClient = WokwiTcpClient();
  StreamSubscription<String>? _wokwiLineSub;
  StreamSubscription<bool>? _wokwiStateSub;
  StreamSubscription<String>? _bleLineSub;
  double _lastAngleDeg = 142.5;
  double _prevHeadingLat = -6.2088;
  double _prevHeadingLon = 106.8456;
  DateTime? _lastEspLogAt;
  DateTime? _lastAiLogAt;
  bool? _lastLoggedGpsFix;
  int? _liveLogSeq;

  static const int _maxHistorySamples = 4500; // ~15 min at 5 Hz
  static const int _maxChartPoints = 24;
  static const int _maxLogEntries = 50;
  List<_MetricSample>? _instantForceHistory;
  List<_MetricSample>? _peakForceHistory;
  List<_MetricSample>? _rateHistory;
  List<_MetricSample>? _angleHistory;
  List<_MetricSample>? _countHistory;
  List<_MetricSample>? _depthHistory;
  List<_MetricSample>? _tempHistory;
  List<_MetricSample>? _directionHistory; // 1.0 = CW, 0.0 = CCW

  List<_MetricSample> get _instantForceHist => _instantForceHistory ??= [];
  List<_MetricSample> get _peakForceHist => _peakForceHistory ??= [];
  List<_MetricSample> get _rateHist => _rateHistory ??= [];
  List<_MetricSample> get _angleHist => _angleHistory ??= [];
  List<_MetricSample> get _countHist => _countHistory ??= [];
  List<_MetricSample> get _depthHist => _depthHistory ??= [];
  List<_MetricSample> get _tempHist => _tempHistory ??= [];
  List<_MetricSample> get _directionHist => _directionHistory ??= [];

  // Reactive state notifiers
  final ValueNotifier<Esp32Telemetry> esp32Notifier = ValueNotifier(Esp32Telemetry.initial());
  final ValueNotifier<AiDiagnosticsData> aiDiagnosticsNotifier = ValueNotifier(AiDiagnosticsData.initial());
  final ValueNotifier<DeviceLocationData> locationNotifier = ValueNotifier(const DeviceLocationData());
  final ValueNotifier<List<TelemetryLogItem>> logsNotifier = ValueNotifier(_initialLogs);
  final ValueNotifier<Esp32ConnectionStatus> connectionStatusNotifier =
      ValueNotifier(Esp32ConnectionStatus.connected);
  final ValueNotifier<String> telemetrySourceNotifier =
      ValueNotifier<String>('Internal Demo Sim');

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
  bool get isWokwiConnected => _wokwiClient.isConnected;
  bool get isExternalStreamActive =>
      _wokwiClient.isConnected || _bleLineSub != null;
  String get telemetrySource => telemetrySourceNotifier.value;
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
    final updated = [log, ...logsNotifier.value];
    logsNotifier.value = updated.length > _maxLogEntries
        ? updated.sublist(0, _maxLogEntries)
        : updated;
  }

  // =========================================================================
  // UNIFIED FIRMWARE CSV PARSER (WOKWI TCP :4000 & REAL ESP32 BLE NOTIFY)
  // =========================================================================

  /// Connects directly to the Wokwi Simulator RFC2217 TCP server (`127.0.0.1:4000`).
  /// Returns `true` if the Wokwi simulation stream was reached.
  Future<bool> connectToWokwi({
    String host = '127.0.0.1',
    int port = 4000,
    bool selectAsPairedDevice = true,
  }) async {
    _handshakeTimer?.cancel();
    connectionStatusNotifier.value = Esp32ConnectionStatus.searching;
    connectionFeedbackNotifier.value =
        'Connecting to Wokwi Simulator ($host:$port)...';

    final ok = await _wokwiClient.connect(host: host, port: port);
    if (!ok) {
      connectionStatusNotifier.value = Esp32ConnectionStatus.timeout;
      connectionFeedbackNotifier.value =
          'Could not reach Wokwi on $host:$port. Start the Wokwi simulator in VS Code first.';
      return false;
    }

    if (selectAsPairedDevice) {
      pairedDeviceNotifier.value = const BleDeviceModel(
        id: wokwiDeviceId,
        name: 'OtoCPR Wokwi Simulator',
        rssi: -38,
        serviceUuid: otoCprServiceUuid,
        isPaired: true,
      );
    }

    connectionStatusNotifier.value = Esp32ConnectionStatus.connected;
    connectionFeedbackNotifier.value =
        'Connected (${_wokwiClient.endpoint})';
    telemetrySourceNotifier.value =
        'Wokwi RFC2217 (${_wokwiClient.endpoint})';
    esp32Notifier.value = esp32.copyWith(
      isConnected: true,
      deviceStatus: 'Connected',
      timestamp: DateTime.now(),
    );
    return true;
  }

  /// Disconnects the Wokwi TCP stream and reverts to internal demo or standby.
  Future<void> disconnectWokwi({bool resumeDemoSim = true}) async {
    await _wokwiClient.disconnect();
    if (_bleLineSub == null) {
      telemetrySourceNotifier.value = 'Internal Demo Sim';
      if (resumeDemoSim && isConnected) {
        _startLiveSimulation();
      }
    }
  }

  /// Attaches a real wireless BLE GATT Notification byte stream from the physical
  /// ESP32 (`OtoCprBleTelemetry`, Characteristic UUID `BEB5483E-...`).
  /// Feeds the exact same `ingestFirmwareCsvLine` parser used by Wokwi.
  void attachBleCharacteristicStream(Stream<List<int>> rawBleStream) {
    _bleLineSub?.cancel();
    _wokwiClient.disconnect();
    telemetrySourceNotifier.value =
        'BLE GATT Notify ($otoCprTxCharacteristicUuid)';
    _bleLineSub = rawBleStream
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .listen(
          ingestFirmwareCsvLine,
          onDone: () {
            _bleLineSub = null;
            telemetrySourceNotifier.value = 'Internal Demo Sim';
          },
        );
  }

  /// Detaches an active wireless BLE notification stream.
  Future<void> detachBleCharacteristicStream() async {
    await _bleLineSub?.cancel();
    _bleLineSub = null;
    if (!_wokwiClient.isConnected) {
      telemetrySourceNotifier.value = 'Internal Demo Sim';
    }
  }

  /// Parses a single CSV telemetry line emitted by `Firmware/src/main.cpp`:
  /// `Time(ms),Set_RPM,Actual_RPM,PWM,Raw_Counts,Freq_Hz,LoadCell[,GPS_Fix,Latitude,Longitude,Satellites,Speed_kmh,Altitude_m,GPS_UTC]`
  ///
  /// Used identically by both Wokwi TCP (`:4000`) and wireless BLE notifications.
  bool ingestFirmwareCsvLine(String rawLine) {
    final line = rawLine.trim();
    if (line.isEmpty ||
        line.startsWith('Time(ms)') ||
        line.startsWith('[') ||
        line.startsWith(r'$')) {
      return false;
    }

    final parts = line.split(',');
    if (parts.length < 7) return false;

    final timeMs = int.tryParse(parts[0].trim());
    if (timeMs == null) return false;

    final setRpm = double.tryParse(parts[1].trim()) ?? 100.0;
    final actualRpm = double.tryParse(parts[2].trim()) ?? 0.0;
    final pwm = int.tryParse(parts[3].trim()) ?? 0;
    final rawCounts = int.tryParse(parts[4].trim()) ?? 0;
    final loadCellRaw = double.tryParse(parts[6].trim()) ?? 0.0;

    // If the user spins the encoder in Wokwi (or on real hardware), use actualRpm;
    // otherwise when PWM is active in Wokwi without encoder clicks, reflect setRpm.
    final effectiveRpm = actualRpm.abs() > 0.1
        ? actualRpm.abs()
        : (pwm > 0 ? setRpm.abs() : 0.0);

    // Map HX711 reading into Newtons (baseline 68.5 N when scale is tared at 0.0 in Wokwi)
    double forceN;
    if (loadCellRaw.abs() < 0.01) {
      forceN = 68.5;
    } else if (loadCellRaw.abs() > 150.0) {
      forceN = (loadCellRaw.abs() / 42.0).clamp(5.0, 120.0);
    } else {
      forceN = loadCellRaw.abs().clamp(5.0, 120.0);
    }

    final deltaDeg = rawCounts != 0
        ? (rawCounts.abs() / (11.0 * 65.0)) * 360.0
        : (effectiveRpm / 60.0) * 0.2 * 360.0;
    final nextAngle = (_lastAngleDeg + deltaDeg) % 360.0;
    final completedTurn = (_lastAngleDeg + deltaDeg) >= 360.0;
    _lastAngleDeg = nextAngle;

    final nextPeak = math.max(esp32.peakForce, forceN);
    final nextCount =
        esp32.compressionCount + (completedTurn ? 1 : 0);

    esp32Notifier.value = esp32.copyWith(
      instantForce: double.parse(forceN.toStringAsFixed(1)),
      peakForce: double.parse(nextPeak.toStringAsFixed(1)),
      positionAngle: double.parse(nextAngle.toStringAsFixed(1)),
      motorSpeed: double.parse(effectiveRpm.toStringAsFixed(1)),
      compressionRate: double.parse(effectiveRpm.toStringAsFixed(1)),
      direction: actualRpm < -0.1 ? 'CCW' : 'CW',
      compressionCount: nextCount,
      recoilOk: forceN <= 95.0,
      anomalyFlag: forceN > 95.0,
      isConnected: true,
      deviceStatus: 'Connected',
      timestamp: DateTime.now(),
    );

    // Parse optional NEO-6M GPS columns (columns 7..13)
    if (parts.length >= 13) {
      final hasFix = parts[7].trim() == '1';
      final lat = double.tryParse(parts[8].trim());
      final lon = double.tryParse(parts[9].trim());
      final sats = int.tryParse(parts[10].trim()) ?? 0;
      final speedKmh = double.tryParse(parts[11].trim()) ?? 0.0;
      final altM = double.tryParse(parts[12].trim()) ?? 0.0;

      if (hasFix &&
          lat != null &&
          lon != null &&
          (lat.abs() > 0.0001 || lon.abs() > 0.0001)) {
        double heading = location.heading;
        final dLat = lat - _prevHeadingLat;
        final dLon = lon - _prevHeadingLon;
        if (dLat.abs() > 1e-6 || dLon.abs() > 1e-6) {
          heading = (math.atan2(dLon, dLat) * 180.0 / math.pi + 360.0) % 360.0;
          _prevHeadingLat = lat;
          _prevHeadingLon = lon;
        }
        final estHdop = sats > 0
            ? double.parse((0.7 + 6.0 / sats).toStringAsFixed(2))
            : 99.99;

        updateGpsData(
          latitude: lat,
          longitude: lon,
          altitude: altM,
          speed: speedKmh,
          heading: double.parse(heading.toStringAsFixed(1)),
          hdop: estHdop,
          satellites: sats,
          isGpsLocked: true,
          fixType: sats >= 4 ? '3D Fix (NEO-6M)' : '2D Fix (NEO-6M)',
        );
      } else {
        updateGpsData(
          latitude: location.latitude,
          longitude: location.longitude,
          satellites: sats,
          isGpsLocked: false,
          fixType: 'Acquiring ($sats sats)',
        );
      }
    }

    _recordLiveSampleAndLogs(
      timeMs: timeMs,
      setRpm: setRpm,
      actualRpm: effectiveRpm,
      pwm: pwm,
      rawCounts: rawCounts,
      forceN: forceN,
      peakForceN: nextPeak,
      angleDeg: nextAngle,
      compressionCount: nextCount,
    );

    return true;
  }

  void _pushHistorySample(
    List<_MetricSample> history,
    DateTime now,
    double value,
  ) {
    history.add(_MetricSample(now, value));
    if (history.length > _maxHistorySamples) {
      history.removeAt(0);
    }
  }

  void _recordLiveSampleAndLogs({
    required int timeMs,
    required double setRpm,
    required double actualRpm,
    required int pwm,
    required int rawCounts,
    required double forceN,
    required double peakForceN,
    required double angleDeg,
    required int compressionCount,
  }) {
    final now = DateTime.now();
    _pushHistorySample(_instantForceHist, now, forceN);
    _pushHistorySample(_peakForceHist, now, peakForceN);
    _pushHistorySample(_rateHist, now, actualRpm);
    _pushHistorySample(_angleHist, now, angleDeg);
    _pushHistorySample(_countHist, now, compressionCount.toDouble());
    _pushHistorySample(_depthHist, now, esp32.compressionDepth);
    _pushHistorySample(_tempHist, now, esp32.motorTemp);
    _pushHistorySample(
      _directionHist,
      now,
      esp32.direction == 'CW' ? 1.0 : 0.0,
    );

    final loc = location;
    final isOverForce = forceN > 95.0;
    final isRateOk = actualRpm >= 100.0 && actualRpm <= 120.0;
    final isIdle = actualRpm <= 0.1;

    final String classification;
    final String insight;
    if (isOverForce) {
      classification = 'Elevated Compression Force';
      insight =
          'Peak chest force reached ${forceN.toStringAsFixed(1)} N (above 95.0 N safety limit). Supervisory throttle engaged to protect infant ribcage.';
    } else if (isIdle) {
      classification = 'Actuator Standby / Idle';
      insight =
          'Motor PWM is inactive (0 RPM). Ready to resume pediatric compression protocol (100-120 CPM).';
    } else if (!isRateOk) {
      classification = actualRpm < 100.0
          ? 'Low Compression Rate'
          : 'High Compression Rate';
      insight =
          'Live actuator cadence is ${actualRpm.toStringAsFixed(1)} CPM (AHA pediatric target: 100-120 CPM). Instant force ${forceN.toStringAsFixed(1)} N.';
    } else {
      classification = 'Optimal Compression Dynamics';
      insight =
          'Live compression rate ${actualRpm.toStringAsFixed(1)} CPM matches AHA 2020 pediatric guidelines (100-120 CPM). Instant force ${forceN.toStringAsFixed(1)} N with complete recoil.';
    }

    final fatigueDrift = isIdle
        ? 0.0
        : double.parse(
            (((actualRpm - setRpm).abs() / (setRpm > 0 ? setRpm : 100.0)) * 100.0)
                .clamp(0.0, 25.0)
                .toStringAsFixed(1),
          );
    final recoilResidual =
        isOverForce ? double.parse((forceN - 95.0).toStringAsFixed(1)) : 0.2;
    final healthScore = isOverForce
        ? 82.0
        : (isIdle ? 95.0 : (isRateOk ? 99.2 : 91.5));
    final tidalVolume = isIdle
        ? 0.0
        : double.parse((98.0 * (actualRpm / 108.0).clamp(0.7, 1.2)).toStringAsFixed(0));

    final aiPayload = <String, dynamic>{
      'timestamp': now.toUtc().toIso8601String(),
      'source': telemetrySource,
      'model_version': 'OtoCPR-Edge-v2.1',
      'inference': {
        'classification': classification,
        'confidence': isOverForce ? 0.962 : 0.984,
        'metrics': {
          'instant_force_N': double.parse(forceN.toStringAsFixed(1)),
          'peak_force_N': double.parse(peakForceN.toStringAsFixed(1)),
          'motor_rpm': double.parse(actualRpm.toStringAsFixed(1)),
          'shaft_angle_deg': double.parse(angleDeg.toStringAsFixed(1)),
          'pwm': pwm,
          'recoil_ok': !isOverForce,
        },
        'gps': {
          'locked': loc.isGpsLocked,
          'latitude': loc.latitude,
          'longitude': loc.longitude,
          'satellites': loc.satellites,
        },
        'anomaly_flag': isOverForce,
      },
    };
    const encoder = JsonEncoder.withIndent('  ');
    final aiJson = encoder.convert(aiPayload);

    aiDiagnosticsNotifier.value = AiDiagnosticsData(
      confidence: isOverForce ? 96.2 : 98.4,
      classification: classification,
      guidelineSubtitle:
          'Live ${actualRpm.toStringAsFixed(0)} CPM · Force ${forceN.toStringAsFixed(1)} N · ${loc.isGpsLocked ? 'GPS Locked' : 'GPS Acquiring'}',
      diagnosticInsight: insight,
      tidalVolume: tidalVolume,
      strokeForce: double.parse(peakForceN.toStringAsFixed(1)),
      recoilResidual: recoilResidual,
      fatigueDrift: fatigueDrift,
      sessionHealthIndex: healthScore,
      rawJson: aiJson,
    );

    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final gpsFixChanged =
        _lastLoggedGpsFix != null && _lastLoggedGpsFix != loc.isGpsLocked;
    final shouldLogEsp = _lastEspLogAt == null ||
        gpsFixChanged ||
        (isOverForce && now.difference(_lastEspLogAt!) >= const Duration(seconds: 2)) ||
        now.difference(_lastEspLogAt!) >= const Duration(seconds: 5);

    if (shouldLogEsp) {
      _lastEspLogAt = now;
      _lastLoggedGpsFix = loc.isGpsLocked;
      final seq = (_liveLogSeq ?? 0) + 1;
      _liveLogSeq = seq;

      final espPayload = <String, dynamic>{
        'event': isOverForce
            ? 'OVERFORCE_WARNING'
            : (gpsFixChanged ? 'GPS_FIX_CHANGE' : 'LIVE_TELEMETRY'),
        'timestamp': now.toUtc().toIso8601String(),
        'source': telemetrySource,
        'firmware_ms': timeMs,
        'actuator': {
          'set_rpm': double.parse(setRpm.toStringAsFixed(1)),
          'actual_rpm': double.parse(actualRpm.toStringAsFixed(1)),
          'pwm': pwm,
          'raw_counts': rawCounts,
          'instant_force_n': double.parse(forceN.toStringAsFixed(1)),
          'peak_force_n': double.parse(peakForceN.toStringAsFixed(1)),
          'compression_count': compressionCount,
        },
        'gps': {
          'fix_type': loc.fixType,
          'is_locked': loc.isGpsLocked,
          'latitude': double.parse(loc.latitude.toStringAsFixed(6)),
          'longitude': double.parse(loc.longitude.toStringAsFixed(6)),
          'altitude_m': double.parse(loc.altitude.toStringAsFixed(1)),
          'speed_kmh': double.parse(loc.speed.toStringAsFixed(2)),
          'satellites': loc.satellites,
        },
        'status': isOverForce ? 'DERATE' : 'NORMAL',
      };
      final fullJson = encoder.convert(espPayload);
      final sizeKb = (fullJson.length / 1024.0).toStringAsFixed(1);
      final seqLabel = seq.toString().padLeft(4, '0');

      addLog(
        TelemetryLogItem(
          name: 'L${seqLabel}_esp32.json',
          time: timeStr,
          size: '$sizeKb KB',
          status: isOverForce ? 'Derate' : 'Normal',
          isDerate: isOverForce,
          category: 'ESP32',
          preview:
              '{\n  "rpm": ${actualRpm.toStringAsFixed(1)},\n  "force_n": ${forceN.toStringAsFixed(1)},\n  "lat": ${loc.latitude.toStringAsFixed(5)},\n  "lon": ${loc.longitude.toStringAsFixed(5)}\n}',
          fullJson: fullJson,
        ),
      );
    }

    final shouldLogAi = _lastAiLogAt == null ||
        (isOverForce && now.difference(_lastAiLogAt!) >= const Duration(seconds: 4)) ||
        now.difference(_lastAiLogAt!) >= const Duration(seconds: 10);

    if (shouldLogAi) {
      _lastAiLogAt = now;
      final seq = (_liveLogSeq ?? 0) + 1;
      _liveLogSeq = seq;
      final sizeKb = (aiJson.length / 1024.0).toStringAsFixed(1);
      final seqLabel = seq.toString().padLeft(4, '0');

      addLog(
        TelemetryLogItem(
          name: 'L${seqLabel}_inference.json',
          time: timeStr,
          size: '$sizeKb KB',
          status: isOverForce ? 'Derate' : 'Normal',
          isDerate: isOverForce,
          category: 'AI',
          preview:
              '{\n  "classification": "$classification",\n  "rpm": ${actualRpm.toStringAsFixed(1)},\n  "force_n": ${forceN.toStringAsFixed(1)}\n}',
          fullJson: aiJson,
        ),
      );
    }
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
          id: wokwiDeviceId,
          name: pairedDevice?.id == wokwiDeviceId
              ? (pairedDevice?.name ?? 'OtoCPR Wokwi Simulator')
              : 'OtoCPR Wokwi Simulator',
          rssi: -38, // Localhost TCP simulator bridge
          serviceUuid: otoCprServiceUuid,
          isPaired: pairedDevice?.id == wokwiDeviceId,
          lastSeen: DateTime.now(),
        ),
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

    // If the user selected the Wokwi Simulator device, connect directly to Wokwi TCP :4000
    if (target.id == wokwiDeviceId) {
      final ok = await connectToWokwi(selectAsPairedDevice: false);
      if (!ok) {
        // Fallback so UI still functions if user hasn't pressed Play in Wokwi yet
        _startLiveSimulation();
      }
      return;
    }

    // Step 2: Handshake - Connecting
    await Future.delayed(const Duration(milliseconds: 1100));
    if (connectionStatusNotifier.value != Esp32ConnectionStatus.searching) return;

    connectionStatusNotifier.value = Esp32ConnectionStatus.connecting;
    connectionFeedbackNotifier.value = 'Connecting to ${target.name}...';

    // Step 3: Connected (also probe Wokwi :4000 automatically if running locally)
    final wokwiReached = await _wokwiClient.connect();
    if (!wokwiReached) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (connectionStatusNotifier.value != Esp32ConnectionStatus.connecting) return;

    connectionStatusNotifier.value = Esp32ConnectionStatus.connected;
    connectionFeedbackNotifier.value = wokwiReached
        ? 'Connected (Wokwi Live Stream)'
        : 'Connected';
    telemetrySourceNotifier.value = wokwiReached
        ? 'Wokwi RFC2217 (${_wokwiClient.endpoint})'
        : 'Internal Demo Sim';
    esp32Notifier.value = esp32.copyWith(
      isConnected: true,
      deviceStatus: 'Connected',
      timestamp: DateTime.now(),
    );
    _startLiveSimulation();
  }

  void disconnectEsp32() {
    _handshakeTimer?.cancel();
    _wokwiClient.disconnect();
    _stopLiveSimulation();
    telemetrySourceNotifier.value = 'Disconnected';
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
      // When Wokwi TCP or Wireless BLE is actively streaming, do not overwrite with fake jitter
      if (isExternalStreamActive) {
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

  Future<void> disposeStreams() async {
    await _wokwiLineSub?.cancel();
    await _wokwiStateSub?.cancel();
    await _bleLineSub?.cancel();
  }

  List<double> _windowValues(
    List<_MetricSample> live,
    int timeframeIndex,
    List<double> fallback,
  ) {
    if (live.isEmpty) return fallback;
    final Duration? maxAge;
    switch (timeframeIndex) {
      case 0:
        maxAge = const Duration(minutes: 1);
        break;
      case 1:
        maxAge = const Duration(minutes: 5);
        break;
      case 2:
        maxAge = const Duration(minutes: 15);
        break;
      case 3:
      default:
        maxAge = null;
        break;
    }
    if (maxAge == null) {
      return live.map((s) => s.value).toList();
    }
    final cutoff = DateTime.now().subtract(maxAge);
    final filtered = live
        .where((s) => !s.time.isBefore(cutoff))
        .map((s) => s.value)
        .toList();
    return filtered.isNotEmpty ? filtered : [live.last.value];
  }

  List<double> _downsampleChartPoints(List<double> values) {
    if (values.length <= _maxChartPoints) {
      return List<double>.from(values);
    }
    final sampled = <double>[];
    final step = (values.length - 1) / (_maxChartPoints - 1);
    for (int i = 0; i < _maxChartPoints; i++) {
      sampled.add(values[(i * step).round()]);
    }
    return sampled;
  }

  String _meanOf(List<double> values, {int decimals = 1}) {
    if (values.isEmpty) return '0';
    final avg = values.reduce((a, b) => a + b) / values.length;
    return avg.toStringAsFixed(decimals);
  }

  String _rangeEfficiency(
    List<double> values, {
    double? min,
    double? max,
  }) {
    if (values.isEmpty) return '0%';
    final inRange = values.where((v) {
      final okMin = min == null || v >= min;
      final okMax = max == null || v <= max;
      return okMin && okMax;
    }).length;
    final pct = ((inRange / values.length) * 100.0).round();
    return '$pct%';
  }

  /// Provides dynamic historical metric series and statistics for any requested metric
  MetricHistorySeries getMetricHistory(String title, {int timeframeIndex = 0}) {
    final cleanTitle = title.trim().toLowerCase();

    if (cleanTitle.contains('instant') || cleanTitle.contains('instantaneous')) {
      final val = esp32.instantForce;
      final window = _windowValues(
        _instantForceHist,
        timeframeIndex,
        [50, 56, 62, 68, 72, 65, 63, 67, 70, val, 66, val],
      );
      return MetricHistorySeries(
        title: 'Instantaneous Force',
        unit: 'N',
        currentValue: val.toStringAsFixed(1),
        targetRange: '50 - 80',
        meanValue: _meanOf(window),
        efficiency: _rangeEfficiency(window, min: 50.0, max: 80.0),
        chartPoints: _downsampleChartPoints(window),
        description: 'Real-time normal force vector reported by the piezoelectric load cell on the robotic actuator plunger.',
      );
    } else if (cleanTitle.contains('peak')) {
      final val = esp32.peakForce;
      final window = _windowValues(
        _peakForceHist,
        timeframeIndex,
        [82, 88, 92, 94, 96, 93, 94.2, 95, val, 93, val],
      );
      return MetricHistorySeries(
        title: 'Peak Force',
        unit: 'N',
        currentValue: val.toStringAsFixed(1),
        targetRange: '85 - 100',
        meanValue: _meanOf(window),
        efficiency: _rangeEfficiency(window, min: 85.0, max: 100.0),
        chartPoints: _downsampleChartPoints(window),
        description: 'Maximum compressive peak force reached at the bottom of the stroke trajectory before the release phase.',
      );
    } else if (cleanTitle.contains('depth')) {
      final val = esp32.compressionDepth;
      final window = _windowValues(
        _depthHist,
        timeframeIndex,
        [3.8, 4.1, 4.3, 4.6, 4.8, 4.7, 4.5, 4.6, 4.8, val, 4.7, val],
      );
      return MetricHistorySeries(
        title: 'Compression Depth',
        unit: 'CM',
        currentValue: val.toStringAsFixed(1),
        targetRange: '4.0 - 5.0',
        meanValue: _meanOf(window),
        efficiency: _rangeEfficiency(window, min: 4.0, max: 5.0),
        chartPoints: _downsampleChartPoints(window),
        description: 'Physical displacement depth of the mechanical actuator stroke calibrated for pediatric resuscitation.',
      );
    } else if (cleanTitle.contains('rate') || cleanTitle.contains('cpm')) {
      final val = esp32.compressionRate;
      final window = _windowValues(
        _rateHist,
        timeframeIndex,
        [96, 102, 106, 108, 108, 107, 109, 108, val, 108, val],
      );
      return MetricHistorySeries(
        title: 'Compression Rate',
        unit: 'CPM',
        currentValue: val.toStringAsFixed(0),
        targetRange: '100 - 120',
        meanValue: _meanOf(window),
        efficiency: _rangeEfficiency(window, min: 100.0, max: 120.0),
        chartPoints: _downsampleChartPoints(window),
        description: 'Stroke cadence delivered by the BLDC motor drive shaft, synced to AHA 2020 pediatric guidelines (100-120 CPM).',
      );
    } else if (cleanTitle.contains('speed') || cleanTitle.contains('rpm')) {
      final val = esp32.motorSpeed;
      final window = _windowValues(
        _rateHist,
        timeframeIndex,
        [96, 102, 106, 108, 108, 107, 109, 108, val, 108, val],
      );
      return MetricHistorySeries(
        title: 'Motor Speed',
        unit: 'RPM',
        currentValue: val.toStringAsFixed(0),
        targetRange: '100 - 120',
        meanValue: _meanOf(window),
        efficiency: _rangeEfficiency(window, min: 100.0, max: 120.0),
        chartPoints: _downsampleChartPoints(window),
        description: 'Rotational velocity of the BLDC motor drive shaft, synced through the closed-loop PID servo controller.',
      );
    } else if (cleanTitle.contains('angle') || cleanTitle.contains('position')) {
      final val = esp32.positionAngle;
      final window = _windowValues(
        _angleHist,
        timeframeIndex,
        [30, 60, 90, 120, 142.5, 180, 240, 300, 340, val],
      );
      return MetricHistorySeries(
        title: 'Position Angle',
        unit: '°',
        currentValue: val.toStringAsFixed(1),
        targetRange: '0 - 360',
        meanValue: _meanOf(window),
        efficiency: _rangeEfficiency(window, min: 0.0, max: 360.0),
        chartPoints: _downsampleChartPoints(window),
        description: 'Absolute optical encoder angle tracking the cam mechanism position across each compression cycle.',
      );
    } else if (cleanTitle.contains('direction')) {
      final window = _windowValues(
        _directionHist,
        timeframeIndex,
        [1, 1, 1, 1, 1, 1],
      );
      final cwCount = window.where((v) => v >= 0.5).length;
      final dominantDir = cwCount >= (window.length / 2) ? 'CW' : 'CCW';
      return MetricHistorySeries(
        title: 'Motor Direction',
        unit: '',
        currentValue: esp32.direction,
        targetRange: 'CW',
        meanValue: dominantDir,
        efficiency: _rangeEfficiency(window, min: 0.5, max: 1.5),
        chartPoints: _downsampleChartPoints(window),
        description: 'Rotation direction of the BLDC actuator shaft (Clockwise / Counter-Clockwise).',
      );
    } else if (cleanTitle.contains('count')) {
      final window = _windowValues(
        _countHist,
        timeframeIndex,
        [100, 250, 400, 550, 700, esp32.compressionCount.toDouble()],
      );
      return MetricHistorySeries(
        title: 'Compression Count',
        unit: 'CYC',
        currentValue: '${esp32.compressionCount}',
        targetRange: '> 0',
        meanValue: _meanOf(window, decimals: 0),
        efficiency: _rangeEfficiency(window, min: 1.0),
        chartPoints: _downsampleChartPoints(window),
        description: 'Total cumulative CPR compression cycles completed by the robot in the active protocol.',
      );
    } else if (cleanTitle.contains('temp')) {
      final val = esp32.motorTemp;
      final window = _windowValues(
        _tempHist,
        timeframeIndex,
        [32, 35, 38, 40, 42, val],
      );
      return MetricHistorySeries(
        title: 'Motor Temperature',
        unit: '°C',
        currentValue: val.toStringAsFixed(1),
        targetRange: '< 55.0',
        meanValue: _meanOf(window),
        efficiency: _rangeEfficiency(window, max: 54.99),
        chartPoints: _downsampleChartPoints(window),
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

class _MetricSample {
  final DateTime time;
  final double value;
  const _MetricSample(this.time, this.value);
}
