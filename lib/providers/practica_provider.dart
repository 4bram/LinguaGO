import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lingua_go/config/sonidos_service.dart';

/// Estado de una actividad de práctica (escucha, gramática, escritura,
/// vocabulario y evaluación). Cada pantalla de práctica crea su propia
/// instancia, así que nada se mezcla entre actividades.
class PracticaProvider extends ChangeNotifier {
  List<Map<String, String>> preguntas = [];
  int indice = 0;
  int aciertos = 0;
  int? seleccion;
  bool respondida = false;
  bool terminada = false;
  bool guardado = false;

  /// Opciones de la pregunta actual (se conservan al reconstruir la pantalla).
  List<String>? opcionesCache;

  /// Carga las preguntas. No notifica: se llama mientras se arma la pantalla.
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

  /// Avanza a la siguiente pregunta. Devuelve true si ya era la última.
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
