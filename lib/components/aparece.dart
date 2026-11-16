import 'package:flutter/material.dart';

/// Hace que un elemento aparezca con un desvanecido y un pequeño deslizamiento.
/// [indice] escalona la entrada de listas (uno tras otro).
class Aparece extends StatelessWidget {
  final Widget child;
  final int indice;

  const Aparece({super.key, required this.child, this.indice = 0});

  @override
  Widget build(BuildContext context) {
    final retraso = indice > 8 ? 8 : indice;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + retraso * 80),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, valor, hijo) {
        return Opacity(
          opacity: valor,
          child: Transform.translate(
            offset: Offset(0, (1 - valor) * 18),
            child: hijo,
          ),
        );
      },
    );
  }
}
