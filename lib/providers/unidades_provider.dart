import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lingua_go/config/certificado_service.dart';
import 'package:lingua_go/config/firestore_unidades.dart';
import 'package:lingua_go/config/firestore_usuario.dart';
import 'package:lingua_go/config/sonidos_service.dart';
import 'package:lingua_go/config/storage_service.dart';
import 'package:lingua_go/models/unidad_model.dart';

/// Un certificado ya emitido (imagen guardada en Supabase Storage).
class CertificadoInfo {
  final String unidadId;
  final String unidadNombre;
  final int unidadNumero;
  final int porcentaje;
  final String url;
  final String fecha;

  const CertificadoInfo({
    required this.unidadId,
    required this.unidadNombre,
    required this.unidadNumero,
    required this.porcentaje,
    required this.url,
    required this.fecha,
  });
}

/// Unidades (tiempo real desde Firestore) y progreso del usuario.
///
/// Reglas de avance:
///  - Un capítulo se completa (100 %) cuando se terminan TODAS sus actividades
///    (lección, tarjetas, escucha, gramática, escritura) y se aprueba su
///    evaluación con al menos 70 %.
///  - La evaluación del capítulo solo se abre cuando el material está completo.
///  - La evaluación final de la unidad solo se abre con todos los capítulos al
///    100 % y, al aprobarla (>= 70 %), desbloquea la siguiente unidad y emite
///    un certificado.
class UnidadesProvider extends ChangeNotifier {
  static const int umbral = 70;

  /// Actividades obligatorias de cada capítulo (además de su evaluación).
  static const List<String> actividadesMaterial = [
    'leccion',
    'tarjetas',
    'escucha',
    'gramatica',
    'escritura',
  ];

  final FirestoreUnidades _fsUnidades = FirestoreUnidades();
  final FirestoreUsuario _fsUsuario = FirestoreUsuario();
  final StorageService _storage = StorageService();
  final CertificadoService _certificados = CertificadoService();

  List<UnidadModel> unidades = [];
  Map<String, Map<String, dynamic>> _progreso = {};
  bool cargando = true;
  bool generandoCertificado = false;
  String? error;
  String? _uid;
  StreamSubscription<List<UnidadModel>>? _subU;
  StreamSubscription<Map<String, Map<String, dynamic>>>? _subP;

  /// Se llama desde el Dashboard (después del primer frame).
  void m_iniciaEscucha(String uid) {
    _uid = uid;
    cargando = true;
    error = null;
    notifyListeners();

    _fsUnidades.m_sincronizaCatalogo();

    _subU?.cancel();
    _subU = _fsUnidades.m_select().listen((lista) {
      unidades = lista;
      cargando = false;
      notifyListeners();
    }, onError: (e) {
      error = 'No se pudieron cargar las unidades: $e';
      cargando = false;
      notifyListeners();
    });

    _subP?.cancel();
    _subP = _fsUsuario.m_selectProgreso(uid).listen((mapa) {
      _progreso = mapa;
      notifyListeners();
    }, onError: (_) {});
  }

  /// Se llama al cerrar el dashboard. No notifica (el widget se está destruyendo).
  void m_detiene() {
    _subU?.cancel();
    _subP?.cancel();
    _subU = null;
    _subP = null;
    unidades = [];
    _progreso = {};
    _uid = null;
    cargando = true;
    generandoCertificado = false;
  }

  UnidadModel? m_porId(String id) {
    for (final u in unidades) {
      if (u.id == id) return u;
    }
    return null;
  }

  // ---------------------------------------------------------------- lectura

  Map<String, dynamic> _doc(UnidadModel u) =>
      _progreso.putIfAbsent(u.id, () => <String, dynamic>{});

