import 'package:app_blocker/app_blocker.dart' hide AppInfo;
import 'package:block_apps/utils/blocker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// ─── Design tokens (light purple theme) ──────────────────────────────────────
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
  static const chipOff = Color(0xFFF5F3FF);
  static const chipOn = Color(0xFFEDE9FE);
}

class StrictModePage extends StatefulWidget {
  const StrictModePage({super.key});

  @override
  State<StrictModePage> createState() => _StrictModePageState();
}

class _StrictModePageState extends State<StrictModePage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _hoursCtrl = TextEditingController();
  final TextEditingController _minutesCtrl = TextEditingController();

  List<AppInfo> _allApps = [];
  bool _loading = false;

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
        .where((a) => a.name?.trim() != 'Block Apps')
        .map((a) => a.packageName!)
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

  // ── validation + confirm dialog ────────────────────────────────────────────
  void _onStartPressed() {
    final hours = int.tryParse(_hoursCtrl.text) ?? 0;
    final minutes = int.tryParse(_minutesCtrl.text) ?? 0;

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

    final durText =
        '${hours > 0 ? '$hours hr ' : ''}${minutes > 0 ? '$minutes min' : ''}';

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
                'Once started, all apps will be blocked for $durText. You won\'t be able to undo this during the session.',
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

  // ── header ─────────────────────────────────────────────────────────────────
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
                    style: _mono(size: 11, color: _C.red, fw: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── session name ───────────────────────────────────────────────────────────
  Widget _buildNameCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Session Name'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: _C.text, fontSize: 15),
            decoration: _inputDeco(
              'Name this session…',
              suffix: ValueListenableBuilder(
                valueListenable: _nameCtrl,
                builder: (_, v, __) => v.text.isNotEmpty
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

  // ── duration ───────────────────────────────────────────────────────────────
  Widget _buildDurationCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Session Duration'),
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
                  style: const TextStyle(color: _C.text, fontSize: 15),
                  decoration: _inputDeco('Hours'),
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
                  style: const TextStyle(color: _C.text, fontSize: 15),
                  decoration: _inputDeco('Minutes'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Live preview pill
          ValueListenableBuilder(
            valueListenable: _hoursCtrl,
            builder: (_, __, ___) => ValueListenableBuilder(
              valueListenable: _minutesCtrl,
              builder: (_, ___, ____) {
                final h = int.tryParse(_hoursCtrl.text) ?? 0;
                final m = int.tryParse(_minutesCtrl.text) ?? 0;
                if (h == 0 && m == 0) return const SizedBox.shrink();
                final label = '${h > 0 ? '$h hr ' : ''}${m > 0 ? '$m min' : ''}'
                    .trim();
                return Container(
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
                        'Block for $label',
                        style: _mono(
                          size: 12,
                          color: _C.accent,
                          fw: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── info card ──────────────────────────────────────────────────────────────
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
                style: _mono(size: 11, color: _C.red, fw: FontWeight.w700),
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

  // ── stop card ──────────────────────────────────────────────────────────────
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

  // ── start button ───────────────────────────────────────────────────────────
  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _onStartPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.red,
          disabledBackgroundColor: _C.redSoft,
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
                  const Icon(Icons.lock_outline, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Start Strict Block',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD6FE), width: .8),
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
        color: Color(0xFF8B85C1),
      ),
    );
  }
}
