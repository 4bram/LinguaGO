import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/models/sede_model.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: SedeModel.ubicacion,
            initialZoom: 16,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'mx.edu.lingua_go',
            ),
            const MarkerLayer(
              markers: [
                Marker(
                  point: SedeModel.ubicacion,
                  width: 56,
                  height: 56,
                  alignment: Alignment.topCenter,
                  child: Icon(Icons.location_on, color: ThemeApp.morado, size: 52),
                ),
              ],
            ),
          ],
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: const Card(
                  child: ListTile(
                    leading: Icon(Icons.school, color: ThemeApp.morado),
                    title: Text(SedeModel.nombre),
                    subtitle: Text(SedeModel.direccion),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 6,
          bottom: 4,
          child: Text('© OpenStreetMap', style: TextStyle(fontSize: 10, color: Colors.black87)),
        ),
      ],
    );
  }
}
