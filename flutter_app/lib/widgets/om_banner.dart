// "ॐ  जय श्री राम  ॐ" warrior banner: Flutter version of the website's header banner (nav.css .hdr-om).
// Glowing animated border, shimmering text, pulsing Om, swaying bows and flags, rising embers, light sweep and the
// fire line below. One repeating ticker drives everything; it pauses by itself when the screen is covered, and the
// banner stays still when the phone's "remove animations" setting is on.
import 'dart:math' as math;

import 'package:flutter/material.dart';

const Color _kFill = Color(0xFF0C0A0E);

double _phase(double s, double period, [double delay = 0]) => (((s - delay) / period) % 1.0 + 1.0) % 1.0;

/// 0 -> 1 -> 0 smoothly once per [period] (like CSS "ease-in-out" going 0%, 50%, 100%).
double _wave(double s, double period, [double delay = 0]) => 0.5 - 0.5 * math.cos(2 * math.pi * _phase(s, period, delay));

/// Evenly spaced keyframes (first = 0%, last = 100%), linearly blended.
double _keys(double p, List<double> v) {
  final x = p * (v.length - 1);
  var i = x.floor();
  if (i >= v.length - 1) i = v.length - 2;
  final f = x - i;
  return v[i] + (v[i + 1] - v[i]) * f;
}

int _alpha(double v) => math.max(0, math.min(255, (v * 255).round()));

/// A gradient [widths] box-widths long that slides sideways and repeats seamlessly (first colour == last colour).
LinearGradient _slide(List<Color> colors, List<double>? stops, double phase, double widths) {
  final x0 = -1.0 + 2.0 * widths * phase;
  return LinearGradient(
    begin: Alignment(x0, 0),
    end: Alignment(x0 + 2.0 * widths, 0),
    colors: colors,
    stops: stops,
    tileMode: TileMode.repeated,
  );
}

const List<Color> _borderColors = <Color>[
  Color(0xFFFF5E00),
  Color(0xFFFFB347),
  Color(0xFFFFE9A8),
  Color(0xFFFFB347),
  Color(0xFFFF5E00),
  Color(0xFFD81B00),
  Color(0xFFFF5E00),
];

const List<Color> _fireColors = <Color>[
  Color(0xFFD81B00),
  Color(0xFFFF5E00),
  Color(0xFFFFB347),
  Color(0xFFFFF3C4),
  Color(0xFFFFB347),
  Color(0xFFFF5E00),
  Color(0xFFD81B00),
];

const List<Color> _textColors = <Color>[
  Color(0xFFFF3D00),
  Color(0xFFFF9933),
  Color(0xFFFFE082),
  Color(0xFFFFFFFF),
  Color(0xFFFFE082),
  Color(0xFFFF9933),
  Color(0xFFFF3D00),
];
const List<double> _textStops = <double>[0.0, 0.22, 0.45, 0.50, 0.55, 0.78, 1.0];

class OmBanner extends StatefulWidget {
  const OmBanner({super.key});

  @override
  State<OmBanner> createState() => _OmBannerState();
}

