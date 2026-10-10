import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/telemetry_repository.dart';
import 'telemetry_details_screen.dart';

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({super.key});

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = TelemetryRepository.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hardware Header (Frosted Glassmorphism, NO status indicators)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141224).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.memory_rounded,
                            color: AppColors.purple,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ESP32-C3 Actuator Hub',
                                style: AppTypography.sans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Robotic Actuator & Sensor Board',
                                style: AppTypography.sans(
                                  fontSize: 12,
                                  color: AppColors.gray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Clean Real-Time Data Title (NO status indicator)
              Text(
                'Real-Time Data',
                style: AppTypography.sans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              // Comprehensive ESP32 Telemetry Grid (Glassmorphism)
              ListenableBuilder(
                listenable: repo.esp32Notifier,
                builder: (context, _) => _buildEsp32Grid(),
              ),

              const SizedBox(height: 24),

              // Summary Section (Glassmorphism)
              Text(
                'Summary',
                style: AppTypography.sans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListenableBuilder(
                listenable: repo.esp32Notifier,
                builder: (context, _) => _buildEsp32Summary(),
              ),

              const SizedBox(height: 24),

              // About Section (Frosted Glassmorphic Card)
              Text(
                'About Controller',
                style: AppTypography.sans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141224).withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      'Powered by an ultra-compact ESP32-C3 RISC-V microcontroller on a custom carrier PCB, this controller functions as the primary actuator and telemetry engine. It regulates closed-loop PID velocity control over the BLDC drive, samples load-cell normal force vectors up to 500 Hz, monitors optical quadrature shaft encoders, and broadcasts real-time CPR telemetry streams.',
                      style: AppTypography.sans(
                        fontSize: 13,
                        height: 1.6,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEsp32Grid() {
    final esp = TelemetryRepository.instance.esp32;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Instant Force',
                value: esp.instantForce.toStringAsFixed(1),
                unit: 'N',
                icon: Icons.trending_up_rounded,
                accentColor: AppColors.cyan,
                onTap: () => _openDetails('Instantaneous Force', esp.instantForce.toStringAsFixed(1), 'N'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Peak Force',
                value: esp.peakForce.toStringAsFixed(1),
                unit: 'N',
                icon: Icons.compress_rounded,
                accentColor: AppColors.purple,
                onTap: () => _openDetails('Peak Force', esp.peakForce.toStringAsFixed(1), 'N'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Stroke Depth',
                value: esp.compressionDepth.toStringAsFixed(1),
                unit: 'CM',
                icon: Icons.straighten_rounded,
                accentColor: AppColors.cyan,
                onTap: () => _openDetails('Compression Depth', esp.compressionDepth.toStringAsFixed(1), 'CM'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Compression Rate',
                value: esp.compressionRate.toStringAsFixed(0),
                unit: 'CPM',
                icon: Icons.favorite_rounded,
                accentColor: AppColors.purple,
                onTap: () => _openDetails('Compression Rate', esp.compressionRate.toStringAsFixed(0), 'CPM'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Position Angle',
                value: esp.positionAngle.toStringAsFixed(1),
                unit: '°',
                icon: Icons.rotate_right_rounded,
                accentColor: AppColors.cyan,
                onTap: () => _openDetails('Position Angle', esp.positionAngle.toStringAsFixed(1), '°'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Motor Speed',
                value: esp.motorSpeed.toStringAsFixed(0),
                unit: 'RPM',
                icon: Icons.speed_rounded,
                accentColor: AppColors.purple,
                onTap: () => _openDetails('Motor Speed', esp.motorSpeed.toStringAsFixed(0), 'RPM'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Direction',
                value: esp.direction,
                unit: '',
                icon: Icons.sync_rounded,
                accentColor: AppColors.cyan,
                onTap: () => _openDetails('Motor Direction', esp.direction, ''),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Compression Count',
                value: '${esp.compressionCount}',
                unit: 'CYC',
                icon: Icons.repeat_rounded,
                accentColor: AppColors.purple,
                onTap: () => _openDetails('Compression Count', '${esp.compressionCount}', 'CYC'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color accentColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF10121C).withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value,
                          style: AppTypography.mono(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (unit.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            unit,
                            style: AppTypography.sans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Icon(icon, size: 18, color: accentColor),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: AppTypography.sans(
                    fontSize: 13,
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEsp32Summary() {
    final esp = TelemetryRepository.instance.esp32;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF10121C).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Mean Peak Force', (esp.peakForce * 1.01).toStringAsFixed(1), 'N'),
              const Divider(color: Color(0xFF1C202C), height: 16),
              _buildSummaryRow('Median Actuator Speed', esp.motorSpeed.toStringAsFixed(0), 'RPM'),
              const Divider(color: Color(0xFF1C202C), height: 16),
              _buildSummaryRow('Mean Stroke Depth', esp.compressionDepth.toStringAsFixed(1), 'CM'),
              const Divider(color: Color(0xFF1C202C), height: 16),
              _buildSummaryRow('Actuator Core Temp', esp.motorTemp.toStringAsFixed(1), '°C'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.sans(
            fontSize: 13,
            color: AppColors.gray,
          ),
        ),
        Text(
          unit.isNotEmpty ? '$value $unit' : value,
          style: AppTypography.mono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  void _openDetails(String title, String value, String unit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TelemetryDetailsScreen(
          title: title,
          currentValue: value,
          unit: unit,
        ),
      ),
    );
  }
}
