import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_elevation.dart';
import '../../tokens/app_icon_size.dart';
import '../../tokens/app_spacing.dart';
import '../../tokens/app_typography.dart';
import '../molecules/app_search_bar.dart';

enum AppTopAppBarVariant { standard, withBack, withSearch, withActions }

class AppTopAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final AppTopAppBarVariant variant;
  final List<Widget>? actions;
  final ValueChanged<String>? onSearch;
  final String searchPlaceholder;
  final VoidCallback? onBack;
  final bool centerTitle;
  final double elevation;

  const AppTopAppBar({
    super.key,
    required this.title,
    this.variant = AppTopAppBarVariant.standard,
    this.actions,
    this.onSearch,
    this.searchPlaceholder = 'Cari...',
    this.onBack,
    this.centerTitle = true,
    this.elevation = AppElevation.none,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppTopAppBar> createState() => _AppTopAppBarState();
}

class _AppTopAppBarState extends State<AppTopAppBar> {
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    if (widget.variant == AppTopAppBarVariant.withSearch && _showSearch) {
      return AppBar(
        backgroundColor: colors.surface,
        elevation: widget.elevation,
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.s8,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: AppIconSize.lg,
              onPressed: () => setState(() => _showSearch = false),
            ),
            Expanded(
              child: AppSearchBar(
                placeholder: widget.searchPlaceholder,
                onSearch: widget.onSearch,
                autofocus: true,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
          ],
        ),
      );
    }

    return AppBar(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      elevation: widget.elevation,
      centerTitle: widget.centerTitle,
      automaticallyImplyLeading: widget.variant == AppTopAppBarVariant.withBack,
      leading: _buildLeading(colors),
      title: Text(widget.title, style: typography.h3.copyWith(color: colors.onSurface)),
      actions: _buildActions(colors),
    );
  }

  Widget? _buildLeading(AppColors colors) {
    if (widget.variant == AppTopAppBarVariant.withBack) {
      return IconButton(
        icon: Icon(Icons.arrow_back, size: AppIconSize.lg, color: colors.onSurface),
        onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
      );
    }
    return null;
  }

  List<Widget>? _buildActions(AppColors colors) {
    final actions = <Widget>[];

    if (widget.variant == AppTopAppBarVariant.withSearch) {
      actions.add(
        IconButton(
          icon: Icon(Icons.search, size: AppIconSize.lg, color: colors.onSurface),
          onPressed: () => setState(() => _showSearch = true),
        ),
      );
    }

    if (widget.actions != null) {
      actions.addAll(widget.actions!);
    }

    return actions.isEmpty ? null : actions;
  }
}
