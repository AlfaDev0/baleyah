import 'package:flutter/foundation.dart' hide Category;

import '../models/category_model.dart';

class UiProvider extends ChangeNotifier {
  int bottomNavIndex = 0;
  Category? pendingCategory;

  void setBottomNavIndex(int index) {
    bottomNavIndex = index;
    pendingCategory = null;
    notifyListeners();
  }

  void openMenuWithCategory(Category category) {
    pendingCategory = category;
    bottomNavIndex = 1;
    notifyListeners();
  }

  void consumePendingCategory() {
    pendingCategory = null;
  }
}
