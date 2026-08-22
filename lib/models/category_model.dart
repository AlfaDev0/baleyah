class Category {
  final String id;
  final String name;
  final String nameEn;
  final String image;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.image,
    required this.sortOrder,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameEn': nameEn,
    'image': image,
    'sortOrder': sortOrder,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    nameEn: json['nameEn'] as String,
    image: json['image'] as String? ?? '🍛',
    sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  );
}
