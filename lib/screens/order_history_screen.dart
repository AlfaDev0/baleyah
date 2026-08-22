import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../providers/user_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  final bool embedded;

  const OrderHistoryScreen({super.key, this.embedded = false});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final user = context.read<UserProvider>().user;
    if (user != null) {
      context.read<OrderProvider>().loadOrders(user.uid);
      _loaded = true;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.secondary;
      case OrderStatus.pending:
        return AppColors.warning;
      default:
        return AppColors.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    final active = orders.where((o) => o.isActive).toList();
    final history = orders.where((o) => !o.isActive).toList();

    final body = RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        final uid = context.read<UserProvider>().user?.uid;
        if (uid != null) {
          await context.read<OrderProvider>().loadOrders(uid);
        }
      },
      child: orders.isEmpty
          ? ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * .22),
                const Column(
                  children: [
                    Text('📭', style: TextStyle(fontSize: 76)),
                    SizedBox(height: 14),
                    Text(
                      'لسه مفيش طلبات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'أول أوردر هيكون أحلى حاجة في يومك 🍛',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  ],
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                if (active.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      widget.embedded ? 8 : 0,
                      16,
                      8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_rounded,
                          size: 19,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'طلبات شغالة دلوقتي',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ...active.map((o) => _tile(o)),
                if (history.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 19,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'السجل',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ...history.map((o) => _tile(o)),
              ],
            ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('طلبك عندنا')),
      body: body,
    );
  }

  Widget _tile(OrderModel o) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(
          context,
        ).pushNamed(AppRoutes.orderTracking, arguments: o.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#${o.id}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(o.status).withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          OrderStatus.icon(o.status),
                          size: 13.5,
                          color: _statusColor(o.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          OrderStatus.label(o.status),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: _statusColor(o.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${o.items.length} أصناف - ${_dateText(o.createdAt)}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                o.items.map((e) => e.productName).join('، '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '${o.total.toStringAsFixed(0)} ${AppInfo.currency}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  if (o.rating > 0)
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: i < o.rating.round()
                              ? AppColors.primary
                              : AppColors.grey.withValues(alpha: .4),
                        ),
                      ),
                    )
                  else
                    const Text(
                      'تابع الطلب ←',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textLight,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateText(DateTime d) =>
      '${d.day}/${d.month} - ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
