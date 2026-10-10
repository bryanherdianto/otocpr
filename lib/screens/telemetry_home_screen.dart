import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/device_location_map.dart';
import '../widgets/glass_container.dart';
import '../models/telemetry_models.dart';
import '../services/telemetry_repository.dart';

class TelemetryHomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToTelemetry;
  final VoidCallback? onNavigateToLogs;

  const TelemetryHomeScreen({
    super.key,
    this.onNavigateToTelemetry,
    this.onNavigateToLogs,
  });

  @override
  State<TelemetryHomeScreen> createState() => _TelemetryHomeScreenState();
}

class _TelemetryHomeScreenState extends State<TelemetryHomeScreen> {
  bool _isInteractingWithMap = false;

  void _showDiagnosticsSheet(BuildContext context) {
    final repo = TelemetryRepository.instance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.88,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10121C).withValues(alpha: 0.75),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        blurRadius: 24,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Sheet Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Engineering Diagnostics',
                                  style: AppTypography.sans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Hardware telemetry & RF specs',
                                  style: AppTypography.sans(
                                    fontSize: 12,
                                    color: AppColors.gray,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              icon: const Icon(Icons.close_rounded, color: AppColors.gray, size: 20),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: Color(0xFF1E2430), height: 16),

                      // Diagnostics Content List
                      Expanded(
                        child: ListenableBuilder(
                          listenable: Listenable.merge([
                            repo.esp32Notifier,
                            repo.locationNotifier,
                            repo.connectionStatusNotifier,
                          ]),
                          builder: (context, _) {
                            final esp = repo.esp32;
                            final loc = repo.location;
                            final isConnected = repo.isConnected;

                            return ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                              children: [
                                // Section: Controller Electronics
                                _buildDiagSectionHeader('CONTROLLER & BLE HARDWARE'),
                                _buildDiagTile(
                                  label: 'Carrier Board',
                                  value: 'ESP32-C3 RISC-V Actuator Hub',
                                ),
                                _buildDiagTile(
                                  label: 'Firmware Version',
                                  value: 'v2.1.4-Release (Build 2026-09)',
                                ),
                                _buildDiagTile(
                                  label: 'BLE MAC Address',
                                  value: '24:DC:C3:A8:14:02',
                                  isMonospace: true,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.cyan),
                                    onPressed: () {
                                      Clipboard.setData(const ClipboardData(text: '24:DC:C3:A8:14:02'));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('MAC address copied to clipboard'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                                _buildDiagTile(
                                  label: 'RF Signal Strength',
                                  value: isConnected ? '-58 dBm (RSSI)' : 'Offline',
                                  isMonospace: true,
                                ),
                                _buildDiagTile(
                                  label: 'Sensor Sample Rate',
                                  value: isConnected ? '500 Hz (Load Cell / Encoder)' : '0 Hz (Standby)',
                                ),

                                const SizedBox(height: 20),

                                // Section: GNSS Navigation Receiver
                                _buildDiagSectionHeader('GNSS / GPS RECEIVER'),
                                _buildDiagTile(
                                  label: 'Fix Classification',
                                  value: loc.fixType,
                                  valueColor: loc.isGpsLocked ? AppColors.cyan : AppColors.red,
                                ),
                                _buildDiagTile(
                                  label: 'Satellites Tracked',
                                  value: '${loc.satellites} Satellites',
                                  isMonospace: true,
                                ),
                                _buildDiagTile(
                                  label: 'HDOP Precision',
                                  value: '${loc.hdop.toStringAsFixed(2)} (Target < 2.0)',
                                  isMonospace: true,
                                ),
                                _buildDiagTile(
                                  label: 'Raw Coordinates',
                                  value: 'Lat ${loc.latitude.toStringAsFixed(6)}°, Lon ${loc.longitude.toStringAsFixed(6)}°',
                                  isMonospace: true,
                                ),
                                _buildDiagTile(
                                  label: 'Altitude / Velocity',
                                  value: '${loc.altitude.toStringAsFixed(1)} m AMSL · ${loc.speed.toStringAsFixed(1)} km/h',
                                ),

                                const SizedBox(height: 20),

                                // Section: Safety & Thermal Monitor
                                _buildDiagSectionHeader('SUPERVISOR & SAFETY MONITOR'),
                                _buildDiagTile(
                                  label: 'Anomaly Flag',
                                  value: esp.anomalyFlag ? 'FLAGGED (Interlock Active)' : 'Nominal (Zero Faults)',
                                  valueColor: esp.anomalyFlag ? AppColors.red : AppColors.cyan,
                                ),
                                _buildDiagTile(
                                  label: 'Actuator Stator Temp',
                                  value: '${esp.motorTemp.toStringAsFixed(1)} °C (Threshold: 55.0 °C)',
                                ),
                                _buildDiagTile(
                                  label: 'Cumulative Compressions',
                                  value: '${esp.compressionCount} Cycles',
                                  isMonospace: true,
                                ),

                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // PHASE 1: FIRST-TIME SETUP (FILTERED DISCOVERY PICKER MODAL)
  // =========================================================================
  void _showBleDiscoveryModal(BuildContext context) {
    final repo = TelemetryRepository.instance;
    repo.startDiscoveryScan();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.90,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10121C).withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Header & UUID Filter Notification
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.bluetooth_searching_rounded, color: AppColors.cyan, size: 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Hardware Discovery',
                                      style: AppTypography.sans(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.gray),
                                  onPressed: () {
                                    repo.stopDiscoveryScan();
                                    Navigator.pop(sheetContext);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Strictly filtering by Service UUID (4FAFC201...)\nAmbient audio, TVs & consumer devices are hidden.',
                              style: AppTypography.sans(fontSize: 11, color: AppColors.gray, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            // Zero-Friction QR / NFC Pairing CTA
                            InkWell(
                              onTap: () async {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(sheetContext);
                                await repo.pairViaQrOrNfc();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('NFC / QR Tag scanned: OtoCPR Unit 01 paired directly!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfacePurple,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.nfc_rounded, color: AppColors.purple, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Zero-Friction QR / NFC Pairing',
                                            style: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          Text(
                                            'Tap phone to OtoCPR unit NFC tag to bypass list',
                                            style: AppTypography.sans(fontSize: 10, color: AppColors.gray),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.purple),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white12, height: 16),
                      // Discovered devices list (Sorted by Proximity RSSI)
                      Expanded(
                        child: ValueListenableBuilder<List<BleDeviceModel>>(
                          valueListenable: repo.discoveredDevicesNotifier,
                          builder: (context, devices, _) {
                            if (devices.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyan),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Listening for nearby OtoCPR beacons...',
                                      style: AppTypography.sans(fontSize: 13, color: AppColors.gray),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: devices.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final device = devices[index];
                                final isClosest = index == 0;

                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0C0E17).withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isClosest
                                          ? AppColors.purple.withValues(alpha: 0.5)
                                          : Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isClosest
                                              ? AppColors.surfacePurple
                                              : Colors.white.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.bluetooth_connected_rounded,
                                          color: isClosest ? AppColors.purple : AppColors.gray,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    device.name,
                                                    style: AppTypography.sans(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isClosest) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.purple.withValues(alpha: 0.3),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      'Closest',
                                                      style: AppTypography.sans(
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  '${device.rssi} dBm',
                                                  style: AppTypography.mono(
                                                    fontSize: 11,
                                                    color: AppColors.cyan,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '·  ${device.id}',
                                                  style: AppTypography.mono(
                                                    fontSize: 10,
                                                    color: AppColors.gray,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Rename button
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.gray),
                                        tooltip: 'Rename',
                                        onPressed: () => _showRenameDialog(context, device),
                                      ),
                                      // Pair Button
                                      ElevatedButton(
                                        onPressed: () async {
                                          HapticFeedback.mediumImpact();
                                          Navigator.pop(sheetContext);
                                          await repo.pairAndConnect(device);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.purple,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          'Pair',
                                          style: AppTypography.sans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      repo.stopDiscoveryScan();
    });
  }

  void _showRenameDialog(BuildContext context, BleDeviceModel device) {
    final textController = TextEditingController(text: device.name);
    final repo = TelemetryRepository.instance;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141724),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          title: Text(
            'Rename Hardware Identifier',
            style: AppTypography.sans(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            style: AppTypography.sans(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. OtoCPR Unit 01',
              hintStyle: AppTypography.sans(color: AppColors.gray),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.purple.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.purple),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: AppTypography.sans(color: AppColors.gray)),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = textController.text.trim();
                if (newName.isNotEmpty) {
                  repo.renamePairedDevice(newName);
                  final currentList = repo.discoveredDevicesNotifier.value;
                  repo.discoveredDevicesNotifier.value = currentList.map((d) {
                    return d.id == device.id ? d.copyWith(name: newName) : d;
                  }).toList();
                }
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Save', style: AppTypography.sans(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiagSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: AppTypography.sans(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: AppColors.cyan,
        ),
      ),
    );
  }

  Widget _buildDiagTile({
    required String label,
    required String value,
    Color? valueColor,
    bool isMonospace = false,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D14).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.sans(fontSize: 13, color: AppColors.gray),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: isMonospace
                    ? AppTypography.mono(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? AppColors.white,
                      )
                    : AppTypography.sans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? AppColors.white,
                      ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = TelemetryRepository.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: _isInteractingWithMap
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean Header Layer (Logo + Brand + Glass Diagnostics Button. NO status indicators)
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo_otocpr.png',
                    width: 36,
                    height: 36,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'OtoCPR',
                    style: AppTypography.sans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  // Glassmorphic Diagnostics Button
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF141224).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: IconButton(
                          onPressed: () => _showDiagnosticsSheet(context),
                          icon: const Icon(Icons.tune_rounded, color: AppColors.white, size: 20),
                          tooltip: 'Diagnostics',
                          splashRadius: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Operational Device Card (Frosted Glassmorphism, NO status indicators)
              Text(
                'Robotic System',
                style: AppTypography.sans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildOperationalGlassCard(context),

              const SizedBox(height: 24),

              // Streamlined Location Section (Clean map with location pointer, NO status overlays)
              Text(
                'Device Location',
                style: AppTypography.sans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              DeviceLocationMap(
                height: 280,
                onInteractingChange: (isInteracting) {
                  setState(() => _isInteractingWithMap = isInteracting);
                },
              ),

              const SizedBox(height: 24),

              // Machine Logs Section (Glassmorphic log cards)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Machine Logs',
                    style: AppTypography.sans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.onNavigateToLogs != null)
                    TextButton(
                      onPressed: widget.onNavigateToLogs,
                      child: Text(
                        'View all',
                        style: AppTypography.sans(
                          fontSize: 13,
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              ValueListenableBuilder<List<TelemetryLogItem>>(
                valueListenable: repo.logsNotifier,
                builder: (context, logs, _) {
                  final recentLogs = logs.take(4).toList();
                  return Column(
                    children: recentLogs.map((log) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildGlassLogCard(
                          filename: log.name,
                          timestamp: log.time,
                          size: log.size,
                          status: log.status,
                          isDerate: log.isDerate,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperationalGlassCard(BuildContext context) {
    final repo = TelemetryRepository.instance;

    return ValueListenableBuilder<BleDeviceModel?>(
      valueListenable: repo.pairedDeviceNotifier,
      builder: (context, pairedDevice, _) {
        return ValueListenableBuilder<Esp32ConnectionStatus>(
          valueListenable: repo.connectionStatusNotifier,
          builder: (context, status, _) {
            final isConnected = status == Esp32ConnectionStatus.connected;
            final isSearching = status == Esp32ConnectionStatus.searching;
            final isConnecting = status == Esp32ConnectionStatus.connecting;
            final isTimeout = status == Esp32ConnectionStatus.timeout;
            final isBusy = isSearching || isConnecting;

            final deviceName = pairedDevice?.name ?? 'No Device Paired';

            return GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(18),
              borderColor: isTimeout
                  ? AppColors.red.withValues(alpha: 0.5)
                  : (isConnected
                      ? AppColors.purple.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.12)),
              tintColor: isTimeout
                  ? const Color(0xFF281018).withValues(alpha: 0.6)
                  : const Color(0xFF141224).withValues(alpha: 0.55),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Equipment Name & Actions
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isConnected
                              ? AppColors.purple.withValues(alpha: 0.25)
                              : const Color(0xFF181C24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.precision_manufacturing_rounded,
                          color: isConnected ? AppColors.purple : AppColors.gray,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    deviceName,
                                    style: AppTypography.sans(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (pairedDevice != null) ...[
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.gray),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Rename Device',
                                    onPressed: () => _showRenameDialog(context, pairedDevice),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pairedDevice != null
                                  ? 'ID: ${pairedDevice.id} · Cached'
                                  : 'Tap to setup your OtoCPR hardware',
                              style: AppTypography.sans(
                                fontSize: 11,
                                color: AppColors.gray,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Options popup menu (Unpair, Discovery, Test Timeout)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.gray),
                        color: const Color(0xFF141724),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        onSelected: (value) {
                          if (value == 'discovery') {
                            _showBleDiscoveryModal(context);
                          } else if (value == 'unpair') {
                            repo.unpairDevice();
                          } else if (value == 'test_timeout') {
                            repo.oneTapReconnect(simulateHardwareOff: true);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'discovery',
                            child: Row(
                              children: [
                                const Icon(Icons.bluetooth_searching_rounded, size: 16, color: AppColors.cyan),
                                const SizedBox(width: 10),
                                Text('Scan for New Device', style: AppTypography.sans(fontSize: 12)),
                              ],
                            ),
                          ),
                          if (pairedDevice != null)
                            PopupMenuItem(
                              value: 'test_timeout',
                              child: Row(
                                children: [
                                  const Icon(Icons.timer_off_outlined, size: 16, color: AppColors.red),
                                  const SizedBox(width: 10),
                                  Text('Simulate Hardware Off (Test Timeout)', style: AppTypography.sans(fontSize: 12)),
                                ],
                              ),
                            ),
                          if (pairedDevice != null)
                            PopupMenuItem(
                              value: 'unpair',
                              child: Row(
                                children: [
                                  const Icon(Icons.link_off_rounded, size: 16, color: AppColors.gray),
                                  const SizedBox(width: 10),
                                  Text('Unpair Device', style: AppTypography.sans(fontSize: 12)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Operational Vitals Bar (Clean Glassmorphic container with pure telemetry numbers)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF080A12).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildVitalPill(
                          icon: Icons.battery_charging_full_rounded,
                          label: 'Battery',
                          value: isConnected ? '96%' : '--',
                          color: AppColors.cyan,
                        ),
                        Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.08)),
                        _buildVitalPill(
                          icon: Icons.speed_rounded,
                          label: 'Cadence',
                          value: isConnected ? '${repo.esp32.compressionRate.toStringAsFixed(0)} CPM' : '--',
                          color: AppColors.purple,
                        ),
                        Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.08)),
                        _buildVitalPill(
                          icon: Icons.repeat_rounded,
                          label: 'Cycles',
                          value: isConnected ? '${repo.esp32.compressionCount}' : '--',
                          color: AppColors.cyan,
                        ),
                      ],
                    ),
                  ),

                  // Handshake Progress Feedback / Safety Fallback Warning
                  if (isBusy) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCyan,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyan),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ValueListenableBuilder<String>(
                              valueListenable: repo.connectionFeedbackNotifier,
                              builder: (context, feedback, _) {
                                return Text(
                                  feedback,
                                  style: AppTypography.sans(fontSize: 12, color: AppColors.cyan, fontWeight: FontWeight.w500),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (isTimeout) ...[
                    const SizedBox(height: 14),
                    // Essential Safety Fallback Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRed,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Could not find $deviceName. Make sure it is powered on.',
                                  style: AppTypography.sans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              // Fallback CTA: [Scan for New Device]
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showBleDiscoveryModal(context),
                                  icon: const Icon(Icons.bluetooth_searching_rounded, size: 14),
                                  label: const Text('Scan for New Device'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.purple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    textStyle: AppTypography.sans(fontSize: 11, fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Retry 1-tap reconnect
                              OutlinedButton(
                                onPressed: () => repo.oneTapReconnect(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.5)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  'Retry',
                                  style: AppTypography.sans(fontSize: 11, color: AppColors.cyan, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action Buttons Row (1-Tap Reconnect vs Phase 1 Setup)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isBusy
                              ? null
                              : () async {
                                  HapticFeedback.mediumImpact();
                                  if (pairedDevice == null) {
                                    // Phase 1 Setup
                                    _showBleDiscoveryModal(context);
                                  } else if (isConnected) {
                                    repo.disconnectEsp32();
                                  } else {
                                    // Phase 2: 1-Tap Reconnect
                                    await repo.oneTapReconnect();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isConnected
                                ? const Color(0xFF32121E)
                                : (isBusy ? const Color(0xFF161C26) : AppColors.purple),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isConnected
                                    ? AppColors.red.withValues(alpha: 0.6)
                                    : (isBusy ? AppColors.cyan.withValues(alpha: 0.5) : AppColors.purple),
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            pairedDevice == null
                                ? 'Pair Device'
                                : (isBusy
                                    ? 'Connecting...'
                                    : (isConnected ? 'Disconnect' : 'Connect ($deviceName)')),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (widget.onNavigateToTelemetry != null) ...[
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: widget.onNavigateToTelemetry,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Telemetry',
                            style: AppTypography.sans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.cyan,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVitalPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.sans(
                fontSize: 10,
                color: AppColors.gray,
              ),
            ),
            Text(
              value,
              style: AppTypography.sans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassLogCard({
    required String filename,
    required String timestamp,
    required String size,
    required String status,
    required bool isDerate,
  }) {
    final statusColor = isDerate ? AppColors.red : AppColors.cyan;
    final statusBg = isDerate ? AppColors.surfaceRed : AppColors.surfaceCard;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1018).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDerate ? Icons.warning_amber_rounded : Icons.description_outlined,
                  size: 18,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filename,
                      style: AppTypography.mono(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$timestamp · $size',
                      style: AppTypography.sans(
                        fontSize: 11,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  status,
                  style: AppTypography.sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
