import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importación necesaria

class EcuacionesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _temasCargados = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get temasCargados => _temasCargados;
  bool get isLoading => _isLoading;

  Future<void> fetchTemasPorCategoria(String categoria) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Reemplazar 'ecuaciones_diferenciales' por el nombre exacto de la colección generada por el script
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ecuaciones_diferenciales')
          .where('categoria', isEqualTo: categoria) // Asegurar que los JSONs tengan el campo 'categoria'
          .get();

      _temasCargados = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint("Error obteniendo datos de Firebase: $e");
      _temasCargados = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}