import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lingua_go/config/cache_imagenes.dart';
import 'package:lingua_go/config/firestore_unidades.dart';
import 'package:lingua_go/config/firestore_usuario.dart';
import 'package:lingua_go/models/unidad_model.dart';

class UnidadesProvider extends ChangeNotifier {
  static const int umbral = 70;

  static const List<String> actividadesMaterial = [
    'leccion',
    'tarjetas',
    'escucha',
    'gramatica',
    'escritura',
  ];

  final FirestoreUnidades _fsUnidades = FirestoreUnidades();
  final FirestoreUsuario _fsUsuario = FirestoreUsuario();

  List<UnidadModel> unidades = [];
  Map<String, Map<String, dynamic>> _progreso = {};
  bool cargando = true;
  String? error;
  String? _uid;
  StreamSubscription<List<UnidadModel>>? _subU;
  StreamSubscription<Map<String, Map<String, dynamic>>>? _subP;

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
      _precargaImagenes(lista);
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

  final Set<String> _precargadas = {};

  void _precargaImagenes(List<UnidadModel> lista) {
    final nuevas = CacheImagenes.m_urls(unidades: lista)
        .where((u) => _precargadas.add(u))
        .toList();
    if (nuevas.isNotEmpty) CacheImagenes.m_precarga(nuevas);
  }

  void m_detiene() {
    _subU?.cancel();
    _subP?.cancel();
    _subU = null;
    _subP = null;
    unidades = [];
    _progreso = {};
    _uid = null;
    cargando = true;
  }

  UnidadModel? m_porId(String id) {
    for (final u in unidades) {
      if (u.id == id) return u;
    }
    return null;
  }

  Map<String, dynamic> _doc(UnidadModel u) =>
      _progreso.putIfAbsent(u.id, () => <String, dynamic>{});

  Set<String> m_actividadesCap(UnidadModel u, int i) {
    final raw = _progreso[u.id]?['actividades'];
    if (raw is Map) {
      final lista = raw['$i'];
      if (lista is List) return lista.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  int m_pctCapitulo(UnidadModel u, int i) {
    final hechas = m_actividadesCap(u, i);
    final total = actividadesMaterial.length + 1;
    var n = actividadesMaterial.where(hechas.contains).length;
    if (hechas.contains('evaluacion')) n++;
    return (n * 100 / total).round();
  }

  List<int> m_progresoDe(UnidadModel u) =>
      List.generate(u.capitulos.length, (i) => m_pctCapitulo(u, i));

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

  Map<String, dynamic>? m_evalCapitulo(UnidadModel u, int i) {
    final raw = _progreso[u.id]?['evaluaciones'];
    if (raw is Map && raw['$i'] is Map) {
      return Map<String, dynamic>.from(raw['$i'] as Map);
    }
    return null;
  }

  Map<String, dynamic>? m_evalUnidad(UnidadModel u) {
    final raw = _progreso[u.id]?['final'];
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  bool m_unidadAprobada(UnidadModel u) => m_evalUnidad(u)?['aprobada'] == true;

  int m_porcentajeUnidad(UnidadModel u) {
    final lista = m_progresoDe(u);
    final suma = lista.fold<int>(0, (a, b) => a + b) + (m_unidadAprobada(u) ? 100 : 0);
    return (suma / (lista.length + 1)).round();
  }

  bool m_desbloqueada(UnidadModel u) {
    if (u.orden <= 1) return true;
    final anterior = unidades.where((x) => x.orden == u.orden - 1).firstOrNull;
    if (anterior == null) return true;
    return m_unidadAprobada(anterior);
  }

  UnidadModel? m_anterior(UnidadModel u) =>
      unidades.where((x) => x.orden == u.orden - 1).firstOrNull;

  void _guarda(String unidadId, Map<String, dynamic> datos) {
    if (_uid != null) _fsUsuario.m_guardaProgreso(_uid!, unidadId, datos);
  }

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
    _guarda(u.id, {'actividades': {'$cap': hechas.toList()}});
  }

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
      m_completaActividad(u, cap, 'evaluacion');
    } else {
      notifyListeners();
    }
  }

  Future<bool> m_registraEvaluacionUnidad(
    UnidadModel u,
    int porcentaje,
  ) async {
    final previa = m_evalUnidad(u);
    final aprobadaAntes = previa?['aprobada'] == true;
    final aprueba = porcentaje >= umbral;
    final datos = <String, dynamic>{
      'mejor': max(porcentaje, (previa?['mejor'] as num?)?.toInt() ?? 0),
      'ultimo': porcentaje,
      'intentos': ((previa?['intentos'] as num?)?.toInt() ?? 0) + 1,
      'fecha': DateTime.now().toIso8601String(),
      'aprobada': aprobadaAntes || aprueba,
    };
    _doc(u)['final'] = datos;
    notifyListeners();
    _guarda(u.id, {'final': datos});
    return aprueba;
  }

  @override
  void dispose() {
    _subU?.cancel();
    _subP?.cancel();
    super.dispose();
  }
}
