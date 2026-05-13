import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color error;
  final Color onError;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color outline;

  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.error,
    required this.onError,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.outline,
  });

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? background,
    Color? onBackground,
    Color? surface,
    Color? onSurface,
    Color? error,
    Color? onError,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? outline,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      outline: outline ?? this.outline,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimaryContainer: Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
    );
  }

  // Light Theme Palette (Premium Green)
  static const light = AppColors(
    primary: Color(0xFF006D3B), // Forest Green
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF98F7B5),
    onPrimaryContainer: Color(0xFF00210E),
    secondary: Color(0xFF4F6353),
    onSecondary: Colors.white,
    background: Color(0xFFFBFDF8),
    onBackground: Color(0xFF191C19),
    surface: Color(0xFFFBFDF8),
    onSurface: Color(0xFF191C19),
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    success: Color(0xFF2E7D32),
    onSuccess: Colors.white,
    warning: Color(0xFFED6C02),
    onWarning: Colors.white,
    outline: Color(0xFF717970),
  );


  // Dark Theme Palette
  static const dark = AppColors(
    primary: Color(0xFF7DDA9B),
    onPrimary: Color(0xFF00391C),
    primaryContainer: Color(0xFF00522B),
    onPrimaryContainer: Color(0xFF98F7B5),
    secondary: Color(0xFFB7CCB8),
    onSecondary: Color(0xFF213527),
    background: Color(0xFF191C19),
    onBackground: Color(0xFFE1E3DE),
    surface: Color(0xFF191C19),
    onSurface: Color(0xFFE1E3DE),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    success: Color(0xFF81C784),
    onSuccess: Color(0xFF003308),
    warning: Color(0xFFFFB74D),
    onWarning: Color(0xFF4B2800),
    outline: Color(0xFF8B9389),
  );
}
