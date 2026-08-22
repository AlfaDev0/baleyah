import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/user_model.dart';
import '../screens/add_address_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_shell.dart';
import '../screens/menu_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/order_tracking_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String shell = '/shell';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String menu = '/menu';
  static const String productDetail = '/product-detail';
  static const String orderTracking = '/order-tracking';
  static const String addAddress = '/add-address';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case initial:
        return _page(const SplashScreen(), settings);
      case onboarding:
        return _page(const OnboardingScreen(), settings);
      case login:
        return _page(const LoginScreen(), settings);
      case shell:
        return _page(const MainShell(), settings);
      case cart:
        return _page(const CartScreen(), settings);
      case checkout:
        return _page(const CheckoutScreen(), settings);
      case menu:
        return _page(const MenuScreen(), settings);
      case productDetail:
        return _page(ProductDetailScreen(product: args! as Product), settings);
      case orderTracking:
        return _page(OrderTrackingScreen(orderId: args! as String), settings);
      case addAddress:
        return _page(
          AddAddressScreen(existing: args is Address ? args : null),
          settings,
        );
    }
    return _page(const RouteError(), settings);
  }

  static PageRouteBuilder _page(Widget screen, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: screen,
      ),
    );
  }
}

class RouteError extends StatelessWidget {
  final RouteSettings? settings;
  const RouteError({super.key, this.settings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صفحة مش موجودة')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😵', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 10),
            Text('المسار ${settings?.name ?? ''} مش معروف عندنا'),
          ],
        ),
      ),
    );
  }
}
