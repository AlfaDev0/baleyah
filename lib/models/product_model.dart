class ProductSize {
  final String name;
  final double price;

  const ProductSize({required this.name, required this.price});

  Map<String, dynamic> toJson() => {'name': name, 'price': price};

  factory ProductSize.fromJson(Map<String, dynamic> json) => ProductSize(
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
  );
}

class ProductExtra {
  final String name;
  final double price;

  const ProductExtra({required this.name, required this.price});

  Map<String, dynamic> toJson() => {'name': name, 'price': price};

  factory ProductExtra.fromJson(Map<String, dynamic> json) => ProductExtra(
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
  );
}

class Product {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final double? oldPrice;
  final String image;
  final bool isAvailable;
  final bool isPopular;
  final List<String> ingredients;
  final List<ProductSize> sizes;
  final List<ProductExtra> extras;
  final double rating;
  final int reviewsCount;

  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.image,
    required this.isAvailable,
    required this.isPopular,
    required this.ingredients,
    required this.sizes,
    required this.extras,
    required this.rating,
    required this.reviewsCount,
  });

  bool get hasOffer => oldPrice != null && oldPrice! > price;

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'name': name,
    'description': description,
    'price': price,
    'oldPrice': oldPrice,
    'image': image,
    'isAvailable': isAvailable,
    'isPopular': isPopular,
    'ingredients': ingredients,
    'sizes': sizes.map((e) => e.toJson()).toList(),
    'extras': extras.map((e) => e.toJson()).toList(),
    'rating': rating,
    'reviewsCount': reviewsCount,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    categoryId: json['categoryId'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    oldPrice: json['oldPrice'] == null
        ? null
        : (json['oldPrice'] as num).toDouble(),
    image: json['image'] as String,
    isAvailable: json['isAvailable'] as bool,
    isPopular: json['isPopular'] as bool,
    ingredients: (json['ingredients'] as List).map((e) => e as String).toList(),
    sizes: (json['sizes'] as List)
        .map((e) => ProductSize.fromJson(e as Map<String, dynamic>))
        .toList(),
    extras: (json['extras'] as List)
        .map((e) => ProductExtra.fromJson(e as Map<String, dynamic>))
        .toList(),
    rating: (json['rating'] as num).toDouble(),
    reviewsCount: (json['reviewsCount'] as num).toInt(),
  );
}
