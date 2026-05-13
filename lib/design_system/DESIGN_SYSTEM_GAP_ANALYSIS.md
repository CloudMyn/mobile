# Mobile Design System — Gap Analysis

> Audit tanggal: 12 Mei 2026  
> Basis: Material 3, Flutter `^3.11.0`, GetX `^4.7.3`

---

## Status: **~45% Complete**

Design system sudah punya fondasi yang baik: token warna (light/dark), typography, spacing, radius, dan 11 komponen dasar. Tapi masih banyak gap yang harus diisi agar siap production.

---

## ✅ What Exists (Already Done)

| Kategori | Item | File |
|---|---|---|
| **Tokens** | `AppColors` (ThemeExtension, light + dark) | `tokens/app_colors.dart` |
| **Tokens** | `AppTypography` (9 text styles, Outfit + Inter) | `tokens/app_typography.dart` |
| **Tokens** | `AppSpacing` (10 spacing constants) | `tokens/app_spacing.dart` |
| **Tokens** | `AppRadius` (9 radius constants) | `tokens/app_radius.dart` |
| **Theme** | `AppTheme` (Material 3, ColorScheme, AppBar, Card, Button defaults) | `theme/app_theme.dart` |
| **Components** | `AppButton` (filled/outlined/ghost + loading + icon) | `components/app_button.dart` |
| **Components** | `AppTextField` (label, hint, icons, error, obscure) | `components/app_text_field.dart` |
| **Components** | `AppCard` (elevated/outlined, tappable) | `components/app_card.dart` |
| **Components** | `AppCheckbox` / `AppRadioButton<T>` / `AppSwitch` | `components/app_selection_controls.dart` |
| **Components** | `AppAvatar` (image/initials + online/offline/busy) + `AppBadge` | `components/app_avatar_badge.dart` |
| **Components** | `AppChip` (ChoiceChip wrapper) | `components/app_chip.dart` |
| **Components** | `AppListItem` (leading, trailing, subtitle, divider) | `components/app_list_item.dart` |
| **Components** | `AppSkeleton` (shimmer, rect + circle) | `components/app_skeleton.dart` |
| **Components** | `AppDropdown<T>` (styled DropdownButtonFormField) | `components/app_dropdown.dart` |
| **Components** | `AppBottomNavBar` (animated, with items) | `components/app_bottom_nav_bar.dart` |
| **Components** | `AppFeedback` (snackbar, dialog, loading via GetX) | `components/app_feedback.dart` |
| **Tools** | `DesignSystemShowcasePage` | `tools/design_system_showcase_page.dart` |

---

## ❌ Gap Analysis — What's Missing

### 1. Incomplete Token Set

| # | Gap | Severity | Detail |
|---|---|---|---|
| 1 | **No elevation/shadow tokens** | HIGH | Hardcoded `elevation: 2`, `blurRadius: 10`, `offset: Offset(0,-5)` di berbagai komponen. Harus didefinisikan di `AppElevation` token. |
| 2 | **No opacity/alpha tokens** | MEDIUM | Pola `colors.outline.withOpacity(0.5)`, `0.3`, `0.1`, `0.05` berulang di 8+ tempat. Rawan inkonsistensi. |
| 3 | **No animation duration tokens** | MEDIUM | `Duration(milliseconds: 200)` hardcoded di `AppBottomNavBar`. Harus punya `AppDuration` token. |
| 4 | **No icon size tokens** | MEDIUM | Hardcoded: `size: 20`, `size: 18`, `size: 16`. Butuh `AppIconSize` token. |
| 5 | **No breakpoint tokens** | LOW | `ScreenUtil` sudah terpasang tapi tidak ada breakpoint constants (`mobile`, `tablet`, `desktop`). |
| 6 | **No border width tokens** | LOW | Hardcoded `width: 2`, `width: 1.5`. |

### 2. Typography Gaps

| # | Gap | Severity | Detail |
|---|---|---|---|
| 7 | **Tidak lengkap terhadap Material 3 spec** | HIGH | Material 3 punya `displayLarge/Medium/Small`, `headlineLarge/Medium/Small`, `titleLarge/Medium/Small`. Saat ini hanya `h1-h3` (mapping ke display scale) + `bodyLarge/Medium/Small` + `labelLarge/Medium/Small`. `titleMedium` dan `headlineSmall` dipakai di showcase page tapi TIDAK ADA di `AppTypography` — ini akan null/error. |
| 8 | **Tidak ada caption style** | MEDIUM | Butuh text style lebih kecil dari `bodySmall` (11-12px) untuk caption, legal text, metadata. |

### 3. Theme Coverage Gaps

| # | Gap | Severity | Detail |
|---|---|---|---|
| 9 | **Tidak ada `InputDecorationTheme`** | HIGH | Styling TextField / Dropdown diulang manual di setiap komponen (`OutlineInputBorder`, `BorderRadius`, `BorderSide`). Harus didefinisikan sekali di theme. |
| 10 | **Tidak ada `TabBarTheme`** | HIGH | Tidak ada tabs component maupun theme-nya. |
| 11 | **Tidak ada `SnackBarTheme`** | MEDIUM | Snackbar dibuat via GetX tanpa styled SnackBar theme. |
| 12 | **Tidak ada `BottomSheetTheme`** | MEDIUM | Tidak ada bottom sheet component maupun theme. |
| 13 | **Tidak ada `TooltipTheme`** | MEDIUM | Tidak ada tooltip component maupun theme. |
| 14 | **Tidak ada `DialogTheme`** | MEDIUM | Dialog dibuat via `AppFeedback` tanpa theme terpusat. |
| 15 | **Tidak ada `DividerTheme`** | LOW | Divider styling diulang manual (`Divider(height: 1, color: ...)`). |
| 16 | **Tidak ada `ChipTheme`** | LOW | AppChip menggunakan ChoiceChip tanpa theme chip global. |
| 17 | **Tidak ada `CheckboxTheme` / `RadioTheme` / `SwitchTheme`** | LOW | Warna di-set per-komponen, bukan dari theme. |
| 18 | **Tidak ada `FloatingActionButtonTheme`** | LOW | Tidak ada FAB component. |

