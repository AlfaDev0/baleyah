import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../widgets/order_status_stepper.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.select<OrderProvider, OrderModel?>(
      (o) => o.orderById(orderId),
    );
    final orderProv = context.read<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.primaryDark,
            ),
            onPressed: () =>
                _showContactDialog(context, order?.deliveryAddress.phone),
          ),
        ],
      ),
      body: order == null
          ? const Center(child: Text('مفيش طلب بالرقم ده'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'طلب #${order.id}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          Chip(
                            avatar: Icon(
                              OrderStatus.icon(order.status),
                              size: 16,
                              color: order.status == OrderStatus.cancelled
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                            label: Text(
                              OrderStatus.label(order.status),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.payments_rounded,
                            color: Colors.white.withValues(alpha: .9),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'كاش عند الاستلام: ${order.total.toStringAsFixed(0)} ${AppInfo.currency}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .95),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Icon(
                            Icons.timer_outlined,
                            color: Colors.white.withValues(alpha: .9),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${orderProv.etaMinutesFor(order)} دقيقة',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .95),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'العنوان: ${order.deliveryAddress.fullAddress}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: KeyedSubtree(
                        key: ValueKey(order.status + order.id),
                        child: OrderStatusStepper(status: order.status),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        for (final item in order.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Text(
                                  '${item.quantity}×',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _itemLine(item),
                                    style: const TextStyle(fontSize: 13.5),
                                  ),
                                ),
                                Text(
                                  item.totalPrice.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (order.discount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'الخصم',
                                    style: TextStyle(color: AppColors.success),
                                  ),
                                ),
                                Text(
                                  '-${order.discount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Divider(),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'الإجمالي كاش',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            Text(
                              '${order.total} ${AppInfo.currency}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (order.canCancel)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('إلغاء الطلب؟'),
                          content: const Text(
                            'لسه في الوقت الآمن للإلغاء. تأكد إنك عايز تلغيه؟',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('راجعت نفسي، كمّل'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('أيوه، الغيه'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await context.read<OrderProvider>().cancelOrder(
                          order.id,
                        );
                      }
                    },
                    label: const Text('إلغاء الطلب'),
                  ),
                if (order.status == OrderStatus.outForDelivery)
                  ElevatedButton.icon(
                    onPressed: () => _showContactDialog(
                      context,
                      order.deliveryAddress.phone,
                    ),
                    icon: const Icon(Icons.call_rounded),
                    label: const Text('اتصل بالمندوب'),
                  ),
                if (order.status == OrderStatus.delivered && order.rating <= 0)
                  _RatingCard(orderId: order.id),
              ],
            ),
    );
  }

  String _itemLine(OrderItem item) {
    final base = '${item.productName} (${item.size})';
    if (item.extras.isEmpty) return base;
    final joined = item.extras.join('، ');
    return '$base + $joined';
  }

  void _showContactDialog(BuildContext context, String? customerPhone) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('📞 خط ساخن بلية'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المندوب بتاعك: محمود السايح'),
            SizedBox(height: 4),
            Text('رقمه: 0100${AppInfo.hotline}55'),
            SizedBox(height: 4),
            Text('خدمة العملاء: ${AppInfo.hotline}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تمام'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.call_rounded, size: 18),
            label: const Text('اتصل دلوقتي'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري الاتصال... (دي نسخة تجريبية 😄)'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RatingCard extends StatefulWidget {
  final String orderId;
  const _RatingCard({required this.orderId});

  @override
  State<_RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<_RatingCard> {
  double _stars = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'قيم تجربتك معنا 🍛',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final value = i + 1;
                return IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    setState(() => _stars = value.toDouble());
                    await context.read<OrderProvider>().rateOrder(
                      widget.orderId,
                      value.toDouble(),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text('شكراً على تقييمك! ⭐ $value/5'),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.star_rounded,
                    size: 34,
                    color: value <= _stars ? AppColors.primary : AppColors.grey,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
