import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/network/session_manager.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/employee_enums.dart';
import '../../data/models/reference_model.dart';
import '../controllers/profile_controller.dart';

class UpdateEmployeePage extends StatelessWidget {
  const UpdateEmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppTopAppBar(
          title: 'Data Pegawai',
          variant: AppTopAppBarVariant.withBack,
          bottom: TabBar(
            isScrollable: true,
            labelColor: colors.primary,
            unselectedLabelColor: colors.outline,
            indicatorColor: colors.primary,
            labelStyle: typography.labelLarge.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: typography.labelLarge,
            tabs: const [
              Tab(text: 'Personal'),
              Tab(text: 'Kontak & Alamat'),
              Tab(text: 'Info Bank'),
              Tab(text: 'Keluarga & Darurat'),
            ],
          ),
        ),
        body: Obx(() {
          if (ctrl.isLoadingEmployeeData.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.s16.h),
                  Text('Memuat data pegawai...', style: typography.bodyMedium),
                ],
              ),
            );
          }
          return TabBarView(
            children: [
              _PersonalTab(colors: colors, typography: typography, ctrl: ctrl),
              _ContactTab(colors: colors, typography: typography, ctrl: ctrl),
              _BankTab(colors: colors, typography: typography, ctrl: ctrl),
              _FamilyTab(colors: colors, typography: typography, ctrl: ctrl),
            ],
          );
        }),
      ),
    );
  }
}

class _PersonalTab extends StatelessWidget {
  final AppColors colors;
  final AppTypography typography;
  final ProfileController ctrl;

