import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/app_dropdown.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/skp_report_model.dart';
import '../controllers/skp_upload_controller.dart';
import '../../data/services/skp_service.dart';

class SkpUploadPage extends StatelessWidget {
  const SkpUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SkpService>()) {
      Get.put<SkpService>(MockSkpService());
    }
    final controller = Get.put(SkpUploadController(service: Get.find<SkpService>()));
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Upload Laporan SKP',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: Obx(() {
        if (controller.selectedFile.value == null) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.s16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRuleBanner(colors, typography),
                SizedBox(height: AppSpacing.s16.h),
                _buildPeriodSelector(controller, colors, typography),
                SizedBox(height: AppSpacing.s16.h),
                _buildFileSelector(controller, colors, typography),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Period Info Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16.w, vertical: AppSpacing.s8.h),
              color: colors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Periode: ${DateFormat('MMMM', 'id_ID').format(DateTime(2024, controller.selectedMonth.value))} ${controller.selectedYear.value}',
                    style: typography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      controller.selectedFile.value = null;
                      controller.extractedItems.clear();
                    },
                    icon: Icon(Icons.refresh_rounded, size: 18.sp, color: colors.outline),
                    label: Text('Ganti File', style: typography.caption.copyWith(color: colors.outline)),
                  ),
                ],
              ),
            ),
            
            // Area PDF Viewer
            Expanded(
              flex: 5,
              child: Container(
                color: colors.surface,
                child: PDFView(
                  filePath: controller.selectedFile.value!.path,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: false,
                  pageFling: false,
                  fitPolicy: FitPolicy.WIDTH,
                ),
              ),
            ),
            
            // Area Extracted Data (Read-Only)
            Expanded(
              flex: 4,
              child: Container(
                color: colors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(AppSpacing.s16.w, AppSpacing.s12.h, AppSpacing.s16.w, AppSpacing.s8.h),
                      child: Text(
                        'Hasil Ekstraksi Data (Read-Only)',
                        style: typography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    if (controller.isExtracting.value)
                      const Expanded(child: Center(child: CircularProgressIndicator()))
                    else if (controller.extractedItems.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            'Tidak ada data yang diekstrak',
                            style: typography.bodyMedium.copyWith(color: colors.outline),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16.w),
                          itemCount: controller.extractedItems.length,
                          separatorBuilder: (context, index) => SizedBox(height: AppSpacing.s8.h),
                          itemBuilder: (context, index) {
                            final item = controller.extractedItems[index];
                            return _buildReadOnlyItem(index, item, colors, typography);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.selectedFile.value == null) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.s16.w),
            child: AppButton(
              label: 'Kirim Laporan (Verifikasi Atasan)',
              style: AppButtonStyle.filled,
              onPressed: controller.saveReport,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRuleBanner(AppColors colors, AppTypography typography) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s12.w),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.warning, size: 20.sp),
          SizedBox(width: AppSpacing.s8.w),
          Expanded(
            child: Text(
              '1 file SKP hanya berlaku untuk 1 periode bulan. Jika ingin mengganti file, hapus file lama terlebih dahulu agar diverifikasi ulang oleh atasan.',
              style: typography.caption.copyWith(color: colors.onSurface, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(SkpUploadController controller, AppColors colors, AppTypography typography) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Periode Laporan SKP',
            style: typography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          SizedBox(height: AppSpacing.s12.h),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bulan', style: typography.labelSmall.copyWith(color: colors.outline)),
                    SizedBox(height: AppSpacing.s4.h),
                    AppDropdown<int>(
                      value: controller.selectedMonth.value,
                      hint: 'Pilih Bulan',
                      items: List.generate(12, (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text(DateFormat('MMMM', 'id_ID').format(DateTime(2024, index + 1))),
                      )),
                      onChanged: (val) {
                        if (val != null) controller.selectedMonth.value = val;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.s12.w),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tahun', style: typography.labelSmall.copyWith(color: colors.outline)),
                    SizedBox(height: AppSpacing.s4.h),
                    AppDropdown<int>(
                      value: controller.selectedYear.value,
                      hint: 'Tahun',
                      items: years.map((y) => DropdownMenuItem(
                        value: y,
                        child: Text('$y'),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedYear.value = val;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelector(SkpUploadController controller, AppColors colors, AppTypography typography) {
    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s24.w),
      child: Column(
        children: [
          Icon(Icons.picture_as_pdf_rounded, size: 48.sp, color: colors.outline),
          SizedBox(height: AppSpacing.s16.h),
          Text(
            'Unggah Dokumen PDF Penilaian SKP (Maks. 10MB)',
            textAlign: TextAlign.center,
            style: typography.bodyMedium.copyWith(color: colors.outline),
          ),
          SizedBox(height: AppSpacing.s24.h),
          AppButton(
            label: 'Pilih File PDF',
            icon: Icons.folder_open_rounded,
            style: AppButtonStyle.outlined,
            onPressed: controller.pickAndExtractPdf,
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyItem(int index, SkpItem item, AppColors colors, AppTypography typography) {
    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item ${index + 1}',
            style: typography.labelSmall.copyWith(color: colors.primary, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.s8.h),
          Text(
            item.kegiatan,
            style: typography.bodyMedium.copyWith(color: colors.onSurface, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.s4.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Target: ${item.target}',
                  style: typography.caption.copyWith(color: colors.outline),
                ),
              ),
              Expanded(
                child: Text(
                  'Realisasi: ${item.realisasi}',
                  style: typography.caption.copyWith(color: colors.outline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
