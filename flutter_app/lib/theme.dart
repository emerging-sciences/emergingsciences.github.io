import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dark / light choice. Same idea (and same saved key, "es_theme") as the website's sun/moon button.
class ThemeState extends ChangeNotifier {
  bool _light = false;
  bool get light => _light;

  /// Reads the saved choice. Called once before the first frame so there is no flash.
  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      _light = p.getString('es_theme') == 'light';
    } catch (_) {}
  }

  Future<void> setLight(bool value) async {
    if (value == _light) return;
    _light = value;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('es_theme', value ? 'light' : 'dark');
    } catch (_) {}
  }

  Future<void> toggle() => setLight(!_light);
}

final ThemeState themeState = ThemeState();

class _Palette {
  final Color bg, surface, surface2, border, text, text2, text3, blue, green, orange, red;
  const _Palette({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text,
    required this.text2,
    required this.text3,
    required this.blue,
    required this.green,
    required this.orange,
    required this.red,
  });
}

// Dark: website palette with a pure black background.
const _Palette _dark = _Palette(
  bg: Color(0xFF000000),
  surface: Color(0xFF0D0F14),
  surface2: Color(0xFF151821),
  border: Color(0x1FFFFFFF),
  text: Color(0xFFECEEF5),
  text2: Color(0xFFA6ABBE),
  text3: Color(0xFF737891),
  blue: Color(0xFF4F8CFF),
  green: Color(0xFF34D399),
  orange: Color(0xFFFBBF24),
  red: Color(0xFFF87171),
);

// Light: copied from the website's html[data-theme="light"] block in theme.css.
const _Palette _light = _Palette(
  bg: Color(0xFFF7F8FC),
  surface: Color(0xFFFFFFFF),
  surface2: Color(0xFFEEF1F8),
  border: Color(0x1A0F172A),
  text: Color(0xFF0F172A),
  text2: Color(0xFF475569),
  text3: Color(0xFF64748B),
  blue: Color(0xFF2563EB),
  green: Color(0xFF047857),
  orange: Color(0xFFB45309),
  red: Color(0xFFDC2626),
);

/// Colours of the current theme (read at build time, so these are not compile-time constants).
class C {
  static _Palette get _p => themeState.light ? _light : _dark;
  static Color get bg => _p.bg;
  static Color get surface => _p.surface;
  static Color get surface2 => _p.surface2;
  static Color get border => _p.border;
  static Color get text => _p.text;
  static Color get text2 => _p.text2;
  static Color get text3 => _p.text3;
  static Color get blue => _p.blue;
  static Color get green => _p.green;
  static Color get orange => _p.orange;
  static Color get red => _p.red;
}

ThemeData buildTheme() {
  final light = themeState.light;
  final scheme = (light ? const ColorScheme.light() : const ColorScheme.dark()).copyWith(
    primary: C.blue,
    secondary: C.green,
    surface: C.surface,
    onSurface: C.text,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: light ? Brightness.light : Brightness.dark,
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

/// Pastel accent colours (made for a dark background) get deeper on the light theme so they stay readable.
Color accentFor(Color c) {
  if (!themeState.light) return c;
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness(math.min(hsl.lightness, 0.36)).toColor();
}

/// The gold logo is pale on white: same tweak as the website (brightness .78, saturate 1.4) in light mode.
Widget themedLogo(Widget image) {
  if (!themeState.light) return image;
  const b = 0.78;
  const s = 1.4;
  const m = <double>[
    (0.213 + 0.787 * s) * b, (0.715 - 0.715 * s) * b, (0.072 - 0.072 * s) * b, 0, 0,
    (0.213 - 0.213 * s) * b, (0.715 + 0.285 * s) * b, (0.072 - 0.072 * s) * b, 0, 0,
    (0.213 - 0.213 * s) * b, (0.715 - 0.715 * s) * b, (0.072 + 0.928 * s) * b, 0, 0,
    0, 0, 0, 1, 0,
  ];
  return ColorFiltered(colorFilter: const ColorFilter.matrix(m), child: image);
}

TextStyle get kTitle => TextStyle(color: C.text, fontSize: 15, fontWeight: FontWeight.w600, height: 1.3);
TextStyle get kBody => TextStyle(color: C.text2, fontSize: 13, height: 1.35);
TextStyle get kSmall => TextStyle(color: C.text3, fontSize: 12, height: 1.3);
TextStyle get kH1 => TextStyle(color: C.text, fontSize: 22, fontWeight: FontWeight.w700, height: 1.25);
