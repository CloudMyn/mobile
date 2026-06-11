import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../logging/request_log_db.dart';
import '../logging/request_log_interceptor.dart';
import '../network/auth_interceptor.dart';
import '../network/session_manager.dart';
import '../network/token_storage.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/home/data/services/dashboard_service.dart';
import '../../features/home/data/services/notification_service.dart';
import '../../features/home/data/services/statistik_service.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/home/presentation/controllers/notification_controller.dart';
import '../../features/home/presentation/controllers/statistik_controller.dart';
import '../../features/informasi/data/services/informasi_service.dart';
import '../../features/informasi/presentation/controllers/informasi_controller.dart';
import '../../features/kinerja/data/services/kinerja_bawahan_service.dart';
import '../../features/kinerja/data/services/kinerja_service.dart';
import '../../features/kinerja/presentation/controllers/kinerja_bawahan_controller.dart';
import '../../features/kinerja/presentation/controllers/kinerja_controller.dart';
import '../../features/kinerja/presentation/controllers/kinerja_statistik_controller.dart';
import '../../features/presensi/data/repositories/attendance_history_repository.dart';
import '../../features/presensi/data/repositories/presensi_repository.dart';
import '../../features/presensi/data/services/face_service.dart';
import '../../features/presensi/data/services/location_service.dart';
import '../../features/presensi/presentation/controllers/presensi_controller.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/profile/presentation/controllers/request_log_controller.dart';
import '../../features/profile/presentation/controllers/theme_controller.dart';
import '../../features/submission/data/services/submission_lookup_service.dart';
import '../../features/submission/data/services/submission_service.dart';
import '../../features/submission/data/services/subordinate_submission_service.dart';
import '../../features/submission/presentation/controllers/submission_controller.dart';
import '../../features/submission/presentation/controllers/subordinate_submission_controller.dart';

/// Mendaftarkan semua dependency global.
/// Async deps (SharedPreferences, FlutterSecureStorage) di-inisialisasi
/// di main() sebelum runApp() — bukan di sini — agar dependencies() tetap
/// synchronous dan GetX tidak melewatkan registrasi.
class AppBindings extends Bindings {
  AppBindings({required this.prefs, required this.secureStorage});

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
    // Bypass SSL certificate validation for barrukab.go.id to support devices with out-of-date root certs (e.g. Android 14)
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          if (host.endsWith('barrukab.go.id')) {
            return true;
          }
          return false;
        };
        return client;
      },
    );
    dio.interceptors.add(AuthInterceptor(tokenStorage));
    dio.interceptors.add(RequestLogInterceptor(RequestLogDb.instance));
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (object) => debugPrint('[Dio] $object'),
      ),
    );
    Get.put<Dio>(dio, permanent: true);

    // ── Auth ─────────────────────────────────────────────────────────────────
    Get.put<AuthService>(AuthService(dio, tokenStorage), permanent: true);

    // ── Dashboard & Statistik ────────────────────────────────────────────────
    Get.put<DashboardService>(DashboardService(dio), permanent: true);
    Get.put<NotificationService>(NotificationService(dio), permanent: true);
    Get.put<StatistikService>(StatistikService(dio), permanent: true);

    // ── Presensi ─────────────────────────────────────────────────────────────
    Get.put<FaceService>(FaceService(), permanent: true);
    Get.put<LocationService>(LocationService(), permanent: true);

    Get.put<PresensiRepository>(PresensiRepositoryImpl(dio), permanent: true);
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
    Get.put<SubordinateSubmissionService>(MockSubordinateSubmissionService(), permanent: true);
    Get.put<SubmissionLookupService>(
      SubmissionLookupService(dio),
      permanent: true,
    );
    Get.put<SubmissionController>(
      SubmissionController(service: Get.find<SubmissionService>()),
      permanent: true,
    );
    Get.put<SubordinateSubmissionController>(
      SubordinateSubmissionController(service: Get.find<SubordinateSubmissionService>()),
      permanent: true,
    );

    // ── Kinerja ───────────────────────────────────────────────────────────────
    Get.put<KinerjaService>(MockKinerjaService(), permanent: true);
    Get.put<KinerjaController>(
      KinerjaController(service: Get.find<KinerjaService>()),
      permanent: true,
    );

    Get.put<KinerjaBawahanService>(MockKinerjaBawahanService(), permanent: true);
    Get.put<KinerjaBawahanController>(
      KinerjaBawahanController(service: Get.find<KinerjaBawahanService>()),
      permanent: true,
    );

    Get.lazyPut<KinerjaStatistikController>(
      () => KinerjaStatistikController(service: Get.find<KinerjaService>()),
      fenix: true,
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
    Get.lazyPut<NotificationController>(
      () => NotificationController(
        service: Get.find<NotificationService>(),
        submissionLookupService: Get.find<SubmissionLookupService>(),
      ),
      fenix: true,
    );

    // ── Profile ───────────────────────────────────────────────────────────────
    Get.put<ProfileRepository>(ProfileRepositoryImpl(dio), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);

    // ── Theme ─────────────────────────────────────────────────────────────────
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // ── Request Log ──────────────────────────────────────────────────────────
    Get.lazyPut<RequestLogController>(
      () => RequestLogController(),
      fenix: true,
    );

    // ── Informasi ─────────────────────────────────────────────────────────────
    Get.put<InformasiService>(InformasiService(dio), permanent: true);
    Get.lazyPut<InformasiController>(
      () => InformasiController(service: Get.find<InformasiService>()),
      fenix: true,
    );
  }
}
