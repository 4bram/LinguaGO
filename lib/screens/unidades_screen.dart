import 'package:flutter/material.dart';
import 'package:lingua_go/components/aparece.dart';
import 'package:lingua_go/components/avatar_usuario.dart';
import 'package:lingua_go/components/barras.dart';
import 'package:lingua_go/components/encabezado_curvo.dart';
import 'package:lingua_go/components/tarjeta_unidad.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/config/sonidos_service.dart';
import 'package:lingua_go/providers/busqueda_provider.dart';
import 'package:lingua_go/providers/nav_provider.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:lingua_go/providers/suscripcion_provider.dart';
import 'package:lingua_go/providers/unidades_provider.dart';
import 'package:provider/provider.dart';

/// Pantalla "Unidades principales" (diseño de referencia, pantalla 2).
class UnidadesScreen extends StatefulWidget {
  const UnidadesScreen({super.key});

  @override
  State<UnidadesScreen> createState() => _UnidadesScreenState();
}

class _UnidadesScreenState extends State<UnidadesScreen> {
  late final TextEditingController _busqueda;

  @override
  void initState() {
    super.initState();
    // Conserva el texto si la pestaña se reconstruye.
    _busqueda = TextEditingController(
      text: context.read<BusquedaProvider>().filtro,
    );
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<UnidadesProvider>();
    final susc = context.watch<SuscripcionProvider>();

    return Column(
      children: [
        EncabezadoCurvo(
          alto: 190,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.school, color: Colors.white),
                      AvatarUsuario(radio: 20),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'INGLÉS',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'UNIDADES PRINCIPALES',
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: _contenido(context, prov, susc)),
      ],
    );
  }

  Widget _contenido(
    BuildContext context,
    UnidadesProvider prov,
    SuscripcionProvider susc,
  ) {
    if (prov.error != null) {
      return Center(child: Text(prov.error!, textAlign: TextAlign.center));
    }
    if (prov.cargando) {
      return const CargandoBarra(texto: 'Cargando unidades…');
    }
    if (prov.unidades.isEmpty) {
      return const Center(child: Text('Aún no hay unidades disponibles'));
    }

    final esAdmin = context.watch<SesionProvider>().esAdmin;
    final filtro = context.watch<BusquedaProvider>().filtro;
    final consulta = filtro.trim().toLowerCase();
    final filtradas = prov.unidades.where((u) =>
      consulta.isEmpty ||
      u.nombre.toLowerCase().contains(consulta) ||
      u.capitulos.any((c) => c.toLowerCase().contains(consulta)) ||
      u.vocabulario.any((v) => (v['en'] ?? '').toLowerCase().contains(consulta) ||
          (v['es'] ?? '').toLowerCase().contains(consulta))
    ).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: TextField(
            controller: _busqueda,
            onChanged: (v) => context.read<BusquedaProvider>().m_cambia(v),
            decoration: InputDecoration(
              hintText: 'Buscar tema, capítulo o palabra…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: filtro.isEmpty ? null : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _busqueda.clear();
                  context.read<BusquedaProvider>().m_cambia('');
                },
              ),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: filtradas.isEmpty
              ? const Center(child: Text('No encontramos contenido con esa búsqueda.'))
              : LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        Widget tarjeta(int i) {
          final u = filtradas[i];
          final sinPlan = u.premium && !susc.activa;
          // Se abre al aprobar la evaluación final de la unidad anterior
          // (los administradores pueden abrir cualquiera para revisar contenido).
          final sinAprobar = !esAdmin && !prov.m_desbloqueada(u);
          final bloqueada = sinPlan || sinAprobar;
          return TarjetaUnidad(
            unidad: u,
            porcentaje: prov.m_porcentajeUnidad(u),
            bloqueada: bloqueada,
            mostrarPremium: sinPlan,
            color: i.isEven ? ThemeApp.morado : ThemeApp.lila,
            onTap: () {
              if (sinAprobar) {
                final anterior = prov.m_anterior(u);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Aprueba la evaluación final de la Unidad ${anterior?.orden ?? u.orden - 1} '
                      '(70 % o más) para desbloquear esta unidad.',
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              } else if (sinPlan) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unidad premium: elige un plan para desbloquearla'),
                    duration: Duration(seconds: 3),
                  ),
                );
                context.read<NavProvider>().m_cambia(2);
              } else {
                SonidosService.m_portada();
                Navigator.pushNamed(context, '/unidad', arguments: u.id);
              }
            },
          );
        }

        if (ancho >= 700) {
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ancho >= 1100 ? 3 : 2,
              mainAxisExtent: 84,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filtradas.length,
            itemBuilder: (context, i) => Aparece(indice: i, child: tarjeta(i)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          itemCount: filtradas.length,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Aparece(
              indice: i,
              child: SizedBox(height: 74, child: tarjeta(i)),
            ),
          ),
        );
      },
    ),
        ),
      ],
    );
  }
}