  const _PersonalTab({required this.colors, required this.typography, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final emp = ctrl.employee.value;
    final nipCtrl = TextEditingController(text: emp?.nip ?? '');
    final isLocked = !ctrl.canEditHistoricalData;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageIntro(
            colors: colors,
            typography: typography,
            title: 'Data Personal',
            subtitle: 'Lengkapi identitas dasar Anda. Data utama yang telah disimpan hanya dapat diubah oleh Admin.',
          ),
          SizedBox(height: AppSpacing.s16.h),
          _StatusCard(
            colors: colors,
            typography: typography,
            icon: isLocked ? Icons.lock_outline_rounded : Icons.info_outline_rounded,
            title: isLocked ? 'Data historis terkunci' : 'Lengkapi dengan benar',
            message: isLocked
                ? 'NIP dan beberapa data utama dikunci.'
                : 'Setelah disimpan, beberapa field utama tidak dapat diubah.',
            tint: isLocked ? colors.warning : colors.primary,
          ),
          SizedBox(height: AppSpacing.s16.h),
          Obx(() {
            final userSession = Get.find<SessionManager>().currentUser.value;
            final hasJobTitle = userSession?.jobTitle != null || ctrl.selectedJobTitle.value != null;
            final hasInstitution = userSession?.institution != null || userSession?.department != null || ctrl.selectedInstitution.value != null;
            final hasMaritalStatus = ctrl.maritalStatus.value != null;
            final hasReligion = ctrl.religion.value != null;
            final hasGender = ctrl.gender.value != null;
            final hasBirthDate = ctrl.birthDate.value != null;

            final missingFields = <String>[];
            if (!hasJobTitle) missingFields.add('Jabatan');
            if (!hasInstitution) missingFields.add('Unit Kerja');
            if (!hasMaritalStatus) missingFields.add('Status Perkawinan');
            if (!hasReligion) missingFields.add('Agama');
            if (!hasGender) missingFields.add('Jenis Kelamin');
            if (!hasBirthDate) missingFields.add('Tanggal Lahir');

            if (missingFields.isEmpty) return const SizedBox.shrink();

            return Column(
              children: [
                _StatusCard(
                  colors: colors,
                  typography: typography,
                  icon: Icons.warning_amber_rounded,
                  title: 'Data Belum Lengkap',
                  message: 'Harap lengkapi kolom berikut: ${missingFields.join(', ')}.',
                  tint: colors.error,
                ),
                SizedBox(height: AppSpacing.s16.h),
              ],
            );
          }),
          AppCard(
            outlined: true,
            child: Form(
              key: ctrl.formKeyPersonal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'NIP',
                    hint: 'Nomor Induk Pegawai',
                    controller: nipCtrl,
                    readOnly: true,
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  AppTextField(
                    label: 'NIK',
                    hint: 'Nomor Induk Kependudukan',
                    controller: ctrl.nikCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.credit_card_outlined),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  AppTextField(
                    label: 'Nama Lengkap (Tanpa Gelar)',
                    hint: 'Masukkan nama lengkap',
                    controller: ctrl.namaCtrl,
                    readOnly: isLocked,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    validator: ctrl.validateHistoricalFullName,
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Gelar Depan',
                          hint: 'Contoh: Dr., Ir.',
                          controller: ctrl.titlePrefixCtrl,
                        ),
                      ),
                      SizedBox(width: AppSpacing.s16.w),
                      Expanded(
                        child: AppTextField(
                          label: 'Gelar Belakang',
                          hint: 'Contoh: S.Kom., M.Ti.',
                          controller: ctrl.titleSuffixCtrl,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Tempat Lahir',
                          hint: 'Kota Lahir',
                          controller: ctrl.birthPlaceCtrl,
                        ),
                      ),
                      SizedBox(width: AppSpacing.s16.w),
                      Expanded(
                        child: Obx(() {
                          final dateText = ctrl.birthDate.value != null
                              ? ctrl.birthDate.value!.toIso8601String().split('T')[0]
                              : '';
                          final dateCtrl = TextEditingController(text: dateText);
                          return AppTextField(
                            label: 'Tanggal Lahir',
                            hint: 'YYYY-MM-DD',
                            controller: dateCtrl,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: ctrl.birthDate.value ?? DateTime(1990),
                                firstDate: DateTime(1940),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                ctrl.birthDate.value = picked;
                              }
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  Obx(() => _buildDropdown<Gender>(
                    label: 'Jenis Kelamin',
                    value: ctrl.gender.value,
                    items: Gender.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
                    onChanged: (v) => ctrl.gender.value = v,
                    colors: colors,
                    typography: typography,
                  )),
                  SizedBox(height: AppSpacing.s16.h),
                  Obx(() => _buildDropdown<Religion>(
                    label: 'Agama',
                    value: ctrl.religion.value,
                    items: Religion.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
                    onChanged: (v) => ctrl.religion.value = v,
                    colors: colors,
                    typography: typography,
                  )),
                  SizedBox(height: AppSpacing.s16.h),
                  Obx(() => _buildDropdown<MaritalStatus>(
                    label: 'Status Perkawinan',
                    value: ctrl.maritalStatus.value,
                    items: MaritalStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
                    onChanged: (v) => ctrl.maritalStatus.value = v,
                    colors: colors,
                    typography: typography,
                  )),
                  SizedBox(height: AppSpacing.s16.h),
                  Obx(() {
                    final userSession = Get.find<SessionManager>().currentUser.value;
                    final hasJobTitle = userSession?.jobTitle != null;

                    if (hasJobTitle) {
                      return AppTextField(
                        label: 'Jabatan',
                        hint: 'Jabatan pegawai',
                        controller: TextEditingController(text: userSession?.jobTitle?.name ?? ''),
                        readOnly: true,
                        prefixIcon: const Icon(Icons.work_outline_rounded),
                      );
                    } else {
                      return _buildDropdown<ReferenceItem>(
                        label: 'Jabatan',
                        value: ctrl.selectedJobTitle.value,
                        items: ctrl.jobTitles.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                        onChanged: (v) => ctrl.selectedJobTitle.value = v,
                        colors: colors,
                        typography: typography,
                        hint: Text(
                          ctrl.isLoadingReferences.value ? 'Memuat jabatan...' : 'Pilih Jabatan',
                          style: typography.bodyMedium.copyWith(color: colors.outline),
                        ),
                      );
                    }
                  }),
                  SizedBox(height: AppSpacing.s16.h),
                  Obx(() {
                    final userSession = Get.find<SessionManager>().currentUser.value;
                    final hasInstitution = userSession?.institution != null || userSession?.department != null;

                    if (hasInstitution) {
                      final unitName = userSession?.institution?.name ?? userSession?.department?.name ?? '';
                      return AppTextField(
                        label: 'Unit Kerja',
                        hint: 'Unit/OPD',
                        controller: TextEditingController(text: unitName),
                        readOnly: true,
                        prefixIcon: const Icon(Icons.apartment_rounded),
                      );
                    } else {
                      return _buildDropdown<ReferenceItem>(
                        label: 'Unit Kerja',
                        value: ctrl.selectedInstitution.value,
                        items: ctrl.institutions.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                        onChanged: (v) => ctrl.selectedInstitution.value = v,
                        colors: colors,
                        typography: typography,
                        hint: Text(
                          ctrl.isLoadingReferences.value ? 'Memuat unit kerja...' : 'Pilih Unit Kerja',
                          style: typography.bodyMedium.copyWith(color: colors.outline),
                        ),
                      );
                    }
                  }),
                  SizedBox(height: AppSpacing.s24.h),
                  Obx(
                    () => AppButton(
                      label: 'Simpan Data Personal',
                      fullWidth: true,
                      icon: Icons.save_rounded,
                      isLoading: ctrl.isSavingPersonal.value,
                      onPressed: ctrl.savePersonalData,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required AppColors colors,
    required AppTypography typography,
    Widget? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.labelLarge.copyWith(color: colors.onSurface, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.s8.h),
        DropdownButtonFormField<T>(
          value: value,
          hint: hint,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.s16.w, vertical: AppSpacing.s12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: colors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: colors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactTab extends StatelessWidget {
  final AppColors colors;
  final AppTypography typography;
  final ProfileController ctrl;

  const _ContactTab({required this.colors, required this.typography, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageIntro(
            colors: colors,
            typography: typography,
            title: 'Kontak & Alamat',
            subtitle: 'Pastikan email, nomor HP, dan alamat selalu diperbarui agar instansi mudah menghubungi Anda.',
          ),
          SizedBox(height: AppSpacing.s16.h),
          AppCard(
            outlined: true,
            child: Form(
              key: ctrl.formKeyContact,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Email',
                    hint: 'Alamat email aktif',
                    controller: ctrl.emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  SizedBox(height: AppSpacing.s8.h),
                  Text(
                    'Email dikelola oleh sistem dan saat ini belum dapat diubah melalui mobile.',
                    style: typography.caption.copyWith(color: colors.outline),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  AppTextField(
                    label: 'Nomor HP',
                    hint: 'Contoh: 08123456789',
                    controller: ctrl.phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  AppTextField(
                    label: 'Alamat Domisili',
                    hint: 'Jalan, RT/RW, Dusun',
                    controller: ctrl.alamatCtrl,
                    maxLines: 3,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  AppTextField(
                    label: 'Kode Pos',
                    hint: 'Contoh: 90711',
                    controller: ctrl.postalCodeCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                  ),
                  SizedBox(height: AppSpacing.s24.h),
                  Obx(
                    () => AppButton(
                      label: 'Simpan Kontak',
                      fullWidth: true,
                      icon: Icons.save_outlined,
                      isLoading: ctrl.isSavingContact.value,
                      onPressed: ctrl.saveContactData,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankTab extends StatelessWidget {
  final AppColors colors;
  final AppTypography typography;
  final ProfileController ctrl;

  const _BankTab({required this.colors, required this.typography, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageIntro(
            colors: colors,
            typography: typography,
            title: 'Informasi Rekening',
            subtitle: 'Data rekening bank yang digunakan untuk keperluan penggajian dan administrasi lainnya.',
          ),
          SizedBox(height: AppSpacing.s16.h),
          AppCard(
            outlined: true,
            child: Form(
              key: ctrl.formKeyBank,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Nama Bank',
                    hint: 'Contoh: Bank Sulselbar, BRI, BNI',
                    controller: ctrl.bankNameCtrl,
                    prefixIcon: const Icon(Icons.account_balance_outlined),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  AppTextField(
                    label: 'Nomor Rekening',
                    hint: 'Masukkan nomor rekening',
                    controller: ctrl.bankAccountNumberCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.numbers_outlined),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  AppTextField(
                    label: 'Nama Pemilik Rekening',
                    hint: 'Sesuai dengan buku tabungan',
                    controller: ctrl.bankAccountHolderNameCtrl,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  SizedBox(height: AppSpacing.s24.h),
                  Obx(
                    () => AppButton(
                      label: 'Simpan Info Bank',
                      fullWidth: true,
                      icon: Icons.save_outlined,
                      isLoading: ctrl.isSavingBank.value,
                      onPressed: ctrl.saveBankData,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyTab extends StatelessWidget {
  final AppColors colors;
  final AppTypography typography;
  final ProfileController ctrl;

  const _FamilyTab({required this.colors, required this.typography, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageIntro(
            colors: colors,
            typography: typography,
            title: 'Keluarga & Darurat',
            subtitle: 'Informasi orang tua, jumlah anak, dan kontak darurat yang dapat dihubungi jika terjadi sesuatu.',
          ),
          SizedBox(height: AppSpacing.s16.h),
          AppCard(
            outlined: true,
            child: Form(
              key: ctrl.formKeyFamily,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data Orang Tua & Anak', style: typography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(),
                  SizedBox(height: AppSpacing.s8.h),
                  AppTextField(
                    label: 'Nama Ayah Kandung',
                    hint: 'Masukkan nama ayah',
                    controller: ctrl.fatherNameCtrl,
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  AppTextField(
                    label: 'Nama Ibu Kandung',
                    hint: 'Masukkan nama ibu',
                    controller: ctrl.motherNameCtrl,
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  AppTextField(
                    label: 'Jumlah Anak',
                    hint: 'Contoh: 2',
                    controller: ctrl.childrenCountCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: AppSpacing.s24.h),
                  
                  Text('Kontak Darurat', style: typography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(),
                  SizedBox(height: AppSpacing.s8.h),
                  AppTextField(
                    label: 'Nama Kontak Darurat',
                    hint: 'Nama lengkap kerabat/keluarga',
                    controller: ctrl.emergencyContactNameCtrl,
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  AppTextField(
                    label: 'Nomor HP Darurat',
                    hint: '08xxxxxxx',
                    controller: ctrl.emergencyContactPhoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  AppTextField(
                    label: 'Hubungan Darurat',
                    hint: 'Contoh: Istri, Suami, Saudara',
                    controller: ctrl.emergencyContactRelationshipCtrl,
                  ),
                  SizedBox(height: AppSpacing.s24.h),

                  Obx(
                    () => AppButton(
                      label: 'Simpan Data Keluarga',
                      fullWidth: true,
                      icon: Icons.save_outlined,
                      isLoading: ctrl.isSavingFamily.value,
                      onPressed: ctrl.saveFamilyData,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIntro extends StatelessWidget {
  final AppColors colors;
  final AppTypography typography;
  final String title;
  final String subtitle;

  const _PageIntro({
    required this.colors,
    required this.typography,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.manage_accounts_rounded,
              color: colors.primary,
              size: 20.w,
            ),
          ),
          SizedBox(width: AppSpacing.s12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Text(
                  subtitle,
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final AppColors colors;
  final AppTypography typography;
  final IconData icon;
  final String title;
  final String message;
  final Color tint;

  const _StatusCard({
    required this.colors,
    required this.typography,
    required this.icon,
    required this.title,
    required this.message,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      outlined: true,
      padding: const EdgeInsets.all(AppSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16.w, color: tint),
          ),
          SizedBox(width: AppSpacing.s10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.labelLarge.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Text(
                  message,
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
