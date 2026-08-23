import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/ui_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_loading.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _syncPendingCategory() {
    final ui = context.read<UiProvider>();
    final pending = ui.pendingCategory;
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<MenuProvider>().selectCategory(pending.id);
        ui.consumePendingCategory();
      });
    }
  }

  Future<void> _quickAdd(Product p) async {
    await context.read<CartProvider>().add(
      product: p,
      size: p.sizes.first,
      extras: [],
      quantity: 1,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${p.name} للسلة 🛒'),
        action: SnackBarAction(
          label: 'السلة',
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncPendingCategory();
    final menu = context.watch<MenuProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الطعام'),
        actions: [
          PopupMenuButton<MenuSort>(
            icon: const Icon(Icons.sort_rounded, color: AppColors.primaryDark),
            onSelected: (s) => context.read<MenuProvider>().setSort(s),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: MenuSort.popular,
                child: Text('الأكثر شعبية'),
              ),
              PopupMenuItem(
                value: MenuSort.priceAsc,
                child: Text('الأرخص أولاً'),
              ),
              PopupMenuItem(
                value: MenuSort.priceDesc,
                child: Text('الأغلى أولاً'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => context.read<MenuProvider>().setSearchQuery(v),
              decoration: InputDecoration(
                hintText: 'دوّر على أكلك المفضل...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                ),
                suffixIcon: menu.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textLight,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          context.read<MenuProvider>().setSearchQuery('');
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _chip(context, id: 'all', emoji: '🍽️', name: 'الكل'),
                _favChip(context),
                ...menu.categories.map(
                  (c) => _chip(context, id: c.id, emoji: c.image, name: c.name),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<MenuProvider>().load(),
              child: menu.isLoading
                  ? ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [ShimmerLoading(itemCount: 6)],
                    )
                  : Builder(
                       builder: (context) {
                         final favs = context.watch<FavoritesProvider>();
                         final products = menu.selectedCategoryId == 'favs'
                             ? menu.filteredProducts
                                   .where((p) => favs.isFav(p.id))
                                   .toList()
                             : menu.filteredProducts;
                        if (products.isEmpty) {
                          return ListView(
                            children: const [
                              SizedBox(height: 80),
                              Center(
                                child: Text(
                                  '🔍',
                                  style: TextStyle(fontSize: 70),
                                ),
                              ),
                              SizedBox(height: 12),
                              Center(
                                child: Text(
                                  'مفيش نتائج للبحث ده\nجرب كلمة تانية',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textLight),
                                ),
                              ),
                            ],
                          );
                        }
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: products.length,
                          padding: const EdgeInsets.only(bottom: 20, top: 6),
                          itemBuilder: (_, i) => ProductCard(
                            product: products[i],
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.productDetail,
                              arguments: products[i],
                            ),
                            onAdd: () => _quickAdd(products[i]),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _favChip(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final selected = context.watch<MenuProvider>().selectedCategoryId == 'favs';
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              favs.count > 0 || selected
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 15,
              color: selected ? Colors.white : AppColors.secondary,
            ),
            const SizedBox(width: 5),
            Text('المفضلة${favs.count > 0 ? ' (${favs.count})' : ''}'),
          ],
        ),
        selected: selected,
        onSelected: (_) => context.read<MenuProvider>().selectCategory('favs'),
        labelStyle: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.w600,
          color: selected ? Colors.white : AppColors.textLight,
        ),
        selectedColor: AppColors.secondary,
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String id,
    required String emoji,
    required String name,
  }) {
    final selected = context.watch<MenuProvider>().selectedCategoryId == id;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 5),
              Text(name),
            ],
          ),
          selected: selected,
          onSelected: (_) => context.read<MenuProvider>().selectCategory(id),
          labelStyle: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            color: selected ? AppColors.textDark : AppColors.textLight,
          ),
        ),
      ),
    );
  }
}
