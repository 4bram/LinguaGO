import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingua_go/components/botones_campos.dart';
import 'package:lingua_go/components/responsive.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/components/validadores.dart';
import 'package:lingua_go/providers/carrito_provider.dart';
import 'package:provider/provider.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final _form = GlobalKey<FormState>();
  final conTitular = TextEditingController();
  final conNumero = TextEditingController();
  final conExp = TextEditingController();
  final conCvv = TextEditingController();

  @override
  void dispose() {
    conTitular.dispose();
    conNumero.dispose();
    conExp.dispose();
    conCvv.dispose();
    super.dispose();
  }

  Future<void> _pagar() async {
    if (!_form.currentState!.validate()) return;
    final partes = conExp.text.split('/');
    final resultado = await context.read<CarritoProvider>().m_pagar(
          titular: conTitular.text.trim(),
          numero: conNumero.text.replaceAll(' ', ''),
          mes: int.parse(partes[0]),
          anio: 2000 + int.parse(partes[1]),
          cvv: conCvv.text,
        );
    if (!mounted) return;

    if (resultado.exito) {
      await showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Compra exitosa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 12),
              Text(
                'Tu pedido quedó registrado.\nFolio: ${resultado.idTransaccion}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () => Navigator.of(c).pop(),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensaje),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    final lineas = carrito.lineas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        backgroundColor: ThemeApp.morado,
        foregroundColor: Colors.white,
      ),
      body: lineas.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 72, color: ThemeApp.lila),
                    const SizedBox(height: 12),
                    const Text('Tu carrito está vacío', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Ir a la tienda'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: ContenedorCentrado(
                anchoMaximo: 480,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _form,
                    child: Column(
                      children: [
                        for (final l in lineas)
                          Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
                              child: Row(
                                children: [
                                  Icon(l.key.icono, color: ThemeApp.morado),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l.key.nombre,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        Text('${l.value} × \$${l.key.precio} MXN',
                                            style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Quitar uno',
                                    onPressed: () =>
                                        context.read<CarritoProvider>().m_quita(l.key.id),
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  IconButton(
                                    tooltip: 'Eliminar',
                                    onPressed: () =>
                                        context.read<CarritoProvider>().m_elimina(l.key.id),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [ThemeApp.morado, ThemeApp.lila],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL (${carrito.totalArticulos} artículos)',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${carrito.total} MXN',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: conTitular,
                          textCapitalization: TextCapitalization.words,
                          validator: (v) => Validadores.requerido(v, 'El titular'),
                          decoration: decoracionCampo('Titular de la tarjeta', Icons.person),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: conNumero,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FormatoTarjeta()],
                          validator: Validadores.tarjeta,
                          decoration: decoracionCampo('Número de tarjeta', Icons.credit_card),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: conExp,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FormatoExpira()],
                                validator: Validadores.expiracion,
                                decoration: decoracionCampo('MM/AA', Icons.date_range),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: conCvv,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                validator: Validadores.cvv,
                                decoration: decoracionCampo('CVV', Icons.lock),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tarjetas de ejemplo\n'
                          'Tarjeta 1 (aprobada): 4242 4242 4242 4242\n'
                          'Tarjeta 2 (rechazada): 4000 0000 0000 0002\n'
                          'Fecha futura y CVV cualquiera.',
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        BotonPrincipal(
                          texto: 'PAGAR \$${carrito.total} MXN',
                          icono: Icons.lock,
                          cargando: carrito.procesando,
                          onPressed: _pagar,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
