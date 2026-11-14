import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lingua_go/components/curva_clipper.dart';
import 'package:lingua_go/components/theme_app.dart';

/// Encabezado morado con esquina curva, sombra y círculos decorativos.
/// Si recibe [imagenUrl] la muestra detrás (en caché local) con un velo morado.
class EncabezadoCurvo extends StatelessWidget {
  final double alto;
  final Widget child;
  final String? imagenUrl;

  const EncabezadoCurvo({
    super.key,
    required this.alto,
    required this.child,
    this.imagenUrl,
  });

  @override
  Widget build(BuildContext context) {
    final tieneImagen = imagenUrl != null && imagenUrl!.isNotEmpty;
    return PhysicalShape(
      clipper: CurvaClipper(),
      color: ThemeApp.morado,
      elevation: 10,
      shadowColor: const Color(0xFF2A0F8F),
      child: Container(
        height: alto,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ThemeApp.morado, ThemeApp.moradoClaro],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (tieneImagen)
              CachedNetworkImage(
                imageUrl: imagenUrl!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const SizedBox(),
              ),
            if (tieneImagen)
              Container(color: ThemeApp.morado.withValues(alpha: 0.78)),
            Positioned(
              top: -40,
              right: -30,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -40,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            // Altura fija: se limita el escalado de texto para evitar overflow.
            MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.2,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
