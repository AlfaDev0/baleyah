import 'package:flutter/material.dart' show IconData, Icons;

import 'user_model.dart';
import 'cart_model.dart' show CartItem;

class OrderStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String preparing = 'preparing';
  static const String outForDelivery = 'out_for_delivery';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';

  static const List<String> flow = [
    pending,
    confirmed,
    preparing,
    outForDelivery,
    delivered,
  ];

  static String label(String status) {
    switch (status) {
      case pending:
        return 'قيد الانتظار';
      case confirmed:
        return 'تم التأكيد';
      case preparing:
        return 'جاري التحضير';
      case outForDelivery:
        return 'في الطريق إليك';
      case delivered:
        return 'تم التوصيل';
      case cancelled:
        return 'ملغي';
    }
    return status;
  }

  static IconData icon(String status) {
    switch (status) {
      case pending:
        return Icons.hourglass_empty_rounded;
      case confirmed:
        return Icons.check_circle_rounded;
      case preparing:
        return Icons.restaurant_rounded;
      case outForDelivery:
        return Icons.delivery_dining_rounded;
      case delivered:
        return Icons.celebration_rounded;
      case cancelled:
        return Icons.cancel_rounded;
    }
    return Icons.help_outline_rounded;
  }

  static int stageIndex(String status) => flow.indexOf(status);
}

class OrderItem {
  final String productId;
  final String productName;
  final String size;
  final List<String> extras;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.size,
    required this.extras,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'size': size,
    'extras': extras,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalPrice': totalPrice,
  };

  factory OrderItem.fromCartItem(CartItem c) => OrderItem(
    productId: c.productId,
    productName: c.productName,
    size: c.size,
    extras: c.extras,
    quantity: c.quantity,
    unitPrice: c.unitPrice,
    totalPrice: c.totalPrice,
  );

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    size: json['size'] as String,
    extras: ((json['extras'] as List?) ?? []).map((e) => e as String).toList(),
    quantity: (json['quantity'] as num).toInt(),
    unitPrice: (json['unitPrice'] as num).toDouble(),
    totalPrice: (json['totalPrice'] as num).toDouble(),
  );
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String status;
  final String paymentMethod;
  final Address deliveryAddress;
  final String notes;
  final int estimatedTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deliveredAt;
  final double rating;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.notes,
    required this.estimatedTime,
    required this.createdAt,
    required this.updatedAt,
    this.deliveredAt,
    required this.rating,
  });

  bool get isActive =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  OrderModel copyWith({
    String? status,
    DateTime? updatedAt,
    DateTime? deliveredAt,
    double? rating,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      notes: notes,
      estimatedTime: estimatedTime,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'discount': discount,
    'total': total,
    'status': status,
    'paymentMethod': paymentMethod,
    'deliveryAddress': deliveryAddress.toJson(),
    'notes': notes,
    'estimatedTime': estimatedTime,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'deliveredAt': deliveredAt?.millisecondsSinceEpoch,
    'rating': rating,
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as String,
    userId: json['userId'] as String,
    items: ((json['items'] as List?) ?? [])
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    subtotal: (json['subtotal'] as num).toDouble(),
    deliveryFee: (json['deliveryFee'] as num).toDouble(),
    discount: (json['discount'] as num?)?.toDouble() ?? 0,
    total: (json['total'] as num).toDouble(),
    status: json['status'] as String,
    paymentMethod: json['paymentMethod'] as String? ?? 'cod',
    deliveryAddress: Address.fromJson(
      json['deliveryAddress'] as Map<String, dynamic>,
    ),
    notes: json['notes'] as String? ?? '',
    estimatedTime: (json['estimatedTime'] as num?)?.toInt() ?? 35,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num).toInt(),
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      (json['updatedAt'] as num).toInt(),
    ),
    deliveredAt: json['deliveredAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            (json['deliveredAt'] as num).toInt(),
          ),
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
  );
}
