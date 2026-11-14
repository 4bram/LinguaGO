import 'package:flutter/material.dart';
import 'package:lingua_go/config/firestore_usuario.dart';
import 'package:lingua_go/config/notificaciones_service.dart';
import 'package:lingua_go/models/notificacion_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Historial de notificaciones y suscripción a temas (FCM Topics).
///
/// Los temas elegidos son POR USUARIO: se guardan en el dispositivo con el uid
/// y en Firestore (usuarios/{uid}/preferencias/temas). Al iniciar sesión se
/// suscribe SOLO a los temas de esa cuenta; al cerrar sesión se desuscribe de
/// todos, así no se mezclan entre cuentas del mismo teléfono.
class NotificacionesProvider extends ChangeNotifier {
  final NotificacionesService _servicio = NotificacionesService();
  final FirestoreUsuario _fs = FirestoreUsuario();

  /// tema -> nombre visible
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

  /// Arranca el listener global (permisos, token y mensajes). Los temas se
  /// aplican después, cuando hay un usuario con sesión (m_cargaUsuario).
  Future<void> m_inicializa() async {
    await _servicio.m_inicializa(provider: this);
  }

  /// Al iniciar sesión: carga y aplica los temas de ESTE usuario.
  Future<void> m_cargaUsuario(String uid) async {
    _uid = uid;

    // 1) Local (rápido). Un usuario nuevo empieza con el tema "general".
    List<String> temas = ['general'];
    try {
      final prefs = await SharedPreferences.getInstance();
      temas = prefs.getStringList('temas_$uid') ?? temas;
    } catch (_) {}
    if (_uid != uid) return;
    _aplica(temas);
    await _sincronizaSuscripciones();

    // 2) Nube (por si cambió de dispositivo)
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

  /// Al cerrar sesión: se desuscribe de todo y borra lo de esta cuenta.
  /// (Se llama mientras el árbol se destruye: se notifica después del frame.)
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

  /// Suscribe a los temas activos y desuscribe de los demás.
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
      // Sin await: si no hay internet no debe bloquear (se sincroniza solo)
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
