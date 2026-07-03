# Changelog - Mobile Presensi App

## [1.1.4+1] - 2026-07-03

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

### Commenter Profiles & Detailed Information
* **Comment Avatar Sanitization:** Updated [CommentItem](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/informasi/data/models/comment_item.dart) to parse avatars from both `profile_picture_url` and `avatar_url` API fields.
* **Commenter Details Dialog:** Implemented public user profile retrieval in [InformasiService](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/informasi/data/services/informasi_service.dart) and [InformasiController](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/informasi/presentation/controllers/informasi_controller.dart). Displayed details (Instansi, Jabatan, and Pangkat/Golongan) via a bottom sheet in [comment_section.dart](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/informasi/presentation/widgets/comment_section.dart) with loaded/loading states.
* **User Rank Integration:** Added `rank` property and `UserRank` model mapping to [UserModel](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/auth/data/models/user_model.dart) to support display labels of user's rank/class.

### User Shift Schedule Control
* **Active Shift Highlighting:** Updated [ShiftSchedulePage](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/profile/presentation/pages/shift_schedule_page.dart) and [ProfileController](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/profile/presentation/controllers/profile_controller.dart) to track and clearly tag the user's currently active shift with a border and "Aktif Saat Ini" badge.
* **Check-In Validation Warning:** Added a warning alert on [ShiftSchedulePage](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/profile/presentation/pages/shift_schedule_page.dart) notifying users that shift schedule changes after an active check-in today will only take effect tomorrow.

### Subordinate Submissions List & Display
* **Paginated Response Parsing Fix:** Fixed subordinate submissions list empty/error bug in [ApiSubordinateSubmissionService](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/submission/data/services/subordinate_submission_service.dart) by adjusting the JSON envelopes to handle both lists and map-nested lists.
* **Safe Number Parsing:** Updated [SubordinateSubmissionItem](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/submission/data/models/subordinate_submission_item.dart) to perform safe string-to-double parsing for numeric properties (`totalDays`, `totalHours`) to prevent runtime parse crashes.
* **List View Error Fallback:** Added `AppErrorState` view handler inside [SubordinateSubmissionListPage](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/submission/presentation/pages/subordinate_submission_list_page.dart) to gracefully display connection errors and prompt for retry.
* **Approver Section Hiding:** Extended [SubmissionTypeInfoCard](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/submission/presentation/pages/widgets/submission_type_info_card.dart) with a `showApprover` toggle to prevent redundant information on subordinate details view in [SubordinateSubmissionDetailPage](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/submission/presentation/pages/subordinate_submission_detail_page.dart).

### UI Layouts & General Enhancements
* **Compact TPP Details:** Redesigned daily records in [TppDailyDetailScreen](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/home/presentation/pages/tpp_daily_detail_screen.dart) into a compact row format showing discipline and performance details alongside error/success icons.
* **Developer Options Refactoring:** Moved the "Full Reload Aplikasi" command from developer lists into a standalone outlined action button in [ProfileTab](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/home/presentation/pages/tabs/profile_tab.dart).
* **Compact Request Logger UI:** Optimised metadata alignment in [RequestLogDetailPage](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/profile/presentation/pages/request_log_detail_page.dart) to fit timestamp and request sizes into a single clean line.
* **Version Display:** Added a version indicator labeling the current version name and build number at the footer of [ProfileTab](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/home/presentation/pages/tabs/profile_tab.dart).

### Networking & Customizations
* **Certificate Overrides:** Configured custom `HttpOverrides` in [main.dart](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/main.dart) to support certificate validation bypass for domains ending with `barrukab.go.id`.
* **Indonesian Locale Initialization:** Initialized date formatting for `id_ID` in [main.dart](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/main.dart).
* **Console Logging Fix:** Modified request logger console printing inside [RequestLogEntry](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/core/logging/request_log_entry.dart) to output strings line-by-line, preventing CLI text truncated bugs.
* **Splash Scaling:** Set image fit scaling to `BoxFit.contain` for Sekda image in [LeaderSplashPage](file:///d:/PROJECTS/barru_kab/presensi/mobile/lib/features/auth/presentation/pages/leader_splash_page.dart).

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
