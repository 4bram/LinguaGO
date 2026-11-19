import 'package:flutter/material.dart';
import 'package:lingua_go/config/firestore_usuario.dart';
import 'package:lingua_go/config/sonidos_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasProvider extends ChangeNotifier {
  final FirestoreUsuario _fs = FirestoreUsuario();
  String? _uid;
  ThemeMode modo = ThemeMode.light;
  bool onboardingVisto = false;
  bool cargado = false;
  bool sonidos = true;
  bool splashTerminado = false;
  int paginaOnboarding = 0;

  PreferenciasProvider() {
    _carga();
  }

  bool get esOscuro => modo == ThemeMode.dark;

  Future<void> _carga() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      onboardingVisto = prefs.getBool('onboarding') ?? false;
    } catch (_) {}
    cargado = true;
    notifyListeners();
  }

  Future<void> m_cargaUsuario(String uid) async {
    _uid = uid;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_uid == uid) {
        modo = (prefs.getBool('oscuro_$uid') ?? false) ? ThemeMode.dark : ThemeMode.light;
        sonidos = prefs.getBool('sonidos_$uid') ?? true;
        SonidosService.activo = sonidos;
        notifyListeners();
      }
    } catch (_) {}

    final remoto = await _fs.m_leePreferencias(uid);
    if (_uid != uid || remoto == null) return;

    final oscuro = remoto['oscuro'];
    final conSonido = remoto['sonidos'];
    if (oscuro is bool) modo = oscuro ? ThemeMode.dark : ThemeMode.light;
    if (conSonido is bool) {
      sonidos = conSonido;
      SonidosService.activo = conSonido;
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (oscuro is bool) await prefs.setBool('oscuro_$uid', oscuro);
      if (conSonido is bool) await prefs.setBool('sonidos_$uid', conSonido);
    } catch (_) {}
  }


  void m_limpiaUsuario() {
    _uid = null;
    modo = ThemeMode.light;
    sonidos = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  Future<void> m_cambiaTema(bool oscuro) async {
    modo = oscuro ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final uid = _uid;
    if (uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('oscuro_$uid', oscuro);
    } catch (_) {}
    await _fs.m_guardaTema(uid, oscuro);
  }

  Future<void> m_cambiaSonidos(bool v) async {
    sonidos = v;
    SonidosService.activo = v;
    notifyListeners();
    if (v) SonidosService.m_presionar();
    final uid = _uid;
    if (uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sonidos_$uid', v);
    } catch (_) {}
    await _fs.m_guardaPreferencia(uid, 'sonidos', v);
  }

  void m_terminaSplash() {
    splashTerminado = true;
    notifyListeners();
  }

  void m_paginaOnboarding(int pagina) {
    paginaOnboarding = pagina;
    notifyListeners();
  }

  Future<void> m_terminaOnboarding() async {
    onboardingVisto = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding', true);
    } catch (_) {}
  }
}
