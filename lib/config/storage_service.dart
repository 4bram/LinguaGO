import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Almacenamiento en SUPABASE STORAGE (el resto de la app —Auth, Firestore,
/// FCM— sigue en Firebase):
///   - bucket "imagenes" (la app sube): fotos de perfil, imágenes de unidades
///     (solo administradores) y CERTIFICADOS PNG de las unidades aprobadas.
///   - bucket "recursos" (solo lectura desde la app; el administrador sube los
///     archivos desde el panel de Supabase): PDF descargables y portadas de los
///     productos de la tienda.
///
/// Configuración en el `.env`:
///   SUPABASE_URL=https://xxxx.supabase.co
///   SUPABASE_ANON_KEY=<clave anon / publishable del proyecto>
/// (la clave anon es pública por diseño; lo que protege el bucket son sus
/// políticas, ver README).
class StorageService {
  /// Bucket público donde la app puede subir imágenes.
  static const String _bucket = 'imagenes';

  /// Bucket público de solo lectura con los archivos de la tienda.
  static const String bucketRecursos = 'recursos';

  /// URL pública de un archivo del bucket de recursos (PDF, audio, portada…).
  String m_urlRecurso(String ruta) {
    final base = _env('SUPABASE_URL').replaceAll(RegExp(r'/+$'), '');
    return '$base/storage/v1/object/public/$bucketRecursos/$ruta';
  }

  bool get configurado =>
      _env('SUPABASE_URL').isNotEmpty && _env('SUPABASE_ANON_KEY').isNotEmpty;

  String _env(String nombre) {
    try {
      return (dotenv.maybeGet(nombre) ?? '').trim();
    } catch (_) {
      return '';
    }
  }

  /// Nombre único por subida para que la caché local no muestre la foto vieja.
  Future<String> m_subirFotoPerfil(String uid, Uint8List bytes) {
    return _sube('perfiles/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg', bytes);
  }

  Future<String> m_subirImagenUnidad(String unidadId, Uint8List bytes) {
    return _sube('unidades/$unidadId/${DateTime.now().millisecondsSinceEpoch}.jpg', bytes);
  }

  /// Certificado (PNG) de una unidad aprobada.
  Future<String> m_subirCertificado(String uid, String unidadId, Uint8List bytes) {
    return _sube(
      'certificados/$uid/${unidadId}_${DateTime.now().millisecondsSinceEpoch}.png',
      bytes,
      tipo: 'image/png',
    );
  }

  /// Sube la imagen y devuelve su URL pública (la que se guarda en Firebase
  /// y la que cachea cached_network_image para verse sin conexión).
  Future<String> _sube(String ruta, Uint8List bytes, {String tipo = 'image/jpeg'}) async {
    final base = _env('SUPABASE_URL').replaceAll(RegExp(r'/+$'), '');
    final clave = _env('SUPABASE_ANON_KEY');
    if (base.isEmpty || clave.isEmpty) {
      throw Exception('Falta configurar SUPABASE_URL y SUPABASE_ANON_KEY en el .env');
    }

    // Las claves anon antiguas son JWT (eyJ...) y van también en Authorization;
    // las nuevas "publishable" (sb_publishable_...) solo van en apikey.
    final esJwt = clave.startsWith('eyJ');
    final respuesta = await http
        .post(
          Uri.parse('$base/storage/v1/object/$_bucket/$ruta'),
          headers: {
            'apikey': clave,
            if (esJwt) 'Authorization': 'Bearer $clave',
            'Content-Type': tipo,
          },
          body: bytes,
        )
        .timeout(const Duration(seconds: 45));

    if (respuesta.statusCode >= 300) {
      throw Exception('Supabase respondió ${respuesta.statusCode}: ${respuesta.body}');
    }
    return '$base/storage/v1/object/public/$_bucket/$ruta';
  }
}
