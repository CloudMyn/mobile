# Changelog - Mobile Presensi App

## [Uncommitted Changes] - Current WIP

### Security & Location Verification Bypass
* **Bypass Face & Geofence Verification:** Added `isBypassFermuk` property to [UserModel](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/auth/data/models/user_model.dart) to support users exempted from facial recognition verification.
* **Smart Verification Bypassing:** Updated [AttendanceConfig](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/presensi/data/models/attendance_config.dart) to automatically disable facial recognition and geofencing validation if `isBypassFermuk` is active or if the attendance record does not require a location.

### Security Scoring System Adjustment
* **Threshold Adjustment:** Adjusted the blocking threshold for device/location security scores from `> 50` to `>= 100` in [PresensiController](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/presensi/presentation/controllers/presensi_controller.dart). Users with a warning score below 100 will see a warning snackbar but are allowed to proceed.
* **Verification Flow Reordering:** Moved the security score evaluation to execute *after* geofence calculations in [PresensiController](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/presensi/presentation/controllers/presensi_controller.dart). This ensures that the UI can calculate and display the closest location and distance best-effort even when there are warnings or blocks.
* **Enhanced Block Alert UI:** Added a block warning card styled alert in [PresencePage](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/presensi/presentation/pages/presence_page.dart) listing security violation details when block criteria are met, and locked the submit action.

### Profile Completion Workflow & Reference API Integration
* **Reference Model Integration:** Introduced a new generic [ReferenceItem](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/profile/data/models/reference_model.dart) model.
* **Dynamic Form Fields:** Modified [UpdateEmployeePage](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/profile/presentation/pages/update_employee_page.dart) to show an alert indicating missing profile data (Jabatan, Unit Kerja, Status Perkawinan, Agama, Jenis Kelamin, Tanggal Lahir).
* **Editable Job Title and Work Unit:** Replaced static read-only textfields for "Jabatan" and "Unit Kerja" with dynamic search dropdown elements if their initial values are null/empty. Loaded reference datasets using the newly created `fetchReferences()` endpoint in [ProfileRepository](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/profile/data/repositories/profile_repository.dart) and [ProfileController](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/profile/presentation/controllers/profile_controller.dart).

### Image Loading & URL Sanitization
* **Local Development Domain Mapping:** Added a utility function `sanitizeImageUrl()` to [AppConstants](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/core/constants/app_constants.dart) to automatically map localhost/local Minio server URLs to the active API base host, resolving image loading issues on emulators and physical testing devices.
* **Sanitized Performance Attachments:** Updated [KinerjaListPage](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/kinerja/presentation/pages/kinerja_list_page.dart) and [KinerjaItemDetailSheet](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/kinerja/presentation/pages/widgets/kinerja_item_detail_sheet.dart) to sanitize image URLs prior to rendering.
* **Error Fallback UI:** Enhanced image loading error states to display a fallback broken image icon rather than collapsing or overflowing inside [AppImageViewer](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/design_system/components/app_image_viewer.dart).

---

## [b9b0ba4] - 2026-07-02
* **Submission Details Widget:** Implemented the `SubmissionTypeInfoCard` to display comprehensive details of submission types, requirements, and approval tracks.
* **Reusable App Button & Performance Limit:** Refactored `AppButton` and adjusted `KinerjaListPage` to show all activities up to a maximum limit of 5 items, replacing the old 3-day window limit.
* **Performance Module Skeleton:** Set up base controllers and directory foundations for the performance (kinerja) tracking system.

---

## [7e98bae] - 2026-07-02
* **Submission Module Foundation:** Created `SubmissionType` model, base `SubmissionFormController`, and custom `AttachmentUploadField` widget for uploading supporting documents.
* **Form Simplification:** Optimized the submission creation page (`SubmissionCreatePage`) and updated the notification system handler (`NotificationController`).

---

## [aa314b3] - 2026-07-02
* **TPP Daily Detail Screen:** Implemented `TppDailyDetailScreen` to show detailed breakdown of daily performance allowances (TPP) calculations.
* **Dashboard Statistics & Comments:** Created `StatistikModel` and updated `TppStatCard` for home dashboard visualization. Added comments and subordinate submissions models.
