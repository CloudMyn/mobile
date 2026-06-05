import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/logging/request_log_entry.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/request_log_controller.dart';
import 'request_log_detail_page.dart';

/// Halaman daftar request/response log untuk debugging.
class RequestLogPage extends StatelessWidget {
  const RequestLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RequestLogController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    // Reload saat halaman dibuka
    ctrl.loadLogs();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Request Log',
        variant: AppTopAppBarVariant.withBack,
        actions: [
          Obx(() {
            if (ctrl.logs.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(Icons.delete_sweep_rounded, color: colors.error),
              tooltip: 'Hapus Semua Log',
              onPressed: () => _confirmClear(context, ctrl, colors, typography),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          _FilterSection(ctrl: ctrl, colors: colors, typography: typography),
          Expanded(
            child: Obx(() {
              if (ctrl.logs.isEmpty) {
                if (ctrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _EmptyState(
                  colors: colors,
                  typography: typography,
                  hasFilters: ctrl.hasActiveFilters,
                  onClearFilters: ctrl.clearFilters,
                );
              }
              return _LogList(
                ctrl: ctrl,
                colors: colors,
                typography: typography,
              );
            }),
          ),
        ],
      ),
    );
  }

  void _confirmClear(
    BuildContext context,
    RequestLogController ctrl,
    AppColors colors,
    AppTypography typography,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16),
        ),
        title: Text(
          'Hapus Semua Log?',
          style: typography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Semua log request/response akan dihapus permanen.',
          style: typography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: typography.labelLarge),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              ctrl.clearAllLogs();
            },
            child: Text(
              'Hapus',
              style: typography.labelLarge.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Filter Section
// ═══════════════════════════════════════════════════════════════════════════════

class _FilterSection extends StatelessWidget {
  final RequestLogController ctrl;
  final AppColors colors;
  final AppTypography typography;

  const _FilterSection({
    required this.ctrl,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.surface,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s16.w,
              vertical: AppSpacing.s8.h,
            ),
            child: TextField(
              onChanged: (v) => ctrl.setSearch(v),
              decoration: InputDecoration(
                hintText: 'Cari URL endpoint...',
                hintStyle: typography.bodyMedium.copyWith(
                  color: colors.outline,
                ),
                prefixIcon: Icon(Icons.search, color: colors.outline),
                filled: true,
                fillColor: colors.background,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12.w,
                  vertical: AppSpacing.s10.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  borderSide: BorderSide(
                    color: colors.outline.withValues(alpha: 0.15),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
                isDense: true,
              ),
              style: typography.bodyMedium.copyWith(color: colors.onSurface),
            ),
          ),

          // Method + Status filter chips
          Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16.w),
                child: Row(
                  children: [
                    // Method filters
                    _buildMethodChip('ALL', null),
                    _buildMethodChip('GET', 'GET'),
                    _buildMethodChip('POST', 'POST'),
                    _buildMethodChip('PUT', 'PUT'),
                    _buildMethodChip('DELETE', 'DELETE'),
                    SizedBox(width: AppSpacing.s8.w),
                    // Divider
                    Container(
                      width: 1,
                      height: 24.h,
                      color: colors.outline.withValues(alpha: 0.2),
                    ),
                    SizedBox(width: AppSpacing.s8.w),
                    // Status filters
                    _buildStatusChip('All', null),
                    _buildStatusChip('Success', true),
                    _buildStatusChip('Error', false),
                    SizedBox(width: AppSpacing.s8.w),
                    // Date range button
                    _DateRangeChip(
                      ctrl: ctrl,
                      colors: colors,
                      typography: typography,
                    ),
                  ],
                ),
              )),

          SizedBox(height: AppSpacing.s8.h),

          // Total count
          Obx(() => Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16.w),
                child: Row(
                  children: [
                    Text(
                      '${ctrl.totalCount.value} log entries',
                      style: typography.labelSmall.copyWith(
                        color: colors.outline,
                      ),
                    ),
                    const Spacer(),
                    if (ctrl.hasActiveFilters)
                      GestureDetector(
                        onTap: ctrl.clearFilters,
                        child: Text(
                          'Clear Filters',
                          style: typography.labelSmall.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              )),

          SizedBox(height: AppSpacing.s4.h),
          Divider(height: 1, color: colors.outline.withValues(alpha: 0.1)),
        ],
      ),
    );
  }

  Widget _buildMethodChip(String label, String? method) {
    final isSelected = ctrl.selectedMethod.value == method;
    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.s4.w),
      child: ChoiceChip(
        label: Text(
          label,
          style: typography.labelSmall.copyWith(
            color: isSelected ? colors.onPrimary : colors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: colors.primary,
        backgroundColor: colors.surface,
        side: BorderSide(
          color: isSelected ? colors.primary : colors.outline.withValues(alpha: 0.3),
        ),
        visualDensity: VisualDensity.compact,
        onSelected: (_) => ctrl.setMethod(method),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool? status) {
    final isSelected = ctrl.selectedStatus.value == status;
    Color chipColor;
    if (status == true) {
      chipColor = colors.success;
    } else if (status == false) {
      chipColor = colors.error;
    } else {
      chipColor = colors.primary;
    }

    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.s4.w),
      child: ChoiceChip(
        label: Text(
          label,
          style: typography.labelSmall.copyWith(
            color: isSelected ? colors.onPrimary : colors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: chipColor,
        backgroundColor: colors.surface,
        side: BorderSide(
          color: isSelected ? chipColor : colors.outline.withValues(alpha: 0.3),
        ),
        visualDensity: VisualDensity.compact,
        onSelected: (_) => ctrl.setStatus(status),
      ),
    );
  }
}

class _DateRangeChip extends StatelessWidget {
  final RequestLogController ctrl;
  final AppColors colors;
  final AppTypography typography;

  const _DateRangeChip({
    required this.ctrl,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasRange = ctrl.startDate.value != null || ctrl.endDate.value != null;
      return ActionChip(
        avatar: Icon(
          Icons.date_range_rounded,
          size: 16,
          color: hasRange ? colors.onPrimary : colors.outline,
        ),
        label: Text(
          hasRange ? _formatRange() : 'Tanggal',
          style: typography.labelSmall.copyWith(
            color: hasRange ? colors.onPrimary : colors.onSurface,
            fontWeight: hasRange ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: hasRange ? colors.primary : colors.surface,
        side: BorderSide(
          color: hasRange ? colors.primary : colors.outline.withValues(alpha: 0.3),
        ),
        visualDensity: VisualDensity.compact,
        onPressed: () => _pickDateRange(context),
      );
    });
  }

  String _formatRange() {
    final start = ctrl.startDate.value;
    final end = ctrl.endDate.value;
    if (start != null && end != null) {
      return '${_fmtDate(start)} - ${_fmtDate(end)}';
    }
    if (start != null) return 'Dari ${_fmtDate(start)}';
    if (end != null) return 'Sampai ${_fmtDate(end)}';
    return 'Tanggal';
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}';

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
      initialDateRange: ctrl.startDate.value != null && ctrl.endDate.value != null
          ? DateTimeRange(start: ctrl.startDate.value!, end: ctrl.endDate.value!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: colors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ctrl.setDateRange(picked.start, picked.end);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Log List
// ═══════════════════════════════════════════════════════════════════════════════

class _LogList extends StatelessWidget {
  final RequestLogController ctrl;
  final AppColors colors;
  final AppTypography typography;

  const _LogList({
    required this.ctrl,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
          ctrl.loadMore();
        }
        return false;
      },
      child: Obx(() => ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s12.w,
              vertical: AppSpacing.s8.h,
            ),
            itemCount: ctrl.logs.length + (ctrl.hasMore.value ? 1 : 0),
            separatorBuilder: (_, _) => SizedBox(height: AppSpacing.s4.h),
            itemBuilder: (context, index) {
              if (index >= ctrl.logs.length) {
                return Padding(
                  padding: EdgeInsets.all(AppSpacing.s16.w),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return RepaintBoundary(
                child: _LogListItem(
                  entry: ctrl.logs[index],
                  colors: colors,
                  typography: typography,
                  onTap: () => Get.to(
                    () => RequestLogDetailPage(entry: ctrl.logs[index]),
                  ),
                ),
              );
            },
          )),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Log List Item
// ═══════════════════════════════════════════════════════════════════════════════

class _LogListItem extends StatelessWidget {
  final RequestLogEntry entry;
  final AppColors colors;
  final AppTypography typography;
  final VoidCallback onTap;

  const _LogListItem({
    required this.entry,
    required this.colors,
    required this.typography,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.r8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.r8),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s12.w,
            vertical: AppSpacing.s10.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.r8),
            border: Border.all(
              color: entry.isError
                  ? colors.error.withValues(alpha: 0.3)
                  : colors.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Method badge + URL
              Row(
                children: [
                  _MethodBadge(
                    method: entry.method,
                    colors: colors,
                    typography: typography,
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  Expanded(
                    child: Text(
                      _shortenUrl(entry.url),
                      style: typography.bodySmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  _StatusBadge(
                    statusCode: entry.statusCode,
                    isError: entry.isError,
                    colors: colors,
                    typography: typography,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s4.h),
              // Row 2: Duration + Timestamp + Size
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 12, color: colors.outline),
                  SizedBox(width: AppSpacing.s2.w),
                  Text(
                    '${entry.durationMs}ms',
                    style: typography.labelSmall.copyWith(
                      color: _getDurationColor(entry.durationMs),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s12.w),
                  Icon(Icons.access_time, size: 12, color: colors.outline),
                  SizedBox(width: AppSpacing.s2.w),
                  Text(
                    _formatTime(entry.timestamp),
                    style: typography.labelSmall.copyWith(color: colors.outline),
                  ),
                  const Spacer(),
                  Text(
                    '↑${RequestLogEntry.formatBytes(entry.requestSize)} ↓${RequestLogEntry.formatBytes(entry.responseSize)}',
                    style: typography.labelSmall.copyWith(
                      color: colors.outline,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDurationColor(int ms) {
    if (ms < 300) return colors.success;
    if (ms < 1000) return colors.warning;
    return colors.error;
  }

  String _shortenUrl(String url) {
    // Hanya tampilkan path (tanpa base URL)
    try {
      final uri = Uri.parse(url);
      return uri.path + (uri.query.isNotEmpty ? '?...' : '');
    } catch (_) {
      return url;
    }
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Badges
// ═══════════════════════════════════════════════════════════════════════════════

class _MethodBadge extends StatelessWidget {
  final String method;
  final AppColors colors;
  final AppTypography typography;

  const _MethodBadge({
    required this.method,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s2.h,
      ),
      decoration: BoxDecoration(
        color: _methodColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: Text(
        method,
        style: typography.labelSmall.copyWith(
          color: _methodColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Color get _methodColor {
    switch (method.toUpperCase()) {
      case 'GET':
        return colors.success;
      case 'POST':
        return const Color(0xFF1976D2); // Blue
      case 'PUT':
        return colors.warning;
      case 'DELETE':
        return colors.error;
      case 'PATCH':
        return const Color(0xFF7B1FA2); // Purple
      default:
        return colors.outline;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final int? statusCode;
  final bool isError;
  final AppColors colors;
  final AppTypography typography;

  const _StatusBadge({
    required this.statusCode,
    required this.isError,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    final code = statusCode?.toString() ?? '---';
    final badgeColor = isError ? colors.error : colors.success;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s2.h,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: Text(
        code,
        style: typography.labelSmall.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Empty State
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final AppColors colors;
  final AppTypography typography;
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.colors,
    required this.typography,
    required this.hasFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters ? Icons.filter_alt_off_rounded : Icons.dns_rounded,
              size: 64,
              color: colors.outline.withValues(alpha: 0.3),
            ),
            SizedBox(height: AppSpacing.s16.h),
            Text(
              hasFilters ? 'Tidak ada log yang cocok' : 'Belum ada log',
              style: typography.titleMedium.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: AppSpacing.s8.h),
            Text(
              hasFilters
                  ? 'Coba ubah filter atau hapus filter'
                  : 'Log request/response akan muncul di sini setelah aplikasi melakukan API call',
              style: typography.bodySmall.copyWith(color: colors.outline),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              SizedBox(height: AppSpacing.s16.h),
              TextButton(
                onPressed: onClearFilters,
                child: Text(
                  'Hapus Semua Filter',
                  style: typography.labelLarge.copyWith(color: colors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
