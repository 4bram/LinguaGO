import 'package:flutter/material.dart';

class VisibilidadPasswordProvider extends ChangeNotifier {
  bool oculto = true;

  void m_alterna() {
    oculto = !oculto;
    notifyListeners();
  }
}
