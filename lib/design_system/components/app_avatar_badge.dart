import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';

enum AppAvatarStatus { online, offline, busy, none }

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final AppAvatarStatus status;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 48,
    this.status = AppAvatarStatus.none,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return initials != null
                          ? Center(
                              child: Text(
                                initials!,
                                style: TextStyle(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: size * 0.4,
                                ),
                              ),
                            )
                          : const SizedBox();
                    },
                  )
                : (initials != null
                    ? Center(
                        child: Text(
                          initials!,
                          style: TextStyle(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: size * 0.4,
                          ),
                        ),
                      )
                    : const SizedBox()),
          ),
        ),
        if (status != AppAvatarStatus.none)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: _getStatusColor(colors),
                shape: BoxShape.circle,
                border: Border.all(color: colors.background, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(AppColors colors) {
    switch (status) {
      case AppAvatarStatus.online:
        return colors.success;
      case AppAvatarStatus.offline:
        return colors.outline;
      case AppAvatarStatus.busy:
        return colors.error;
      case AppAvatarStatus.none:
        return Colors.transparent;
    }
  }
}

class AppBadge extends StatelessWidget {
  final Widget child;
  final String? label;
  final bool showDot;

  const AppBadge({
    super.key,
    required this.child,
    this.label,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (showDot || label != null)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: label != null ? 6 : 0,
                vertical: label != null ? 2 : 0,
              ),
              constraints: BoxConstraints(
                minWidth: label != null ? 18 : 10,
                minHeight: label != null ? 18 : 10,
              ),
              decoration: BoxDecoration(
                color: colors.error,
                borderRadius: BorderRadius.circular(AppRadius.circular),
                border: Border.all(color: colors.background, width: 1.5),
              ),
              child: label != null
                  ? Center(
                      child: Text(
                        label!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
