import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/profile_controller.dart';

class UpdateEmployeePage extends StatelessWidget {
  const UpdateEmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final emp = ctrl.employee.value;

    final nipCtrl = TextEditingController(text: emp?.nip ?? '');
    final jabatanCtrl = TextEditingController(text: emp?.position ?? '');
    final unitCtrl = TextEditingController(text: emp?.unit ?? '');

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Data Pegawai',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s16.w,
          vertical: AppSpacing.s16.h,
        ),
        child: Form(
          key: ctrl.formKeyEmployee,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('Identitas', colors, typography),
              AppTextField(
                label: 'NIP',
                hint: 'Nomor Induk Pegawai',
                controller: nipCtrl,
                readOnly: true,
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              SizedBox(height: AppSpacing.s16.h),
              AppTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                controller: ctrl.namaCtrl,
                prefixIcon: const Icon(Icons.person_outline_rounded),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: AppSpacing.s16.h),
              AppTextField(
                label: 'Jabatan',
                hint: 'Jabatan pegawai',
                controller: jabatanCtrl,
                readOnly: true,
                prefixIcon: const Icon(Icons.work_outline_rounded),
              ),
              SizedBox(height: AppSpacing.s16.h),
              AppTextField(
                label: 'Unit Kerja',
                hint: 'Unit/OPD',
                controller: unitCtrl,
                readOnly: true,
                prefixIcon: const Icon(Icons.apartment_rounded),
              ),
              SizedBox(height: AppSpacing.s24.h),
              _SectionLabel('Kontak', colors, typography),
              AppTextField(
                label: 'Email',
                hint: 'Alamat email aktif',
                controller: ctrl.emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                  if (!v.contains('@')) return 'Format email tidak valid';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: AppSpacing.s16.h),
              AppTextField(
                label: 'Nomor HP',
                hint: 'Contoh: 08123456789',
                controller: ctrl.phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: AppSpacing.s16.h),
              AppTextField(
                label: 'Alamat',
                hint: 'Alamat lengkap',
                controller: ctrl.alamatCtrl,
                maxLines: 3,
                prefixIcon: const Icon(Icons.location_on_outlined),
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: AppSpacing.s32.h),
              Obx(() => AppButton(
                    label: 'Simpan Perubahan',
                    fullWidth: true,
                    icon: Icons.save_rounded,
                    isLoading: ctrl.isUpdatingEmployee.value,
                    onPressed: ctrl.updateEmployeeData,
                  )),
              SizedBox(height: AppSpacing.s32.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final AppColors colors;
  final AppTypography typography;

  const _SectionLabel(this.label, this.colors, this.typography);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s12.h),
      child: Text(
        label,
        style: typography.titleSmall.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
