import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../models/user_model.dart';
import '../providers/order_provider.dart';
import '../providers/ui_provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  final bool embedded;

  const ProfileScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white.withValues(alpha: .25),
                  child: const Text('🙂', style: TextStyle(fontSize: 36)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name.isEmpty ?? true ? 'صاحب النعم' : user!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📞 ${user?.phone ?? ''}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  onPressed: () => _editName(context, user),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'عناويني المحفوظة',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...(user?.addresses ?? []).map(
            (a) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(
                  _titleIcon(a.title),
                  style: const TextStyle(fontSize: 26),
                ),
                title: Row(
                  children: [
                    Text(
                      a.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (a.isDefault)
                      Container(
                        margin: const EdgeInsetsDirectional.only(start: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'افتراضي',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  a.fullAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    final userProv = context.read<UserProvider>();
                    if (v == 'default') {
                      await userProv.setDefaultAddress(a.id);
                    } else if (v == 'edit') {
                      if (!context.mounted) return;
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.addAddress, arguments: a);
                    } else if (v == 'delete') {
                      await userProv.deleteAddress(a.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'default',
                      child: Text('خلّيه الافتراضي'),
                    ),
                    PopupMenuItem(value: 'edit', child: Text('تعديل')),
                    PopupMenuItem(value: 'delete', child: Text('حذف')),
                  ],
                ),
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.addAddress, arguments: a),
              ),
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withValues(alpha: .7)),
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.addAddress),
            icon: const Icon(Icons.add_location_alt_outlined, size: 19),
            label: const Text('إضافة عنوان جديد'),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.local_offer_rounded,
                    color: AppColors.secondary,
                  ),
                  title: const Text(
                    'كوبون خصم 20%',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('اكتب "بلية20" وقت تأكيد الطلب'),
                  trailing: const Icon(Icons.copy_rounded, size: 18),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الكود: بلية20 🎁')),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(
                    Icons.payments_rounded,
                    color: AppColors.success,
                  ),
                  title: Text(
                    'الدفع عند الاستلام فقط',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('كاش بس، من غير أي رسوم إلكترونية'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(
                    Icons.support_agent_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'خدمة العملاء',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('خط ساخن: 19999'),
                  trailing: Icon(Icons.call_rounded, size: 18),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.textLight,
                  ),
                  title: Text(
                    'بلية - الإصدار 1.0.0',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('كشري على أصوله من 1985 ❤️'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: const BorderSide(color: AppColors.secondary),
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.logout_rounded, size: 19),
            label: const Text('تسجيل الخروج'),
            onPressed: () => _logout(context),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String _titleIcon(String title) {
    switch (title) {
      case 'المنزل':
        return '🏠';
      case 'العمل':
        return '🏢';
      default:
        return '📍';
    }
  }

  Future<void> _editName(BuildContext context, UserModel? user) {
    final controller = TextEditingController(text: user?.name ?? '');
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اسمك ايه يا معلم؟'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'اكتب اسمك هنا...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              context.read<UserProvider>().updateName(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('هتخرج ليه؟ 😢'),
        content: const Text('سلتك محفوظة عندنا، ترجع تلاقيها زي ما هي.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('مش خارج'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    await context.read<UserProvider>().signOut();
    if (!context.mounted) return;
    await context.read<OrderProvider>().loadOrders('-');
    if (!context.mounted) return;
    context.read<UiProvider>().setBottomNavIndex(0);
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
  }
}
