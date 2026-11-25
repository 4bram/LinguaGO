import 'package:flutter/material.dart';
import 'package:lingua_go/components/anillo_progreso.dart';
import 'package:lingua_go/components/etiqueta.dart';
import 'package:lingua_go/models/unidad_model.dart';

class TarjetaUnidad extends StatelessWidget {
  final UnidadModel unidad;
  final int porcentaje;
  final bool bloqueada;

  final bool mostrarPremium;
  final Color color;
  final VoidCallback onTap;

  const TarjetaUnidad({
    super.key,
    required this.unidad,
    required this.porcentaje,
    required this.bloqueada,
    this.mostrarPremium = true,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.white, 0.14)!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -18,
              top: -28,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white.withValues(alpha: 0.09),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: MediaQuery.withClampedTextScaling(
                    maxScaleFactor: 1.15,
                    child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Unidad ${unidad.orden}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (unidad.premium && mostrarPremium) ...[
                                  const SizedBox(width: 8),
                                  const Etiqueta('Premium', icono: Icons.star),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              unidad.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      bloqueada
                          ? const Icon(Icons.lock, color: Colors.white)
                          : AnilloProgreso(porcentaje: porcentaje, tam: 40),
                    ],
                  ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
