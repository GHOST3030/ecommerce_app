import 'package:ecommerce_app/core/extensions/context_extension.dart';
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

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).clearError();

    final success = await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!success && mounted) {
      final error = ref.read(authErrorProvider);
      if (error != null) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(error),
        //     backgroundColor: AppColors.error,
        //     behavior: SnackBarBehavior.floating,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(AppRadius.sm),
        //     ),
        //   ),
        // );
        print('Login failed: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authIsLoadingProvider);
    final error = ref.watch(authErrorProvider);

    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),
            AuthHeader(
              title: context.l10n.loginTitle,
              subtitle: context.l10n.loginSubtitle,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (error != null) ...[
              ErrorBanner(message: error),
              const SizedBox(height: AppSpacing.md),
            ],
            AuthTextField(
              controller: _emailController,
              label: context.l10n.email,
              hint: context.l10n.emailHint,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              validator: Validators.email,
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
              controller: _passwordController,
              label: context.l10n.password,
              hint: context.l10n.passwordHint,
              obscure: true,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              validator: Validators.password,
              enabled: !isLoading,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextLinkButton(
                label: context.l10n.forgotPassword,
                onPressed: () => context.push(AppRoutes.forgotPassword),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: context.l10n.login,
              onPressed: _submit,
              isLoading: isLoading,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.dontHaveAccount,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                TextLinkButton(
                  label: context.l10n.register,
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).clearError();
                    context.push(AppRoutes.register);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
