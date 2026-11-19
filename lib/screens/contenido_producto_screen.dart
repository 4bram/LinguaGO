import 'package:flutter/material.dart';
import 'package:lingua_go/components/responsive.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/config/storage_service.dart';
import 'package:lingua_go/models/producto_model.dart';
import 'package:lingua_go/providers/contenido_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContenidoProductoScreen extends StatelessWidget {
  final ProductoModel producto;
  const ContenidoProductoScreen({super.key, required this.producto});

  Future<void> _abrirArchivo(BuildContext context, String ext) async {
    final storage = StorageService();
    final messenger = ScaffoldMessenger.of(context);
    if (!storage.configurado) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Configura Supabase en el .env para descargar el archivo.'),
      ));
      return;
    }
    final ok = await launchUrl(
      Uri.parse(storage.m_urlRecurso(producto.m_rutaArchivo(ext))),
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);
    if (!ok) {
      messenger.showSnackBar(const SnackBar(
        content: Text('No se pudo abrir el archivo. Revisa tu conexión y que esté subido al bucket "recursos".'),
      ));
    }
  }

  IconData _icono(String ext) => switch (ext) {
        'xlsx' => Icons.table_chart,
        'docx' => Icons.description,
        _ => Icons.picture_as_pdf,
      };

  Widget _tarjetaArchivos(BuildContext context) {
    return Card(
      color: ThemeApp.lila.withValues(alpha: .12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tus archivos', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(
              producto.secciones.isEmpty
                  ? 'Este producto se entrega como archivo descargable.'
                  : 'Descarga la versión completa para imprimir o usar sin la app.',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ext in producto.archivos)
                  FilledButton.icon(
                    onPressed: () => _abrirArchivo(context, ext),
                    icon: Icon(_icono(ext), size: 18),
                    label: Text('Descargar ${ext.toUpperCase()}'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContenidoProvider(producto),
      child: Scaffold(
        appBar: AppBar(
          title: Text(producto.nombre, overflow: TextOverflow.ellipsis),
          backgroundColor: ThemeApp.morado,
          foregroundColor: Colors.white,
        ),
        body: ContenedorCentrado(
          anchoMaximo: 650,
          child: Consumer<ContenidoProvider>(
            builder: (context, c, _) {
              final secciones = c.seccionesFiltradas;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  _tarjetaArchivos(context),
                  if (producto.secciones.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: c.m_buscar,
                    decoration: InputDecoration(
                      hintText: 'Buscar en este contenido…',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Vista rápida en la app (funciona sin internet): '
                    '${producto.totalItems} elementos · ${producto.secciones.length} secciones'
                    '${producto.modoTarjeta ? ' · toca una tarjeta para voltearla' : ''}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  ],
                  if (secciones.isEmpty && producto.secciones.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Sin resultados.')),
                    ),
                  for (final s in secciones) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 8),
                      child: Text(
                        producto.secciones[s.key].titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: ThemeApp.morado,
                        ),
                      ),
                    ),
                    for (final e in s.value)
                      producto.modoTarjeta
                          ? _TarjetaVoltea(s: s.key, i: e.key, item: e.value)
                          : _FilaItem(item: e.value),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FilaItem extends StatelessWidget {
  final ItemContenido item;
  const _FilaItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final c = context.read<ContenidoProvider>();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: item.emoji.isEmpty
            ? null
            : Text(item.emoji, style: const TextStyle(fontSize: 28)),
        title: Text(item.en, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.es),
            if (item.ejemplo.isNotEmpty)
              Text(
                item.ejemplo,
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
          ],
        ),
        trailing: IconButton(
          tooltip: 'Escuchar',
          icon: const Icon(Icons.volume_up, color: ThemeApp.morado),
          onPressed: () => c.m_habla(item.ejemplo.isNotEmpty && item.ejemplo.length < 90
              ? '${item.en}. ${item.ejemplo}'
              : item.en),
        ),
      ),
    );
  }
}

class _TarjetaVoltea extends StatelessWidget {
  final int s;
  final int i;
  final ItemContenido item;
  const _TarjetaVoltea({required this.s, required this.i, required this.item});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ContenidoProvider>();
    final atras = c.m_estaVolteada(s, i);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: atras ? ThemeApp.morado : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          c.m_voltea(s, i);
          if (!atras) c.m_habla(item.en);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (item.emoji.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Text(item.emoji, style: const TextStyle(fontSize: 30)),
                ),
              Expanded(
                child: atras
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.es,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                          if (item.ejemplo.isNotEmpty)
                            Text(item.ejemplo,
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      )
                    : Text(item.en,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ),
              Icon(atras ? Icons.visibility : Icons.touch_app,
                  color: atras ? Colors.white70 : ThemeApp.morado),
            ],
          ),
        ),
      ),
    );
  }
}
