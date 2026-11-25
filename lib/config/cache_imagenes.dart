import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lingua_go/config/storage_service.dart';
import 'package:lingua_go/models/producto_model.dart';
import 'package:lingua_go/models/unidad_model.dart';
import 'package:path_provider/path_provider.dart';

class CacheImagenes {
  CacheImagenes._();

  static const String clave = 'linguago_imagenes';

  static final CacheManager manager = CacheManager(
    Config(
      clave,
      stalePeriod: const Duration(days: 90),
      maxNrOfCacheObjects: 400,
    ),
  );

  static const List<String> demo = [
    'https://picsum.photos/id/1015/640/360',
    'https://picsum.photos/id/1025/640/360',
    'https://picsum.photos/id/1043/640/360',
  ];

  static List<String> m_urls({
    required List<UnidadModel> unidades,
    String? fotoUrl,
    bool incluirDemo = false,
  }) {
    final r = <String>[];
    if (fotoUrl != null && fotoUrl.isNotEmpty) r.add(fotoUrl);
    for (final u in unidades) {
      if (u.imagenUrl.isNotEmpty) r.add(u.imagenUrl);
    }
    final storage = StorageService();
    if (storage.configurado) {
      for (final p in ProductoModel.catalogo) {
        r.add(storage.m_urlRecurso(p.rutaPortada));
      }
    }
    if (incluirDemo) r.addAll(demo);
    return r.toSet().toList();
  }

  static Future<int> m_precarga(List<String> urls) async {
    var nuevas = 0;
    for (final url in urls) {
      try {
        final ya = await manager.getFileFromCache(url);
        if (ya != null) continue;
        await manager.downloadFile(url);
        nuevas++;
      } catch (e) {
        debugPrint('No se pudo precargar $url: $e');
      }
    }
    return nuevas;
  }

  static Future<Directory?> m_carpeta() async {
    if (kIsWeb) return null;
    try {
      final base = await getTemporaryDirectory();
      final dir = Directory('${base.path}/$clave');
      return await dir.exists() ? dir : null;
    } catch (_) {
      return null;
    }
  }

  static Future<({int archivos, int bytes, String ruta})> m_estadisticas() async {
    final dir = await m_carpeta();
    if (dir == null) return (archivos: 0, bytes: 0, ruta: kIsWeb ? 'caché del navegador' : '—');
    var n = 0;
    var b = 0;
    try {
      await for (final e in dir.list(recursive: true, followLinks: false)) {
        if (e is File) {
          n++;
          b += await e.length();
        }
      }
    } catch (_) {}
    return (archivos: n, bytes: b, ruta: dir.path);
  }

  static Future<void> m_vacia() => manager.emptyCache();

  static String m_formatoBytes(int b) {
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    return '${(b / 1024 / 1024).toStringAsFixed(2)} MB';
  }
}
