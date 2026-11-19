import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lingua_go/config/cache_imagenes.dart';

class ImagenCache {
  final String url;
  final bool guardada;
  final int bytes;
  final DateTime? fecha;
  const ImagenCache(this.url, this.guardada, this.bytes, this.fecha);
}

class CacheProvider extends ChangeNotifier {
  final List<String> urls;
  CacheProvider(this.urls) {
    m_actualiza();
  }

  int archivos = 0;
  int bytes = 0;
  String ruta = '';
  List<ImagenCache> imagenes = [];
  bool ocupado = false;
  String? mensaje;
  int? unidadesEnCacheFirestore;
  bool cargado = false;

  Future<void> m_actualiza() async {
    final est = await CacheImagenes.m_estadisticas();
    archivos = est.archivos;
    bytes = est.bytes;
    ruta = est.ruta;
    final lista = <ImagenCache>[];
    for (final u in urls) {
      FileInfo? info;
      try {
        info = await CacheImagenes.manager.getFileFromCache(u);
      } catch (_) {}
      int tam = 0;
      DateTime? fecha;
      if (info != null) {
        try {
          tam = await info.file.length();
          fecha = await info.file.lastModified();
        } catch (_) {}
      }
      lista.add(ImagenCache(u, info != null, tam, fecha));
    }
    imagenes = lista;
    cargado = true;
    notifyListeners();
  }

  Future<void> m_precarga() async {
    ocupado = true;
    mensaje = 'Descargando imágenes al teléfono…';
    notifyListeners();
    final n = await CacheImagenes.m_precarga(urls);
    ocupado = false;
    mensaje = n == 0
        ? 'Todo ya estaba guardado (o no hay conexión).'
        : 'Se guardaron $n imágenes nuevas. Ya se ven sin internet.';
    await m_actualiza();
  }

  Future<void> m_vacia() async {
    ocupado = true;
    notifyListeners();
    await CacheImagenes.m_vacia();
    ocupado = false;
    mensaje = 'Caché vaciada. Con internet se vuelve a llenar sola.';
    await m_actualiza();
  }

  Future<void> m_pruebaFirestore() async {
    ocupado = true;
    notifyListeners();
    try {
      final snap = await FirebaseFirestore.instance
          .collection('unidades')
          .get(const GetOptions(source: Source.cache));
      unidadesEnCacheFirestore = snap.docs.length;
      mensaje = 'Firestore devolvió ${snap.docs.length} unidades desde el almacenamiento local.';
    } catch (e) {
      unidadesEnCacheFirestore = 0;
      mensaje = 'Aún no hay datos locales de Firestore: abre las unidades con internet una vez.';
    }
    ocupado = false;
    notifyListeners();
  }
}
