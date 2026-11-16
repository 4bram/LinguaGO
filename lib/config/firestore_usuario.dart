import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';


class FirestoreUsuario {
  final FirebaseFirestore conexion = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      conexion.collection('usuarios').doc(uid);


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

  Future<void> m_guardaPreferencia(String uid, String clave, dynamic valor) async {
    try {
      await _doc(uid).set({
        'preferencias': {clave: valor},
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<bool> m_esAdmin(String uid) async {
    try {
      final doc = await conexion.collection('admins').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint('$e');
      return false;
    }
  }

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

  Stream<Map<String, Map<String, dynamic>>> m_selectProgreso(String uid) {
    return _doc(uid).collection('progreso').snapshots().map((snap) {
      final mapa = <String, Map<String, dynamic>>{};
      for (final doc in snap.docs) {
        mapa[doc.id] = Map<String, dynamic>.from(doc.data());
      }
      return mapa;
    });
  }

  void m_guardaProgreso(String uid, String unidadId, Map<String, dynamic> datos) {
    _doc(uid)
        .collection('progreso')
        .doc(unidadId)
        .set(datos, SetOptions(merge: true)).catchError((e) {
      debugPrint('$e');
    });
  }
}
