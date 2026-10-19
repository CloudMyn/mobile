import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../data/models/activity_item.dart';
import '../../data/services/kinerja_service.dart';
import '../controllers/kinerja_form_controller.dart';

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
                    firstDate: DateTime.now().subtract(const Duration(days: 2)),
                    lastDate: DateTime.now(),
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
                      onTap: () => ctrl.selectStartTime(context),
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
              SizedBox(height: AppSpacing.s24.h),

              // ── Tombol Simpan Draft & Ajukan ──────────────────────────────
              Obx(() {
                final isBusy = ctrl.isLoading.value || ctrl.isCompressing.value;
                return Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: isEdit ? 'Simpan Perubahan' : 'Simpan Draft',
                        onPressed: isBusy ? null : () => ctrl.submit(autoSubmit: false),
                        isLoading: ctrl.isLoading.value,
                        style: AppButtonStyle.outlined,
                        icon: Icons.save_rounded,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s12.w),
                    Expanded(
                      child: AppButton(
                        label: isEdit ? 'Ajukan Sekarang' : 'Ajukan Kinerja',
                        onPressed: isBusy ? null : () => ctrl.submit(autoSubmit: true),
                        isLoading: ctrl.isLoading.value,
                        icon: Icons.send_rounded,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
