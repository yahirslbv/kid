import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Robot avatar inspirado en la imagen de referencia.
/// Úsalo en cualquier parte del chat así:
///
///   BotAvatar(size: 32)   → pequeño (en burbujas)
///   BotAvatar(size: 80)   → grande (en estado vacío)
class BotAvatar extends StatefulWidget {
  final double size;
  final bool animate; // false para versión estática (en burbujas)

  const BotAvatar({super.key, this.size = 40, this.animate = true});

  @override
  State<BotAvatar> createState() => _BotAvatarState();
}

class _BotAvatarState extends State<BotAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;
  late Animation<double> _blink;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _float = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _blink = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 85),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 5),
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 5),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 5),
    ]).animate(_ctrl);

    if (widget.animate) _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return CustomPaint(
        size: Size(widget.size, widget.size * 1.15),
        painter: _RobotPainter(floatValue: 0, blinkValue: 1),
      );
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final floatOffset =
            math.sin(_float.value * 2 * math.pi) * widget.size * 0.04;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: CustomPaint(
            size: Size(widget.size, widget.size * 1.15),
            painter: _RobotPainter(
              floatValue: _float.value,
              blinkValue: _blink.value,
            ),
          ),
        );
      },
    );
  }
}

// ── PAINTER DEL ROBOT ─────────────────────────────────────────────────────────
class _RobotPainter extends CustomPainter {
  final double floatValue;
  final double blinkValue;

  _RobotPainter({required this.floatValue, required this.blinkValue});

