import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lingua_go/components/barras.dart';
import 'package:lingua_go/components/responsive.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/providers/flashcards_provider.dart';
import 'package:lingua_go/providers/unidades_provider.dart';
import 'package:provider/provider.dart';

/// Tarjetas de vocabulario. SENSOR: acelerómetro (agitar = siguiente tarjeta).
class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  late final FlashcardsProvider _flash;
  String? _idUnidad;
  int? _capituloIndex;

  @override
  void initState() {
    super.initState();
    _flash = context.read<FlashcardsProvider>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_idUnidad == null) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Map) {
        _idUnidad = args['unidadId']?.toString();
        final raw = args['capituloIndex'];
        _capituloIndex = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
      } else {
        _idUnidad = args?.toString();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final u = context.read<UnidadesProvider>().m_porId(_idUnidad!);
        if (u != null) _flash.m_inicia(u, capituloIndex: _capituloIndex);
      });
    }
  }

  @override
  void dispose() {
    _flash.m_detieneSensor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flash = context.watch<FlashcardsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(flash.capituloIndex != null && flash.unidad != null
            ? 'Tarjetas · ${flash.unidad!.capitulos[flash.capituloIndex!]}'
            : 'Vocabulario'),
        backgroundColor: ThemeApp.morado,
        foregroundColor: Colors.white,
      ),
      body: ContenedorCentrado(
        anchoMaximo: 520,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: flash.palabras.isEmpty
              ? const CargandoBarra(texto: 'Preparando tarjetas…')
              : (flash.terminada ? _final(context, flash) : _tarjetas(context, flash)),
        ),
      ),
    );
  }

  Widget _tarjetas(BuildContext context, FlashcardsProvider flash) {
    final palabra = flash.palabras[flash.indice];

    return Column(
      children: [
        Text('Tarjeta ${flash.indice + 1} de ${flash.palabras.length}'),
        const SizedBox(height: 8),
        BarraProgreso(valor: (flash.indice + 1) / flash.palabras.length, alto: 8),
        const SizedBox(height: 20),
        Expanded(
          child: GestureDetector(
            onTap: () => context.read<FlashcardsProvider>().m_voltea(),
            // La key reinicia la animación al cambiar de tarjeta
            child: TweenAnimationBuilder<double>(
              key: ValueKey(flash.indice),
              tween: Tween<double>(begin: 0, end: flash.volteada ? 1 : 0),
              duration: const Duration(milliseconds: 450),
              builder: (context, valor, _) {
                final reverso = valor > 0.5;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(valor * pi),
                  child: reverso
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(pi),
                          child: _cara(palabra['es'] ?? '', 'Español', ThemeApp.lila),
                        )
                      : _cara(palabra['en'] ?? '', 'English', ThemeApp.morado),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        _indicadorSensor(flash),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.read<FlashcardsProvider>().m_voltea(),
                icon: const Icon(Icons.flip),
                label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Voltear')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.read<FlashcardsProvider>().m_siguiente(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeApp.morado,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Siguiente')),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cara(String texto, String idioma, Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
      ),
      child: LayoutBuilder(
        builder: (context, c) => Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: c.maxWidth.isFinite ? c.maxWidth - 32 : 400,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(idioma.toUpperCase(),
                      style: const TextStyle(color: Colors.white70, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Text(
                    texto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Toca para voltear',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Muestra la lectura en vivo del acelerómetro.
  Widget _indicadorSensor(FlashcardsProvider flash) {
    if (!flash.sensorDisponible) {
      return const Text(
        'Este dispositivo no tiene acelerómetro: usa el botón Siguiente.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12),
      );
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.vibration, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Agita el teléfono para la siguiente · ${flash.fuerza.toStringAsFixed(1)} m/s²',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        BarraProgreso(valor: flash.fuerza / FlashcardsProvider.umbralSacudon, alto: 8),
      ],
    );
  }

  Widget _final(BuildContext context, FlashcardsProvider flash) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: _finalContenido(context, flash),
        ),
      ),
    );
  }

  Widget _finalContenido(BuildContext context, FlashcardsProvider flash) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.emoji_events, size: 96, color: ThemeApp.lila),
        const SizedBox(height: 12),
        const Text(
          '¡Sesión completa!',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text('Repasaste ${flash.palabras.length} palabras.'),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              final unidad = flash.unidad;
              final cap = flash.capituloIndex;
              // Solo cuenta para el avance si se estudió desde un capítulo.
              if (unidad != null && cap != null) {
                context.read<UnidadesProvider>().m_completaActividad(unidad, cap, 'tarjetas');
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeApp.morado,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: Text(flash.capituloIndex != null ? 'GUARDAR AVANCE' : 'TERMINAR'),
          ),
        ),
        TextButton(
          onPressed: () {
            final unidad = flash.unidad;
            if (unidad != null) context.read<FlashcardsProvider>().m_inicia(unidad, capituloIndex: flash.capituloIndex);
          },
          child: const Text('Repetir'),
        ),
      ],
    );
  }
}
