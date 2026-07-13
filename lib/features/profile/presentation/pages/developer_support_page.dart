import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../design_system/components/app_card.dart';
import '../../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';
import '../../../../../design_system/tokens/app_radius.dart';
import 'developer_attendance_detail_page.dart';

class DeveloperSupportController extends GetxController {
  final Dio _dio = Get.find<Dio>();
  final prefs = Get.find<SharedPreferences>();

  var attendances = <dynamic>[].obs;
  var kinerjas = <dynamic>[].obs;

  var isLoading = false.obs;
  var isLoadingKinerja = false.obs;
  var selectedMonth = DateTime.now().obs;

  var bypassAttendance = false.obs;
  var mockGps = false.obs;

  @override
  void onInit() {
    super.onInit();
    bypassAttendance.value =
        prefs.getBool('bypass_attendance_activity') ?? false;
    mockGps.value = prefs.getBool('mock_gps_location') ?? false;
    fetchAttendances();
    fetchKinerja();
  }

  void toggleBypassAttendance(bool val) {
    bypassAttendance.value = val;
    prefs.setBool('bypass_attendance_activity', val);
  }

  void toggleMockGps(bool val) {
    mockGps.value = val;
    prefs.setBool('mock_gps_location', val);
  }

  void fetchAttendances() async {
    isLoading.value = true;
    try {
      final monthStr = DateFormat('yyyy-MM').format(selectedMonth.value);
      final response = await _dio.get(
        '/system/developer-support/attendances',
        queryParameters: {'month': monthStr},
      );

      if (response.data != null && response.data['data'] != null) {
        attendances.value = response.data['data'];
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data presensi. Pastikan Anda memiliki akses Developer.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void fetchKinerja() async {
    isLoadingKinerja.value = true;
    try {
      final response = await _dio.get(
        '/v1/activities',
        queryParameters: {
          'month': selectedMonth.value.month,
          'year': selectedMonth.value.year,
        },
      );

      if (response.data != null && response.data['data'] != null) {
        kinerjas.value = response.data['data'];
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data kinerja.');
    } finally {
      isLoadingKinerja.value = false;
    }
  }

  void updateAttendanceStatus(int id, Map<String, dynamic> data) async {
    try {
      await _dio.put('/system/developer-support/attendances/$id', data: data);
      Get.snackbar('Sukses', 'Data presensi harian berhasil diubah');
      fetchAttendances();
    } catch (e) {
      Get.snackbar('Error', 'Gagal merubah data presensi harian');
    }
  }

  void deleteAttendance(int id) async {
    try {
      await _dio.delete('/system/developer-support/attendances/$id');
      Get.snackbar('Sukses', 'Data presensi berhasil dihapus');
      fetchAttendances();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus data presensi');
    }
  }

  void deleteKinerja(int id) async {
    try {
      await _dio.delete('/v1/activities/$id');
      Get.snackbar('Sukses', 'Data kinerja berhasil dihapus');
      fetchKinerja();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus data kinerja');
    }
  }

  void changeMonth(DateTime newMonth) {
    selectedMonth.value = newMonth;
    fetchAttendances();
    fetchKinerja();
  }
}

class DeveloperSupportPage extends StatelessWidget {
  const DeveloperSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeveloperSupportController());
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppTopAppBar(
          title: 'Developer Support',
          variant: AppTopAppBarVariant.withBack,
          onBack: () => Get.back(),
        ),
        body: Column(
          children: [
            // Settings Cards
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s16.w,
                vertical: AppSpacing.s8.h,
              ),
              child: Column(
                children: [
                  Obx(
                    () => SwitchListTile(
                      title: Text(
                        'Bypass Presensi untuk Kinerja',
                        style: typography.bodyMedium,
                      ),
                      subtitle: Text(
                        'Bisa buat aktifitas tanpa presensi masuk',
                        style: typography.bodySmall.copyWith(
                          color: colors.outline,
                        ),
                      ),
                      value: controller.bypassAttendance.value,
                      onChanged: controller.toggleBypassAttendance,
                      activeColor: colors.primary,
                    ),
                  ),
                  Obx(
                    () => SwitchListTile(
                      title: Text(
                        'Mock GPS Presensi',
                        style: typography.bodyMedium,
                      ),
                      subtitle: Text(
                        'Otomatis tembak koordinat target (bypass validasi jarak)',
                        style: typography.bodySmall.copyWith(
                          color: colors.outline,
                        ),
                      ),
                      value: controller.mockGps.value,
                      onChanged: controller.toggleMockGps,
                      activeColor: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Month Picker
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s16.w,
                vertical: AppSpacing.s8.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      'Bulan: ${DateFormat('MMMM yyyy', 'id_ID').format(controller.selectedMonth.value)}',
                      style: typography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onBackground,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedMonth.value,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        controller.changeMonth(date);
                      }
                    },
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: const Text('Pilih Bulan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              tabAlignment: TabAlignment.fill,
              labelColor: colors.primary,
              unselectedLabelColor: colors.outline,
              indicatorColor: colors.primary,
              tabs: const [
                Tab(text: 'Presensi Harian'),
                Tab(text: 'Kinerja'),
              ],
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _buildAttendancesTab(controller, colors, typography),
                  _buildKinerjaTab(controller, colors, typography),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendancesTab(
    DeveloperSupportController controller,
    AppColors colors,
    AppTypography typography,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: colors.primary));
      }

      if (controller.attendances.isEmpty) {
        return Center(
          child: Text(
            'Tidak ada data presensi',
            style: typography.bodyLarge.copyWith(color: colors.outline),
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.attendances.length,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s16.w,
          vertical: AppSpacing.s8.h,
        ),
        itemBuilder: (context, index) {
          final record = controller.attendances[index];
          final userName = record['user']?['name'] ?? 'Unknown';
          final dateStr = record['work_date'] ?? '';
          final status = record['day_status'] ?? 'Unknown';

          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
            child: AppCard(
              onTap: () {
                Get.to(() => DeveloperAttendanceDetailPage(record: record));
              },
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s12.w,
                vertical: AppSpacing.s12.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: typography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.s4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: colors.outline,
                            ),
                            SizedBox(width: AppSpacing.s4.w),
                            Expanded(
                              child: Text(
                                dateStr,
                                style: typography.bodySmall.copyWith(
                                  color: colors.outline,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8.w,
                      vertical: AppSpacing.s4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        status,
                        colors,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.r4),
                      border: Border.all(
                        color: _getStatusColor(
                          status,
                          colors,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      status.toString().toUpperCase(),
                      style: typography.labelSmall.copyWith(
                        color: _getStatusColor(status, colors),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.all(AppSpacing.s4.w),
                    icon: Icon(Icons.delete, size: 18, color: colors.error),
                    onPressed: () => controller.deleteAttendance(record['id']),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildKinerjaTab(
    DeveloperSupportController controller,
    AppColors colors,
    AppTypography typography,
  ) {
    return Obx(() {
      if (controller.isLoadingKinerja.value) {
        return Center(child: CircularProgressIndicator(color: colors.primary));
      }

      if (controller.kinerjas.isEmpty) {
        return Center(
          child: Text(
            'Tidak ada data kinerja',
            style: typography.bodyLarge.copyWith(color: colors.outline),
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.kinerjas.length,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s16.w,
          vertical: AppSpacing.s8.h,
        ),
        itemBuilder: (context, index) {
          final record = controller.kinerjas[index];
          final title = record['title'] ?? 'No Title';
          final dateStr = record['activity_date'] ?? '';
          final status = record['status'] ?? 'Unknown';

          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
            child: AppCard(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s12.w,
                vertical: AppSpacing.s12.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: typography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.s4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: colors.outline,
                            ),
                            SizedBox(width: AppSpacing.s4.w),
                            Text(
                              dateStr,
                              style: typography.bodySmall.copyWith(
                                color: colors.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8.w,
                      vertical: AppSpacing.s4.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.r4),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Text(
                      status.toString().toUpperCase(),
                      style: typography.labelSmall.copyWith(
                        color: colors.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.all(AppSpacing.s4.w),
                    icon: Icon(Icons.delete, size: 18, color: colors.error),
                    onPressed: () => controller.deleteKinerja(record['id']),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Color _getStatusColor(String status, AppColors colors) {
    switch (status.toLowerCase()) {
      case 'present':
        return colors.primary;
      case 'absent':
        return colors.error;
      case 'leave':
      case 'permit':
        return colors.warning;
      case 'sick':
        return Colors.blue;
      default:
        return colors.outline;
    }
  }
}
