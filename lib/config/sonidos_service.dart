import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Efectos de sonido de LinguaGo. Los archivos viven en el APK
/// (carpeta `assets/sonidos/`), así que suenan SIN internet.
/// Si falta un archivo o el dispositivo no puede reproducirlo, simplemente
/// no suena (nunca falla).
///
/// ── Sonidos principales (los de la app de referencia, .wav) ──────────────
///   inicio.wav       pantalla de carga al abrir la app
///   sfx_toque.wav    cualquier toque corto en la pantalla
///   sfx_abrir.wav    se abre una pantalla, hoja o diálogo
///   sfx_cerrar.wav   se cierra una pantalla, hoja o diálogo
///   sfx_exito.wav    algo se completó (actividad, respuesta correcta, cuenta creada)
///   sfx_logro.wav    trofeo: certificado, compra, plan activado
///   sfx_portada.wav  se abre una unidad o un contenido (como la portada de un libro)
///   sfx_guia.wav     ambiente en bucle durante la introducción (onboarding)
///
/// ── Sonidos suaves de antes (se conservan en 2 momentos) ─────────────────
///   burbuja.mp3         agregar al carrito
///   burbuja2soft.mp3    quitar del carrito / voltear una tarjeta
enum Sfx { toque, abrir, cerrar, exito, logro, portada, burbuja, burbujaSuave }

class SonidosService {
  SonidosService._();

  static const Map<Sfx, String> _archivos = {
    Sfx.toque: 'sfx_toque.wav',
    Sfx.abrir: 'sfx_abrir.wav',
    Sfx.cerrar: 'sfx_cerrar.wav',
    Sfx.exito: 'sfx_exito.wav',
    Sfx.logro: 'sfx_logro.wav',
    Sfx.portada: 'sfx_portada.wav',
    Sfx.burbuja: 'burbuja.mp3',
    Sfx.burbujaSuave: 'burbuja2soft.mp3',
  };

  // ───────── Interruptor (preferencia POR USUARIO, ver PreferenciasProvider) ─────────
  static bool _activo = true;
  static bool get activo => _activo;
  static set activo(bool v) {
    _activo = v;
    if (!v) {
      m_detenerBucle();
      m_detieneInicio();
    }
    _guardaUltimo(v);
  }

  /// Se recuerda el último valor en el dispositivo para respetarlo también
  /// ANTES de iniciar sesión (pantalla de carga, onboarding y login).
  static void _guardaUltimo(bool v) {
    SharedPreferences.getInstance()
        .then((p) => p.setBool('sonidos_ultimo', v))
        .catchError((_) => false);
  }

