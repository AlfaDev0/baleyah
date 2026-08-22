import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/cart_model.dart' show CartItem, CartTotals;
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  String? _couponCode;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get discount {
    if (_couponCode == AppInfo.couponCode) {
      return subtotal * AppInfo.couponPercent;
    }
    return 0;
  }

  bool get isCouponApplied => _couponCode != null && discount > 0;

  CartTotals get totals => CartTotals.calculate(subtotal, discount);

  bool hasProduct(String productId) =>
      _items.any((i) => i.productId == productId);

  int quantityOfProduct(String productId) => _items
      .where((i) => i.productId == productId)
      .fold(0, (sum, i) => sum + i.quantity);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PrefsKeys.cart);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List;
      _items = list
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _items = [];
    }
    notifyListeners();
  }

  Future<void> add({
    required Product product,
    required ProductSize size,
    required List<ProductExtra> extras,
    required int quantity,
  }) async {
    final id = CartItem.buildId(
      productId: product.id,
      size: size.name,
      extras: extras.map((e) => e.name).toList(),
    );
    final unitPrice =
        size.price + extras.fold<double>(0, (sum, e) => sum + e.price);
    final index = _items.indexWhere((i) => i.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
      );
    } else {
      _items = [
        ..._items,
        CartItem(
          id: id,
          productId: product.id,
          productName: product.name,
          image: product.image,
          size: size.name,
          extras: extras.map((e) => e.name).toList(),
          quantity: quantity,
          unitPrice: unitPrice,
        ),
      ];
    }
    await _persist();
    notifyListeners();
  }

  Future<void> increaseQuantity(String itemId) async => _changeQty(itemId, 1);

  Future<void> decreaseQuantity(String itemId) async => _changeQty(itemId, -1);

  Future<void> removeItem(String itemId) async {
    _items = _items.where((i) => i.id != itemId).toList();
    if (_items.isEmpty) _couponCode = null;
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _items = [];
    _couponCode = null;
    await _persist();
    notifyListeners();
  }

  bool applyCoupon(String code) {
    final clean = code.trim().replaceAll(RegExp(r'\s+'), '');
    if (clean == AppInfo.couponCode || clean.toLowerCase() == 'baleyah20') {
      _couponCode = AppInfo.couponCode;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  void removeCoupon() {
    _couponCode = null;
    notifyListeners();
  }

  Future<void> _changeQty(String itemId, int delta) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index < 0) return;
    final newQty = _items[index].quantity + delta;
    if (newQty <= 0) {
      await removeItem(itemId);
      return;
    }
    _items[index] = _items[index].copyWith(quantity: newQty);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      PrefsKeys.cart,
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
  }
}
