import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/telemetry_repository.dart';

class TelemetryAiScreen extends StatefulWidget {
  const TelemetryAiScreen({super.key});

  @override
  State<TelemetryAiScreen> createState() => _TelemetryAiScreenState();
}

class _TelemetryAiScreenState extends State<TelemetryAiScreen> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: TelemetryRepository.instance.aiDiagnosticsNotifier,
          builder: (context, ai, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clean Header (No slop status pills)
                  Text(
                    'AI Diagnostics',
                    style: AppTypography.sans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Primary Hero Card (NO GRADIENT, Clean Frosted Glassmorphism)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141224).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.purple.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ai.classification,
                              style: AppTypography.sans(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ai.guidelineSubtitle,
                              style: AppTypography.sans(
                                fontSize: 13,
                                color: AppColors.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Diagnostic Insight (Glassmorphism)
                  Text(
                    'Diagnostic Insight',
                    style: AppTypography.sans(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10121C).withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          ai.diagnosticInsight,
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

                  // Data Evidence Grid (Clean glass cards, NO status pills, NO green)
                  Text(
                    'Data Evidence',
                    style: AppTypography.sans(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassEvidenceCard(
                          'Tidal Volume',
                          '${ai.tidalVolume.toStringAsFixed(0)} ML',
                          AppColors.cyan,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGlassEvidenceCard(
                          'Stroke Force',
                          '${ai.strokeForce.toStringAsFixed(1)} N',
                          AppColors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassEvidenceCard(
                          'Recoil Residual',
                          '${ai.recoilResidual.toStringAsFixed(1)} N',
                          AppColors.cyan,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGlassEvidenceCard(
                          'Fatigue Drift',
                          '${ai.fatigueDrift.toStringAsFixed(1)}%',
                          AppColors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Window History (Glassmorphism, NO GREEN, explicit legend for blue/purple/red)
                  Text(
                    'Window History',
                    style: AppTypography.sans(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10121C).withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Session Protocol Index', style: AppTypography.sans(fontSize: 13, color: AppColors.gray)),
                                Text(
                                  '${ai.sessionHealthIndex.toStringAsFixed(1)}%',
                                  style: AppTypography.mono(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.cyan),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Segmented History Bar (Strictly: Cyan/Blue = Optimal, Purple = Trim, Red = Warning)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Row(
                                children: [
                                  Expanded(flex: 7, child: Container(height: 10, color: AppColors.cyan)),
                                  const SizedBox(width: 2),
                                  Expanded(flex: 2, child: Container(height: 10, color: AppColors.purple)),
                                  const SizedBox(width: 2),
                                  Expanded(flex: 9, child: Container(height: 10, color: AppColors.cyan)),
                                  const SizedBox(width: 2),
                                  Expanded(flex: 1, child: Container(height: 10, color: AppColors.red)),
                                  const SizedBox(width: 2),
                                  Expanded(flex: 6, child: Container(height: 10, color: AppColors.cyan)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('-10m', style: AppTypography.mono(fontSize: 10, color: AppColors.gray)),
                                Text('Now', style: AppTypography.mono(fontSize: 10, color: AppColors.gray)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Color Legend: Explaining Blue, Purple, and Red
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildLegendItem(AppColors.cyan, 'Optimal Dynamics'),
                                  _buildLegendItem(AppColors.purple, 'Actuator Trim'),
                                  _buildLegendItem(AppColors.red, 'Limit Warning'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Raw JSON Data (Glassmorphic)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Raw JSON Data',
                        style: AppTypography.sans(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: ai.rawJson));
                          setState(() => _copied = true);
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) setState(() => _copied = false);
                          });
                        },
                        icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded, size: 14, color: AppColors.cyan),
                        label: Text(
                          _copied ? 'Copied' : 'Copy',
                          style: AppTypography.sans(fontSize: 12, color: AppColors.cyan, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0C14).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            ai.rawJson,
                            style: AppTypography.mono(fontSize: 11, height: 1.5, color: const Color(0xFFC0CAD0)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassEvidenceCard(String label, String value, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF10121C).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.sans(fontSize: 12, color: AppColors.gray)),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTypography.mono(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.sans(fontSize: 10, color: AppColors.gray),
        ),
      ],
    );
  }
}
