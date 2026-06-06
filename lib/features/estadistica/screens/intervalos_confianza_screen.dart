import 'dart:math';
import 'package:flutter/material.dart';
import '../../../shared/app_imports.dart';

class IntervalosConfianzaScreen extends StatefulWidget {
  const IntervalosConfianzaScreen({super.key});

  @override
  State<IntervalosConfianzaScreen> createState() => _IntervalosConfianzaScreenState();
}

class _IntervalosConfianzaScreenState extends State<IntervalosConfianzaScreen> {
  String _tipoIntervalo = 'Media Poblacional (Z)';
  String _nivelConfianza = '95%';
  
  // Controladores
  final _nController = TextEditingController(); 
  final _mediaController = TextEditingController(); 
  final _desviacionController = TextEditingController(); 
  final _exitosController = TextEditingController(); // Para proporción (x)

  double? _limiteInferior;
  double? _limiteSuperior;
  double? _estimacionPuntual;
  double? _margenError;

  @override
  void dispose() {
    _nController.dispose();
    _mediaController.dispose();
    _desviacionController.dispose();
    _exitosController.dispose();
    super.dispose();
  }

  // Parseo seguro para tolerar comas en lugar de puntos
  double _parseD(String text) {
    return double.tryParse(text.replaceAll(',', '.')) ?? -1.0;
  }

