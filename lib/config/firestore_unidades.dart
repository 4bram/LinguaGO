import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lingua_go/models/unidad_model.dart';

class FirestoreUnidades {
  final FirebaseFirestore conexion = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> unidadesCollection;

  FirestoreUnidades() {
    unidadesCollection = conexion.collection('unidades');
  }

  Stream<List<UnidadModel>> m_select() {
    return unidadesCollection.orderBy('orden').snapshots().map(
          (snap) => snap.docs
              .map((doc) => UnidadModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> m_sincronizaCatalogo() async {
    try {
      final actual = await unidadesCollection.get();
      final existentes = {for (final doc in actual.docs) doc.id: doc.data()};
      final batch = conexion.batch();
      var cambios = 0;
      for (final u in UnidadModel.iniciales()) {
        final version = (existentes[u.id]?['versionCatalogo'] as num?)?.toInt() ?? 0;
        if (version < 2) {
          batch.set(unidadesCollection.doc(u.id), u.toMap(), SetOptions(merge: true));
          cambios++;
        }
      }
      if (cambios > 0) await batch.commit();
    } catch (e) {
      debugPrint('No se pudo sincronizar el catálogo: $e');
    }
  }

  void m_actualizaImagen(String id, String url) {
    unidadesCollection.doc(id).update({'imagenUrl': url}).catchError((e) {
      debugPrint('$e');
    });
  }
}
