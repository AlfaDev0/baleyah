import 'package:flutter/material.dart';

import '../core/constants.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void show(String title, String body, {Color? color}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: color ?? AppColors.textDark,
        content: Row(
          children: [
            Icon(
              Icons.notifications_active_rounded,
              color: color ?? AppColors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$title\n$body',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
