import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lingua_go/config/firestore_usuario.dart';
import 'package:lingua_go/config/notificaciones_service.dart';
import 'package:lingua_go/models/notificacion_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificacionesProvider extends ChangeNotifier {
  final NotificacionesService _servicio = NotificacionesService();
  final FirestoreUsuario _fs = FirestoreUsuario();

  static const Map<String, String> temasDisponibles = {
    'general': 'Avisos generales',
    'ofertas': 'Ofertas y promociones',
    'nuevas_unidades': 'Nuevas unidades',
    'recordatorios': 'Recordatorios de estudio',
  };

  final List<NotificacionModel> historial = [];
  final Set<String> temasActivos = {};
  String? token;
  String permiso = 'comprobando…';
  String? _uid;

  bool get soportado => NotificacionesService.soportado;

  Future<void> m_inicializa() async {
    await _servicio.m_inicializa(provider: this);
    m_actualizaPermiso();
  }

  Future<void> m_actualizaPermiso() async {
    permiso = await _servicio.m_leePermiso();
    notifyListeners();
  }

  int m_cuenta(String estado) => historial.where((n) => n.estado == estado).length;

  Future<void> m_cargaUsuario(String uid) async {
    _uid = uid;
    await _cargaHistorial(uid);
    m_actualizaPermiso();

    List<String> temas = ['general'];
    try {
      final prefs = await SharedPreferences.getInstance();
      temas = prefs.getStringList('temas_$uid') ?? temas;
    } catch (_) {}
    if (_uid != uid) return;
    _aplica(temas);
    await _sincronizaSuscripciones();

    final remoto = await _fs.m_leePreferencias(uid);
    if (_uid != uid || remoto == null) return;
    final lista = remoto['temas'];
    if (lista is List) {
      _aplica(lista.map((e) => e.toString()).toList());
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('temas_$uid', temasActivos.toList());
      } catch (_) {}
      await _sincronizaSuscripciones();
    }
  }

  void m_limpiaUsuario() {
    _uid = null;
    temasActivos.clear();
    historial.clear();
    for (final tema in temasDisponibles.keys) {
      _servicio.m_desuscribe(tema).catchError((e) {
        debugPrint('Tema FCM: $e');
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  void _aplica(List<String> temas) {
    temasActivos
      ..clear()
      ..addAll(temas.where((t) => temasDisponibles.containsKey(t)));
    notifyListeners();
  }

  Future<void> _sincronizaSuscripciones() async {
    for (final tema in temasDisponibles.keys) {
      try {
        if (temasActivos.contains(tema)) {
          await _servicio.m_suscribe(tema);
        } else {
          await _servicio.m_desuscribe(tema);
        }
      } catch (e) {
        debugPrint('Tema FCM $tema: $e');
      }
    }
  }

  Future<void> m_cambiaTema(String tema, bool activo) async {
    if (activo) {
      temasActivos.add(tema);
    } else {
      temasActivos.remove(tema);
    }
    notifyListeners();

    final uid = _uid;
    if (uid != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('temas_$uid', temasActivos.toList());
      } catch (_) {}

      _fs.m_guardaPreferencia(uid, 'temas', temasActivos.toList());
    }

    try {
      if (activo) {
        await _servicio.m_suscribe(tema);
      } else {
        await _servicio.m_desuscribe(tema);
      }
    } catch (e) {
      debugPrint('Tema FCM: $e');
    }
  }

  void m_agrega(NotificacionModel n) {

    if (n.id.isNotEmpty && historial.any((x) => x.id == n.id)) return;
    historial.insert(0, n);
    if (historial.length > 100) historial.removeRange(100, historial.length);
    notifyListeners();
    _guardaHistorial();
  }

  Future<void> m_borraHistorial() async {
    historial.clear();
    notifyListeners();
    _guardaHistorial();
  }

  Future<void> _cargaHistorial(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final crudo = prefs.getString('historial_notif_$uid');
      if (crudo == null) {
        _guardaHistorial();
        return;
      }
      final guardadas = (jsonDecode(crudo) as List)
          .whereType<Map>()
          .map((e) => NotificacionModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      for (final g in guardadas) {
        final repetida = g.id.isNotEmpty && historial.any((x) => x.id == g.id);
        if (!repetida) historial.add(g);
      }
      historial.sort((a, b) => b.fecha.compareTo(a.fecha));
      notifyListeners();
      _guardaHistorial();
    } catch (e) {
      debugPrint('Historial FCM: $e');
    }
  }

  Future<void> _guardaHistorial() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'historial_notif_$uid',
        jsonEncode(historial.map((n) => n.toMap()).toList()),
      );
    } catch (_) {}
  }

  void m_guardaToken(String? nuevo) {
    token = nuevo;

    debugPrint('FCM token: $nuevo');
    notifyListeners();
  }
}
