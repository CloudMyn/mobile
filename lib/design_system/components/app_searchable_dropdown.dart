import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'app_text_field.dart';

class AppSearchableDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemAsString;
  final ValueChanged<T?>? onChanged;
  final String? errorText;

  const AppSearchableDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    required this.itemAsString,
    this.onChanged,
    this.errorText,
  });

  void _showSearchDialog(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String searchQuery = '';
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label ?? 'Pilih Item',
                          style: typography.titleMedium.copyWith(color: colors.onSurface),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: colors.onSurface),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    AppTextField(
                      hint: 'Cari...',
                      prefixIcon: Icon(Icons.search, color: colors.outline),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Expanded(
                      child: ListView(
                        children: items.where((item) {
                          return itemAsString(item).toLowerCase().contains(searchQuery);
                        }).map((item) {
                          return ListTile(
                            title: Text(
                              itemAsString(item),
                              style: typography.bodyMedium.copyWith(color: colors.onSurface),
                            ),
                            onTap: () {
                              if (onChanged != null) {
                                onChanged!(item);
                              }
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: typography.labelLarge.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
        InkWell(
          onTap: items.isEmpty ? null : () => _showSearchDialog(context),
          borderRadius: BorderRadius.circular(AppRadius.r8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null ? colors.error : colors.outline,
              ),
              borderRadius: BorderRadius.circular(AppRadius.r8),
              color: colors.surface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value != null ? itemAsString(value as T) : (hint ?? 'Pilih'),
                    style: typography.bodyMedium.copyWith(
                      color: value != null ? colors.onSurface : colors.outline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: colors.outline),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: typography.bodySmall.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }
}
