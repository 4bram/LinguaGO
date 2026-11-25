import 'package:flutter/material.dart';
import 'package:lingua_go/components/encabezado_curvo.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/models/plan_model.dart';
import 'package:lingua_go/providers/suscripcion_provider.dart';
import 'package:provider/provider.dart';

class PlanesScreen extends StatelessWidget {
  const PlanesScreen({super.key});

  String _fecha(DateTime? f) {
    if (f == null) return '';
    final d = f.day.toString().padLeft(2, '0');
    final m = f.month.toString().padLeft(2, '0');
    return '$d/$m/${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    final susc = context.watch<SuscripcionProvider>();

    return Column(
      children: [
        const EncabezadoCurvo(
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
                    Text('Premium', style: TextStyle(color: Colors.white70)),
                    Text(
                      'Elige tu plan',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (susc.activa) _bannerActivo(context, susc),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final tarjetas = PlanModel.planes
                        .asMap()
                        .entries
                        .map((e) => _tarjetaPlan(context, e.value, susc))
                        .toList();
                    if (constraints.maxWidth >= 800) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: tarjetas
                            .map((t) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: t,
                                  ),
                                ))
                            .toList(),
                      );
                    }
                    return Column(children: tarjetas);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bannerActivo(BuildContext context, SuscripcionProvider susc) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Plan ${susc.nombrePlan} activo hasta el ${_fecha(susc.fechaFin)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Alerta del sistema'),
                content: const Text('Cancelar suscripcion?'),
                actions: [
                  TextButton(
                    child: const Text('Aceptar'),
                    onPressed: () {
                      context.read<SuscripcionProvider>().m_cancela();
                      Navigator.of(c).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.of(c).pop(),
                  ),
                ],
              ),
            ),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaPlan(BuildContext context, PlanModel plan, SuscripcionProvider susc) {
    final esActual = susc.activa && susc.idPlan == plan.id;
    final color = plan.destacado ? ThemeApp.morado : ThemeApp.lila;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: plan.destacado ? 8 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: color, width: plan.destacado ? 3 : 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    plan.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (plan.destacado) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeApp.morado,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Popular',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(plan.descripcion),
            const SizedBox(height: 12),
            Text(
              '\$${plan.precio} MXN',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            Text(
              plan.meses == 1 ? 'Por mes' : 'Por ${plan.meses} meses',
              style: const TextStyle(fontSize: 12),
            ),
            const Divider(height: 24),
            ...plan.beneficios.map(
              (b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: color),
                    const SizedBox(width: 8),
                    Expanded(child: Text(b)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: esActual
                    ? null
                    : () => Navigator.pushNamed(context, '/pago', arguments: plan.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  minimumSize: const Size.fromHeight(46),
                ),
                child: Text(esActual ? 'Plan actual' : 'Suscribirme'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
