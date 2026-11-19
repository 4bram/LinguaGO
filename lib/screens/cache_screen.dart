import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lingua_go/components/responsive.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/config/cache_imagenes.dart';
import 'package:lingua_go/providers/cache_provider.dart';
import 'package:lingua_go/providers/conexion_provider.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:lingua_go/providers/unidades_provider.dart';
import 'package:provider/provider.dart';

class CacheScreen extends StatelessWidget {
  const CacheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unidades = context.read<UnidadesProvider>().unidades;
    final foto = context.read<SesionProvider>().fotoUrl;
    final urls = CacheImagenes.m_urls(unidades: unidades, fotoUrl: foto, incluirDemo: true);

    return ChangeNotifierProvider(
      create: (_) => CacheProvider(urls),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Almacenamiento y sin conexión'),
          backgroundColor: ThemeApp.morado,
          foregroundColor: Colors.white,
        ),
        body: ContenedorCentrado(
          anchoMaximo: 900,
          child: Consumer<CacheProvider>(
            builder: (context, c, _) {
              final online = context.watch<ConexionProvider>();
              final guardadas = c.imagenes.where((i) => i.guardada).length;
              final ancho = MediaQuery.sizeOf(context).width;
              final columnas = ancho >= 900 ? 3 : (ancho >= 560 ? 2 : 1);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _estado(context, online),
                  const SizedBox(height: 12),
                  _resumen(context, c, guardadas),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: c.ocupado ? null : c.m_precarga,
                        icon: const Icon(Icons.download_for_offline),
                        label: const Text('Guardar imágenes ahora'),
                      ),
                      OutlinedButton.icon(
                        onPressed: c.ocupado ? null : c.m_pruebaFirestore,
                        icon: const Icon(Icons.storage),
                        label: const Text('Leer Firestore local'),
                      ),
                      OutlinedButton.icon(
                        onPressed: c.ocupado ? null : c.m_vacia,
                        icon: const Icon(Icons.delete_sweep),
                        label: const Text('Vaciar caché'),
                      ),
                      OutlinedButton.icon(
                        onPressed: online.m_comprueba,
                        icon: const Icon(Icons.wifi_find),
                        label: const Text('Comprobar conexión'),
                      ),
                    ],
                  ),
                  if (c.ocupado) const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(),
                  ),
                  if (c.mensaje != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(c.mensaje!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(height: 16),
                  const Text('Imágenes (se leen de la caché primero)',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 8),
                  if (!c.cargado)
                    const Center(child: CircularProgressIndicator())
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: c.imagenes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnas,
                        mainAxisExtent: 230,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, i) => _tarjetaImagen(c.imagenes[i]),
                    ),
                  const SizedBox(height: 18),
                  _guia(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _estado(BuildContext context, ConexionProvider online) {
    final color = online.enLinea ? Colors.green : Colors.red;
    return Card(
      color: color.withValues(alpha: .12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(online.enLinea ? Icons.wifi : Icons.wifi_off, color: color),
        title: Text(
          online.enLinea ? 'En línea' : 'Sin conexión',
          style: TextStyle(fontWeight: FontWeight.w800, color: color),
        ),
        subtitle: Text(online.enLinea
            ? 'Las imágenes nuevas se descargan y se guardan.'
            : 'Se muestran las imágenes y datos guardados en el teléfono.'),
      ),
    );
  }

  Widget _resumen(BuildContext context, CacheProvider c, int guardadas) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Guardado en este teléfono', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _dato(Icons.image, 'Imágenes en disco', '${c.archivos} archivos · ${CacheImagenes.m_formatoBytes(c.bytes)}'),
            _dato(Icons.check_circle, 'Imágenes de esta lista ya guardadas', '$guardadas de ${c.imagenes.length}'),
            _dato(Icons.folder, 'Carpeta', c.ruta.isEmpty ? '—' : c.ruta),
            _dato(Icons.storage, 'Firestore (datos)',
                c.unidadesEnCacheFirestore == null
                    ? 'Persistencia activada · pulsa «Leer Firestore local»'
                    : '${c.unidadesEnCacheFirestore} unidades leídas de la base local'),
            _dato(Icons.tune, 'Preferencias', 'SharedPreferences (tema, sonidos, introducción)'),
          ],
        ),
      ),
    );
  }

  Widget _dato(IconData i, String t, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(i, size: 18, color: ThemeApp.morado),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(TextSpan(children: [
                TextSpan(text: '$t: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: v),
              ])),
            ),
          ],
        ),
      );

  Widget _tarjetaImagen(ImagenCache im) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: im.url,
              cacheManager: CacheImagenes.manager,
              fit: BoxFit.cover,
              placeholder: (_, _) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              errorWidget: (_, _, _) => const Center(
                child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(im.guardada ? Icons.offline_pin : Icons.cloud_off,
                    size: 18, color: im.guardada ? Colors.green : Colors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    im.guardada
                        ? 'En caché · ${CacheImagenes.m_formatoBytes(im.bytes)}'
                        : 'Aún no descargada',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _guia() {
    return Card(
      color: ThemeApp.lila.withValues(alpha: .12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cómo comprobarlo (modo avión)', style: TextStyle(fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('1. Con internet, pulsa «Guardar imágenes ahora» y abre las unidades.\n'
                '2. Verás las imágenes marcadas «En caché».\n'
                '3. Activa el modo avión y cierra la app por completo.\n'
                '4. Ábrela de nuevo: el aviso dirá «Sin conexión» y las imágenes, las unidades y tu progreso siguen apareciendo.\n'
                '5. «Leer Firestore local» confirma que los datos salen del teléfono.'),
          ],
        ),
      ),
    );
  }
}
