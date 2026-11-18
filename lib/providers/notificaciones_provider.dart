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
  String? _uid;

  bool get soportado => NotificacionesService.soportado;

  Future<void> m_inicializa() async {
    await _servicio.m_inicializa(provider: this);
  }

  Future<void> m_cargaUsuario(String uid) async {
    _uid = uid;

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
    historial.insert(0, n);
    notifyListeners();
  }

  void m_guardaToken(String? nuevo) {
    token = nuevo;
    notifyListeners();
  }
}
