import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFD4A017);
  static const Color primaryDark = Color(0xFFA87C0F);
  static const Color primaryLight = Color(0xFFF3D57E);
  static const Color secondary = Color(0xFFC41E3A);
  static const Color background = Color(0xFFFFF8E7);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF2C1810);
  static const Color textLight = Color(0xFF8A7563);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color shimmerBase = Color(0xFFF0E4C8);
  static const Color shimmerHighlight = Color(0xFFFFFDF5);
}

class AppInfo {
  static const String appName = 'بلية';
  static const String appNameEn = 'Baleyah';
  static const String slogan = 'كشري على أصوله';
  static const String currency = 'ج.م';
  static const double deliveryFee = 15.0;
  static const double freeDeliveryOver = 200.0;
  static const int estimatedMinutes = 35;
  static const String demoOtp = '123456';
  static const String hotline = '19999';
  static const String couponCode = 'بلية20';
  static const double couponPercent = 0.20;
}

class PrefsKeys {
  static const String user = 'baleyah_user_v1';
  static const String orders = 'baleyah_orders_v1';
  static const String cart = 'baleyah_cart_v1';
  static const String onboarded = 'baleyah_onboarded_v1';
}
