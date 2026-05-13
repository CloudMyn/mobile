import 'package:flutter/material.dart';
import '../tokens/app_border_width.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_duration.dart';
import '../tokens/app_elevation.dart';
import '../tokens/app_opacity.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppTheme {
  static ThemeData light = _buildTheme(AppColors.light, AppTypography.standard);
  static ThemeData dark = _buildTheme(AppColors.dark, AppTypography.standard);

  static ThemeData _buildTheme(AppColors colors, AppTypography typography) {
    final isDark = colors == AppColors.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        primaryContainer: colors.primaryContainer,
        onPrimaryContainer: colors.onPrimaryContainer,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        surface: colors.surface,
        onSurface: colors.onSurface,
        error: colors.error,
        onError: colors.onError,
        outline: colors.outline,
      ),
      scaffoldBackgroundColor: colors.background,
      extensions: [colors, typography],

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: AppElevation.none,
        shadowColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: typography.h3.copyWith(color: colors.onSurface),
        iconTheme: IconThemeData(color: colors.onSurface),
        actionsIconTheme: IconThemeData(color: colors.onSurface),
      ),

      // Card
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: AppElevation.sm,
        shadowColor: Colors.black.withValues(alpha: AppOpacity.light),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r12),
        ),
        margin: EdgeInsets.zero,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          textStyle: typography.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s24,
            vertical: AppSpacing.s12,
          ),
          elevation: AppElevation.sm,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
          animationDuration: AppDuration.normal,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: typography.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s24,
            vertical: AppSpacing.s12,
          ),
          side: BorderSide(color: colors.primary, width: AppBorderWidth.normal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
          animationDuration: AppDuration.normal,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: typography.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
          animationDuration: AppDuration.normal,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: AppElevation.md,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16),
        ),
      ),

      // Input fields — kunci sentralisasi TextField/Dropdown
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colors.surface.withValues(alpha: 0.6)
            : colors.primary.withValues(alpha: AppOpacity.subtle),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r8),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: AppOpacity.hint)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r8),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: AppOpacity.hint)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r8),
          borderSide: BorderSide(color: colors.primary, width: AppBorderWidth.medium),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r8),
          borderSide: BorderSide(color: colors.error, width: AppBorderWidth.normal),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r8),
          borderSide: BorderSide(color: colors.error, width: AppBorderWidth.medium),
        ),
        hintStyle: typography.bodyMedium.copyWith(
          color: colors.onSurface.withValues(alpha: AppOpacity.hint),
        ),
        labelStyle: typography.labelLarge.copyWith(color: colors.onSurface),
        errorStyle: typography.bodySmall.copyWith(color: colors.error),
        prefixIconColor: colors.outline,
        suffixIconColor: colors.outline,
      ),

      // Tabs
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.onSurface.withValues(alpha: AppOpacity.hint),
        labelStyle: typography.labelLarge,
        unselectedLabelStyle: typography.labelLarge,
        indicatorColor: colors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colors.onSurface : colors.onBackground,
        contentTextStyle: typography.bodyMedium.copyWith(color: colors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r8),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppElevation.md,
        insetPadding: const EdgeInsets.all(AppSpacing.s16),
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        elevation: AppElevation.xl,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r24)),
        ),
        showDragHandle: true,
        dragHandleColor: colors.outline.withValues(alpha: AppOpacity.medium),
        dragHandleSize: const Size(32, 4),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        elevation: AppElevation.xxl,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16),
        ),
        titleTextStyle: typography.titleLarge.copyWith(color: colors.onSurface),
        contentTextStyle: typography.bodyMedium.copyWith(color: colors.onSurface),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colors.outline.withValues(alpha: AppOpacity.light),
        thickness: AppBorderWidth.thin,
        space: AppBorderWidth.thin,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: colors.primaryContainer,
        labelStyle: typography.labelMedium,
        secondaryLabelStyle: typography.labelMedium.copyWith(color: colors.onPrimaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r8),
          side: BorderSide(color: colors.outline.withValues(alpha: AppOpacity.hint)),
        ),
        elevation: AppElevation.none,
        pressElevation: AppElevation.xs,
      ),

      // Selection controls
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colors.onPrimary),
        side: BorderSide(color: colors.outline, width: AppBorderWidth.medium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return colors.outline;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.onPrimary;
          return colors.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return colors.outline.withValues(alpha: AppOpacity.medium);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? colors.onSurface : colors.onBackground,
          borderRadius: BorderRadius.circular(AppRadius.r4),
        ),
        textStyle: typography.bodySmall.copyWith(color: colors.surface),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
        waitDuration: const Duration(milliseconds: 500),
      ),

      // Icon
      iconTheme: IconThemeData(
        color: colors.onSurface,
        size: 24,
      ),
      primaryIconTheme: IconThemeData(
        color: colors.onPrimary,
        size: 24,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        titleTextStyle: typography.bodyLarge.copyWith(color: colors.onSurface),
        subtitleTextStyle: typography.bodySmall.copyWith(
          color: colors.onSurface.withValues(alpha: AppOpacity.hint),
        ),
        leadingAndTrailingTextStyle: typography.labelMedium,
        iconColor: colors.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r12)),
        minLeadingWidth: 0,
      ),

      // NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return typography.labelSmall.copyWith(color: colors.primary);
          }
          return typography.labelSmall.copyWith(color: colors.outline);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.onPrimaryContainer, size: 24);
          }
          return IconThemeData(color: colors.outline, size: 24);
        }),
        elevation: AppElevation.sm,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Text theme — map DS typography ke M3 TextTheme
      textTheme: TextTheme(
        displaySmall: typography.displaySmall,
        headlineMedium: typography.headlineMedium,
        headlineSmall: typography.headlineSmall,
        titleLarge: typography.titleLarge,
        titleMedium: typography.titleMedium,
        titleSmall: typography.titleSmall,
        bodyLarge: typography.bodyLarge,
        bodyMedium: typography.bodyMedium,
        bodySmall: typography.bodySmall,
        labelLarge: typography.labelLarge,
        labelMedium: typography.labelMedium,
        labelSmall: typography.labelSmall,
      ),
    );
  }
}
