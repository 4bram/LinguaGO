import 'package:flutter/material.dart';
import 'package:lingua_go/components/responsive.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/providers/carrito_provider.dart';
import 'package:lingua_go/providers/nav_provider.dart';
import 'package:lingua_go/providers/notificaciones_provider.dart';
import 'package:lingua_go/providers/preferencias_provider.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:lingua_go/providers/suscripcion_provider.dart';
import 'package:lingua_go/providers/unidades_provider.dart';
import 'package:lingua_go/screens/mapa_screen.dart';
import 'package:lingua_go/screens/perfil_screen.dart';
//import 'package:lingua_go/screens/planes_screen.dart';
//import 'package:lingua_go/screens/unidades_screen.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final UnidadesProvider _unidades;
  late final SuscripcionProvider _suscripcion;
  late final CarritoProvider _carrito;
  late final PreferenciasProvider _preferencias;
  late final NotificacionesProvider _notificaciones;

  @override
  void initState() {
    super.initState();
    _unidades = context.read<UnidadesProvider>();
    _suscripcion = context.read<SuscripcionProvider>();
    _carrito = context.read<CarritoProvider>();
    _preferencias = context.read<PreferenciasProvider>();
    _notificaciones = context.read<NotificacionesProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final uid = context.read<SesionProvider>().usuario?.uid;
      if (uid != null) {
        _unidades.m_iniciaEscucha(uid);
        _suscripcion.m_iniciaEscucha(uid);
        _carrito.m_iniciaEscucha(uid);
        _preferencias.m_cargaUsuario(uid);
        _notificaciones.m_cargaUsuario(uid);
      }
    });
  }

  @override
  void dispose() {
    _unidades.m_detiene();
    _suscripcion.m_detiene();
    _carrito.m_detiene();
    _preferencias.m_limpiaUsuario();
    _notificaciones.m_limpiaUsuario();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavProvider>();

    const paginas = <Widget>[
      MapaScreen(),
      PerfilScreen(),
    ];
    final pagina = paginas[nav.indice];

    if (Responsivo.esEscritorio(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: nav.indice,
              onDestinationSelected: (i) => context.read<NavProvider>().m_cambia(i),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book),
                  label: Text('Unidades'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.map),
                  label: Text('Mapa'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.workspace_premium),
                  label: Text('Planes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Perfil'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: pagina),
          ],
        ),
      );
    }

    return Scaffold(
      body: pagina,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: nav.indice,
          elevation: 0,
          indicatorColor: ThemeApp.lila.withValues(alpha: 0.3),
          onDestinationSelected: (i) => context.read<NavProvider>().m_cambia(i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.menu_book), label: 'Unidades'),
            NavigationDestination(icon: Icon(Icons.map), label: 'Mapa'),
            NavigationDestination(icon: Icon(Icons.workspace_premium), label: 'Planes'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
