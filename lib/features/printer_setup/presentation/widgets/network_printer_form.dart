import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';

class NetworkPrinterForm extends StatelessWidget {
  const NetworkPrinterForm({
    super.key,
    required this.ipController,
    required this.portController,
    required this.formKey,
  });

  final TextEditingController ipController;
  final TextEditingController portController;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextField(
            label: AppStrings.printerIpLabel,
            hint: AppStrings.printerIpHint,
            controller: ipController,
            keyboardType: TextInputType.url,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? AppStrings.printerIpRequired : null,
          ),
          const SizedBox(height: AppDimensions.md),
          CustomTextField(
            label: AppStrings.printerPortLabel,
            hint: AppStrings.printerPortHint,
            controller: portController,
            keyboardType: TextInputType.number,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? AppStrings.printerPortRequired : null,
          ),
        ],
      ),
    );
  }
}
