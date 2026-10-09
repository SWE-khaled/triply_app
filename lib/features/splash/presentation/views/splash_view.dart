import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TriplySplashScreen extends StatefulWidget {
  const TriplySplashScreen({
    super.key,
    required this.nextPageBuilder,
    this.holdDuration = const Duration(seconds: 1),
  });

  final WidgetBuilder nextPageBuilder;
  final Duration holdDuration;

  @override
  State<TriplySplashScreen> createState() => _TriplySplashScreenState();
}

class _TriplySplashScreenState extends State<TriplySplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color _bg = Color(0xFFF8F4E9);
  static const Color _holeColor = Color(0xFFF1D6C3);
  static const Color _tealDark = Color(0xFF147A7A);
  static const Color _tealLight = Color(0xFF35C2A1);
  static const Color _textTop = Color(0xFFDDAE6A);
  static const Color _textBottom = Color(0xFFD4724A);

  static const double _peakScale = 1.35;
  static const String _word = 'riply';

  late final AnimationController _c;

  late final Animation<double> _holeIn;
  late final Animation<double> _holeOut;
  late final Animation<double> _rise;
  late final Animation<double> _settle;
  late final Animation<double> _slideLeft;
  late final Animation<double> _textReveal;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    );

    Animation<double> seg(double a, double b, Curve curve) =>
        CurvedAnimation(parent: _c, curve: Interval(a, b, curve: curve));

    _holeIn = seg(0.00, 0.10, Curves.easeOut);
    _rise = seg(0.08, 0.40, Curves.easeOutCubic);
    _holeOut = seg(0.30, 0.46, Curves.easeInOut);
    _settle = seg(0.40, 0.58, Curves.easeInOutCubic);
    _slideLeft = seg(0.68, 0.90, Curves.easeInOutCubic);
    _textReveal = seg(0.72, 0.96, Curves.easeOutCubic);

    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navTimer = Timer(widget.holdDuration, _goNext);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _c.forward();
    });
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (ctx, _, __) => widget.nextPageBuilder(ctx),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;

          final ankhH = (math.min(w, h) * 0.26).clamp(80.0, 170.0);
          final ankhW = ankhH * 0.62;
          final fontSize = ankhH * 0.62;
          final gap = ankhH * 0.04;

          final textStyle = TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            letterSpacing: -fontSize * 0.02,
            height: 1.0,
            color: Colors.white,
          );
          final textW = _measure(_word, textStyle);
          final textH = fontSize;

          final centerX = w / 2;
          final centerY = h * 0.48;
          final holeY = h * 0.78;
          final holeW = w * 0.34;
          final holeH = holeW * 0.22;

          final lockupW = ankhW + gap + textW;
          final lockupLeft = centerX - lockupW / 2;
          final ankhFinalCx = lockupLeft + ankhW / 2;
          final textLeft = lockupLeft + ankhW + gap;

          final startCy = holeY + ankhH * _peakScale / 2;
          final peakCy = h * 0.40;

          return AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final riseCy = lerpDouble(startCy, peakCy, _rise.value)!;
              final cy = lerpDouble(riseCy, centerY, _settle.value)!;
              final scale = lerpDouble(_peakScale, 1.0, _settle.value)!;
              final cx = lerpDouble(centerX, ankhFinalCx, _slideLeft.value)!;

              final holeOpacity = _holeIn.value * (1 - _holeOut.value);
              final holeScaleX = lerpDouble(0.6, 1.0, _holeIn.value)!;

              final tp = _textReveal.value;
              final textSlide = lerpDouble(-textW * 0.35, 0, tp)!;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: centerX - holeW / 2,
                    top: holeY - holeH / 2,
                    width: holeW,
                    height: holeH,
                    child: Opacity(
                      opacity: holeOpacity.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scaleX: holeScaleX,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: _holeColor,
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(1000, 1000)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: textLeft,
                    top: centerY - textH / 2 + ankhH * 0.10,
                    width: textW,
                    height: textH,
                    child: Opacity(
                      opacity: tp.clamp(0.0, 1.0),
                      child: ClipRect(
                        clipper: _RevealClipper(tp),
                        child: Transform.translate(
                          offset: Offset(textSlide, 0),
                          child: SvgPicture.asset(
                           'assets/images/svg/riply_text.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: ClipRect(
                      clipper: _AboveLineClipper(holeY),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: cx - ankhW / 2,
                            top: cy - ankhH / 2,
                            width: ankhW,
                            height: ankhH,
                            child: Transform.scale(
                              scale: scale,
                              child: SvgPicture.asset(
                                'assets/images/svg/ankh_logo.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  double _measure(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.width;
  }
}

class _RevealClipper extends CustomClipper<Rect> {
  _RevealClipper(this.progress);
  final double progress;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, -size.height, size.width * progress.clamp(0.0, 1.0),
          size.height * 3);

  @override
  bool shouldReclip(_RevealClipper old) => old.progress != progress;
}

class _AboveLineClipper extends CustomClipper<Rect> {
  _AboveLineClipper(this.y);
  final double y;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, size.width, y);

  @override
  bool shouldReclip(_AboveLineClipper old) => old.y != y;
}
