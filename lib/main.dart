import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/di/app_bindings.dart';
import 'core/utils/restart_helper.dart';
import 'design_system/theme/app_theme.dart';
import 'features/auth/presentation/pages/splash_page.dart';

class AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (host.endsWith('barrukab.go.id')) {
          return true;
        }
        return false;
      };
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = AppHttpOverrides();
  await initializeDateFormatting('id_ID', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inisialisasi async dependencies sebelum runApp agar AppBindings
  // bisa tetap synchronous dan GetX tidak melewatkan registrasi.
  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: false,
      resetOnError: true,
    ),
  );

  runApp(
    RestartWidget(
      child: MyApp(prefs: prefs, secureStorage: secureStorage),
    ),
  );
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
    return LayoutBuilder(
      builder: (context, constraints) {
        const maxMobileWidth = 430.0;
        final isWide = constraints.maxWidth > maxMobileWidth;
        
        // Agar flutter_screenutil (.w, .h, .sp) tetap menghitung skala secara proporsional 
        // terhadap maxMobileWidth (430) dan bukan terhadap lebar asli tablet (misal 1000px), 
        // kita menyesuaikan designWidth dengan rumus matematika:
        final realWidth = constraints.maxWidth;
        final designWidth = isWide 
            ? (realWidth * 375.0 / maxMobileWidth) 
            : 375.0;

        return ScreenUtilInit(
          designSize: Size(designWidth, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, _) => GetMaterialApp(
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
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              
              if (!isWide) {
                return child ?? const SizedBox();
              }

              // Timpa MediaQuery agar widget child membaca ukuran maxMobileWidth (430)
              final constrainedMediaQueryData = mediaQuery.copyWith(
                size: Size(maxMobileWidth, mediaQuery.size.height),
              );

              return Container(
                color: Colors.black12,
                child: Center(
                  child: SizedBox(
                    width: maxMobileWidth,
                    height: mediaQuery.size.height,
                    child: MediaQuery(
                      data: constrainedMediaQueryData,
                      child: child ?? const SizedBox(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
