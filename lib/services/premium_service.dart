import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  PremiumService._();
  static final PremiumService instance = PremiumService._();

  static const _key = 'is_premium';

  bool _isPremium = false;
  bool _loaded = false;

  bool get isPremium => _isPremium;
  bool get loaded => _loaded;

  /// Call once at app startup in main.dart
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_key) ?? false;
    _loaded = true;
    _verifyInBackground();
  }

  Future<void> _verifyInBackground() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _isPremium = info.entitlements.active.containsKey('premium');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, _isPremium);
    } catch (_) {}
  }

  Future<void> setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}