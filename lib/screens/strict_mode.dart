import 'dart:io';

import 'package:app_blocker/app_blocker.dart' hide AppInfo;
import 'package:block_apps/services/premium_service.dart';
import 'package:block_apps/utils/blocker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF5F3FF);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF0EDFF);
  static const border = Color(0xFFDDD6FE);
  static const accent = Color(0xFF7C3AED);
  static const accentSoft = Color(0xFFEDE9FE);
  static const red = Color(0xFFDC2626);
  static const redSoft = Color(0xFFFEE2E2);
  static const redBorder = Color(0xFFFCA5A5);
  static const green = Color(0xFF059669);
  static const greenSoft = Color(0xFFD1FAE5);
  static const text = Color(0xFF1E1B4B);
  static const muted = Color(0xFF8B85C1);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEE2E2);
  static const amber = Color(0xFFD97706);
  static const amberSoft = Color(0xFFFEF3C7);
  static const amberBorder = Color(0xFFFCD34D);
}

// ─── Free tier limits ─────────────────────────────────────────────────────────
const _kFreeMaxMinutes = 15;
const _kFreeDailyLimit = 2;
const _kSessionCountKey = 'strict_session_count';
const _kSessionDateKey = 'strict_session_date';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class StrictModePage extends StatefulWidget {
  const StrictModePage({super.key});

  @override
  State<StrictModePage> createState() => _StrictModePageState();
}

