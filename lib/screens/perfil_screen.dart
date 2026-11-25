import 'package:lingua_go/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:lingua_go/components/avatar_usuario.dart';
import 'package:lingua_go/components/encabezado_curvo.dart';
import 'package:lingua_go/components/responsive.dart';
import 'package:lingua_go/providers/carrito_provider.dart';
import 'package:lingua_go/providers/guia_provider.dart';
import 'package:lingua_go/providers/nav_provider.dart';
import 'package:lingua_go/providers/preferencias_provider.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:lingua_go/providers/suscripcion_provider.dart';
import 'package:provider/provider.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  Future<void> _cambiarFoto(BuildContext context) async {
    final error = await context.read<SesionProvider>().m_cambiaFoto();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Foto actualizada'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final pref = context.watch<PreferenciasProvider>();
    final susc = context.watch<SuscripcionProvider>();

    return Column(
      children: [
        EncabezadoCurvo(
          alto: 230,
          child: SafeArea(
            bottom: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      const AvatarUsuario(radio: 48),
                      if (sesion.subiendoFoto)
                        const Positioned.fill(
                          child: Center(child: CircularProgressIndicator()),
                        ),

                      if (sesion.esCorreo)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: sesion.subiendoFoto ? null : () => _cambiarFoto(context),
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.camera_alt, size: 18),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      sesion.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      sesion.correo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ContenedorCentrado(
            anchoMaximo: 600,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Metodo de acceso'),
                  subtitle: Text(sesion.proveedor),
                ),
                if (!sesion.esCorreo)
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Foto de perfil'),
                    subtitle: Text('No puedes editar esto'),
                  ),
                ListTile(
                  leading: const Icon(Icons.workspace_premium),
                  title: const Text('Suscripcion'),
                  subtitle: Text(
                    susc.activa ? 'Plan ${susc.nombrePlan}' : 'Sin suscripcion activa',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.read<NavProvider>().m_cambia(2),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('Modo oscuro'),
                  value: pref.esOscuro,
                  onChanged: (v) => context.read<PreferenciasProvider>().m_cambiaTema(v),
                ),
                ListTile(
                  leading: const Icon(Icons.slideshow),
                  title: const Text('Ver introduccion'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OnboardingScreen(repetir: true)),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.explore),
                  title: const Text('Guia de la app'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.read<NavProvider>().m_cambia(0);
                    context.read<GuiaProvider>().m_inicia();
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up),
                  title: const Text('Sonido de clic'),
                  value: pref.sonidos,
                  onChanged: (v) => context.read<PreferenciasProvider>().m_cambiaSonidos(v),
                ),
                ListTile(
                  leading: const Icon(Icons.storefront),
                  title: const Text('Tienda'),
                  subtitle: Text('${context.watch<CarritoProvider>().biblioteca.length} comprados'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/tienda'),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notificaciones'),
                  subtitle: const Text('Temas e historial'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/notificaciones'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar sesion'),
                  subtitle: const Text('Salir'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.read<NavProvider>().m_cambia(0);
                    context.read<SesionProvider>().m_cerrarSesion();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
