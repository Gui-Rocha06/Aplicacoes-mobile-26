import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0B5CAD);
  static const primaryDark = Color(0xFF083D75);
  static const accent = Color(0xFFFF6B4A);
  static const background = Color(0xFFF4F7FB);
  static const textDark = Color(0xFF1B2733);
  static const textMuted = Color(0xFF6B7A8C);
  static const success = Color(0xFF1FA971);
  static const border = Color(0xFFE2E8F0);
  static const highlight = Color(0xFFEAF2FB);

  static const gradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6)),
  ];
}