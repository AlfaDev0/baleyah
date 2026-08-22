import '../core/constants.dart';

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String image;
  final String size;
  final List<String> extras;
  final int quantity;
  final double unitPrice;

  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.image,
    required this.size,
    required this.extras,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;

  String get extrasText {
    if (extras.isEmpty) return '';
    final joined = extras.join('، ');
    return 'إضافات: $joined';
  }

  static String buildId({
    required String productId,
    required String size,
    required List<String> extras,
  }) {
    final sorted = [...extras]..sort();
    return '$productId|$size|${sorted.join(',')}';
  }

  CartItem copyWith({int? quantity}) => CartItem(
    id: id,
    productId: productId,
    productName: productName,
    image: image,
    size: size,
    extras: extras,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'image': image,
    'size': size,
    'extras': extras,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] as String,
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    image: json['image'] as String? ?? '🍛',
    size: json['size'] as String,
    extras: ((json['extras'] as List?) ?? []).map((e) => e as String).toList(),
    quantity: (json['quantity'] as num).toInt(),
    unitPrice: (json['unitPrice'] as num).toDouble(),
  );
}

class CartTotals {
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;

  const CartTotals({
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
  });

  factory CartTotals.calculate(double subtotal, double discount) {
    final fee = subtotal <= 0 || subtotal >= AppInfo.freeDeliveryOver
        ? 0.0
        : AppInfo.deliveryFee;
    return CartTotals(
      subtotal: subtotal,
      discount: discount,
      deliveryFee: fee,
      total: subtotal - discount + fee,
    );
  }
}
