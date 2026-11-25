import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/providers/visibilidad_password_provider.dart';
import 'package:provider/provider.dart';

const String rutaFondoLogin = 'assets/imagenes/fondo_login.png';

const Color _noche = Color(0xFF1B0B45);
const Color _campo = Color(0x66120730);
const Color _enlace = Color(0xFFC7B2FF);
const Color _errorTexto = Color(0xFFFFB4B4);
const double _anchoEscritorio = 820;

OutlineInputBorder _borde(Color color, [double grosor = 1]) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: grosor),
  );
}

InputDecoration decoracionAuth(String hint, IconData icono, {Widget? sufijo}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
    prefixIcon: Icon(icono, color: Colors.white60, size: 20),
    suffixIcon: sufijo,
    filled: true,
    fillColor: _campo,
    contentPadding: const EdgeInsets.symmetric(vertical: 16),
    border: _borde(Colors.white.withValues(alpha: 0.10)),
    enabledBorder: _borde(Colors.white.withValues(alpha: 0.10)),
    focusedBorder: _borde(ThemeApp.lila, 1.5),
    errorBorder: _borde(_errorTexto),
    focusedErrorBorder: _borde(_errorTexto, 1.5),
    errorStyle: const TextStyle(color: _errorTexto),
  );
}

class PantallaAuth extends StatelessWidget {
  final Widget child;
  final bool conAtras;

  const PantallaAuth({super.key, required this.child, this.conAtras = false});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeApp.oscuro(),
      child: Scaffold(
        backgroundColor: _noche,
        body: LayoutBuilder(
          builder: (context, c) {
            final ancho = c.maxWidth >= _anchoEscritorio;
            return Stack(
              fit: StackFit.expand,
              children: [
                const _Fondo(),
                if (ancho)
                  _Escritorio(conAtras: conAtras, child: child)
                else
                  _Movil(conAtras: conAtras, alto: c.maxHeight, child: child),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Fondo extends StatelessWidget {
  const _Fondo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      rutaFondoLogin,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => const ColoredBox(color: _noche),
    );
  }
}

class _Movil extends StatelessWidget {
  final bool conAtras;
  final double alto;
  final Widget child;

  const _Movil({required this.conAtras, required this.alto, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x000E0525), Color(0xD90E0525)],
              stops: [0.3, 0.75],
            ),
          ),
        ),
        _ZonaFormulario(
          conAtras: conAtras,
          centrado: false,
          arriba: (alto * 0.27).clamp(48.0, 280.0).toDouble(),
          child: child,
        ),
      ],
    );
  }
}

class _Escritorio extends StatelessWidget {
  final bool conAtras;
  final Widget child;

  const _Escritorio({required this.conAtras, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 11, child: _Hero()),
        Expanded(
          flex: 9,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x2E0E0525), Color(0xBF0E0525)],
              ),
            ),
            child: _ZonaFormulario(conAtras: conAtras, centrado: true, arriba: 0, child: child),
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 40, 24, 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'LinguaGo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Spacer(),
            Text(
              'Aprende ingles\na tu ritmo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w800,
                height: 1.05,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZonaFormulario extends StatelessWidget {
  final Widget child;
  final bool conAtras;
  final bool centrado;
  final double arriba;

  const _ZonaFormulario({
    required this.child,
    required this.conAtras,
    required this.centrado,
    required this.arriba,
  });

  @override
  Widget build(BuildContext context) {
    final seguro = MediaQuery.of(context).padding;
    return LayoutBuilder(
      builder: (context, c) {
        final minimo = math.max(0.0, c.maxHeight - seguro.top - seguro.bottom - 40);
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, seguro.top + 16, 24, seguro.bottom + 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minimo),
            child: Align(
              alignment: centrado ? Alignment.center : Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (conAtras) ...[
                      const Align(alignment: Alignment.centerLeft, child: _BotonAtras()),
                      SizedBox(height: centrado ? 28 : 0),
                    ],
                    SizedBox(height: centrado ? 0 : arriba),
                    child,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BotonAtras extends StatelessWidget {
  const _BotonAtras();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Volver',
      child: Material(
        color: const Color(0x4D120730),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.maybePop(context),
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class TituloAuth extends StatelessWidget {
  final String titulo;
  final String? detalle;

  const TituloAuth(this.titulo, {super.key, this.detalle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -0.8,
          ),
        ),
        if (detalle != null) ...[
          const SizedBox(height: 10),
          Text(
            detalle!,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.45),
          ),
        ],
      ],
    );
  }
}

class CampoAuth extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icono;
  final bool esPassword;
  final TextInputType? teclado;
  final String? Function(String?)? validator;

  const CampoAuth({
    super.key,
    required this.controller,
    required this.hint,
    required this.icono,
    this.esPassword = false,
    this.teclado,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VisibilidadPasswordProvider(),
      child: Consumer<VisibilidadPasswordProvider>(
        builder: (context, vis, _) => TextFormField(
          controller: controller,
          obscureText: esPassword && vis.oculto,
          keyboardType: teclado,
          validator: validator,
          cursorColor: ThemeApp.lila,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: decoracionAuth(
            hint,
            icono,
            sufijo: esPassword
                ? IconButton(
                    tooltip: vis.oculto ? 'Mostrar' : 'Ocultar',
                    icon: Icon(
                      vis.oculto ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: vis.m_alterna,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class BotonAuth extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;

  const BotonAuth({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    final activo = onPressed != null && !cargando;
    final forma = BorderRadius.circular(12);
    return Opacity(
      opacity: onPressed == null && !cargando ? 0.5 : 1,
      child: SizedBox(
        height: 52,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: forma,
              gradient: const LinearGradient(colors: [ThemeApp.morado, Color(0xFF8E6BFF)]),
            ),
            child: InkWell(
              borderRadius: forma,
              onTap: activo ? onPressed : null,
              child: Center(
                child: cargando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        texto,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BotonContornoAuth extends StatelessWidget {
  final String texto;
  final Widget icono;
  final VoidCallback? onPressed;

  const BotonContornoAuth({
    super.key,
    required this.texto,
    required this.icono,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: Colors.white.withValues(alpha: 0.06),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icono,
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    texto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IconoGoogle extends StatelessWidget {
  const IconoGoogle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 13,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class SeparadorAuth extends StatelessWidget {
  const SeparadorAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0x1FFFFFFF));
  }
}

class EnlaceAuth extends StatelessWidget {
  final String? texto;
  final String accion;
  final VoidCallback onTap;

  const EnlaceAuth({super.key, this.texto, required this.accion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Text.rich(
          TextSpan(
            children: [
              if (texto != null)
                TextSpan(text: '$texto ', style: const TextStyle(color: Colors.white70)),
              TextSpan(
                text: accion,
                style: const TextStyle(color: _enlace, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
