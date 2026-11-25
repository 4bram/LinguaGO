import 'package:flutter/material.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/providers/guia_provider.dart';
import 'package:lingua_go/providers/nav_provider.dart';
import 'package:provider/provider.dart';

class GuiaOverlay extends StatelessWidget {
  const GuiaOverlay({super.key});

  void _siguiente(BuildContext context) {
    final guia = context.read<GuiaProvider>();
    if (guia.esUltimo) {
      _terminar(context);
      return;
    }
    guia.m_siguiente();
    context.read<NavProvider>().m_cambia(pasosGuia[guia.paso].pestana);
  }

  void _atras(BuildContext context) {
    final guia = context.read<GuiaProvider>();
    guia.m_atras();
    context.read<NavProvider>().m_cambia(pasosGuia[guia.paso].pestana);
  }

  void _terminar(BuildContext context) {
    context.read<GuiaProvider>().m_termina();
    context.read<NavProvider>().m_cambia(0);
  }

  @override
  Widget build(BuildContext context) {
    final guia = context.watch<GuiaProvider>();
    if (!guia.activa) return const SizedBox.shrink();

    final paso = pasosGuia[guia.paso];

    return Stack(
      fit: StackFit.expand,
      children: [
        const ModalBarrier(color: Colors.black54, dismissible: false),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: ThemeApp.lila,
                          child: Icon(paso.icono, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            paso.titulo,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text('${guia.paso + 1}/${pasosGuia.length}'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(paso.texto),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        if (!guia.esUltimo)
                          TextButton(
                            onPressed: () => _terminar(context),
                            child: const Text('Saltar'),
                          ),
                        const Spacer(),
                        if (guia.paso > 0)
                          TextButton(
                            onPressed: () => _atras(context),
                            child: const Text('Atras'),
                          ),
                        FilledButton(
                          onPressed: () => _siguiente(context),
                          child: Text(guia.esUltimo ? 'Listo' : 'Siguiente'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
