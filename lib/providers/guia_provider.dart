import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasoGuia {
  final IconData icono;
  final String titulo;
  final String texto;
  final int pestana;

  const PasoGuia(this.icono, this.titulo, this.texto, this.pestana);
}

const List<PasoGuia> pasosGuia = [
  PasoGuia(
    Icons.menu_book,
    'Unidades',
    'Aqui estan las unidades del curso. Entra a una para ver vocabulario, flashcards y practica. '
        'Las que tienen candado se abren al aprobar la anterior o con un plan.',
    0,
  ),
  PasoGuia(
    Icons.map,
    'Mapa',
    'Aqui ves en el mapa donde esta la sede.',
    1,
  ),
  PasoGuia(
    Icons.workspace_premium,
    'Planes',
    'Elige un plan para entrar a todas las unidades. Se paga con tarjeta.',
    2,
  ),
  PasoGuia(
    Icons.person,
    'Perfil',
    'Aqui cambias tu foto (solo con correo), activas el modo oscuro, '
        'entras a la tienda y ves tus notificaciones.',
    3,
  ),
];

class GuiaProvider extends ChangeNotifier {
  bool activa = false;
  int paso = 0;
  String? _uid;

  bool get esUltimo => paso == pasosGuia.length - 1;

  Future<void> m_iniciaSiEsNueva(String uid) async {
    _uid = uid;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('guia_$uid') ?? false) return;
    } catch (_) {}
    if (_uid == uid) m_inicia();
  }

  void m_inicia() {
    paso = 0;
    activa = true;
    notifyListeners();
  }

  void m_siguiente() {
    if (esUltimo) return;
    paso++;
    notifyListeners();
  }

  void m_atras() {
    if (paso == 0) return;
    paso--;
    notifyListeners();
  }

  Future<void> m_termina() async {
    activa = false;
    paso = 0;
    notifyListeners();
    final uid = _uid;
    if (uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('guia_$uid', true);
    } catch (_) {}
  }

  void m_limpia() {
    _uid = null;
    activa = false;
    paso = 0;
  }
}
