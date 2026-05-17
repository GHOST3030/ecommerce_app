import 'dart:async';

import 'package:ecommerce_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce_app/features/auth/logic/entities/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends AsyncNotifier<UserEntity?> {
  @override
  FutureOr<UserEntity?> build() async {
    final repository = ref.watch(authRepositoryProvider);

    final subscription = repository.authStateChanges().listen(
      (user) {
        state = AsyncData(user);
      },
      onError: (Object error, StackTrace stack) {
        state = AsyncError(error, stack);
      },
    );

    ref.onDispose(subscription.cancel);

    return repository.getCurrentUser();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signIn(email: email, password: password);
      return repository.getCurrentUser();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      return repository.getCurrentUser();
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
      return null;
    });
  }
}