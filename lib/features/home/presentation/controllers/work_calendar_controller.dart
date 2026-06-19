import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../data/models/work_calendar_model.dart';
import '../../data/services/work_calendar_service.dart';

class WorkCalendarController extends GetxController {
  final WorkCalendarService _service;

  WorkCalendarController({required WorkCalendarService service})
      : _service = service;

  final currentMonth = DateTime.now().obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // Maps calendar_date to WorkCalendarModel for O(1) lookup
  final calendarDays = <DateTime, WorkCalendarModel>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi ke awal bulan
    final now = DateTime.now();
    currentMonth.value = DateTime(now.year, now.month);
    fetchCalendar(currentMonth.value.year, currentMonth.value.month);
  }

  void nextMonth() {
    final next = DateTime(currentMonth.value.year, currentMonth.value.month + 1);
    currentMonth.value = next;
    fetchCalendar(next.year, next.month);
  }

  void prevMonth() {
    final prev = DateTime(currentMonth.value.year, currentMonth.value.month - 1);
    currentMonth.value = prev;
    fetchCalendar(prev.year, prev.month);
  }

  Future<void> fetchCalendar(int year, int month) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _service.getMyWorkCalendar(year: year, month: month);

      final Map<DateTime, WorkCalendarModel> map = {};
      for (final item in data) {
        // Normalisasi waktu ke 00:00:00 untuk mempermudah pencarian key
        final dateKey = DateTime(
          item.calendarDate.year,
          item.calendarDate.month,
          item.calendarDate.day,
        );
        map[dateKey] = item;
      }

      calendarDays.value = map;
    } on ApiException catch (e) {
      if (e.statusCode == 400) {
        errorMessage.value = e.message.isNotEmpty
            ? e.message
            : 'Pegawai tidak terdaftar di instansi manapun saat ini.';
      } else {
        errorMessage.value = 'Gagal memuat kalender kerja.';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  WorkCalendarModel? getDayData(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return calendarDays[dateKey];
  }
}
