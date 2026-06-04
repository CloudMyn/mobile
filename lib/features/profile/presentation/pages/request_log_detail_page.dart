import 'dart:convert';

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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(
          color: entry.isError
              ? colors.error.withValues(alpha: 0.3)
              : colors.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method + Status Code
          Row(
            children: [
              _buildMethodTag(),
              SizedBox(width: AppSpacing.s8.w),
              _buildStatusTag(),
              const Spacer(),
              // Duration
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8.w,
                  vertical: AppSpacing.s4.h,
                ),
                decoration: BoxDecoration(
                  color: _durationColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: _durationColor),
                    SizedBox(width: AppSpacing.s4.w),
                    Text(
                      '${entry.durationMs}ms',
                      style: typography.labelSmall.copyWith(
                        color: _durationColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s12.h),

          // URL
          Text(
            'URL',
            style: typography.labelSmall.copyWith(
              color: colors.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s4.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.s10.w),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: SelectableText(
              entry.url,
              style: typography.bodySmall.copyWith(
                color: colors.onSurface,
                fontFamily: 'monospace',
              ),
            ),
          ),
          SizedBox(height: AppSpacing.s12.h),

          // Info grid
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Timestamp',
                  value: _formatDateTime(entry.timestamp),
                  icon: Icons.access_time,
                  colors: colors,
                  typography: typography,
                ),
              ),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: _InfoTile(
                  label: 'Request Size',
                  value: RequestLogEntry.formatBytes(entry.requestSize),
                  icon: Icons.arrow_upward_rounded,
                  colors: colors,
                  typography: typography,
                ),
              ),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: _InfoTile(
                  label: 'Response Size',
                  value: RequestLogEntry.formatBytes(entry.responseSize),
                  icon: Icons.arrow_downward_rounded,
                  colors: colors,
                  typography: typography,
                ),
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
        horizontal: AppSpacing.s10.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.r4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        entry.method,
        style: typography.labelMedium.copyWith(
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
        horizontal: AppSpacing.s10.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.r4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        code,
        style: typography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
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

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final AppColors colors;
  final AppTypography typography;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s8.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: colors.outline),
              SizedBox(width: AppSpacing.s4.w),
              Flexible(
                child: Text(
                  label,
                  style: typography.labelSmall.copyWith(
                    color: colors.outline,
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s2.h),
          Text(
            value,
            style: typography.labelSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
