import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../domain/entities/server_config.dart';
import '../providers/server_config_provider.dart';

class ServerForm extends ConsumerStatefulWidget {
  const ServerForm({super.key, required this.onSaved, this.onCancel});

  final VoidCallback onSaved;
  final VoidCallback? onCancel;

  @override
  ConsumerState<ServerForm> createState() => _ServerFormState();
}

class _ServerFormState extends ConsumerState<ServerForm> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _headerNameController = TextEditingController();
  final _headerValueController = TextEditingController();
  final _userAgentController = TextEditingController();
  bool _loading = false;

  bool get _isReconfiguring =>
      ref.read(serverConfigProvider).valueOrNull != null;

  @override
  void initState() {
    super.initState();
    _prefillIfExists();
  }

  void _prefillIfExists() {
    final existing = ref.read(serverConfigProvider).valueOrNull;
    if (existing == null) return;
    _hostController.text = existing.host;
    _headerNameController.text = existing.headerName ?? '';
    _headerValueController.text = existing.headerValue ?? '';
    _userAgentController.text = existing.userAgent ?? '';
  }

  @override
  void dispose() {
    _hostController.dispose();
    _headerNameController.dispose();
    _headerValueController.dispose();
    _userAgentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await ref.read(serverConfigProvider.notifier).clear();
      final config = ServerConfig(
        host: _hostController.text.trim(),
        headerName: _headerNameController.text.trim(),
        headerValue: _headerValueController.text.trim(),
        userAgent: _userAgentController.text.trim(),
      );
      await ref.read(serverConfigProvider.notifier).save(config);
      widget.onSaved();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _hostController,
            label: AppStrings.hostLabel,
            hint: AppStrings.hostHint,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? AppStrings.hostRequired : null,
          ),
          const SizedBox(height: AppDimensions.md),
          _SecuritySection(
            headerNameController: _headerNameController,
            headerValueController: _headerValueController,
            userAgentController: _userAgentController,
          ),
          const SizedBox(height: AppDimensions.xl),
          PrimaryButton(
            label: AppStrings.connectButton,
            onPressed: _loading ? null : _submit,
            isLoading: _loading,
          ),
          if (_isReconfiguring && widget.onCancel != null) ...[
            const SizedBox(height: AppDimensions.sm),
            TextButton(
              onPressed: widget.onCancel,
              child: Text(
                AppStrings.cancelButton,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({
    required this.headerNameController,
    required this.headerValueController,
    required this.userAgentController,
  });

  final TextEditingController headerNameController;
  final TextEditingController headerValueController;
  final TextEditingController userAgentController;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text(
        AppStrings.securitySectionTitle,
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
      ),
      children: [
        CustomTextField(
          controller: headerNameController,
          label: AppStrings.headerNameLabel,
          hint: AppStrings.headerNameHint,
        ),
        const SizedBox(height: AppDimensions.md),
        CustomTextField(
          controller: headerValueController,
          label: AppStrings.headerValueLabel,
          hint: AppStrings.headerValueHint,
        ),
        const SizedBox(height: AppDimensions.md),
        CustomTextField(
          controller: userAgentController,
          label: AppStrings.userAgentLabel,
          hint: AppStrings.userAgentHint,
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          AppStrings.securityDefaultsHint,
          style: AppTextStyles.labelSmall,
        ),
      ],
    );
  }
}
