import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/ui_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/cart_badge.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final user = context.watch<UserProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<MenuProvider>().load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 24,
          ),
          children: [
            _header(cart, user),
            const SizedBox(height: 14),
            _searchBar(context),
            const SizedBox(height: 18),
            _offerBanner(),
            const SizedBox(height: 20),
            if (menu.isLoading)
              const SizedBox.shrink()
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'التصنيفات',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 108,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: menu.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _categoryItem(menu.categories[i]),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'الأكثر طلباً',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: menu.products.length,
                  itemBuilder: (_, i) {
                    final p = menu.products[i];
                    if (!p.isPopular) return const SizedBox.shrink();
                    return _compactCard(p);
                  },
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.percent_rounded,
                      color: AppColors.success,
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'عروض اليوم',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              ...menu.products
                  .where((p) => p.hasOffer)
                  .map(
                    (p) => ProductCard(
                      product: p,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.productDetail, arguments: p),
                      onAdd: () => _quickAdd(p),
                    ),
                  ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(CartProvider cart, UserProvider user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: const Center(
              child: Text('🍛', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً ${user.displayName} 👋',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'نفسك تاكل ايه النهاردة؟',
                  style: TextStyle(color: AppColors.textLight, fontSize: 13),
                ),
              ],
            ),
          ),
          CartBadge(
            count: cart.itemCount,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.cart),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.menu),
      child: AbsorbPointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            enabled: false,
            decoration: InputDecoration(
              hintText: 'دوّر على كشري، سجق، مكرونة...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryLight),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _offerBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Clipboard.setData(const ClipboardData(text: AppInfo.couponCode));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text(
                'اتنسخ الكود ${AppInfo.couponCode} 🎉 استخدمه في الدفع',
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondary, Color(0xFFE85D3A)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: .35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            children: [
              Text('🥘', style: TextStyle(fontSize: 44)),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خصم 20% على كل الطلبات!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'اكتب كود "بلية20" في صفحة تأكيد الطلب - دوس هنا يتنسخ',
                      style: TextStyle(color: Colors.white, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryItem(Category category) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.read<UiProvider>().openMenuWithCategory(category),
      child: Container(
        width: 92,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.image, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactCard(Product p) {
    return Container(
      width: 140,
      margin: const EdgeInsetsDirectional.only(end: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: .7)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.productDetail, arguments: p),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'popular_${p.id}',
                child: Text(p.image, style: const TextStyle(fontSize: 42)),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${p.price.toInt()} ${AppInfo.currency}',
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _quickAdd(Product p) async {
    final cart = context.read<CartProvider>();
    await cart.add(product: p, size: p.sizes.first, extras: [], quantity: 1);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('تم إضافة ${p.name} للسلة 🛒'),
        action: SnackBarAction(
          label: 'عرض السلة',
          textColor: AppColors.primaryLight,
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
        ),
      ),
    );
  }
}
