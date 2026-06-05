import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/subordinate_submission_item.dart';
import '../../data/models/submission_item.dart';
import '../controllers/subordinate_submission_controller.dart';
import '../controllers/submission_controller.dart';
import 'widgets/submission_type_info_card.dart';

class SubordinateSubmissionDetailPage extends StatelessWidget {
  final SubordinateSubmissionItem item;

  const SubordinateSubmissionDetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final controller = Get.find<SubordinateSubmissionController>();
    
    // Find matching SubmissionType to show the info card if available
    final submissionCtrl = Get.find<SubmissionController>();
    final type = submissionCtrl.types.firstWhereOrNull((t) => t.id == item.typeId);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Detail Pengajuan Bawahan',
        variant: AppTopAppBarVariant.withBack,
        elevation: 0,
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
            // ── Profile Bawahan Card ─────────────────────────────────
            _buildProfileCard(colors, typography),
            SizedBox(height: AppSpacing.s16.h),

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
                    value: item.title.isNotEmpty ? item.title : '-',
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
                      value: '${item.startTime!} – ${item.endTime ?? ""}',
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

            // ── Catatan Persetujuan / Alasan Penolakan ───────────────
            if (item.approvalNote != null && item.status != SubmissionStatus.pending) ...[
              SizedBox(height: AppSpacing.s12.h),
              _ApprovalNoteCard(item: item, colors: colors, typography: typography),
            ],

            // ── Lampiran ─────────────────────────────────────────────
            if (item.attachments.isNotEmpty) ...[
              SizedBox(height: AppSpacing.s12.h),
              _buildAttachmentCard(colors, typography),
            ],

            // ── Informasi Ketentuan Jenis Pengajuan ──────────────────
            if (type != null) ...[
              SizedBox(height: AppSpacing.s12.h),
              SubmissionTypeInfoCard(type: type),
            ],
          ],
        ),
      ),
      bottomNavigationBar: item.status == SubmissionStatus.pending
          ? _buildBottomActionButtons(context, controller, colors, typography)
          : null,
    );
  }

  Widget _buildProfileCard(AppColors colors, AppTypography typography) {
    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              item.subordinateAvatar,
              style: typography.titleMedium.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subordinateName,
                  style: typography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'NIP. ${item.subordinateNip}',
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Pegawai Bawahan',
                  style: typography.caption.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard(AppColors colors, AppTypography typography) {
    return AppCard(
      outlined: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Lampiran', colors: colors, typography: typography),
          SizedBox(height: AppSpacing.s12.h),
          ...item.attachments.map(
            (att) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
              child: InkWell(
                onTap: () {
                  Get.snackbar(
                    'Membuka Lampiran',
                    'Membuka ${att.fileName}...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                borderRadius: BorderRadius.circular(AppRadius.r8),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file_rounded,
                        size: 18,
                        color: colors.primary,
                      ),
                      SizedBox(width: AppSpacing.s8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              att.fileName,
                              style: typography.bodySmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (att.fileSizeKb != null)
                              Text(
                                '${att.fileSizeKb} KB',
                                style: typography.caption.copyWith(
                                  color: colors.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                          ],
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
                          att.extensionLabel,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons(
    BuildContext context,
    SubordinateSubmissionController controller,
    AppColors colors,
    AppTypography typography,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s16.w,
        vertical: AppSpacing.s12.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showRejectDialog(context, controller, colors, typography),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                  ),
                ),
                child: Text(
                  'Tolak',
                  style: typography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.s12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showApproveDialog(context, controller, colors, typography),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.success,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Setujui',
                  style: typography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(
    BuildContext context,
    SubordinateSubmissionController controller,
    AppColors colors,
    AppTypography typography,
  ) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Setujui Pengajuan',
          style: typography.titleMedium.copyWith(
            color: colors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menyetujui pengajuan dari ${item.subordinateName}?',
              style: typography.bodyMedium.copyWith(color: colors.onSurface),
            ),
            SizedBox(height: AppSpacing.s16.h),
            AppTextField(
              controller: noteController,
              label: 'Catatan Persetujuan (Opsional)',
              hint: 'Masukkan catatan...',
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: typography.labelLarge.copyWith(color: colors.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.approve(item.id, noteController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.success),
            child: Text('Setujui', style: typography.labelLarge.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    SubordinateSubmissionController controller,
    AppColors colors,
    AppTypography typography,
  ) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Tolak Pengajuan',
          style: typography.titleMedium.copyWith(
            color: colors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Silakan masukkan alasan penolakan pengajuan dari ${item.subordinateName}.',
                style: typography.bodyMedium.copyWith(color: colors.onSurface),
              ),
              SizedBox(height: AppSpacing.s16.h),
              AppTextField(
                controller: reasonController,
                label: 'Alasan Penolakan (Wajib)',
                hint: 'Masukkan alasan...',
                maxLines: 2,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Alasan penolakan wajib diisi';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: typography.labelLarge.copyWith(color: colors.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop();
                controller.reject(item.id, reasonController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.error),
            child: Text('Tolak', style: typography.labelLarge.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime d) {
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final time = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

class _StatusBanner extends StatelessWidget {
  final SubordinateSubmissionItem item;
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
      _ => (
          colors.outline.withValues(alpha: 0.12),
          colors.outline,
          Icons.info_rounded,
          'Status Tidak Diketahui',
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

class _ApprovalNoteCard extends StatelessWidget {
  final SubordinateSubmissionItem item;
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
              item.approvalNote ?? (isApproved ? 'Disetujui tanpa catatan.' : 'Ditolak.'),
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
