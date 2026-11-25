import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/providers/preferencias_provider.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:provider/provider.dart';

class _PaginaIntro {
  final String titulo;
  final String subtitulo;
  final IconData principal;
  final IconData decoUno;
  final IconData decoDos;
  const _PaginaIntro({
    required this.titulo,
    required this.subtitulo,
    required this.principal,
    required this.decoUno,
    required this.decoDos,
  });
}

class OnboardingScreen extends StatefulWidget {

  final bool repetir;

  final bool bienvenida;
  final String? nombre;
  const OnboardingScreen({super.key, this.repetir = false, this.bienvenida = false, this.nombre});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  static const List<_PaginaIntro> _paginas = [
    _PaginaIntro(
      titulo: 'Aprende ingles\na tu ritmo',
      subtitulo: 'Unidades con lecciones, tarjetas, escucha y escritura.',
      principal: Icons.menu_book_rounded,
      decoUno: Icons.schedule_rounded,
      decoDos: Icons.bar_chart_rounded,
    ),
    _PaginaIntro(
      titulo: 'Aprueba y\ndesbloquea',
      subtitulo: 'Aprueba cada evaluacion con 70 % para pasar a la siguiente unidad.',
      principal: Icons.emoji_events_rounded,
      decoUno: Icons.extension_rounded,
      decoDos: Icons.lightbulb_rounded,
    ),
    _PaginaIntro(
      titulo: 'Estudia sin\ninternet',
      subtitulo: 'Tus unidades se guardan en el telefono. Agita el celular para pasar las tarjetas.',
      principal: Icons.vibration_rounded,
      decoUno: Icons.notifications_active_rounded,
      decoDos: Icons.wifi_off_rounded,
    ),
    _PaginaIntro(
      titulo: 'Mas recursos\nen la tienda',
      subtitulo: 'Guias y plantillas en PDF para comprar y descargar.',
      principal: Icons.local_mall_rounded,
      decoUno: Icons.picture_as_pdf_rounded,
      decoDos: Icons.star_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PreferenciasProvider>().m_paginaOnboarding(0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _terminar() {
    if (widget.repetir) {
      Navigator.of(context).pop();
    } else if (widget.bienvenida) {
      context.read<SesionProvider>().m_bienvenidaHecha();
    } else {
      context.read<PreferenciasProvider>().m_terminaOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pref = context.watch<PreferenciasProvider>();
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final actual = pref.paginaOnboarding.clamp(0, _paginas.length - 1);
    final esUltima = actual == _paginas.length - 1;

    final fondoPantalla = oscuro ? const Color(0xFF14111F) : ThemeApp.morado;
    final fondoTarjeta = oscuro ? const Color(0xFF241D3B) : const Color(0xFFF3EEFF);
    final tinta = oscuro ? Colors.white : const Color(0xFF1E1250);
    final tintaSuave = oscuro ? Colors.white70 : const Color(0xFF4E4673);
    final acento = oscuro ? const Color(0xFF8E6BFF) : ThemeApp.morado;

    return Scaffold(
      backgroundColor: fondoPantalla,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440, maxHeight: 760),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                decoration: BoxDecoration(
                  color: fondoTarjeta,
                  borderRadius: BorderRadius.circular(34),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _paginas.length,
                        onPageChanged: (i) =>
                            context.read<PreferenciasProvider>().m_paginaOnboarding(i),
                        itemBuilder: (context, i) => _pagina(
                          _paginas[i],
                          i == 0 ? _tituloInicial : null,
                          tinta: tinta,
                          tintaSuave: tintaSuave,
                          acento: acento,
                          oscuro: oscuro,
                        ),
                      ),
                    ),
                    _indicador(actual, acento),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
                      child: esUltima
                          ? Center(child: _boton('Empezar', _terminar, acento, ancho: 200))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: _terminar,
                                  style: TextButton.styleFrom(foregroundColor: tinta),
                                  child: const Text(
                                    'Saltar',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: .6),
                                  ),
                                ),
                                _boton('Siguiente', () => _controller.jumpToPage(actual + 1), acento),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _boton(String texto, VoidCallback onPressed, Color color, {double ancho = 150}) {
    return SizedBox(
      width: ancho,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: .8),
        ),
      ),
    );
  }

  Widget _indicador(int actual, Color acento) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _paginas.length,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: actual == i ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: actual == i ? acento : acento.withValues(alpha: .28),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String? get _tituloInicial =>
      widget.bienvenida && (widget.nombre ?? '').isNotEmpty
          ? 'Bienvenido,\n${widget.nombre}!'
          : null;

  Widget _pagina(
    _PaginaIntro p,
    String? tituloExtra, {
    required Color tinta,
    required Color tintaSuave,
    required Color acento,
    required bool oscuro,
  }) {
    return LayoutBuilder(
      builder: (context, c) {

        final horizontal = c.maxWidth > c.maxHeight * 1.25 && c.maxWidth > 360;
        final lado = max(
          90.0,
          min(horizontal ? c.maxHeight - 24 : c.maxWidth * .78, c.maxHeight * (horizontal ? .95 : .5)),
        );
        final ilustracion = _Ilustracion(pagina: p, lado: lado, acento: acento, oscuro: oscuro);
        final textos = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Text(
              tituloExtra ?? p.titulo,
              textAlign: horizontal ? TextAlign.start : TextAlign.center,
              style: TextStyle(color: tinta, fontSize: 24, fontWeight: FontWeight.w800, height: 1.15),
            ),
            const SizedBox(height: 10),
            Text(
              p.subtitulo,
              textAlign: horizontal ? TextAlign.start : TextAlign.center,
              style: TextStyle(color: tintaSuave, fontSize: 14, height: 1.35),
            ),
          ],
        );
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              child: Center(
                child: horizontal
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [ilustracion, const SizedBox(width: 24), Flexible(child: textos)],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [ilustracion, const SizedBox(height: 26), textos],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Ilustracion extends StatelessWidget {
  final _PaginaIntro pagina;
  final double lado;
  final Color acento;
  final bool oscuro;
  const _Ilustracion({
    required this.pagina,
    required this.lado,
    required this.acento,
    required this.oscuro,
  });

  @override
  Widget build(BuildContext context) {
    const halo = Colors.white;
    return SizedBox(
      width: lado,
      height: lado,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: lado * .88,
            height: lado * .88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  halo.withValues(alpha: oscuro ? .12 : .95),
                  halo.withValues(alpha: oscuro ? .02 : .15),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(lado * .09),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ThemeApp.moradoClaro, ThemeApp.lila],
              ),
              borderRadius: BorderRadius.circular(lado * .16),
            ),
            child: Icon(pagina.principal, size: lado * .34, color: Colors.white),
          ),
          Positioned(
            top: lado * .04,
            left: lado * .08,
            child: Icon(pagina.decoUno, size: lado * .17, color: ThemeApp.lila),
          ),
          Positioned(
            bottom: lado * .08,
            right: lado * .04,
            child: Icon(pagina.decoDos, size: lado * .19, color: acento.withValues(alpha: .85)),
          ),
        ],
      ),
    );
  }
}
