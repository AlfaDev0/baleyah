import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareService {
  static const String apkUrl =
      'https://github.com/AlfaDev0/baleyah/releases/download/v1.2/baleyah-v1.2.apk';
  static const String siteUrl = 'https://alfadev0.github.io/baleyah/';

  static String get message =>
      '🍽️ جرب تطبيق بلية — كشري على أصوله!\n'
      '✅ أكل بيتي محضر يومياً بمكونات طازة\n'
      '🚚 توصيل سريع — والدفع كاش عند الاستلام\n'
      '🎁 وكل 5 طلبات ليكم هدية!\n\n'
      '⬇️ حمل التطبيق من هنا:\n'
      '$apkUrl';

  static Future<bool> shareApp() async {
    final uri = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(message)}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (ok) return true;
    } catch (_) {}
    await Clipboard.setData(ClipboardData(text: message));
    return false;
  }
}
