import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../features/kinerja/data/services/kinerja_service.dart';
import '../../features/presensi/data/repositories/attendance_history_repository.dart';
import '../../features/presensi/data/repositories/presensi_repository.dart';
import '../../features/presensi/data/services/face_service.dart';
import '../../features/presensi/data/services/location_service.dart';
import '../../features/presensi/presentation/controllers/presensi_controller.dart';
import '../../features/informasi/presentation/controllers/informasi_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/profile/presentation/controllers/theme_controller.dart';
import '../../features/submission/data/services/submission_service.dart';
import '../../features/submission/presentation/controllers/submission_controller.dart';

/// Mendaftarkan semua dependency global aplikasi saat startup.
/// Didaftarkan sekali via [GetMaterialApp.initialBinding].
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // -------------------------------------------------------------------------
    //  HTTP Client
    // -------------------------------------------------------------------------
    final dio = Dio(
      BaseOptions(
        baseUrl: '${AppConstants.apiBaseUrl}/api/${AppConstants.apiVersion}',
        connectTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
        headers: {'Accept': 'application/json'},
      ),
    );
    Get.put<Dio>(dio, permanent: true);

    // -------------------------------------------------------------------------
    //  Services
    // -------------------------------------------------------------------------
    Get.put<FaceService>(FaceService(dio), permanent: true);
    Get.put<LocationService>(LocationService(), permanent: true);

    // -------------------------------------------------------------------------
    //  Repositories — gunakan Mock selama API belum ready
    // -------------------------------------------------------------------------
    Get.put<PresensiRepository>(
      MockPresensiRepository(),
      permanent: true,
    );
    Get.put<AttendanceHistoryRepository>(
      MockAttendanceHistoryRepository(),
      permanent: true,
    );

    // -------------------------------------------------------------------------
    //  Controllers
    // -------------------------------------------------------------------------
    Get.put<PresensiController>(
      PresensiController(
        repository: Get.find<PresensiRepository>(),
        faceService: Get.find<FaceService>(),
        locationService: Get.find<LocationService>(),
      ),
      permanent: true,
    );

    // -------------------------------------------------------------------------
    //  Submission — gunakan Mock selama API belum ready
    // -------------------------------------------------------------------------
    Get.put<SubmissionService>(MockSubmissionService(), permanent: true);
    Get.put<SubmissionController>(
      SubmissionController(service: Get.find<SubmissionService>()),
      permanent: true,
    );

    // -------------------------------------------------------------------------
    //  Kinerja — gunakan Mock selama API belum ready
    // -------------------------------------------------------------------------
    Get.put<KinerjaService>(MockKinerjaService(), permanent: true);

    // -------------------------------------------------------------------------
    //  Profile
    // -------------------------------------------------------------------------
    Get.put<ProfileController>(ProfileController(), permanent: true);

    // -------------------------------------------------------------------------
    //  Theme
    // -------------------------------------------------------------------------
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // -------------------------------------------------------------------------
    //  Informasi
    // -------------------------------------------------------------------------
    Get.put<InformasiController>(InformasiController(), permanent: true);
  }
}
