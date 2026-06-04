import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/session_manager.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/models/employee_model.dart';
import '../../data/models/shift_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final employee = Rx<EmployeeModel?>(null);
  final shifts = <ShiftModel>[].obs;
  final selectedShiftId = Rx<String?>(null);
  final photoFile = Rx<File?>(null);

  final isLoadingProfile = false.obs;
  final isUpdatingPhoto = false.obs;
  final isUpdatingPassword = false.obs;
  final isUpdatingEmployee = false.obs;
  final isUpdatingShift = false.obs;

  final formKeyPassword = GlobalKey<FormState>();
  final currentPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final isCurrentPassVisible = false.obs;
  final isNewPassVisible = false.obs;
  final isConfirmPassVisible = false.obs;

  final formKeyEmployee = GlobalKey<FormState>();
  final namaCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    ever(Get.find<SessionManager>().currentUser, (user) {
      if (user != null) {
        _updateFromUser(user);
      }
    });

    final initialUser = Get.find<SessionManager>().currentUser.value;
    if (initialUser != null) {
      _updateFromUser(initialUser);
    }

    loadProfile();
    loadShifts();
  }

  void _updateFromUser(UserModel user) {
    employee.value = EmployeeModel(
      id: user.id.toString(),
      nip: user.nip,
      name: user.fullName.isNotEmpty ? user.fullName : user.name,
      position: user.jobTitle?.name ?? '-',
      unit: user.institution?.name ?? user.department?.name ?? '-',
      email: user.email,
      phone: user.phone ?? '-',
      address: '-',
      photoUrl: user.profilePictureUrl,
    );
    namaCtrl.text = employee.value!.name;
    emailCtrl.text = employee.value!.email;
    phoneCtrl.text = employee.value!.phone;
    alamatCtrl.text = employee.value!.address;
  }

  Future<void> loadProfile() async {
    final sessionUser = Get.find<SessionManager>().currentUser.value;
    if (sessionUser != null) {
      _updateFromUser(sessionUser);
      return;
    }

    isLoadingProfile.value = true;
    try {
      final user = await Get.find<AuthService>().getMe();
      Get.find<SessionManager>().setUser(user);
      _updateFromUser(user);
    } catch (_) {
      employee.value = const EmployeeModel(
        id: '001',
        nip: '19850412 200903 1 012',
        name: 'Budi Santoso, S.Kom.',
        position: 'Pranata Komputer Muda',
        unit: 'Dinas Komunikasi dan Informatika',
        email: 'budi.santoso@barrukab.go.id',
        phone: '08123456789',
        address: 'Jl. Soppeng No. 1, Barru',
        photoUrl: null,
      );
      namaCtrl.text = employee.value!.name;
      emailCtrl.text = employee.value!.email;
      phoneCtrl.text = employee.value!.phone;
      alamatCtrl.text = employee.value!.address;
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> loadShifts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    shifts.assignAll([
      const ShiftModel(
        id: 's1',
        name: 'Pagi',
        checkIn: '07:30',
        checkOut: '16:00',
        isActive: true,
      ),
      const ShiftModel(
        id: 's2',
        name: 'Siang',
        checkIn: '13:00',
        checkOut: '21:00',
        isActive: false,
      ),
      const ShiftModel(
        id: 's3',
        name: 'Malam',
        checkIn: '21:00',
        checkOut: '07:00',
        isActive: false,
      ),
    ]);
    selectedShiftId.value = shifts.firstWhereOrNull((s) => s.isActive)?.id;
  }

  Future<void> pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;
    photoFile.value = File(picked.path);
  }

  Future<void> uploadPhoto() async {
    final file = photoFile.value;
    if (file == null || isUpdatingPhoto.value) return;

    isUpdatingPhoto.value = true;
    try {
      final updatedProfile = await Get.find<ProfileRepository>()
          .updateProfilePhoto(file);
      final session = Get.find<SessionManager>();
      final currentUser = session.currentUser.value;

      if (currentUser != null) {
        session.setUser(_mergeProfileUpdate(currentUser, updatedProfile));
      } else {
        session.setUser(updatedProfile);
      }

      photoFile.value = null;
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Foto profil berhasil diperbarui',
      );
      Get.back();
    } on ValidationException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.fieldError('profile_picture') ?? e.message,
        isError: true,
      );
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } finally {
      isUpdatingPhoto.value = false;
    }
  }

  String? validateCurrentPassword(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Kata sandi lama tidak boleh kosong';
    }
    return null;
  }

  String? validateNewPassword(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Kata sandi baru tidak boleh kosong';
    }
    if (v.length < 8) return 'Kata sandi minimal 8 karakter';
    return null;
  }

  String? validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) {
      return 'Konfirmasi kata sandi tidak boleh kosong';
    }
    if (v != newPassCtrl.text) return 'Konfirmasi kata sandi tidak cocok';
    return null;
  }

  Future<void> updatePassword() async {
    final formState = formKeyPassword.currentState;
    if (formState == null ||
        !formState.validate() ||
        isUpdatingPassword.value) {
      return;
    }

    isUpdatingPassword.value = true;
    try {
      await Get.find<ProfileRepository>().updatePassword(
        currentPassword: currentPassCtrl.text.trim(),
        newPassword: newPassCtrl.text,
        newPasswordConfirmation: confirmPassCtrl.text,
      );
      currentPassCtrl.clear();
      newPassCtrl.clear();
      confirmPassCtrl.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      await Get.find<TokenStorage>().clearAll();
      Get.find<SessionManager>().clear();
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Password berhasil diperbarui. Silakan login kembali.',
      );
      Get.offAll(() => const LoginPage());
    } on ValidationException catch (e) {
      final message =
          e.fieldError('current_password') ??
          e.fieldError('new_password') ??
          e.fieldError('new_password_confirmation') ??
          e.message;
      AppFeedback.showSnackbar(title: 'Gagal', message: message, isError: true);
    } on ApiException catch (e) {
      final message = e.errorCode == 'WRONG_CURRENT_PASSWORD'
          ? 'Password saat ini tidak sesuai'
          : e.message;
      AppFeedback.showSnackbar(title: 'Gagal', message: message, isError: true);
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } finally {
      isUpdatingPassword.value = false;
    }
  }

  Future<void> updateEmployeeData() async {
    if (!formKeyEmployee.currentState!.validate()) return;
    isUpdatingEmployee.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isUpdatingEmployee.value = false;
    AppFeedback.showSnackbar(
      title: 'Berhasil',
      message: 'Data pegawai berhasil diperbarui',
    );
    Get.back();
  }

  void selectShift(String shiftId) {
    selectedShiftId.value = shiftId;
  }

  Future<void> saveShift() async {
    if (selectedShiftId.value == null) return;
    isUpdatingShift.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isUpdatingShift.value = false;
    AppFeedback.showSnackbar(
      title: 'Berhasil',
      message: 'Jadwal shift berhasil disimpan',
    );
    Get.back();
  }

  Future<void> logout() async {
    final colors = Get.theme.extension<AppColors>()!;
    final textTheme = Get.textTheme;
    final typography = Get.theme.extension<AppTypography>()!;

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
              Icon(Icons.logout_rounded, size: 48, color: colors.error),
              const SizedBox(height: AppSpacing.s16),
              Text(
                'Keluar dari Aplikasi',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Apakah Anda yakin ingin keluar?\nSesi Anda akan diakhiri.',
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
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: true),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.error),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r8),
                        ),
                      ),
                      child: Text(
                        'Keluar',
                        style: typography.labelLarge.copyWith(
                          color: colors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;
    try {
      await Get.find<AuthService>().logout();
    } catch (_) {
      // Lanjutkan logout lokal meski request ke server gagal
    }
    Get.find<SessionManager>().clear();
    FocusManager.instance.primaryFocus?.unfocus();
    Get.offAll(() => const LoginPage());
  }

  void toggleCurrentPassVisibility() => isCurrentPassVisible.toggle();
  void toggleNewPassVisibility() => isNewPassVisible.toggle();
  void toggleConfirmPassVisibility() => isConfirmPassVisible.toggle();

  UserModel _mergeProfileUpdate(UserModel current, UserModel updated) {
    return current.copyWith(
      name: updated.name.isNotEmpty ? updated.name : current.name,
      fullName: updated.fullName.isNotEmpty
          ? updated.fullName
          : current.fullName,
      phone: updated.phone ?? current.phone,
      profilePictureUrl: updated.profilePictureUrl ?? current.profilePictureUrl,
    );
  }

  @override
  void onClose() {
    currentPassCtrl.dispose();
    newPassCtrl.dispose();
    confirmPassCtrl.dispose();
    namaCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    alamatCtrl.dispose();
    super.onClose();
  }

  String get initials {
    final name = employee.value?.name ?? '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}
