import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingua_go/components/botones_campos.dart';
import 'package:lingua_go/components/responsive.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/components/validadores.dart';
import 'package:lingua_go/config/sonidos_service.dart';
import 'package:lingua_go/models/plan_model.dart';
import 'package:lingua_go/providers/suscripcion_provider.dart';
import 'package:provider/provider.dart';

class PagoScreen extends StatefulWidget {
  const PagoScreen({super.key});

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
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

  Future<void> _pagar(PlanModel plan) async {
    if (!_form.currentState!.validate()) return;
    final partes = conExp.text.split('/');
    final resultado = await context.read<SuscripcionProvider>().m_pagar(
          plan: plan,
          titular: conTitular.text.trim(),
          numero: conNumero.text.replaceAll(' ', ''),
          mes: int.parse(partes[0]),
          anio: 2000 + int.parse(partes[1]),
          cvv: conCvv.text,
        );
    if (!mounted) return;

    if (resultado.exito) {
      SonidosService.m_compra();
      await showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Pago exitoso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 12),
              Text(
                'Ya tienes el plan ${plan.nombre}.\nFolio: ${resultado.idTransaccion}',
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
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final idPlan = ModalRoute.of(context)!.settings.arguments as String;
    final plan = PlanModel.m_porId(idPlan);
    final susc = context.watch<SuscripcionProvider>();

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Plan no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago'),
        backgroundColor: ThemeApp.morado,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: ContenedorCentrado(
          anchoMaximo: 480,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _form,
              child: Column(
                children: [
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
                          'Plan ${plan.nombre}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${plan.precio} MXN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          plan.meses == 1 ? '1 mes de acceso' : '${plan.meses} meses de acceso',
                          style: const TextStyle(color: Colors.white),
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
                    decoration: decoracionCampo('Numero de tarjeta', Icons.credit_card),
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
                    'Tarjetas de prueba\n'
                    'Aprobada: 4242 4242 4242 4242\n'
                    'Rechazada: 4000 0000 0000 0002',
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  BotonPrincipal(
                    texto: 'Pagar \$${plan.precio} MXN',
                    icono: Icons.lock,
                    cargando: susc.procesando,
                    onPressed: () => _pagar(plan),
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
