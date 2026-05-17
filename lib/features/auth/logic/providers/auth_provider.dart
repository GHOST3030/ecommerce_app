import 'package:ecommerce_app/features/auth/logic/entities/user_entity.dart';
import 'package:ecommerce_app/features/auth/logic/notifiers/auth_notifier.dart';
import 'package:ecommerce_app/features/auth/logic/states/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, UserEntity?>(
  AuthNotifier.new,
);

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authNotifierProvider).value;
});

final authStateProvider = Provider<AuthState>((ref) {
  final authAsync = ref.watch(authNotifierProvider);

  if (authAsync.isLoading) {
    return const AuthLoading();
  } else if (authAsync.hasError) {
    return AuthError(authAsync.error.toString());
  } else if (authAsync.hasValue) {
    final user = authAsync.value;
    return user != null ? Authenticated(user) : const Unauthenticated();
  }
  return const AuthInitial();
});