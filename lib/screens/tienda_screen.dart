import 'package:lingua_go/config/cache_imagenes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lingua_go/components/responsive.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/config/storage_service.dart';
import 'package:lingua_go/models/producto_model.dart';
import 'package:lingua_go/providers/carrito_provider.dart';
import 'package:lingua_go/screens/contenido_producto_screen.dart';
import 'package:provider/provider.dart';

class TiendaScreen extends StatelessWidget {
  const TiendaScreen({super.key});

  String _fecha(String iso) {
    final f = DateTime.tryParse(iso);
    if (f == null) return '';
    final d = f.day.toString().padLeft(2, '0');
    final m = f.month.toString().padLeft(2, '0');
    return '$d/$m/${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        backgroundColor: ThemeApp.morado,
        foregroundColor: Colors.white,
        bottom: TabBar(
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(icon: Icon(Icons.storefront), text: 'Catalogo'),
            Tab(icon: const Icon(Icons.library_books), text: 'Mi biblioteca (${carrito.biblioteca.length})'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Carrito',
            onPressed: () => Navigator.pushNamed(context, '/carrito'),
            icon: Badge(
              isLabelVisible: carrito.totalArticulos > 0,
              label: Text('${carrito.totalArticulos}'),
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      floatingActionButton: carrito.totalArticulos == 0
          ? null
          : FloatingActionButton.extended(
              backgroundColor: ThemeApp.morado,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.pushNamed(context, '/carrito'),
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Text('Ver carrito · \$${carrito.total} MXN'),
            ),
      body: TabBarView(
        children: [
          _catalogo(context, carrito),
          _biblioteca(context, carrito),
        ],
      ),
    ),
    );
  }

  Widget _catalogo(BuildContext context, CarritoProvider carrito) {
    return ContenedorCentrado(
      anchoMaximo: 1100,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: carrito.categoriaFiltro == null,
                    onSelected: (_) => context.read<CarritoProvider>().m_filtraCategoria(null),
                  ),
                ),
                for (final c in ProductoModel.categorias)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: carrito.categoriaFiltro == c,
                      onSelected: (_) => context.read<CarritoProvider>().m_filtraCategoria(c),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _rejilla([for (final p in carrito.catalogoFiltrado) _tarjetaProducto(context, p, carrito)]),
          if (carrito.pedidos.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Mis pedidos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            for (final pedido in carrito.pedidos) _tarjetaPedido(pedido),
          ],
        ],
      ),
    );
  }

  Widget _biblioteca(BuildContext context, CarritoProvider carrito) {
    final libros = carrito.biblioteca;
    if (libros.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No has comprado nada',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ContenedorCentrado(
      anchoMaximo: 1100,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [_rejilla([for (final p in libros) _tarjetaBiblioteca(context, p)])],
      ),
    );
  }

  Widget _rejilla(List<Widget> tarjetas) {
    return LayoutBuilder(
      builder: (context, c) {
        const sep = 12.0;
        final cols = Responsivo.columnas(c.maxWidth - 32, anchoMinimo: 340);
        final w = (c.maxWidth - sep * (cols - 1)) / cols;
        return Wrap(
          spacing: sep,
          children: [for (final t in tarjetas) SizedBox(width: w, child: t)],
        );
      },
    );
  }

  Widget _portada(ProductoModel p, {double alto = 120}) {
    final storage = StorageService();
    final fallback = Container(
      height: alto,
      color: ThemeApp.lila.withValues(alpha: .15),
      child: Center(child: Icon(p.icono, size: 44, color: ThemeApp.morado)),
    );
    if (!storage.configurado) return fallback;
    return CachedNetworkImage(
      imageUrl: storage.m_urlRecurso(p.rutaPortada),
      cacheManager: CacheImagenes.manager,
      height: alto,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }

  Widget _tarjetaBiblioteca(BuildContext context, ProductoModel p) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => _abre(context, p),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _portada(p, alto: 130),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('${p.formatos} · ${p.categoria}',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => _abre(context, p),
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Abrir contenido'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abre(BuildContext context, ProductoModel p) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContenidoProductoScreen(producto: p)),
    );
  }

  Widget _tarjetaProducto(BuildContext context, ProductoModel p, CarritoProvider carrito) {
    final cantidad = carrito.cantidadDe(p.id);
    final loTiene = carrito.m_loTiene(p.id);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
        _portada(p, alto: 110),
        Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: ThemeApp.lila.withValues(alpha: .15),
                  child: Icon(p.icono, color: ThemeApp.morado),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(p.descripcion, style: const TextStyle(fontSize: 12)),
                      Text('${p.formatos} · ${p.categoria}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '\$${p.precio} MXN',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (loTiene)
                  FilledButton.icon(
                    onPressed: () => _abre(context, p),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Comprado · abrir'),
                  )
                else if (cantidad == 0)
                  FilledButton.tonalIcon(
                    onPressed: () => context.read<CarritoProvider>().m_agrega(p.id),
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Agregar'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => context.read<CarritoProvider>().m_quita(p.id),
                    icon: const Icon(Icons.remove_shopping_cart, size: 18),
                    label: const Text('En el carrito · quitar'),
                  ),
              ],
            ),
          ],
        ),
        ),
        ],
      ),
    );
  }

  Widget _tarjetaPedido(Map<String, dynamic> pedido) {
    final articulos = (pedido['articulos'] as List? ?? const [])
        .map((a) => '${a['cantidad']}× ${a['nombre']}')
        .join(', ');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long, color: ThemeApp.morado),
        title: Text('Pedido · \$${pedido['total']} MXN'),
        subtitle: Text(
          '${_fecha('${pedido['fecha']}')} · ${pedido['estado'] ?? ''}\n'
          '$articulos\nFolio: ${pedido['idTransaccion'] ?? ''}',
        ),
      ),
    );
  }
}
