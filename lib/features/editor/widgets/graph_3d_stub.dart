// Stub para plataformas que no soportan webview_flutter (Windows, Web, Linux, macOS)
// En estas plataformas graph_3d_view.dart usa ditredi como fallback automáticamente.

import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class Graph3DWebView extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const Graph3DWebView({super.key, required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}