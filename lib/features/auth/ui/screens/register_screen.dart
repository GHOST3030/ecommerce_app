import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/features/auth/logic/providers/auth_provider.dart';
import 'package:ecommerce_app/features/auth/ui/widgets/auth_button.dart';
import 'package:ecommerce_app/features/auth/ui/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.registerTitle,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.registerSubtitle,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.theme.hintColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AuthTextField(
                  label: context.l10n.fullName,
                  hintText: context.l10n.fullNameHint,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.length < 2) {
                      return context.l10n.invalidName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  label: context.l10n.email,
                  hintText: context.l10n.emailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return context.l10n.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  label: context.l10n.password,
                  hintText: context.l10n.passwordHint,
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return context.l10n.invalidPassword;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                AuthButton(
                  label: context.l10n.register,
                  onPressed: _register,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(context.l10n.alreadyHaveAccount),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(context.l10n.login),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
