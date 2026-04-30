import 'dart:io';

import 'package:app_blocker/app_blocker.dart' hide AppInfo;
import 'package:block_apps/utils/blocker_service.dart';
import 'package:block_apps/services/premium_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF5F3FF);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF0EDFF);
  static const border = Color(0xFFDDD6FE);
  static const accent = Color.fromARGB(255, 68, 27, 139);
  static const accentSoft = Color(0xFFEDE9FE);
  static const accentMid = Color(0xFFDDD6FE);
  static const green = Color(0xFF059669);
  static const greenSoft = Color(0xFFD1FAE5);
  static const text = Color(0xFF1E1B4B);
  static const muted = Color(0xFF8B85C1);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEE2E2);
  static const dangerBorder = Color(0xFFFCA5A5);
  static const chipOff = Color(0xFFF5F3FF);
  static const chipOn = Color(0xFFEDE9FE);
  static const chipLavender = Color(0xFF6D28D9);
}

// ─── Benefits ─────────────────────────────────────────────────────────────────
const _benefits = [
  (Icons.flash_on_rounded,         'Unlimited Daily Blocks',    'Quick-block any time focus slips'),
  (Icons.lock_clock_rounded,       'Unlimited Sessions',        'Run as many lock sessions as you want'),
  (Icons.hourglass_bottom_rounded, 'Unlimited Duration',        'Minutes, hours, even days — no caps'),
  (Icons.apps_rounded,             'Unlimited App Blocking',    'Add every app to your blocklist'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class LockSessionPage extends StatefulWidget {
  const LockSessionPage({super.key});

  @override
  State<LockSessionPage> createState() => _LockSessionPageState();
}

class _LockSessionPageState extends State<LockSessionPage>
    with WidgetsBindingObserver {

  final _blocker = AppBlocker.instance;
  final _premium = PremiumService.instance;
  BlockerPermissionStatus? _permission;
  bool _checkingPermission = true;
  bool _isBuying = false;

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

  // ── Premium ────────────────────────────────────────────────────────────────

  Future<void> _onBuyPressed() async {
    setState(() => _isBuying = true);
    try {
      final result = await RevenueCatUI.presentPaywall();
      if (!mounted) return;
      if (result == PaywallResult.purchased || result == PaywallResult.restored) {
        await _premium.setPremium(true);
        if (mounted) setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: _C.danger),
      );
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  // ── Permission ─────────────────────────────────────────────────────────────

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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_premium.isPremium) {
      return _PremiumGatePage(isBuying: _isBuying, onBuy: _onBuyPressed);
    }

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

    return const _LockSessionContent();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium gate page
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumGatePage extends StatelessWidget {
  final bool isBuying;
  final VoidCallback onBuy;
  const _PremiumGatePage({required this.isBuying, required this.onBuy});

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
                width: 96, height: 96,
                decoration: BoxDecoration(
                  color: _C.accentSoft,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _C.border, width: .8),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: _C.accent, size: 48,
                ),
              ),
              const Gap(20),
              Text(
                'Premium Required',
                style: GoogleFonts.dmSans(
                  fontSize: 22, fontWeight: FontWeight.w700, color: _C.text,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                'Lock Sessions are a premium feature. Upgrade to unlock full control over your focus.',
                style: GoogleFonts.dmSans(fontSize: 14, color: _C.muted, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const Gap(28),

              // Benefits card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _C.border, width: .8),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A7C3AED), blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  children: _benefits.map((b) {
                    final isLast = b == _benefits.last;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: _C.accentSoft,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _C.border, width: .8),
                            ),
                            child: Icon(b.$1, color: _C.accent, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.$2,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13, fontWeight: FontWeight.w700, color: _C.text,
                                    )),
                                const SizedBox(height: 2),
                                Text(b.$3,
                                    style: GoogleFonts.dmSans(fontSize: 12, color: _C.muted)),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded, color: _C.green, size: 18),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Gap(24),

              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: isBuying ? null : onBuy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.accent,
                    disabledBackgroundColor: _C.muted,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: isBuying
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.workspace_premium_rounded, size: 20),
                            const SizedBox(width: 10),
                            Text('Unlock Premium',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16, fontWeight: FontWeight.w700,
                                )),
                          ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Permission gate page
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
                width: 96, height: 96,
                decoration: BoxDecoration(
                  color: _C.accentSoft,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _C.border, width: .8),
                ),
                child: const Icon(Icons.lock_clock_outlined, color: _C.accent, size: 48),
              ),
              const Gap(24),
              Text(
                'Permission Required',
                style: GoogleFonts.dmSans(
                  fontSize: 22, fontWeight: FontWeight.w700, color: _C.text,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(10),
              Text(
                'Lock Session needs special permissions to schedule app blocking on your device.',
                style: GoogleFonts.dmSans(fontSize: 14, color: _C.muted, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const Gap(28),
              _StatusBadge(status: permissionStatus),
              const Gap(20),
              if (Platform.isAndroid)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _C.accentSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _C.border, width: .8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: _C.accent, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Two permissions needed on Android',
                            style: GoogleFonts.dmSans(
                              fontSize: 13, fontWeight: FontWeight.w700, color: _C.accent,
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                      const _PermStep(
                        number: '1',
                        label: 'Accessibility Service',
                        desc: 'Lets the app detect which app is in the foreground.',
                      ),
                      const Gap(8),
                      const _PermStep(
                        number: '2',
                        label: 'Alarms & Reminders',
                        desc: 'Required for exact scheduled blocking.',
                      ),
                      const Gap(10),
                      Text(
                        'Tap "Grant next" repeatedly until both are enabled, then come back here.',
                        style: GoogleFonts.dmSans(fontSize: 12, color: _C.muted, height: 1.5),
                      ),
                    ],
                  ),
                ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRequest,
                  icon: const Icon(Icons.settings_outlined, size: 18, color: Colors.white),
                  label: Text(
                    'Grant next permission',
                    style: GoogleFonts.dmSans(
                      fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.accent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const Gap(10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCheck,
                  icon: const Icon(Icons.refresh, size: 18, color: _C.accent),
                  label: Text(
                    'Check permission status',
                    style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w600, color: _C.accent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: _C.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
        color: granted ? _C.greenSoft : _C.dangerSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: granted ? _C.green : _C.dangerBorder, width: .8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel_outlined,
            color: granted ? _C.green : _C.danger, size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Status: $label',
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: granted ? _C.green : _C.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermStep extends StatelessWidget {
  const _PermStep({required this.number, required this.label, required this.desc});
  final String number, label, desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(color: _C.accent, borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: Text(number,
                style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700,
                )),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _C.text,
                  )),
              Text(desc, style: GoogleFonts.dmSans(fontSize: 11, color: _C.muted)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lock Session content
// ─────────────────────────────────────────────────────────────────────────────

class _LockSessionContent extends StatefulWidget {
  const _LockSessionContent();

  @override
  State<_LockSessionContent> createState() => _LockSessionContentState();
}

class _LockSessionContentState extends State<_LockSessionContent> {
  final TextEditingController _sessionNameController = TextEditingController();
  final TextEditingController _modalSearchController = TextEditingController();

  bool _isOneTime = false;
  final List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  Set<int> _weekdays = {1, 2, 3, 4, 5, 6, 7};
  DateTime _scheduleDate = DateTime.now();
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 17, minute: 0);
  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];
  Set<String> _selectedPackages = {};
  bool _loadingApps = false;

  @override
  void dispose() {
    _sessionNameController.dispose();
    _modalSearchController.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TextStyle _mono({double size = 13, Color? color, FontWeight fw = FontWeight.normal}) =>
      TextStyle(fontFamily: 'monospace', fontSize: size, color: color ?? _C.text, fontWeight: fw);

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.accent, onPrimary: Colors.white, surface: _C.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => isStart ? _start = picked : _end = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduleDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.accent, onPrimary: Colors.white, surface: _C.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _scheduleDate = picked);
  }

  Future<void> _getApps() async {
    if (_allApps.isNotEmpty) return;
    setState(() => _loadingApps = true);
    try {
      final list = await InstalledApps.getInstalledApps(
        excludeSystemApps: false, withIcon: true,
      );
      setState(() {
        _allApps = list.where((a) => a.name != 'Block Apps').toList();
        _filteredApps = List.from(_allApps);
        _loadingApps = false;
      });
    } on PlatformException {
      setState(() => _loadingApps = false);
    }
  }

  Future<void> _submit() async {
    final name = _sessionNameController.text.trim();
    if (name.isEmpty) { _snack('Please enter a session name'); return; }
    if (_selectedPackages.isEmpty) { _snack('Please add apps to block'); return; }
    if (!_isOneTime && _weekdays.isEmpty) { _snack('Select at least one day'); return; }

    final startMinutes = _start.hour * 60 + _start.minute;
    final endMinutes = _end.hour * 60 + _end.minute;
    if (endMinutes <= startMinutes) { _snack('End time must be after start time'); return; }

    await BlockService.blocker2.addSchedule(
      BlockSchedule(
        enabled: true,
        weekdays: _isOneTime ? [] : (_weekdays.toList()..sort()),
        id: 'sessionmode',
        name: name,
        scheduleDate: _isOneTime ? _scheduleDate : null,
        appIdentifiers: _selectedPackages.toList(),
        startTime: _start,
        endTime: _end,
      ),
    );

    _snack('"$name" session created!', success: true);
    setState(() { _sessionNameController.clear(); _selectedPackages = {}; });
  }

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
              color: success ? _C.green : _C.danger, size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg,
                  style: TextStyle(color: success ? _C.green : _C.danger, fontSize: 13)),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showAppsModal() async {
    await _getApps();
    _modalSearchController.clear();
    _filteredApps = List.from(_allApps);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setM) {
            return Container(
              height: MediaQuery.of(ctx).size.height * .85,
              decoration: const BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: _C.border),
                  left: BorderSide(color: _C.border),
                  right: BorderSide(color: _C.border),
                ),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: _C.border, borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('SELECT APPS TO BLOCK', style: _mono(size: 11, color: _C.muted)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _modalSearchController,
                      style: const TextStyle(color: _C.text, fontSize: 14),
                      onChanged: (q) {
                        setM(() {
                          _filteredApps = q.isEmpty
                              ? List.from(_allApps)
                              : _allApps
                                  .where((a) => a.name.toLowerCase().contains(q.toLowerCase()))
                                  .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search apps…',
                        hintStyle: const TextStyle(color: _C.muted, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: _C.muted, size: 18),
                        filled: true,
                        fillColor: _C.surface2,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          borderSide: const BorderSide(color: _C.accent, width: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _loadingApps
                        ? const Center(child: CircularProgressIndicator(color: _C.accent))
                        : _filteredApps.isEmpty
                            ? Center(
                                child: Text('No apps found',
                                    style: TextStyle(color: _C.muted)),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 6,
                                  mainAxisSpacing: 6,
                                  childAspectRatio: .8,
                                ),
                                itemCount: _filteredApps.length,
                                itemBuilder: (ctx, i) {
                                  final app = _filteredApps[i];
                                  final isSel = _selectedPackages.contains(app.packageName);
                                  return GestureDetector(
                                    onTap: () {
                                      setM(() {
                                        isSel
                                            ? _selectedPackages.remove(app.packageName)
                                            : _selectedPackages.add(app.packageName);
                                      });
                                      setState(() {});
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSel ? _C.accentSoft : _C.surface2,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSel ? _C.accent : _C.border,
                                          width: isSel ? 1.2 : .8,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Stack(
                                            children: [
                                              app.icon != null
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Image.memory(
                                                        app.icon!, width: 40, height: 40,
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 40, height: 40,
                                                      decoration: BoxDecoration(
                                                        color: _C.border,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: const Icon(
                                                        Icons.android, color: _C.muted, size: 22,
                                                      ),
                                                    ),
                                              if (isSel)
                                                Positioned(
                                                  right: -2, bottom: -2,
                                                  child: Container(
                                                    width: 16, height: 16,
                                                    decoration: const BoxDecoration(
                                                      color: _C.accent, shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.check, color: Colors.white, size: 10,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            app.name ?? '',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              color: isSel ? _C.chipLavender : _C.muted,
                                              fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: _C.border, width: .8)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.accent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Done — ${_selectedPackages.length} selected',
                          style: const TextStyle(
                            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
              const Gap(12),
              _buildSessionNameCard(),
              const Gap(10),
              _buildScheduleCard(),
              const Gap(10),
              _buildTimeCard(),
              const Gap(10),
              _buildAppsCard(),
              const Gap(16),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: _C.accent, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.timer_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lock Session',
                    style: GoogleFonts.dmSans(
                      fontSize: 18, fontWeight: FontWeight.w700, color: _C.text,
                    )),
                const SizedBox(height: 3),
                Text('Choose exactly which apps to block and when.',
                    style: GoogleFonts.dmSans(fontSize: 12, color: _C.muted, height: 1.4)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _C.greenSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.green.withOpacity(.4), width: .8),
                  ),
                  child: const Text(
                    'Custom block list',
                    style: TextStyle(
                      fontFamily: 'monospace', fontSize: 11,
                      color: _C.green, fontWeight: FontWeight.w700,
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

  Widget _buildSessionNameCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('Session Name'),
          const SizedBox(height: 8),
          TextField(
            controller: _sessionNameController,
            style: const TextStyle(color: _C.text, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Name this session…',
              hintStyle: const TextStyle(color: _C.muted),
              filled: true,
              fillColor: _C.surface2,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                borderSide: const BorderSide(color: _C.accent, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('One-time schedule',
                  style: GoogleFonts.dmSans(fontSize: 14, color: _C.text)),
              Switch(
                value: _isOneTime,
                activeThumbColor: _C.accent,
                inactiveTrackColor: _C.surface2,
                onChanged: (v) => setState(() {
                  _isOneTime = v;
                  _weekdays = v ? {} : {1, 2, 3, 4, 5, 6, 7};
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Label(_isOneTime ? 'Start Date' : 'Schedule Days'),
          const SizedBox(height: 8),
          _isOneTime ? _buildDatePicker() : _buildDayChips(),
        ],
      ),
    );
  }

  Widget _buildDayChips() {
    return Wrap(
      spacing: 6, runSpacing: 6,
      children: List.generate(7, (i) {
        final day = i + 1;
        final on = _weekdays.contains(day);
        return GestureDetector(
          onTap: () => setState(() => on ? _weekdays.remove(day) : _weekdays.add(day)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: on ? _C.chipOn : _C.chipOff,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: on ? _C.accent : _C.border, width: on ? 1.2 : .8),
            ),
            child: Text(
              _dayLabels[i],
              style: TextStyle(
                fontFamily: 'monospace', fontSize: 12,
                color: on ? _C.chipLavender : _C.muted,
                fontWeight: on ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _C.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border, width: .8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: _C.accent, size: 16),
            const SizedBox(width: 10),
            Text(_fmtDate(_scheduleDate),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14, color: _C.text)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('Block Window'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _timeTile('Start', _fmtTime(_start), () => _pickTime(true))),
              const SizedBox(width: 8),
              Expanded(child: _timeTile('End', _fmtTime(_end), () => _pickTime(false))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeTile(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _C.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border, width: .8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: _C.muted)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                  fontFamily: 'monospace', fontSize: 16,
                  color: _C.accent, fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAppsCard() {
    final selectedApps = _allApps
        .where((a) => _selectedPackages.contains(a.packageName))
        .toList();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _Label('Apps to Block'),
              GestureDetector(
                onTap: _showAppsModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.accent, borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _selectedPackages.isNotEmpty ? 'EDIT' : 'ADD',
                    style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 11,
                      color: Colors.white, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _selectedPackages.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: _C.border, width: .8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.apps_outlined, color: _C.muted, size: 28),
                      const SizedBox(height: 6),
                      Text('No apps selected',
                          style: TextStyle(color: _C.muted, fontSize: 13)),
                    ],
                  ),
                )
              : Wrap(
                  spacing: 8, runSpacing: 8,
                  children: selectedApps.map((app) {
                    return Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: _C.surface2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _C.border, width: .8),
                      ),
                      child: Column(
                        children: [
                          app.icon != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(app.icon!, width: 36, height: 36),
                                )
                              : const Icon(Icons.android, color: _C.muted, size: 36),
                          const SizedBox(height: 4),
                          Text(
                            app.name ?? '',
                            style: const TextStyle(fontSize: 9, color: _C.muted),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.accent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          'Add Session',
          style: GoogleFonts.dmSans(
            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
          ),
        ),
      ),
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
          BoxShadow(color: Color(0x0A7C3AED), blurRadius: 8, offset: Offset(0, 2)),
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
        fontFamily: 'monospace', fontSize: 10,
        letterSpacing: 1.2, color: _C.muted,
      ),
    );
  }
}