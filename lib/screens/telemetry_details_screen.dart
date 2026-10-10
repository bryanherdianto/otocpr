import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/telemetry_repository.dart';

class TelemetryDetailsScreen extends StatefulWidget {
  final String title;
  final String currentValue;
  final String unit;

  const TelemetryDetailsScreen({
    super.key,
    this.title = 'Instantaneous Force',
    this.currentValue = '68.5',
    this.unit = 'N',
  });

  @override
  State<TelemetryDetailsScreen> createState() => _TelemetryDetailsScreenState();
}

class _TelemetryDetailsScreenState extends State<TelemetryDetailsScreen> {
  int _selectedTimeframe = 0;
  final List<String> _timeframes = ['1m', '5m', '15m', 'All'];

  @override
  Widget build(BuildContext context) {
    final history = TelemetryRepository.instance.getMetricHistory(
      widget.title,
      timeframeIndex: _selectedTimeframe,
    );
    final displayValue = widget.currentValue.isNotEmpty ? widget.currentValue : history.currentValue;
    final displayUnit = widget.unit.isNotEmpty ? widget.unit : history.unit;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Back Button + Clean Title (NO status badges)
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF141224).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTypography.sans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Timeframe Selector Tabs (Glassmorphism)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10121C).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: List.generate(_timeframes.length, (index) {
                        final isSelected = _selectedTimeframe == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTimeframe = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.purple.withValues(alpha: 0.4) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _timeframes[index],
                                textAlign: TextAlign.center,
                                style: AppTypography.sans(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? Colors.white : AppColors.gray,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Hero Metric Display
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    displayValue,
                    style: AppTypography.mono(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (displayUnit.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      displayUnit,
                      style: AppTypography.sans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Section: Data Distribution Chart (Glassmorphism)
              Text(
                'Data Distribution',
                style: AppTypography.sans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10121C).withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _TelemetryChartPainter(data: history.chartPoints),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section: Summary Cards (Glassmorphism)
              Text(
                'Summary',
                style: AppTypography.sans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10121C).withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Target Range', history.targetRange, displayUnit),
                        Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.1)),
                        _buildStat('Mean Value', history.meanValue, displayUnit),
                        Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.1)),
                        _buildStat('Efficiency', history.efficiency, ''),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section: About Metric (Glassmorphism)
              Text(
                'About ${widget.title}',
                style: AppTypography.sans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141224).withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Text(
                      history.description,
                      style: AppTypography.sans(
                        fontSize: 13,
                        height: 1.6,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.sans(fontSize: 11, color: AppColors.gray),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTypography.mono(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: AppTypography.sans(fontSize: 10, color: AppColors.gray),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _TelemetryChartPainter extends CustomPainter {
  final List<double> data;
  _TelemetryChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Strict palette: Cyan/Blue bars + Purple trend line
    final paintBar = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final barWidth = size.width / (data.length * 1.6);
    final maxVal = 120.0;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * (size.width / (data.length - 1));
      final barHeight = (data[i] / maxVal) * size.height;
      final y = size.height - barHeight;

      // Draw bar
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - barWidth / 2, y, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(barRect, paintBar);

      // Path for overlay line
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
