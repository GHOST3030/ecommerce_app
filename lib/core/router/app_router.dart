import 'package:ecommerce_app/core/router/app_routes.dart';
import 'package:ecommerce_app/features/auth/logic/provider/auth_providers.dart';
import 'package:ecommerce_app/features/auth/logic/state/auth_state.dart';
import 'package:ecommerce_app/features/auth/ui/pages/email_verification_page.dart';
import 'package:ecommerce_app/features/auth/ui/pages/forgot_password_page.dart';
import 'package:ecommerce_app/features/auth/ui/pages/home_page.dart';
import 'package:ecommerce_app/features/auth/ui/pages/login_page.dart';
import 'package:ecommerce_app/features/auth/ui/pages/register_page.dart';
import 'package:ecommerce_app/features/auth/ui/pages/reset_password_page.dart';
import 'package:ecommerce_app/features/auth/ui/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthStateListenable(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final location = state.matchedLocation;

      final isInitial = authState.status == AuthStatus.initial;
      final isAuthenticated = authState.isAuthenticated;
      final isEmailUnverified = authState.requiresEmailVerification;
      final isPasswordRecovery = authState.isPasswordRecovery;

      final guestRoutes = [
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      ];

      if (location == AppRoutes.splash) {
        if (isInitial) return null;
        if (isPasswordRecovery) return AppRoutes.resetPassword;
        if (isAuthenticated) return AppRoutes.home;
        if (isEmailUnverified) return AppRoutes.emailVerification;
        return AppRoutes.login;
      }

      if (isInitial) return AppRoutes.splash;

      if (isPasswordRecovery && location != AppRoutes.resetPassword) {
        return AppRoutes.resetPassword;
      }

      if (isAuthenticated &&
          (guestRoutes.contains(location) ||
              location == AppRoutes.resetPassword)) {
        return AppRoutes.home;
      }

      if (isEmailUnverified && location != AppRoutes.emailVerification) {
        return AppRoutes.emailVerification;
      }

      if (!isAuthenticated &&
          !isEmailUnverified &&
          !isPasswordRecovery &&
          !guestRoutes.contains(location) &&
          location != AppRoutes.splash) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, __) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        builder: (_, __) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomePage(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.error}')),
    ),
  );
});

class _AuthStateListenable extends ChangeNotifier {
  final Ref _ref;
  AuthStatus? _lastStatus;

  _AuthStateListenable(this._ref) {
    _ref.listen(authStatusProvider, (_, next) {
      if (_lastStatus != next) {
        _lastStatus = next;
        notifyListeners();
      }
    });
  }
}
