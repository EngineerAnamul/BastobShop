import 'package:flutter/material.dart';

class AppColors {
  // static const Color primary = Color(0xFF25A3E4); // Deep Purple
  static const Color primary = Color(0xFF25A3E4); // Deep Purple
  static const Color white = Color(0xFFFFFFFF); // Orange
  static const Color secondary = Color(0xFFFFA726); // Orange
  // static const Color background = Color(0xFFF5F5F5); // Light Grey
  static const Color background = Color(0xFFF1F4F8); // Light Grey
  static const Color body = Color(0xF5F5F5FF); // Light Grey
  static const Color textDark = Color(0xFF212121); // Dark Text
  static const Color textLight = Color(0xFFFFFFFF); // White Text


  // লোগোর অরিজিনাল কালারগুলো এখানে ভেরিয়েবল হিসেবে রাখা হলো
  static const Color logoOrange = Color(0xFFF9881F);
  static const Color logoYellowGreen = Color(0xFF90C12B);
  static const Color logoGreen = Color(0xFF28A745);
  static const Color logoBlue = Color(0xFF25A3E4);


// লোগো গ্রেডিয়েন্ট ফাংশন
  static Shader logoShader(Rect bounds) {
    return const LinearGradient(
      colors: [logoOrange, logoYellowGreen, logoGreen, logoBlue],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(bounds);
  }
}
