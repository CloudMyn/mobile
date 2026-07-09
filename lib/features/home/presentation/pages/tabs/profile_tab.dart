import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../design_system/components/app_avatar_badge.dart';
import '../../../../../design_system/components/app_card.dart';
import '../../../../../design_system/components/app_feedback.dart';
import '../../../../../design_system/components/app_list_item.dart';
import '../../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_radius.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';
import '../../../../profile/presentation/controllers/profile_controller.dart';
import '../../../../profile/presentation/controllers/theme_controller.dart';
import '../../../../profile/presentation/pages/face_enrollment_page.dart';
import '../../../../profile/presentation/pages/shift_schedule_page.dart';
import '../../../../profile/presentation/pages/update_employee_page.dart';
import '../../../../profile/presentation/pages/update_password_page.dart';
import '../../../../profile/presentation/pages/update_photo_page.dart';
import '../../../../profile/presentation/pages/request_log_page.dart';
import '../../../../profile/presentation/pages/set_home_location_page.dart';
import '../../../../../core/network/session_manager.dart';
import '../../../../auth/presentation/pages/leader_splash_page.dart';
import '../../../../profile/presentation/pages/supervisor_history_page.dart';
import '../../../../../design_system/components/app_button.dart';
import '../../../../../core/utils/restart_helper.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Profil',
        variant: AppTopAppBarVariant.standard,
      ),
      body: Obx(() {
        if (ctrl.isLoadingProfile.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildContent(context, ctrl, colors, typography);
      }),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProfileController ctrl,
    AppColors colors,
    AppTypography typography,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ctrl.loadProfile(force: true, showLoading: false),
          ctrl.loadEmployeeData(showLoading: false),
          ctrl.loadShifts(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16.w),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(ctrl: ctrl, colors: colors, typography: typography),
          SizedBox(height: AppSpacing.s24.h),
          _SectionLabel(
            label: 'Pengaturan Akun',
            colors: colors,
            typography: typography,
          ),
          SizedBox(height: AppSpacing.s8.h),
          AppCard(
            outlined: true,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AppListItem(
                  title: 'Update Foto Profil',
                  subtitle: 'Ganti foto profil Anda',
                  leading: const Icon(Icons.photo_camera_rounded),
                  showDivider: true,
                  onTap: () => Get.to(() => const UpdatePhotoPage()),
                ),
                AppListItem(
                  title: 'Update Password',
                  subtitle: 'Ubah kata sandi akun',
                  leading: const Icon(Icons.lock_outline_rounded),
                  showDivider: true,
                  onTap: () => Get.to(() => const UpdatePasswordPage()),
                ),
                Obx(() {
                  final session = Get.find<SessionManager>();
                  final user = session.currentUser.value;
                  final hasFace = user?.faceData != null && user!.faceData!.isNotEmpty;
                  return AppListItem(
                    title: hasFace ? 'Pengaturan Wajah' : 'Daftarkan Wajah',
                    subtitle: hasFace ? 'Wajah sudah terdaftar' : 'Untuk absensi dengan Face Recognition',
                    leading: const Icon(Icons.face_retouching_natural_rounded),
                    showDivider: true,
                    onTap: () => Get.to(() => const FaceEnrollmentPage()),
                  );
                }),
                Obx(() {
                  final session = Get.find<SessionManager>();
                  final user = session.currentUser.value;
                  final hasHomeLocation = user?.homeLatitude != null && user?.homeLongitude != null;
                  return AppListItem(
                    title: 'Lokasi Rumah',
                    subtitle: hasHomeLocation
                        ? 'Terdaftar: ${user!.homeLatitude!.toStringAsFixed(5)}, ${user.homeLongitude!.toStringAsFixed(5)}'
                        : 'Belum diatur – diperlukan untuk WFH dari rumah',
                    leading: Icon(
                      Icons.home_work_rounded,
                      color: hasHomeLocation ? null : colors.error,
                    ),
                    trailing: hasHomeLocation
                        ? Icon(Icons.check_circle_rounded, color: colors.success, size: 18)
                        : Icon(Icons.warning_amber_rounded, color: colors.error, size: 18),
                    showDivider: true,
                    onTap: () => Get.to(() => const SetHomeLocationPage()),
                  );
                }),
                AppListItem(
                  title: 'Pembaruan Data Pegawai',
                  subtitle: 'Edit data kontak dan identitas',
                  leading: const Icon(Icons.manage_accounts_rounded),
                  showDivider: true,
                  onTap: () => Get.to(() => const UpdateEmployeePage()),
                ),
                AppListItem(
                  title: 'Menu Atasan',
                  subtitle: 'Riwayat dan pengajuan atasan',
                  leading: const Icon(Icons.supervisor_account_rounded),
                  onTap: () => Get.to(() => const SupervisorHistoryPage()),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.s16.h),
          _SectionLabel(
            label: 'Jadwal & Informasi',
            colors: colors,
            typography: typography,
          ),
          SizedBox(height: AppSpacing.s8.h),
          AppCard(
            outlined: true,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Obx(() {
                  if (!ctrl.canChooseSchedule.value) {
                    return const SizedBox.shrink();
                  }
                  return AppListItem(
                    title: 'Atur Jadwal Shift',
                    subtitle: 'Pilih jadwal shift kerja Anda',
                    leading: const Icon(Icons.schedule_rounded),
                    showDivider: true,
                    onTap: () => Get.to(() => const ShiftSchedulePage()),
                  );
                }),
                AppListItem(
                  title: 'FAQ',
                  subtitle: 'Pertanyaan yang sering diajukan',
                  leading: const Icon(Icons.help_outline_rounded),
                  trailing: Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: colors.outline,
                  ),
                  onTap: _openFaq,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.s16.h),
          _SectionLabel(
            label: 'Tampilan',
            colors: colors,
            typography: typography,
          ),
          SizedBox(height: AppSpacing.s8.h),
          AppCard(
            outlined: true,
            padding: EdgeInsets.zero,
            child: Obx(() {
              final themeCtrl = Get.find<ThemeController>();
              return AppListItem(
                title: 'Mode Gelap',
                subtitle: themeCtrl.isSystemMode
                    ? 'Mengikuti sistem'
                    : (themeCtrl.isDarkMode ? 'Aktif' : 'Nonaktif'),
                leading: const Icon(Icons.dark_mode_rounded),
                trailing: Switch(
                  value: themeCtrl.isDarkMode,
                  activeThumbColor: colors.onPrimary,
                  activeTrackColor: colors.primary,
                  inactiveThumbColor: colors.outline,
                  inactiveTrackColor: colors.outline.withValues(alpha: 0.3),
                  onChanged: (value) => themeCtrl.toggleDarkMode(value),
                ),
                onTap: () => themeCtrl.toggleDarkMode(!themeCtrl.isDarkMode),
              );
            }),
          ),
          SizedBox(height: AppSpacing.s16.h),
          _SectionLabel(
            label: 'Developer',
            colors: colors,
            typography: typography,
          ),
          SizedBox(height: AppSpacing.s8.h),
          AppCard(
            outlined: true,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AppListItem(
                  title: 'Request Log',
                  subtitle: 'Lihat log request & response API',
                  leading: const Icon(Icons.bug_report_rounded),
                  showDivider: true,
                  onTap: () => Get.to(() => const RequestLogPage()),
                ),
                AppListItem(
                  title: 'Leader Splash Page',
                  subtitle: 'Tampilkan Splash Pimpinan Daerah (Tanpa Auto Close)',
                  leading: const Icon(Icons.slideshow_rounded),
                  onTap: () => Get.to(() => const LeaderSplashPage(autoClose: false)),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.s32.h),
          _ReloadButton(
            colors: colors,
            typography: typography,
            onPressed: () => _showRestartConfirmation(context),
          ),
          SizedBox(height: AppSpacing.s12.h),
          _LogoutButton(ctrl: ctrl, colors: colors, typography: typography),
          SizedBox(height: AppSpacing.s16.h),
          Center(
            child: Text(
              'Versi ${AppConstants.versionName} (${AppConstants.buildNumber})',
              style: typography.bodySmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.s32.h),
        ],
      ),
    ),
  );
}

  Future<void> _openFaq() async {
    final uri = Uri.parse(AppConstants.faqUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: 'Tidak dapat membuka halaman FAQ',
        isError: true,
      );
    }
  }

  Future<void> _showRestartConfirmation(BuildContext context) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restart_alt_rounded, size: 48, color: colors.primary),
              const SizedBox(height: AppSpacing.s16),
              Text(
                'Reload Aplikasi',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Apakah Anda yakin ingin memuat ulang aplikasi?\nSemua state/koneksi akan diatur ulang.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Batal',
                      style: AppButtonStyle.ghost,
                      onPressed: () => Get.back(result: false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: AppButton(
                      label: 'Reload',
                      style: AppButtonStyle.filled,
                      onPressed: () => Get.back(result: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      RestartWidget.restartApp(context);
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileController ctrl;
  final AppColors colors;
  final AppTypography typography;

  const _ProfileHeader({
    required this.ctrl,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    final emp = ctrl.employee.value;

    return Column(
      children: [
        SizedBox(height: AppSpacing.s24.h),
        Center(
          child: Stack(
            children: [
              AppAvatar(
                imageUrl: emp?.photoUrl,
                initials: ctrl.initials,
                size: 88.r,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Get.to(() => const UpdatePhotoPage()),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.background, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.s12.h),
        Text(
          emp?.name ?? '-',
          style: typography.titleLarge.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.s4.h),
        Text(
          emp?.nip ?? '-',
          style: typography.bodySmall.copyWith(color: colors.outline),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.s8.h),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s4,
          ),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadius.circular),
          ),
          child: Text(
            emp?.position ?? '-',
            style: typography.labelSmall.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.s4.h),
        Text(
          emp?.unit ?? '-',
          style: typography.bodySmall.copyWith(
            color: colors.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.s8.h),
      ],
    );
  }
}

class _ReloadButton extends StatelessWidget {
  final AppColors colors;
  final AppTypography typography;
  final VoidCallback onPressed;

  const _ReloadButton({
    required this.colors,
    required this.typography,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.restart_alt_rounded, color: colors.primary),
      label: Text(
        'Muat Ulang Aplikasi',
        style: typography.labelLarge.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colors.primary),
        minimumSize: Size(double.infinity, 48.h),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r8),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final ProfileController ctrl;
  final AppColors colors;
  final AppTypography typography;

  const _LogoutButton({
    required this.ctrl,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: ctrl.logout,
      icon: Icon(Icons.logout_rounded, color: colors.error),
      label: Text(
        'Keluar dari Aplikasi',
        style: typography.labelLarge.copyWith(
          color: colors.error,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colors.error),
        minimumSize: Size(double.infinity, 48.h),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r8),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final AppColors colors;
  final AppTypography typography;

  const _SectionLabel({
    required this.label,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: typography.labelLarge.copyWith(
        color: colors.onSurface.withValues(alpha: 0.5),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
