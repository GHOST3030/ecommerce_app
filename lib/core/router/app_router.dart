import 'dart:async';

import 'package:ecommerce_app/features/auth/logic/providers/auth_provider.dart';
import 'package:ecommerce_app/features/auth/logic/states/auth_state.dart';
import 'package:ecommerce_app/features/auth/ui/screens/login_screen.dart';
import 'package:ecommerce_app/features/auth/ui/screens/register_screen.dart';
import 'package:ecommerce_app/features/auth/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthStateNotifier(ref);

  return GoRouter(
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, __) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
              child: const Text('Logout'),
            ),
          ),
        ),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      final isSplash = state.matchedLocation == '/splash';
      final isAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (authState is AuthLoading || authState is AuthInitial) {
        return isSplash ? null : '/splash';
      }

      if (authState is Authenticated) {
        return (isAuth || isSplash) ? '/' : null;
      }

      if (authState is Unauthenticated || authState is AuthError) {
        return isAuth ? null : '/login';
      }

      return null;
    },
  );
});

class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}