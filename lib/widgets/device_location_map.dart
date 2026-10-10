import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../models/telemetry_models.dart';
import '../services/telemetry_repository.dart';

class DeviceLocationMap extends StatefulWidget {
  final LatLng? initialPosition;
  final double height;
  final ValueChanged<bool>? onInteractingChange;

  const DeviceLocationMap({
    super.key,
    this.initialPosition,
    this.height = 280,
    this.onInteractingChange,
  });

  @override
  State<DeviceLocationMap> createState() => _DeviceLocationMapState();
}

class _DeviceLocationMapState extends State<DeviceLocationMap> {
  late final MapController _mapController;
  double _currentZoom = 15.0;
  bool _autoFollow = true;

  LatLng get _currentPos {
    if (widget.initialPosition != null) return widget.initialPosition!;
    final loc = TelemetryRepository.instance.location;
    return LatLng(loc.latitude, loc.longitude);
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    TelemetryRepository.instance.locationNotifier.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    TelemetryRepository.instance.locationNotifier.removeListener(_onLocationChanged);
    _mapController.dispose();
    super.dispose();
  }

  void _onLocationChanged() {
    if (_autoFollow && mounted) {
      final loc = TelemetryRepository.instance.location;
      final target = LatLng(loc.latitude, loc.longitude);
      _mapController.move(target, _currentZoom);
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(3.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(3.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _toggleAutoFollow() {
    setState(() {
      _autoFollow = !_autoFollow;
      if (_autoFollow) {
        _currentZoom = 15.0;
        _mapController.move(_currentPos, _currentZoom);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DeviceLocationData>(
      valueListenable: TelemetryRepository.instance.locationNotifier,
      builder: (context, location, child) {
        final pos = _currentPos;

        return Listener(
          onPointerDown: (_) => widget.onInteractingChange?.call(true),
          onPointerUp: (_) => widget.onInteractingChange?.call(false),
          onPointerCancel: (_) => widget.onInteractingChange?.call(false),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: widget.height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF10121C),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: pos,
                      initialZoom: _currentZoom,
                      minZoom: 3.0,
                      maxZoom: 18.0,
                      onPositionChanged: (camera, hasGesture) {
                        if (hasGesture && _autoFollow) {
                          setState(() => _autoFollow = false);
                        }
                      },
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.otocpr.auto_cpr',
                      ),
                      MarkerLayer(
                        markers: [
                          // 1. Map Pointer Icon indicating the device location
                          Marker(
                            point: pos,
                            width: 44,
                            height: 44,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_pin,
                              size: 42,
                              color: AppColors.purple,
                              shadows: [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Floating Glassmorphic Map Controls (Top-Right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Column(
                      children: [
                        _buildGlassControlButton(
                          icon: Icons.add_rounded,
                          onPressed: _zoomIn,
                          tooltip: 'Zoom in',
                        ),
                        const SizedBox(height: 6),
                        _buildGlassControlButton(
                          icon: Icons.remove_rounded,
                          onPressed: _zoomOut,
                          tooltip: 'Zoom out',
                        ),
                        const SizedBox(height: 6),
                        _buildGlassControlButton(
                          icon: _autoFollow ? Icons.near_me_rounded : Icons.my_location_rounded,
                          onPressed: _toggleAutoFollow,
                          tooltip: _autoFollow ? 'Tracking' : 'Follow Device',
                          iconColor: _autoFollow ? AppColors.cyan : Colors.white70,
                          isActive: _autoFollow,
                        ),
                      ],
                    ),
                  ),

                  // OpenStreetMap attribution badge (Bottom-Right, subtle glass)
                  Positioned(
                    right: 8,
                    bottom: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            '© OpenStreetMap',
                            style: AppTypography.sans(
                              fontSize: 9,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color iconColor = Colors.white,
    bool isActive = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF121420).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? AppColors.cyan.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, size: 18, color: iconColor),
            onPressed: onPressed,
            tooltip: tooltip,
            padding: EdgeInsets.zero,
            splashRadius: 18,
          ),
        ),
      ),
    );
  }
}