### 4. Missing Components (High Priority — Apps Everyday)

| # | Gap | Severity | Detail |
|---|---|---|---|
| 19 | **AppTopAppBar** | HIGH | Tidak ada custom AppBar component. Saat ini hanya theme global, tidak reusable. |
| 20 | **AppEmptyState** | HIGH | Setiap app butuh empty state (ikon + title + subtitle + CTA). Belum ada. |
| 21 | **AppErrorState** | HIGH | Error state dengan retry button. Belum ada. |
| 22 | **AppSearchBar** | HIGH | Search input dengan debounce, clear button. Belum ada. |
| 23 | **AppLoadingOverlay** | MEDIUM | Full-screen loading overlay dengan spinner + pesan. |
| 24 | **AppBottomSheet** | MEDIUM | Bottom sheet dengan drag handle, scrollable content. |
| 25 | **AppTabs** | MEDIUM | TabBar + TabBarView wrapper dengan styling konsisten. |
| 26 | **AppDialog/AppModal** | MEDIUM | Dialog standalone (saat ini hanya via `AppFeedback.showDialog`). |
| 27 | **AppFloatingActionButton** | MEDIUM | FAB dengan extended/mini variant. |
| 28 | **AppSegmentedControl** | MEDIUM | Segmented toggle (iOS-style atau Material segmented button). |
| 29 | **AppImage** | MEDIUM | Network image dengan placeholder, error, loading states. |
| 30 | **AppPullToRefresh** | MEDIUM | RefreshIndicator wrapper. |
| 31 | **AppPageIndicator** | LOW | Dot indicator untuk carousel/onboarding. |
| 32 | **AppTooltip** | LOW | Tooltip wrapper dengan styling DS. |
| 33 | **AppDataTable** | LOW | Table dengan header sticky, sorting indicator. |
| 34 | **AppStepper** | LOW | Vertical/horizontal stepper. |
| 35 | **AppDrawer** | LOW | Navigation drawer component. |

### 5. Architecture & Pattern Gaps

| # | Gap | Severity | Detail |
|---|---|---|---|
| 36 | **Tidak ada form validation system** | HIGH | `errorText` ada di komponen tapi tidak ada form key, validator pattern, atau `AppForm` wrapper untuk validasi collective. |
| 37 | **Tidak ada accessibility baseline** | HIGH | Tidak ada semantic labels, `Semantics` widget usage, screen reader testing, atau contrast ratio enforcement. |
| 38 | **Tidak ada asset management convention** | MEDIUM | Belum ada standard path untuk icons, images, illustrations di `pubspec.yaml`. |
| 39 | **Tidak ada RTL consideration** | LOW | Tidak ada konfigurasi `Directionality` atau testing RTL. |

### 6. Potential Bugs & Code Smells

| # | Issue | File | Detail |
|---|---|---|---|
| 40 | `titleMedium` & `headlineSmall` dipakai tapi tidak didefinisikan | `design_system_showcase_page.dart:192:252` | `AppTypography` tidak punya `titleMedium` atau `headlineSmall`. Ini akan fallback ke Flutter default, bukan ke DS typography. |
| 41 | `Get.theme.cardColor` mungkin null | `app_feedback.dart:93` | Tidak ada jaminan `cardColor` di-set di `ColorScheme`. Lebih aman pakai `colors.surface`. |
| 42 | Tidak ada dark mode testing | Semua komponen | Warna dark palette sudah ada tapi komponen belum tentu di-test dalam dark mode (misal `AppSkeleton` hardcode `Colors.white` sebagai container color). |

---

## 📊 Priority Summary

### 🔴 Critical (harus segera)

1. Lengkapi typography: tambah `titleLarge`, `titleMedium`, `titleSmall`, `caption`
2. `InputDecorationTheme` di theme global — hilangkan duplikasi styling TextField/Dropdown
3. `AppEmptyState` + `AppErrorState` components
4. `AppSearchBar` component
5. Form validation pattern (`AppForm`)
6. Fix bug: `titleMedium`/`headlineSmall` digunakan tanpa definisi

### 🟡 Important (dalam 1-2 sprint)

7. Elevation/shadow tokens (`AppElevation`)
8. Animation duration tokens (`AppDuration`)
9. `AppTopAppBar` component
10. `AppTabs` component
11. `AppBottomSheet` component
12. `TabBarTheme`, `SnackBarTheme`, `BottomSheetTheme`
13. Dark mode testing & bug fixes (`AppSkeleton` white container)

### 🟢 Nice-to-have (backlog)

14. Opacity tokens, icon size tokens
15. `AppFloatingActionButton`, `AppSegmentedControl`, `AppImage`, `AppPullToRefresh`
16. `AppPageIndicator`, `AppTooltip`, `AppDataTable`, `AppStepper`, `AppDrawer`
17. Accessibility baseline (semantics, contrast)
18. RTL support
19. Asset convention documentation
