import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../network/auth_interceptor.dart';
import '../network/session_manager.dart';
import '../network/token_storage.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/home/data/services/dashboard_service.dart';
import '../../features/home/data/services/statistik_service.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/home/presentation/controllers/statistik_controller.dart';
import '../../features/informasi/data/services/informasi_service.dart';
import '../../features/informasi/presentation/controllers/informasi_controller.dart';
import '../../features/kinerja/data/services/kinerja_service.dart';
import '../../features/kinerja/presentation/controllers/kinerja_controller.dart';
import '../../features/presensi/data/repositories/attendance_history_repository.dart';
import '../../features/presensi/data/repositories/presensi_repository.dart';
import '../../features/presensi/data/services/face_service.dart';
import '../../features/presensi/data/services/location_service.dart';
import '../../features/presensi/presentation/controllers/presensi_controller.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/profile/presentation/controllers/theme_controller.dart';
import '../../features/submission/data/services/submission_service.dart';
import '../../features/submission/presentation/controllers/submission_controller.dart';

/// Mendaftarkan semua dependency global.
/// Async deps (SharedPreferences, FlutterSecureStorage) di-inisialisasi
/// di main() sebelum runApp() — bukan di sini — agar dependencies() tetap
/// synchronous dan GetX tidak melewatkan registrasi.
class AppBindings extends Bindings {
  AppBindings({
    required this.prefs,
    required this.secureStorage,
  });

  final SharedPreferences prefs;
  final FlutterSecureStorage secureStorage;

  @override
  void dependencies() {
    // ── Penyimpanan ─────────────────────────────────────────────────────────
    Get.put<SharedPreferences>(prefs, permanent: true);
    Get.put<FlutterSecureStorage>(secureStorage, permanent: true);

    final tokenStorage = TokenStorage(secureStorage);
    Get.put<TokenStorage>(tokenStorage, permanent: true);

    // ── Session ─────────────────────────────────────────────────────────────
    Get.put<SessionManager>(SessionManager(), permanent: true);

    // ── HTTP Client ─────────────────────────────────────────────────────────
    final dio = Dio(
      BaseOptions(
        baseUrl: '${AppConstants.apiBaseUrl}/api/${AppConstants.apiVersion}',
        connectTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(AuthInterceptor(tokenStorage));
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (object) => debugPrint('[Dio] $object'),
    ));
    Get.put<Dio>(dio, permanent: true);

    // ── Auth ─────────────────────────────────────────────────────────────────
    Get.put<AuthService>(AuthService(dio, tokenStorage), permanent: true);

    // ── Dashboard & Statistik ────────────────────────────────────────────────
    Get.put<DashboardService>(DashboardService(dio), permanent: true);
    Get.put<StatistikService>(StatistikService(dio), permanent: true);

    // ── Presensi ─────────────────────────────────────────────────────────────
    Get.put<FaceService>(FaceService(), permanent: true);
    Get.put<LocationService>(LocationService(), permanent: true);

    Get.put<PresensiRepository>(
      PresensiRepositoryImpl(dio),
      permanent: true,
    );
    Get.put<AttendanceHistoryRepository>(
      MockAttendanceHistoryRepository(),
      permanent: true,
    );

    Get.put<PresensiController>(
      PresensiController(
        repository: Get.find<PresensiRepository>(),
        faceService: Get.find<FaceService>(),
        locationService: Get.find<LocationService>(),
        tokenStorage: tokenStorage,
      ),
      permanent: true,
    );

    // ── Submission ────────────────────────────────────────────────────────────
    Get.put<SubmissionService>(MockSubmissionService(), permanent: true);
    Get.put<SubmissionController>(
      SubmissionController(service: Get.find<SubmissionService>()),
      permanent: true,
    );

    // ── Kinerja ───────────────────────────────────────────────────────────────
    Get.put<KinerjaService>(MockKinerjaService(), permanent: true);
    Get.put<KinerjaController>(
      KinerjaController(service: Get.find<KinerjaService>()),
      permanent: true,
    );

    // ── Home ──────────────────────────────────────────────────────────────────
    Get.put<HomeController>(
      HomeController(dashboardService: Get.find<DashboardService>()),
      permanent: true,
    );

    // StatistikController — lazy: dibuat saat StatistikPage pertama kali dibuka
    Get.lazyPut<StatistikController>(
      () => StatistikController(service: Get.find<StatistikService>()),
      fenix: true,
    );

    // ── Profile ───────────────────────────────────────────────────────────────
    Get.put<ProfileRepository>(ProfileRepositoryImpl(dio), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);

    // ── Theme ─────────────────────────────────────────────────────────────────
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // ── Informasi ─────────────────────────────────────────────────────────────
    Get.put<InformasiService>(InformasiService(dio), permanent: true);
    Get.put<InformasiController>(
      InformasiController(service: Get.find<InformasiService>()),
      permanent: true,
    );
  }
}
