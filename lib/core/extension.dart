import 'package:flutter/material.dart';

/// Extension buat akses cepat ke color palette lewat context.color
extension ColorSchemeExtension on BuildContext {
  AppColors get color => AppColors();
}

/// Kumpulan warna custom sesuai palet
class AppColors {
  // Warna utama dari palet
  final Color primary = const Color(0xFFFEC325);
  final Color secondary = const Color(0xFFF1D384);

  // Warna tambahan buat teks dan background
  final Color lavenderText = const Color(0xFF5B4C9A);
  final Color backgroundLight = const Color(0xFFF7F3FF);
  final Color accentMango = const Color(0xFFFDD67A);
}
