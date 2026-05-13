import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_typography.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  const AppText._(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  factory AppText.displaySmall(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.displaySmall, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.headlineMedium(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.headlineMedium, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.headlineSmall(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.headlineSmall, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.titleLarge(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.titleLarge, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.titleMedium(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.titleMedium, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.titleSmall(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.titleSmall, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.h1(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.h1, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.h2(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.h2, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.h3(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.h3, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.bodyLarge(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.bodyLarge, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.bodyMedium(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.bodyMedium, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.bodySmall(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.bodySmall, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.labelLarge(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.labelLarge, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.labelMedium(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.labelMedium, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.labelSmall(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.labelSmall, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.caption(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      _AppTypedText(text, key: key, variant: _Variant.caption, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        color: color ?? colors.onSurface,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

enum _Variant {
  displaySmall, headlineMedium, headlineSmall,
  titleLarge, titleMedium, titleSmall,
  h1, h2, h3,
  bodyLarge, bodyMedium, bodySmall,
  labelLarge, labelMedium, labelSmall,
  caption,
}

class _AppTypedText extends AppText {
  final _Variant variant;

  const _AppTypedText(
    super.text, {
    super.key,
    required this.variant,
    super.color,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) : super._();

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypography>()!;
    final colors = Theme.of(context).extension<AppColors>()!;

    final base = switch (variant) {
      _Variant.displaySmall => typography.displaySmall,
      _Variant.headlineMedium => typography.headlineMedium,
      _Variant.headlineSmall => typography.headlineSmall,
      _Variant.titleLarge => typography.titleLarge,
      _Variant.titleMedium => typography.titleMedium,
      _Variant.titleSmall => typography.titleSmall,
      _Variant.h1 => typography.h1,
      _Variant.h2 => typography.h2,
      _Variant.h3 => typography.h3,
      _Variant.bodyLarge => typography.bodyLarge,
      _Variant.bodyMedium => typography.bodyMedium,
      _Variant.bodySmall => typography.bodySmall,
      _Variant.labelLarge => typography.labelLarge,
      _Variant.labelMedium => typography.labelMedium,
      _Variant.labelSmall => typography.labelSmall,
      _Variant.caption => typography.caption,
    };

    return Text(
      text,
      style: base.copyWith(color: color ?? colors.onSurface),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
