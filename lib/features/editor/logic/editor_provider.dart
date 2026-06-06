import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class EditorProvider extends ChangeNotifier {
  String _equation = 'x^2';
  bool _isValid = true;
  List<FlSpot> _points = [];
  bool _is3DMode = false;

  // --- CÁMARA DINÁMICA (ESTADO DEL ZOOM Y POSICIÓN) ---
  double minX = -10, maxX = 10;
  double minY = -10, maxY = 10;

  // Variables para controlar el gesto de zoom
  double _baseMinX = -10, _baseMaxX = 10;
  double _baseMinY = -10, _baseMaxY = 10;
  Offset? _startFocalPoint;

  // --- DATOS 3D ---
  List<vm.Vector3> _surface3DPoints = [];
  String _equation3D = 'sin(x) * cos(y)'; // Ecuación por defecto para 3D
  bool _isValid3D = true;
  double _rotationX = 0.4; // Rotación inicial en X (para ver la superficie)
  double _rotationZ = 0.6; // Rotación inicial en Z

  List<vm.Vector3> get surface3DPoints => _surface3DPoints;
  String get equation3D => _equation3D;
  bool get isValid3D => _isValid3D;
  double get rotationX => _rotationX;
  double get rotationZ => _rotationZ;

  String get equation => _is3DMode ? _equation3D : _equation;
  bool get isValid => _is3DMode ? _isValid3D : _isValid;
  List<FlSpot> get points => _points;
  bool get is3DMode => _is3DMode;

  EditorProvider() {
    _calculatePoints();
    _calculate3DPoints();
  }

  // --- LÓGICA DE GESTOS (ZOOM Y PAN) en 2D ---
  void startGesture(ScaleStartDetails details) {
    _baseMinX = minX;
    _baseMaxX = maxX;
    _baseMinY = minY;
    _baseMaxY = maxY;
    _startFocalPoint = details.localFocalPoint;
  }

  void updateGesture(ScaleUpdateDetails details, Size size) {
    if (_startFocalPoint == null) return;

    double newWidth = (_baseMaxX - _baseMinX) / details.scale;
    double newHeight = (_baseMaxY - _baseMinY) / details.scale;

    double dxPixels = details.localFocalPoint.dx - _startFocalPoint!.dx;
    double dyPixels = details.localFocalPoint.dy - _startFocalPoint!.dy;

    double dxMath = -dxPixels * (newWidth / size.width);
    double dyMath = dyPixels * (newHeight / size.height);

    double baseCenterX = (_baseMinX + _baseMaxX) / 2;
    double baseCenterY = (_baseMinY + _baseMaxY) / 2;

    double newCenterX = baseCenterX + dxMath;
    double newCenterY = baseCenterY + dyMath;

    minX = newCenterX - newWidth / 2;
    maxX = newCenterX + newWidth / 2;
    minY = newCenterY - newHeight / 2;
    maxY = newCenterY + newHeight / 2;

    _calculatePoints();
    notifyListeners();
  }

  // --- ROTACIÓN 3D con gestos ---
  void update3DRotation(double dx, double dy) {
    _rotationZ += dx * 0.01;
    _rotationX += dy * 0.01;
    notifyListeners();
  }

  // --- LÓGICA DE CÁLCULO ---
  void toggleMode() {
    _is3DMode = !_is3DMode;
    notifyListeners();
  }

  void updateEquation(String input) {
    if (_is3DMode) {
      _equation3D = input;
      _calculate3DPoints();
    } else {
      _equation = input;
      _validateEquation();
      if (_isValid) _calculatePoints();
    }
    notifyListeners();
  }

  void _validateEquation() {
    try {
      if (_equation.isEmpty) {
        _isValid = false;
        return;
      }
      Parser p = Parser();
      p.parse(_equation);
      _isValid = true;
    } catch (e) {
      _isValid = false;
    }
  }

  void _calculatePoints() {
    try {
      if (_is3DMode) return;

      Parser p = Parser();
      Expression exp = p.parse(_equation);
      ContextModel cm = ContextModel();
      List<FlSpot> tempPoints = [];

      double range = maxX - minX;
      double step = range / 300;

      double start = minX - range;
      double end = maxX + range;

      for (double x = start; x <= end; x += step) {
        cm.bindVariable(Variable('x'), Number(x));
        double y = exp.evaluate(EvaluationType.REAL, cm);

        if (y.isFinite && !y.isNaN) {
          tempPoints.add(FlSpot(x, y));
        }
      }
      _points = tempPoints;
    } catch (e) {
      _points = [];
    }
  }

  // --- CÁLCULO DE SUPERFICIE 3D z = f(x, y) ---
  void _calculate3DPoints() {
    try {
      if (_equation3D.isEmpty) {
        _isValid3D = false;
        _surface3DPoints = [];
        return;
      }

      Parser p = Parser();
      Expression exp = p.parse(_equation3D);
      ContextModel cm = ContextModel();

      // Validar primero
      cm.bindVariable(Variable('x'), Number(0));
      cm.bindVariable(Variable('y'), Number(0));
      exp.evaluate(EvaluationType.REAL, cm);

      _isValid3D = true;

      const int resolution = 30; // 30x30 = 900 puntos, buen balance calidad/rendimiento
      const double rangeVal = 4.0; // Rango -4 a 4 en X e Y
      const double step = (rangeVal * 2) / resolution;

      List<vm.Vector3> points = [];

      for (double x = -rangeVal; x <= rangeVal; x += step) {
        for (double y = -rangeVal; y <= rangeVal; y += step) {
          cm.bindVariable(Variable('x'), Number(x));
          cm.bindVariable(Variable('y'), Number(y));
          double z = exp.evaluate(EvaluationType.REAL, cm);

          if (z.isFinite && !z.isNaN) {
            // Clampear Z para que no explote la visualización
            z = z.clamp(-6.0, 6.0);
            points.add(vm.Vector3(x.toDouble(), z.toDouble(), y.toDouble()));
          }
        }
      }

      _surface3DPoints = points;
    } catch (e) {
      _isValid3D = false;
      _surface3DPoints = [];
    }

    notifyListeners();
  }

  // Ejemplos de funciones 3D para los chips de sugerencia
  static const List<String> example3DFunctions = [
    'sin(x) * cos(y)',
    'sin(sqrt(x*x + y*y))',
    'x*x - y*y',
    'cos(x) + sin(y)',
    'x*y / 4',
    'sin(x*x + y*y) / (x*x + y*y + 0.1)',
  ];
}