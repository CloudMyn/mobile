import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    Widget checkbox = Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: colors.primary,
      checkColor: colors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );

    if (label == null) return checkbox;

    return InkWell(
      onTap: () => onChanged?.call(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          checkbox,
          const SizedBox(width: AppSpacing.s4),
          Text(label!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class AppRadioButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final String? label;

  const AppRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    Widget radio = Radio<T>(
      value: value,
      // ignore: deprecated_member_use
      groupValue: groupValue,
      // ignore: deprecated_member_use
      onChanged: onChanged,
    );

    if (label == null) return radio;

    return InkWell(
      onTap: () => onChanged?.call(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          radio,
          const SizedBox(width: AppSpacing.s4),
          Text(label!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    Widget toggle = Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: colors.onPrimary,
      activeTrackColor: colors.primary,
      inactiveThumbColor: colors.outline,
      inactiveTrackColor: colors.outline.withValues(alpha: 0.2),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );

    if (label == null) return toggle;

    return InkWell(
      onTap: () => onChanged?.call(!value),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label!, style: Theme.of(context).textTheme.bodyMedium),
          toggle,
        ],
      ),
    );
  }
}
