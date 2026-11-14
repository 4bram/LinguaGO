import 'package:flutter/material.dart';

/// Texto del buscador de la pantalla de unidades (sin setState).
class BusquedaProvider extends ChangeNotifier {
  String filtro = '';

  void m_cambia(String nuevo) {
    if (nuevo == filtro) return;
    filtro = nuevo;
    notifyListeners();
  }
}
