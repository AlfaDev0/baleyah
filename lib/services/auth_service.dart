import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/user_model.dart';

class AuthService {
  Future<bool> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final clean = phone.replaceAll(RegExp(r'\s'), '');
    return RegExp(r'^01[0125][0-9]{8}$').hasMatch(clean);
  }

  Future<UserModel?> verifyOtp(String phone, String code) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (code.trim() != AppInfo.demoOtp) return null;

    final saved = await loadUser();
    final clean = _normalize(phone);
    if (saved != null && saved.phone == clean) return saved;

    return UserModel(
      uid: 'u_${DateTime.now().millisecondsSinceEpoch}',
      phone: clean,
      name: '',
      addresses: const [],
      createdAt: DateTime.now(),
    );
  }

  String _normalize(String phone) => phone.replaceAll(RegExp(r'\s'), '');

  Future<UserModel?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PrefsKeys.user);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.user, jsonEncode(user.toJson()));
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.user);
  }
}
