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
import '../../data/repositories/skp_report_repository.dart';
import '../controllers/skp_upload_controller.dart';

class SkpUploadPage extends StatelessWidget {
  const SkpUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SkpUploadController(repository: Get.find<SkpReportRepository>()),
    );
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Upload Evaluasi Kinerja Pegawai',
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

        final data = controller.extractedData.value;
        final isValid = controller.isDocValid.value;
        final validationError = controller.validationError.value;

        return Column(
          children: [
            // Period Info Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s16.w,
                vertical: AppSpacing.s8.h,
              ),
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
                      controller.extractedData.value = null;
                      controller.isDocValid.value = false;
                      controller.validationError.value = null;
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 18.sp,
                      color: colors.outline,
                    ),
                    label: Text(
                      'Ganti File',
                      style: typography.caption.copyWith(color: colors.outline),
                    ),
                  ),
                ],
              ),
            ),

            // Area PDF Viewer
            Expanded(
              flex: 4,
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
              flex: 5,
              child: Container(
                color: colors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.s16.w,
                        AppSpacing.s12.h,
                        AppSpacing.s16.w,
                        AppSpacing.s8.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hasil Ekstraksi Dokumen EKP',
                            style: typography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                          if (isValid)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.s8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: colors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(
                                  color: colors.success.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '✓ Dokumen Valid',
                                style: typography.caption.copyWith(
                                  color: colors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (controller.isExtracting.value)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (validationError != null)
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(AppSpacing.s16.w),
                          child: Container(
                            padding: EdgeInsets.all(AppSpacing.s16.w),
                            decoration: BoxDecoration(
                              color: colors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: colors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: colors.error,
                                      size: 24.sp,
                                    ),
                                    SizedBox(width: AppSpacing.s8.w),
                                    Expanded(
                                      child: Text(
                                        'Dokumen EKP Ditolak',
                                        style: typography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppSpacing.s8.h),
                                Text(
                                  validationError,
                                  style: typography.caption.copyWith(
                                    color: colors.onSurface,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else if (data == null)
                      Expanded(
                        child: Center(
                          child: Text(
                            'Tidak ada data EKP yang terdeteksi',
                            style: typography.bodyMedium.copyWith(
                              color: colors.outline,
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16.w,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildEvaluationSummary(data, colors, typography),
                              SizedBox(height: AppSpacing.s12.h),
                              _buildPersonCard(
                                title: '1. Pegawai Yang Dinilai',
                                isCurrentUser: true,
                                person:
                                    data['pegawai_dinilai']
                                        as Map<String, dynamic>?,
                                colors: colors,
                                typography: typography,
                              ),
                              SizedBox(height: AppSpacing.s12.h),
                              _buildPersonCard(
                                title:
                                    '2. Pejabat Penilai Kinerja (Direct Atasan)',
                                person:
                                    data['pejabat_penilai']
                                        as Map<String, dynamic>?,
                                colors: colors,
                                typography: typography,
                              ),
                              SizedBox(height: AppSpacing.s12.h),
                              _buildPersonCard(
                                title: '3. Atasan Pejabat Penilai Kinerja',
                                person:
                                    data['atasan_pejabat_penilai']
                                        as Map<String, dynamic>?,
                                colors: colors,
                                typography: typography,
                              ),
                              SizedBox(height: AppSpacing.s16.h),
                            ],
                          ),
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
        if (controller.selectedFile.value == null) {
          return const SizedBox.shrink();
        }
        final canSubmit =
            controller.isDocValid.value &&
            controller.validationError.value == null;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.s16.w),
            child: AppButton(
              label: 'Kirim Dokumen EKP',
              style: AppButtonStyle.filled,
              onPressed: canSubmit ? controller.saveReport : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEvaluationSummary(
    Map<String, dynamic> data,
    AppColors colors,
    AppTypography typography,
  ) {
    final eval = data['evaluasi_kinerja'] as Map<String, dynamic>?;
    final predikat =
        eval?['predikat_kinerja_pegawai']?.toString() ??
        data['predikat_kinerja_pegawai']?.toString() ??
        '-';
    final capaian =
        eval?['capaian_kinerja_organisasi']?.toString() ??
        data['capaian_kinerja_organisasi']?.toString() ??
        '-';
    final tpp = eval?['tpp_percentage'] ?? 80;
    final periodeText = data['periode_penilaian']?.toString();

    Color predikatColor = colors.primary;
    if (predikat == 'Sangat Baik') {
      predikatColor = colors.success;
    } else if (predikat == 'Baik') {
      predikatColor = colors.primary;
    } else if (predikat == 'Butuh Perbaikan') {
      predikatColor = colors.warning;
    } else if (predikat == 'Kurang' || predikat == 'Sangat Kurang') {
      predikatColor = colors.error;
    }

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Predikat Kinerja Pegawai',
                      style: typography.caption.copyWith(color: colors.outline),
                    ),
                    SizedBox(height: AppSpacing.s4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s8.w,
                        vertical: AppSpacing.s4.h,
                      ),
                      decoration: BoxDecoration(
                        color: predikatColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        predikat,
                        style: typography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: predikatColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Capaian Organisasi',
                      style: typography.caption.copyWith(color: colors.outline),
                    ),
                    SizedBox(height: AppSpacing.s4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s8.w,
                        vertical: AppSpacing.s4.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        capaian,
                        style: typography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.s8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Estimasi TPP',
                    style: typography.caption.copyWith(color: colors.outline),
                  ),
                  SizedBox(height: AppSpacing.s4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8.w,
                      vertical: AppSpacing.s4.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '$tpp%',
                      style: typography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (periodeText != null && periodeText.isNotEmpty) ...[
            SizedBox(height: AppSpacing.s8.h),
            Divider(color: colors.outline.withValues(alpha: 0.2)),
            SizedBox(height: AppSpacing.s4.h),
            Text(
              'Periode Dokumen: $periodeText',
              style: typography.caption.copyWith(
                color: colors.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonCard({
    required String title,
    bool isCurrentUser = false,
    Map<String, dynamic>? person,
    required AppColors colors,
    required AppTypography typography,
  }) {
    if (person == null) return const SizedBox.shrink();

    final nama = person['nama']?.toString() ?? '-';
    final nip = person['nip']?.toString() ?? '-';
    final pangkat = person['pangkat_gol']?.toString() ?? '';
    final jabatan = person['jabatan']?.toString() ?? '-';
    final unitKerja = person['unit_kerja']?.toString() ?? '-';

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: typography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              if (isCurrentUser)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Akun Sesuai',
                    style: typography.caption.copyWith(
                      color: colors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.s8.h),
          Text(
            nama,
            style: typography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'NIP: $nip ${pangkat.isNotEmpty ? '• $pangkat' : ''}',
            style: typography.caption.copyWith(color: colors.outline),
          ),
          SizedBox(height: 4.h),
          Text(
            'Jabatan: $jabatan',
            style: typography.caption.copyWith(color: colors.onSurface),
          ),
          if (unitKerja.isNotEmpty && unitKerja != '-') ...[
            SizedBox(height: 2.h),
            Text(
              'Unit Kerja: $unitKerja',
              style: typography.caption.copyWith(color: colors.outline),
            ),
          ],
        ],
      ),
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
              '1 file Dokumen EKP hanya berlaku untuk 1 periode bulan. Pastikan file PDF memuat Dokumen Evaluasi Kinerja Pegawai resmi dan sesuai dengan NIP akun login Anda.',
              style: typography.caption.copyWith(
                color: colors.onSurface,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(
    SkpUploadController controller,
    AppColors colors,
    AppTypography typography,
  ) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Periode Laporan EKP',
            style: typography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.s12.h),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bulan',
                      style: typography.labelSmall.copyWith(
                        color: colors.outline,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4.h),
                    AppDropdown<int>(
                      value: controller.selectedMonth.value,
                      hint: 'Pilih Bulan',
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            DateFormat(
                              'MMMM',
                              'id_ID',
                            ).format(DateTime(2024, index + 1)),
                          ),
                        ),
                      ),
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
                    Text(
                      'Tahun',
                      style: typography.labelSmall.copyWith(
                        color: colors.outline,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4.h),
                    AppDropdown<int>(
                      value: controller.selectedYear.value,
                      hint: 'Tahun',
                      items: years
                          .map(
                            (y) =>
                                DropdownMenuItem(value: y, child: Text('$y')),
                          )
                          .toList(),
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

  Widget _buildFileSelector(
    SkpUploadController controller,
    AppColors colors,
    AppTypography typography,
  ) {
    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s24.w),
      child: Column(
        children: [
          Icon(
            Icons.picture_as_pdf_rounded,
            size: 48.sp,
            color: colors.outline,
          ),
          SizedBox(height: AppSpacing.s16.h),
          Text(
            'Unggah Dokumen PDF Evaluasi Kinerja Pegawai (EKP) (Maks. 10MB)',
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
}
