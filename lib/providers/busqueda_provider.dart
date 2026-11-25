import 'package:flutter/material.dart';

class BusquedaProvider extends ChangeNotifier {
  String filtro = '';

  void m_cambia(String nuevo) {
    if (nuevo == filtro) return;
    filtro = nuevo;
    notifyListeners();
  }
}
