import 'dart:math' as math;

import 'package:banking_app22/screens/main_screen.dart';
import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:banking_app22/src/features/auth/presentation/screens/reegister_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class _Geo {
  static const String word = 'BANKO';
  static const int ringIndex = 4;
  static const double letterWidth = 46;
  static const double letterHeight = 64;
  static const double fontSize = 52;
  static const double ringSize = 40;
  static const double ringStroke = 6.5;

  static double get innerRadius => (ringSize - ringStroke * 2) / 2;

  static double get ringShift =>
      ((ringIndex + 0.5) - word.length / 2) * letterWidth;

  static double maxScale(Size size) {
    final halfDiagonal =
        math.sqrt(size.width * size.width + size.height * size.height) / 2;
    return halfDiagonal / innerRadius * 1.15;
  }

  static double shiftProgress(double z) {
    return const Interval(0, 0.85, curve: Curves.easeInOutCubic).transform(z);
  }

  static double zoomProgress(double z) => Curves.easeInQuad.transform(z);

  static double exitProgress(double z) {
    final t = (z / 0.55).clamp(0.0, 1.0).toDouble();
    return 1 - Curves.easeInOut.transform(t);
  }

  static Offset center(Size size, double z) {
    return Offset(
      size.width / 2 + ringShift * (1 - shiftProgress(z)),
      size.height / 2,
    );
  }

  static double radius(Size size, double z) {
    return innerRadius * math.pow(maxScale(size), zoomProgress(z)).toDouble();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String _tagline = 'Your money. Simplified.';

  late final AnimationController _controller;
  late final Future<String?> _jwt;
  Animation<double>? _portal;

  @override
  void initState() {
    super.initState();
    _jwt = _readJwt();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );
    _controller.animateTo(0.72).whenComplete(_openNext);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String?> _readJwt() async {
    try {
      return await const FlutterSecureStorage().read(key: 'jwt');
    } catch (_) {
      return null;
    }
  }

  Future<void> _openNext() async {
    final jwt = await _jwt;
    if (!mounted) return;
    final splashRoute = ModalRoute.of(context);
     final Widget next = jwt != null
        ? const MainScreen()
        : const RegisterScreen(portalIntro: true);
    final route = PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 1100),
      reverseTransitionDuration: Duration.zero,
      // ignore: unnecessary_underscores
      pageBuilder: (_, __, ___) => next,
      transitionsBuilder: (context, animation, _, child) {
        final size = MediaQuery.sizeOf(context);
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (_, child) {
            return ClipPath(
              clipper: _PortalClipper(
                center: _Geo.center(size, animation.value),
                radius: _Geo.radius(size, animation.value),
              ),
              child: child,
            );
          },
        );
      },
    );

    Navigator.of(context).push(route);
    _attachPortal(route, splashRoute);
  }

  void _attachPortal(PageRoute<void> route, Route<dynamic>? splashRoute) {
    final animation = route.animation;
    if (animation == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _attachPortal(route, splashRoute);
      });
      return;
    }
    setState(() => _portal = animation);

    void onStatus(AnimationStatus status) {
      if (status != AnimationStatus.completed) return;
      animation.removeStatusListener(onStatus);
      if (mounted && splashRoute != null && splashRoute.isActive) {
        Navigator.of(context).removeRoute(splashRoute);
      }
    }

    animation.addStatusListener(onStatus);
  }

  double _t(double begin, double end, Curve curve) {
    final raw = (_controller.value - begin) / (end - begin);
    return curve.transform(raw.clamp(0.0, 1.0).toDouble());
  }

  Widget _glow(double diameter, double progress, double exit) {
    return Opacity(
      opacity: (progress * exit).clamp(0.0, 1.0).toDouble(),
      child: Transform.scale(
        scale: 0.7 + 0.3 * progress,
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primarySoft,
                AppColors.primarySoft.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _letter(int index, double exit) {
    final start = 0.04 + index * 0.045;
    final slide = _t(start, start + 0.24, Curves.easeOutBack);
    final fade = _t(start, start + 0.14, Curves.easeOut);
    return SizedBox(
      width: _Geo.letterWidth,
      height: _Geo.letterHeight,
      child: Opacity(
        opacity: (fade * exit).clamp(0.0, 1.0).toDouble(),
        child: Transform.translate(
          offset: Offset(0, (1 - slide) * 36),
          child: Center(
            child: Text(
              _Geo.word[index],
              style: const TextStyle(
                fontSize: _Geo.fontSize,
                height: 1,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ring(double progress) {
    return SizedBox(
      width: _Geo.letterWidth,
      height: _Geo.letterHeight,
      child: Center(
        child: CustomPaint(
          size: const Size.square(_Geo.ringSize),
          painter: _RingPainter(
            progress: progress,
            color: AppColors.primary,
            stroke: _Geo.ringStroke,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final maxScale = _Geo.maxScale(size);
    final count = _Geo.word.length;
    final ringAlignX = (_Geo.ringIndex + 0.5) / count * 2 - 1;
    final portal = _portal;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: portal == null
            ? _controller
            : Listenable.merge([_controller, portal]),
        builder: (context, _) {
          final z = portal?.value ?? 0.0;
          final scale = math.pow(maxScale, _Geo.zoomProgress(z)).toDouble();
          final shift = _Geo.shiftProgress(z);
          final exit = _Geo.exitProgress(z);
          final glowIn = _t(0.0, 0.35, Curves.easeOut);
          final ringProgress = _t(0.18, 0.50, Curves.easeInOutCubic);
          final taglineIn = _t(0.50, 0.68, Curves.easeOutCubic);

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -size.width * 0.35,
                left: -size.width * 0.3,
                child: _glow(size.width * 0.9, glowIn, exit),
              ),
              Positioned(
                bottom: -size.width * 0.4,
                right: -size.width * 0.35,
                child: _glow(size.width * 1.0, glowIn, exit),
              ),
              Center(
                child: Transform.translate(
                  offset: Offset(-_Geo.ringShift * shift, 0),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment(ringAlignX, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < count; i++)
                          i == _Geo.ringIndex
                              ? _ring(ringProgress)
                              : _letter(i, exit),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: size.height / 2 +
                    _Geo.letterHeight / 2 +
                    20 +
                    (1 - taglineIn) * 12,
                child: Opacity(
                  opacity: (taglineIn * exit).clamp(0.0, 1.0).toDouble(),
                  child: Text(
                    _tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.hint,
                      letterSpacing: 8 - 6.5 * taglineIn,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PortalClipper extends CustomClipper<Path> {
  const _PortalClipper({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_PortalClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius;
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.stroke,
  });

  final double progress;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      (Offset.zero & size).deflate(stroke / 2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}