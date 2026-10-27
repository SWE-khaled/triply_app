import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.nextPageBuilder,
    this.holdDuration = const Duration(milliseconds: 400),
  });

  final WidgetBuilder nextPageBuilder;
  final Duration holdDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color _bg = Color(0xFFF8F4E9);
  static const Color _holeColor = Color(0xFFF1D6C3);

  static const double _peakScale = 1.35;
  static const String _word = 'Triply';
  static const double _wordmarkAspectRatio = 463 / 192;

  late final AnimationController _controller;
  late final Animation<double> _holeIn;
  late final Animation<double> _holeOut;
  late final Animation<double> _rise;
  late final Animation<double> _settle;
  late final Animation<double> _slideLeft;
  late final Animation<double> _textReveal;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    Animation<double> segment(double start, double end, Curve curve) =>
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: curve),
        );

    _holeIn = segment(0.00, 0.10, Curves.easeOut);
    _rise = segment(0.08, 0.40, Curves.easeOutCubic);
    _holeOut = segment(0.30, 0.46, Curves.easeInOut);
    _settle = segment(0.40, 0.58, Curves.easeInOutCubic);
    _slideLeft = segment(0.68, 0.90, Curves.easeInOutCubic);
    _textReveal = segment(0.72, 0.96, Curves.easeOutCubic);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigationTimer = Timer(widget.holdDuration, _goNext);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, _, _) => widget.nextPageBuilder(context),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('triply-splash-screen'),
      backgroundColor: _bg,
      body: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth;
          final height = box.maxHeight;

          final ankhHeight = (math.min(width, height) * 0.26)
              .clamp(80.0, 170.0)
              .toDouble();
          final ankhWidth = ankhHeight * 0.62;
          final fontSize = ankhHeight * 0.62;
          final gap = ankhHeight * 0.04;
          final textHeight = fontSize;
          final textWidth = textHeight * _wordmarkAspectRatio;

          final centerX = width / 2;
          final centerY = height * 0.48;
          final holeY = height * 0.78;
          final holeWidth = width * 0.34;
          final holeHeight = holeWidth * 0.22;

          final lockupWidth = ankhWidth + gap + textWidth;
          final lockupLeft = centerX - lockupWidth / 2;
          final ankhFinalCenterX = lockupLeft + ankhWidth / 2;
          final textLeft = lockupLeft + ankhWidth + gap;

          final startCenterY = holeY + ankhHeight * _peakScale / 2;
          final peakCenterY = height * 0.40;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final riseCenterY = lerpDouble(
                startCenterY,
                peakCenterY,
                _rise.value,
              )!;
              final centerYAnimated = lerpDouble(
                riseCenterY,
                centerY,
                _settle.value,
              )!;
              final scale = lerpDouble(_peakScale, 1.0, _settle.value)!;
              final centerXAnimated = lerpDouble(
                centerX,
                ankhFinalCenterX,
                _slideLeft.value,
              )!;

              final holeOpacity = _holeIn.value * (1 - _holeOut.value);
              final holeScaleX = lerpDouble(0.6, 1.0, _holeIn.value)!;

              final textProgress = _textReveal.value;
              final textSlide = lerpDouble(-textWidth * 0.35, 0, textProgress)!;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: centerX - holeWidth / 2,
                    top: holeY - holeHeight / 2,
                    width: holeWidth,
                    height: holeHeight,
                    child: Opacity(
                      opacity: holeOpacity.clamp(0.0, 1.0).toDouble(),
                      child: Transform.scale(
                        scaleX: holeScaleX,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: _holeColor,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(1000, 1000),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: textLeft,
                    top: centerY - textHeight / 2 + ankhHeight * 0.10,
                    width: textWidth,
                    height: textHeight,
                    child: Opacity(
                      opacity: textProgress.clamp(0.0, 1.0).toDouble(),
                      child: ClipRect(
                        clipper: _RevealClipper(textProgress),
                        child: Transform.translate(
                          offset: Offset(textSlide, 0),
                          child: Image.asset(
                            'assets/images/edits/Frame 2.png',
                            width: textWidth,
                            height: textHeight,
                            fit: BoxFit.contain,
                            semanticLabel: _word,
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
                            left: centerXAnimated - ankhWidth / 2,
                            top: centerYAnimated - ankhHeight / 2,
                            width: ankhWidth,
                            height: ankhHeight,
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
}

class _RevealClipper extends CustomClipper<Rect> {
  _RevealClipper(this.progress);

  final double progress;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(
    0,
    -size.height,
    size.width * progress.clamp(0.0, 1.0),
    size.height * 3,
  );

  @override
  bool shouldReclip(_RevealClipper oldClipper) =>
      oldClipper.progress != progress;
}

class _AboveLineClipper extends CustomClipper<Rect> {
  _AboveLineClipper(this.y);

  final double y;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, size.width, y);

  @override
  bool shouldReclip(_AboveLineClipper oldClipper) => oldClipper.y != y;
}
