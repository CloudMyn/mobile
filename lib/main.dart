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

  // Deteksi awal ukuran layar untuk menentukan orientasi tablet vs smartphone.
  // Ambang batas standar tablet adalah shortestSide >= 600 dp.
  final views = WidgetsBinding.instance.platformDispatcher.views;
  final view = views.isNotEmpty ? views.first : null;
  final isTabletEarly = view != null &&
      ((view.physicalSize.width / view.devicePixelRatio) < (view.physicalSize.height / view.devicePixelRatio)
          ? (view.physicalSize.width / view.devicePixelRatio)
          : (view.physicalSize.height / view.devicePixelRatio)) >= 600.0;

  if (isTabletEarly) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

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

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.prefs,
    required this.secureStorage,
  });

  final SharedPreferences prefs;
  final FlutterSecureStorage secureStorage;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _isTablet;

  void _updateOrientations(double shortestSide) {
    final isTabletDevice = shortestSide >= 600.0;
    if (_isTablet == isTabletDevice) return;
    _isTablet = isTabletDevice;

    if (isTabletDevice) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // shortestSide dari constraints untuk memastikan orientasi tablet tetap berlaku
        final shortestSide = constraints.biggest.shortestSide;
        if (shortestSide > 0 && shortestSide.isFinite) {
          _updateOrientations(shortestSide);
        }

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
              prefs: widget.prefs,
              secureStorage: widget.secureStorage,
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

              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              final backdropColor = isDark
                  ? const Color(0xFF0F172A) // Dark slate background
                  : const Color(0xFFF1F5F9); // Light slate background
              final shadowColor = isDark
                  ? Colors.black.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.12);

              return Container(
                color: backdropColor,
                child: Center(
                  child: Container(
                    width: maxMobileWidth,
                    height: mediaQuery.size.height,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
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
