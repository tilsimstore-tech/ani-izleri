import 'package:flutter/material.dart';

class AppTheme {
  final String key;
  final String name;
  final Color bg;
  final Color panel;
  final Color ink;
  final Color soft;
  final Color line;
  final Color gold;
  final Color goldDeep;
  final Color accent;
  final Color tape;

  const AppTheme({
    required this.key,
    required this.name,
    required this.bg,
    required this.panel,
    required this.ink,
    required this.soft,
    required this.line,
    required this.gold,
    required this.goldDeep,
    required this.accent,
    required this.tape,
  });
}

const Map<String, AppTheme> kThemes = {
  'mavi': AppTheme(
    key: 'mavi', name: 'Bebe Mavisi',
    bg: Color(0xFFEAF1F6), panel: Color(0xFFFBFDFE), ink: Color(0xFF3A4651),
    soft: Color(0xFF6E8092), line: Color(0xFFD6E2EA), gold: Color(0xFF8FB3CC),
    goldDeep: Color(0xFF6E97B5), accent: Color(0xFFA9C9DE), tape: Color(0xFFA9C9DE),
  ),
  'gul': AppTheme(
    key: 'gul', name: 'Gül',
    bg: Color(0xFFF6ECEA), panel: Color(0xFFFFFAF9), ink: Color(0xFF4A3A38),
    soft: Color(0xFF9A7872), line: Color(0xFFEAD7D2), gold: Color(0xFFC99A90),
    goldDeep: Color(0xFFB07C72), accent: Color(0xFFD9B3AB), tape: Color(0xFFD9B3AB),
  ),
  'altin': AppTheme(
    key: 'altin', name: 'Altın',
    bg: Color(0xFFF7F1E8), panel: Color(0xFFFFFDF9), ink: Color(0xFF4A4036),
    soft: Color(0xFF8C7B66), line: Color(0xFFE6DBC9), gold: Color(0xFFB79866),
    goldDeep: Color(0xFF9A7D4E), accent: Color(0xFFC9AE84), tape: Color(0xFFC9AE84),
  ),
  'seftali': AppTheme(
    key: 'seftali', name: 'Şeftali',
    bg: Color(0xFFF8EEE6), panel: Color(0xFFFFFAF6), ink: Color(0xFF4E3F36),
    soft: Color(0xFF9A7E6C), line: Color(0xFFEBD9CC), gold: Color(0xFFD6A07A),
    goldDeep: Color(0xFFBF8460), accent: Color(0xFFE8C0A3), tape: Color(0xFFE8C0A3),
  ),
  'yesil': AppTheme(
    key: 'yesil', name: 'Adaçayı',
    bg: Color(0xFFEEF0E8), panel: Color(0xFFFBFCF8), ink: Color(0xFF3E463A),
    soft: Color(0xFF6E7A63), line: Color(0xFFDBE0D0), gold: Color(0xFF9AA77F),
    goldDeep: Color(0xFF7E8C63), accent: Color(0xFFAEB994), tape: Color(0xFFAEB994),
  ),
  'lavanta': AppTheme(
    key: 'lavanta', name: 'Lavanta',
    bg: Color(0xFFF0ECF5), panel: Color(0xFFFCFAFE), ink: Color(0xFF463E52),
    soft: Color(0xFF7E7290), line: Color(0xFFE0D8EA), gold: Color(0xFFA593C0),
    goldDeep: Color(0xFF8A77A8), accent: Color(0xFFC3B4D8), tape: Color(0xFFC3B4D8),
  ),
  'karanlik': AppTheme(
    key: 'karanlik', name: 'Gece',
    bg: Color(0xFF211E1A), panel: Color(0xFF2B2722), ink: Color(0xFFEDE3D2),
    soft: Color(0xFFB6A78E), line: Color(0xFF3A352D), gold: Color(0xFFCBA86E),
    goldDeep: Color(0xFFB8965A), accent: Color(0xFF8C7B5E), tape: Color(0xFF8C7B5E),
  ),
};
