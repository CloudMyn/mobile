import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/activity_item.dart';
import '../../data/models/activity_type.dart';
import '../../data/services/kinerja_service.dart';
import '../../../../core/utils/image_compression_helper.dart';
import 'kinerja_controller.dart';

class KinerjaFormController extends GetxController {
  final KinerjaService _service;

  KinerjaFormController({required KinerjaService service}) : _service = service;

  final formKey = GlobalKey<FormState>();
  final descriptionCtrl = TextEditingController();

  final selectedType = Rx<ActivityType?>(null);
  final originalImagePath = Rx<String?>(null);
  final compressedImagePath = Rx<String?>(null);
  final isLoading = false.obs;
  final isCompressing = false.obs;

  // ── Edit Mode State ─────────────────────────────────────────
  final editingItem = Rx<ActivityItem?>(null);
  final isEditMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedType, (_) {});
  }

  /// Muat data dari item yang akan diedit ke form.
  void loadFromItem(ActivityItem item) {
    editingItem.value = item;
    isEditMode.value = true;

    // Pre-select type
    if (Get.isRegistered<KinerjaController>(tag: 'kinerja_list')) {
      final types = Get.find<KinerjaController>(tag: 'kinerja_list').types;
      final match = types.firstWhereOrNull((t) => t.id == item.typeId);
      if (match != null) {
        selectedType.value = match;
      }
    }

    // Pre-fill description
    descriptionCtrl.text = item.description;

    // Set image if exists
    if (item.imageUrl != null) {
      originalImagePath.value = item.imageUrl;
      compressedImagePath.value = item.imageUrl;
    }
  }

  void selectType(ActivityType type) {
    selectedType.value = type;
  }

  Future<void> pickAndCompressImage(String sourcePath) async {
    originalImagePath.value = sourcePath;
    isCompressing.value = true;

    try {
      final compressed = await ImageCompressionHelper.compress(
        sourcePath: sourcePath,
      );

      if (compressed != null) {
        compressedImagePath.value = compressed;
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal mengompresi gambar. Coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memproses gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCompressing.value = false;
    }
  }

  void removeImage() {
    originalImagePath.value = null;
    compressedImagePath.value = null;
  }

  String? validateForm() {
    if (selectedType.value == null) return 'Pilih jenis kegiatan terlebih dahulu';
    if (descriptionCtrl.text.trim().length < 10) {
      return 'Deskripsi minimal 10 karakter';
    }
    return null;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    final extraError = validateForm();
    if (extraError != null) {
      Get.snackbar(
        'Perhatian',
        extraError,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    try {
      if (isEditMode.value && editingItem.value != null) {
        // ── Edit Mode: update existing activity ──────────
        final updated = await _service.updateActivity(
          id: editingItem.value!.id,
          typeId: selectedType.value!.id,
          description: descriptionCtrl.text.trim(),
          imagePath: compressedImagePath.value,
        );

        if (Get.isRegistered<KinerjaController>(tag: 'kinerja_list')) {
          Get.find<KinerjaController>(tag: 'kinerja_list')
              .updateActivityInList(updated);
        }

        Get.back();
        Get.snackbar(
          'Berhasil',
          'Kinerja berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // ── Create Mode: create new activity ─────────────
        final item = await _service.createActivity(
          typeId: selectedType.value!.id,
          description: descriptionCtrl.text.trim(),
          imagePath: compressedImagePath.value,
        );

        if (Get.isRegistered<KinerjaController>(tag: 'kinerja_list')) {
          Get.find<KinerjaController>(tag: 'kinerja_list').addActivity(item);
        }

        Get.back();
        Get.snackbar(
          'Berhasil',
          'Kinerja berhasil dicatat',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan kinerja: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
