import 'package:flutter/material.dart';
import '../components/app_button.dart';

class AppForm extends StatefulWidget {
  final GlobalKey<FormState>? formKey;
  final Widget child;
  final Future<void> Function()? onSubmit;
  final String? submitLabel;
  final bool showSubmitButton;

  const AppForm({
    super.key,
    this.formKey,
    required this.child,
    this.onSubmit,
    this.submitLabel,
    this.showSubmitButton = false,
  });

  @override
  State<AppForm> createState() => _AppFormState();
}

class _AppFormState extends State<AppForm> {
  late final GlobalKey<FormState> _formKey;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    try {
      await widget.onSubmit?.call();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.child,
          if (widget.showSubmitButton && widget.submitLabel != null) ...[
            const SizedBox(height: 16),
            AppButton(
              label: widget.submitLabel!,
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }
}

// Convenience validator functions
class AppValidators {
  static String? Function(String?) required([String message = 'Wajib diisi']) {
    return (value) => (value == null || value.trim().isEmpty) ? message : null;
  }

  static String? Function(String?) minLength(int min, [String? message]) {
    return (value) {
      if (value == null || value.length < min) {
        return message ?? 'Minimal $min karakter';
      }
      return null;
    };
  }

  static String? Function(String?) email([String message = 'Email tidak valid']) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      return emailRegex.hasMatch(value) ? null : message;
    };
  }

  static String? Function(String?) phone([String message = 'Nomor telepon tidak valid']) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final phoneRegex = RegExp(r'^[0-9+\-\s()]{8,}$');
      return phoneRegex.hasMatch(value) ? null : message;
    };
  }

  // Combine multiple validators — returns first error found
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (value) {
      for (final v in validators) {
        final result = v(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
