import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../core/constants.dart';
import '../models/cart_model.dart' show CartItem;
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  Timer? _ticker;

  List<OrderModel> _orders = [];
  bool _isLoading = false;

  static const Map<int, int> _stageSeconds = {1: 15, 2: 40, 3: 70, 4: 120};

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  List<OrderModel> get activeOrders =>
      _orders.where((o) => o.isActive).toList();

  OrderModel? orderById(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  int etaMinutesFor(OrderModel order) {
    const byStage = [AppInfo.estimatedMinutes, 30, 22, 12, 0];
    final index = OrderStatus.stageIndex(order.status);
    if (index < 0 || index > 4) return AppInfo.estimatedMinutes;
    return byStage[index];
  }

  Future<void> loadOrders(String userId) async {
    _isLoading = true;
    notifyListeners();
    _orders = await _service.fetchOrders(userId);
    _isLoading = false;
    notifyListeners();
    _ensureTicker();
  }

  Future<OrderModel?> placeOrder({
    required String userId,
    required Address address,
    required List<CartItem> items,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required double total,
    required String notes,
  }) async {
    if (items.isEmpty) return null;
    final now = DateTime.now();
    final order = OrderModel(
      id: 'BL-${now.millisecondsSinceEpoch.toString().substring(7)}',
      userId: userId,
      items: items.map(OrderItem.fromCartItem).toList(),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      status: OrderStatus.pending,
      paymentMethod: 'cod',
      deliveryAddress: address,
      notes: notes.trim(),
      estimatedTime: AppInfo.estimatedMinutes,
      createdAt: now,
      updatedAt: now,
      rating: 0,
    );
    await _service.saveOrder(order);
    _orders = [order, ..._orders];
    notifyListeners();
    _ensureTicker();
    NotificationService.instance.show(
      'تم استلام طلبك ${order.id}',
      'هتأكدلك في دقيقة يا صاحب النعم 🍛',
    );
    return order;
  }

  Future<void> cancelOrder(String orderId) async {
    final order = orderById(orderId);
    if (order == null || !order.canCancel) return;
    await _service.updateOrderStatus(orderId, OrderStatus.cancelled);
    _replace(
      order.copyWith(status: OrderStatus.cancelled, updatedAt: DateTime.now()),
    );
    NotificationService.instance.show(
      'تم إلغاء الطلب ${order.id}',
      'مفيش أي مبالغ اتخصمت، الدفع كان عند الاستلام',
      color: const Color(0xFFFF9800),
    );
  }

  Future<void> rateOrder(String orderId, double rating) async {
    await _service.rateOrder(orderId, rating);
    final order = orderById(orderId);
    if (order != null) _replace(order.copyWith(rating: rating));
  }

  void _replace(OrderModel updated) {
    final index = _orders.indexWhere((o) => o.id == updated.id);
    if (index >= 0) {
      _orders[index] = updated;
    } else {
      _orders.insert(0, updated);
    }
    notifyListeners();
  }

  void _ensureTicker() {
    if (_ticker != null && _ticker!.isActive) return;
    _ticker = Timer.periodic(const Duration(seconds: 3), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    for (final order in _orders) {
      if (!order.isActive) continue;
      final elapsed = now.difference(order.createdAt).inSeconds;
      var targetStage = 0;
      _stageSeconds.forEach((stage, seconds) {
        if (elapsed >= seconds) targetStage = stage;
      });
      if (targetStage <= OrderStatus.stageIndex(order.status)) continue;
      final newStatus = OrderStatus.flow[targetStage];
      _applyStatus(order.id, newStatus);
    }
  }

  Future<void> _applyStatus(String orderId, String status) async {
    await _service.updateOrderStatus(
      orderId,
      status,
      deliveredAt: status == OrderStatus.delivered ? DateTime.now() : null,
    );
    final order = orderById(orderId);
    if (order == null) return;
    final updated = order.copyWith(
      status: status,
      updatedAt: DateTime.now(),
      deliveredAt: status == OrderStatus.delivered
          ? DateTime.now()
          : order.deliveredAt,
    );
    _replace(updated);
    NotificationService.instance.show(
      'تحديث الطلب ${updated.id}',
      '${OrderStatus.label(status)} 🛵',
      color: const Color(0xFF4CAF50),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
