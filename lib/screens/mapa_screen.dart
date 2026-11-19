import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lingua_go/components/encabezado_curvo.dart';
import 'package:lingua_go/components/responsive.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/models/sede_model.dart';
import 'package:lingua_go/providers/mapa_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  Future<void> _abre(BuildContext context, Uri uri, String error) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication)
        .catchError((_) => false);
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapaProvider(),
      child: Column(
        children: [
          if (!Responsivo.esBaja(context)) const EncabezadoCurvo(
            alto: 150,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 20, 22),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VISÍTANOS', style: TextStyle(color: Colors.white70)),
                      Text(
                        'NUESTRAS SEDES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<MapaProvider>(
              builder: (context, m, _) => Stack(
                children: [
                  FlutterMap(
                    mapController: m.controlador,
                    options: MapOptions(
                      initialCenter: m.sede.ubicacion,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'mx.edu.lingua_go',
                      ),
                      MarkerLayer(
                        markers: [
                          for (var i = 0; i < SedeModel.sedes.length; i++)
                            Marker(
                              point: SedeModel.sedes[i].ubicacion,
                              width: 64,
                              height: 64,
                              alignment: Alignment.topCenter,
                              child: GestureDetector(
                                onTap: () => m.m_selecciona(i),
                                child: Icon(
                                  Icons.location_on,
                                  color: i == m.indice ? ThemeApp.morado : Colors.orange,
                                  size: i == m.indice ? 56 : 40,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: FloatingActionButton.small(
                      heroTag: 'mapa_todas',
                      tooltip: 'Ver todas las sedes',
                      backgroundColor: Colors.white,
                      foregroundColor: ThemeApp.morado,
                      onPressed: m.m_verTodas,
                      child: const Icon(Icons.zoom_out_map),
                    ),
                  ),
                  Align(
                    alignment: MediaQuery.sizeOf(context).width >= 900
                        ? Alignment.bottomLeft
                        : Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  for (var i = 0; i < SedeModel.sedes.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(SedeModel.sedes[i].nombre.split('· ').last),
                                        selected: i == m.indice,
                                        onSelected: (_) => m.m_selecciona(i),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            _tarjetaSede(context, m.sede, Responsivo.esBaja(context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 6,
                    top: 4,
                    child: Text(
                      '© OpenStreetMap',
                      style: TextStyle(fontSize: 10, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaSede(BuildContext context, SedeModel sede, bool compacta) {
    final abierta = sede.m_abiertaAhora();
    return Card(
      elevation: 6,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: ThemeApp.morado),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(sede.nombre, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            if (!compacta) ...[
              const SizedBox(height: 4),
              Text(sede.direccion, style: const TextStyle(fontSize: 12)),
              Text(sede.horarioTexto, style: const TextStyle(fontSize: 12)),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.circle, size: 10, color: abierta ? Colors.green : Colors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    sede.m_estadoTexto(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: abierta ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _abre(
                      context,
                      Uri.parse(
                        'https://www.google.com/maps/dir/?api=1&destination='
                        '${sede.ubicacion.latitude},${sede.ubicacion.longitude}',
                      ),
                      'No se pudo abrir la app de mapas.',
                    ),
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Cómo llegar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _abre(
                      context,
                      Uri(scheme: 'tel', path: sede.telefono),
                      'No se pudo abrir el marcador.',
                    ),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Llamar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
