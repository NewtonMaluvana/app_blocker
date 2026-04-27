import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design tokens (light purple theme) ──────────────────────────────────────
class _C {
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF0EDFF);
  static const border = Color(0xFFEDE9FE);
  static const accent = Color(0xFF7C3AED);
  static const accentLight = Color(0xFFA78BFA);
  static const accentSoft = Color(0xFFEDE9FE);
  static const text = Color(0xFF1E1B4B);
  static const muted = Color(0xFF8B85C1);
}

class AppUsageCard extends StatefulWidget {
  final String appName;
  final Uint8List icon;
  final String time;
  final String date;

  /// Optional: rank label e.g. "Most used today", "2nd most used"
  final String? subtitle;

  const AppUsageCard({
    super.key,
    required this.appName,
    required this.icon,
    required this.time,
    required this.date,
    this.subtitle,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: _C.accent.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── left gradient accent bar ─────────────────────────────────
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_C.accent, _C.accentLight],
                  ),
                ),
              ),

              // ── content ───────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // app icon
                      Container(
                        width: 46,
                        height: 46,
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: _C.accentSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _C.border, width: 1),
                        ),
                        child: Image.memory(widget.icon, fit: BoxFit.contain),
                      ),

                      const SizedBox(width: 12),

                      // name + subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.appName,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _C.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                widget.subtitle!,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: _C.muted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // time + date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.time,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _C.accent,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.date,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: _C.muted,
                            ),
                          ),
                        ],
                      ),

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
