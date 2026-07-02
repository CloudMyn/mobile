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
import '../../data/models/employee_enums.dart';
import '../../data/models/shift_model.dart';
import '../../data/models/reference_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final employee = Rx<EmployeeModel?>(null);
  final employeeData = Rx<ProfileEmployeeDataModel?>(null);
  final shifts = <ShiftModel>[].obs;
  final selectedShiftId = Rx<int?>(null);
  final photoFile = Rx<File?>(null);

  final canChooseSchedule = false.obs;
  final hasCheckedInToday = false.obs;
  final isLoadingSchedules = false.obs;
  final isLoadingReferences = false.obs;

  final jobTitles = <ReferenceItem>[].obs;
  final institutions = <ReferenceItem>[].obs;
  final selectedJobTitle = Rx<ReferenceItem?>(null);
  final selectedInstitution = Rx<ReferenceItem?>(null);

  final isLoadingProfile = false.obs;
  final isLoadingEmployeeData = false.obs;
  final isUpdatingPhoto = false.obs;
  final isUpdatingPassword = false.obs;
  final isSavingPersonal = false.obs;
  final isSavingContact = false.obs;
  final isSavingBank = false.obs;
  final isSavingFamily = false.obs;
  final isUpdatingShift = false.obs;

  final formKeyPassword = GlobalKey<FormState>();
  final currentPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final isCurrentPassVisible = false.obs;
  final isNewPassVisible = false.obs;
  final isConfirmPassVisible = false.obs;

  final formKeyPersonal = GlobalKey<FormState>();
  final formKeyContact = GlobalKey<FormState>();
  final formKeyBank = GlobalKey<FormState>();
  final formKeyFamily = GlobalKey<FormState>();

  final nikCtrl = TextEditingController();
  final namaCtrl = TextEditingController();
  final titlePrefixCtrl = TextEditingController();
  final titleSuffixCtrl = TextEditingController();
  final birthPlaceCtrl = TextEditingController();
  final gender = Rx<Gender?>(null);
  final birthDate = Rx<DateTime?>(null);
  final religion = Rx<Religion?>(null);
  final maritalStatus = Rx<MaritalStatus?>(null);

  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();
  final postalCodeCtrl = TextEditingController();

  final bankAccountNumberCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final bankAccountHolderNameCtrl = TextEditingController();

  final motherNameCtrl = TextEditingController();
  final fatherNameCtrl = TextEditingController();
  final childrenCountCtrl = TextEditingController();
  final emergencyContactNameCtrl = TextEditingController();
  final emergencyContactPhoneCtrl = TextEditingController();
  final emergencyContactRelationshipCtrl = TextEditingController();

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
    loadReferences();
  }

  void _syncEmployeeState({UserModel? user}) {
    final resolvedUser = user ?? Get.find<SessionManager>().currentUser.value;
    if (resolvedUser == null) return;

    final data = employeeData.value;
    final fullName = data != null && data.fullName.trim().isNotEmpty
        ? data.fullName
        : (resolvedUser.fullName.isNotEmpty ? resolvedUser.fullName : resolvedUser.name);
    final phone = resolvedUser.phone ?? data?.phone ?? '';
    final address = data?.address ?? '';

    employee.value = EmployeeModel(
      id: resolvedUser.id.toString(),
      nip: data?.nip.isNotEmpty == true ? data!.nip : resolvedUser.nip,
      name: fullName,
      position: resolvedUser.jobTitle?.name ?? '-',
      unit: resolvedUser.institution?.name ?? resolvedUser.department?.name ?? '-',
      email: resolvedUser.email,
      phone: phone,
      address: address,
      photoUrl: resolvedUser.profilePictureUrl,
    );

    if (resolvedUser.jobTitle != null) {
      selectedJobTitle.value = ReferenceItem(id: resolvedUser.jobTitle!.id, name: resolvedUser.jobTitle!.name);
    }

    if (resolvedUser.institution != null) {
      selectedInstitution.value = ReferenceItem(id: resolvedUser.institution!.id, name: resolvedUser.institution!.name);
    } else if (resolvedUser.department != null) {
      selectedInstitution.value = ReferenceItem(id: resolvedUser.department!.id, name: resolvedUser.department!.name);
    }

    namaCtrl.text = fullName;
    emailCtrl.text = resolvedUser.email;
    phoneCtrl.text = phone;
    alamatCtrl.text = address;

    if (data != null) {
      nikCtrl.text = data.nik ?? '';
      titlePrefixCtrl.text = data.titlePrefix ?? '';
      titleSuffixCtrl.text = data.titleSuffix ?? '';
      birthPlaceCtrl.text = data.birthPlace ?? '';
      gender.value = data.gender;
      birthDate.value = data.birthDate;
      religion.value = data.religion;
      maritalStatus.value = data.maritalStatus;

      postalCodeCtrl.text = data.postalCode ?? '';

      bankAccountNumberCtrl.text = data.bankAccountNumber ?? '';
      bankNameCtrl.text = data.bankName ?? '';
      bankAccountHolderNameCtrl.text = data.bankAccountHolderName ?? '';

      motherNameCtrl.text = data.motherName ?? '';
      fatherNameCtrl.text = data.fatherName ?? '';
      childrenCountCtrl.text = data.childrenCount?.toString() ?? '';
      emergencyContactNameCtrl.text = data.emergencyContactName ?? '';
      emergencyContactPhoneCtrl.text = data.emergencyContactPhone ?? '';
      emergencyContactRelationshipCtrl.text = data.emergencyContactRelationship ?? '';
    }
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
    isLoadingSchedules.value = true;
    try {
      final data = await Get.find<ProfileRepository>().getSchedules();
      canChooseSchedule.value = data.canChooseSchedule;
      hasCheckedInToday.value = data.hasCheckedInToday;
      shifts.assignAll(data.availableSchedules);
      selectedShiftId.value = data.currentScheduleId;
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
      isLoadingSchedules.value = false;
    }
  }

  Future<void> loadReferences() async {
    isLoadingReferences.value = true;
    try {
      final jobTitlesData = await Get.find<ProfileRepository>().fetchReferences('job-titles');
      final institutionsData = await Get.find<ProfileRepository>().fetchReferences('institutions');
      jobTitles.assignAll(jobTitlesData);
      institutions.assignAll(institutionsData);
    } catch (e) {
      debugPrint('Error loading references: $e');
    } finally {
      isLoadingReferences.value = false;
    }
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

  Future<void> savePersonalData() async {
    final formState = formKeyPersonal.currentState;
    if (formState == null || !formState.validate() || isSavingPersonal.value) {
      return;
    }

    isSavingPersonal.value = true;
    try {
      employeeData.value = await Get.find<ProfileRepository>().upsertEmployeeData(
        fullName: namaCtrl.text.trim(),
        nik: nikCtrl.text.trim().isEmpty ? null : nikCtrl.text.trim(),
        titlePrefix: titlePrefixCtrl.text.trim().isEmpty ? null : titlePrefixCtrl.text.trim(),
        titleSuffix: titleSuffixCtrl.text.trim().isEmpty ? null : titleSuffixCtrl.text.trim(),
        birthPlace: birthPlaceCtrl.text.trim().isEmpty ? null : birthPlaceCtrl.text.trim(),
        gender: gender.value,
        birthDate: birthDate.value,
        religion: religion.value,
        maritalStatus: maritalStatus.value,
      );

      final user = Get.find<SessionManager>().currentUser.value;
      final selectedJobId = selectedJobTitle.value?.id;
      final selectedInstId = selectedInstitution.value?.id;

      if ((selectedJobId != null && user?.jobTitle == null) ||
          (selectedInstId != null && user?.institution == null)) {
        final updatedUser = await Get.find<ProfileRepository>().updateProfile(
          jobTitleId: user?.jobTitle == null ? selectedJobId : null,
          institutionId: user?.institution == null ? selectedInstId : null,
        );
        Get.find<SessionManager>().setUser(updatedUser);
      }

      _syncEmployeeState();
      FocusManager.instance.primaryFocus?.unfocus();
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Data personal berhasil disimpan',
      );
    } on ValidationException catch (e) {
      AppFeedback.showSnackbar(title: 'Gagal', message: e.message, isError: true);
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(title: 'Gagal', message: e.message, isError: true);
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(title: 'Gagal', message: e.message, isError: true);
    } finally {
      isSavingPersonal.value = false;
    }
  }

  Future<void> saveContactData() async {
    final formState = formKeyContact.currentState;
    if (formState == null || !formState.validate() || isSavingContact.value) {
      return;
    }

    final session = Get.find<SessionManager>();
    final currentUser = session.currentUser.value;
    final currentPhone = currentUser?.phone ?? '';
    final nextPhone = phoneCtrl.text.trim();
    final nextAddress = alamatCtrl.text.trim();
    final nextPostalCode = postalCodeCtrl.text.trim();

    isSavingContact.value = true;
    try {
      if (nextPhone != currentPhone) {
        final updatedProfile = await Get.find<ProfileRepository>().updateProfile(
          phone: nextPhone.isEmpty ? '' : nextPhone,
        );

        if (currentUser != null) {
          session.setUser(_mergeProfileUpdate(currentUser, updatedProfile));
        } else {
          session.setUser(updatedProfile);
        }
      }

      employeeData.value = await Get.find<ProfileRepository>().upsertEmployeeData(
        address: nextAddress,
        postalCode: nextPostalCode.isEmpty ? null : nextPostalCode,
      );

      _syncEmployeeState();
      FocusManager.instance.primaryFocus?.unfocus();
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Data kontak berhasil diperbarui',
      );
    } on ValidationException catch (e) {
      AppFeedback.showSnackbar(title: 'Gagal', message: e.message, isError: true);
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(title: 'Gagal', message: e.message, isError: true);
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(title: 'Gagal', message: e.message, isError: true);
    } finally {
      isSavingContact.value = false;
    }
  }

  Future<void> saveBankData() async {
    final formState = formKeyBank.currentState;
    if (formState == null || !formState.validate() || isSavingBank.value) {
      return;
    }

    isSavingBank.value = true;
    try {
      employeeData.value = await Get.find<ProfileRepository>().upsertEmployeeData(
        bankAccountNumber: bankAccountNumberCtrl.text.trim().isEmpty ? null : bankAccountNumberCtrl.text.trim(),
        bankName: bankNameCtrl.text.trim().isEmpty ? null : bankNameCtrl.text.trim(),
        bankAccountHolderName: bankAccountHolderNameCtrl.text.trim().isEmpty ? null : bankAccountHolderNameCtrl.text.trim(),
      );
      _syncEmployeeState();
      FocusManager.instance.primaryFocus?.unfocus();
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Data bank berhasil disimpan',
      );
    } on ValidationException catch (e) {
      AppFeedback.showSnackbar(title: 'Gagal', message: e.message, isError: true);
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(title: 'Gagal', message: e.message, isError: true);
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(title: 'Gagal', message: e.message, isError: true);
    } finally {
      isSavingBank.value = false;
    }
  }

  Future<void> saveFamilyData() async {
    final formState = formKeyFamily.currentState;
    if (formState == null || !formState.validate() || isSavingFamily.value) {
      return;
    }

    isSavingFamily.value = true;
    try {
      final childCount = int.tryParse(childrenCountCtrl.text.trim());
      employeeData.value = await Get.find<ProfileRepository>().upsertEmployeeData(
        motherName: motherNameCtrl.text.trim().isEmpty ? null : motherNameCtrl.text.trim(),
        fatherName: fatherNameCtrl.text.trim().isEmpty ? null : fatherNameCtrl.text.trim(),
        childrenCount: childCount,
        emergencyContactName: emergencyContactNameCtrl.text.trim().isEmpty ? null : emergencyContactNameCtrl.text.trim(),
        emergencyContactPhone: emergencyContactPhoneCtrl.text.trim().isEmpty ? null : emergencyContactPhoneCtrl.text.trim(),
        emergencyContactRelationship: emergencyContactRelationshipCtrl.text.trim().isEmpty ? null : emergencyContactRelationshipCtrl.text.trim(),
      );
      _syncEmployeeState();
      FocusManager.instance.primaryFocus?.unfocus();
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Data keluarga & darurat berhasil disimpan',
      );
    } on ValidationException catch (e) {
      AppFeedback.showSnackbar(title: 'Gagal', message: e.message, isError: true);
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(title: 'Gagal', message: e.message, isError: true);
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(title: 'Gagal', message: e.message, isError: true);
    } finally {
      isSavingFamily.value = false;
    }
  }

  void selectShift(int shiftId) {
    selectedShiftId.value = shiftId;
  }

  Future<void> saveShift() async {
    if (selectedShiftId.value == null) return;
    isUpdatingShift.value = true;
    try {
      final result = await Get.find<ProfileRepository>()
          .updateSchedule(selectedShiftId.value!);
      final message = result['message'] as String? ?? 'Jadwal berhasil disimpan';
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: message,
      );
      Get.back();
    } on ValidationException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
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
      isUpdatingShift.value = false;
    }
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
    nikCtrl.dispose();
    titlePrefixCtrl.dispose();
    titleSuffixCtrl.dispose();
    birthPlaceCtrl.dispose();

    emailCtrl.dispose();
    phoneCtrl.dispose();
    alamatCtrl.dispose();
    postalCodeCtrl.dispose();

    bankAccountNumberCtrl.dispose();
    bankNameCtrl.dispose();
    bankAccountHolderNameCtrl.dispose();

    motherNameCtrl.dispose();
    fatherNameCtrl.dispose();
    childrenCountCtrl.dispose();
    emergencyContactNameCtrl.dispose();
    emergencyContactPhoneCtrl.dispose();
    emergencyContactRelationshipCtrl.dispose();
    super.onClose();
  }

  String get initials {
    final name = employee.value?.name ?? '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}