class _StrictModePageState extends State<StrictModePage>
    with WidgetsBindingObserver {
  final _blocker = AppBlocker.instance;
  BlockerPermissionStatus? _permission;
  bool _checkingPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPermission();
  }

  Future<void> _checkPermission() async {
    setState(() => _checkingPermission = true);
    try {
      final status = await _blocker.checkPermission();
      if (mounted) setState(() => _permission = status);
    } catch (_) {}
    if (mounted) setState(() => _checkingPermission = false);
  }

  Future<void> _requestPermission() async {
    try {
      final status = await _blocker.requestPermission();
      if (mounted) setState(() => _permission = status);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  bool get _granted => _permission == BlockerPermissionStatus.granted;

  @override
  Widget build(BuildContext context) {
    if (_checkingPermission) {
      return const Scaffold(
        backgroundColor: _C.bg,
        body: Center(child: CircularProgressIndicator(color: _C.accent)),
      );
    }

    if (!_granted) {
      return _PermissionGatePage(
        permissionStatus: _permission,
        onCheck: _checkPermission,
        onRequest: _requestPermission,
      );
    }

    return const _StrictModeContent();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Permission gate
// ─────────────────────────────────────────────────────────────────────────────

class _PermissionGatePage extends StatelessWidget {
  const _PermissionGatePage({
    required this.permissionStatus,
    required this.onCheck,
    required this.onRequest,
  });

  final BlockerPermissionStatus? permissionStatus;
  final VoidCallback onCheck;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: _C.redSoft,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _C.redBorder, width: .8),
                ),
                child: const Icon(Icons.lock_outline, color: _C.red, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Permission Required',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _C.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Strict Mode needs special permissions to block apps on your device.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: _C.muted,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _StatusBadge(status: permissionStatus),
              const SizedBox(height: 20),
              if (Platform.isAndroid)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _C.accentSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _C.border, width: .8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: _C.accent,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Two permissions needed on Android',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _C.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _PermStep(
                        number: '1',
                        label: 'Accessibility Service',
                        desc:
                            'Lets the app detect which app is in the foreground.',
                      ),
                      const SizedBox(height: 6),
                      _PermStep(
                        number: '2',
                        label: 'Alarms & Reminders',
                        desc: 'Required for exact time-based scheduling.',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap "Grant next" repeatedly until both are enabled, then come back here.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: _C.muted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRequest,
                  icon: const Icon(
                    Icons.settings_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Grant next permission',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.accent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCheck,
                  icon: const Icon(Icons.refresh, size: 18, color: _C.accent),
                  label: Text(
                    'Check permission status',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _C.accent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: _C.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final BlockerPermissionStatus? status;

  @override
  Widget build(BuildContext context) {
    final granted = status == BlockerPermissionStatus.granted;
    final label = status == null ? 'Checking…' : status!.name;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: granted ? _C.greenSoft : _C.redSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: granted ? _C.green : _C.redBorder, width: .8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel_outlined,
            color: granted ? _C.green : _C.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Status: $label',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: granted ? _C.green : _C.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermStep extends StatelessWidget {
  const _PermStep({
    required this.number,
    required this.label,
    required this.desc,
  });
  final String number, label, desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _C.accent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _C.text,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.dmSans(fontSize: 11, color: _C.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Strict Mode content
// ─────────────────────────────────────────────────────────────────────────────

class _StrictModeContent extends StatefulWidget {
  const _StrictModeContent();

  @override
  State<_StrictModeContent> createState() => _StrictModeContentState();
}

class _StrictModeContentState extends State<_StrictModeContent> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _hoursCtrl = TextEditingController();
  final TextEditingController _minutesCtrl = TextEditingController();

  final _premium = PremiumService.instance;

  List<AppInfo> _allApps = [];
  bool _loading = false;
  int _todaySessionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTodayCount();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hoursCtrl.dispose();
    _minutesCtrl.dispose();
    super.dispose();
  }

  // ── Daily session counter ──────────────────────────────────────────────────

  Future<void> _loadTodayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_kSessionDateKey) ?? '';
    final today = _todayStr();

    if (savedDate != today) {
      // New day — reset counter
      await prefs.setString(_kSessionDateKey, today);
      await prefs.setInt(_kSessionCountKey, 0);
      if (mounted) setState(() => _todaySessionCount = 0);
    } else {
      final count = prefs.getInt(_kSessionCountKey) ?? 0;
      if (mounted) setState(() => _todaySessionCount = count);
    }
  }

  Future<void> _incrementTodayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final newCount = _todaySessionCount + 1;
    await prefs.setInt(_kSessionCountKey, newCount);
    await prefs.setString(_kSessionDateKey, _todayStr());
    if (mounted) setState(() => _todaySessionCount = newCount);
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  bool get _dailyLimitReached =>
      !_premium.isPremium && _todaySessionCount >= _kFreeDailyLimit;

  // ── helpers ────────────────────────────────────────────────────────────────

  TextStyle _mono({
    double size = 13,
    Color? color,
    FontWeight fw = FontWeight.normal,
  }) => TextStyle(
    fontFamily: 'monospace',
    fontSize: size,
    color: color ?? _C.text,
    fontWeight: fw,
  );

  // ── apps ───────────────────────────────────────────────────────────────────

  Future<void> _getApps() async {
    setState(() => _loading = true);
    try {
      final list = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        withIcon: true,
      );
      setState(() {
        _allApps = list;
        _loading = false;
      });
    } on PlatformException {
      setState(() => _loading = false);
    }
  }

  // ── block ──────────────────────────────────────────────────────────────────

  Future<void> _blockApps() async {
    await _getApps();
    final packages = _allApps
        .where((a) => a.name.trim() != 'Block Apps')
        .map((a) => a.packageName)
        .toList();

    final hours = int.tryParse(_hoursCtrl.text) ?? 0;
    final minutes = int.tryParse(_minutesCtrl.text) ?? 0;
    final now = TimeOfDay.now();

    await BlockService.blocker.addSchedule(
      BlockSchedule(
        enabled: true,
        weekdays: [],
        id: 'strictmode',
        name: _nameCtrl.text.trim(),
        scheduleDate: DateTime.now(),
        appIdentifiers: packages,
        startTime: now,
        endTime: TimeOfDay(
          hour: now.hour + hours,
          minute: now.minute + minutes,
        ),
      ),
    );

    await _incrementTodayCount();

    _hoursCtrl.clear();
    _minutesCtrl.clear();
    _nameCtrl.clear();
  }

  Future<void> _stopApps() async {
    try {
      final schedules = await BlockService.blocker2.getSchedules();
      for (final s in schedules) {
        await BlockService.blocker2.removeSchedule(s.id);
      }
      _snack('All sessions stopped.', success: true);
    } catch (_) {}
  }

  // ── show paywall ───────────────────────────────────────────────────────────

  Future<void> _showPaywall() async {
    final result = await RevenueCatUI.presentPaywall();
    if (!mounted) return;
    if (result == PaywallResult.purchased || result == PaywallResult.restored) {
      await _premium.setPremium(true);
      if (mounted) setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Welcome to Premium!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ── validation ─────────────────────────────────────────────────────────────

  void _onStartPressed() {
    final hours = int.tryParse(_hoursCtrl.text) ?? 0;
    final minutes = int.tryParse(_minutesCtrl.text) ?? 0;
    final totalMinutes = hours * 60 + minutes;

    if (_nameCtrl.text.trim().isEmpty ||
        _hoursCtrl.text.isEmpty ||
        _minutesCtrl.text.isEmpty) {
      _snack('Please fill in all three fields.');
      return;
    }
    if (hours <= 0 && minutes <= 0) {
      _snack('Duration cannot be zero.');
      return;
    }

    // ── Free tier: daily limit check ──────────────────────────────────────
    if (_dailyLimitReached) {
      _showLimitDialog(
        title: 'Daily Limit Reached',
        icon: Icons.today_rounded,
        message:
            'Free users can only start $_kFreeDailyLimit strict sessions per day. '
            'Upgrade to Premium for unlimited daily sessions.',
      );
      return;
    }

    // ── Free tier: duration check ─────────────────────────────────────────
    if (!_premium.isPremium && totalMinutes > _kFreeMaxMinutes) {
      _showLimitDialog(
        title: 'Duration Limit Reached',
        icon: Icons.hourglass_bottom_rounded,
        message:
            'Free users can only block for up to $_kFreeMaxMinutes minutes. '
            'Upgrade to Premium for unlimited duration.',
      );
      return;
    }

    // ── All good — show confirm dialog ────────────────────────────────────
    final durText =
        '${hours > 0 ? '$hours hr ' : ''}${minutes > 0 ? '$minutes min' : ''}'
            .trim();

    showDialog(
      context: context,
      builder: (dCtx) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.accent,
            onPrimary: Colors.white,
            surface: _C.surface,
          ),
        ),
        child: AlertDialog(
          backgroundColor: _C.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _C.redSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_outline, color: _C.red, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Confirm Block',
                style: GoogleFonts.dmSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.text,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Once started, all apps will be blocked for $durText. '
                "You won't be able to undo this during the session.",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: _C.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _C.redSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.redBorder, width: .8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: _C.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This action cannot be reversed mid-session.',
                        style: TextStyle(fontSize: 12, color: _C.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dCtx),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _C.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.dmSans(
                  color: _C.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dCtx);
                _blockApps();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Session Started',
                      message: 'Strict block is now active.',
                      contentType: ContentType.success,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Start Block',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Premium limit dialog ───────────────────────────────────────────────────

  void _showLimitDialog({
    required String title,
    required IconData icon,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: _C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _C.amberSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _C.amber, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _C.text,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: _C.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Benefits preview
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _C.accentSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border, width: .8),
              ),
              child: Column(
                children: [
                  _BenefitRow(
                    Icons.hourglass_bottom_rounded,
                    'Unlimited Duration',
                  ),
                  const SizedBox(height: 8),
                  _BenefitRow(Icons.today_rounded, 'Unlimited Daily Sessions'),
                  const SizedBox(height: 8),
                  _BenefitRow(Icons.flash_on_rounded, 'Unlimited Quick Blocks'),
                  const SizedBox(height: 8),
                  _BenefitRow(Icons.apps_rounded, 'Unlimited App Blocking'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dCtx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _C.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(
              'Not now',
              style: GoogleFonts.dmSans(
                color: _C.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dCtx);
              _showPaywall();
            },
            icon: const Icon(Icons.workspace_premium_rounded, size: 16),
            label: Text(
              'Unlock Premium',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── snackbar ───────────────────────────────────────────────────────────────

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: success ? _C.greenSoft : _C.dangerSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: success ? _C.green : _C.danger, width: .8),
        ),
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: success ? _C.green : _C.danger,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(
                  color: success ? _C.green : _C.danger,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── input decoration ───────────────────────────────────────────────────────

  InputDecoration _inputDeco(String hint, {Widget? suffix}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _C.muted, fontSize: 14),
    suffixIcon: suffix,
    filled: true,
    fillColor: _C.surface2,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _C.border, width: .8),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _C.border, width: .8),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _C.accent, width: 1.2),
    ),
  );

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),

              // Free tier usage banner
              if (!_premium.isPremium) ...[
                _buildFreeBanner(),
                const SizedBox(height: 10),
              ],

              _buildNameCard(),
              const SizedBox(height: 10),
              _buildDurationCard(),
              const SizedBox(height: 10),
              _buildInfoCard(),
              const SizedBox(height: 10),
              _buildStopCard(),
              const SizedBox(height: 16),
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Free usage banner ──────────────────────────────────────────────────────

  Widget _buildFreeBanner() {
    final remaining = (_kFreeDailyLimit - _todaySessionCount).clamp(
      0,
      _kFreeDailyLimit,
    );
    final isExhausted = remaining == 0;

    return GestureDetector(
      onTap: _showPaywall,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isExhausted ? _C.redSoft : _C.amberSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExhausted ? _C.redBorder : _C.amberBorder,
            width: .8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isExhausted ? Icons.block_rounded : Icons.info_outline_rounded,
              color: isExhausted ? _C.red : _C.amber,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExhausted
                        ? 'Daily limit reached'
                        : '$remaining session${remaining == 1 ? '' : 's'} left today',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isExhausted ? _C.red : _C.amber,
                    ),
                  ),
                  Text(
                    isExhausted
                        ? 'Upgrade to Premium for unlimited sessions'
                        : 'Free: max $_kFreeMaxMinutes min · $_kFreeDailyLimit sessions/day · Tap to upgrade',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: isExhausted ? _C.red : _C.amber,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isExhausted ? _C.red : _C.amber,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _C.redSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.redBorder, width: .8),
            ),
            child: const Icon(Icons.lock, color: _C.red, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Strict Mode',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _C.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'All your apps are blocked at once.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: _C.muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _C.redSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.redBorder, width: .8),
                  ),
                  child: Text(
                    'All apps blocked',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: _C.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('Session Name'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: _C.text, fontSize: 15),
            decoration: _inputDeco(
              'Name this session…',
              suffix: ValueListenableBuilder(
                valueListenable: _nameCtrl,
                builder: (_, v, _) => v.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 18,
                          color: _C.muted,
                        ),
                        onPressed: () => setState(() => _nameCtrl.clear()),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCard() {
    final hours = int.tryParse(_hoursCtrl.text) ?? 0;
    final minutes = int.tryParse(_minutesCtrl.text) ?? 0;
    final totalMinutes = hours * 60 + minutes;
    final overLimit = !_premium.isPremium && totalMinutes > _kFreeMaxMinutes;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Label('Session Duration'),
              if (!_premium.isPremium) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _C.amberSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.amberBorder, width: .8),
                  ),
                  child: Text(
                    'Max $_kFreeMaxMinutes min',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: _C.amber,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _hoursCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    color: overLimit ? _C.red : _C.text,
                    fontSize: 15,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDeco('Hours').copyWith(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: overLimit ? _C.redBorder : _C.border,
                        width: .8,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _minutesCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    color: overLimit ? _C.red : _C.text,
                    fontSize: 15,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDeco('Minutes').copyWith(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: overLimit ? _C.redBorder : _C.border,
                        width: .8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Duration pill or over-limit warning
          if (totalMinutes > 0)
            overLimit
                ? GestureDetector(
                    onTap: _showPaywall,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _C.redSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _C.redBorder, width: .8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: _C.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Over $_kFreeMaxMinutes min limit — tap to upgrade',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: _C.red,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _C.accentSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _C.border, width: .8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: _C.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Block for ${hours > 0 ? '$hours hr ' : ''}${minutes > 0 ? '$minutes min' : ''}'
                              .trim(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: _C.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.redSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.redBorder, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: _C.red, size: 16),
              const SizedBox(width: 8),
              Text(
                'What gets blocked',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: _C.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Every app on your phone will be blocked — except Block Apps itself.',
            style: GoogleFonts.dmSans(fontSize: 13, color: _C.red, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStopCard() {
    return _Card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active sessions',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stop all running block sessions.',
                  style: GoogleFonts.dmSans(fontSize: 12, color: _C.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _stopApps,
            icon: const Icon(Icons.stop_circle_outlined, size: 16),
            label: const Text('Stop All'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _C.red,
              side: const BorderSide(color: _C.redBorder, width: .8),
              backgroundColor: _C.redSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    final isDisabled = _loading || _dailyLimitReached;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled
            ? (_dailyLimitReached
                  ? () => _showLimitDialog(
                      title: 'Daily Limit Reached',
                      icon: Icons.today_rounded,
                      message:
                          'Free users can only start $_kFreeDailyLimit strict sessions per day. '
                          'Upgrade to Premium for unlimited daily sessions.',
                    )
                  : null)
            : _onStartPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _dailyLimitReached ? _C.redSoft : _C.red,
          disabledBackgroundColor: _dailyLimitReached ? _C.redSoft : _C.redSoft,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _dailyLimitReached
                        ? Icons.lock_outline
                        : Icons.lock_outline,
                    size: 18,
                    color: _dailyLimitReached ? _C.red : Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _dailyLimitReached
                        ? 'Limit reached — Upgrade'
                        : 'Start Strict Block',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _dailyLimitReached ? _C.red : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Benefit row (used in limit dialog) ───────────────────────────────────────

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BenefitRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _C.accent, size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _C.text,
          ),
        ),
        const Spacer(),
        const Icon(Icons.check_circle_rounded, color: _C.green, size: 16),
      ],
    );
  }
}

// ─── Reusable widgets ──────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border, width: .8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A7C3AED),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 10,
        letterSpacing: 1.2,
        color: _C.muted,
      ),
    );
  }
}
