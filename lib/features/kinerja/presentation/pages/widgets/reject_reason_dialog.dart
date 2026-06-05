import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../design_system/components/app_button.dart';
import '../../../../../design_system/components/app_text_field.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';
import '../../controllers/kinerja_bawahan_controller.dart';

class RejectReasonDialog extends StatefulWidget {
  final String activityId;

  const RejectReasonDialog({super.key, required this.activityId});

  @override
  State<RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<RejectReasonDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Get.find<KinerjaBawahanController>().rejectActivity(
        widget.activityId,
        _reasonController.text,
      );
      setState(() => _isLoading = false);
      
      // Close dialog
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return AlertDialog(
      title: Text(
        'Tolak Kinerja',
        style: typography.titleMedium.copyWith(
          color: colors.error,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Silakan masukkan alasan penolakan kinerja ini. Alasan akan dikirimkan kepada pegawai yang bersangkutan.',
              style: typography.bodyMedium.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.s16),
            AppTextField(
              controller: _reasonController,
              label: 'Alasan Penolakan',
              hint: 'Masukkan alasan...',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Alasan penolakan wajib diisi';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text('Batal', style: typography.labelLarge.copyWith(color: colors.onSurface)),
        ),
        AppButton(
          label: 'Tolak',
          onPressed: _isLoading ? null : _submit,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
