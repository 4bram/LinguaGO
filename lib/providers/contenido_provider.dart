import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lingua_go/config/sonidos_service.dart';
import 'package:lingua_go/models/producto_model.dart';

class ContenidoProvider extends ChangeNotifier {
  final ProductoModel producto;
  final FlutterTts _tts = FlutterTts();
  bool _vozLista = false;

  String consulta = '';
  final Set<String> _volteadas = {};

  ContenidoProvider(this.producto);

  String _clave(int s, int i) => '$s-$i';

  bool m_estaVolteada(int s, int i) => _volteadas.contains(_clave(s, i));

  void m_voltea(int s, int i) {
    SonidosService.m_burbujaSuave();
    final k = _clave(s, i);
    if (!_volteadas.remove(k)) _volteadas.add(k);
    notifyListeners();
  }

  void m_buscar(String texto) {
    consulta = texto.trim().toLowerCase();
    notifyListeners();
  }

  List<MapEntry<int, List<MapEntry<int, ItemContenido>>>> get seccionesFiltradas {
    final r = <MapEntry<int, List<MapEntry<int, ItemContenido>>>>[];
    for (var s = 0; s < producto.secciones.length; s++) {
      final items = <MapEntry<int, ItemContenido>>[];
      final lista = producto.secciones[s].items;
      for (var i = 0; i < lista.length; i++) {
        final it = lista[i];
        if (consulta.isEmpty ||
            it.en.toLowerCase().contains(consulta) ||
            it.es.toLowerCase().contains(consulta) ||
            it.ejemplo.toLowerCase().contains(consulta)) {
          items.add(MapEntry(i, it));
        }
      }
      if (items.isNotEmpty) r.add(MapEntry(s, items));
    }
    return r;
  }

  Future<void> m_habla(String texto) async {
    try {
      if (!_vozLista) {
        await _tts.setLanguage('en-US');
        await _tts.setSpeechRate(0.45);
        _vozLista = true;
      }
      await _tts.stop();
      await _tts.speak(texto);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
