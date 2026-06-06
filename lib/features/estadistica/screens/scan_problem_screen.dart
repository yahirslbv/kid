import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class ScanProblemScreen extends StatefulWidget {
  final String tema;
  const ScanProblemScreen({super.key, required this.tema});

  @override
  State<ScanProblemScreen> createState() => _ScanProblemScreenState();
}

class _ScanProblemScreenState extends State<ScanProblemScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // ── Seleccionar / recortar imagen ─────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );
      if (pickedFile == null) return;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        maxWidth: 800,
        maxHeight: 800,
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Enfocar Fórmula',
            toolbarColor: const Color(0xFF5B9BD5),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Enfocar Fórmula',
            doneButtonTitle: 'Aceptar',
            cancelButtonTitle: 'Cancelar',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() => _selectedImage = File(croppedFile.path));
      }
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
    }
  }

  void _clearImage() => setState(() => _selectedImage = null);

  // ── Enviar imagen al servidor ──────────────────────────────────────────────
  Future<void> _resolverProblema() async {
    if (_selectedImage == null) return;

    // Mostrar carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final uri = Uri.parse(
          'https://juancarlos2431-api-matematicas.hf.space/escanear/${widget.tema}');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
          await http.MultipartFile.fromPath('file', _selectedImage!.path));

      final response     = await request.send();
      final responseData = await response.stream.bytesToString();
      final json         = jsonDecode(responseData);

      // Quitar carga
      if (mounted) Navigator.pop(context);

      if (json['success'] == true) {
        final String formula   = json['formula_detectada'] ?? '';
        final String resultado = json['resultado'] ?? '';

        // ── Comportamiento especial para TABULADOR ────────────────────────
        // En vez de mostrar un diálogo, regresamos la función al TabuladorScreen
        if (widget.tema == 'tabulador') {
          if (mounted) Navigator.pop(context, resultado); // devuelve String
          return;
        }

        // ── Resto de temas: mostrar diálogo con resultado ─────────────────
        if (mounted) _mostrarResultadoDialog(context, formula, resultado);
      } else {
        final String errorReal   = json['error']              ?? 'Error desconocido';
        final String formulaLeida = json['formula_detectada'] ?? '';

        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Ops! Algo falló'),
              content: Text(
                  'La IA leyó esto: $formulaLeida\n\nPero el motor matemático dijo: $errorReal'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Título dinámico según tema
    final String titulo = widget.tema == 'tabulador'
        ? 'Escanear Función'
        : 'Escanear Problema';

    final String instruccion = widget.tema == 'tabulador'
        ? 'Toma una foto de la función f(x) que quieres tabular'
        : 'Toma una foto de tu problema de matemáticas';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
            color: isDark ? Colors.white : const Color(0xFF1A2D4A)),
        title: Text(
          titulo,
          style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A2D4A),
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Área de imagen ──────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C3350) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF234060)
                        : const Color(0xFFD6E8F7),
                    width: 2,
                  ),
                ),
                child: _selectedImage == null
                    ? _buildPlaceholder(isDark, instruccion)
                    : _buildImagePreview(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Botones ─────────────────────────────────────────────────────
            if (_selectedImage == null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Cámara',
                      color: const Color(0xFF5B9BD5),
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Galería',
                      color: const Color(0xFF6B8CAE),
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildActionButton(
                icon: widget.tema == 'tabulador'
                    ? Icons.table_chart
                    : Icons.auto_awesome,
                label: widget.tema == 'tabulador'
                    ? 'Usar esta función'
                    : 'Resolver Problema',
                color: Colors.green.shade600,
                isLarge: true,
                onTap: _resolverProblema,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _clearImage,
                icon: const Icon(Icons.refresh, color: Colors.redAccent),
                label: const Text('Tomar otra foto',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Widgets de UI ─────────────────────────────────────────────────────────

  Widget _buildPlaceholder(bool isDark, String instruccion) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.document_scanner_rounded,
            size: 80,
            color: isDark ? Colors.white24 : Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          instruccion,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : const Color(0xFF6B8CAE)),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.file(_selectedImage!, fit: BoxFit.contain),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: isLarge ? 60 : 55,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: isLarge ? 28 : 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: isLarge ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Diálogo de resultado (para temas que no son tabulador) ────────────────────
void _mostrarResultadoDialog(
    BuildContext context, String formula, String resultado) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final List<String> soluciones = resultado
      .split(r', \quad ')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF1C3350) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Solución Encontrada ✓',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A2D4A),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Problema detectado:', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Math.tex(formula, textStyle: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Resultado:', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          ...soluciones.map((sol) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9BD5).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFF5B9BD5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Math.tex(
                    sol,
                    textStyle: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B9BD5),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9BD5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    ),
  );
}