import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Bungkus widget dengan semantic label, hint, dan value untuk aksesibilitas.
class SemanticsWrapper extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool isButton;
  final bool isHeader;
  final bool excludeSemantics;

  const SemanticsWrapper({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.isButton = false,
    this.isHeader = false,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      header: isHeader,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }
}

/// Cek WCAG AA contrast ratio antara dua warna.
/// Minimum: 4.5:1 untuk teks normal, 3:1 untuk teks besar.
class AppContrastChecker {
  static double contrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static bool passesAA(Color foreground, Color background, {bool largeText = false}) {
    final ratio = contrastRatio(foreground, background);
    return largeText ? ratio >= 3.0 : ratio >= 4.5;
  }

  static bool passesAAA(Color foreground, Color background, {bool largeText = false}) {
    final ratio = contrastRatio(foreground, background);
    return largeText ? ratio >= 4.5 : ratio >= 7.0;
  }

  static double _relativeLuminance(Color color) {
    final r = _linearize(color.r);
    final g = _linearize(color.g);
    final b = _linearize(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double channel) {
    return channel <= 0.04045 ? channel / 12.92 : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }
}

extension DSSemanticLabel on Widget {
  Widget withSemantics({
    String? label,
    String? hint,
    String? value,
    bool isButton = false,
    bool isHeader = false,
  }) {
    return SemanticsWrapper(
      label: label,
      hint: hint,
      value: value,
      isButton: isButton,
      isHeader: isHeader,
      child: this,
    );
  }
}
