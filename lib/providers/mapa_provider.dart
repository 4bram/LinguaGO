import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lingua_go/models/sede_model.dart';

class MapaProvider extends ChangeNotifier {
  final MapController controlador = MapController();
  int indice = 0;

  SedeModel get sede => SedeModel.sedes[indice];

  void m_selecciona(int i) {
    indice = i;
    notifyListeners();
    try {
      controlador.move(SedeModel.sedes[i].ubicacion, 16);
    } catch (_) {}
  }

  void m_verTodas() {
    try {
      controlador.fitCamera(
        CameraFit.coordinates(
          coordinates: [for (final s in SedeModel.sedes) s.ubicacion],
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 220),
        ),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }
}
