import 'package:app_blocker/app_blocker.dart' hide AppInfo;
import 'package:block_apps/constants/colors.dart';
import 'package:block_apps/utils/blocker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

// ─── Design tokens (light purple theme) ──────────────────────────────────────
class _C {
  static const bg = Color(0xFFF5F3FF); // soft lavender page bg
  static const surface = Color(0xFFFFFFFF); // white cards
  static const surface2 = Color(0xFFF0EDFF); // tinted input bg
  static const border = Color(0xFFDDD6FE); // light purple border
  static const accent = Color.fromARGB(255, 68, 27, 139); // purple — unchanged
  static const accentSoft = Color(0xFFEDE9FE); // very light purple tint
  static const accentMid = Color(0xFFDDD6FE); // chip selected bg
  static const green = Color(0xFF059669); // emerald (visible on light)
  static const greenSoft = Color(0xFFD1FAE5); // light green bg
  static const text = Color(0xFF1E1B4B); // deep indigo text
  static const muted = Color(0xFF8B85C1); // muted purple-gray
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEE2E2);
  static const chipOff = Color(0xFFF5F3FF);
  static const chipOn = Color(0xFFEDE9FE);
  static const chipLavender = Color(0xFF6D28D9); // dark purple text on chip
}

class LockSessionPage extends StatefulWidget {
  const LockSessionPage({super.key});

  @override
  State<LockSessionPage> createState() => _LockSessionPageState();
}

class _LockSessionPageState extends State<LockSessionPage> {
  final TextEditingController _sessionNameController = TextEditingController();
  final TextEditingController _modalSearchController = TextEditingController();

