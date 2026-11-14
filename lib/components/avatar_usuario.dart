import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:provider/provider.dart';

/// Avatar del usuario con borde blanco y sombra. Escucha al SesionProvider,
/// por eso la foto se sincroniza sola en el dashboard y en el perfil.
class AvatarUsuario extends StatelessWidget {
  final double radio;

  const AvatarUsuario({super.key, this.radio = 20});

  @override
  Widget build(BuildContext context) {
    final url = context.watch<SesionProvider>().fotoUrl;
    final tieneFoto = url != null && url.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radio,
        backgroundColor: Colors.white,
        backgroundImage: tieneFoto ? CachedNetworkImageProvider(url) : null,
        child: tieneFoto
            ? null
            : Icon(Icons.person, size: radio, color: ThemeApp.morado),
      ),
    );
  }
}
