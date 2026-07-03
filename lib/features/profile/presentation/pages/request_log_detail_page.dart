import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/logging/request_log_entry.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/request_log_controller.dart';

/// Halaman detail satu log entry — menampilkan full request/response.
class RequestLogDetailPage extends StatelessWidget {
  const RequestLogDetailPage({super.key, required this.entry});

  final RequestLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Log Detail',
        variant: AppTopAppBarVariant.withBack,
        actions: [
          IconButton(
            icon: Icon(Icons.copy_rounded, color: colors.primary),
            tooltip: 'Copy to Clipboard',
            onPressed: () {
              Get.find<RequestLogController>().copyLogToClipboard(entry);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary Card ──────────────────────────────────────────────
            _SummaryCard(entry: entry, colors: colors, typography: typography),
            SizedBox(height: AppSpacing.s16.h),

            // ── Request Headers ───────────────────────────────────────────
            if (entry.requestHeaders != null &&
                entry.requestHeaders!.isNotEmpty)
              _JsonSection(
                title: 'Request Headers',
                icon: Icons.arrow_upward_rounded,
                iconColor: const Color(0xFF1976D2),
                jsonStr: entry.requestHeaders!,
                colors: colors,
                typography: typography,
              ),

            // ── Request Body ──────────────────────────────────────────────
            if (entry.requestBody != null && entry.requestBody!.isNotEmpty) ...[
              SizedBox(height: AppSpacing.s12.h),
              _JsonSection(
                title: 'Request Body',
                icon: Icons.upload_rounded,
                iconColor: colors.warning,
                jsonStr: entry.requestBody!,
                colors: colors,
                typography: typography,
              ),
            ],

            // ── Response Body ─────────────────────────────────────────────
            if (entry.responseBody != null &&
                entry.responseBody!.isNotEmpty) ...[
              SizedBox(height: AppSpacing.s12.h),
              _JsonSection(
                title: 'Response Body',
                icon: Icons.download_rounded,
                iconColor: entry.isError ? colors.error : colors.success,
                jsonStr: entry.responseBody!,
                colors: colors,
                typography: typography,
              ),
            ],

            SizedBox(height: AppSpacing.s32.h),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Summary Card
// ═══════════════════════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  final RequestLogEntry entry;
  final AppColors colors;
  final AppTypography typography;

  const _SummaryCard({
    required this.entry,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Method, Status, Duration & Status Icon
          Row(
            children: [
              _buildMethodTag(),
              SizedBox(width: AppSpacing.s8.w),
              _buildStatusTag(),
              SizedBox(width: AppSpacing.s8.w),
              _buildDurationTag(),
              const Spacer(),
              Icon(
                entry.isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                color: entry.isError ? colors.error : colors.success,
                size: 20.w,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s12.h),

          // Row 2: URL
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s10.w, vertical: AppSpacing.s8.h),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(AppRadius.r8),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.05),
              ),
            ),
            child: SelectableText(
              entry.url,
              style: typography.bodySmall.copyWith(
                color: colors.onSurface,
                fontFamily: 'monospace',
                fontSize: 11.sp,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.s12.h),

          // Row 3: Metadata (Compact horizontal row)
          Row(
            children: [
              // Timestamp
              _buildMetaItem(
                icon: Icons.access_time_rounded,
                value: _formatDateTime(entry.timestamp),
              ),
              const Spacer(),
              // Request Size
              _buildMetaItem(
                icon: Icons.arrow_upward_rounded,
                value: RequestLogEntry.formatBytes(entry.requestSize),
              ),
              SizedBox(width: AppSpacing.s12.w),
              // Response Size
              _buildMetaItem(
                icon: Icons.arrow_downward_rounded,
                value: RequestLogEntry.formatBytes(entry.responseSize),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTag() {
    Color color;
    switch (entry.method.toUpperCase()) {
      case 'GET':
        color = colors.success;
        break;
      case 'POST':
        color = const Color(0xFF1976D2);
        break;
      case 'PUT':
        color = colors.warning;
        break;
      case 'DELETE':
        color = colors.error;
        break;
      default:
        color = colors.outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s2.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: Text(
        entry.method,
        style: typography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusTag() {
    final code = entry.statusCode?.toString() ?? '---';
    final color = entry.isError ? colors.error : colors.success;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s2.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: Text(
        code,
        style: typography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDurationTag() {
    final color = _durationColor;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s2.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 12.w, color: color),
          SizedBox(width: AppSpacing.s4.w),
          Text(
            '${entry.durationMs}ms',
            style: typography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem({required IconData icon, required String value}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.w, color: colors.outline),
        SizedBox(width: AppSpacing.s4.w),
        Text(
          value,
          style: typography.labelSmall.copyWith(
            color: colors.onSurface.withValues(alpha: 0.6),
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Color get _durationColor {
    if (entry.durationMs < 300) return colors.success;
    if (entry.durationMs < 1000) return colors.warning;
    return colors.error;
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// JSON Section (Collapsible)
// ═══════════════════════════════════════════════════════════════════════════════

class _JsonSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String jsonStr;
  final AppColors colors;
  final AppTypography typography;

  const _JsonSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.jsonStr,
    required this.colors,
    required this.typography,
  });

  @override
  State<_JsonSection> createState() => _JsonSectionState();
}

class _JsonSectionState extends State<_JsonSection> {
  bool _expanded = true;

  String get _prettyJson {
    try {
      final decoded = jsonDecode(widget.jsonStr);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return widget.jsonStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(
          color: widget.colors.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          // Header (tappable)
          InkWell(
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(AppRadius.r12),
              bottom: Radius.circular(_expanded ? 0 : AppRadius.r12),
            ),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s12.w),
              child: Row(
                children: [
                  Icon(widget.icon, size: 18, color: widget.iconColor),
                  SizedBox(width: AppSpacing.s8.w),
                  Text(
                    widget.title,
                    style: widget.typography.labelLarge.copyWith(
                      color: widget.colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: widget.colors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body
          if (_expanded) ...[
            Divider(
              height: 1,
              color: widget.colors.outline.withValues(alpha: 0.1),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.s12.w),
              child: SelectableText(
                _prettyJson,
                style: widget.typography.bodySmall.copyWith(
                  fontFamily: 'monospace',
                  color: widget.colors.onSurface,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
