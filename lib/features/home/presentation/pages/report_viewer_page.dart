import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/report_viewer_controller.dart';
import '../widgets/report_filter_bottom_sheet.dart';

class ReportViewerPage extends StatefulWidget {
  const ReportViewerPage({super.key});

  @override
  State<ReportViewerPage> createState() => _ReportViewerPageState();
}

class _ReportViewerPageState extends State<ReportViewerPage> {
  late final ReportViewerController _ctrl;
  final TransformationController _transformationController =
      TransformationController();

  final List<String> _monthNames = const [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(ReportViewerController());
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      appBar: AppTopAppBar(
        title: 'Laporan PDF',
        variant: AppTopAppBarVariant.withBack,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset Zoom (100%)',
            onPressed: _resetZoom,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter Periode',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ReportFilterBottomSheet(controller: _ctrl),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented button for switching report type (Presensi vs TPP)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s16.w,
              vertical: AppSpacing.s8.h,
            ),
            color: colors.surface,
            child: Obx(() {
              final isAttendance =
                  _ctrl.reportType.value == ReportType.attendance;
              return Container(
                decoration: BoxDecoration(
                  color: colors.outline.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: 'Laporan Presensi',
                        icon: Icons.calendar_month_rounded,
                        isSelected: isAttendance,
                        colors: colors,
                        typography: typography,
                        onTap: () {
                          _resetZoom();
                          _ctrl.setReportType(ReportType.attendance);
                        },
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: 'Laporan TPP',
                        icon: Icons.account_balance_wallet_rounded,
                        isSelected: !isAttendance,
                        colors: colors,
                        typography: typography,
                        onTap: () {
                          _resetZoom();
                          _ctrl.setReportType(ReportType.tpp);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          // Active filter banner info
          Obx(() {
            final monthStr = _monthNames[_ctrl.selectedMonth.value];
            final yearStr = '${_ctrl.selectedYear.value}';
            final isAttendance =
                _ctrl.reportType.value == ReportType.attendance;
            final scopeStr = isAttendance
                ? ' (${_ctrl.selectedScope.value.capitalizeFirst})'
                : '';

            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s16.w,
                vertical: AppSpacing.s8.h,
              ),
              color: colors.primary.withValues(alpha: 0.05),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16.w,
                    color: colors.primary,
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  Expanded(
                    child: Text(
                      'Periode: $monthStr $yearStr$scopeStr',
                      style: typography.caption.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_ctrl.totalPages.value > 0)
                    Text(
                      'Halaman ${_ctrl.currentPage.value + 1} dari ${_ctrl.totalPages.value}',
                      style: typography.caption.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            );
          }),

          // PDF View Body
          Expanded(
            child: Obx(() {
              if (_ctrl.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.s16.h),
                      Text(
                        'Mengunduh & memuat berkas PDF...',
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (_ctrl.errorMessage.value != null) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 48,
                          color: colors.error,
                        ),
                        SizedBox(height: AppSpacing.s12.h),
                        Text(
                          _ctrl.errorMessage.value!,
                          textAlign: TextAlign.center,
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: AppSpacing.s20.h),
                        ElevatedButton.icon(
                          onPressed: () {
                            _resetZoom();
                            _ctrl.fetchPdf();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final path = _ctrl.pdfFilePath.value;
              if (path == null) {
                return const SizedBox.shrink();
              }

              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 4.0,
                panEnabled: true,
                scaleEnabled: true,
                child: PDFView(
                  filePath: path,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  onRender: (pages) {
                    _ctrl.totalPages.value = pages ?? 0;
                  },
                  onPageChanged: (page, total) {
                    _ctrl.currentPage.value = page ?? 0;
                  },
                  onError: (error) {
                    _ctrl.errorMessage.value = 'Gagal menampilkan PDF: $error';
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (_ctrl.pdfFilePath.value == null || _ctrl.isLoading.value) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: _ctrl.openDownloadedFile,
          icon: const Icon(Icons.download_rounded),
          label: const Text('Buka / Unduh PDF'),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        );
      }),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.colors,
    required this.typography,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final AppColors colors;
  final AppTypography typography;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s10.h),
        decoration: BoxDecoration(
          color: isSelected ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.r8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.w,
              color: isSelected ? colors.primary : colors.outline,
            ),
            SizedBox(width: AppSpacing.s4.w),
            Text(
              label,
              style: typography.bodySmall.copyWith(
                color: isSelected ? colors.primary : colors.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
