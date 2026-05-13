import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/constants/app_constants.dart';
import 'core/di/app_bindings.dart';
import 'design_system/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ScreenUtil initialization for responsive layout
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13/14 size as base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          initialBinding: AppBindings(),

          // Theme Configuration — paksa light theme selalu
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          
          // Initial Route
          home: const LoginPage(),
          
          // Customizing GetX default behavior
          defaultTransition: Transition.cupertino,
        );
      },
    );
  }
}
