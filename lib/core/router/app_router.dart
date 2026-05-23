import 'dart:async';

import 'package:ecommerce_app/core/router/app_routes.dart';
import 'package:ecommerce_app/core/supabase/supabase_service.dart';
import 'package:ecommerce_app/features/auth/logic/provider/auth_providers.dart';
import 'package:ecommerce_app/features/auth/logic/state/auth_state.dart';
import 'package:ecommerce_app/features/auth/ui/pages/email_verification_page.dart';
import 'package:ecommerce_app/features/auth/ui/pages/forgot_password_page.dart';
import 'package:ecommerce_app/features/auth/ui/pages/home_page.dart';
import 'package:ecommerce_app/features/auth/ui/pages/login_page.dart';
import 'package:ecommerce_app/features/auth/ui/pages/register_page.dart';
import 'package:ecommerce_app/features/auth/ui/pages/reset_password_page.dart';
import 'package:ecommerce_app/features/auth/ui/pages/splash_page.dart';
import 'package:ecommerce_app/features/cart/ui/screens/cart_screen.dart';
import 'package:ecommerce_app/features/notifications/ui/screens/notifications_screen.dart';
import 'package:ecommerce_app/features/order/logic/entities/order_entity.dart';
import 'package:ecommerce_app/features/order/ui/screens/checkout_screen.dart';
import 'package:ecommerce_app/features/order/ui/screens/order_confirmation_screen.dart';
import 'package:ecommerce_app/features/order/ui/screens/order_detail_screen.dart';
import 'package:ecommerce_app/features/order/ui/screens/orders_list_screen.dart';
import 'package:ecommerce_app/features/product/ui/pages/product_detail_screen.dart';
import 'package:ecommerce_app/features/product/ui/pages/product_list_screen.dart';
import 'package:ecommerce_app/features/product/ui/pages/search_screen.dart';
import 'package:ecommerce_app/features/wishlist/ui/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,
    refreshListenable:
        GoRouterRefreshStream(SupabaseService.auth.onAuthStateChange),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'reset-password',
        builder: (_, __) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        name: 'email-verification',
        builder: (_, __) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.productList,
        name: 'product-list',
        builder: (_, __) => const ProductListScreen(),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        name: 'product-detail',
        builder: (_, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (_, __) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.wishlist,
        name: 'wishlist',
        builder: (_, __) => const WishlistScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        builder: (_, __) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        builder: (_, __) => const OrdersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        name: 'order-detail',
        builder: (_, state) {
          final order = state.extra;
          return OrderDetailScreen(
            orderId: state.pathParameters['id']!,
            order: order is OrderEntity ? order : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.orderConfirmation,
        name: 'order-confirmation',
        builder: (_, state) => OrderConfirmationScreen(
          orderId: state.uri.queryParameters['orderId'],
        ),
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSplash = location == AppRoutes.splash;
      final isAuthRoute = location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.forgotPassword ||
          location == AppRoutes.resetPassword;
      final isVerificationRoute = location == AppRoutes.emailVerification;

      if (authState.status == AuthStatus.initial || authState.isLoading) {
        return isSplash ? null : AppRoutes.splash;
      }

      if (authState.status == AuthStatus.emailUnverified) {
        return isVerificationRoute ? null : AppRoutes.emailVerification;
      }

      if (authState.status == AuthStatus.authenticated) {
        if (isSplash || isAuthRoute || isVerificationRoute) {
          return AppRoutes.home;
        }
        return null;
      }

      if (authState.status == AuthStatus.unauthenticated) {
        return location == AppRoutes.login
            ? AppRoutes.register
            : AppRoutes.login;
      }

      return null;
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
