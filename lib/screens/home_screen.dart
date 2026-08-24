import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/product_images.dart';
import '../core/routes.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/order_provider.dart';
import '../providers/ui_provider.dart';
import '../providers/user_provider.dart';
import '../services/share_service.dart';
import '../widgets/cart_badge.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _ticker;
  Duration _toMidnight = const Duration();

  @override
  void initState() {
    super.initState();
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().load();
    });
  }

  void _tick() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    if (mounted) setState(() => _toMidnight = midnight.difference(now));
  }

  String get _countdownText {
    final h = _toMidnight.inHours;
    final m = _toMidnight.inMinutes.remainder(60);
    final s = _toMidnight.inSeconds.remainder(60);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
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
            const _RestaurantStrip(),
            const SizedBox(height: 14),
            _searchBar(context),
            const SizedBox(height: 18),
            _offerBanner(),
            const SizedBox(height: 14),
            _loyaltyCard(),
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
              const SizedBox(height: 18),
              _ownerCard(),
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight, width: 2),
              image: const DecorationImage(
                image: AssetImage(ProductImages.splashLogo),
                fit: BoxFit.cover,
              ),
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
          height: 130,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: .35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(ProductImages.banner, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: .75),
                      Colors.black.withValues(alpha: .25),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_rounded,
                          size: 13, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          'العرض بيقف بعد $_countdownText',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryItem(Category category) {
    final img = ProductImages.category(category.id);
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
            ClipOval(
              child: SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Text(
                        category.image,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    if (img != null) Image.asset(img, fit: BoxFit.cover),
                  ],
                ),
              ),
            ),
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


  Widget _loyaltyCard() {
    final orders = context.watch<OrderProvider>().orders;
    final delivered =
        orders.where((o) => o.status == OrderStatus.delivered).length;
    final stamps = delivered % 5;
    final remaining = 5 - stamps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4A017), Color(0xFFB8860B)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.card_giftcard_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'كارت الولاء',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(5, (i) {
                        final filled = i < stamps;
                        return Container(
                          width: 15,
                          height: 15,
                          margin: const EdgeInsets.only(left: 3),
                          decoration: BoxDecoration(
                            color: filled
                                ? Colors.white
                                : Colors.white.withValues(alpha: .25),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 1.2),
                          ),
                          child: filled
                              ? const Icon(Icons.check_rounded,
                                  size: 11, color: AppColors.primary)
                              : null,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    delivered == 0
                        ? 'اطلب أول طلب وابدأ جمع الخواتم — كل 5 طلبات هدية 🎁'
                        : remaining == 5 && delivered > 0
                            ? 'مبروك! خلصت كارت — الكشري الجاي علينا 🎉'
                            : 'بعد $remaining ${remaining == 1 ? 'طلب' : 'طلبات'} ويجيلك كشري مجاني 🎁',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final opened = await ShareService.shareApp();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor:
                        opened ? AppColors.success : AppColors.primaryDark,
                    content: Text(
                      opened
                          ? 'اتفتح واتساب — ابعت الرسالة لصحابك 🚀'
                          : 'الرسالة اتنسخت — الصقها في واتساب 📋',
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.share_rounded,
                        size: 16, color: AppColors.primaryDark),
                    SizedBox(width: 6),
                    Text(
                      'شارك',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ownerCard() {    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 86,
              height: 112,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 2),
                image: const DecorationImage(
                  image: AssetImage('assets/images/owner.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'أحمد ايمن فكرى',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.verified_rounded,
                        size: 17,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'مطعم بلية - كشري على أصوله',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textLight),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'أهلاً بيك في بلية! كل طبق بيتعمل بإيدينا يومياً بمكونات طازة. لو عاجباك الأكل قول لصحابك، ولو عندك أي ملاحظة أنا موجود دايماً 🤍',
                    style: TextStyle(
                      height: 1.55,
                      fontSize: 12.5,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactCard(Product p) {
    final img = ProductImages.product(p.id);
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
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(17),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(child: Text(p.image, style: const TextStyle(fontSize: 42))),
                      if (img != null) Image.asset(img, fit: BoxFit.cover),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
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

class _RestaurantStrip extends StatelessWidget {
  const _RestaurantStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: .8)),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: .06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              ProductImages.splashLogo,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'مطعم بلية - شارع الترعة، فيصل',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    _LiveDot(),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: AppColors.primary),
                    SizedBox(width: 2),
                    Text('4.8',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 12.5)),
                    Text('  (1200+ تقييم)',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          const _InfoPill(icon: Icons.access_time_rounded, label: '${AppInfo.estimatedMinutes} د'),
          const SizedBox(width: 6),
          _InfoPill(
              icon: Icons.delivery_dining_rounded,
              label: '${AppInfo.deliveryFee.toInt()} ${AppInfo.currency}'),
        ],
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: .35, end: 1.0).animate(_c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'مفتوح الآن',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryDark),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
