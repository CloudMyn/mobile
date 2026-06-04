import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/molecules/app_empty_state.dart';
import '../../../../design_system/components/molecules/app_error_state.dart';
import '../../../../design_system/components/app_skeleton.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/submission_item.dart';
import '../../data/models/submission_type.dart';
import '../controllers/submission_controller.dart';
import 'submission_create_page.dart';
import 'submission_detail_page.dart';
import 'widgets/submission_card.dart';

/// Halaman Pengajuan mandiri dengan AppBar — ditampilkan dari QuickActionGrid.
class SubmissionPage extends StatefulWidget {
  const SubmissionPage({super.key});

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage>
    with SingleTickerProviderStateMixin {
  late final SubmissionController _ctrl;
  TabController? _tabCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<SubmissionController>();
    ever(_ctrl.types, _onTypesLoaded);
    if (_ctrl.types.isNotEmpty) _buildTabController(_ctrl.types);
  }

  void _onTypesLoaded(List<SubmissionType> types) {
    if (!mounted || types.isEmpty) return;
    _buildTabController(types);
  }

  void _buildTabController(List<SubmissionType> types) {
    _tabCtrl?.dispose();
    _tabCtrl = TabController(length: types.length, vsync: this);
    _tabCtrl!.addListener(() {
      if (!_tabCtrl!.indexIsChanging) {
        _ctrl.onTabChanged(_tabCtrl!.index);
      }
    });
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Pengajuan',
        variant: AppTopAppBarVariant.withBack,
        elevation: 0,
      ),
      body: Obx(() {
        if (_ctrl.isLoadingTypes.value) return _buildSkeleton(colors);
        if (_ctrl.errorMessage.value != null) {
          return AppErrorState(
            message: _ctrl.errorMessage.value!,
            onRetry: _ctrl.loadTypes,
          );
        }
        if (_ctrl.types.isEmpty) {
          return const AppEmptyState(
            icon: Icons.upload_file_rounded,
            title: 'Belum ada jenis pengajuan',
            subtitle: 'Hubungi administrator untuk konfigurasi jenis pengajuan.',
          );
        }
        if (_tabCtrl == null || _tabCtrl!.length != _ctrl.types.length) {
          return _buildSkeleton(colors);
        }
        return Column(
          children: [
            ColoredBox(
              color: colors.surface,
              child: TabBar(
                controller: _tabCtrl,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: _ctrl.types
                    .map((t) => Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(t.icon, size: 16),
                              SizedBox(width: AppSpacing.s4.w),
                              Text(t.name),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: _ctrl.types
                    .map((type) => _SubmissionList(ctrl: _ctrl, type: type))
                    .toList(),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        if (_ctrl.isLoadingTypes.value || _ctrl.types.isEmpty) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          onPressed: () => Get.to(
            () => const SubmissionCreatePage(),
            transition: Transition.rightToLeft,
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'Buat Pengajuan',
            style: typography.labelMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        );
      }),
    );
  }

  Widget _buildSkeleton(AppColors colors) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton(width: double.infinity, height: 48.h),
          SizedBox(height: AppSpacing.s16.h),
          ...List.generate(
            4,
            (_) => const SubmissionCardSkeleton(),
          ),
        ],
      ),
    );
  }
}

class _SubmissionList extends StatelessWidget {
  final SubmissionController ctrl;
  final SubmissionType type;

  const _SubmissionList({required this.ctrl, required this.type});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingList.value &&
          !ctrl.submissionsMap.containsKey(type.id)) {
        return Padding(
          padding: EdgeInsets.all(AppSpacing.s16.w),
          child: Column(
            children: List.generate(
              3,
              (_) => const SubmissionCardSkeleton(),
            ),
          ),
        );
      }

      final List<SubmissionItem> items = ctrl.submissionsFor(type.id);

      if (items.isEmpty) {
        return AppEmptyState(
          icon: type.icon,
          title: 'Belum ada pengajuan ${type.name}',
          subtitle:
              'Tekan tombol "Buat Pengajuan" untuk membuat pengajuan baru.',
        );
      }

      return ListView.builder(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s16.w,
          AppSpacing.s12.h,
          AppSpacing.s16.w,
          80.h,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return SubmissionCard(
            item: item,
            onDelete: () => ctrl.deleteSubmission(item.id, type.id),
            onTap: () => Get.to(
              () => SubmissionDetailPage(item: item, type: type),
              transition: Transition.rightToLeft,
            ),
          );
        },
      );
    });
  }
}
