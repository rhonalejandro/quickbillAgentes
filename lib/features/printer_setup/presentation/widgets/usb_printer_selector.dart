import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

class UsbPrinterSelector extends StatelessWidget {
  const UsbPrinterSelector({
    super.key,
    required this.printers,
    required this.selected,
    required this.isLoading,
    required this.onChanged,
  });

  final List<String> printers;
  final String? selected;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Row(
        children: [
          const SizedBox(
            width: AppDimensions.iconMd,
            height: AppDimensions.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Text(AppStrings.printerLoadingList, style: AppTextStyles.bodyMedium),
        ],
      );
    }

    if (printers.isEmpty) {
      return Text(
        AppStrings.printerNoneFound,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.printerNameLabel, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppDimensions.sm),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: selected, // ignore: deprecated_member_use
          hint: Text(
            AppStrings.printerNameHint,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          decoration: const InputDecoration(),
          items: printers
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? AppStrings.printerNameRequired : null,
        ),
      ],
    );
  }
}
