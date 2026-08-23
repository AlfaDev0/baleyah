import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/product_images.dart';
import '../core/routes.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/notification_service.dart';
import '../widgets/animated_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String selectedSize = widget.product.sizes.first.name;
  final Set<String> selectedExtras = {};
  int quantity = 1;

  double get unitPrice {
    double price = 0;
    for (final s in widget.product.sizes) {
      if (s.name == selectedSize) price = s.price;
    }
    for (final e in widget.product.extras) {
      if (selectedExtras.contains(e.name)) price += e.price;
    }
    return price;
  }

  double get total => unitPrice * quantity;

  Future<void> _addToCart(Offset flyFrom) async {
    final size = widget.product.sizes.firstWhere((s) => s.name == selectedSize);
    final extras = widget.product.extras
        .where((e) => selectedExtras.contains(e.name))
        .toList();
    await context.read<CartProvider>().add(
          product: widget.product,
          size: size,
          extras: extras,
          quantity: quantity,
        );
    if (!mounted) return;
    _flyToCart(flyFrom);
    NotificationService.instance.show(
      'تمت الإضافة للسلة 🛒',
      '${widget.product.name} × $quantity',
      color: AppColors.success,
    );
  }

  void _flyToCart(Offset from) {
    final overlay = Overlay.of(context);
    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 750),
    );
    final startTween = Tween<Offset>(begin: from, end: const Offset(50, 90));
    final entry = OverlayEntry(
      builder: (_) => AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final pos = startTween.transform(
            Curves.easeInBack.transform(controller.value),
          );
          return Positioned(
            top: pos.dy,
            left: pos.dx,
            child: IgnorePointer(
              child: Opacity(
                opacity: 1 - (controller.value * .4),
                child: Transform.scale(
                  scale: 1.6 - controller.value * .8,
                  child: Text(
                    widget.product.image,
                    style: const TextStyle(fontSize: 42),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    overlay.insert(entry);
    controller.forward().whenComplete(() {
      entry.remove();
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primaryLight,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                tooltip: 'السلة',
                icon: const Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    Positioned(left: -7, top: -7, child: CartCountDot()),
                  ],
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.cart),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Color(0xFFE8B93B)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(p.image, style: const TextStyle(fontSize: 120)),
                  ),
                  if (ProductImages.product(p.id) != null)
                    Hero(
                      tag: 'product_${p.id}',
                      child: Image.asset(
                        ProductImages.product(p.id)!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: .35),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (p.isPopular)
                                  const _MiniBadge(
                                    icon: Icons.local_fire_department_rounded,
                                    text: 'الأكثر مبيعاً',
                                    color: AppColors.secondary,
                                  ),
                                const _MiniBadge(
                                  icon: Icons.schedule_rounded,
                                  text:
                                      'جاهز في ${AppInfo.estimatedMinutes - 10} د',
                                  color: AppColors.success,
                                ),
                                const _MiniBadge(
                                  icon: Icons.bolt_rounded,
                                  text: 'كاش عند الاستلام',
                                  color: AppColors.primaryDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _DetailFavButton(productId: p.id),
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              Text(
                                '${p.rating}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' (${p.reviewsCount})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: p.ingredients
                        .map(
                          (i) => Chip(
                            label: Text(
                              i,
                              style: const TextStyle(fontSize: 12),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.description,
                    style: const TextStyle(
                      height: 1.7,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _ReviewsSection(),
                  const SizedBox(height: 20),
                  const Text(
                    'اختار الحجم',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in p.sizes)
                        ChoiceChip(
                          label: Text('${s.name} (${s.price.toInt()})'),
                          selected: selectedSize == s.name,
                          onSelected: (_) =>
                              setState(() => selectedSize = s.name),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'إضافات على ذوقك',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (p.extras.isEmpty)
                    const Text(
                      'مفيش إضافات للأكلة دي',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final e in p.extras)
                        FilterChip(
                          label: Text(
                            '+${e.name} (${e.price.toInt()} ${AppInfo.currency})',
                          ),
                          selected: selectedExtras.contains(e.name),
                          onSelected: (_) => setState(() {
                            selectedExtras.contains(e.name)
                                ? selectedExtras.remove(e.name)
                                : selectedExtras.add(e.name);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الكمية',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primaryLight),
                        ),
                        child: Row(
                          children: [
                            _qtyBtn(Icons.remove_rounded, () {
                              if (quantity > 1) setState(() => quantity--);
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            _qtyBtn(
                              Icons.add_rounded,
                              () => setState(() => quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 12,
          top: 12,
          left: 16,
          right: 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 14,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Builder(
          builder: (context) {
            return Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الإجمالي',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                    Text(
                      '$total ${AppInfo.currency}',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Builder(
                    builder: (btnContext) => AnimatedButton(
                      label: 'أضف للسلة',
                      icon: Icons.add_shopping_cart_rounded,
                      onPressed: () {
                        final box = btnContext.findRenderObject() as RenderBox;
                        _addToCart(box.localToGlobal(Offset.zero));
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 22, color: AppColors.primaryDark),
      ),
    );
  }
}

class CartCountDot extends StatelessWidget {
  const CartCountDot({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().itemCount;
    if (count == 0) return const SizedBox.shrink();
    return CircleAvatar(
      radius: 9,
      backgroundColor: AppColors.secondary,
      child: Text(
        '$count',
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _MiniBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailFavButton extends StatelessWidget {
  final String productId;
  const _DetailFavButton({required this.productId});

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoritesProvider>().isFav(productId);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.read<FavoritesProvider>().toggle(productId),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryLight),
            color: Colors.white,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFav),
              size: 22,
              color: isFav ? AppColors.secondary : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  static const _reviews = [
    (
      name: 'محمود ع.',
      stars: 5,
      text: 'أحسن كشري اكلته في حياتي بجد، البصل مقرمش والصلصة طعمة جداً'
    ),
    (
      name: 'سارة م.',
      stars: 5,
      text: 'الطلب وصل سخن وبسرعة، الكمية كبيرة وكفاية لاتنين'
    ),
    (
      name: 'أحمد ر.',
      stars: 4,
      text: 'ممتاز بس أتمنى يزودوا الثومية شوية في الوسط'
    ),
  ];

  const _ReviewsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'آراء العملاء',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: .35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded,
                      size: 15, color: AppColors.primaryDark),
                  SizedBox(width: 2),
                  Text('4.8/5',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 11.5)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._reviews.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: .6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: .18),
                        child: Text(r.name[0],
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 8),
                      Text(r.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < r.stars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(r.text,
                      style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: AppColors.textDark)),
                ],
              ),
            )),
      ],
    );
  }
}
