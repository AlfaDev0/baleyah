import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/ui_provider.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final ui = context.watch<UiProvider>();

    return Scaffold(
      body: IndexedStack(
        index: ui.bottomNavIndex,
        children: const [
          HomeScreen(),
          MenuScreen(),
          OrderHistoryScreen(embedded: true),
          ProfileScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: ui.bottomNavIndex,
        onDestinationSelected: (i) =>
            context.read<UiProvider>().setBottomNavIndex(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: AppColors.primaryDark,
            ),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.primaryDark,
            ),
            label: 'القائمة',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primaryDark,
            ),
            label: 'طلباتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: AppColors.primaryDark,
            ),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}
