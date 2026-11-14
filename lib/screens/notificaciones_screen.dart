import 'package:flutter/material.dart';
import 'package:lingua_go/components/responsive.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/providers/notificaciones_provider.dart';
import 'package:provider/provider.dart';

/// Suscripción a temas (FCM Topics) e historial de notificaciones recibidas.
class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificacionesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: ThemeApp.morado,
        foregroundColor: Colors.white,
      ),
      body: ContenedorCentrado(
        anchoMaximo: 600,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!prov.soportado)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Las notificaciones push solo están disponibles en Android e iOS'),
                ),
              ),
            const Text(
              'Temas de interés',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ...NotificacionesProvider.temasDisponibles.entries.map(
              (e) => SwitchListTile(
                title: Text(e.value),
                subtitle: Text('Tema: ${e.key}'),
                value: prov.temasActivos.contains(e.key),
                onChanged: (v) =>
                    context.read<NotificacionesProvider>().m_cambiaTema(e.key, v),
              ),
            ),
            const Divider(height: 28),
            if (prov.token != null) ...[
              const Text(
                'Token del dispositivo (para pruebas en la consola)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SelectableText(prov.token!, style: const TextStyle(fontSize: 11)),
              const Divider(height: 28),
            ],
            const Text(
              'Historial',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (prov.historial.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aún no has recibido notificaciones'),
              ),
            ...prov.historial.map(
              (n) => Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_active, color: ThemeApp.morado),
                  title: Text(n.titulo),
                  subtitle: Text('${n.cuerpo}\nRecibida con la app en: ${n.estado}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
