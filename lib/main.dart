import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/di/app_bindings.dart';
import 'design_system/theme/app_theme.dart';
import 'features/auth/presentation/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi async dependencies sebelum runApp agar AppBindings
  // bisa tetap synchronous dan GetX tidak melewatkan registrasi.
  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  runApp(MyApp(prefs: prefs, secureStorage: secureStorage));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.prefs,
    required this.secureStorage,
  });

  final SharedPreferences prefs;
  final FlutterSecureStorage secureStorage;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          initialBinding: AppBindings(
            prefs: prefs,
            secureStorage: secureStorage,
          ),
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const SplashPage(),
          defaultTransition: Transition.cupertino,
        );
      },
    );
  }
}
