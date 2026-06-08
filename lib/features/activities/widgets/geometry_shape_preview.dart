import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/geometry_question.dart';

class GeometryShapePreview extends StatelessWidget {
  final GeometryShapeType shapeType;
  final Color color;

  const GeometryShapePreview({
    super.key,
    required this.shapeType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: _labelFor(shapeType),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF10243A) : const Color(0xFFF7FDFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.45),
            width: 2,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 116,
            height: 116,
            child: CustomPaint(
              painter: _GeometryShapePainter(
                shapeType: shapeType,
                color: color,
                isDark: isDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _labelFor(GeometryShapeType type) {
    switch (type) {
      case GeometryShapeType.circle:
        return 'Círculo';
      case GeometryShapeType.square:
        return 'Cuadrado';
      case GeometryShapeType.triangle:
        return 'Triángulo';
      case GeometryShapeType.rectangle:
        return 'Rectángulo';
      case GeometryShapeType.pentagon:
        return 'Pentágono';
      case GeometryShapeType.hexagon:
        return 'Hexágono';
    }
  }
}

class _GeometryShapePainter extends CustomPainter {
  final GeometryShapeType shapeType;
  final Color color;
  final bool isDark;

  const _GeometryShapePainter({
    required this.shapeType,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.85 : 0.78)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF1A2D4A)
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = _buildPath(size);
    if (shapeType == GeometryShapeType.circle) {
      final radius = math.min(size.width, size.height) * 0.38;
      final center = Offset(size.width / 2, size.height / 2);
      canvas.drawCircle(center, radius, fillPaint);
      canvas.drawCircle(center, radius, strokePaint);
      return;
    }

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  Path _buildPath(Size size) {
    switch (shapeType) {
      case GeometryShapeType.circle:
        return Path();
      case GeometryShapeType.square:
        final side = math.min(size.width, size.height) * 0.72;
        final left = (size.width - side) / 2;
        final top = (size.height - side) / 2;
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(left, top, side, side),
              const Radius.circular(6),
            ),
          );
      case GeometryShapeType.rectangle:
        final width = size.width * 0.82;
        final height = size.height * 0.52;
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(size.width / 2, size.height / 2),
                width: width,
                height: height,
              ),
              const Radius.circular(6),
            ),
          );
      case GeometryShapeType.triangle:
        return Path()
          ..moveTo(size.width / 2, size.height * 0.13)
          ..lineTo(size.width * 0.13, size.height * 0.86)
          ..lineTo(size.width * 0.87, size.height * 0.86)
          ..close();
      case GeometryShapeType.pentagon:
        return _regularPolygon(size, 5, -math.pi / 2);
      case GeometryShapeType.hexagon:
        return _regularPolygon(size, 6, math.pi / 6);
    }
  }

  Path _regularPolygon(Size size, int sides, double startAngle) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;
    final path = Path();

    for (var i = 0; i < sides; i++) {
      final angle = startAngle + (2 * math.pi * i / sides);
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    return path..close();
  }

  @override
  bool shouldRepaint(covariant _GeometryShapePainter oldDelegate) {
    return oldDelegate.shapeType != shapeType ||
        oldDelegate.color != color ||
        oldDelegate.isDark != isDark;
  }
}
