import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/printer_config.dart';

class PrinterTypeSelector extends StatelessWidget {
  const PrinterTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PrinterType selected;
  final ValueChanged<PrinterType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.printerSetupSubtitle, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppDimensions.sm),
        SegmentedButton<PrinterType>(
          segments: const [
            ButtonSegment(
              value: PrinterType.network,
              label: Text(AppStrings.printerTypeNetwork),
              icon: Icon(Icons.wifi_rounded),
            ),
            ButtonSegment(
              value: PrinterType.windowsUsb,
              label: Text(AppStrings.printerTypeUsb),
              icon: Icon(Icons.usb_rounded),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (set) => onChanged(set.first),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return AppColors.surface;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.onPrimary;
              }
              return AppColors.onBackground;
            }),
          ),
        ),
      ],
    );
  }
}
