import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/submission_item.dart';
import '../../data/models/submission_type.dart';
import 'widgets/submission_type_info_card.dart';

class SubmissionDetailPage extends StatelessWidget {
  final SubmissionItem item;
  final SubmissionType type;

  const SubmissionDetailPage({
    super.key,
    required this.item,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Detail Pengajuan',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s16.w,
          AppSpacing.s16.h,
          AppSpacing.s16.w,
          AppSpacing.s32.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Banner ────────────────────────────────────────
            _StatusBanner(item: item, colors: colors, typography: typography),
            SizedBox(height: AppSpacing.s16.h),

            // ── Informasi Pengajuan ──────────────────────────────────
            AppCard(
              outlined: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    'Informasi Pengajuan',
                    colors: colors,
                    typography: typography,
                  ),
                  SizedBox(height: AppSpacing.s12.h),
                  _DetailRow(
                    icon: Icons.title_rounded,
                    label: 'Judul',
                    value: item.title,
                    colors: colors,
                    typography: typography,
                  ),
                  SizedBox(height: AppSpacing.s12.h),
                  _DetailRow(
                    icon: Icons.notes_rounded,
                    label: 'Deskripsi',
                    value: item.description,
                    colors: colors,
                    typography: typography,
                    multiLine: true,
                  ),
                  SizedBox(height: AppSpacing.s12.h),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Tanggal',
                    value: item.formattedDate,
                    colors: colors,
                    typography: typography,
                  ),
                  if (item.startTime != null) ...[
                    SizedBox(height: AppSpacing.s12.h),
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Waktu',
                      value: _formatTimeRange(item),
                      colors: colors,
                      typography: typography,
                    ),
                  ],
                  SizedBox(height: AppSpacing.s12.h),
                  _DetailRow(
                    icon: Icons.folder_rounded,
                    label: 'Jenis',
                    value: item.typeName,
                    colors: colors,
                    typography: typography,
                  ),
                  SizedBox(height: AppSpacing.s12.h),
                  _DetailRow(
                    icon: Icons.schedule_rounded,
                    label: 'Tanggal Pengajuan',
                    value: _formatDateTime(item.createdAt),
                    colors: colors,
                    typography: typography,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.s12.h),

            // ── Keterangan Persetujuan (jika ada) ───────────────────
            if (item.approvalNote != null &&
                item.status != SubmissionStatus.pending)
              _ApprovalNoteCard(item: item, colors: colors, typography: typography),

            // ── Lampiran ─────────────────────────────────────────────
            if (item.attachmentNames.isNotEmpty) ...[
              SizedBox(height: AppSpacing.s12.h),
              _AttachmentCard(
                attachmentNames: item.attachmentNames,
                colors: colors,
                typography: typography,
              ),
            ],

            // ── Informasi Jenis Pengajuan ────────────────────────────
            SizedBox(height: AppSpacing.s12.h),
            SubmissionTypeInfoCard(type: type),
          ],
        ),
      ),
    );
  }

  String _formatTimeRange(SubmissionItem item) {
    if (item.startTime == null) return '-';
    final start = item.startTime!;
    if (item.endTime == null) return start;
    return '$start – ${item.endTime!}';
  }

  static String _formatDateTime(DateTime d) {
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final time = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

// ── Status Banner ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final SubmissionItem item;
  final AppColors colors;
  final AppTypography typography;

  const _StatusBanner({
    required this.item,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, icon, label) = switch (item.status) {
      SubmissionStatus.draft => (
          colors.primary.withValues(alpha: 0.12),
          colors.primary,
          Icons.edit_note_rounded,
          'Draft Pengajuan',
        ),
      SubmissionStatus.pending => (
          colors.warning.withValues(alpha: 0.12),
          colors.warning,
          Icons.hourglass_empty_rounded,
          'Menunggu Persetujuan',
        ),
      SubmissionStatus.approved => (
          colors.success.withValues(alpha: 0.12),
          colors.success,
          Icons.check_circle_rounded,
          'Pengajuan Disetujui',
        ),
      SubmissionStatus.rejected => (
          colors.error.withValues(alpha: 0.12),
          colors.error,
          Icons.cancel_rounded,
          'Pengajuan Ditolak',
        ),
      SubmissionStatus.cancelled => (
          colors.onSurface.withValues(alpha: 0.12),
          colors.onSurface.withValues(alpha: 0.7),
          Icons.block_rounded,
          'Pengajuan Dibatalkan',
        ),
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.s20.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: textColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: textColor),
          SizedBox(height: AppSpacing.s8.h),
          Text(
            label,
            style: typography.titleMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.s4.h),
          Text(
            'Diajukan pada ${_fmtDate(item.createdAt)}',
            style: typography.bodySmall.copyWith(
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Approval Note Card ───────────────────────────────────────────────────────

class _ApprovalNoteCard extends StatelessWidget {
  final SubmissionItem item;
  final AppColors colors;
  final AppTypography typography;

  const _ApprovalNoteCard({
    required this.item,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = item.status == SubmissionStatus.approved;
    final accentColor = isApproved ? colors.success : colors.error;
    final icon = isApproved ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded;
    final title = isApproved ? 'Keterangan Persetujuan' : 'Alasan Penolakan';

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              SizedBox(width: AppSpacing.s8.w),
              Text(
                title,
                style: typography.titleSmall.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.s12.w),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Text(
              item.approvalNote!,
              style: typography.bodyMedium.copyWith(
                color: colors.onSurface.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Attachment Card ──────────────────────────────────────────────────────────

class _AttachmentCard extends StatelessWidget {
  final List<String> attachmentNames;
  final AppColors colors;
  final AppTypography typography;

  const _AttachmentCard({
    required this.attachmentNames,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      outlined: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Lampiran', colors: colors, typography: typography),
          SizedBox(height: AppSpacing.s12.h),
          ...attachmentNames.map(
            (name) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  Expanded(
                    child: Text(
                      name,
                      style: typography.bodySmall.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'PDF',
                      style: typography.labelSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final AppColors colors;
  final AppTypography typography;

  const _SectionTitle(this.text, {required this.colors, required this.typography});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16.h,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        SizedBox(width: AppSpacing.s8.w),
        Text(
          text,
          style: typography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiLine;
  final AppColors colors;
  final AppTypography typography;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    required this.typography,
    this.multiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: colors.primary.withValues(alpha: 0.7)),
        SizedBox(width: AppSpacing.s8.w),
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: typography.bodySmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.s8.w),
        Expanded(
          child: Text(
            value,
            style: typography.bodySmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
