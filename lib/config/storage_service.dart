import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class StorageService {

  static const String _bucket = 'imagenes';

  static const String bucketRecursos = 'recursos';

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

  Future<String> m_subirFotoPerfil(String uid, Uint8List bytes) {
    return _sube('perfiles/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg', bytes);
  }

  Future<String> _sube(String ruta, Uint8List bytes, {String tipo = 'image/jpeg'}) async {
    final base = _env('SUPABASE_URL').replaceAll(RegExp(r'/+$'), '');
    final clave = _env('SUPABASE_ANON_KEY');
    if (base.isEmpty || clave.isEmpty) {
      throw Exception('Falta configurar SUPABASE_URL y SUPABASE_ANON_KEY en el .env');
    }

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
