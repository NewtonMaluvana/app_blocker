import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpgradeButton extends StatefulWidget {
  const UpgradeButton({super.key});

  @override
  State<UpgradeButton> createState() => _UpgradeButtonState();
}

class _UpgradeButtonState extends State<UpgradeButton> {
  bool _isLoading = false;
  bool _isPremium = false;

  static const String _premiumKey = 'is_premium';

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }

  // 1️⃣ Load from local cache instantly (no flicker)
  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getBool(_premiumKey) ?? false;
    if (mounted) setState(() => _isPremium = cached);

    // Then verify with RevenueCat in background
    _verifyWithRevenueCat();
  }

  // 2️⃣ Verify against RevenueCat and update cache
  Future<void> _verifyWithRevenueCat() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements.active.containsKey("premium");

      // Save to cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, isPremium);

      if (mounted) setState(() => _isPremium = isPremium);
    } catch (e) {
      debugPrint('RevenueCat check failed: $e');
      // Keep showing cached value if network fails
    }
  }

  // 3️⃣ Save premium after successful purchase
  Future<void> _savePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
    if (mounted) setState(() => _isPremium = true);
  }

  Future<void> _onUpgradePressed() async {
    setState(() => _isLoading = true);

    try {
      final result = await RevenueCatUI.presentPaywall();

      if (!mounted) return;

      if (result == PaywallResult.purchased || result == PaywallResult.restored) {
        await _savePremium(); // ← persist it
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Welcome to Premium!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Premium state ──
    if (_isPremium) {
      return ElevatedButton.icon(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          disabledBackgroundColor: Colors.amber.shade700,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        icon: const Icon(Icons.star_rounded, color: Colors.white),
        label: const Text(
          "You're on Premium ✨",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }

    // ── Free state ──
    return ElevatedButton(
      onPressed: _isLoading ? null : _onUpgradePressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Text(
              'Upgrade to Premium',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }
}