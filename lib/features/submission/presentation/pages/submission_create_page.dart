import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_dropdown.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/submission_controller.dart';
import '../controllers/submission_form_controller.dart';
import '../../data/models/submission_type.dart';
import '../../data/services/submission_service.dart';
import 'widgets/attachment_upload_field.dart';
import 'widgets/submission_type_info_card.dart';

class SubmissionCreatePage extends StatelessWidget {
  const SubmissionCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      SubmissionFormController(service: Get.find<SubmissionService>()),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ctrl.selectedType.value == null &&
          Get.isRegistered<SubmissionController>()) {
        final type = Get.find<SubmissionController>().currentType;
        if (type != null) ctrl.selectType(type);
      }
    });

    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Buat Pengajuan',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: Form(
        key: ctrl.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s16.w,
            AppSpacing.s16.h,
            AppSpacing.s16.w,
            AppSpacing.s32.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Pilih jenis pengajuan ────────────────────────────────
              Obx(() {
                final types = Get.isRegistered<SubmissionController>()
                    ? Get.find<SubmissionController>().types
                    : <SubmissionType>[].obs;
                return AppDropdown<SubmissionType>(
                  label: 'Jenis Pengajuan',
                  hint: 'Pilih jenis pengajuan',
                  value: ctrl.selectedType.value,
                  items: types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                      .toList(),
                  onChanged: (t) {
                    if (t != null) ctrl.selectType(t);
                  },
                  validator: (_) =>
                      ctrl.selectedType.value == null ? 'Wajib dipilih' : null,
                );
              }),
              SizedBox(height: AppSpacing.s16.h),

              // ── Info card tipe pengajuan ─────────────────────────────
              Obx(() {
                final type = ctrl.selectedType.value;
                if (type == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    SubmissionTypeInfoCard(type: type),
                    SizedBox(height: AppSpacing.s16.h),
                  ],
                );
              }),

              // ── Judul ────────────────────────────────────────────────
              AppTextField(
                label: 'Judul',
                hint: 'Masukkan judul pengajuan',
                controller: ctrl.titleCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
              ),
              SizedBox(height: AppSpacing.s16.h),

              // ── Deskripsi ────────────────────────────────────────────
              AppTextField(
                label: 'Deskripsi',
                hint: 'Jelaskan alasan atau keterangan pengajuan',
                controller: ctrl.descCtrl,
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Deskripsi wajib diisi' : null,
              ),
              SizedBox(height: AppSpacing.s20.h),

              // ── Seksi Tanggal ────────────────────────────────────────
              _DateSection(ctrl: ctrl, colors: colors, typography: typography),
              SizedBox(height: AppSpacing.s20.h),

              // ── Seksi Waktu (muncul hanya jika tipe mengizinkan) ─────
              Obx(() {
                if (!ctrl.requiresTimeRange) return const SizedBox.shrink();
                return Column(
                  children: [
                    _TimeSection(
                      ctrl: ctrl,
                      colors: colors,
                      typography: typography,
                    ),
                    SizedBox(height: AppSpacing.s20.h),
                  ],
                );
              }),

              // ── Info maks hari ───────────────────────────────────────
              Obx(() {
                final type = ctrl.selectedType.value;
                if (type == null || type.maxDaysPerRequest == null || !type.requiresDateRange) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.s20.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                      SizedBox(width: AppSpacing.s4.w),
                      Text(
                        'Maksimal ${type.maxDaysPerRequest} hari untuk jenis pengajuan ini',
                        style: typography.bodySmall.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // ── Lampiran dinamis ─────────────────────────────────────
              Obx(() {
                final type = ctrl.selectedType.value;
                if (type == null || type.attachmentFields.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lampiran',
                      style: typography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s8.h),
                    ...type.attachmentFields.map(
                      (field) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
                        child: Obx(
                          () => AttachmentUploadField(
                            fieldName: field.name,
                            isRequired: field.isRequired,
                            allowedExtensions: field.allowedExtensions,
                            maxFileSizeKb: field.maxFileSizeKb,
                            fileName: ctrl.attachments[field.id],
                            onPick: () => ctrl.pickFile(field.id),
                            onRemove: () => ctrl.removeFile(field.id),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.s12.h),
                  ],
                );
              }),

              // ── Tombol submit ────────────────────────────────────────
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Simpan Draft',
                        onPressed: ctrl.isLoading.value ? null : () => ctrl.submit(autoSubmit: false),
                        isLoading: ctrl.isLoading.value,
                        style: AppButtonStyle.outlined,
                        icon: Icons.save_rounded,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s12.w),
                    Expanded(
                      child: AppButton(
                        label: 'Ajukan',
                        onPressed: ctrl.isLoading.value ? null : () => ctrl.submit(autoSubmit: true),
                        isLoading: ctrl.isLoading.value,
                        icon: Icons.send_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Date Section ────────────────────────────────────────────────────────────

class _DateSection extends StatelessWidget {
  final SubmissionFormController ctrl;
  final AppColors colors;
  final AppTypography typography;

  const _DateSection({
    required this.ctrl,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final requiresDateRange = ctrl.requiresDateRange;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tanggal',
            style: typography.titleSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s8.h),
          if (!requiresDateRange)
            AppTextField(
              label: 'Tanggal Pengajuan',
              hint: 'Pilih tanggal',
              readOnly: true,
              controller: ctrl.startDateDisplayCtrl,
              onTap: () => ctrl.pickDate(context, isStart: true),
              suffixIcon: const Icon(Icons.calendar_month_rounded),
              validator: (_) =>
                  ctrl.startDate.value == null ? 'Tanggal wajib diisi' : null,
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Mulai',
                    hint: 'Pilih tanggal',
                    readOnly: true,
                    controller: ctrl.startDateDisplayCtrl,
                    onTap: () => ctrl.pickDate(context, isStart: true),
                    suffixIcon: const Icon(Icons.calendar_month_rounded),
                    validator: (_) =>
                        ctrl.startDate.value == null ? 'Wajib diisi' : null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 36.h,
                    left: AppSpacing.s8.w,
                    right: AppSpacing.s8.w,
                  ),
                  child: Text(
                    '–',
                    style: typography.titleMedium.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Expanded(
                  child: AppTextField(
                    label: 'Selesai',
                    hint: 'Pilih tanggal',
                    readOnly: true,
                    controller: ctrl.endDateDisplayCtrl,
                    onTap: () => ctrl.pickDate(context, isStart: false),
                    suffixIcon: const Icon(Icons.calendar_month_rounded),
                    validator: (_) =>
                        ctrl.endDate.value == null ? 'Wajib diisi' : null,
                  ),
                ),
              ],
            ),
        ],
      );
    });
  }
}

// ── Time Section ────────────────────────────────────────────────────────────

class _TimeSection extends StatelessWidget {
  final SubmissionFormController ctrl;
  final AppColors colors;
  final AppTypography typography;

  const _TimeSection({
    required this.ctrl,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final requiresTimeRange = ctrl.requiresTimeRange;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waktu',
            style: typography.titleSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (requiresTimeRange) ...[
            SizedBox(height: AppSpacing.s8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Jam Mulai',
                    hint: '08:00',
                    readOnly: true,
                    controller: ctrl.startTimeDisplayCtrl,
                    onTap: () => ctrl.pickTime(context, isStart: true),
                    suffixIcon: const Icon(Icons.access_time_rounded),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 36.h,
                    left: AppSpacing.s8.w,
                    right: AppSpacing.s8.w,
                  ),
                  child: Text(
                    '–',
                    style: typography.titleMedium.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Expanded(
                  child: AppTextField(
                    label: 'Jam Selesai',
                    hint: '17:00',
                    readOnly: true,
                    controller: ctrl.endTimeDisplayCtrl,
                    onTap: () => ctrl.pickTime(context, isStart: false),
                    suffixIcon: const Icon(Icons.access_time_rounded),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}
