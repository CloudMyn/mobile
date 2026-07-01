import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/molecules/app_empty_state.dart';
import '../../../../design_system/components/molecules/app_page_indicator.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../data/models/informasi_item.dart';
import '../controllers/informasi_controller.dart';
import '../widgets/active_filter_row.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/informasi_card.dart';
import '../widgets/informasi_pinned_card.dart';
import 'informasi_detail_page.dart';

class InformasiPage extends StatefulWidget {
  const InformasiPage({super.key});

  @override
  State<InformasiPage> createState() => _InformasiPageState();
}

class _InformasiPageState extends State<InformasiPage> {
  late final InformasiController _ctrl;
  final _pinnedPageCtrl = PageController();
  int _pinnedPage = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<InformasiController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.loadData();
    });
  }

  @override
  void dispose() {
    _pinnedPageCtrl.dispose();
    super.dispose();
  }

  void _openDetail(InformasiItem item) {
    Get.to(
      () => InformasiDetailPage(item: item),
      transition: Transition.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Informasi',
        variant: AppTopAppBarVariant.withActions,
        actions: [
          Obx(() {
            final hasFilter =
                _ctrl.selectedCategoryId.value != null ||
                _ctrl.dateRange.value != null;
            return IconButton(
              icon: Badge(
                isLabelVisible: hasFilter,
                backgroundColor: colors.primary,
                child: Icon(Icons.tune_rounded, color: colors.onSurface),
              ),
              onPressed: () => FilterBottomSheet.show(context),
            );
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _ctrl.loadData,
        child: Obx(() {
          final pinned = _ctrl.pinnedItems;
          final list = _ctrl.filteredItems;

          if (pinned.isEmpty && list.isEmpty) {
            if (_ctrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    icon: Icons.newspaper_rounded,
                    title: 'Tidak ada informasi',
                    subtitle:
                        _ctrl.errorMessage.value ??
                        'Coba ubah filter atau periksa kembali nanti.',
                  ),
                ),
              ],
            );
          }

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (pinned.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.s16.w,
                      AppSpacing.s16.h,
                      AppSpacing.s16.w,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.push_pin_rounded,
                              size: 14.sp,
                              color: colors.onSurface.withValues(alpha: 0.5),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Terpasang',
                              style: typography.labelLarge.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.s12.h),
                        SizedBox(
                          height: 180.h,
                          width: double.infinity,
                          child: pinned.length == 1
                              ? InformasiPinnedCard(
                                  item: pinned.first,
                                  category: _ctrl.categories.firstWhereOrNull(
                                    (c) => c.id == pinned.first.categoryId,
                                  ),
                                  onTap: () => _openDetail(pinned.first),
                                )
                              : PageView.builder(
                                  controller: _pinnedPageCtrl,
                                  itemCount: pinned.length,
                                  onPageChanged: (i) =>
                                      setState(() => _pinnedPage = i),
                                  itemBuilder: (_, i) => InformasiPinnedCard(
                                    item: pinned[i],
                                    category: _ctrl.categories.firstWhereOrNull(
                                      (c) => c.id == pinned[i].categoryId,
                                    ),
                                    onTap: () => _openDetail(pinned[i]),
                                  ),
                                ),
                        ),
                        if (pinned.length > 1) ...[
                          SizedBox(height: AppSpacing.s12.h),
                          Center(
                            child: AppPageIndicator(
                              count: pinned.length,
                              currentIndex: _pinnedPage,
                            ),
                          ),
                        ],
                        SizedBox(height: AppSpacing.s20.h),
                        Divider(
                          height: 1,
                          color: colors.outline.withValues(alpha: 0.12),
                        ),
                        SizedBox(height: AppSpacing.s16.h),
                        Text(
                          'Semua Informasi',
                          style: typography.labelLarge.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.s12.h),
                      ],
                    ),
                  ),
                ),
              if (_ctrl.selectedCategoryId.value != null ||
                  _ctrl.dateRange.value != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.s16.w,
                      pinned.isEmpty ? AppSpacing.s16.h : 0,
                      AppSpacing.s16.w,
                      AppSpacing.s8.h,
                    ),
                    child: ActiveFilterRow(
                      ctrl: _ctrl,
                      colors: colors,
                      typography: typography,
                    ),
                  ),
                ),
              if (list.isEmpty)
                if (_ctrl.selectedCategoryId.value != null ||
                    _ctrl.dateRange.value != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Tidak ada hasil',
                      subtitle: 'Tidak ada informasi yang sesuai filter.',
                    ),
                  )
                else
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      icon: Icons.newspaper_rounded,
                      title: 'Belum ada informasi',
                      subtitle: 'Informasi lainnya akan tampil di sini.',
                    ),
                  )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.s16.w,
                    pinned.isEmpty ? AppSpacing.s16.h : 0,
                    AppSpacing.s16.w,
                    AppSpacing.s32.h,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((_, i) {
                      final item = list[i];
                      return InformasiCard(
                        item: item,
                        category: _ctrl.categories.firstWhereOrNull(
                          (c) => c.id == item.categoryId,
                        ),
                        onTap: () => _openDetail(item),
                      );
                    }, childCount: list.length),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
