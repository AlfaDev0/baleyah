/// خريطة صور المنتجات والأقسام — كل صورة أصل محلي في assets/images
class ProductImages {
  ProductImages._();

  static const Map<String, String> products = {
    'p1': 'assets/images/koshari.jpg',
    'p2': 'assets/images/koshari_sog.jpg',
    'p3': 'assets/images/koshari_family.jpg',
    'p4': 'assets/images/koshari.jpg',
    'p5': 'assets/images/pasta_salsa.jpg',
    'p6': 'assets/images/macarona_bechamel.jpg',
    'p7': 'assets/images/rice_maamar.jpg',
    'p8': 'assets/images/rice_white.jpg',
    'p9': 'assets/images/salad.jpg',
    'p10': 'assets/images/hommos.jpg',
    'p11': 'assets/images/cola.jpg',
    'p12': 'assets/images/mango_juice.jpg',
  };

  static const Map<String, String> categories = {
    'c1': 'assets/images/koshari.jpg',
    'c2': 'assets/images/pasta_salsa.jpg',
    'c3': 'assets/images/rice_white.jpg',
    'c4': 'assets/images/salad.jpg',
    'c5': 'assets/images/mango_juice.jpg',
  };

  static const String banner = 'assets/images/banner.jpg';
  static const String splashLogo = 'assets/images/splash_logo.png';

  static String? product(String id) => products[id];
  static String? category(String id) => categories[id];
}
