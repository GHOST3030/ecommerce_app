import 'package:ecommerce_app/core/router/app_routes.dart';
import 'package:ecommerce_app/features/auth/logic/provider/auth_providers.dart';
import 'package:ecommerce_app/features/auth/ui/widget/app_theme.dart';
import 'package:ecommerce_app/features/auth/ui/widget/auth_scaffold.dart';
import 'package:ecommerce_app/features/auth/ui/widget/auth_text_field.dart';
import 'package:ecommerce_app/features/auth/ui/widget/auth_widgets.dart';
import 'package:ecommerce_app/features/auth/ui/widget/primary_button.dart';
import 'package:ecommerce_app/features/auth/ui/widget/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _resetSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).clearError();

    final success = await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(newPassword: _passwordController.text);

    if (success && mounted) {
      setState(() => _resetSuccess = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.go(AppRoutes.login);
    } else if (mounted) {
      final error = ref.read(authErrorProvider);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authIsLoadingProvider);

    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),
            const AuthHeader(
              title: 'New password',
              subtitle: 'Choose a strong password for your account.',
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_resetSuccess) ...[
              const SuccessBanner(
                message: 'Password updated. Redirecting to sign in...',
              ),
            ] else ...[
              AuthTextField(
                controller: _passwordController,
                label: 'New Password',
                obscure: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                validator: Validators.password,
                enabled: !isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
              AuthTextField(
                controller: _confirmController,
                label: 'Confirm New Password',
                obscure: true,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                validator: (v) =>
                    Validators.confirmPassword(v, _passwordController.text),
                enabled: !isLoading,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Update Password',
                onPressed: _submit,
                isLoading: isLoading,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