class _OmBannerState extends State<OmBanner> with SingleTickerProviderStateMixin {
  // One long, endlessly repeating controller: seconds = value * 1000.
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1000));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    // same breakpoints as the website's CSS
    final double jsr, om, bow, flag, gap, padH, padV;
    if (screenW <= 340) {
      jsr = 15; om = 17; bow = 16; flag = 0; gap = 7; padH = 12; padV = 5;
    } else if (screenW <= 420) {
      jsr = 17; om = 19; bow = 18; flag = 0; gap = 7; padH = 12; padV = 5;
    } else if (screenW <= 768) {
      jsr = 19; om = 21; bow = 20; flag = 18; gap = 9; padH = 16; padV = 5;
    } else {
      jsr = 22; om = 25; bow = 23; flag = 21; gap = 12; padH = 24; padV = 7;
    }

    return Semantics(
      label: 'Om, Jai Shri Ram, Om',
      excludeSemantics: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final s = _c.value * 1000.0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
                  child: CustomPaint(
                    painter: _PillPainter(s),
                    foregroundPainter: _PillOverlayPainter(s),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (flag > 0) ...[_flag(s, flag, 0), SizedBox(width: gap)],
                          _bow(s, bow, false),
                          SizedBox(width: gap),
                          _om(s, om, 0),
                          SizedBox(width: gap),
                          _jsr(s, jsr),
                          SizedBox(width: gap),
                          _om(s, om, 1.1),
                          SizedBox(width: gap),
                          _bow(s, bow, true),
                          if (flag > 0) ...[SizedBox(width: gap), _flag(s, flag, 0.9)],
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3, width: double.infinity, child: CustomPaint(painter: _FireLinePainter(s))),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _flag(double s, double size, double delay) {
    final angle = (-8.0 + 18.0 * _wave(s, 1.8, delay)) * math.pi / 180.0;
    return Transform.rotate(
      angle: angle,
      alignment: const Alignment(-0.6, 0.8),
      child: Text('🚩', style: TextStyle(fontSize: size, height: 1.0)),
    );
  }

  Widget _bow(double s, double size, bool mirrored) {
    final p = _wave(s, 2.6);
    Widget w = Transform.translate(
      offset: Offset(-3.0 * p, 0),
      child: Transform.rotate(
        angle: -8.0 * p * math.pi / 180.0,
        child: Text('🏹', style: TextStyle(fontSize: size, height: 1.0)),
      ),
    );
    if (mirrored) {
      w = Transform(alignment: Alignment.center, transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0), child: w);
    }
    return w;
  }

  Widget _om(double s, double size, double delay) {
    final p = _wave(s, 2.2, delay);
    return Transform.scale(
      scale: 1.0 + 0.15 * p,
      child: Text(
        'ॐ',
        style: TextStyle(
          fontSize: size,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFFFC266),
          shadows: [
            Shadow(color: Color.fromARGB(_alpha(0.7 + 0.3 * p), 255, 140 + (70 * p).round(), (120 * p).round()), blurRadius: 6 + 8 * p),
            Shadow(color: Color.fromARGB(_alpha(0.45 + 0.45 * p), 255, 100 + (20 * p).round(), 0), blurRadius: 14 + 16 * p),
          ],
        ),
      ),
    );
  }

  Widget _jsr(double s, double size) {
    final flick = _keys(_phase(s, 1.6), const <double>[0.8, 1.0, 0.7, 1.0, 0.85, 0.8]);
    final blur = _keys(_phase(s, 1.6), const <double>[6, 10, 5, 12, 7, 6]);
    final gradient = _slide(_textColors, _textStops, _phase(s, 3.0), 2.6);
    final base = TextStyle(fontSize: size, height: 1.15, fontWeight: FontWeight.w800, letterSpacing: size * 0.06);
    return Stack(
      alignment: Alignment.center,
      children: [
        // flickering fire glow behind the letters
        Text(
          'जय श्री राम',
          style: base.copyWith(
            foreground: Paint()
              ..color = Color.fromARGB(_alpha(flick * 0.75), 255, 110, 0)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur * 0.55),
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) => gradient.createShader(bounds),
          child: Text('जय श्री राम', style: base.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}

/// Dark pill with the glow, and the moving gradient border.
class _PillPainter extends CustomPainter {
  final double s;
  const _PillPainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));
    final g = _wave(s, 2.2); // glow breathes 0..1
    canvas.drawRRect(
      r,
      Paint()
        ..color = Color.fromARGB(_alpha(0.35 + 0.45 * g), 255, 120 + (30 * g).round(), 0)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 + 6 * g),
    );
    canvas.drawRRect(r, Paint()..color = _kFill);
    canvas.drawRRect(
      r.deflate(1.0),
      Paint()
        ..shader = _slide(_borderColors, null, _phase(s, 4.0), 1.5).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(_PillPainter old) => old.s != s;
}

/// Light sweep and rising embers drawn on top of the content.
class _PillOverlayPainter extends CustomPainter {
  final double s;
  const _PillOverlayPainter(this.s);

  static const List<double> _x = <double>[0.08, 0.22, 0.36, 0.50, 0.64, 0.78, 0.91];
  static const List<double> _delay = <double>[0.0, 0.9, 1.7, 0.4, 2.1, 1.2, 0.6];

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.height / 2));
    canvas.save();
    canvas.clipRRect(r);

    // embers
    for (var i = 0; i < _x.length; i++) {
      final p = _phase(s, 2.8, _delay[i]);
      final a = p < 0.15 ? p / 0.15 : 1.0 - (p - 0.15) / 0.85;
      final big = i.isEven;
      final rad = (big ? 2.0 : 1.5) * (1.0 - 0.8 * p);
      final c = Offset(size.width * _x[i] + 7.0 * p, size.height + 2.0 - 36.0 * p);
      canvas.drawCircle(
        c,
        rad * 2.4,
        Paint()
          ..color = Color.fromARGB(_alpha(a * 0.65), 255, 140, 0)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(c, rad, Paint()..color = Color.fromARGB(_alpha(a), 255, 179, 71));
    }

    // light sweep (first 60% of every 3.2 s)
    final ph = _phase(s, 3.2);
    if (ph < 0.6) {
      final t = ph / 0.6;
      final e = t * t * (3.0 - 2.0 * t);
      final x = size.width * (-0.6 + 1.9 * e);
      final w = size.width * 0.4;
      final box = Rect.fromLTWH(0, 0, w, size.height);
      canvas.translate(x, 0);
      canvas.skew(-0.364, 0);
      canvas.drawRect(
        box,
        Paint()
          ..shader = const LinearGradient(
            colors: <Color>[Color(0x00FFEBB4), Color(0x61FFEBB4), Color(0x00FFEBB4)],
          ).createShader(box),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PillOverlayPainter old) => old.s != s;
}

/// The thin moving fire line under the banner.
class _FireLinePainter extends CustomPainter {
  final double s;
  const _FireLinePainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    final line = Rect.fromLTWH(0, size.height - 2, size.width, 2);
    canvas.drawRect(
      line,
      Paint()
        ..color = const Color(0xCCFF7800)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRect(line, Paint()..shader = _slide(_fireColors, null, _phase(s, 4.0), 3.0).createShader(line));
  }

  @override
  bool shouldRepaint(_FireLinePainter old) => old.s != s;
}
