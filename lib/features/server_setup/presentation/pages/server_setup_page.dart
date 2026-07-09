import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../routes/app_router.dart';
import '../widgets/server_form.dart';
import '../widgets/setup_header.dart';

class ServerSetupPage extends StatelessWidget {
  const ServerSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppDimensions.formMaxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SetupHeader(),
                const SizedBox(height: AppDimensions.xl),
                ServerForm(
                  onSaved: () => context.go(AppRoutes.pos),
                  onCancel: () => context.go(AppRoutes.pos),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
