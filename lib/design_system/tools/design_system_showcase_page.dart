import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../accessibility/accessibility_helpers.dart';
import '../theme/app_theme.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../components/app_button.dart';
import '../components/app_text_field.dart';
import '../components/app_card.dart';
import '../components/app_selection_controls.dart';
import '../components/app_avatar_badge.dart';
import '../components/app_chip.dart';
import '../components/app_skeleton.dart';
import '../components/app_bottom_nav_bar.dart';
import '../components/app_feedback.dart';
import '../components/atoms/app_typography_text.dart';
import '../components/atoms/app_icon.dart';
import '../components/atoms/app_image.dart';
import '../components/molecules/app_search_bar.dart';
import '../components/molecules/app_empty_state.dart';
import '../components/molecules/app_error_state.dart';
import '../components/molecules/app_loading_overlay.dart';
import '../components/molecules/app_page_indicator.dart';
import '../components/organisms/app_top_app_bar.dart';
import '../components/organisms/app_bottom_sheet.dart';
import '../components/feedback/app_dialog.dart';
import '../components/feedback/app_tooltip.dart';
import '../form/app_form.dart';
import 'theme_viewer_page.dart';

class ShowcaseController extends GetxController {
  var checkboxValue = false.obs;
  var radioValue = 1.obs;
  var switchValue = false.obs;
  var selectedChip = 0.obs;
  var dropdownValue = 'Option 1'.obs;
  var bottomNavIndex = 0.obs;
  var isLoading = true.obs;
  var pageIndex = 0.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3), () => isLoading.value = false);
  }
}

