import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../models/user_model.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/animated_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _notesController = TextEditingController();
  final _couponController = TextEditingController();
  bool _placing = false;

  @override
  void dispose() {
    _notesController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(Address address) async {
    if (_placing) return;
    setState(() => _placing = true);

    final cart = context.read<CartProvider>();
    final user = context.read<UserProvider>();
    final orderProv = context.read<OrderProvider>();
    final totals = cart.totals;

    final order = await orderProv.placeOrder(
      userId: user.user!.uid,
      address: address,
      items: cart.items,
      subtotal: totals.subtotal,
      deliveryFee: totals.deliveryFee,
      discount: totals.discount,
      total: totals.total,
      notes: _notesController.text,
    );
    await cart.clear();

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(orderId: order?.id ?? ''),
    );
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacementNamed(AppRoutes.orderTracking, arguments: order!.id);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = context.watch<UserProvider>();
    final totals = cart.totals;
    final addresses = user.user?.addresses ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد الطلب')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('📍 عنوان التوصيل'),
          const SizedBox(height: 10),
          if (addresses.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_off_rounded,
                      size: 40,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 8),
                    const Text('لسه مفيش عنوان محفوظ'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.addAddress),
                      icon: const Icon(Icons.add_location_alt_rounded),
                      label: const Text('إضافة عنوان جديد'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ...addresses.map((a) {
              final selected = user.selectedAddress?.id == a.id;
              return GestureDetector(
                onTap: () => user.selectAddress(a.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryLight : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.primaryLight,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: AppColors.primaryDark,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${_titleIcon(a.title)} ${a.title}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (a.isDefault)
                                  Container(
                                    margin: const EdgeInsetsDirectional.only(
                                      start: 6,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(
                                        alpha: .15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'الافتراضي',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              a.fullAddress,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.addAddress, arguments: a),
                        child: const Text(
                          'تعديل',
                          style: TextStyle(color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.addAddress),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('عنوان جديد'),
              ),
            ),
          ],
          const SizedBox(height: 14),
          _sectionTitle('🎁 كوبون خصم'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'اكتب الكود... مثال: ${AppInfo.couponCode}',
                    prefixIcon: Icon(
                      Icons.local_offer_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: cart.isCouponApplied
                      ? AppColors.secondary
                      : AppColors.primary,
                  minimumSize: const Size(90, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  final ok = cart.applyCoupon(_couponController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: ok
                          ? AppColors.success
                          : AppColors.secondary,
                      content: Text(
                        ok
                            ? 'مبروك! خصم ${(AppInfo.couponPercent * 100).toInt()}% 🎉'
                            : 'الكود ده مش شغال 😕',
                      ),
                    ),
                  );
                },
                child: Text(cart.isCouponApplied ? 'إلغاء' : 'تفعيل'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _sectionTitle('📝 ملاحظات للمطبخ أو المندوب'),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'مثال: الشطة على الجنب، ادق الجرس مرتين...',
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row(
                    'المجموع الفرعي',
                    '${totals.subtotal} ${AppInfo.currency}',
                  ),
                  if (totals.discount > 0)
                    _row(
                      'الخصم',
                      '-${totals.discount.toStringAsFixed(0)} ${AppInfo.currency}',
                      green: true,
                    ),
                  _row(
                    'التوصيل',
                    totals.deliveryFee <= 0
                        ? 'مجاناً 🎉'
                        : '${totals.deliveryFee} ${AppInfo.currency}',
                  ),
                  const Divider(height: 20),
                  _row(
                    'الإجمالي (كاش عند الاستلام)',
                    '${totals.total} ${AppInfo.currency}',
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Chip(
              avatar: Icon(
                Icons.timer_outlined,
                size: 17,
                color: AppColors.warning,
              ),
              label: Text(
                'التوصيل المتوقع خلال ~${AppInfo.estimatedMinutes} دقيقة',
              ),
              backgroundColor: AppColors.background,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedButton(
            label: _placing
                ? 'جاري تأكيد طلبك...'
                : 'تأكيد الطلب - الدفع عند الاستلام 💵',
            icon: Icons.check_circle_outline_rounded,
            color: _placing ? null : AppColors.success,
            onPressed:
                (_placing || cart.isEmpty || user.selectedAddress == null)
                ? null
                : () => _placeOrder(user.selectedAddress!),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String _titleIcon(String title) {
    switch (title) {
      case 'المنزل':
        return '🏠';
      case 'العمل':
        return '🏢';
      default:
        return '📍';
    }
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
  );

  Widget _row(String l, String v, {bool bold = false, bool green = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              l,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w900 : null,
                fontSize: 13.5,
              ),
            ),
            const Spacer(),
            Text(
              v,
              style: TextStyle(
                fontWeight: bold || green ? FontWeight.bold : null,
                color: green ? AppColors.success : AppColors.textDark,
              ),
            ),
          ],
        ),
      );
}

class _SuccessDialog extends StatefulWidget {
  final String orderId;
  const _SuccessDialog({required this.orderId});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> {
  int stage = 0;
  Timer? timer;

  static const List<String> layers = ['🍚', '🍝', '🫘', '🧅', '🍛'];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 420), (t) {
      if (!mounted || t.tick >= layers.length) {
        t.cancel();
        return;
      }
      setState(() => stage = t.tick + 1);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < stage; i++)
            AnimatedOpacity(
              key: ValueKey(i),
              opacity: 1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Transform.scale(
                scale: i == layers.length - 1 ? 1.5 : 1,
                child: Text(
                  layers[i],
                  style: TextStyle(fontSize: i == layers.length - 1 ? 64 : 44),
                ),
              ),
            ),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (_, v, child) => Opacity(opacity: v, child: child),
            child: Column(
              children: [
                const Text(
                  'تم استلام طلبك!',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'رقم الطلب ${widget.orderId}\nالدفع كاش عند الاستلام 💵',
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('تابع طلبك'),
          ),
        ],
      ),
    );
  }
}
