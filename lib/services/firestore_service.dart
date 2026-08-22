import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class FirestoreService {
  Future<List<Category>> fetchCategories() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _categories;
  }

  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 900));
    return _products;
  }

  Future<List<OrderModel>> fetchOrders(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PrefsKeys.orders);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .where((o) => o.userId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveOrder(OrderModel order) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _allOrders(prefs);
    all.removeWhere((e) => e.id == order.id);
    all.add(order);
    await prefs.setString(
      PrefsKeys.orders,
      jsonEncode(all.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> updateOrderStatus(
    String orderId,
    String status, {
    DateTime? deliveredAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _allOrders(prefs);
    OrderModel? updated;
    for (final o in all) {
      if (o.id == orderId) {
        updated = o.copyWith(
          status: status,
          updatedAt: DateTime.now(),
          deliveredAt: status == OrderStatus.delivered
              ? DateTime.now()
              : o.deliveredAt,
        );
      }
    }
    if (updated != null) {
      all.removeWhere((e) => e.id == orderId);
      all.add(updated);
      await prefs.setString(
        PrefsKeys.orders,
        jsonEncode(all.map((e) => e.toJson()).toList()),
      );
    }
  }

  Future<void> rateOrder(String orderId, double rating) =>
      _patchOrder(orderId, (o) => o.copyWith(rating: rating));

  Future<List<OrderModel>> _allOrders(SharedPreferences prefs) async {
    final raw = prefs.getString(PrefsKeys.orders);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _patchOrder(
    String orderId,
    OrderModel Function(OrderModel) patcher,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _allOrders(prefs);
    OrderModel? updated;
    for (final o in all) {
      if (o.id == orderId) updated = patcher(o);
    }
    if (updated != null) {
      all.removeWhere((e) => e.id == orderId);
      all.add(updated);
      await prefs.setString(
        PrefsKeys.orders,
        jsonEncode(all.map((e) => e.toJson()).toList()),
      );
    }
  }

  static const List<Category> _categories = [
    Category(
      id: 'c1',
      name: 'كشري',
      nameEn: 'Koshary',
      image: '🍛',
      sortOrder: 1,
    ),
    Category(
      id: 'c2',
      name: 'مكرونة',
      nameEn: 'Pasta',
      image: '🍝',
      sortOrder: 2,
    ),
    Category(id: 'c3', name: 'أرز', nameEn: 'Rice', image: '🍚', sortOrder: 3),
    Category(
      id: 'c4',
      name: 'إضافات',
      nameEn: 'Extras',
      image: '🥗',
      sortOrder: 4,
    ),
    Category(
      id: 'c5',
      name: 'مشروبات',
      nameEn: 'Drinks',
      image: '🥤',
      sortOrder: 5,
    ),
  ];

  static const List<ProductSize> _kosharySizes = [
    ProductSize(name: 'صغير', price: 25),
    ProductSize(name: 'وسط', price: 35),
    ProductSize(name: 'كبير', price: 45),
    ProductSize(name: 'عائلي', price: 90),
  ];

  static const List<ProductExtra> _kosharyExtras = [
    ProductExtra(name: 'شطة زيادة', price: 2),
    ProductExtra(name: 'بصل مقرمش', price: 3),
    ProductExtra(name: 'ثومية زيادة', price: 2),
    ProductExtra(name: 'سجق', price: 15),
    ProductExtra(name: 'حمص زيادة', price: 4),
    ProductExtra(name: 'دقاق', price: 2),
  ];

  static const List<Product> _products = [
    Product(
      id: 'p1',
      categoryId: 'c1',
      name: 'كشري بلية كبير',
      description:
          'الكشري الأصيل بأرز مصري ومكرونة وعدسة حمرة مع صلصة الشطة الحارة والبصل المقرمش، سر بلية من 1985.',
      price: 45,
      oldPrice: 55,
      image: '🍛',
      isAvailable: true,
      isPopular: true,
      ingredients: ['أرز', 'مكرونة', 'عدسة', 'حمص', 'بصل مقرمش', 'صلصة شطة'],
      sizes: _kosharySizes,
      extras: _kosharyExtras,
      rating: 4.8,
      reviewsCount: 1240,
    ),
    Product(
      id: 'p2',
      categoryId: 'c1',
      name: 'كشري بالسجق',
      description: 'كشري بلية مع سجق بلدي مشوي على الفحم وصلصة خاصة.',
      price: 55,
      image: '🍲',
      isAvailable: true,
      isPopular: true,
      ingredients: ['أرز', 'مكرونة', 'عدسة', 'سجق بلدي', 'صلصة شطة'],
      sizes: _kosharySizes,
      extras: _kosharyExtras,
      rating: 4.7,
      reviewsCount: 860,
    ),
    Product(
      id: 'p3',
      categoryId: 'c1',
      name: 'كشري عائلي جumbo',
      description: 'طبخة كاملة تكفي 4 أفراد مع كل الإضافات والصوصات.',
      price: 90,
      oldPrice: 110,
      image: '🥘',
      isAvailable: true,
      isPopular: true,
      ingredients: ['أرز', 'مكرونة', 'عدسة', 'حمص', 'سجق', 'كل الصوصات'],
      sizes: [ProductSize(name: 'عائلي', price: 90)],
      extras: _kosharyExtras,
      rating: 4.9,
      reviewsCount: 430,
    ),
    Product(
      id: 'p4',
      categoryId: 'c1',
      name: 'كشري ناشف',
      description: 'كشري بدون مرقة مع الدقاق والخلطة الجافة.',
      price: 40,
      image: '🍛',
      isAvailable: true,
      isPopular: false,
      ingredients: ['أرز', 'مكرونة', 'عدسة', 'دقاق'],
      sizes: _kosharySizes,
      extras: _kosharyExtras,
      rating: 4.5,
      reviewsCount: 210,
    ),
    Product(
      id: 'p5',
      categoryId: 'c2',
      name: 'مكرونة ابيخ بالصلصة',
      description: 'مكرونة مسلوقة بالصلصة الحارة والثومية والدقاق.',
      price: 22,
      image: '🍝',
      isAvailable: true,
      isPopular: false,
      ingredients: ['مكرونة', 'صلصة', 'ثومية', 'دقاق'],
      sizes: [
        ProductSize(name: 'وسط', price: 22),
        ProductSize(name: 'كبير', price: 32),
      ],
      extras: [
        ProductExtra(name: 'شطة زيادة', price: 2),
        ProductExtra(name: 'ثومية زيادة', price: 2),
      ],
      rating: 4.3,
      reviewsCount: 150,
    ),
    Product(
      id: 'p6',
      categoryId: 'c2',
      name: 'مكرونة بالبشاميل',
      description: 'بشاميل بلية الكريمي بطبقات مكرونة ولحمة مفرومة.',
      price: 42,
      image: '🥧',
      isAvailable: true,
      isPopular: true,
      ingredients: ['مكرونة', 'بشاميل', 'لحمة مفرومة'],
      sizes: [
        ProductSize(name: 'وسط', price: 42),
        ProductSize(name: 'عائلي', price: 75),
      ],
      extras: [],
      rating: 4.6,
      reviewsCount: 320,
    ),
    Product(
      id: 'p7',
      categoryId: 'c3',
      name: 'أرز معمر',
      description: 'أرز معمر بالقشطة في الفرن البلدي.',
      price: 30,
      image: '🍚',
      isAvailable: true,
      isPopular: false,
      ingredients: ['أرز', 'قشطة', 'لبن'],
      sizes: [
        ProductSize(name: 'وسط', price: 30),
        ProductSize(name: 'عائلي', price: 55),
      ],
      extras: [],
      rating: 4.4,
      reviewsCount: 95,
    ),
    Product(
      id: 'p8',
      categoryId: 'c3',
      name: 'أرز أبيض بالسمنة',
      description: 'أرز أبيض مصري بالسمنة البلدي.',
      price: 12,
      image: '🍚',
      isAvailable: true,
      isPopular: false,
      ingredients: ['أرز', 'سمنة بلدي'],
      sizes: [
        ProductSize(name: 'وسط', price: 12),
        ProductSize(name: 'كبير', price: 18),
      ],
      extras: [],
      rating: 4.1,
      reviewsCount: 60,
    ),
    Product(
      id: 'p9',
      categoryId: 'c4',
      name: 'سلطة بلية المشكلة',
      description: 'سلطة طازجة يومياً: خيار، طماطم، جرجير، ليمون.',
      price: 8,
      image: '🥗',
      isAvailable: true,
      isPopular: false,
      ingredients: ['خيار', 'طماطم', 'جرجير'],
      sizes: [ProductSize(name: 'طبق', price: 8)],
      extras: [],
      rating: 4.2,
      reviewsCount: 45,
    ),
    Product(
      id: 'p10',
      categoryId: 'c4',
      name: 'حمص بالليمون',
      description: 'حمص مدفون بالليمون وزيت الزيتون.',
      price: 10,
      image: '🫘',
      isAvailable: true,
      isPopular: false,
      ingredients: ['حمص', 'ليمون', 'زيت زيتون'],
      sizes: [ProductSize(name: 'طبق', price: 10)],
      extras: [],
      rating: 4.3,
      reviewsCount: 70,
    ),
    Product(
      id: 'p11',
      categoryId: 'c5',
      name: 'كولا باردة',
      description: 'علبة كولا مثلجة.',
      price: 10,
      image: '🥤',
      isAvailable: true,
      isPopular: true,
      ingredients: [],
      sizes: [ProductSize(name: 'علبة', price: 10)],
      extras: [],
      rating: 4.0,
      reviewsCount: 500,
    ),
    Product(
      id: 'p12',
      categoryId: 'c5',
      name: 'عصير مانجو طازج',
      description: 'مانجو بلدي طبيعي 100% بدون سكر مضاف.',
      price: 15,
      image: '🧃',
      isAvailable: true,
      isPopular: false,
      ingredients: ['مانجو'],
      sizes: [
        ProductSize(name: 'وسط', price: 15),
        ProductSize(name: 'كبير', price: 22),
      ],
      extras: [],
      rating: 4.6,
      reviewsCount: 180,
    ),
  ];
}
