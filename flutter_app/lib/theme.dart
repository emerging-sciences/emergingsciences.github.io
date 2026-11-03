import 'package:flutter/material.dart';

/// Colours (same palette as the website, with a pure black background).
class C {
  static const Color bg = Color(0xFF000000);
  static const Color surface = Color(0xFF0D0F14);
  static const Color surface2 = Color(0xFF151821);
  static const Color border = Color(0x1FFFFFFF);
  static const Color text = Color(0xFFECEEF5);
  static const Color text2 = Color(0xFFA6ABBE);
  static const Color text3 = Color(0xFF737891);
  static const Color blue = Color(0xFF4F8CFF);
  static const Color green = Color(0xFF34D399);
  static const Color orange = Color(0xFFFBBF24);
  static const Color red = Color(0xFFF87171);
}

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    primary: C.blue,
    secondary: C.green,
    surface: C.surface,
    onSurface: C.text,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.bg,
    canvasColor: C.bg,
  );
}

/// "#4F8CFF" -> Color (falls back when the text is not a 6-digit hex colour).
Color hexColor(String hex, Color fallback) {
  var h = hex.trim();
  if (h.startsWith('#')) h = h.substring(1);
  if (h.length != 6) return fallback;
  final v = int.tryParse(h, radix: 16);
  if (v == null) return fallback;
  return Color(0xFF000000 | v);
}

const TextStyle kTitle = TextStyle(color: C.text, fontSize: 15, fontWeight: FontWeight.w600, height: 1.3);
const TextStyle kBody = TextStyle(color: C.text2, fontSize: 13, height: 1.35);
const TextStyle kSmall = TextStyle(color: C.text3, fontSize: 12, height: 1.3);
const TextStyle kH1 = TextStyle(color: C.text, fontSize: 22, fontWeight: FontWeight.w700, height: 1.25);
