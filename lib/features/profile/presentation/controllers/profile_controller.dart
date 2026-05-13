import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/models/employee_model.dart';
import '../../data/models/shift_model.dart';

class ProfileController extends GetxController {
  // ── Reactive state ──────────────────────────────────────────────────────────
  final employee = Rx<EmployeeModel?>(null);
  final shifts = <ShiftModel>[].obs;
  final selectedShiftId = Rx<String?>(null);
  final photoFile = Rx<File?>(null);

  final isLoadingProfile = false.obs;
  final isUpdatingPhoto = false.obs;
  final isUpdatingPassword = false.obs;
  final isUpdatingEmployee = false.obs;
  final isUpdatingShift = false.obs;

  // Password form
  final formKeyPassword = GlobalKey<FormState>();
  final currentPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final isCurrentPassVisible = false.obs;
  final isNewPassVisible = false.obs;
  final isConfirmPassVisible = false.obs;

  // Employee form (editable fields)
  final formKeyEmployee = GlobalKey<FormState>();
  final namaCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadProfile();
    loadShifts();
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

  // ── Data loading ─────────────────────────────────────────────────────────────
  Future<void> loadProfile() async {
    isLoadingProfile.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
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
    isLoadingProfile.value = false;
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
    selectedShiftId.value =
        shifts.firstWhereOrNull((s) => s.isActive)?.id;
  }

  // ── Photo update ─────────────────────────────────────────────────────────────
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
    if (photoFile.value == null) return;
    isUpdatingPhoto.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isUpdatingPhoto.value = false;
    AppFeedback.showSnackbar(
      title: 'Berhasil',
      message: 'Foto profil berhasil diperbarui',
    );
    Get.back();
  }

  // ── Password validators ───────────────────────────────────────────────────────
  String? validateCurrentPassword(String? v) {
    if (v == null || v.trim().isEmpty) return 'Kata sandi lama tidak boleh kosong';
    return null;
  }

  String? validateNewPassword(String? v) {
    if (v == null || v.trim().isEmpty) return 'Kata sandi baru tidak boleh kosong';
    if (v.length < 8) return 'Kata sandi minimal 8 karakter';
    return null;
  }

  String? validateConfirmPassword(String? v) {
    if (v != newPassCtrl.text) return 'Konfirmasi kata sandi tidak cocok';
    return null;
  }

  Future<void> updatePassword() async {
    if (!formKeyPassword.currentState!.validate()) return;
    isUpdatingPassword.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isUpdatingPassword.value = false;
    currentPassCtrl.clear();
    newPassCtrl.clear();
    confirmPassCtrl.clear();
    AppFeedback.showSnackbar(
      title: 'Berhasil',
      message: 'Kata sandi berhasil diperbarui',
    );
    Get.back();
  }

  // ── Employee update ───────────────────────────────────────────────────────────
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

  // ── Shift ─────────────────────────────────────────────────────────────────────
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

  // ── Logout ────────────────────────────────────────────────────────────────────
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
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
    Get.offAll(() => const LoginPage());
  }

  // ── Visibility toggles ────────────────────────────────────────────────────────
  void toggleCurrentPassVisibility() => isCurrentPassVisible.toggle();
  void toggleNewPassVisibility() => isNewPassVisible.toggle();
  void toggleConfirmPassVisibility() => isConfirmPassVisible.toggle();

  // ── Helpers ───────────────────────────────────────────────────────────────────
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
