import 'package:flutter/foundation.dart' hide Category;

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

enum MenuSort { popular, priceAsc, priceDesc }

class MenuProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<Category> categories = [];
  List<Product> products = [];
  bool isLoading = true;

  String searchQuery = '';
  String selectedCategoryId = 'all';
  MenuSort sort = MenuSort.popular;

  bool get hasOfferProducts => products.any((p) => p.hasOffer);

  List<Product> get filteredProducts {
    Iterable<Product> list = products.where((p) => p.isAvailable);
    if (selectedCategoryId != 'all') {
      list = list.where((p) => p.categoryId == selectedCategoryId);
    }
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where(
        (p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.ingredients.any((i) => i.toLowerCase().contains(q)),
      );
    }
    switch (sort) {
      case MenuSort.popular:
        final result = list.toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));
        return result;
      case MenuSort.priceAsc:
        return list.toList()..sort((a, b) => a.price.compareTo(b.price));
      case MenuSort.priceDesc:
        return list.toList()..sort((a, b) => b.price.compareTo(a.price));
    }
  }

  Product? productById(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    categories = await _service.fetchCategories();
    products = await _service.fetchProducts();
    isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void selectCategory(String id) {
    selectedCategoryId = id;
    notifyListeners();
  }

  void setSort(MenuSort value) {
    sort = value;
    notifyListeners();
  }
}
