import 'package:flutter/material.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5EFE6); // warm beige
  static const Color surface = Color(0xFFFFFFFF); // white cards
  static const Color primary = Color(0xFF5C3D2E); // deep brown
  static const Color primaryLight = Color(0xFF8B6351); // medium brown
  static const Color accent = Color(0xFFC9A87C); // gold-tan accent
  static const Color dark = Color(0xFF1C1008); // near-black
  static const Color muted = Color(0xFF9E8A7A); // muted brown-grey
  static const Color divider = Color(0xFFE8DDD4); // light beige divider

  // ── Text Styles ──────────────────────────────────────────────────────────
  static const TextStyle heading = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: dark,
    letterSpacing: 0.3,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: dark,
    letterSpacing: 0.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: muted,
    height: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    color: muted,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w500,
  );

  // ── Decoration helpers ───────────────────────────────────────────────────
  static BoxDecoration card({double radius = 20}) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: primary.withOpacity(0.07),
        blurRadius: 16,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static BoxDecoration primaryCard({double radius = 20}) => BoxDecoration(
    color: primary,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: primary.withOpacity(0.3),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static InputDecoration inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: muted, fontSize: 14),
        prefixIcon: Icon(icon, color: accent, size: 20),
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: divider, width: 1),
        ),
      );
}
