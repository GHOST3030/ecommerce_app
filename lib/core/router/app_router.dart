import 'dart:async';

import 'package:ecommerce_app/core/supabase/supabase_service.dart';
import 'package:ecommerce_app/features/auth/logic/providers/auth_provider.dart';
import 'package:ecommerce_app/features/auth/logic/states/auth_state.dart';
import 'package:ecommerce_app/features/auth/ui/screens/login_screen.dart';
import 'package:ecommerce_app/features/auth/ui/screens/register_screen.dart';
import 'package:ecommerce_app/features/auth/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable:
        GoRouterRefreshStream(SupabaseService.auth.onAuthStateChange),
    //   initialLocation: '/splash',
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
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).signOut();
                  },
                  child: const Text("Logout"))),
        ),
      ),
    ],

    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      final isAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (authState is AuthLoading) {
        return null; // Stay on the current page while loading
      } else if (authState is Authenticated) {
        print('User is authenticated, redirecting to home');
        if (isAuth || isSplash) {
          return '/'; // Redirect authenticated users to home
        }
      } else if (authState is Unauthenticated) {
        print('User is unauthenticated, redirecting to login');
        if (!isAuth && !isSplash) {
          return '/login'; // Redirect unauthenticated users to login
        }
      }
      // No redirection
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
