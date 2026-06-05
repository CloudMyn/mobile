import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_card.dart';
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

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Data Pegawai',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: Obx(() {
        final emp = ctrl.employee.value;
        final nipCtrl = TextEditingController(text: emp?.nip ?? '');
        final jabatanCtrl = TextEditingController(text: emp?.position ?? '');
        final unitCtrl = TextEditingController(text: emp?.unit ?? '');
        final isHistoricalLocked = !ctrl.canEditHistoricalData;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s16.w,
            vertical: AppSpacing.s16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PageIntro(colors: colors, typography: typography),
              SizedBox(height: AppSpacing.s16.h),
              _SectionLabel('Data Historis', colors, typography),
              SizedBox(height: AppSpacing.s8.h),
              _StatusCard(
                colors: colors,
                typography: typography,
                icon: isHistoricalLocked
                    ? Icons.lock_outline_rounded
                    : Icons.info_outline_rounded,
                title: isHistoricalLocked
                    ? 'Data historis sudah terkunci'
                    : 'Data historis hanya bisa diisi sekali',
                message: isHistoricalLocked
                    ? 'Perubahan nama lengkap, NIP, jabatan, dan unit kerja harus melalui admin atau operator.'
                    : 'Lengkapi data historis sebelum tersimpan. Setelah record data pegawai terbentuk, field ini akan terkunci.',
                tint: isHistoricalLocked
                    ? colors.warning
                    : colors.primary,
              ),
              SizedBox(height: AppSpacing.s8.h),
              AppCard(
                outlined: true,
                child: Form(
                  key: ctrl.formKeyHistorical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        readOnly: isHistoricalLocked,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        validator: ctrl.validateHistoricalFullName,
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
                      if (!isHistoricalLocked) ...[
                        SizedBox(height: AppSpacing.s20.h),
                        Obx(
                          () => AppButton(
                            label: 'Simpan Data Historis',
                            fullWidth: true,
                            icon: Icons.save_rounded,
                            isLoading: ctrl.isSavingHistoricalData.value,
                            onPressed: ctrl.saveHistoricalEmployeeData,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s24.h),
              _SectionLabel('Data Dapat Diubah', colors, typography),
              SizedBox(height: AppSpacing.s8.h),
              _StatusCard(
                colors: colors,
                typography: typography,
                icon: Icons.edit_note_rounded,
                title: 'Kontak dapat diperbarui',
                message:
                    'Nomor HP dan alamat dapat diubah kapan saja. Email hanya ditampilkan dan belum dapat diperbarui dari aplikasi mobile.',
                tint: colors.success,
              ),
              SizedBox(height: AppSpacing.s8.h),
              AppCard(
                outlined: true,
                child: Form(
                  key: ctrl.formKeyContact,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Email',
                        hint: 'Alamat email aktif',
                        controller: ctrl.emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      SizedBox(height: AppSpacing.s8.h),
                      Text(
                        'Email dikelola oleh sistem dan saat ini belum dapat diubah melalui mobile.',
                        style: typography.caption.copyWith(
                          color: colors.outline,
                        ),
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
                      SizedBox(height: AppSpacing.s20.h),
                      Obx(
                        () => AppButton(
                          label: 'Simpan Kontak',
                          fullWidth: true,
                          icon: Icons.save_outlined,
                          isLoading: ctrl.isSavingContactData.value,
                          onPressed: ctrl.saveEditableEmployeeData,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (ctrl.isLoadingEmployeeData.value) ...[
                SizedBox(height: AppSpacing.s16.h),
                Row(
                  children: [
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: AppSpacing.s8.w),
                    Text(
                      'Memuat status data pegawai...',
                      style: typography.caption.copyWith(color: colors.outline),
                    ),
                  ],
                ),
              ],
              SizedBox(height: AppSpacing.s32.h),
            ],
          ),
        );
      }),
    );
  }
}

class _PageIntro extends StatelessWidget {
  final AppColors colors;
  final AppTypography typography;

  const _PageIntro({
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.manage_accounts_rounded,
              color: colors.primary,
              size: 20.w,
            ),
          ),
          SizedBox(width: AppSpacing.s12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelola data pegawai',
                  style: typography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Text(
                  'Bagian historis hanya dapat disimpan sekali, sedangkan data kontak dapat diperbarui kapan saja.',
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final AppColors colors;
  final AppTypography typography;
  final IconData icon;
  final String title;
  final String message;
  final Color tint;

  const _StatusCard({
    required this.colors,
    required this.typography,
    required this.icon,
    required this.title,
    required this.message,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      outlined: true,
      padding: const EdgeInsets.all(AppSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16.w, color: tint),
          ),
          SizedBox(width: AppSpacing.s10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.labelLarge.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Text(
                  message,
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: EdgeInsets.only(bottom: AppSpacing.s4.h),
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
