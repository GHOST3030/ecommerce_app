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
  print('AuthState is loading, returning AuthLoading');
    return const AuthLoading();
  } else if (authAsync.hasError) {
    print('AuthState has error: ${authAsync.error}');
    return AuthError(authAsync.error.toString());
  } else if (authAsync.hasValue) {
    print('AuthState has value: ${authAsync.value}');
    final user = authAsync.value;
    if (user != null) {
      print('User is authenticated: ${user.email}');
      return Authenticated(user);
    } else {
      print('User is unauthenticated');
      return const Unauthenticated();
    }
  } else {
    return const AuthInitial();
  }
});
