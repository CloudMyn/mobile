import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/presensi_controller.dart';

/// Menampilkan progress langkah presensi berdasarkan [PresensiStep].
class PresensiStepIndicator extends StatelessWidget {
  final PresensiStep currentStep;
  final bool hasFaceRecognition;
  final bool hasFaceCapture;
  final bool hasGeofence;

  const PresensiStepIndicator({
    super.key,
    required this.currentStep,
    this.hasFaceRecognition = false,
    this.hasFaceCapture = false,
    this.hasGeofence = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final steps = _buildStepList();
    if (steps.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s16.w,
        vertical: AppSpacing.s12.h,
      ),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            _StepNode(
              icon: steps[i].icon,
              label: steps[i].label,
              state: _stateFor(steps[i].step),
              colors: colors,
              typography: typography,
            ),
            if (i < steps.length - 1)
              _StepConnector(
                isCompleted: _isCompleted(steps[i].step),
                colors: colors,
              ),
          ],
        ],
      ),
    );
  }

  List<_StepMeta> _buildStepList() {
    final list = <_StepMeta>[];

    if (hasFaceRecognition) {
      list.add(_StepMeta(
        step: PresensiStep.liveness,
        icon: Icons.face_rounded,
        label: 'Liveness',
      ));
    }

    if (hasFaceCapture || hasFaceRecognition) {
      list.add(_StepMeta(
        step: PresensiStep.faceCapture,
        icon: Icons.camera_alt_rounded,
        label: 'Foto',
      ));
    }

    if (hasGeofence) {
      list.add(_StepMeta(
        step: PresensiStep.geofenceCheck,
        icon: Icons.location_on_rounded,
        label: 'Lokasi',
      ));
    }

    list.add(_StepMeta(
      step: PresensiStep.submitting,
      icon: Icons.check_circle_rounded,
      label: 'Submit',
    ));

    return list;
  }

  _StepNodeState _stateFor(PresensiStep step) {
    if (currentStep == PresensiStep.success) return _StepNodeState.completed;
    if (currentStep == PresensiStep.error) {
      if (_stepIndex(step) < _stepIndex(currentStep)) {
        return _StepNodeState.completed;
      }
      return _StepNodeState.pending;
    }
    final current = _stepIndex(currentStep);
    final target = _stepIndex(step);
    if (target < current) return _StepNodeState.completed;
    if (target == current) return _StepNodeState.active;
    return _StepNodeState.pending;
  }

  bool _isCompleted(PresensiStep step) =>
      _stateFor(step) == _StepNodeState.completed;

  int _stepIndex(PresensiStep s) => switch (s) {
        PresensiStep.idle => 0,
        PresensiStep.liveness => 1,
        PresensiStep.faceCapture => 2,
        PresensiStep.geofenceCheck => 3,
        PresensiStep.submitting => 4,
        PresensiStep.success => 5,
        PresensiStep.error => 6,
      };
}

// =============================================================================
enum _StepNodeState { pending, active, completed }

class _StepNode extends StatelessWidget {
  final IconData icon;
  final String label;
  final _StepNodeState state;
  final AppColors colors;
  final AppTypography typography;

  const _StepNode({
    required this.icon,
    required this.label,
    required this.state,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = switch (state) {
      _StepNodeState.completed => colors.success,
      _StepNodeState.active => colors.primary,
      _StepNodeState.pending => colors.outline,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.s4,
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(
                alpha: state == _StepNodeState.pending ? 0.08 : 0.15),
            border: Border.all(
              color: color,
              width: state == _StepNodeState.active ? 2.0 : 1.0,
            ),
          ),
          child: Icon(
            state == _StepNodeState.completed ? Icons.check_rounded : icon,
            size: 18.sp,
            color: color,
          ),
        ),
        Text(
          label,
          style: typography.caption.copyWith(
            color: color,
            fontWeight: state == _StepNodeState.active
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isCompleted;
  final AppColors colors;

  const _StepConnector({required this.isCompleted, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: AppSpacing.s16.h),
        color: isCompleted
            ? colors.success
            : colors.outline.withValues(alpha: 0.3),
      ),
    );
  }
}

class _StepMeta {
  final PresensiStep step;
  final IconData icon;
  final String label;
  const _StepMeta({required this.step, required this.icon, required this.label});
}
