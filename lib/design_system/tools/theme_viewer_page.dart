import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/app_button.dart';
import '../components/app_card.dart';
import '../components/app_chip.dart';
import '../components/app_text_field.dart';
import '../components/atoms/app_typography_text.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

class ThemeViewerPage extends StatefulWidget {
  const ThemeViewerPage({super.key});

  @override
  State<ThemeViewerPage> createState() => _ThemeViewerPageState();
}

class _ThemeViewerPageState extends State<ThemeViewerPage> {
  bool _isDark = false;
  double _primaryHue = 150; // default: green ~150°
  double _fontScale = 1.0;
  String _fontFamily = 'Outfit';
  bool _chipSelected = false;

  static const _fontOptions = ['Outfit', 'Inter', 'Poppins', 'Roboto', 'Lato', 'Nunito'];

  ThemeData _buildPreviewTheme() {
    final hsvColor = HSVColor.fromAHSV(1, _primaryHue, 0.85, 0.5);
    final primary = hsvColor.toColor();
    final onPrimary = _primaryHue > 50 && _primaryHue < 200 ? Colors.white : Colors.black87;

    final previewColors = AppColors.light.copyWith(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: HSVColor.fromAHSV(1, _primaryHue, 0.3, 0.95).toColor(),
    );

    final scaledTypography = AppTypography(
      displaySmall: GoogleFonts.getFont(_fontFamily, fontSize: 36 * _fontScale, fontWeight: FontWeight.bold, height: 1.2),
      headlineMedium: GoogleFonts.getFont(_fontFamily, fontSize: 28 * _fontScale, fontWeight: FontWeight.bold, height: 1.2),
      headlineSmall: GoogleFonts.getFont(_fontFamily, fontSize: 24 * _fontScale, fontWeight: FontWeight.bold, height: 1.25),
      titleLarge: GoogleFonts.getFont(_fontFamily, fontSize: 22 * _fontScale, fontWeight: FontWeight.w600, height: 1.3),
      titleMedium: GoogleFonts.getFont(_fontFamily, fontSize: 16 * _fontScale, fontWeight: FontWeight.w600, height: 1.4),
      titleSmall: GoogleFonts.getFont(_fontFamily, fontSize: 14 * _fontScale, fontWeight: FontWeight.w600, height: 1.4),
      h1: GoogleFonts.getFont(_fontFamily, fontSize: 32 * _fontScale, fontWeight: FontWeight.bold, height: 1.2),
      h2: GoogleFonts.getFont(_fontFamily, fontSize: 24 * _fontScale, fontWeight: FontWeight.bold, height: 1.2),
      h3: GoogleFonts.getFont(_fontFamily, fontSize: 20 * _fontScale, fontWeight: FontWeight.w600, height: 1.2),
      bodyLarge: GoogleFonts.getFont(_fontFamily, fontSize: 16 * _fontScale, fontWeight: FontWeight.normal, height: 1.5),
      bodyMedium: GoogleFonts.getFont(_fontFamily, fontSize: 14 * _fontScale, fontWeight: FontWeight.normal, height: 1.5),
      bodySmall: GoogleFonts.getFont(_fontFamily, fontSize: 12 * _fontScale, fontWeight: FontWeight.normal, height: 1.5),
      labelLarge: GoogleFonts.getFont(_fontFamily, fontSize: 14 * _fontScale, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: GoogleFonts.getFont(_fontFamily, fontSize: 12 * _fontScale, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelSmall: GoogleFonts.getFont(_fontFamily, fontSize: 11 * _fontScale, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      caption: GoogleFonts.getFont(_fontFamily, fontSize: 10 * _fontScale, fontWeight: FontWeight.normal, height: 1.4),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: _isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: _isDark ? Brightness.dark : Brightness.light,
        primary: previewColors.primary,
        onPrimary: previewColors.onPrimary,
        primaryContainer: previewColors.primaryContainer,
        onPrimaryContainer: previewColors.onPrimaryContainer,
        secondary: previewColors.secondary,
        onSecondary: previewColors.onSecondary,
        surface: previewColors.surface,
        onSurface: previewColors.onSurface,
        error: previewColors.error,
        onError: previewColors.onError,
        outline: previewColors.outline,
      ),
      scaffoldBackgroundColor: previewColors.background,
      extensions: [previewColors, scaledTypography],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildPreviewTheme(),
      child: Builder(
        builder: (ctx) {
          final colors = Theme.of(ctx).extension<AppColors>()!;
          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              title: const Text('Theme Viewer'),
              centerTitle: true,
            ),
            body: Column(
              children: [
                _buildControls(ctx, colors),
                const Divider(height: 1),
                Expanded(child: _buildPreview(ctx)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls(BuildContext context, AppColors colors) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dark_mode_outlined, size: 18),
              const SizedBox(width: 8),
              const Text('Dark Mode'),
              const Spacer(),
              Switch(
                value: _isDark,
                onChanged: (v) => setState(() => _isDark = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _primaryHue,
                  min: 0,
                  max: 360,
                  divisions: 36,
                  label: 'Hue ${_primaryHue.toInt()}°',
                  onChanged: (v) => setState(() => _primaryHue = v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.text_fields, size: 18),
              const SizedBox(width: 8),
              Text('${(_fontScale * 100).toInt()}%'),
              Expanded(
                child: Slider(
                  value: _fontScale,
                  min: 0.8,
                  max: 1.5,
                  divisions: 14,
                  onChanged: (v) => setState(() => _fontScale = v),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _fontOptions.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: _fontFamily == f,
                    onSelected: (_) => setState(() => _fontFamily = f),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.h2('Typography Preview'),
          const SizedBox(height: 8),
          AppText.titleLarge('Title Large'),
          AppText.titleMedium('Title Medium'),
          AppText.bodyLarge('Body Large — Lorem ipsum dolor sit amet.'),
          AppText.bodyMedium('Body Medium — Lorem ipsum dolor sit amet.'),
          AppText.bodySmall('Body Small — Lorem ipsum dolor sit amet.'),
          AppText.caption('Caption — Lorem ipsum dolor sit amet.'),
          const SizedBox(height: 16),
          AppText.h2('Buttons'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: AppButton(label: 'Filled', onPressed: () {})),
              const SizedBox(width: 8),
              Expanded(child: AppButton(label: 'Outlined', style: AppButtonStyle.outlined, onPressed: () {})),
              const SizedBox(width: 8),
              Expanded(child: AppButton(label: 'Ghost', style: AppButtonStyle.ghost, onPressed: () {})),
            ],
          ),
          const SizedBox(height: 16),
          AppText.h2('Input'),
          const SizedBox(height: 8),
          const AppTextField(label: 'Nama Lengkap', hint: 'Masukkan nama'),
          const SizedBox(height: 16),
          AppText.h2('Cards & Chips'),
          const SizedBox(height: 8),
          AppCard(
            child: AppText.bodyMedium('Card content goes here.'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              AppChip(
                label: 'Chip 1',
                isSelected: _chipSelected,
                onSelected: (v) => setState(() => _chipSelected = v),
              ),
              AppChip(label: 'Chip 2', isSelected: false),
              AppChip(label: 'Chip 3', isSelected: true),
            ],
          ),
        ],
      ),
    );
  }
}
