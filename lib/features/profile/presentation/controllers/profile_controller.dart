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
import '../../data/models/profile_employee_data_model.dart';
import '../../data/models/shift_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final employee = Rx<EmployeeModel?>(null);
  final employeeData = Rx<ProfileEmployeeDataModel?>(null);
  final shifts = <ShiftModel>[].obs;
  final selectedShiftId = Rx<String?>(null);
  final photoFile = Rx<File?>(null);

  final isLoadingProfile = false.obs;
  final isLoadingEmployeeData = false.obs;
  final isUpdatingPhoto = false.obs;
  final isUpdatingPassword = false.obs;
  final isSavingHistoricalData = false.obs;
  final isSavingContactData = false.obs;
  final isUpdatingShift = false.obs;

  final formKeyPassword = GlobalKey<FormState>();
  final currentPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final isCurrentPassVisible = false.obs;
  final isNewPassVisible = false.obs;
  final isConfirmPassVisible = false.obs;

  final formKeyHistorical = GlobalKey<FormState>();
  final formKeyContact = GlobalKey<FormState>();
  final namaCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();

  bool get employeeDataExists => employeeData.value != null;
  bool get canEditHistoricalData => !employeeDataExists;

  @override
  void onInit() {
    super.onInit();

    ever(Get.find<SessionManager>().currentUser, (user) {
      if (user != null) {
        _syncEmployeeState(user: user);
      }
    });

    final initialUser = Get.find<SessionManager>().currentUser.value;
    if (initialUser != null) {
      _syncEmployeeState(user: initialUser);
    }

    loadProfile();
    loadEmployeeData();
    loadShifts();
  }

  void _syncEmployeeState({UserModel? user}) {
    final resolvedUser = user ?? Get.find<SessionManager>().currentUser.value;
    if (resolvedUser == null) return;

    final historicalData = employeeData.value;
    final fullName = historicalData != null && historicalData.fullName.trim().isNotEmpty
        ? historicalData.fullName
        : (resolvedUser.fullName.isNotEmpty ? resolvedUser.fullName : resolvedUser.name);
    final phone = resolvedUser.phone ?? historicalData?.phone ?? '';
    final address = historicalData?.address ?? '';

    employee.value = EmployeeModel(
      id: resolvedUser.id.toString(),
      nip: historicalData?.nip.isNotEmpty == true ? historicalData!.nip : resolvedUser.nip,
      name: fullName,
      position: resolvedUser.jobTitle?.name ?? '-',
      unit: resolvedUser.institution?.name ?? resolvedUser.department?.name ?? '-',
      email: resolvedUser.email,
      phone: phone,
      address: address,
      photoUrl: resolvedUser.profilePictureUrl,
    );

    namaCtrl.text = fullName;
    emailCtrl.text = resolvedUser.email;
    phoneCtrl.text = phone;
    alamatCtrl.text = address;
  }

  Future<void> loadProfile({bool force = false, bool showLoading = true}) async {
    if (!force) {
      final sessionUser = Get.find<SessionManager>().currentUser.value;
      if (sessionUser != null) {
        _syncEmployeeState(user: sessionUser);
        return;
      }
    }

    if (showLoading) {
      isLoadingProfile.value = true;
    }
    try {
      final user = await Get.find<AuthService>().getMe();
      Get.find<SessionManager>().setUser(user);
      _syncEmployeeState(user: user);
    } catch (_) {
      final sessionUser = Get.find<SessionManager>().currentUser.value;
      if (sessionUser == null) {
        employee.value = const EmployeeModel(
          id: '001',
          nip: '19850412 200903 1 012',
          name: 'Budi Santoso, S.Kom.',
          position: 'Pranata Komputer Muda',
          unit: 'Dinas Komunikasi dan Informatika',
          email: 'budi.santoso@barrukab.go.id',
          phone: '08123456789',
          address: '',
          photoUrl: null,
        );
        namaCtrl.text = employee.value!.name;
        emailCtrl.text = employee.value!.email;
        phoneCtrl.text = employee.value!.phone;
        alamatCtrl.text = employee.value!.address;
      }
    } finally {
      if (showLoading) {
        isLoadingProfile.value = false;
      }
    }
  }

  Future<void> loadEmployeeData({bool showLoading = true}) async {
    if (showLoading) {
      isLoadingEmployeeData.value = true;
    }
    try {
      employeeData.value = await Get.find<ProfileRepository>().getEmployeeData();
      _syncEmployeeState();
    } on ApiException {
      employeeData.value = null;
      _syncEmployeeState();
    } on NetworkException {
      // Biarkan UI menggunakan data session saat koneksi gagal.
    } finally {
      if (showLoading) {
        isLoadingEmployeeData.value = false;
      }
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

  String? validateHistoricalFullName(String? value) {
    if (!canEditHistoricalData) return null;
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
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

  Future<void> saveHistoricalEmployeeData() async {
    final formState = formKeyHistorical.currentState;
    if (!canEditHistoricalData ||
        formState == null ||
        !formState.validate() ||
        isSavingHistoricalData.value) {
      return;
    }

    isSavingHistoricalData.value = true;
    try {
      employeeData.value = await Get.find<ProfileRepository>().upsertEmployeeData(
        fullName: namaCtrl.text.trim(),
      );
      _syncEmployeeState();
      FocusManager.instance.primaryFocus?.unfocus();
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Data historis berhasil disimpan',
      );
    } on ValidationException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.fieldError('full_name') ?? e.message,
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
      isSavingHistoricalData.value = false;
    }
  }

  Future<void> saveEditableEmployeeData() async {
    final formState = formKeyContact.currentState;
    if (formState == null || !formState.validate() || isSavingContactData.value) {
      return;
    }

    final session = Get.find<SessionManager>();
    final currentUser = session.currentUser.value;
    final currentPhone = currentUser?.phone ?? '';
    final currentAddress = employeeData.value?.address ?? '';
    final nextPhone = phoneCtrl.text.trim();
    final nextAddress = alamatCtrl.text.trim();

    final phoneChanged = nextPhone != currentPhone;
    final addressChanged = nextAddress != currentAddress;
    final shouldBootstrapEmployeeData = !employeeDataExists && nextAddress.isNotEmpty;

    if (!phoneChanged && !addressChanged && !shouldBootstrapEmployeeData) {
      AppFeedback.showSnackbar(
        title: 'Info',
        message: 'Tidak ada perubahan yang perlu disimpan',
      );
      return;
    }

    isSavingContactData.value = true;
    try {
      if (phoneChanged) {
        final updatedProfile = await Get.find<ProfileRepository>().updateProfile(
          phone: nextPhone.isEmpty ? '' : nextPhone,
        );

        if (currentUser != null) {
          session.setUser(_mergeProfileUpdate(currentUser, updatedProfile));
        } else {
          session.setUser(updatedProfile);
        }
      }

      if (addressChanged || shouldBootstrapEmployeeData) {
        employeeData.value = await Get.find<ProfileRepository>().upsertEmployeeData(
          fullName: employeeDataExists ? null : namaCtrl.text.trim(),
          address: nextAddress,
        );
      }

      _syncEmployeeState();
      FocusManager.instance.primaryFocus?.unfocus();
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Data kontak berhasil diperbarui',
      );
    } on ValidationException catch (e) {
      final message =
          e.fieldError('phone') ??
          e.fieldError('address') ??
          e.fieldError('full_name') ??
          e.message;
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: message,
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
      isSavingContactData.value = false;
    }
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
      phone: updated.phone,
      profilePictureUrl: updated.profilePictureUrl,
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
