import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../models/cart_model.dart';
import '../providers/cart_provider.dart';
import '../providers/ui_provider.dart';
import '../widgets/animated_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final totals = cart.totals;

    return Scaffold(
      appBar: AppBar(
        title: Text(cart.isEmpty ? 'السلة' : 'السلة (${cart.itemCount})'),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: AppColors.secondary,
              ),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('تفضية السلة؟'),
                    content: const Text(
                      'هتشيل كل الأكل من السلة، متندم بعدين 😅',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('لأ سيبها'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('امسح الكل'),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await context.read<CartProvider>().clear();
                }
              },
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 14),
                  const Text(
                    'السلة فاضية يا معلم!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'كشري بلية مستنيك',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: AnimatedButton(
                      label: 'اتفرج على المنيو',
                      onPressed: () {
                        context.read<UiProvider>().setBottomNavIndex(1);
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 190),
              itemCount: cart.items.length,
              itemBuilder: (_, i) => _CartTile(item: cart.items[i]),
            ),
      bottomSheet: cart.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 14,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _row('المجموع الفرعي', totals.subtotal),
                  if (totals.discount > 0)
                    _row(
                      'خصم كوبون ${AppInfo.couponCode}',
                      -totals.discount,
                      green: true,
                    ),
                  _row(
                    'التوصيل',
                    totals.deliveryFee,
                    freeLabel: totals.deliveryFee <= 0,
                  ),
                  const Divider(height: 18),
                  Row(
                    children: [
                      const Text(
                        'الإجمالي',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${totals.total} ${AppInfo.currency}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedButton(
                    label: 'إتمام الطلب - كاش عند الاستلام',
                    icon: Icons.payments_rounded,
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.checkout),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _row(
    String label,
    double value, {
    bool green = false,
    bool freeLabel = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textLight)),
          const Spacer(),
          Text(
            freeLabel
                ? 'مجاناً 🎉'
                : '${value > 0 ? '' : '-'}${value.abs()} ${AppInfo.currency}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: green ? AppColors.success : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(item.image, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'الحجم: ${item.size}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                  if (item.extras.isNotEmpty)
                    Text(
                      item.extrasText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textLight,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.totalPrice.toStringAsFixed(0)} ${AppInfo.currency}',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    _roundBtn(
                      Icons.remove_rounded,
                      () => context.read<CartProvider>().decreaseQuantity(
                        item.id,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    _roundBtn(
                      Icons.add_rounded,
                      () => context.read<CartProvider>().increaseQuantity(
                        item.id,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  onPressed: () =>
                      context.read<CartProvider>().removeItem(item.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Icon(icon, size: 17, color: AppColors.primaryDark),
      ),
    );
  }
}
