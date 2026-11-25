import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SonidosService {
  SonidosService._();

  static bool _activo = true;
  static bool get activo => _activo;
  static set activo(bool v) {
    _activo = v;
    SharedPreferences.getInstance()
        .then((p) => p.setBool('sonidos_ultimo', v))
        .catchError((_) => false);
  }

  static AudioPlayer? _jugador;
  static AudioPlayer? _jugadorCompra;
  static AudioPlayer? _jugadorAcierto;

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

  static Future<void> m_click({double volumen = 0.5}) async {
    if (!_activo) return;
    try {
      final p = _jugador ??= AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
      await p.stop();
      await p.play(AssetSource('sonidos/click.mp3'), volume: volumen);
    } catch (_) {}
  }

  static Future<void> m_compra({double volumen = 0.9}) async {
    if (!_activo) return;
    try {
      final p = _jugadorCompra ??= AudioPlayer();
      await p.stop();
      await p.play(AssetSource('sonidos/compra.mp3'), volume: volumen);
    } catch (_) {}
  }

  static Future<void> m_acierto({double volumen = 0.9}) async {
    if (!_activo) return;
    try {
      final p = _jugadorAcierto ??= AudioPlayer();
      await p.stop();
      await p.play(AssetSource('sonidos/acierto.mp3'), volume: volumen);
    } catch (_) {}
  }

  static Offset? _abajo;
  static Duration? _desde;

  static void m_punteroAbajo(PointerDownEvent e) {
    _abajo = e.position;
    _desde = e.timeStamp;
  }

  static void m_punteroArriba(PointerUpEvent e) {
    final a = _abajo, d = _desde;
    _abajo = null;
    _desde = null;
    if (a == null || d == null) return;
    if ((e.position - a).distance < 12 && (e.timeStamp - d).inMilliseconds < 350) {
      m_click();
    }
  }

  static void m_olvidaPuntero() {
    _abajo = null;
    _desde = null;
  }
}
