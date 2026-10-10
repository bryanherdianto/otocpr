import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/telemetry_models.dart';
import '../services/telemetry_repository.dart';

class TelemetryLogsScreen extends StatefulWidget {
  const TelemetryLogsScreen({super.key});

  @override
  State<TelemetryLogsScreen> createState() => _TelemetryLogsScreenState();
}

class _TelemetryLogsScreenState extends State<TelemetryLogsScreen> {
  int _selectedCategory = 0; // 0: All, 1: ESP32, 2: AI
  int? _selectedLogIndex;

  List<TelemetryLogItem> _filterLogs(List<TelemetryLogItem> allLogs) {
    switch (_selectedCategory) {
      case 1:
        return allLogs.where((l) => l.category == 'ESP32').toList();
      case 2:
        return allLogs.where((l) => l.category == 'AI').toList();
      case 0:
      default:
        return allLogs;
    }
  }

  void _showLogDetailsSheet(BuildContext context, TelemetryLogItem log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.38,
          minChildSize: 0.22,
          maxChildSize: 0.72,
          snap: true,
          snapSizes: const [0.38, 0.72],
          builder: (sheetContext, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF101318),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: AppColors.darkGray),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Drag Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.gray.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header Row with filename, timestamp, and copy action
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.terminal_rounded, size: 16, color: AppColors.cyan),
                            const SizedBox(width: 8),
                            Text(
                              log.name,
                              style: AppTypography.mono(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              log.time,
                              style: AppTypography.mono(fontSize: 11, color: AppColors.gray),
                            ),
                            const SizedBox(width: 8),
                            _CopyLogButton(text: log.fullJson),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Clearer, fuller JSON viewer that can be dragged up & scrolled
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF22262E)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SelectableText(
                                log.fullJson,
                                style: AppTypography.mono(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: const Color(0xFFC0CAD0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TelemetryLogItem>>(
      valueListenable: TelemetryRepository.instance.logsNotifier,
      builder: (context, allLogs, _) {
        final filteredLogs = _filterLogs(allLogs);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header & Sub-Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Machine Logs',
                            style: AppTypography.sans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfacePurple,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              '${filteredLogs.length} Files',
                              style: AppTypography.mono(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sub-tabs: All | ESP32 | AI
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surfacePurple,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.purple.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            _buildCategoryTab(0, 'All'),
                            _buildCategoryTab(1, 'ESP32'),
                            _buildCategoryTab(2, 'AI'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // High-density File Tree List (Driven by TelemetryRepository)
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredLogs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      final isSelected = _selectedLogIndex == index;
                      final isDerate = log.isDerate;
                      final statusColor = isDerate ? AppColors.red : AppColors.cyan;
                      final statusBg = isDerate ? AppColors.surfaceRed : AppColors.surfaceCard;

                      return InkWell(
                        onTap: () {
                          setState(() => _selectedLogIndex = index);
                          _showLogDetailsSheet(context, log);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF181C22) : const Color(0xFF0D0D0D),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? statusColor.withValues(alpha: 0.6) : AppColors.darkGray,
                              width: isSelected ? 1.5 : 1,
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
                                  isDerate ? Icons.warning_amber_rounded : Icons.code_rounded,
                                  size: 16,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.name,
                                      style: AppTypography.mono(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${log.time} · ${log.size}',
                                      style: AppTypography.sans(fontSize: 11, color: AppColors.gray),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  log.status,
                                  style: AppTypography.sans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTab(int index, String title) {
    final isSelected = _selectedCategory == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedCategory = index;
          _selectedLogIndex = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.purple.withValues(alpha: 0.4) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.sans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.gray,
            ),
          ),
        ),
      ),
    );
  }
}

class _CopyLogButton extends StatefulWidget {
  final String text;
  const _CopyLogButton({required this.text});

  @override
  State<_CopyLogButton> createState() => _CopyLogButtonState();
}

class _CopyLogButtonState extends State<_CopyLogButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.text));
        setState(() => _copied = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _copied = false);
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          _copied ? Icons.check_rounded : Icons.copy_rounded,
          size: 16,
          color: _copied ? AppColors.purple : AppColors.cyan,
        ),
      ),
    );
  }
}
