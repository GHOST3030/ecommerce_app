import 'dart:async';
import 'package:ecommerce_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce_app/features/auth/logic/entities/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends AsyncNotifier<UserEntity?> {
  @override
  FutureOr<UserEntity?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    
    // Listen to auth state changes from Supabase
    final subscription = repository.authStateChanges().listen(
      (user) {
        state = AsyncData(user);
      },
      onError: (error) {
        state = AsyncError(error, StackTrace.current);
      },
    );

    ref.onDispose(() => subscription.cancel());

    try {
      return await repository.getCurrentUser();
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return null;
    }
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
