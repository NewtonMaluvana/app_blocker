import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design tokens (light purple theme) ──────────────────────────────────────
class _C {
  static const bg = Color(0xFFF5F3FF);
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
}

class SessionCard extends StatefulWidget {
  final String date;
  final String time;
  final IconData icon;

  /// 0.0 – 1.0 fraction of the session elapsed

  /// Optional: callback when Edit is tapped
  final VoidCallback? onEdit;

  const SessionCard({
    super.key,
    required this.date,
    required this.time,
    required this.icon,

    this.onEdit,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
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

  @override
  Widget build(BuildContext context) {
   

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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── row 1: icon + title/date + time pill + settings ────────────
            Row(
              children: [
                // icon circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _C.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border, width: .8),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: _C.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),

                // title + date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Focus Session',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.date,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: _C.muted,
                        ),
                      ),
                    ],
                  ),
                ),

                // time pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _C.accentSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.border, width: .8),
                  ),
                  child: Text(
                    widget.time,
                    style: _mono(
                      size: 12,
                      color: _C.accent,
                      fw: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // settings button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _C.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.border, width: .8),
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: _C.muted,
                    size: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── progress bar ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 2,
                      minHeight: 6,
                      backgroundColor: _C.accentSoft,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        _C.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '90%',
                  style: _mono(size: 11, color: _C.accent, fw: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── row 3: extra icon + edit button ────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // extra icon tile (the `icon` param)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _C.accentSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.border, width: .8),
                  ),
                  child: Icon(widget.icon, color: _C.accent, size: 18),
                ),

                // edit button
                GestureDetector(
                  onTap: widget.onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
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
                          Icons.edit_outlined,
                          color: _C.accent,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Edit',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