  int _parseI(String text) {
    return int.tryParse(text.trim()) ?? -1;
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent)
    );
  }

  double _obtenerZ(String nivel) {
    if (nivel == '90%') return 1.645;
    if (nivel == '99%') return 2.576;
    return 1.960; // 95% por defecto
  }

  void _calcular() {
    // Reiniciar valores
    setState(() { 
      _limiteInferior = null; 
      _limiteSuperior = null; 
      _estimacionPuntual = null; 
      _margenError = null; 
    });

    int n = _parseI(_nController.text);
    double z = _obtenerZ(_nivelConfianza);

    if (n <= 0) {
      _mostrarError('Error: El tamaño de la muestra (n) debe ser mayor a 0.');
      return;
    }

    if (_tipoIntervalo == 'Media Poblacional (Z)') {
      double media = _parseD(_mediaController.text);
      double desviacion = _parseD(_desviacionController.text);

      if (desviacion <= 0) {
        _mostrarError('Error: La desviación estándar (σ) debe ser mayor a 0.');
        return;
      }

      double error = z * (desviacion / sqrt(n));
      
      setState(() {
        _estimacionPuntual = media;
        _margenError = error;
        _limiteInferior = media - error;
        _limiteSuperior = media + error;
      });

    } else if (_tipoIntervalo == 'Proporción Poblacional (Z)') {
      int x = _parseI(_exitosController.text);

      if (x < 0 || x > n) {
        _mostrarError('Error: Los éxitos (x) deben estar entre 0 y n.');
        return;
      }

      double p = x / n;
      double error = z * sqrt((p * (1 - p)) / n);

      setState(() {
        _estimacionPuntual = p;
        _margenError = error;
        _limiteInferior = max(0, p - error); // La proporción no puede ser menor a 0
        _limiteSuperior = min(1, p + error); // La proporción no puede ser mayor a 1
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF9C27B0); // Morado para este módulo
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text('Intervalos de Confianza', style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: primaryColor, 
        elevation: 0
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selectores
            _buildDropdown(
              value: _tipoIntervalo, 
              items: ['Media Poblacional (Z)', 'Proporción Poblacional (Z)'], 
              onChanged: (val) => setState(() { _tipoIntervalo = val!; _limiteInferior = null; }), 
              isDark: isDark, 
              color: primaryColor
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              value: _nivelConfianza, 
              items: ['90%', '95%', '99%'], 
              onChanged: (val) => setState(() { _nivelConfianza = val!; _limiteInferior = null; }), 
              isDark: isDark, 
              color: primaryColor, 
              label: 'Nivel de Confianza (1 - α)'
            ),
            const SizedBox(height: 20),
            
            // Formularios dinámicos
            _buildInput(_nController, 'Tamaño de la muestra (n)', isDark),
            if (_tipoIntervalo == 'Media Poblacional (Z)') ...[
              _buildInput(_mediaController, 'Media muestral (x̄)', isDark, isDecimal: true),
              _buildInput(_desviacionController, 'Desviación estándar (σ o s)', isDark, isDecimal: true),
            ] else if (_tipoIntervalo == 'Proporción Poblacional (Z)') ...[
              _buildInput(_exitosController, 'Casos de éxito en la muestra (x)', isDark),
            ],
            
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, 
                padding: const EdgeInsets.symmetric(vertical: 16), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: _calcular, 
              icon: const Icon(Icons.compare_arrows_rounded, color: Colors.white), 
              label: const Text('Calcular Intervalo', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            // Resultados
            if (_limiteInferior != null) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C3350) : Colors.white, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 2)
                ),
                child: Column(
                  children: [
                    Text(
                      'Intervalo de Confianza al $_nivelConfianza', 
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '[ ${_limiteInferior!.toStringAsFixed(4)} , ${_limiteSuperior!.toStringAsFixed(4)} ]', 
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryColor)
                    ),
                    const SizedBox(height: 20),
                    
                    // --- NUEVA SECCIÓN: INTERPRETACIÓN INTUITIVA ---
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(
                        _tipoIntervalo == 'Media Poblacional (Z)' 
                        ? '💡 Interpretación:\nEstamos $_nivelConfianza seguros de que el verdadero promedio poblacional está entre ${_limiteInferior!.toStringAsFixed(2)} y ${_limiteSuperior!.toStringAsFixed(2)}.\n\n👉 El valor central esperado es ${_estimacionPuntual!.toStringAsFixed(2)}, con un margen de error de ±${_margenError!.toStringAsFixed(2)}.'
                        : '💡 Interpretación:\nEstamos $_nivelConfianza seguros de que el porcentaje real de la población se encuentra entre ${(_limiteInferior! * 100).toStringAsFixed(2)}% y ${(_limiteSuperior! * 100).toStringAsFixed(2)}%.', 
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, height: 1.4), 
                        textAlign: TextAlign.left
                      ),
                    ),
                    // --- FIN DE LA NUEVA SECCIÓN ---
                    
                    const SizedBox(height: 24),
                    
                    // Gráfico Lineal 1D del Intervalo
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(height: 4, width: double.infinity, color: primaryColor.withValues(alpha: 0.3)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _DotLabel(_limiteInferior!.toStringAsFixed(3), primaryColor),
                            _DotLabel(_estimacionPuntual!.toStringAsFixed(3), primaryColor, isCenter: true),
                            _DotLabel(_limiteSuperior!.toStringAsFixed(3), primaryColor),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatText('Estimador Puntual', _estimacionPuntual!.toStringAsFixed(4), isDark),
                        _StatText('Margen Error (E)', '± ${_margenError!.toStringAsFixed(4)}', isDark),
                      ],
                    )
                  ]
                )
              ),
              const SizedBox(height: 40),
            ]
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. Botón del Escáner
          FloatingActionButton.extended(
            heroTag: 'btn_scan_intervalos_confianza', // Tag único
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Le mandamos el tema 'descriptiva' a Python
                  builder: (context) => const ScanProblemScreen(tema: 'intervalos_confianza'), 
                ),
              );
            },
            backgroundColor: const Color(0xFF5B9BD5),
            icon: const Icon(Icons.document_scanner, color: Colors.white),
            label: const Text('Escanear Datos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          // 2. Botón del Asistente de IA (el que ya tenías)
          FloatingActionButton(
            heroTag: 'btn_asistente_intervalos_confianza',
            onPressed: () => _showAssistant(context, primaryColor),
            backgroundColor: const Color(0xFF6B8CAE),
            elevation: 4,
            child: const Icon(Icons.psychology_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged, required bool isDark, required Color color, String? label}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: isDark ? const Color(0xFF234060) : color.withValues(alpha: 0.3))
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value, 
        isExpanded: true,
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
          labelText: label, 
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54), 
          border: InputBorder.none
        ),
        dropdownColor: isDark ? const Color(0xFF1C3350) : Colors.white,
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, bool isDark, {bool isDecimal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), 
      child: TextField(
        controller: controller, 
        keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.number, 
        style: TextStyle(color: isDark ? Colors.white : Colors.black87), 
        decoration: InputDecoration(
          labelText: label, 
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54), 
          filled: true, 
          fillColor: isDark ? const Color(0xFF152840) : Colors.white, 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), 
            borderSide: BorderSide.none
          )
        )
      )
    );
  }

  void _showAssistant(BuildContext context, Color color) {
    String contexto = "Cálculo: $_tipoIntervalo al $_nivelConfianza. n=${_nController.text}. ";
    if (_tipoIntervalo == 'Media Poblacional (Z)') {
      contexto += "Media(x̄)=${_mediaController.text}, Desviación(σ)=${_desviacionController.text}.";
    } else {
      contexto += "Éxitos(x)=${_exitosController.text}.";
    }

    if (_limiteInferior != null) {
      contexto += " El intervalo resultante es [${_limiteInferior!.toStringAsFixed(4)}, ${_limiteSuperior!.toStringAsFixed(4)}] con un margen de error de ${_margenError!.toStringAsFixed(4)}.";
    }

    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => _MiniChatAssistantIC(contextoDatos: contexto, colorTema: color)
    );
  }
}

