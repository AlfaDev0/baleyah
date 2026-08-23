import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _key = 'baleyah_favs_v1';
  final Set<String> _ids = {};
  bool _loaded = false;

  bool get loaded => _loaded;

  bool isFav(String productId) => _ids.contains(productId);

  int get count => _ids.length;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _ids.addAll(prefs.getStringList(_key) ?? []);
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String productId) async {
    if (!_ids.remove(productId)) _ids.add(productId);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids.toList());
  }

  void toggleSync(String productId) {
    toggle(productId);
  }
}
