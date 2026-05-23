abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const emailVerification = '/email-verification';
  static const productList = '/shop';
  static const productDetail = '/product/:id';
  static const search = '/search';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const orderDetail = '/orders/:id';
  static const orderConfirmation = '/order-confirmation';

  static String orderDetailPath(String id) => '/orders/$id';

  static String orderConfirmationPath({String? orderId}) {
    if (orderId == null || orderId.isEmpty) return orderConfirmation;
    return '$orderConfirmation?orderId=$orderId';
  }
}
