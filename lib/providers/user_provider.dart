import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();

  UserModel? _user;
  bool _otpSent = false;
  bool _busy = false;
  String? _selectedAddressId;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get otpSent => _otpSent;
  bool get busy => _busy;

  Address? get selectedAddress {
    final u = _user;
    if (u == null || u.addresses.isEmpty) return null;
    for (final a in u.addresses) {
      if (a.id == _selectedAddressId) return a;
    }
    return u.defaultAddress;
  }

  String get displayName =>
      (_user?.name.isNotEmpty ?? false) ? _user!.name : 'صاحب النعم';

  Future<void> init() async {
    _user = await _auth.loadUser();
    notifyListeners();
  }

  void resetOtpFlow() {
    _otpSent = false;
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _busy = true;
    notifyListeners();
    final ok = await _auth.sendOtp(phone);
    _busy = false;
    _otpSent = ok;
    notifyListeners();
    return ok;
  }

  Future<bool> verifyOtp(String phone, String code) async {
    _busy = true;
    notifyListeners();
    final u = await _auth.verifyOtp(phone, code);
    _busy = false;
    if (u != null) {
      _user = u;
      _otpSent = false;
      await _auth.saveUser(u);
      if (u.addresses.isNotEmpty && _selectedAddressId == null) {
        _selectedAddressId = u.defaultAddress?.id;
      }
    }
    notifyListeners();
    return u != null;
  }

  Future<void> updateName(String name) async {
    if (_user == null) return;
    _user = _user!.copyWith(name: name.trim());
    await _auth.saveUser(_user!);
    notifyListeners();
  }

  Future<void> upsertAddress(Address address) async {
    if (_user == null) return;
    var addresses = [..._user!.addresses];
    var newAddress = address;
    if (address.isDefault) {
      addresses = addresses.map((a) => a.copyWith(isDefault: false)).toList();
    } else if (addresses.isEmpty) {
      newAddress = address.copyWith(isDefault: true);
    }
    final index = addresses.indexWhere((a) => a.id == address.id);
    if (index >= 0) {
      addresses[index] = newAddress;
    } else {
      addresses.add(newAddress);
    }
    _user = _user!.copyWith(addresses: addresses);
    _selectedAddressId = newAddress.isDefault
        ? newAddress.id
        : _selectedAddressId;
    await _auth.saveUser(_user!);
    notifyListeners();
  }

  Future<void> deleteAddress(String id) async {
    if (_user == null) return;
    var addresses = _user!.addresses.where((a) => a.id != id).toList();
    if (addresses.isNotEmpty && !addresses.any((a) => a.isDefault)) {
      addresses = [
        for (final (i, a) in addresses.indexed)
          i == 0 ? a.copyWith(isDefault: true) : a,
      ];
    }
    if (_selectedAddressId == id) _selectedAddressId = null;
    _user = _user!.copyWith(addresses: addresses);
    await _auth.saveUser(_user!);
    notifyListeners();
  }

  Future<void> setDefaultAddress(String id) async {
    if (_user == null) return;
    final addresses = _user!.addresses
        .map((a) => a.copyWith(isDefault: a.id == id))
        .toList();
    _user = _user!.copyWith(addresses: addresses);
    await _auth.saveUser(_user!);
    notifyListeners();
  }

  void selectAddress(String id) {
    _selectedAddressId = id;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _otpSent = false;
    _selectedAddressId = null;
    notifyListeners();
  }
}
