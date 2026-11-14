import 'package:flutter/material.dart';
import 'package:lingua_go/components/theme_app.dart';

/// Decoración común para los campos de texto.
InputDecoration decoracionCampo(String etiqueta, IconData icono) {
  return InputDecoration(
    labelText: etiqueta,
    prefixIcon: Icon(icono),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );
}

/// Botón principal estilo "START" del diseño (píldora morada).
class BotonPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;
  final IconData? icono;

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: cargando || onPressed == null
            ? null
            : () {
                onPressed!();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeApp.morado,
          foregroundColor: Colors.white,
          disabledBackgroundColor: ThemeApp.morado.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
        child: cargando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icono != null) ...[
                    Icon(icono),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      texto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
