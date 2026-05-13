import 'dart:async';
import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_duration.dart';
import '../../tokens/app_icon_size.dart';
import '../../tokens/app_opacity.dart';
import '../../tokens/app_radius.dart';
import '../../tokens/app_spacing.dart';
import '../../tokens/app_typography.dart';

class AppSearchBar extends StatefulWidget {
  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;
  final String placeholder;
  final int debounceMs;
  final TextEditingController? controller;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    this.onSearch,
    this.onClear,
    this.placeholder = 'Cari...',
    this.debounceMs = 300,
    this.controller,
    this.autofocus = false,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  Timer? _debounce;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onSearch?.call(_controller.text);
    });
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onSearch?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: AppOpacity.subtle),
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        style: typography.bodyMedium.copyWith(color: colors.onSurface),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
          prefixIcon: Icon(Icons.search, size: AppIconSize.md, color: colors.outline),
          suffixIcon: AnimatedSwitcher(
            duration: AppDuration.fast,
            child: _hasText
                ? IconButton(
                    key: const ValueKey('clear'),
                    icon: Icon(Icons.close, size: AppIconSize.md, color: colors.outline),
                    onPressed: _clear,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ),
      ),
    );
  }
}
