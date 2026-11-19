import 'package:flutter/material.dart';
import 'package:lingua_go/components/botones_campos.dart';
import 'package:lingua_go/components/encabezado_curvo.dart';
import 'package:lingua_go/components/responsive.dart';
import 'package:lingua_go/config/sonidos_service.dart';
import 'package:lingua_go/providers/preferencias_provider.dart';
import 'package:provider/provider.dart';

class _PaginaIntro {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  const _PaginaIntro(this.titulo, this.subtitulo, this.icono);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  static const List<_PaginaIntro> _paginas = [
    _PaginaIntro(
      'Aprende inglés fácil y rápido en línea',
      'Unidades cortas y claras para estudiar a tu ritmo.',
      Icons.language,
    ),
    _PaginaIntro(
      'Sigue tu progreso en cada capítulo',
      'Tu avance se guarda en la nube y lo ves en todos tus dispositivos.',
      Icons.insights,
    ),
    _PaginaIntro(
      'Practica agitando tu teléfono',
      'Tarjetas de vocabulario con sensores y recordatorios por notificación.',
      Icons.vibration,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SonidosService.m_iniciaBucle('sfx_guia.wav', volumen: 0.3);
  }

  @override
  void dispose() {
    SonidosService.m_detenerBucle();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pref = context.watch<PreferenciasProvider>();
    final esUltima = pref.paginaOnboarding == _paginas.length - 1;

    return Scaffold(
      body: ContenedorCentrado(
        anchoMaximo: 520,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _paginas.length,
                onPageChanged: (i) =>
                    context.read<PreferenciasProvider>().m_paginaOnboarding(i),
                itemBuilder: (context, i) => _pagina(_paginas[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _paginas.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: pref.paginaOnboarding == i ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: pref.paginaOnboarding == i
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  BotonPrincipal(
                    texto: esUltima ? 'EMPEZAR' : 'SIGUIENTE',
                    onPressed: () {
                      if (esUltima) {
                        context.read<PreferenciasProvider>().m_terminaOnboarding();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  if (!esUltima)
                    TextButton(
                      onPressed: () =>
                          context.read<PreferenciasProvider>().m_terminaOnboarding(),
                      child: const Text('Saltar'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pagina(_PaginaIntro p) {
    return Column(
      children: [
        Expanded(
          child: EncabezadoCurvo(
            alto: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  top: -40,
                  right: -40,
                  child: CircleAvatar(
                    radius: 110,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Positioned(
                  top: 90,
                  left: -50,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.35),
                  child: Icon(p.icono, size: 120, color: Colors.white),
                ),
                Positioned(
                  left: 28,
                  right: 60,
                  bottom: 56,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p.titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        p.subtitulo,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
