import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/activity_item.dart';
import '../../data/models/activity_type.dart';
import '../../data/services/kinerja_service.dart';
import '../../../../core/utils/image_compression_helper.dart';
import '../../../../design_system/components/app_feedback.dart';
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
  final clockInTime = Rxn<String>();

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
      final witaNow = DateTime.now().toUtc().add(const Duration(hours: 8));
      final now = DateTime(witaNow.year, witaNow.month, witaNow.day, witaNow.hour, witaNow.minute);
      selectedDate.value = now;
      dateCtrl.text = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      _fetchAndSetStartTime(now);
      
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      endTimeCtrl.text = timeStr;
    }

    loadTypes();

    ever(selectedType, (_) {});
  }

  Future<void> _fetchAndSetStartTime(DateTime date, {bool updateField = true}) async {
    final time = await _service.fetchAttendanceByDate(date);
    clockInTime.value = time;
    if (time != null) {
      if (updateField) {
        startTimeCtrl.text = time;
      }
    } else {
      if (updateField) {
        startTimeCtrl.text = '';
      }
      AppFeedback.showSnackbar(
        title: 'Peringatan',
        message: 'Anda belum melakukan presensi masuk pada tanggal ini. Kinerja tidak dapat dicatat.',
        type: FeedbackType.warning,
      );
    }
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
      } else if (!isEditMode.value && selectedType.value == null) {
        // Default to "Lainnya" (case-insensitive match on name containing 'lainnya')
        final match = types.firstWhereOrNull(
          (t) => t.name.toLowerCase().contains('lainnya'),
        );
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

    _fetchAndSetStartTime(item.date, updateField: false);

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
    _fetchAndSetStartTime(date);
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
        AppFeedback.showSnackbar(
          title: 'Gagal',
          message: 'Gagal mengompresi gambar. Coba lagi.',
          type: FeedbackType.error,
        );
      }
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Terjadi kesalahan saat memproses gambar: $e',
        type: FeedbackType.error,
      );
    } finally {
      isCompressing.value = false;
    }
  }

  void removeImage() {
    originalImagePath.value = null;
    compressedImagePath.value = null;
  }

  int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return 0;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return hours * 60 + minutes;
  }

  Future<void> selectStartTime(BuildContext context) async {
    if (clockInTime.value == null) {
      AppFeedback.showSnackbar(
        title: 'Perhatian',
        message: 'Anda belum memiliki presensi masuk pada tanggal ini.',
        type: FeedbackType.warning,
      );
      return;
    }

    final parts = startTimeCtrl.text.split(':');
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
      final pickedMinutes = _timeToMinutes(formatted);
      final clockInMinutes = _timeToMinutes(clockInTime.value!);

      if (pickedMinutes < clockInMinutes) {
        AppFeedback.showSnackbar(
          title: 'Peringatan',
          message: 'Jam mulai tidak boleh sebelum jam masuk (${clockInTime.value})',
          type: FeedbackType.warning,
        );
      } else {
        startTimeCtrl.text = formatted;
      }
    }
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

    if (clockInTime.value == null) {
      return 'Anda tidak memiliki data presensi masuk untuk tanggal ini. Kinerja tidak dapat dicatat.';
    }

    try {
      final startParts = startTimeCtrl.text.split(':');
      final endParts = endTimeCtrl.text.split(':');
      if (startParts.length == 2 && endParts.length == 2) {
        final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
        if (endMinutes < startMinutes) {
          return 'Jam selesai tidak boleh sebelum jam mulai';
        }

        final clockInMinutes = _timeToMinutes(clockInTime.value!);
        if (startMinutes < clockInMinutes) {
          return 'Jam mulai tidak boleh sebelum jam masuk (${clockInTime.value})';
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
      AppFeedback.showSnackbar(
        title: 'Perhatian',
        message: extraError,
        type: FeedbackType.warning,
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
        AppFeedback.showSnackbar(
          title: 'Berhasil',
          message: 'Kinerja berhasil diperbarui',
          type: FeedbackType.success,
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
        AppFeedback.showSnackbar(
          title: 'Berhasil',
          message: 'Kinerja berhasil dicatat',
          type: FeedbackType.success,
        );
      }
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal menyimpan kinerja: $e',
        type: FeedbackType.error,
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
