import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/skp_report_model.dart';
import '../controllers/skp_list_controller.dart';
import 'skp_upload_page.dart';

class EkpDetailPage extends StatefulWidget {
  final SkpReportModel report;
  final bool isSubordinate;

  const EkpDetailPage({
    super.key,
    required this.report,
    this.isSubordinate = false,
  });

  @override
  State<EkpDetailPage> createState() => _EkpDetailPageState();
}

class _EkpDetailPageState extends State<EkpDetailPage> {
  late SkpReportModel _report;
  bool _isLoadingPdf = false;
  String? _localPdfPath;
  String? _pdfLoadError;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    final url = _report.fileUrl;
    if (url == null || url.isEmpty) {
      setState(() {
        _pdfLoadError = 'File URL dokumen tidak tersedia di server.';
      });
      return;
    }

    setState(() {
      _isLoadingPdf = true;
      _pdfLoadError = null;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final localFile = File('${tempDir.path}/ekp_${_report.id}_${_report.fileName}');

      if (await localFile.exists() && await localFile.length() > 0) {
        if (mounted) {
          setState(() {
            _localPdfPath = localFile.path;
            _isLoadingPdf = false;
          });
        }
        return;
      }

      final dio = Get.isRegistered<Dio>() ? Get.find<Dio>() : Dio();
      await dio.download(url, localFile.path);

      if (mounted) {
        setState(() {
          _localPdfPath = localFile.path;
          _isLoadingPdf = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pdfLoadError = 'Gagal mengunduh dokumen lampiran: $e';
          _isLoadingPdf = false;
        });
      }
    }
  }

