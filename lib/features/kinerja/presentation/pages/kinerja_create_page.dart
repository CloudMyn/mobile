import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_dropdown.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/activity_item.dart';
import '../../data/models/activity_type.dart';
import '../../data/services/kinerja_service.dart';
import '../controllers/kinerja_form_controller.dart';
import 'widgets/image_picker_field.dart';

class KinerjaCreatePage extends StatelessWidget {
  /// Jika null → mode create, jika tidak null → mode edit.
  final ActivityItem? item;

  const KinerjaCreatePage({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    final tag = item != null ? 'kinerja_edit_${item!.id}' : 'kinerja_create';
    final ctrl = Get.put(
      KinerjaFormController(
        service: Get.find<KinerjaService>(),
        initialItem: item,
      ),
      tag: tag,
    );

    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final isEdit = item != null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: isEdit ? 'Edit Kinerja' : 'Buat Kinerja',
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
              // ── Jenis Kegiatan ─────────────────────────────
              Obx(() {
                final isLoading = ctrl.isLoadingTypes.value;
                final types = ctrl.types;
                final error = ctrl.errorTypes.value;

                if (!isLoading && types.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jenis Kegiatan',
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.s8.h),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.s12.w),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.1),
                          border: Border.all(color: colors.error.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(AppRadius.r8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: colors.error, size: 20),
                            SizedBox(width: AppSpacing.s8.w),
                            Expanded(
                              child: Text(
                                error ?? 'Gagal memuat jenis kegiatan atau data kosong.',
                                style: typography.bodySmall.copyWith(color: colors.error),
                              ),
                            ),
                            TextButton(
                              onPressed: () => ctrl.loadTypes(),
                              style: TextButton.styleFrom(
                                foregroundColor: colors.primary,
                                textStyle: typography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8.w),
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return AppDropdown<ActivityType>(
                  label: 'Jenis Kegiatan',
                  hint: isLoading ? 'Memuat jenis kegiatan...' : 'Pilih jenis kegiatan',
                  value: ctrl.selectedType.value,
                  items: isLoading
                      ? []
                      : types
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t.name)))
                          .toList(),
                  onChanged: isLoading ? null : (t) {
                    if (t != null) ctrl.selectType(t);
                  },
                  validator: (_) =>
                      ctrl.selectedType.value == null ? 'Wajib dipilih' : null,
                );
              }),
              SizedBox(height: AppSpacing.s16.h),

              // ── Tanggal Kegiatan ───────────────────────────
              AppTextField(
                label: 'Tanggal Kegiatan',
                hint: 'Pilih tanggal kegiatan',
                controller: ctrl.dateCtrl,
                readOnly: true,
                suffixIcon: const Icon(Icons.calendar_today_rounded),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: ctrl.selectedDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    ctrl.selectDate(picked);
                  }
                },
              ),
              SizedBox(height: AppSpacing.s16.h),

              // ── Jam Mulai & Jam Selesai ──────────────────────
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Jam Mulai',
                      hint: 'Pilih jam mulai',
                      controller: ctrl.startTimeCtrl,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.access_time_rounded),
                      onTap: () async {
                        final parts = ctrl.startTimeCtrl.text.split(':');
                        TimeOfDay initialTime = TimeOfDay.now();
                        if (parts.length == 2) {
                          initialTime = TimeOfDay(
                            hour: int.tryParse(parts[0]) ?? initialTime.hour,
                            minute: int.tryParse(parts[1]) ?? initialTime.minute,
                          );
                        }
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: initialTime,
                        );
                        if (picked != null) {
                          final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                          ctrl.startTimeCtrl.text = formatted;
                        }
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.s16.w),
                  Expanded(
                    child: AppTextField(
                      label: 'Jam Selesai',
                      hint: 'Pilih jam selesai',
                      controller: ctrl.endTimeCtrl,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.access_time_rounded),
                      onTap: () async {
                        final parts = ctrl.endTimeCtrl.text.split(':');
                        TimeOfDay initialTime = TimeOfDay.now();
                        if (parts.length == 2) {
                          initialTime = TimeOfDay(
                            hour: int.tryParse(parts[0]) ?? initialTime.hour,
                            minute: int.tryParse(parts[1]) ?? initialTime.minute,
                          );
                        }
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: initialTime,
                        );
                        if (picked != null) {
                          final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                          ctrl.endTimeCtrl.text = formatted;
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s16.h),

              // ── Status Kegiatan ─────────────────────────────
              Obx(() {
                return AppDropdown<String>(
                  label: 'Status Kegiatan',
                  hint: 'Pilih status kegiatan',
                  value: ctrl.selectedStatus.value,
                  items: const [
                    DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                    DropdownMenuItem(value: 'Belum Selesai', child: Text('Belum Selesai')),
                  ],
                  onChanged: (status) {
                    if (status != null) ctrl.selectStatus(status);
                  },
                  validator: (_) =>
                      ctrl.selectedStatus.value == null ? 'Status wajib dipilih' : null,
                );
              }),
              SizedBox(height: AppSpacing.s16.h),

              // ── Deskripsi ──────────────────────────────────
              AppTextField(
                label: 'Deskripsi Kegiatan',
                hint: 'Jelaskan kegiatan kinerja yang dilakukan',
                controller: ctrl.descriptionCtrl,
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  if (v.trim().length < 10) {
                    return 'Deskripsi minimal 10 karakter';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.s20.h),

              // ── Upload Gambar ──────────────────────────────
              Obx(
                () => ImagePickerField(
                  imagePath: ctrl.originalImagePath.value,
                  onImagePicked: (path) => ctrl.pickAndCompressImage(path),
                  onRemove: () => ctrl.removeImage(),
                ),
              ),

              // ── Loading kompresi ───────────────────────────
              Obx(() {
                if (!ctrl.isCompressing.value) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: AppSpacing.s12.h),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.s8.w),
                      Text(
                        'Mengompresi gambar...',
                        style: typography.bodySmall.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              SizedBox(height: AppSpacing.s24.h),

              // ── Tombol Submit ──────────────────────────────
              Obx(
                () => AppButton(
                  label: isEdit ? 'Simpan Perubahan' : 'Simpan Kinerja',
                  onPressed:
                      (ctrl.isLoading.value || ctrl.isCompressing.value)
                          ? null
                          : ctrl.submit,
                  isLoading: ctrl.isLoading.value,
                  fullWidth: true,
                  icon: Icons.save_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
