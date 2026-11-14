import 'package:flutter/material.dart';

/// Pestaña activa del dashboard: 0 Unidades, 1 Mapa, 2 Planes, 3 Perfil.
class NavProvider extends ChangeNotifier {
  int indice = 0;

  void m_cambia(int nuevo) {
    indice = nuevo;
    notifyListeners();
  }
}