  void _openFullScreenPdf() {
    if (_localPdfPath == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppTopAppBar(
            title: _report.fileName,
            variant: AppTopAppBarVariant.withBack,
          ),
          body: PDFView(
            filePath: _localPdfPath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            fitPolicy: FitPolicy.WIDTH,
          ),
        ),
      ),
    );
  }

  void _showRejectionDialog() {
    final noteController = TextEditingController();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.h,
            16.w,
            MediaQuery.of(ctx).viewInsets.bottom + 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tolak Laporan EKP',
                style: typography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.error,
                ),
              ),
              SizedBox(height: AppSpacing.s8.h),
              Text(
                'Berikan catatan atau alasan penolakan agar pegawai dapat memperbaiki dokumen EKP mereka.',
                style: typography.caption.copyWith(color: colors.outline),
              ),
              SizedBox(height: AppSpacing.s12.h),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan alasan penolakan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s16.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Batal',
                      style: AppButtonStyle.outlined,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s12.w),
                  Expanded(
                    child: AppButton(
                      label: 'Kirim Penolakan',
                      style: AppButtonStyle.filled,
                      onPressed: () async {
                        final note = noteController.text.trim();
                        if (note.isEmpty) {
                          AppFeedback.showSnackbar(
                            title: 'Peringatan',
                            message: 'Harap isi alasan penolakan.',
                            type: FeedbackType.warning,
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        if (Get.isRegistered<SkpListController>()) {
                          await Get.find<SkpListController>().verifySubordinateReport(
                            _report.id,
                            status: 'ditolak',
                            rejectionNote: note,
                          );
                          Get.back();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete() {
    final monthName = DateFormat('MMMM', 'id_ID').format(DateTime(2024, _report.periodMonth));
    AppFeedback.showDialog(
      title: 'Hapus Laporan EKP?',
      message:
          'Anda akan menghapus laporan EKP periode $monthName ${_report.periodYear}.\n\n'
          'Setelah dihapus, Anda dapat mengunggah file EKP yang baru.',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      onConfirm: () async {
        if (Get.isRegistered<SkpListController>()) {
          await Get.find<SkpListController>().deleteReport(_report.id);
          Get.back(); // Kembali ke halaman list
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final monthName = DateFormat('MMMM', 'id_ID').format(DateTime(2024, _report.periodMonth));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Detail Laporan EKP',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner Verifikasi Atasan
            _buildStatusBanner(colors, typography),
            SizedBox(height: AppSpacing.s16.h),

            // Evaluasi Kinerja (Predikat & Capaian Organisasi)
            _buildEvaluationCard(colors, typography),
            SizedBox(height: AppSpacing.s16.h),

            // Informasi Periode & Laporan
            _buildReportInfoCard(monthName, colors, typography),
            SizedBox(height: AppSpacing.s16.h),

            // Identitas Pegawai & Pejabat
            _buildIdentityCard(colors, typography),
            SizedBox(height: AppSpacing.s16.h),

            // Pratinjau Dokumen Lampiran PDF
            _buildPdfPreviewCard(colors, typography),
            SizedBox(height: AppSpacing.s24.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(colors, typography),
    );
  }

  Widget _buildStatusBanner(AppColors colors, AppTypography typography) {
    Color bannerColor;
    Color iconColor;
    IconData bannerIcon;
    String statusTitle;
    String statusSubtitle;

    if (_report.isApproved) {
      bannerColor = colors.success.withValues(alpha: 0.1);
      iconColor = colors.success;
      bannerIcon = Icons.check_circle_rounded;
      statusTitle = 'Laporan EKP Telah Disetujui';
      final verifier = _report.verifierDisplayName;
      final date = _report.verifiedAt != null
          ? DateFormat('dd MMM yyyy HH:mm').format(_report.verifiedAt!)
          : '';
      statusSubtitle = 'Diverifikasi oleh $verifier ${date.isNotEmpty ? "($date)" : ""}';
    } else if (_report.isRejected) {
      bannerColor = colors.error.withValues(alpha: 0.1);
      iconColor = colors.error;
      bannerIcon = Icons.cancel_rounded;
      statusTitle = 'Laporan EKP Ditolak oleh Atasan';
      final verifier = _report.verifierDisplayName;
      statusSubtitle = 'Ditolak oleh $verifier. Silakan periksa catatan penolakan dan unggah ulang dokumen yang sesuai.';
    } else {
      bannerColor = colors.warning.withValues(alpha: 0.1);
      iconColor = colors.warning;
      bannerIcon = Icons.hourglass_bottom_rounded;
      statusTitle = 'Menunggu Verifikasi Atasan';
      statusSubtitle = 'Laporan EKP sedang dalam antrean verifikasi oleh atasan langsung.';
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.s16.w),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(bannerIcon, color: iconColor, size: 24.sp),
              SizedBox(width: AppSpacing.s12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: typography.titleSmall.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      statusSubtitle,
                      style: typography.caption.copyWith(color: colors.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Tampilkan Alasan Penolakan Jika Ditolak
          if (_report.isRejected &&
              _report.rejectionNote != null &&
              _report.rejectionNote!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.s12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.s12.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: colors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speaker_notes_rounded, size: 16.sp, color: colors.error),
                      SizedBox(width: AppSpacing.s8.w),
                      Text(
                        'Alasan Penolakan dari Atasan:',
                        style: typography.labelSmall.copyWith(
                          color: colors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s8.h),
                  Text(
                    _report.rejectionNote!,
                    style: typography.bodySmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(AppColors colors, AppTypography typography) {
    final predikat = _report.predikatKinerja ??
        _report.jsonExtractedData?['evaluasi_kinerja']?['predikat_kinerja_pegawai']?.toString() ??
        '-';
    final capaian = _report.capaianOrganisasi ??
        _report.jsonExtractedData?['evaluasi_kinerja']?['capaian_kinerja_organisasi']?.toString() ??
        '-';

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evaluasi Kinerja EKP',
                style: typography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              if (_report.tppPercentage != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8.w,
                    vertical: AppSpacing.s4.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'TPP: ${_report.tppPercentage}%',
                    style: typography.caption.copyWith(
                      color: colors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.s12.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.s12.w),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Predikat Kinerja',
                        style: typography.caption.copyWith(color: colors.outline),
                      ),
                      SizedBox(height: AppSpacing.s4.h),
                      Text(
                        predikat,
                        style: typography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s12.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.s12.w),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Capaian Organisasi',
                        style: typography.caption.copyWith(color: colors.outline),
                      ),
                      SizedBox(height: AppSpacing.s4.h),
                      Text(
                        capaian,
                        style: typography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportInfoCard(String monthName, AppColors colors, AppTypography typography) {
    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Dokumen Laporan',
            style: typography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.s12.h),
          _buildInfoRow('Periode Laporan', '$monthName ${_report.periodYear}', colors, typography),
          _buildInfoRow('Nama Dokumen', _report.fileName, colors, typography),
          if (_report.fileSize > 0)
            _buildInfoRow(
              'Ukuran File',
              '${(_report.fileSize / 1024).toStringAsFixed(1)} KB',
              colors,
              typography,
            ),
          if (_report.createdAt != null)
            _buildInfoRow(
              'Tanggal Unggah',
              DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(_report.createdAt!),
              colors,
              typography,
            ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(AppColors colors, AppTypography typography) {
    final jsonData = _report.jsonExtractedData;
    final pegawaiData = jsonData?['pegawai_dinilai'] as Map<String, dynamic>?;
    final penilaiData = jsonData?['pejabat_penilai'] as Map<String, dynamic>?;

    final namaPegawai = pegawaiData?['nama'] ?? _report.displayName;
    final nipPegawai = pegawaiData?['nip'] ?? _report.user?.nip ?? '-';
    final jabatanPegawai = pegawaiData?['jabatan']?.toString();

    final namaPenilai = penilaiData?['nama'] ?? _report.verifierDisplayName;
    final nipPenilai = penilaiData?['nip'] ?? '-';
    final jabatanPenilai = penilaiData?['jabatan']?.toString();

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Identitas Dokumen EKP',
            style: typography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.s12.h),
          Text(
            'Pegawai Yang Dinilai',
            style: typography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(namaPegawai, style: typography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
          Text('NIP. $nipPegawai', style: typography.caption.copyWith(color: colors.outline)),
          if (jabatanPegawai != null)
            Text(jabatanPegawai, style: typography.caption.copyWith(color: colors.onSurface)),

          SizedBox(height: AppSpacing.s12.h),
          const Divider(height: 1),
          SizedBox(height: AppSpacing.s12.h),

          Text(
            'Pejabat Penilai Kinerja',
            style: typography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(namaPenilai, style: typography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
          Text('NIP. $nipPenilai', style: typography.caption.copyWith(color: colors.outline)),
          if (jabatanPenilai != null)
            Text(jabatanPenilai, style: typography.caption.copyWith(color: colors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildPdfPreviewCard(AppColors colors, AppTypography typography) {
    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dokumen Lampiran PDF',
                style: typography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              if (_localPdfPath != null)
                TextButton.icon(
                  onPressed: _openFullScreenPdf,
                  icon: Icon(Icons.fullscreen_rounded, size: 20.sp, color: colors.primary),
                  label: Text(
                    'Layar Penuh',
                    style: typography.caption.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.s12.h),
          Container(
            height: 380.h,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildPdfContent(colors, typography),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfContent(AppColors colors, AppTypography typography) {
    if (_isLoadingPdf) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Mengunduh dokumen lampiran...'),
          ],
        ),
      );
    }

    if (_pdfLoadError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: colors.error, size: 36.sp),
              SizedBox(height: AppSpacing.s8.h),
              Text(
                _pdfLoadError!,
                textAlign: TextAlign.center,
                style: typography.caption.copyWith(color: colors.outline),
              ),
              SizedBox(height: AppSpacing.s12.h),
              AppButton(
                label: 'Coba Lagi',
                style: AppButtonStyle.outlined,
                onPressed: _preparePdf,
              ),
            ],
          ),
        ),
      );
    }

    if (_localPdfPath != null) {
      return PDFView(
        filePath: _localPdfPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: false,
        fitPolicy: FitPolicy.WIDTH,
      );
    }

    return const Center(child: Text('Dokumen tidak dapat dimuat'));
  }

  Widget _buildInfoRow(String label, String value, AppColors colors, AppTypography typography) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: typography.bodySmall.copyWith(color: colors.outline)),
          SizedBox(width: AppSpacing.s12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: typography.bodySmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomActions(AppColors colors, AppTypography typography) {
    if (!widget.isSubordinate) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s16.w),
          child: Row(
            children: [
              if (_report.isRejected) ...[
                Expanded(
                  child: AppButton(
                    label: 'Upload Ulang EKP',
                    icon: Icons.upload_file_rounded,
                    style: AppButtonStyle.filled,
                    onPressed: () {
                      Get.to(() => const SkpUploadPage());
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.s12.w),
              ],
              Expanded(
                child: AppButton(
                  label: 'Hapus Laporan',
                  icon: Icons.delete_outline_rounded,
                  style: AppButtonStyle.outlined,
                  onPressed: _confirmDelete,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mode Bawahan (Atasan)
    if (_report.isPending) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s16.w),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Tolak',
                  style: AppButtonStyle.outlined,
                  onPressed: _showRejectionDialog,
                ),
              ),
              SizedBox(width: AppSpacing.s12.w),
              Expanded(
                child: AppButton(
                  label: 'Setujui',
                  style: AppButtonStyle.filled,
                  onPressed: () async {
                    if (Get.isRegistered<SkpListController>()) {
                      await Get.find<SkpListController>().verifySubordinateReport(
                        _report.id,
                        status: 'disetujui',
                      );
                      Get.back();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return null;
  }
}
