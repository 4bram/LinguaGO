import 'package:flutter/material.dart';
import 'package:lingua_go/components/anillo_progreso.dart';
import 'package:lingua_go/components/barras.dart';
import 'package:lingua_go/components/encabezado_curvo.dart';
import 'package:lingua_go/components/responsive.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/providers/unidades_provider.dart';
import 'package:lingua_go/models/contenido_capitulos.dart';
import 'package:lingua_go/models/unidad_model.dart';
import 'package:provider/provider.dart';

class UnidadDetalleScreen extends StatelessWidget {
  const UnidadDetalleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final prov = context.watch<UnidadesProvider>();
    final unidad = prov.m_porId(id);

    if (unidad == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Unidad no encontrada')),
      );
    }

    final progreso = prov.m_progresoDe(unidad);
    final total = prov.m_porcentajeUnidad(unidad);

    return Scaffold(
      body: ContenedorCentrado(
        anchoMaximo: 700,
        child: Column(
          children: [
            EncabezadoCurvo(
              alto: 220,
              imagenUrl: unidad.imagenUrl,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unidad ${unidad.orden}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    unidad.nombre,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            AnilloProgreso(porcentaje: total, tam: 46),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  for (int i = 0; i < unidad.capitulos.length; i++)
                    _cajaCapitulo(
                      context,
                      _tarjetaCapitulo(context, prov, unidad.id, i, unidad, progreso[i]),
                    ),
                  const SizedBox(height: 8),
                  _seccionFinal(context, prov, unidad),
                  const SizedBox(height: 24),
                  const Text(
                    'Practica libre',
                    style: TextStyle(
                      color: ThemeApp.moradoClaro,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _tarjetaEjercicio(
                          'Vocabulario',
                          Icons.style,
                          ThemeApp.morado,
                          () => Navigator.pushNamed(context, '/flashcards',
                              arguments: unidad.id),
                        ),
                        const SizedBox(width: 12),
                        _tarjetaEjercicio(
                          'Escucha',
                          Icons.volume_up,
                          ThemeApp.lila,
                          () => _abrirPractica(context, unidad.id, 'escucha'),
                        ),
                        const SizedBox(width: 12),
                        _tarjetaEjercicio(
                          'Gramatica',
                          Icons.menu_book,
                          ThemeApp.morado,
                          () => _abrirPractica(context, unidad.id, 'gramatica'),
                        ),
                        const SizedBox(width: 12),
                        _tarjetaEjercicio(
                          'Escritura',
                          Icons.edit,
                          ThemeApp.lila,
                          () => _abrirPractica(context, unidad.id, 'escritura'),
                        ),
                        const SizedBox(width: 12),
                        _tarjetaEjercicio(
                          'Prueba libre',
                          Icons.quiz,
                          ThemeApp.morado,
                          () => _abrirPractica(context, unidad.id, 'quiz'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirPractica(BuildContext context, String unidadId, String tipo) {
    Navigator.pushNamed(
      context,
      '/practica',
      arguments: {'unidadId': unidadId, 'tipo': tipo},
    );
  }

  Widget _cajaCapitulo(BuildContext context, Widget hijo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: hijo,
    );
  }

  Widget _tarjetaCapitulo(BuildContext context, UnidadesProvider prov, String unidadId,
      int indice, UnidadModel unidad, int pct) {
    final contenido = ContenidoCapitulo.crear(unidad, indice);
    final hechas = prov.m_actividadesCap(unidad, indice);
    final materialListo = prov.m_materialCompleto(unidad, indice);
    final eval = prov.m_evalCapitulo(unidad, indice);
    final hechasMaterial = UnidadesProvider.actividadesMaterial.where(hechas.contains).length;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
        leading: CircleAvatar(
          backgroundColor: ThemeApp.lila.withValues(alpha: .15),
          child: Text('${indice + 1}', style: const TextStyle(color: ThemeApp.morado, fontWeight: FontWeight.bold)),
        ),
        title: Text(contenido.titulo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: BarraProgreso(valor: pct / 100, alto: 6),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pct >= 100)
              const Icon(Icons.check_circle, size: 18, color: Colors.green)
            else
              Text('$pct%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(contenido.objetivo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(contenido.explicacion, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          if (contenido.ejemplos.isNotEmpty) ...[
            const SizedBox(height: 6),
            Align(alignment: Alignment.centerLeft, child: Text(contenido.ejemplos.first, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic))),
          ],
          const SizedBox(height: 8),
          if (contenido.vocabulario.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: contenido.vocabulario.take(8).map((p) => Chip(
                visualDensity: VisualDensity.compact,
                label: Text('${p['en']} · ${p['es']}', style: const TextStyle(fontSize: 10)),
                backgroundColor: ThemeApp.lila.withValues(alpha: .10),
              )).toList(),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Material: $hechasMaterial/${UnidadesProvider.actividadesMaterial.length} · '
              'Evaluación: ${eval == null ? 'pendiente' : '${eval['mejor']} % (mejor) · ${eval['intentos']} intento(s)'}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Necesitas 70 % en la evaluacion para completar el capitulo.',
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _botonTarjetas(context, unidadId, indice, hechas.contains('tarjetas')),
              _botonCapitulo(context, unidadId, indice, 'Leccion', Icons.menu_book, 'leccion',
                  hecho: hechas.contains('leccion')),
              _botonCapitulo(context, unidadId, indice, 'Escucha', Icons.headphones, 'escucha',
                  hecho: hechas.contains('escucha')),
              _botonCapitulo(context, unidadId, indice, 'Gramatica', Icons.spellcheck, 'gramatica',
                  hecho: hechas.contains('gramatica')),
              _botonCapitulo(context, unidadId, indice, 'Escritura', Icons.edit, 'escritura',
                  hecho: hechas.contains('escritura')),
              _botonCapitulo(context, unidadId, indice, 'Evaluacion', Icons.quiz, 'evaluacion',
                  hecho: hechas.contains('evaluacion'), bloqueado: !materialListo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonTarjetas(BuildContext context, String unidadId, int indice, bool hecho) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor: hecho ? Colors.green : ThemeApp.morado,
        side: BorderSide(color: (hecho ? Colors.green : ThemeApp.morado).withValues(alpha: .35)),
      ),
      onPressed: () => Navigator.pushNamed(context, '/flashcards', arguments: {
        'unidadId': unidadId,
        'capituloIndex': indice,
      }),
      icon: Icon(hecho ? Icons.check_circle : Icons.style, size: 16),
      label: const Text('Tarjetas', style: TextStyle(fontSize: 11)),
    );
  }

  Widget _botonCapitulo(BuildContext context, String unidadId, int indice,
      String texto, IconData icono, String tipo,
      {bool hecho = false, bool bloqueado = false}) {
    final color = hecho ? Colors.green : ThemeApp.morado;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor: bloqueado ? Colors.grey : color,
        side: BorderSide(color: (bloqueado ? Colors.grey : color).withValues(alpha: .35)),
      ),
      onPressed: bloqueado
          ? () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Primero termina las actividades del capitulo'),
                  duration: Duration(seconds: 3),
                ),
              )
          : () => Navigator.pushNamed(context, '/practica', arguments: {
                'unidadId': unidadId,
                'tipo': tipo,
                'capituloIndex': indice,
              }),
      icon: Icon(bloqueado ? Icons.lock : (hecho ? Icons.check_circle : icono), size: 16),
      label: Text(texto, style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _seccionFinal(BuildContext context, UnidadesProvider prov, UnidadModel unidad) {
    final abierta = prov.m_capitulosCompletos(unidad);
    final eval = prov.m_evalUnidad(unidad);
    final aprobada = prov.m_unidadAprobada(unidad);
    final color = aprobada ? Colors.green : ThemeApp.morado;

    final String estado;
    if (aprobada) {
      estado = 'Aprobada · mejor resultado ${eval?['mejor']} % · ${eval?['intentos']} intento(s)';
    } else if (eval != null) {
      estado = 'Sin aprobar · último ${eval['ultimo']} % · ${eval['intentos']} intento(s). Necesitas 70 %.';
    } else if (abierta) {
      estado = 'Disponible: necesitas 70 % para pasar a la siguiente unidad.';
    } else {
      estado = 'Bloqueada';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        border: Border.all(color: color.withValues(alpha: .4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(aprobada ? Icons.verified : Icons.workspace_premium, color: color),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Evaluacion final de la unidad',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(estado, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: abierta ? ThemeApp.morado : Colors.grey,
                ),
                onPressed: abierta
                    ? () => _abrirPractica(context, unidad.id, 'evaluacion_unidad')
                    : () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Termina todos los capitulos primero'),
                            duration: Duration(seconds: 3),
                          ),
                        ),
                icon: Icon(abierta ? Icons.play_arrow : Icons.lock, size: 18),
                label: Text(aprobada ? 'Repetir evaluacion' : 'Presentar evaluacion'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaEjercicio(String texto, IconData icono, Color color, VoidCallback onTap) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 110,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                texto,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