class _DotLabel extends StatelessWidget {
  final String text; 
  final Color color; 
  final bool isCenter;
  
  const _DotLabel(this.text, this.color, {this.isCenter = false});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: isCenter ? 12 : 10, 
          height: isCenter ? 12 : 10, 
          decoration: BoxDecoration(
            color: color, 
            shape: BoxShape.circle, 
            border: isCenter ? Border.all(color: Colors.white, width: 2) : null
          )
        ),
        const SizedBox(height: 6),
        Text(
          text, 
          style: TextStyle(
            fontSize: 12, 
            fontWeight: isCenter ? FontWeight.bold : FontWeight.normal, 
            color: color
          )
        ),
      ],
    );
  }
}

class _StatText extends StatelessWidget {
  final String label, value; 
  final bool isDark;
  
  const _StatText(this.label, this.value, this.isDark);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label, 
          style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)
        ),
        const SizedBox(height: 4),
        Text(
          value, 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)
        ),
      ],
    );
  }
}

class _MiniChatAssistantIC extends StatefulWidget {
  final String contextoDatos; 
  final Color colorTema;
  
  const _MiniChatAssistantIC({required this.contextoDatos, required this.colorTema});
  
  @override
  State<_MiniChatAssistantIC> createState() => _MiniChatAssistantICState();
}

class _MiniChatAssistantICState extends State<_MiniChatAssistantIC> {
  final _controller = TextEditingController();
  
  @override
  void dispose() { 
    _controller.dispose(); 
    super.dispose(); 
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.70 + bottomInset, 
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), 
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))), 
            child: Row(
              children: [
                Icon(Icons.school_rounded, color: widget.colorTema), 
                const SizedBox(width: 8), 
                Text(
                  "Tutor IA - Intervalos", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))
                ), 
                const Spacer(), 
                IconButton(
                  icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), 
                  onPressed: () => Navigator.pop(context)
                )
              ]
            )
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16), 
              itemCount: chatProvider.messages.length, 
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft, 
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8), 
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), 
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8), 
                    decoration: BoxDecoration(
                      color: msg.isUser ? widget.colorTema : (isDark ? const Color(0xFF234060) : const Color(0xFFF3E5F5)), 
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: msg.isUser ? const Radius.circular(0) : null, 
                        bottomLeft: !msg.isUser ? const Radius.circular(0) : null
                      )
                    ), 
                    child: Text(
                      msg.text, 
                      style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A)))
                    )
                  )
                );
              }
            )
          ),
          
          if (chatProvider.isLoading) 
            Padding(
              padding: const EdgeInsets.all(8.0), 
              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: widget.colorTema))
            ),
            
          Padding(
            padding: const EdgeInsets.all(12.0), 
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller, 
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87), 
                    decoration: InputDecoration(
                      hintText: "¿Dudas sobre el margen de error?", 
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13), 
                      filled: true, 
                      fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF5F5F5), 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), 
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                    )
                  )
                ),
                const SizedBox(width: 8), 
                CircleAvatar(
                  backgroundColor: widget.colorTema, 
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), 
                    onPressed: () { 
                      if (_controller.text.isNotEmpty) { 
                        chatProvider.sendMessage(
                          _controller.text, 
                          currentEquation: widget.contextoDatos
                        ); 
                        _controller.clear(); 
                      } 
                    }
                  )
                ),
              ]
            )
          ),
        ],
      ),
    );
  }
}