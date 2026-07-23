import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../design_system/components/app_feedback.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';

class RunningLinkItem {
  final String label;
  final String? href;

  const RunningLinkItem({required this.label, this.href});
}

const List<RunningLinkItem> defaultRunningLinks = [
  RunningLinkItem(
    label: 'Berita',
    href: 'https://barrukab.go.id/category/berita/',
  ),
  RunningLinkItem(
    label: 'LPSE Barru',
    href:
        'https://spse.inaproc.id/?redirect=true&source=https%3A%2F%2Flpse.barrukab.go.id',
  ),
  RunningLinkItem(
    label: 'e-Kinerja',
    href: 'https://e-kinerja.barrukab.go.id/',
  ),
  RunningLinkItem(label: 'PPID', href: null),
  RunningLinkItem(label: 'e-Office', href: 'https://e-office.barrukab.go.id/'),
  RunningLinkItem(label: 'LAPOR!', href: 'https://www.lapor.go.id/'),
  RunningLinkItem(label: 'Satu Data', href: 'https://bolata.barrukab.go.id/'),
  RunningLinkItem(label: 'KOTAKU', href: 'https://kotaku.com/'),
  RunningLinkItem(label: 'JDIH', href: 'https://jdih.barrukab.go.id/'),
  RunningLinkItem(label: 'Singgah', href: 'https://singgah.barrukab.go.id/'),
];

class RunningTextLinkCard extends StatefulWidget {
  final List<RunningLinkItem> items;
  final IconData icon;

  const RunningTextLinkCard({
    super.key,
    this.items = defaultRunningLinks,
    this.icon = Icons.campaign_rounded,
  });

  @override
  State<RunningTextLinkCard> createState() => _RunningTextLinkCardState();
}

class _RunningTextLinkCardState extends State<RunningTextLinkCard> {
  late final ScrollController _scrollController;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 35), (_) {
      if (!mounted || !_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) return;

      final current = _scrollController.offset;
      if (current >= maxScroll) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(current + 1.2);
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleItemTap(RunningLinkItem item) async {
    if (item.href == null || item.href!.trim().isEmpty) {
      AppFeedback.showSnackbar(
        title: item.label,
        message: 'Tautan belum tersedia.',
      );
      return;
    }

    final uri = Uri.tryParse(item.href!);
    if (uri != null) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          _showErrorSnackbar(item.label, item.href!);
        }
      } catch (_) {
        _showErrorSnackbar(item.label, item.href!);
      }
    } else {
      _showErrorSnackbar(item.label, item.href!);
    }
  }

  void _showErrorSnackbar(String label, String url) {
    AppFeedback.showSnackbar(
      title: 'Gagal Membuka Tautan',
      message: 'Tidak dapat membuka tautan untuk $label ($url)',
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    // Duplicate list for continuous infinite marquee scroll
    final displayItems = [...widget.items, ...widget.items];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.s12.h,
        horizontal: AppSpacing.s12.w,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.25),
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Row(
        children: [
          // Icon Badge
          Container(
            padding: EdgeInsets.all(AppSpacing.s4.w),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Icon(widget.icon, size: 20.sp, color: colors.primary),
          ),
          SizedBox(width: AppSpacing.s12.w),

          // Running Links Marquee Strip
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: displayItems.map((item) {
                  final hasLink = item.href != null && item.href!.isNotEmpty;
                  return Padding(
                    padding: EdgeInsets.only(right: AppSpacing.s16.w),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleItemTap(item),
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.s8.w,
                            vertical: AppSpacing.s4.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(AppRadius.r8),
                            border: Border.all(
                              color: colors.outline.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.label,
                                style: typography.caption.copyWith(
                                  color: hasLink
                                      ? colors.primary
                                      : colors.onSurface.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (hasLink) ...[
                                SizedBox(width: AppSpacing.s4.w),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  size: 12.sp,
                                  color: colors.primary.withValues(alpha: 0.8),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
