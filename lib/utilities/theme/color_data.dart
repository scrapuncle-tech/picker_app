import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme_provider.dart';

class CustomColorData {
  final Color Function([double?]) fontColor;
  final Color Function([double?]) primaryColor;
  final Color Function([double?]) secondaryColor;
  final Color Function([double?]) backgroundColor;
  final Color Function([double?]) highlightColor;
  final Color Function([double?]) inactiveColor;

  final Color gradientColor2 = Color(0xFF2274FC);

  final Color gradientColor1 = Color(0xFF3BB8F6);

  final List<List<Color>> colorSets = [
    // Red shades
    [const Color(0xFFFFCDD2), const Color(0xFFE57373), const Color(0xFFD32F2F)],

    // Green shades
    [const Color(0xFFC8E6C9), const Color(0xFF81C784), const Color(0xFF388E3C)],

    // Blue shades
    [const Color(0xFFBBDEFB), const Color(0xFF64B5F6), const Color(0xFF1976D2)],

    // Purple shades
    [const Color(0xFFE1BEE7), const Color(0xFFBA68C8), const Color(0xFF7B1FA2)],

    // Orange shades
    [const Color(0xFFFFE0B2), const Color(0xFFFFB74D), const Color(0xFFF57C00)],

    // Teal shades
    [const Color(0xFFB2DFDB), const Color(0xFF4DB6AC), const Color(0xFF00796B)],

    // Pink shades
    [const Color(0xFFF8BBD0), const Color(0xFFF06292), const Color(0xFFC2185B)],

    // Yellow shades
    [const Color(0xFFFFF9C4), const Color(0xFFFFF176), const Color(0xFFFBC02D)],
  ];

  CustomColorData({
    required this.fontColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.highlightColor,
    required this.inactiveColor,
  });

  factory CustomColorData.from(WidgetRef ref) {
    Map<ThemeMode, Color> themeMap = ref.watch(themeProvider);
    ThemeMode themeMode = themeMap.keys.first;
    bool isDark = themeMode == ThemeMode.dark;
    Color statePrimaryColor = themeMap.values.first;

    Color fontColor([double? alpha]) =>
        isDark
            ? Colors.white.withAlpha(
              alpha != null ? (alpha * 255).toInt() : 255,
            )
            : const Color(
              0XFF1C2136,
            ).withAlpha(alpha != null ? (alpha * 255).toInt() : 255);

    Color primaryColor([double? alpha]) => statePrimaryColor.withAlpha(
      alpha != null ? (alpha * 255).toInt() : 255,
    );

    Color secondaryColor([double? alpha]) =>
        isDark
            ? const Color(
              0XFF333354,
            ).withAlpha(alpha != null ? (alpha * 255).toInt() : 255)
            : const Color(
              0XFFF2F3F6,
            ).withAlpha(alpha != null ? (alpha * 255).toInt() : 255);

    Color backgroundColor([double? alpha]) =>
        isDark
            ? const Color(
              0XFF22223D,
            ).withAlpha(alpha != null ? (alpha * 255).toInt() : 255)
            : const Color.fromARGB(
              255,
              255,
              255,
              255,
            ).withAlpha(alpha != null ? (alpha * 255).toInt() : 255);

    Color highlightColor([double? alpha]) => const Color(
      0XFF1A1B27,
    ).withAlpha(alpha != null ? (alpha * 255).toInt() : 255);

    Color inactiveColor([double? alpha]) =>
        isDark
            ? const Color(
              0XFF4D4D4D,
            ).withAlpha(alpha != null ? (alpha * 255).toInt() : 255)
            : const Color(
              0XFFBBBBBB,
            ).withAlpha(alpha != null ? (alpha * 255).toInt() : 255);

    return CustomColorData(
      fontColor: fontColor,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      backgroundColor: backgroundColor,
      highlightColor: highlightColor,
      inactiveColor: inactiveColor,
    );
  }
}
