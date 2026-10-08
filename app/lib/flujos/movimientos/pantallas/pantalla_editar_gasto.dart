import 'package:flutter/material.dart';
import '../../../comun/formato.dart';
import '../../../comun/servicios/api.dart';
import '../../../comun/servicios/guardia.dart';
import '../../../comun/tema/espaciado.dart';
import '../../../comun/tema/tipografia.dart';
import '../../../comun/widgets/boton_principal.dart';
import '../../../comun/widgets/campo_texto.dart';
import '../modelos/movimiento.dart';
import '../servicios/movimientos_servicio.dart';
import '../servicios/validaciones.dart';
import 'pantalla_nuevo_gasto.dart' show anioMinimo, anioMaximo;

class PantallaEditarGasto extends StatefulWidget {
  final Movimiento movimiento;

  const PantallaEditarGasto({super.key, required this.movimiento});

  @override
  State<PantallaEditarGasto> createState() => _PantallaEditarGastoState();
}

class _PantallaEditarGastoState extends State<PantallaEditarGasto> {
  late final TextEditingController controlConcepto;
  late final TextEditingController controlMonto;
  late final TextEditingController controlFecha;
  late DateTime fecha;
  String? errorConcepto;
  String? errorMonto;
  bool guardando = false;

  // Regla del proyecto: un movimiento pagado no permite modificar su monto
  bool get montoBloqueado => widget.movimiento.esPagado;

  @override
  void initState() {
    super.initState();
    controlConcepto = TextEditingController(text: widget.movimiento.concepto);
    controlMonto = TextEditingController(text: widget.movimiento.monto.toStringAsFixed(2));
    fecha = widget.movimiento.fecha;
    controlFecha = TextEditingController(text: fechaCorta(fecha));
    leerTokenOIrAlLogin(context);
  }

  @override
  void dispose() {
    controlConcepto.dispose();
    controlMonto.dispose();
    controlFecha.dispose();
    super.dispose();
  }

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

  Future<void> guardarCambios() async {
    setState(() {
      errorConcepto = validarConcepto(controlConcepto.text);
      // Si el monto está bloqueado no se valida ni se envía un monto nuevo
      errorMonto = montoBloqueado ? null : validarMonto(controlMonto.text);
    });
    if (errorConcepto != null || errorMonto != null) return;

    final token = await leerTokenOIrAlLogin(context);
    if (token == null || !mounted) return;

    setState(() => guardando = true);
    try {
      await MovimientosServicio.editarMovimiento(
        token,
        widget.movimiento.id,
        controlConcepto.text.trim(),
        montoBloqueado ? widget.movimiento.monto : leerMonto(controlMonto.text),
        fecha,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
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
              Text('Editar gasto', style: Tipografia.titulo),
              const SizedBox(height: espacio8),
              Text('Corregí el concepto, el monto o la fecha.', style: Tipografia.subtitulo),
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
                // Movimiento pagado: el campo queda visible pero sin poder tocarse
                alTocar: montoBloqueado
                    ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se puede modificar el monto porque el movimiento ya está pagado'),
                      ))
                    : null,
              ),
              if (montoBloqueado) ...[
                const SizedBox(height: espacio8),
                Text(
                  'No se puede modificar el monto porque el movimiento ya está pagado.',
                  key: const Key('ayuda_monto_bloqueado'),
                  style: Tipografia.ayuda,
                ),
              ],
              const SizedBox(height: espacio16),
              CampoTexto(
                etiqueta: 'Fecha',
                controlador: controlFecha,
                alTocar: elegirFecha,
                icono: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: espacio32),
              BotonPrincipal(
                texto: 'Guardar cambios',
                textoCargando: 'Guardando…',
                cargando: guardando,
                alPresionar: guardarCambios,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