class DesignSystemShowcasePage extends StatelessWidget {
  const DesignSystemShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ShowcaseController());
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System'),
        actions: [
          IconButton(
            icon: Icon(Get.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => Get.changeTheme(Get.isDarkMode ? AppTheme.light : AppTheme.dark),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ThemeViewerPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ────────────────── TYPOGRAPHY ──────────────────
            _section('Typography'),
            AppText.headlineSmall('Headline Small'),
            AppText.titleLarge('Title Large'),
            AppText.titleMedium('Title Medium'),
            AppText.titleSmall('Title Small'),
            AppText.bodyLarge('Body Large — Lorem ipsum dolor sit amet.'),
            AppText.bodyMedium('Body Medium — Lorem ipsum dolor sit amet.'),
            AppText.bodySmall('Body Small — Lorem ipsum dolor sit amet.'),
            AppText.caption('Caption — Lorem ipsum dolor sit amet.'),

            const Divider(height: AppSpacing.s40),

            // ────────────────── ICONS ──────────────────
            _section('Icons'),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                AppIcon(Icons.home, size: 12, color: colors.primary),
                AppIcon.sm(Icons.star, color: colors.warning),
                AppIcon.md(Icons.favorite, color: colors.error),
                AppIcon.lg(Icons.check_circle, color: colors.success),
                AppIcon.xl(Icons.diamond_outlined, color: colors.secondary),
              ],
            ),

            const Divider(height: AppSpacing.s40),

            // ────────────────── IMAGES ──────────────────
            _section('Network Images'),
            Row(
              children: [
                AppImage(
                  url: 'https://picsum.photos/80/80?random=1',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(width: 12),
                const AppImage(
                  url: '',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(width: 12),
                AppImage(
                  url: 'https://picsum.photos/80/80?random=2',
                  width: 80,
                  height: 80,
                  borderRadius: 40,
                ),
              ],
            ),

            const Divider(height: AppSpacing.s40),

            // ────────────────── SEARCH BAR ──────────────────
            _section('Search Bar'),
            AppSearchBar(
              placeholder: 'Cari karyawan...',
              onSearch: (q) => c.searchQuery.value = q,
            ),
            const SizedBox(height: 8),
            Obx(() => AppText.caption('Query: "${c.searchQuery.value}"')),

            const Divider(height: AppSpacing.s40),

            // ────────────────── PAGE INDICATOR ──────────────────
            _section('Page Indicator'),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => c.pageIndex.value = (c.pageIndex.value - 1).clamp(0, 4),
                  child: const Icon(Icons.chevron_left),
                ),
                const Spacer(),
                Obx(() => AppPageIndicator(count: 5, currentIndex: c.pageIndex.value)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => c.pageIndex.value = (c.pageIndex.value + 1).clamp(0, 4),
                  child: const Icon(Icons.chevron_right),
                ),
              ],
            ),

            const Divider(height: AppSpacing.s40),

            // ────────────────── EMPTY & ERROR STATE ──────────────────
            _section('Empty & Error States'),
            AppEmptyState(
              icon: Icons.inbox_outlined,
              title: 'Tidak ada data',
              subtitle: 'Belum ada karyawan terdaftar.',
              actionLabel: 'Tambah Karyawan',
              onAction: () {},
            ),
            const SizedBox(height: 16),
            AppErrorState(
              message: 'Koneksi terputus. Pastikan internet aktif.',
              onRetry: () {},
            ),

            const Divider(height: AppSpacing.s40),

            // ────────────────── TOP APP BAR ──────────────────
            _section('Top App Bar Variants'),
            const SizedBox(
              height: kToolbarHeight,
              child: AppTopAppBar(title: 'Standard'),
            ),
            const SizedBox(height: 8),
            const SizedBox(
              height: kToolbarHeight,
              child: AppTopAppBar(
                title: 'With Back Button',
                variant: AppTopAppBarVariant.withBack,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: kToolbarHeight,
              child: AppTopAppBar(
                title: 'With Search',
                variant: AppTopAppBarVariant.withSearch,
                onSearch: (q) {},
              ),
            ),

            const Divider(height: AppSpacing.s40),

            // ────────────────── BOTTOM SHEET ──────────────────
            _section('Bottom Sheet'),
            AppButton(
              label: 'Buka Bottom Sheet',
              style: AppButtonStyle.outlined,
              onPressed: () => AppBottomSheet.show(
                context: context,
                title: 'Pilih Opsi',
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit'),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Hapus'),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: AppSpacing.s40),

            // ────────────────── DIALOG ──────────────────
            _section('Dialog'),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Confirm Dialog',
                    onPressed: () => AppDialog.confirm(
                      title: 'Konfirmasi',
                      message: 'Apakah Anda yakin ingin melanjutkan?',
                      cancelLabel: 'Batal',
                      onConfirm: () {},
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Info Dialog',
                    style: AppButtonStyle.outlined,
                    onPressed: () => AppDialog.info(
                      title: 'Informasi',
                      message: 'Fitur ini tersedia untuk semua pengguna.',
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: AppSpacing.s40),

            // ────────────────── LOADING OVERLAY ──────────────────
            _section('Loading Overlay'),
            AppButton(
              label: 'Tampilkan Loading',
              onPressed: () {
                AppLoadingOverlay.show('Memproses data...');
                Future.delayed(const Duration(seconds: 2), AppLoadingOverlay.hide);
              },
              icon: Icons.hourglass_empty,
            ),

            const Divider(height: AppSpacing.s40),

            // ────────────────── TOOLTIP ──────────────────
            _section('Tooltip'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppTooltip(
                  message: 'Ini adalah tooltip',
                  triggerMode: TooltipTriggerMode.tap,
                  child: AppButton(
                    label: 'Tap untuk tooltip',
                    style: AppButtonStyle.outlined,
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const Divider(height: AppSpacing.s40),

            // ────────────────── FORM ──────────────────
            _section('Form dengan Validasi'),
            AppForm(
              showSubmitButton: true,
              submitLabel: 'Kirim',
              onSubmit: () async {
                await Future.delayed(const Duration(seconds: 1));
                AppFeedback.showSnackbar(title: 'Berhasil', message: 'Form telah dikirim!');
              },
              child: Column(
                children: [
                  AppTextField(
                    label: 'Email',
                    hint: 'contoh@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.compose([
                      AppValidators.required(),
                      AppValidators.email(),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  AppTextField(
                    label: 'Kata Sandi',
                    hint: 'Minimal 8 karakter',
                    obscureText: true,
                    validator: AppValidators.compose([
                      AppValidators.required(),
                      AppValidators.minLength(8),
                    ]),
                  ),
                ],
              ),
            ),

            const Divider(height: AppSpacing.s40),

            // ────────────────── SELECTION CONTROLS ──────────────────
            _section('Selection Controls'),
            Obx(() => AppCheckbox(
              label: 'Checkbox Label',
              value: c.checkboxValue.value,
              onChanged: (v) => c.checkboxValue.value = v!,
            )),
            Obx(() => Row(
              children: [
                AppRadioButton<int>(
                  label: 'Option 1',
                  value: 1,
                  groupValue: c.radioValue.value,
                  onChanged: (v) => c.radioValue.value = v!,
                ),
                AppRadioButton<int>(
                  label: 'Option 2',
                  value: 2,
                  groupValue: c.radioValue.value,
                  onChanged: (v) => c.radioValue.value = v!,
                ),
              ],
            )),
            Obx(() => AppSwitch(
              label: 'Enable Notifications',
              value: c.switchValue.value,
              onChanged: (v) => c.switchValue.value = v,
            )),

            const Divider(height: AppSpacing.s40),

            // ────────────────── AVATARS & BADGES ──────────────────
            _section('Avatars & Badges'),
            Row(
              children: [
                const AppAvatar(initials: 'JD', status: AppAvatarStatus.online),
                const SizedBox(width: AppSpacing.s16),
                const AppAvatar(status: AppAvatarStatus.busy),
                const SizedBox(width: AppSpacing.s16),
                AppBadge(
                  label: '3',
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppIcon(Icons.notifications, color: colors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                const AppBadge(showDot: true, child: Icon(Icons.mail)),
              ],
            ),

            const Divider(height: AppSpacing.s40),

            // ────────────────── CHIPS ──────────────────
            _section('Chips'),
            Obx(() => Wrap(
              spacing: 8,
              children: List.generate(
                3,
                (i) => AppChip(
                  label: 'Chip ${i + 1}',
                  isSelected: c.selectedChip.value == i,
                  onSelected: (_) => c.selectedChip.value = i,
                  icon: i == 0 ? Icons.star : null,
                ),
              ),
            )),

            const Divider(height: AppSpacing.s40),

            // ────────────────── SKELETON ──────────────────
            _section('Skeleton Shimmer'),
            Obx(() => c.isLoading.value
                ? Column(children: [
                    const Row(children: [
                      AppSkeleton.circle(size: 40),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeleton(width: 150, height: 12),
                          SizedBox(height: 8),
                          AppSkeleton(width: 100, height: 10),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 20),
                    AppSkeleton(width: double.infinity, height: 100, borderRadius: 12),
                  ])
                : AppCard(
                    child: Row(children: [
                      const AppAvatar(initials: 'SK'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.titleSmall('Data Loaded!'),
                            AppText.bodySmall('Skeleton demo selesai.'),
                          ],
                        ),
                      ),
                    ]),
                  )),

            const Divider(height: AppSpacing.s40),

            // ────────────────── FEEDBACK ──────────────────
            _section('Feedback Utilities'),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Snackbar',
                    onPressed: () => AppFeedback.showSnackbar(
                      title: 'Berhasil',
                      message: 'Operasi selesai!',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Dialog',
                    style: AppButtonStyle.outlined,
                    onPressed: () => AppFeedback.showDialog(
                      title: 'Konfirmasi',
                      message: 'Lanjutkan operasi ini?',
                      cancelLabel: 'Batal',
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: AppSpacing.s40),

            // ────────────────── ACCESSIBILITY DEMO ──────────────────
            _section('Accessibility'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.titleSmall('Semantic Wrapper Demo'),
                  const SizedBox(height: 8),
                  SemanticsWrapper(
                    label: 'Tombol aksi utama',
                    hint: 'Ketuk dua kali untuk mengaktifkan',
                    isButton: true,
                    child: AppButton(
                      label: 'Tombol Aksesibel',
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppText.bodySmall(
                    'Contrast ratio (primary on surface): '
                    '${AppContrastChecker.contrastRatio(colors.primary, colors.surface).toStringAsFixed(2)}:1 '
                    '— ${AppContrastChecker.passesAA(colors.primary, colors.surface) ? "✓ WCAG AA" : "✗ Fail AA"}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s64),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => AppBottomNavBar(
        currentIndex: c.bottomNavIndex.value,
        onTap: (index) => c.bottomNavIndex.value = index,
        items: const [
          AppBottomNavBarItem(icon: Icons.home_filled, label: 'Home'),
          AppBottomNavBarItem(icon: Icons.search, label: 'Search'),
          AppBottomNavBarItem(icon: Icons.person, label: 'Profile'),
        ],
      )),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: AppText.h3(title),
    );
  }
}
