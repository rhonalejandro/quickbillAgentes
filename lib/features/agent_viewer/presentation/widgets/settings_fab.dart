import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class SettingsFab extends StatelessWidget {
  const SettingsFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppDimensions.radiusMd),
            bottomRight: Radius.circular(AppDimensions.radiusMd),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.onBackground.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.settings_rounded,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
