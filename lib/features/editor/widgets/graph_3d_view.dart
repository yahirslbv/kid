import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../logic/editor_provider.dart';
import '../../../l10n/app_localizations.dart';

// Importamos webview solo en plataformas que lo soportan
import 'graph_3d_webview.dart'
    if (dart.library.html) 'graph_3d_stub.dart'
    as webview_impl;

class Graph3DView extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const Graph3DView({super.key, required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    // Android e iOS usan Three.js via WebView
    final isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    if (isMobile && !kIsWeb) {
      return webview_impl.Graph3DWebView(isDark: isDark, l10n: l10n);
    }

    // Desktop/Web usa ditredi (fallback)
    return _DitrediGraph(isDark: isDark, l10n: l10n);
  }
}

// ── IMPLEMENTACIÓN CON DITREDI (Windows / Web / fallback) ────────────────────
class _DitrediGraph extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const _DitrediGraph({required this.isDark, required this.l10n});

  @override
  State<_DitrediGraph> createState() => _DitrediGraphState();
}

class _DitrediGraphState extends State<_DitrediGraph> {
  late DiTreDiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DiTreDiController(
      rotationX: -30,
      rotationY: 30,
      rotationZ: 0,
      userScale: 1.2,
      ambientLightStrength: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final points   = provider.surface3DPoints;
    final isValid  = provider.isValid3D;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        if (isValid && points.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: DiTreDiDraggable(
              controller: _controller,
              child: DiTreDi(
                figures: _buildFigures(points, widget.isDark),
                controller: _controller,
                config: const DiTreDiConfig(supportZIndex: false),
              ),
            ),
          ),

        if (!isValid || points.isEmpty)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xFF1C3350)
                        : const Color(0xFFEBF4FC),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    isValid ? Icons.view_in_ar_rounded : Icons.error_outline_rounded,
                    size: 36,
                    color: isValid
                        ? (widget.isDark ? Colors.white24 : const Color(0xFFB0CDE8))
                        : const Color(0xFFE53935).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isValid ? 'Ingresa una función z = f(x,y)' : 'Función inválida',
                  style: TextStyle(
                    color: widget.isDark ? Colors.white38 : const Color(0xFFB0CDE8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        // Badge y hint
        Positioned(
          top: 12, left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF5B9BD5).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF5B9BD5).withValues(alpha: 0.3)),
            ),
            child: const Text('3D',
                style: TextStyle(
                    color: Color(0xFF5B9BD5),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
          ),
        ),

        if (isValid && points.isNotEmpty)
          Positioned(
            bottom: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded, size: 14,
                      color: widget.isDark ? Colors.white38 : const Color(0xFF6B8CAE)),
                  const SizedBox(width: 4),
                  Text('Arrastra para rotar',
                      style: TextStyle(
                          fontSize: 11,
                          color: widget.isDark ? Colors.white38 : const Color(0xFF6B8CAE))),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Model3D> _buildFigures(List<vm.Vector3> points, bool isDark) {
    final figures = <Model3D>[];

    figures.addAll([
      Line3D(vm.Vector3(-5,0,0), vm.Vector3(5,0,0),  color: Colors.red.withValues(alpha:.7),   width:2),
      Line3D(vm.Vector3(0,-5,0), vm.Vector3(0,5,0),  color: Colors.green.withValues(alpha:.7), width:2),
      Line3D(vm.Vector3(0,0,-5), vm.Vector3(0,0,5),  color: Colors.blue.withValues(alpha:.7),  width:2),
    ]);

    final gc = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.blueGrey.withValues(alpha: 0.15);
    for (double i = -4; i <= 4; i++) {
      figures.add(Line3D(vm.Vector3(i,0,-4), vm.Vector3(i,0,4), color: gc, width:.5));
      figures.add(Line3D(vm.Vector3(-4,0,i), vm.Vector3(4,0,i), color: gc, width:.5));
    }

    if (points.isNotEmpty) {
      final minZ = points.map((p)=>p.y).reduce((a,b)=>a<b?a:b);
      final maxZ = points.map((p)=>p.y).reduce((a,b)=>a>b?a:b);
      final rz   = (maxZ - minZ) < .001 ? 1.0 : (maxZ - minZ);
      for (final p in points) {
        final t = ((p.y - minZ) / rz).clamp(0.0, 1.0);
        figures.add(Point3D(p, width: 3.5, color: _heat(t)));
      }
    }
    return figures;
  }

  Color _heat(double t) {
    if (t < .25) return Color.lerp(const Color(0xFF1565C0), const Color(0xFF00ACC1), t/.25)!;
    if (t < .5)  return Color.lerp(const Color(0xFF00ACC1), const Color(0xFF43A047), (t-.25)/.25)!;
    if (t < .75) return Color.lerp(const Color(0xFF43A047), const Color(0xFFFDD835), (t-.5)/.25)!;
    return Color.lerp(const Color(0xFFFDD835), const Color(0xFFE53935), (t-.75)/.25)!;
  }
}