import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/provider/auth_providers.dart';
import '../widget/app_theme.dart';
import '../widget/auth_scaffold.dart';
import '../widget/auth_text_field.dart';
import '../widget/auth_widgets.dart';
import '../widget/primary_button.dart';
import '../widget/validators.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).clearError();

    final success = await ref
        .read(authNotifierProvider.notifier)
        .forgotPassword(email: _emailController.text.trim());

    if (success && mounted) {
      setState(() => _emailSent = true);
    } else if (mounted) {
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
        print('Forgot password failed: $error');
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
              title: 'Reset password',
              subtitle:
                  'Enter your email and we\'ll send you a reset link.',
              showBackButton: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_emailSent) ...[
              SuccessBanner(
                message:
                    'Reset link sent to ${_emailController.text.trim()}. Check your inbox.',
              ),
              const SizedBox(height: AppSpacing.xl),
            ] else ...[
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.email_outlined),
                validator: Validators.email,
                enabled: !isLoading,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Send Reset Link',
                onPressed: _submit,
                isLoading: isLoading,
                icon: Icons.send_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
