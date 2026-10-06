import 'package:flutter/material.dart';
import '../../../comun/formato.dart';
import '../../../comun/servicios/api.dart';
import '../../../comun/servicios/guardia.dart';
import '../../../comun/tema/espaciado.dart';
import '../../../comun/tema/tipografia.dart';
import '../../../comun/widgets/boton_principal.dart';
import '../../../comun/widgets/campo_texto.dart';
import '../servicios/movimientos_servicio.dart';
import '../servicios/validaciones.dart';

// Rango del calendario: se puede elegir cualquier fecha, sin restricci��n.
// showDatePicker exige que firstDate <= initialDate <= lastDate, as�� que el
// l��mite se pone con a��os amplios en vez de dejar el calendario abierto.
final DateTime anioMinimo = DateTime(2000);
final DateTime anioMaximo = DateTime(2100);

class PantallaNuevoGasto extends StatefulWidget {
  const PantallaNuevoGasto({super.key});

  @override
  State<PantallaNuevoGasto> createState() => _PantallaNuevoGastoState();
}

class _PantallaNuevoGastoState extends State<PantallaNuevoGasto> {
  final controlConcepto = TextEditingController();
  final controlMonto = TextEditingController();
  final controlFecha = TextEditingController();
  DateTime fecha = DateTime.now();
  String? errorConcepto;
  String? errorMonto;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    controlFecha.text = fechaCorta(fecha);
    leerTokenOIrAlLogin(context);
  }

  @override
  void dispose() {
    controlConcepto.dispose();
    controlMonto.dispose();
    controlFecha.dispose();
    super.dispose();
  }

  // Arranca en hoy; el calendario no deja elegir días que todavía no pasaron
  Future<void> elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: anioMinimo,
      lastDate: anioMaximo,
    );
    if (elegida == null) return;
    setState(() {
      fecha = elegida;
      controlFecha.text = fechaCorta(elegida);
    });
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
      await MovimientosServicio.guardarGasto(
        token,
        controlConcepto.text.trim(),
        leerMonto(controlMonto.text),
        fecha,
      );
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
              Text('Anotá qué gastaste, cuánto y cuándo.', style: Tipografia.subtitulo),
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
              const SizedBox(height: espacio16),
              CampoTexto(
                etiqueta: 'Fecha',
                controlador: controlFecha,
                alTocar: elegirFecha,
                icono: Icons.calendar_today_outlined,
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
