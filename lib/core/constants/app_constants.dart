/// [AppConstants] — Centralized constants for the entire application.
///
/// Semua informasi penting seperti nama aplikasi, aset logo,
/// dan versioning dikelola di satu tempat agar mudah dipelihara.
class AppConstants {
  // =========================================================================
  //  Aplikasi
  // =========================================================================

  /// Nama aplikasi — digunakan di title bar, metadata, dll.
  static const String appName = 'Masseddi';

  /// Nama pendek untuk notifikasi atau konteks informal.
  static const String appNameShort = 'Masseddi';

  /// Deskripsi lengkap aplikasi.
  static const String appDescription =
      'E-Office Masseddi merupakan aplikasi presensi dan e-kinerja, Masseddi sendiri berasal dari Kalimat Manajemen Presensi Dan Disiplin';

  /// Nama perusahaan/instansi.
  static const String appOrganization = 'Pemerintah Kabupaten Barru';

  // =========================================================================
  //  Versi & Build
  // =========================================================================

  /// Semantic version (major.minor.patch) — dibaca dari pubspec.yaml.
  static const String versionName = '1.1.4';

  /// Build number — dibaca dari pubspec.yaml (angka setelah '+').
  static const int buildNumber = 1;

  /// Versi lengkap untuk ditampilkan di UI (contoh: "v1.0.0+1").
  static String get fullVersion => 'v$versionName+$buildNumber';

  /// Versi untuk perbandingan di API (contoh: "1.0.0+1").
  static String get versionWithBuild => '$versionName+$buildNumber';

  /// Tahun rilis aplikasi.
  static const String releaseYear = '2026';

  // =========================================================================
  //  Logo — path aset gambar
  // =========================================================================

  /// Logo untuk tema terang (light mode).
  /// Simpan di: assets/images/logo_light.png
  static const String logoLight = 'assets/images/logo_light.png';

  /// Logo untuk tema gelap (dark mode).
  /// Simpan di: assets/images/logo_dark.png
  static const String logoDark = 'assets/images/logo_dark.png';

  /// Logo ikon kecil (favicon-style) — untuk AppBar, splash, dll.
  /// Simpan di: assets/images/logo_icon.png
  static const String logoIcon = 'assets/images/logo_icon.png';

  // =========================================================================
  //  URL & Tautan
  // =========================================================================

  /// Website resmi (jika ada).
  static const String websiteUrl = 'https://masseddi.barrukab.go.id/';

  /// Kebijakan privasi (jika ada).
  static const String privacyPolicyUrl =
      'https://masseddi.barrukab.go.id/privacy';

  /// Syarat & ketentuan (jika ada).
  static const String termsOfServiceUrl =
      'https://masseddi.barrukab.go.id/terms';

  /// Halaman FAQ aplikasi.
  static const String faqUrl = 'https://masseddi.barrukab.go.id/faq';

  // =========================================================================
  //  Preferensi Penyimpanan (SharedPreferences keys)
  // =========================================================================

  /// Key untuk menyimpan token autentikasi (shared_prefs — deprecated, pakai SecureStorage).
  static const String prefAuthToken = 'auth_token';

  // =========================================================================
  //  Secure Storage Keys (FlutterSecureStorage)
  // =========================================================================

  /// Bearer token dari login — disimpan di secure storage.
  static const String secureKeyAccessToken = 'access_token';

  /// Device UUID — di-generate sekali, disimpan permanen di secure storage.
  static const String secureKeyDeviceUuid = 'device_uuid';

  /// Key untuk menyimpan preferensi "ingat saya".
  static const String prefRememberMe = 'remember_me';

  /// Key untuk menyimpan email terakhir yang digunakan.
  static const String prefLastEmail = 'last_email';

  /// Key untuk menyimpan tema yang dipilih pengguna.
  static const String prefThemeMode = 'theme_mode';

  /// Key untuk menyimpan status onboarding.
  static const String prefOnboardingDone = 'onboarding_done';

  /// Key untuk menyimpan koordinat latitude terakhir presensi berhasil.
  static const String prefLastSuccessLatitude = 'last_success_latitude';

  /// Key untuk menyimpan koordinat longitude terakhir presensi berhasil.
  static const String prefLastSuccessLongitude = 'last_success_longitude';

  /// Key untuk menyimpan timestamp terakhir presensi berhasil.
  static const String prefLastSuccessTimestamp = 'last_success_timestamp';

  // =========================================================================
  //  Jaringan (API)
  // =========================================================================

  /// Base URL API — sesuaikan dengan environment.
  static const String apiBaseUrl = 'https://masseddi-api.barrukab.go.id';

  /// Default timeout untuk request HTTP (dalam detik).
  static const int apiTimeoutSeconds = 30;

  /// Versi API yang digunakan.
  static const String apiVersion = 'v1';

  // =========================================================================
  //  Pagination
  // =========================================================================

  /// Jumlah item default per halaman.
  static const int defaultPageSize = 20;

  /// Jumlah item maksimum per halaman.
  static const int maxPageSize = 100;

  // =========================================================================
  //  Upload Gambar
  // =========================================================================

  /// Dimensi maksimum gambar (lebar/tinggi) — gambar akan di-resize
  /// mempertahankan aspect ratio agar tidak melebihi nilai ini.
  static const int maxImageDimension = 1080;

  /// Ukuran maksimum file gambar (dalam KB) — gambar akan dikompresi
  /// iteratif hingga di bawah batas ini.
  static const int maxUploadFileSizeKB = 50;

  /// Memetakan domain pengembangan lokal (seperti minio-masseddi.test, localhost)
  /// ke host dari apiBaseUrl agar dapat diakses dari emulator/perangkat fisik.
  static String sanitizeImageUrl(String url) {
    if (url.isEmpty) return url;

    if (url.startsWith('http')) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        final host = uri.host;
        if (host == 'minio-masseddi.test' ||
            host == 'localhost' ||
            host == '127.0.0.1') {
          final apiUri = Uri.tryParse(apiBaseUrl);
          if (apiUri != null) {
            final apiHost = apiUri.host;
            if (apiHost != host) {
              return url.replaceFirst(host, apiHost);
            }
          }
        }
      }
    }
    return url;
  }
}
