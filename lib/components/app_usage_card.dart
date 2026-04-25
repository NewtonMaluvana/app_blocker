import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design tokens (light purple theme) ──────────────────────────────────────
class _C {
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF0EDFF);
  static const border = Color(0xFFDDD6FE);
  static const accent = Color(0xFF7C3AED);
  static const accentSoft = Color(0xFFEDE9FE);
  static const text = Color(0xFF1E1B4B);
  static const muted = Color(0xFF8B85C1);
}

class AppUsageCard extends StatefulWidget {
  final String appName;
  final Uint8List icon;
  final String time;
  final String date;

  const AppUsageCard({
    super.key,
    required this.appName,
    required this.icon,
    required this.time,
    required this.date,
  });

  @override
  State<AppUsageCard> createState() => _AppUsageCardState();
}

class _AppUsageCardState extends State<AppUsageCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // ── left purple accent bar ─────────────────────────────────────
            Container(width: 4, height: 70, color: _C.accent),

            // ── app icon ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _C.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.border, width: .8),
                ),
                child: Image.memory(widget.icon, fit: BoxFit.contain),
              ),
            ),

            // ── app name ───────────────────────────────────────────────────
            Expanded(
              child: Text(
                widget.appName,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── time + date ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.time,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.date,
                    style: GoogleFonts.dmSans(fontSize: 11, color: _C.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
