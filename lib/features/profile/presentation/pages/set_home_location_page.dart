import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../core/network/session_manager.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/profile_controller.dart';

class SetHomeLocationPage extends StatefulWidget {
  const SetHomeLocationPage({super.key});

  @override
  State<SetHomeLocationPage> createState() => _SetHomeLocationPageState();
}

class _SetHomeLocationPageState extends State<SetHomeLocationPage> {
  late final MapController _mapController;
  LatLng? _selectedLocation;
  bool _isLocating = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Pre-fill with current home location if available
    final user = Get.find<SessionManager>().currentUser.value;
    if (user?.homeLatitude != null && user?.homeLongitude != null) {
      _selectedLocation = LatLng(user!.homeLatitude!, user.homeLongitude!);
    }
  }

  Future<void> _goToMyLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        AppFeedback.showSnackbar(
          title: 'Izin Ditolak',
          message: 'Aktifkan izin lokasi di pengaturan perangkat',
          isError: true,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      setState(() => _selectedLocation = latLng);
      _mapController.move(latLng, 17.0);
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: 'Tidak dapat mengambil lokasi saat ini',
        isError: true,
      );
    } finally {
      setState(() => _isLocating = false);
    }
  }

  Future<void> _saveLocation() async {
    final loc = _selectedLocation;
    if (loc == null) {
      AppFeedback.showSnackbar(
        title: 'Perhatian',
        message: 'Pilih lokasi rumah terlebih dahulu dengan mengetuk peta',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await Get.find<ProfileController>().saveHomeLocation(
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
      Get.back();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final initialCenter =
        _selectedLocation ??
        const LatLng(-4.5, 119.9); // Default: Sulawesi Selatan

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Atur Lokasi Rumah'),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.s16.w,
              vertical: AppSpacing.s12.h,
            ),
            padding: EdgeInsets.all(AppSpacing.s12.w),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colors.primary,
                  size: 18,
                ),
                SizedBox(width: AppSpacing.s8.w),
                Expanded(
                  child: Text(
                    'Ketuk peta untuk memilih lokasi rumah Anda',
                    style: typography.bodySmall.copyWith(
                      color: colors.primary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Map
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation ?? initialCenter,
                    initialZoom: _selectedLocation != null ? 16.0 : 10.0,
                    onTap: (tapPosition, point) {
                      setState(() => _selectedLocation = point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'id.go.barrukab.presensi',
                    ),
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation!,
                            width: 56,
                            height: 56,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.primary.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.home_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                CustomPaint(
                                  size: const Size(12, 8),
                                  painter: _TrianglePainter(colors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    // Accuracy circle
                    if (_selectedLocation != null)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: _selectedLocation!,
                            radius: 100,
                            useRadiusInMeter: true,
                            color: colors.primary.withValues(alpha: 0.08),
                            borderColor: colors.primary.withValues(alpha: 0.3),
                            borderStrokeWidth: 1.5,
                          ),
                        ],
                      ),
                  ],
                ),
                // My Location FAB
                Positioned(
                  right: AppSpacing.s16.w,
                  bottom: AppSpacing.s16.h,
                  child: FloatingActionButton.small(
                    heroTag: 'home_location_fab',
                    backgroundColor: colors.surface,
                    foregroundColor: colors.primary,
                    onPressed: _isLocating ? null : _goToMyLocation,
                    child: _isLocating
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primary,
                            ),
                          )
                        : const Icon(Icons.my_location_rounded),
                  ),
                ),
              ],
            ),
          ),

          // Selected Location Info & Save
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s16.w,
              AppSpacing.s16.h,
              AppSpacing.s16.w,
              AppSpacing.s16.h + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedLocation != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.place_rounded,
                        color: colors.primary,
                        size: 18,
                      ),
                      SizedBox(width: AppSpacing.s8.w),
                      Expanded(
                        child: Text(
                          'Koordinat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                          style: typography.bodySmall.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s12.h),
                ] else ...[
                  Text(
                    'Belum ada lokasi dipilih',
                    style: typography.bodySmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.s12.h),
                ],
                AppButton(
                  label: 'Simpan Lokasi Rumah',
                  icon: Icons.save_rounded,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _saveLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
