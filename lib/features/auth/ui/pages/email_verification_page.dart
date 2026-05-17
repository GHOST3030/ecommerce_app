import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/provider/auth_providers.dart';
import '../widget/app_theme.dart';
import '../widget/auth_scaffold.dart';
import '../widget/primary_button.dart';

class EmailVerificationPage extends ConsumerWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authIsLoadingProvider);
    final user = ref.watch(currentUserProvider);

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_unread_rounded,
              color: AppColors.accent,
              size: 44,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Verify your email',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We sent a verification link to\n${user?.email ?? 'your email'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: 'I\'ve verified my email',
            onPressed: () {
              ref.read(authNotifierProvider.notifier).initializeSession();
            },
            isLoading: isLoading,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: isLoading
                ? null
                : () => ref.read(authNotifierProvider.notifier).signOut(),
            child: const Text(
              'Use a different account',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