  // Paleta del robot (azul cielo como la referencia)
  static const bodyBlue    = Color(0xFF5B9BD5);
  static const bodyLight   = Color(0xFF82C4F8);
  static const bodyDark    = Color(0xFF3A7FC1);
  static const white       = Color(0xFFFFFFFF);
  static const faceGlow    = Color(0xFFD6E8F7);
  static const eyeBlue     = Color(0xFF1E88E5);
  static const antennaTip  = Color(0xFFF5A623); // acento naranja

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawAntenna(canvas, w, h);
    _drawHead(canvas, w, h);
    _drawFace(canvas, w, h);
    _drawNeck(canvas, w, h);
    _drawBody(canvas, w, h);
    _drawArms(canvas, w, h);
  }

  // ── ANTENA ────────────────────────────────────────────────────────────────
  void _drawAntenna(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = bodyDark
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Palo
    canvas.drawLine(
      Offset(w * 0.5, h * 0.22),
      Offset(w * 0.5, h * 0.08),
      paint,
    );

    // Bolita en la punta (naranja como acento)
    final tipPaint = Paint()
      ..color = antennaTip
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.06), w * 0.07, tipPaint);

    // Brillo en la bolita
    final glowPaint = Paint()
      ..color = white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.45, h * 0.04), w * 0.025, glowPaint);
  }

  // ── CABEZA ────────────────────────────────────────────────────────────────
  void _drawHead(Canvas canvas, double w, double h) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.1, h * 0.12, w * 0.8, h * 0.38),
      Radius.circular(w * 0.22),
    );

    // Sombra
    final shadowPaint = Paint()
      ..color = bodyDark.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      rect.shift(const Offset(0, 3)),
      shadowPaint,
    );

    // Gradiente de la cabeza
    final headPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [bodyLight, bodyBlue],
      ).createShader(rect.outerRect);
    canvas.drawRRect(rect, headPaint);

    // Borde
    final borderPaint = Paint()
      ..color = bodyDark.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;
    canvas.drawRRect(rect, borderPaint);

    // Brillo superior izquierdo
    final highlightPaint = Paint()
      ..color = white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final hlRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.14, w * 0.3, h * 0.1),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(hlRect, highlightPaint);
  }

  // ── CARA (ojos + sonrisa) ─────────────────────────────────────────────────
  void _drawFace(Canvas canvas, double w, double h) {
    // Panel de la pantalla (cara)
    final faceRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.64, h * 0.26),
      Radius.circular(w * 0.12),
    );
    final facePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        colors: [faceGlow, const Color(0xFFD0E8F8)],
      ).createShader(faceRect.outerRect);
    canvas.drawRRect(faceRect, facePaint);

    // ── OJOS ────────────────────────────────────────────────────────────
    final eyeY = h * 0.26;
    final eyeRadius = w * 0.1;

    // Ojo izquierdo
    _drawEye(canvas, Offset(w * 0.34, eyeY), eyeRadius);
    // Ojo derecho
    _drawEye(canvas, Offset(w * 0.66, eyeY), eyeRadius);

    // ── SONRISA ─────────────────────────────────────────────────────────
    final smilePaint = Paint()
      ..color = eyeBlue
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final smilePath = Path();
    smilePath.moveTo(w * 0.35, h * 0.355);
    smilePath.quadraticBezierTo(
      w * 0.5, h * 0.41,
      w * 0.65, h * 0.355,
    );
    canvas.drawPath(smilePath, smilePaint);
  }

  void _drawEye(Canvas canvas, Offset center, double radius) {
    // Fondo blanco del ojo
    final bgPaint = Paint()
      ..color = white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Iris azul (parpadeo con blinkValue)
    final irisRadius = radius * 0.65 * blinkValue;
    final irisPaint = Paint()
      ..shader = RadialGradient(
        colors: [eyeBlue, bodyDark],
      ).createShader(Rect.fromCircle(center: center, radius: irisRadius));
    canvas.drawCircle(center, irisRadius, irisPaint);

    // Pupila
    if (blinkValue > 0.1) {
      final pupilPaint = Paint()
        ..color = const Color(0xFF0D47A1)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius * 0.28 * blinkValue, pupilPaint);
    }

    // Brillo del ojo
    final glowPaint = Paint()
      ..color = white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      center + Offset(-radius * 0.25, -radius * 0.25),
      radius * 0.2,
      glowPaint,
    );

    // Borde del ojo
    final borderPaint = Paint()
      ..color = bodyLight.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, borderPaint);
  }

  // ── CUELLO ────────────────────────────────────────────────────────────────
  void _drawNeck(Canvas canvas, double w, double h) {
    final neckPaint = Paint()
      ..shader = LinearGradient(
        colors: [bodyBlue, bodyDark],
      ).createShader(Rect.fromLTWH(w * 0.4, h * 0.5, w * 0.2, h * 0.07));

    final neckRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.4, h * 0.5, w * 0.2, h * 0.07),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(neckRect, neckPaint);
  }

  // ── CUERPO ────────────────────────────────────────────────────────────────
  void _drawBody(Canvas canvas, double w, double h) {
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.57, w * 0.7, h * 0.38),
      Radius.circular(w * 0.18),
    );

    // Sombra del cuerpo
    final shadowPaint = Paint()
      ..color = bodyDark.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(bodyRect.shift(const Offset(0, 3)), shadowPaint);

    // Gradiente del cuerpo
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bodyBlue, bodyDark],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);

    // Borde
    final borderPaint = Paint()
      ..color = bodyDark.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;
    canvas.drawRRect(bodyRect, borderPaint);

    // Panel del pecho (detalle)
    final chestRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.3, h * 0.64, w * 0.4, h * 0.14),
      Radius.circular(w * 0.06),
    );
    final chestPaint = Paint()
      ..color = white.withValues(alpha: 0.15);
    canvas.drawRRect(chestRect, chestPaint);

    // Luzecita del pecho (pulsa con la animación)
    final pulseAlpha = 0.6 + math.sin(floatValue * 2 * math.pi) * 0.4;
    final ledPaint = Paint()
      ..color = antennaTip.withValues(alpha: pulseAlpha)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.03);
    canvas.drawCircle(Offset(w * 0.5, h * 0.715), w * 0.05, ledPaint);
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.715),
      w * 0.035,
      Paint()..color = antennaTip,
    );

    // Brillo superior del cuerpo
    final hlPaint = Paint()
      ..color = white.withValues(alpha: 0.2);
    final hlRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.59, w * 0.25, h * 0.06),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(hlRect, hlPaint);
  }

  // ── BRAZOS ────────────────────────────────────────────────────────────────
  void _drawArms(Canvas canvas, double w, double h) {
    final armPaint = Paint()
      ..shader = LinearGradient(
        colors: [bodyLight, bodyBlue],
      ).createShader(Rect.fromLTWH(0, h * 0.57, w, h * 0.35));

    final borderPaint = Paint()
      ..color = bodyDark.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022;

    // Brazo izquierdo
    final leftArm = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.0, h * 0.59, w * 0.14, h * 0.28),
      Radius.circular(w * 0.07),
    );
    canvas.drawRRect(leftArm, armPaint);
    canvas.drawRRect(leftArm, borderPaint);

    // Brazo derecho
    final rightArm = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.86, h * 0.59, w * 0.14, h * 0.28),
      Radius.circular(w * 0.07),
    );
    canvas.drawRRect(rightArm, armPaint);
    canvas.drawRRect(rightArm, borderPaint);
  }

  @override
  bool shouldRepaint(_RobotPainter old) =>
      old.floatValue != floatValue || old.blinkValue != blinkValue;
}