import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/activity_item.dart';
import '../../data/models/activity_type.dart';
import '../../data/services/kinerja_service.dart';
import '../../../../core/utils/image_compression_helper.dart';
import 'kinerja_controller.dart';

class KinerjaFormController extends GetxController {
  final KinerjaService _service;
  final ActivityItem? initialItem;

  KinerjaFormController({
    required KinerjaService service,
    this.initialItem,
  }) : _service = service;

  final formKey = GlobalKey<FormState>();
  final descriptionCtrl = TextEditingController();
  final startTimeCtrl = TextEditingController();
  final endTimeCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  final selectedType = Rx<ActivityType?>(null);
  final selectedStatus = Rx<String?>(null);
  final selectedDate = Rx<DateTime>(DateTime.now());
  final originalImagePath = Rx<String?>(null);
  final compressedImagePath = Rx<String?>(null);
  final isLoading = false.obs;
  final isCompressing = false.obs;

  // ── Local Activity Types State ──────────────────────────────
  final types = <ActivityType>[].obs;
  final isLoadingTypes = false.obs;
  final errorTypes = Rx<String?>(null);

  // ── Edit Mode State ─────────────────────────────────────────
  final editingItem = Rx<ActivityItem?>(null);
  final isEditMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    if (initialItem != null) {
      loadFromItem(initialItem!);
    } else {
      isEditMode.value = false;
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      startTimeCtrl.text = timeStr;
      endTimeCtrl.text = timeStr;
      selectedDate.value = now;
      dateCtrl.text = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    }

    loadTypes();

    ever(selectedType, (_) {});
  }

  Future<void> loadTypes() async {
    isLoadingTypes.value = true;
    errorTypes.value = null;
    try {
      final result = await _service.fetchTypes();
      types.assignAll(result);

      // Auto-select type in edit mode once types are loaded
      if (isEditMode.value && editingItem.value != null && selectedType.value == null) {
        final match = types.firstWhereOrNull((t) => t.id == editingItem.value!.typeId);
        if (match != null) {
          selectedType.value = match;
        }
      }
    } catch (e) {
      errorTypes.value = e.toString();
    } finally {
      isLoadingTypes.value = false;
    }
  }

  /// Muat data dari item yang akan diedit ke form.
  void loadFromItem(ActivityItem item) {
    editingItem.value = item;
    isEditMode.value = true;

    // Pre-select type
    if (types.isNotEmpty) {
      final match = types.firstWhereOrNull((t) => t.id == item.typeId);
      if (match != null) {
        selectedType.value = match;
      }
    }

    // Pre-fill description
    descriptionCtrl.text = item.description;

    // Pre-fill time and status fields
    startTimeCtrl.text = item.startTime ?? '';
    endTimeCtrl.text = item.endTime ?? '';
    selectedStatus.value = item.status;

    // Pre-fill date fields
    selectedDate.value = item.date;
    dateCtrl.text = '${item.date.day.toString().padLeft(2, '0')}/${item.date.month.toString().padLeft(2, '0')}/${item.date.year}';

    // Set image if exists
    if (item.imageUrl != null) {
      originalImagePath.value = item.imageUrl;
      compressedImagePath.value = item.imageUrl;
    }
  }

  void selectType(ActivityType type) {
    selectedType.value = type;
  }

  void selectStatus(String status) {
    selectedStatus.value = status;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    dateCtrl.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
    if (startTimeCtrl.text.isEmpty) return 'Jam mulai wajib diisi';
    if (endTimeCtrl.text.isEmpty) return 'Jam selesai wajib diisi';
    if (selectedStatus.value == null) return 'Pilih status terlebih dahulu';
    if (dateCtrl.text.isEmpty) return 'Tanggal wajib diisi';

    try {
      final startParts = startTimeCtrl.text.split(':');
      final endParts = endTimeCtrl.text.split(':');
      if (startParts.length == 2 && endParts.length == 2) {
        final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
        if (endMinutes < startMinutes) {
          return 'Jam selesai tidak boleh sebelum jam mulai';
        }
      }
    } catch (_) {
      return 'Format jam tidak valid';
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
          startTime: startTimeCtrl.text.trim(),
          endTime: endTimeCtrl.text.trim(),
          status: selectedStatus.value,
          date: selectedDate.value,
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
          startTime: startTimeCtrl.text.trim(),
          endTime: endTimeCtrl.text.trim(),
          status: selectedStatus.value,
          date: selectedDate.value,
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

  @override
  void onClose() {
    startTimeCtrl.dispose();
    endTimeCtrl.dispose();
    dateCtrl.dispose();
    super.onClose();
  }
}
