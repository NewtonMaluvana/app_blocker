import 'package:block_apps/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

// ─── Design tokens (light purple theme) ──────────────────────────────────────
class _C {
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF0EDFF);
  static const border = Color(0xFFDDD6FE);
  static const accent = Color(0xFF7C3AED);
  static const accentSoft = Color(0xFFEDE9FE);
  static const text = Color(0xFF1E1B4B);
  static const muted = Color(0xFF8B85C1);
  static const green = Color(0xFF059669);
  static const greenSoft = Color(0xFFD1FAE5);
  static const greenBorder = Color(0xFF6EE7B7);
  static const red = Color(0xFFDC2626);
  static const redSoft = Color(0xFFFEE2E2);
  static const redBorder = Color(0xFFFCA5A5);
  static const blue = Color(0xFF2563EB);
  static const blueSoft = Color(0xFFEFF6FF);
  static const blueBorder = Color(0xFF93C5FD);
}

class LockSessionCard extends StatefulWidget {
 
  final String time;
  final List<String> apps;

  const LockSessionCard({
    super.key,
    
    required this.time, required this.apps,
  });

  @override
  State<LockSessionCard> createState() => _StrictModeCardState();
}

class _StrictModeCardState extends State<LockSessionCard> {
  late Stream<int> _timerStream;
  final TimeOfDay _endTime = const TimeOfDay(hour: 2, minute: 0);
  List<AppInfo> _allapps = [];
  List<String> appsName = [];
  // ── timer helpers ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _getApps();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
  }

  TextStyle _mono({
    double size = 12,
    Color? color,
    FontWeight fw = FontWeight.normal,
  }) => TextStyle(
    fontFamily: 'monospace',
    fontSize: size,
    color: color ?? _C.text,
    fontWeight: fw,
  );

  Future<void> _getApps() async {
    try {
      final list = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        withIcon: true,
      );
      setState(() {
        _allapps = list;
        for (var va in widget.apps) {}
      });
    } catch (e) {}
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _timerStream,
      builder: (context, snapshot) {
        
      

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.border, width: .8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A7C3AED),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── blue top accent bar ──────────────────────────────────
                Container(height: 4, color: _C.blue),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── row 1: icon + title + countdown ─────────────────
                      Row(
                        children: [
                          // icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _C.redSoft,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _C.redBorder,
                                width: .8,
                              ),
                            ),
                            child: const Icon(
                              Icons.timer_outlined,
                              color: _C.red,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),

                          // title + active badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lock session',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _C.text,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: _C.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Active now',
                                      style: _mono(
                                        size: 10,
                                        color: _C.green,
                                        fw: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // countdown pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _C.blueSoft,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _C.blueBorder,
                                width: .8,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'remaining',
                                  style: _mono(size: 9, color: _C.blue),
                                ),
                                Text(
                                  widget.time,
                                  style: _mono(
                                    size: 14,
                                    color: _C.blue,
                                    fw: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ── progress bar ───────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: 100,
                                minHeight: 6,
                                backgroundColor: _C.blueSoft,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  _C.blue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '90%',
                            style: _mono(
                              size: 11,
                              color: _C.blue,
                              fw: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ── divider ────────────────────────────────────────
                      const Divider(color: _C.border, thickness: .8, height: 1),

                      const SizedBox(height: 12),

                      // ── phone status ───────────────────────────────────
                      Row(
                        children: [
                          const Icon(
                            Icons.smartphone,
                            size: 14,
                            color: _C.muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'APPS BLOCKED',
                            style: _mono(
                              size: 10,
                              color: _C.muted,
                              fw: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      Gap(8),

                      Container(
                        height: 50,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _C.redSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _C.redBorder, width: .8),
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.apps.length,
                          itemBuilder: (context, index) {
                            return Chip(
                              label: Text(
                                style: TextStyle(color: color.btnColor),
                                _allapps
                                    .where(
                                      (i) =>
                                          i.packageName.toLowerCase() ==
                                          widget.apps[index].toLowerCase(),
                                    )
                                    .map((i) => i.name)
                                    .toString(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── date ──────────────────────────────────────────
                     
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
