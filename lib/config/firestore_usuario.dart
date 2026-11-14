import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Datos del usuario en Firestore:
///   usuarios/{uid}                -> campo "suscripcion"
///   usuarios/{uid}/progreso/{id}  -> por unidad: "actividades" (por capítulo),
///                                    "evaluaciones" (por capítulo) y "final" (evaluación de la unidad)
class FirestoreUsuario {
  final FirebaseFirestore conexion = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      conexion.collection('usuarios').doc(uid);

  // ---------- Preferencias (tema oscuro por usuario) ----------
  /// null si el usuario aún no eligió tema.
  Future<bool?> m_leeTema(String uid) async {
    try {
      final doc = await _doc(uid).get();
      final prefs = doc.data()?['preferencias'];
      if (prefs is Map && prefs['oscuro'] is bool) return prefs['oscuro'] as bool;
    } catch (e) {
      debugPrint('$e');
    }
    return null;
  }

  Future<void> m_guardaTema(String uid, bool oscuro) async {
    try {
      await _doc(uid).set({
        'preferencias': {'oscuro': oscuro},
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('$e');
    }
  }

  /// Todas las preferencias del usuario (tema, sonidos, temas de notificación).
  /// null si no existen o no se pudieron leer.
  Future<Map<String, dynamic>?> m_leePreferencias(String uid) async {
    try {
      final doc = await _doc(uid).get();
      final prefs = doc.data()?['preferencias'];
      if (prefs is Map) return Map<String, dynamic>.from(prefs);
    } catch (e) {
      debugPrint('$e');
    }
    return null;
  }

  /// Guarda UNA preferencia sin borrar las demás (merge).
  Future<void> m_guardaPreferencia(String uid, String clave, dynamic valor) async {
    try {
      await _doc(uid).set({
        'preferencias': {clave: valor},
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('$e');
    }
  }

  // ---------- Administradores ----------
  /// Los administradores se dan de alta SOLO desde la consola de Firebase:
  /// colección "admins", documento con el uid del usuario.
  Future<bool> m_esAdmin(String uid) async {
    try {
      final doc = await conexion.collection('admins').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint('$e');
      return false;
    }
  }

  // ---------- Suscripción ----------
  Stream<Map<String, dynamic>?> m_selectSuscripcion(String uid) {
    return _doc(uid).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      final s = data['suscripcion'];
      if (s == null) return null;
      return Map<String, dynamic>.from(s as Map);
    });
  }

  void m_guardaSuscripcion(String uid, Map<String, dynamic> datos) {
    _doc(uid).set({'suscripcion': datos}, SetOptions(merge: true)).catchError((e) {
      debugPrint('$e');
    });
  }

  void m_borraSuscripcion(String uid) {
    _doc(uid)
        .set({'suscripcion': FieldValue.delete()}, SetOptions(merge: true))
        .catchError((e) {
      debugPrint('$e');
    });
  }

  // ---------- Pedidos de la tienda ----------
  Future<void> m_guardaPedido(String uid, Map<String, dynamic> datos) async {
    try {
      await _doc(uid).collection('pedidos').add(datos);
    } catch (e) {
      debugPrint('$e');
    }
  }

  Stream<List<Map<String, dynamic>>> m_selectPedidos(String uid) {
    return _doc(uid)
        .collection('pedidos')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  // ---------- Progreso ----------
  Stream<Map<String, Map<String, dynamic>>> m_selectProgreso(String uid) {
    return _doc(uid).collection('progreso').snapshots().map((snap) {
      final mapa = <String, Map<String, dynamic>>{};
      for (final doc in snap.docs) {
        mapa[doc.id] = Map<String, dynamic>.from(doc.data());
      }
      return mapa;
    });
  }

  /// Combina (merge) los datos con lo ya guardado de esa unidad.
  void m_guardaProgreso(String uid, String unidadId, Map<String, dynamic> datos) {
    _doc(uid)
        .collection('progreso')
        .doc(unidadId)
        .set(datos, SetOptions(merge: true)).catchError((e) {
      debugPrint('$e');
    });
  }
}
