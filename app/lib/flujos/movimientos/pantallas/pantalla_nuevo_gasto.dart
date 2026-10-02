import 'package:flutter/material.dart';
import '../../../comun/servicios/api.dart';
import '../../../comun/servicios/guardia.dart';
import '../../../comun/tema/espaciado.dart';
import '../../../comun/tema/tipografia.dart';
import '../../../comun/widgets/boton_principal.dart';
import '../../../comun/widgets/campo_texto.dart';
import '../servicios/movimientos_servicio.dart';
import '../servicios/validaciones.dart';

class PantallaNuevoGasto extends StatefulWidget {
  const PantallaNuevoGasto({super.key});

  @override
  State<PantallaNuevoGasto> createState() => _PantallaNuevoGastoState();
}

class _PantallaNuevoGastoState extends State<PantallaNuevoGasto> {
  final controlConcepto = TextEditingController();
  final controlMonto = TextEditingController();
  String? errorConcepto;
  String? errorMonto;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    leerTokenOIrAlLogin(context);
  }

  @override
  void dispose() {
    controlConcepto.dispose();
    controlMonto.dispose();
    super.dispose();
  }

  Future<void> guardarGasto() async {
    setState(() {
      errorConcepto = validarConcepto(controlConcepto.text);
      errorMonto = validarMonto(controlMonto.text);
    });
    if (errorConcepto != null || errorMonto != null) return;

    final token = await leerTokenOIrAlLogin(context);
    if (token == null || !mounted) return;

    setState(() => guardando = true);
    try {
      await MovimientosServicio.guardarGasto(token, controlConcepto.text.trim(), leerMonto(controlMonto.text));
      if (!mounted) return;
      // Si se abrió directo por enlace no hay lista detrás, entonces se abre la lista
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        Navigator.pushReplacementNamed(context, '/movimientos');
      }
    } on ErrorApi catch (e) {
      if (!mounted) return;
      if (e.codigo == 401) {
        mandarAlLogin(context, e.mensaje);
      } else if (e.mensaje == mensajeConceptoVacio || e.mensaje == mensajeConceptoLargo) {
        setState(() => errorConcepto = e.mensaje);
      } else if (e.codigo == 400) {
        setState(() => errorMonto = e.mensaje);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
      }
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(margenLateral, espacio8, margenLateral, espacio24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nuevo gasto', style: Tipografia.titulo),
              const SizedBox(height: espacio8),
              Text('La fecha se pone sola con el día de hoy.', style: Tipografia.subtitulo),
              const SizedBox(height: espacio24),
              CampoTexto(
                etiqueta: 'Concepto',
                controlador: controlConcepto,
                error: errorConcepto,
                alCambiar: (_) => setState(() => errorConcepto = null),
                pista: 'Ej.: Transporte',
                ayuda: 'Entre 2 y 40 letras',
                largoMaximo: 40,
              ),
              const SizedBox(height: espacio16),
              CampoTexto(
                etiqueta: 'Monto (Bs)',
                controlador: controlMonto,
                error: errorMonto,
                alCambiar: (_) => setState(() => errorMonto = null),
                pista: 'Ej.: 25',
                tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                accionTeclado: TextInputAction.done,
              ),
              const SizedBox(height: espacio32),
              BotonPrincipal(
                texto: 'Guardar gasto',
                textoCargando: 'Guardando…',
                cargando: guardando,
                alPresionar: guardarGasto,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