  /// Actividades terminadas del capítulo [i] ('leccion', 'tarjetas', ... 'evaluacion').
  Set<String> m_actividadesCap(UnidadModel u, int i) {
    final raw = _progreso[u.id]?['actividades'];
    if (raw is Map) {
      final lista = raw['$i'];
      if (lista is List) return lista.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  /// 0 - 100: cada actividad obligatoria + la evaluación aportan lo mismo.
  int m_pctCapitulo(UnidadModel u, int i) {
    final hechas = m_actividadesCap(u, i);
    final total = actividadesMaterial.length + 1;
    var n = actividadesMaterial.where(hechas.contains).length;
    if (hechas.contains('evaluacion')) n++;
    return (n * 100 / total).round();
  }

  List<int> m_progresoDe(UnidadModel u) =>
      List.generate(u.capitulos.length, (i) => m_pctCapitulo(u, i));

  /// ¿Ya terminó todo el material del capítulo (falta solo la evaluación)?
  bool m_materialCompleto(UnidadModel u, int i) {
    final hechas = m_actividadesCap(u, i);
    return actividadesMaterial.every(hechas.contains);
  }

  bool m_capituloCompleto(UnidadModel u, int i) => m_pctCapitulo(u, i) >= 100;

  bool m_capitulosCompletos(UnidadModel u) {
    if (u.capitulos.isEmpty) return false;
    for (int i = 0; i < u.capitulos.length; i++) {
      if (!m_capituloCompleto(u, i)) return false;
    }
    return true;
  }

  /// Resultado guardado de la evaluación del capítulo: mejor, ultimo, intentos, fecha.
  Map<String, dynamic>? m_evalCapitulo(UnidadModel u, int i) {
    final raw = _progreso[u.id]?['evaluaciones'];
    if (raw is Map && raw['$i'] is Map) {
      return Map<String, dynamic>.from(raw['$i'] as Map);
    }
    return null;
  }

  /// Resultado guardado de la evaluación final: mejor, ultimo, intentos, aprobada, fecha, certificadoUrl.
  Map<String, dynamic>? m_evalUnidad(UnidadModel u) {
    final raw = _progreso[u.id]?['final'];
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  bool m_unidadAprobada(UnidadModel u) => m_evalUnidad(u)?['aprobada'] == true;

  /// Promedio de los capítulos y de la evaluación final (que vale como un elemento más).
  int m_porcentajeUnidad(UnidadModel u) {
    final lista = m_progresoDe(u);
    final suma = lista.fold<int>(0, (a, b) => a + b) + (m_unidadAprobada(u) ? 100 : 0);
    return (suma / (lista.length + 1)).round();
  }

  /// La unidad 1 siempre está abierta; las demás se abren al aprobar la anterior.
  bool m_desbloqueada(UnidadModel u) {
    if (u.orden <= 1) return true;
    final anterior = unidades.where((x) => x.orden == u.orden - 1).firstOrNull;
    if (anterior == null) return true;
    return m_unidadAprobada(anterior);
  }

  UnidadModel? m_anterior(UnidadModel u) =>
      unidades.where((x) => x.orden == u.orden - 1).firstOrNull;

  /// Certificados emitidos (para la pantalla "Mis certificados").
  List<CertificadoInfo> get certificados {
    final lista = <CertificadoInfo>[];
    for (final u in unidades) {
      final f = m_evalUnidad(u);
      final url = '${f?['certificadoUrl'] ?? ''}';
      if (f != null && url.isNotEmpty) {
        lista.add(CertificadoInfo(
          unidadId: u.id,
          unidadNombre: u.nombre,
          unidadNumero: u.orden,
          porcentaje: (f['mejor'] as num?)?.toInt() ?? 0,
          url: url,
          fecha: '${f['fecha'] ?? ''}',
        ));
      }
    }
    return lista;
  }

  // -------------------------------------------------------------- escritura

  void _guarda(String unidadId, Map<String, dynamic> datos) {
    if (_uid != null) _fsUsuario.m_guardaProgreso(_uid!, unidadId, datos);
  }

  /// Marca una actividad del capítulo como terminada (solo una vez).
  void m_completaActividad(UnidadModel u, int cap, String tipo) {
    if (cap < 0 || cap >= u.capitulos.length) return;
    final hechas = m_actividadesCap(u, cap);
    if (hechas.contains(tipo)) return;
    hechas.add(tipo);
    final doc = _doc(u);
    final acts = Map<String, dynamic>.from((doc['actividades'] as Map?) ?? const {});
    acts['$cap'] = hechas.toList();
    doc['actividades'] = acts;
    notifyListeners();
    SonidosService.m_exito();
    _guarda(u.id, {'actividades': {'$cap': hechas.toList()}});
  }

  /// Guarda el resultado de la evaluación de un capítulo (siempre) y, si se
  /// aprueba con >= 70 %, completa el capítulo.
  void m_registraEvaluacionCapitulo(UnidadModel u, int cap, int porcentaje) {
    if (cap < 0 || cap >= u.capitulos.length) return;
    final previa = m_evalCapitulo(u, cap);
    final datos = <String, dynamic>{
      'mejor': max(porcentaje, (previa?['mejor'] as num?)?.toInt() ?? 0),
      'ultimo': porcentaje,
      'intentos': ((previa?['intentos'] as num?)?.toInt() ?? 0) + 1,
      'fecha': DateTime.now().toIso8601String(),
    };
    final doc = _doc(u);
    final evals = Map<String, dynamic>.from((doc['evaluaciones'] as Map?) ?? const {});
    evals['$cap'] = datos;
    doc['evaluaciones'] = evals;
    _guarda(u.id, {'evaluaciones': {'$cap': datos}});
    if (porcentaje >= umbral) {
      m_completaActividad(u, cap, 'evaluacion'); // notifica
    } else {
      notifyListeners();
    }
  }

  /// Guarda la evaluación final. Si se aprueba, desbloquea la siguiente
  /// unidad y genera el certificado (se sube a Supabase Storage).
  /// Devuelve true si se aprobó (>= 70 %).
  Future<bool> m_registraEvaluacionUnidad(
    UnidadModel u,
    int porcentaje, {
    required String nombre,
  }) async {
    final previa = m_evalUnidad(u);
    final aprobadaAntes = previa?['aprobada'] == true;
    final aprueba = porcentaje >= umbral;
    final datos = <String, dynamic>{
      'mejor': max(porcentaje, (previa?['mejor'] as num?)?.toInt() ?? 0),
      'ultimo': porcentaje,
      'intentos': ((previa?['intentos'] as num?)?.toInt() ?? 0) + 1,
      'fecha': DateTime.now().toIso8601String(),
      'aprobada': aprobadaAntes || aprueba,
      if ('${previa?['certificadoUrl'] ?? ''}'.isNotEmpty)
        'certificadoUrl': previa!['certificadoUrl'],
    };
    _doc(u)['final'] = datos;
    notifyListeners();
    _guarda(u.id, {'final': datos});
    if (aprueba) SonidosService.m_exito();

    final sinCertificado = '${datos['certificadoUrl'] ?? ''}'.isEmpty;
    if (aprueba && sinCertificado && _uid != null) {
      await _emiteCertificado(u, porcentaje, nombre);
      SonidosService.m_celebra();
    }
    return aprueba;
  }

  Future<void> _emiteCertificado(UnidadModel u, int porcentaje, String nombre) async {
    final uid = _uid;
    if (uid == null) return;
    generandoCertificado = true;
    notifyListeners();
    try {
      final bytes = await _certificados.m_genera(
        nombre: nombre.isEmpty ? 'Estudiante LinguaGo' : nombre,
        unidad: u.nombre,
        unidadNumero: u.orden,
        porcentaje: porcentaje,
        fecha: DateTime.now(),
      );
      final url = await _storage.m_subirCertificado(uid, u.id, bytes);
      final final_ = Map<String, dynamic>.from((_progreso[u.id]?['final'] as Map?) ?? const {});
      final_['certificadoUrl'] = url;
      _doc(u)['final'] = final_;
      _guarda(u.id, {'final': {'certificadoUrl': url}});
    } catch (e) {
      debugPrint('No se pudo emitir el certificado: $e');
    }
    generandoCertificado = false;
    notifyListeners();
  }

  // ----------------------------------------------------------------- imagen

  /// Sube una imagen a Supabase Storage y la guarda en la unidad (solo admins).
  Future<String?> m_cambiaImagen(String unidadId) async {
    try {
      final img = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 80,
      );
      if (img == null) return null;
      final bytes = await img.readAsBytes();
      final url = await _storage.m_subirImagenUnidad(unidadId, bytes);
      _fsUnidades.m_actualizaImagen(unidadId, url);
      return null;
    } catch (e) {
      return 'No se pudo subir la imagen: $e';
    }
  }

  @override
  void dispose() {
    _subU?.cancel();
    _subP?.cancel();
    super.dispose();
  }
}
