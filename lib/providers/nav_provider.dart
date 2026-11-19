import 'package:flutter/material.dart';

class NavProvider extends ChangeNotifier {
  int indice = 0;

  void m_cambia(int nuevo) {
    indice = nuevo;
    notifyListeners();
  }
}