  bool _isOneTime = false;
  final List<String> _dayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  Set<int> _weekdays = {1, 2, 3, 4, 5, 6, 7};
  DateTime _scheduleDate = DateTime.now();
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 17, minute: 0);
  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];
  Set<String> _selectedPackages = {};
  bool _loadingApps = false;

  // ── helpers ────────────────────────────────────────────────────────────────
  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

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

  // ── pickers ────────────────────────────────────────────────────────────────
  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      builder: (ctx, child) => _darkTimePicker(ctx, child),
    );
    if (picked != null) {
      setState(() => isStart ? _start = picked : _end = picked);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduleDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => _darkDatePicker(ctx, child),
    );
    if (picked != null) setState(() => _scheduleDate = picked);
  }

  Widget _darkTimePicker(BuildContext ctx, Widget? child) => Theme(
    data: ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: _C.accent,
        onPrimary: Colors.white,
        surface: _C.surface,
      ),
    ),
    child: child!,
  );

  Widget _darkDatePicker(BuildContext ctx, Widget? child) => Theme(
    data: ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: _C.accent,
        onPrimary: Colors.white,
        surface: _C.surface,
      ),
    ),
    child: child!,
  );

  // ── apps ───────────────────────────────────────────────────────────────────
  Future<void> _getApps() async {
    if (_allApps.isNotEmpty) return; // already loaded
    setState(() => _loadingApps = true);
    try {
      final list = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        withIcon: true,
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

  void _filterApps(String query) {
    setState(() {
      _filteredApps = query.isEmpty
          ? List.from(_allApps)
          : _allApps
                .where(
                  (a) => a.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
    });
  }

  // ── submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    final name = _sessionNameController.text.trim();
    if (name.isEmpty) {
      _snack('Please enter a session name');
      return;
    }
    if (_selectedPackages.isEmpty) {
      _snack('Please add apps to block');
      return;
    }
    if (!_isOneTime && _weekdays.isEmpty) {
      _snack('Select at least one day');
      return;
    }

    final startMinutes = _start.hour * 60 + _start.minute;
    final endMinutes = _end.hour * 60 + _end.minute;
    if (endMinutes <= startMinutes) {
      _snack('End time must be after start time');
      return;
    }

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
    setState(() {
      _sessionNameController.clear();
      _selectedPackages = {};
    });
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

  // ── modal ──────────────────────────────────────────────────────────────────
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
                  // handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _C.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'SELECT APPS TO BLOCK',
                    style: _mono(size: 11, color: _C.muted),
                  ),
                  const SizedBox(height: 12),
                  // search
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
                                    .where(
                                      (a) => a.name.toLowerCase().contains(
                                        q.toLowerCase(),
                                      ),
                                    )
                                    .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search apps…',
                        hintStyle: const TextStyle(
                          color: _C.muted,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: _C.muted,
                          size: 18,
                        ),
                        filled: true,
                        fillColor: _C.surface2,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _C.border,
                            width: .8,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _C.border,
                            width: .8,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _C.accent,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // grid
                  Expanded(
                    child: _loadingApps
                        ? const Center(
                            child: CircularProgressIndicator(color: _C.accent),
                          )
                        : _filteredApps.isEmpty
                        ? Center(
                            child: Text(
                              'No apps found',
                              style: TextStyle(color: _C.muted),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 6,
                                  mainAxisSpacing: 6,
                                  childAspectRatio: .8,
                                ),
                            itemCount: _filteredApps.length,
                            itemBuilder: (ctx, i) {
                              final app = _filteredApps[i];
                              final isSel = _selectedPackages.contains(
                                app.packageName,
                              );
                              return GestureDetector(
                                onTap: () {
                                  setM(() {
                                    isSel
                                        ? _selectedPackages.remove(
                                            app.packageName,
                                          )
                                        : _selectedPackages.add(
                                            app.packageName,
                                          );
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
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.memory(
                                                    app.icon!,
                                                    width: 40,
                                                    height: 40,
                                                  ),
                                                )
                                              : Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: _C.border,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.android,
                                                    color: _C.muted,
                                                    size: 22,
                                                  ),
                                                ),
                                          if (isSel)
                                            Positioned(
                                              right: -2,
                                              bottom: -2,
                                              child: Container(
                                                width: 16,
                                                height: 16,
                                                decoration: const BoxDecoration(
                                                  color: _C.accent,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 10,
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
                                          color: isSel
                                              ? _C.chipLavender
                                              : _C.muted,
                                          fontWeight: isSel
                                              ? FontWeight.w600
                                              : FontWeight.normal,
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
                  // footer
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: _C.border, width: .8),
                      ),
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
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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

  // ── header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _C.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lock Session',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _C.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Choose exactly which apps to block and when.',
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
                    color: _C.greenSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _C.green.withOpacity(.4),
                      width: .8,
                    ),
                  ),
                  child: Text(
                    'Custom block list',
                    style: _mono(
                      size: 11,
                      color: _C.green,
                      fw: FontWeight.w700,
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

  // ── session name ───────────────────────────────────────────────────────────
  Widget _buildSessionNameCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Session Name'),
          const SizedBox(height: 8),
          TextField(
            controller: _sessionNameController,
            style: const TextStyle(color: _C.text, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Name this session…',
              hintStyle: const TextStyle(color: _C.muted),
              filled: true,
              fillColor: _C.surface2,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
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

  // ── schedule card ──────────────────────────────────────────────────────────
  Widget _buildScheduleCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'One-time schedule',
                style: GoogleFonts.dmSans(fontSize: 14, color: _C.text),
              ),
              Switch(
                value: _isOneTime,
                activeThumbColor: _C.accent,
                inactiveTrackColor: _C.surface2,
                onChanged: (v) => setState(() {
                  _isOneTime = v;
                  if (v) {
                    _weekdays = {};
                  } else {
                    _weekdays = {1, 2, 3, 4, 5, 6, 7};
                  }
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
      spacing: 6,
      runSpacing: 6,
      children: List.generate(7, (i) {
        final day = i + 1;
        final on = _weekdays.contains(day);
        return GestureDetector(
          onTap: () =>
              setState(() => on ? _weekdays.remove(day) : _weekdays.add(day)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: on ? _C.chipOn : _C.chipOff,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: on ? _C.accent : _C.border,
                width: on ? 1.2 : .8,
              ),
            ),
            child: Text(
              _dayLabels[i],
              style: _mono(
                size: 12,
                color: on ? _C.chipLavender : _C.muted,
                fw: on ? FontWeight.w700 : FontWeight.normal,
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
            const Icon(
              Icons.calendar_today_outlined,
              color: _C.accent,
              size: 16,
            ),
            const SizedBox(width: 10),
            Text(
              _fmtDate(_scheduleDate),
              style: _mono(size: 14, color: _C.text),
            ),
          ],
        ),
      ),
    );
  }

  // ── time card ──────────────────────────────────────────────────────────────
  Widget _buildTimeCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Block Window'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _TimeTile(
                  'Start',
                  _fmtTime(_start),
                  () => _pickTime(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TimeTile('End', _fmtTime(_end), () => _pickTime(false)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _TimeTile(String label, String value, VoidCallback onTap) {
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
            Text(label.toUpperCase(), style: _mono(size: 9, color: _C.muted)),
            const SizedBox(height: 4),
            Text(
              value,
              style: _mono(size: 16, color: _C.accent, fw: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  // ── apps card ──────────────────────────────────────────────────────────────
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
              _Label('Apps to Block'),
              GestureDetector(
                onTap: _showAppsModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _C.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _selectedPackages.isNotEmpty ? 'EDIT' : 'ADD',
                    style: _mono(
                      size: 11,
                      color: Colors.white,
                      fw: FontWeight.w700,
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
                      const Icon(
                        Icons.apps_outlined,
                        color: _C.muted,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No apps selected',
                        style: TextStyle(color: _C.muted, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedApps.map((app) {
                    return Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
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
                                  child: Image.memory(
                                    app.icon!,
                                    width: 36,
                                    height: 36,
                                  ),
                                )
                              : const Icon(
                                  Icons.android,
                                  color: _C.muted,
                                  size: 36,
                                ),
                          const SizedBox(height: 4),
                          Text(
                            app.name ?? '',
                            style: const TextStyle(
                              fontSize: 9,
                              color: _C.muted,
                            ),
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

  // ── submit ─────────────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.accent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          'Add Session',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
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
        boxShadow: [
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