  /// Se llama una vez en main(): lee el último valor y configura el audio
  /// para que los efectos NO pausen la música que el usuario tenga puesta.
  static Future<void> m_inicializa() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _activo = prefs.getBool('sonidos_ultimo') ?? true;
    } catch (_) {}
    try {
      await AudioPlayer.global.setAudioContext(AudioContext(
        android: const AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
        iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
      ));
    } catch (_) {}
  }

  // ───────── Efectos cortos (un reproductor por sonido: no se cortan entre sí) ─────────
  static final Map<Sfx, AudioPlayer> _jugadores = {};

  static Future<void> _toca(Sfx s, double volumen) async {
    if (!_activo) return;
    try {
      final p = _jugadores.putIfAbsent(s, () {
        final a = AudioPlayer();
        a.setPlayerMode(PlayerMode.lowLatency);
        return a;
      });
      await p.stop();
      await p.play(AssetSource('sonidos/${_archivos[s]}'), volume: volumen);
    } catch (_) {
      // Un sonido que falla nunca debe romper la app.
    }
  }

  static Future<void> m_toque({double volumen = 0.4}) => _toca(Sfx.toque, volumen);
  static Future<void> m_abrir({double volumen = 0.45}) => _toca(Sfx.abrir, volumen);
  static Future<void> m_cerrar({double volumen = 0.45}) => _toca(Sfx.cerrar, volumen);
  static Future<void> m_exito({double volumen = 0.7}) => _toca(Sfx.exito, volumen);
  static Future<void> m_logro({double volumen = 0.8}) => _toca(Sfx.logro, volumen);
  static Future<void> m_portada({double volumen = 0.7}) => _toca(Sfx.portada, volumen);
  static Future<void> m_burbuja() => _toca(Sfx.burbuja, 0.7);
  static Future<void> m_burbujaSuave() => _toca(Sfx.burbujaSuave, 0.6);

  // Nombres anteriores (para que el resto de la app siga funcionando)
  static Future<void> m_presionar() => m_toque();
  static Future<void> m_celebra() => m_logro();
  static Future<void> m_transicion() => m_abrir(volumen: 0.3);

  // ───────── Toque corto en cualquier parte de la pantalla ─────────
  static Offset? _abajo;
  static Duration? _desde;

  static void m_punteroAbajo(PointerDownEvent e) {
    _abajo = e.position;
    _desde = e.timeStamp;
  }

  /// Suena solo si fue un toque corto (no al desplazar la pantalla).
  static void m_punteroArriba(PointerUpEvent e) {
    final a = _abajo, d = _desde;
    _abajo = null;
    _desde = null;
    if (a == null || d == null) return;
    if ((e.position - a).distance < 12 && (e.timeStamp - d).inMilliseconds < 350) {
      m_toque();
    }
  }

  static void m_olvidaPuntero() {
    _abajo = null;
    _desde = null;
  }

  // ───────── Sonido de inicio (pantalla de carga) ─────────
  static AudioPlayer? _inicio;

  static Future<void> m_inicio({double volumen = 0.8}) async {
    if (!_activo) return;
    try {
      _inicio ??= AudioPlayer();
      await _inicio!.setReleaseMode(ReleaseMode.stop);
      await _inicio!.play(AssetSource('sonidos/inicio.wav'), volume: volumen);
    } catch (_) {}
  }

  static Future<void> m_detieneInicio() async {
    try {
      await _inicio?.stop();
    } catch (_) {}
  }

  // ───────── Ambiente en bucle (onboarding) ─────────
  static AudioPlayer? _bucle;
  static Timer? _fade;
  static bool _bucleActivo = false;

  /// Reproduce `assets/sonidos/<archivo>` en bucle hasta m_detenerBucle().
  static Future<void> m_iniciaBucle(String archivo, {double volumen = 0.3}) async {
    if (!_activo || _bucleActivo) return;
    _bucleActivo = true;
    _fade?.cancel();
    try {
      final p = _bucle ??= AudioPlayer();
      // mediaPlayer (no lowLatency): es el modo que repite sin cortes.
      await p.setPlayerMode(PlayerMode.mediaPlayer);
      await p.setReleaseMode(ReleaseMode.loop);
      await p.play(AssetSource('sonidos/$archivo'), volume: volumen);
    } catch (_) {
      _bucleActivo = false;
    }
  }

  /// Baja el volumen rápido y detiene el bucle.
  static Future<void> m_detenerBucle() async {
    if (!_bucleActivo) return;
    _bucleActivo = false;
    final p = _bucle;
    if (p == null) return;
    _fade?.cancel();
    final v0 = p.volume;
    _rampa(p, v0, 0, const Duration(milliseconds: 150), alTerminar: () {
      try {
        p.stop();
      } catch (_) {}
    });
  }

  static void _rampa(AudioPlayer p, double de, double a, Duration d,
      {VoidCallback? alTerminar}) {
    _fade?.cancel();
    const paso = 40;
    final pasos = d.inMilliseconds ~/ paso;
    var i = 0;
    _fade = Timer.periodic(const Duration(milliseconds: paso), (t) {
      i++;
      final k = (i / pasos).clamp(0.0, 1.0).toDouble();
      try {
        p.setVolume(de + (a - de) * k);
      } catch (_) {}
      if (i >= pasos) {
        t.cancel();
        alTerminar?.call();
      }
    });
  }
}

/// Suena al abrir y cerrar cualquier pantalla, hoja o diálogo.
class SonidoObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) SonidosService.m_abrir();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    SonidosService.m_cerrar();
  }
}
