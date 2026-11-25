import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lingua_go/models/unidad_model.dart';
import 'package:lingua_go/models/contenido_capitulos.dart';
import 'package:sensors_plus/sensors_plus.dart';

class FlashcardsProvider extends ChangeNotifier {
  UnidadModel? unidad;
  List<Map<String, String>> palabras = [];
  int indice = 0;
  bool volteada = false;
  bool terminada = false;
  int? capituloIndex;

  bool sensorDisponible = true;
  double fuerza = 9.8;
  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime _ultimoSacudon = DateTime.fromMillisecondsSinceEpoch(0);
  static const double umbralSacudon = 20;

  void m_inicia(UnidadModel u, {int? capituloIndex}) {
    unidad = u;
    this.capituloIndex = capituloIndex;
    final base = capituloIndex == null ? u.vocabulario : ContenidoCapitulo.crear(u, capituloIndex).vocabulario;
    palabras = List<Map<String, String>>.from(base)..shuffle();
    indice = 0;
    volteada = false;
    terminada = false;
    notifyListeners();
    m_iniciaSensor();
  }

  void m_voltea() {
    volteada = !volteada;
    notifyListeners();
  }

  void m_siguiente() {
    if (terminada || palabras.isEmpty) return;
    if (indice >= palabras.length - 1) {
      terminada = true;
    } else {
      indice++;
      volteada = false;
    }
    notifyListeners();
  }

  void m_iniciaSensor() {
    _sub?.cancel();
    try {
      _sub = accelerometerEventStream(
        samplingPeriod: SensorInterval.normalInterval,
      ).listen(
        (evento) {
          fuerza = sqrt(
            evento.x * evento.x + evento.y * evento.y + evento.z * evento.z,
          );
          final ahora = DateTime.now();
          if (fuerza > umbralSacudon &&
              ahora.difference(_ultimoSacudon).inMilliseconds > 900) {
            _ultimoSacudon = ahora;
            m_siguiente();
          } else {
            notifyListeners();
          }
        },
        onError: (_) {

          sensorDisponible = false;
          notifyListeners();
        },
      );
      sensorDisponible = true;
    } catch (_) {
      sensorDisponible = false;
    }
  }

  void m_detieneSensor() {
    _sub?.cancel();
    _sub = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
