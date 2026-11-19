import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lingua_go/config/sonidos_service.dart';

class PracticaProvider extends ChangeNotifier {
  List<Map<String, String>> preguntas = [];
  int indice = 0;
  int aciertos = 0;
  int? seleccion;
  bool respondida = false;
  bool terminada = false;
  bool guardado = false;

  List<String>? opcionesCache;

  void m_inicia(List<Map<String, String>> nuevas) {
    preguntas = nuevas;
    indice = 0;
    aciertos = 0;
    seleccion = null;
    respondida = false;
    terminada = false;
    guardado = false;
    opcionesCache = null;
  }

  void m_responde(int opcion, bool correcta) {
    if (respondida) return;
    seleccion = opcion;
    respondida = true;
    if (correcta) {
      aciertos++;
      SonidosService.m_exito(volumen: 0.5);
    }
    notifyListeners();
  }

  void m_respondeEscritura(bool correcta) {
    if (respondida) return;
    respondida = true;
    if (correcta) {
      aciertos++;
      SonidosService.m_exito(volumen: 0.5);
    }
    notifyListeners();
  }

  bool m_siguiente() {
    if (indice + 1 >= preguntas.length) {
      terminada = true;
      notifyListeners();
      return true;
    }
    indice++;
    respondida = false;
    seleccion = null;
    opcionesCache = null;
    notifyListeners();
    return false;
  }

  void m_reinicia(Random random) {
    indice = 0;
    aciertos = 0;
    seleccion = null;
    respondida = false;
    terminada = false;
    guardado = false;
    opcionesCache = null;
    preguntas.shuffle(random);
    notifyListeners();
  }
}
