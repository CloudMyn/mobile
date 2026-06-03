import 'dart:convert';
import 'package:presensi/features/home/data/models/dashboard_model.dart';

void main() {
  final jsonString = '''{
    "success": true,
    "message": "Dashboard berhasil dimuat.",
    "data": {
        "user": {
            "id": 63,
            "uuid": "598a8a7f-8a3c-4ce1-8cb6-9e9efc2388b2",
            "nip": "112233",
            "name": "test_pegawai",
            "full_name": "test_pegawai",
            "email": "test_pegawai@mail.io",
            "profile_picture_url": null,
            "roles": [
                "pegawai"
            ],
            "permissions": [
                "correspondences.viewAny",
                "correspondences.view",
                "dispositions.viewAny",
                "dispositions.view",
                "dispositions.complete",
                "tpps.viewAny",
                "tpps.view",
                "employee-data.view-own",
                "employee-data.update-own",
                "attendance-reports.view-own",
                "attendance-reports.export-pdf"
            ],
            "institution": {
                "id": 1,
                "name": "Dinas Komunikasi, Informatika dan Statistik"
            },
            "department": {
                "id": 2,
                "name": "Bidang E-Government"
            },
            "job_title": {
                "id": 398,
                "name": "Operator Layanan Operasional (Kelas 3)"
            }
        },
        "today_schedule": {
            "id": 574,
            "work_date": "2026-06-03",
            "day_status": "partial",
            "scheduled_location": null,
            "location_event": null,
            "scheduled_start_at": "2026-06-03T02:00:00.000000Z",
            "scheduled_end_at": "2026-06-03T08:00:00.000000Z",
            "is_overnight": false,
            "total_required_types": 2,
            "total_completed_types": 1,
            "total_late_minutes": 16,
            "total_early_leave_minutes": 0,
            "total_work_minutes": 0,
            "summary_note": null,
            "schedule": {
                "id": 1,
                "institution_id": null,
                "code": "GLOBAL",
                "name": "Global",
                "timezone": "Asia/Makassar",
                "is_active": true,
                "created_at": "2026-05-25T09:04:42.000000Z",
                "updated_at": "2026-05-31T08:04:20.000000Z"
            },
            "records": [
                {
                    "id": 73,
                    "daily_record_id": 574,
                    "attendance_type_id": 1,
                    "sequence_no": 1,
                    "expected_at": "2026-06-03T02:00:00.000000Z",
                    "window_open_at": "2026-06-03T01:00:00.000000Z",
                    "window_close_at": "2026-06-03T04:00:00.000000Z",
                    "status": "late",
                    "attended_at": "2026-06-03T02:16:46.000000Z",
                    "source": "mobile_app",
                    "is_manual_entry": false,
                    "required_location_id": null,
                    "required_location": null,
                    "effective_geofence_mode": "default",
                    "event_geofence": null,
                    "actual_latitude": "-4.4145484",
                    "actual_longitude": "119.6167724",
                    "distance_to_location_meters": null,
                    "attendance_type": {
                        "id": 1,
                        "code": "MASUK",
                        "name": "Absen Masuk",
                        "direction": "in",
                        "description": "Presensi masuk kerja reguler berbasis lokasi GPS.",
                        "requires_location": true,
                        "requires_photo": false,
                        "requires_face_verification": false,
                        "requires_device_lock": false,
                        "allows_manual_entry": false,
                        "open_minutes_before": 60,
                        "close_minutes_after": 120,
                        "late_tolerance_minutes": 0,
                        "is_active": true,
                        "is_system": true,
                        "default_sequence": 1,
                        "is_skippable": true
                    },
                    "photo_url": null,
                    "note": null,
                    "is_valid_locked_device": true,
                    "is_face_verified": true
                },
                {
                    "id": 74,
                    "daily_record_id": 574,
                    "attendance_type_id": 2,
                    "sequence_no": 2,
                    "expected_at": "2026-06-03T08:00:00.000000Z",
                    "window_open_at": "2026-06-03T07:00:00.000000Z",
                    "window_close_at": "2026-06-03T10:00:00.000000Z",
                    "status": "pending",
                    "attended_at": null,
                    "source": null,
                    "is_manual_entry": false,
                    "required_location_id": null,
                    "required_location": null,
                    "effective_geofence_mode": "default",
                    "event_geofence": null,
                    "actual_latitude": null,
                    "actual_longitude": null,
                    "distance_to_location_meters": null,
                    "attendance_type": {
                        "id": 2,
                        "code": "PULANG",
                        "name": "Absen Pulang",
                        "direction": "out",
                        "description": "Presensi pulang kerja reguler berbasis lokasi GPS.",
                        "requires_location": true,
                        "requires_photo": false,
                        "requires_face_verification": false,
                        "requires_device_lock": false,
                        "allows_manual_entry": false,
                        "open_minutes_before": 240,
                        "close_minutes_after": 120,
                        "late_tolerance_minutes": 0,
                        "is_active": true,
                        "is_system": true,
                        "default_sequence": 2,
                        "is_skippable": true
                    },
                    "photo_url": null,
                    "note": null,
                    "is_valid_locked_device": false,
                    "is_face_verified": false
                }
            ]
        },
        "pending_submission": null,
        "current_tpp": null,
        "institution_info": {
            "id": 1,
            "code": "DISKOMINFO",
            "name": "Dinas Komunikasi, Informatika dan Statistik",
            "locations": [
                {
                    "id": 1,
                    "name": "Kantor Dinas Kominfo",
                    "address": "Jl. Kantor Dinas Kominfo, Kab. Barru, Sulawesi Selatan",
                    "latitude": -4.407,
                    "longitude": 119.623,
                    "radius_meters": 150
                }
            ]
        },
        "attendance_types": [
            {
                "id": 1,
                "code": "MASUK",
                "name": "Absen Masuk",
                "direction": "in",
                "description": "Presensi masuk kerja reguler berbasis lokasi GPS.",
                "requires_location": true,
                "requires_photo": false,
                "requires_face_verification": false,
                "requires_device_lock": false,
                "allows_manual_entry": false,
                "open_minutes_before": 60,
                "close_minutes_after": 120,
                "late_tolerance_minutes": 0,
                "is_active": true,
                "is_system": true,
                "default_sequence": 1,
                "is_skippable": true
            },
            {
                "id": 2,
                "code": "PULANG",
                "name": "Absen Pulang",
                "direction": "out",
                "description": "Presensi pulang kerja reguler berbasis lokasi GPS.",
                "requires_location": true,
                "requires_photo": false,
                "requires_face_verification": false,
                "requires_device_lock": false,
                "allows_manual_entry": false,
                "open_minutes_before": 240,
                "close_minutes_after": 120,
                "late_tolerance_minutes": 0,
                "is_active": true,
                "is_system": true,
                "default_sequence": 2,
                "is_skippable": true
            }
        ],
        "settings": {
            "attendance": {
                "daily_check_enabled": true,
                "daily_check_first_time": "10:00",
                "daily_check_second_time": "15:00",
                "default_radius_meters": 150,
                "require_photo": true
            }
        }
    }
  }''';

  try {
    final Map<String, dynamic> data = jsonDecode(jsonString)['data'];
    final model = DashboardModel.fromJson(data);
    print("Parsed successfully: ${model.todaySchedule?.id}");
    print("Is Workday: ${model.todaySchedule?.isWorkday}");
    print("Records count: ${model.todaySchedule?.records.length}");
    for (var r in model.todaySchedule!.records) {
      print("Record status: ${r.status}, isPending: ${r.isPending}, isCompleted: ${r.isCompleted}");
    }
  } catch (e, st) {
    print("Error parsing json: $e");
    print(st);
  }
}
