import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../data/models/tpp_detail_model.dart';
import '../../data/services/statistik_service.dart';

class TppDetailController extends GetxController {
  TppDetailController({
    required StatistikService service,
    int? initialMonth,
    int? initialYear,
  })  : _service = service,
        selectedMonth = (initialMonth ?? DateTime.now().month).obs,
        selectedYear = (initialYear ?? DateTime.now().year).obs;

  final StatistikService _service;

  // ── State ───────────────────────────────────────────────────────────────────
  final Rx<TppDetailModel?> tppData = Rx<TppDetailModel?>(null);
  final RxInt selectedMonth;
  final RxInt selectedYear;
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  final List<String> monthNames = const [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  List<int> get availableYears {
    final current = DateTime.now().year;
    return [current, current - 1];
  }

  @override
  void onInit() {
    super.onInit();
    loadTpp();
  }

  Future<void> loadTpp({int? month, int? year}) async {
    final m = month ?? selectedMonth.value;
    final y = year ?? selectedYear.value;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final res = await _service.fetchMyTpp(month: m, year: y);
      tppData.value = res;
      selectedMonth.value = m;
      selectedYear.value = y;
    } on NetworkException {
      errorMessage.value = 'Tidak ada koneksi internet.';
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        tppData.value = null;
        errorMessage.value = null;
      } else {
        errorMessage.value = e.message;
      }
    } catch (_) {
      errorMessage.value = 'Gagal memuat detail TPP.';
    } finally {
      isLoading.value = false;
    }
  }

  void changeMonth(int month) {
    if (month == selectedMonth.value) return;
    loadTpp(month: month, year: selectedYear.value);
  }

  void changeYear(int year) {
    if (year == selectedYear.value) return;
    loadTpp(month: selectedMonth.value, year: year);
  }

  Future<void> refreshData() => loadTpp();
}
