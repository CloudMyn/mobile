import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/submission_type.dart';
import '../../data/services/submission_service.dart';
import 'submission_controller.dart';

class SubmissionFormController extends GetxController {
  final SubmissionService _service;

  SubmissionFormController({required SubmissionService service}) : _service = service;

  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  // Display-only controllers — diupdate via ever(), tidak dibuat ulang tiap rebuild
  final startDateDisplayCtrl = TextEditingController();
  final endDateDisplayCtrl = TextEditingController();
  final startTimeDisplayCtrl = TextEditingController();
  final endTimeDisplayCtrl = TextEditingController();

  final selectedType = Rx<SubmissionType?>(null);
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);
  final startTime = Rx<TimeOfDay?>(null);
  final endTime = Rx<TimeOfDay?>(null);
  final attachments = <String, String?>{}.obs;
  final isLoading = false.obs;
  final isWfhFromHome = false.obs;

  bool get requiresDateRange => selectedType.value?.requiresDateRange ?? false;
  bool get requiresTimeRange => selectedType.value?.requiresTimeRange ?? false;

  @override
  void onInit() {
    super.onInit();
    ever(startDate, (d) => startDateDisplayCtrl.text = d != null ? _formatDate(d) : '');
    ever(endDate, (d) => endDateDisplayCtrl.text = d != null ? _formatDate(d) : '');
    ever(startTime, (t) => startTimeDisplayCtrl.text = t != null ? _formatTime(t) : '');
    ever(endTime, (t) => endTimeDisplayCtrl.text = t != null ? _formatTime(t) : '');
  }

  void selectType(SubmissionType type) {
    selectedType.value = type;
    startDate.value = null;
    endDate.value = null;
    startTime.value = null;
    endTime.value = null;
    attachments.clear();
    isWfhFromHome.value = false;
    for (final field in type.attachmentFields) {
      attachments[field.id] = null;
    }
  }

  Future<void> pickDate(BuildContext context, {required bool isStart}) async {
    if (requiresDateRange) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDateRange: startDate.value != null && endDate.value != null
            ? DateTimeRange(start: startDate.value!, end: endDate.value!)
            : null,
      );
      if (range != null) {
        startDate.value = range.start;
        endDate.value = range.end;
      }
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: startDate.value ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) {
        startDate.value = picked;
        endDate.value = null;
      }
    }
  }

  Future<void> pickTime(BuildContext context, {required bool isStart}) async {
    final initial = isStart
        ? (startTime.value ?? const TimeOfDay(hour: 8, minute: 0))
        : (endTime.value ?? const TimeOfDay(hour: 17, minute: 0));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      if (isStart) {
        startTime.value = picked;
      } else {
        endTime.value = picked;
      }
    }
  }

  Future<void> pickFile(String fieldId) async {
    final type = selectedType.value;
    if (type == null) return;
    
    final field = type.attachmentFields.firstWhereOrNull((f) => f.id == fieldId);
    if (field == null) return;

    try {
      FileType fileType = FileType.any;
      List<String>? allowedExts;
      
      if (field.allowedExtensions.isNotEmpty) {
        fileType = FileType.custom;
        allowedExts = field.allowedExtensions.map((e) => e.toLowerCase().replaceAll('.', '')).toList();
      }

      final result = await FilePicker.pickFiles(
        type: fileType,
        allowedExtensions: allowedExts,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (field.maxFileSizeKb != null) {
          final sizeKb = file.size / 1024;
          if (sizeKb > field.maxFileSizeKb!) {
            final mb = (field.maxFileSizeKb! / 1024).toStringAsFixed(1);
            Get.snackbar('File Terlalu Besar', 'Maksimal ukuran file adalah $mb MB', snackPosition: SnackPosition.BOTTOM);
            return;
          }
        }
        
        attachments[fieldId] = file.path;
        attachments.refresh();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih file: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removeFile(String fieldId) {
    attachments[fieldId] = null;
    attachments.refresh();
  }

  String? validateForm() {
    if (selectedType.value == null) return 'Pilih jenis pengajuan terlebih dahulu';
    if (startDate.value == null) return 'Tanggal pengajuan harus diisi';
    if (requiresDateRange && endDate.value == null) return 'Tanggal akhir harus diisi';
    if (requiresTimeRange) {
      if (startTime.value == null) return 'Waktu mulai harus diisi';
      if (endTime.value == null) return 'Waktu selesai harus diisi';
    }
    
    final type = selectedType.value!;
    
    // Validasi max days
    if (requiresDateRange && type.maxDaysPerRequest != null && startDate.value != null && endDate.value != null) {
      final diff = endDate.value!.difference(startDate.value!).inDays + 1;
      if (diff > type.maxDaysPerRequest!) {
        return 'Maksimal pengajuan ${type.maxDaysPerRequest} hari';
      }
    }
    
    for (final field in type.attachmentFields) {
      if (field.isRequired && attachments[field.id] == null) {
        return '${field.name} wajib dilampirkan';
      }
    }
    return null;
  }

  Future<void> submit({bool autoSubmit = false}) async {
    if (!formKey.currentState!.validate()) return;
    final extraError = validateForm();
    if (extraError != null) {
      Get.snackbar('Perhatian', extraError, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final item = await _service.createSubmission(
        typeId: selectedType.value!.id,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        startDate: startDate.value!,
        endDate: requiresDateRange ? endDate.value : null,
        startTime: requiresTimeRange && startTime.value != null ? _formatTime(startTime.value!) : null,
        endTime: requiresTimeRange && endTime.value != null ? _formatTime(endTime.value!) : null,
        attachments: Map.from(attachments),
        autoSubmit: autoSubmit,
        isWfhFromHome: isWfhFromHome.value,
      );

      if (Get.isRegistered<SubmissionController>()) {
        Get.find<SubmissionController>().addSubmission(item);
      }

      FocusManager.instance.primaryFocus?.unfocus();
      Get.back();
      final msg = autoSubmit ? 'Pengajuan berhasil dikirim' : 'Draft pengajuan berhasil disimpan';
      Get.snackbar('Berhasil', msg,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan pengajuan: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
