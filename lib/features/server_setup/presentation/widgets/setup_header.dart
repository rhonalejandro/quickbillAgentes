import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

class SetupHeader extends StatelessWidget {
  const SetupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: AppDimensions.iconXl,
          height: AppDimensions.iconXl,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: const Icon(
            Icons.groups_rounded,
            color: AppColors.onPrimary,
            size: AppDimensions.iconLg,
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Text(AppStrings.setupTitle, style: AppTextStyles.displayLarge),
        const SizedBox(height: AppDimensions.sm),
        Text(
          AppStrings.setupSubtitle,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
