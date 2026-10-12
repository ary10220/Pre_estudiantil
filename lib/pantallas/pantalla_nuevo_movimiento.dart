import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';
import '../configuracion/rutas.dart';
import '../modelos/movimiento.dart';
import '../servicios/servicio_acceso.dart';
import '../servicios/servicio_movimientos.dart';
import '../widgets/boton_pildora.dart';
import '../widgets/campo_texto.dart';
import '../widgets/mensajes.dart';

class PantallaNuevoMovimiento extends StatefulWidget {
  // Si viene un movimiento, la pantalla funciona en modo edición
  final Movimiento? movimiento;

  const PantallaNuevoMovimiento({super.key, this.movimiento});

  @override
  State<PantallaNuevoMovimiento> createState() => _PantallaNuevoMovimientoState();
}

class _PantallaNuevoMovimientoState extends State<PantallaNuevoMovimiento> {
  final _concepto = TextEditingController();
  final _monto = TextEditingController();
  final _fechaTexto = TextEditingController();
  DateTime? _fecha;
  TipoMovimiento _tipo = TipoMovimiento.gasto;
  CategoriaMovimiento _categoria = CategoriaMovimiento.otros;
  bool _cargando = false;

  bool get _editando => widget.movimiento != null;
  bool get _montoBloqueado => widget.movimiento?.montoBloqueado ?? false;

  @override
  void initState() {
    super.initState();
    final m = widget.movimiento;
    if (m != null) {
      _concepto.text = m.concepto;
      _monto.text = m.monto.toStringAsFixed(2);
      _fecha = m.fecha;
      _fechaTexto.text = Movimiento.formatearFecha(m.fecha);
      _tipo = m.tipo;
      _categoria = m.categoria;
    }
  }

  @override
  void dispose() {
    _concepto.dispose();
    _monto.dispose();
    _fechaTexto.dispose();
    super.dispose();
  }

  // Sin restricción: se puede elegir cualquier fecha
  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (elegida != null) {
      setState(() {
        _fecha = elegida;
        _fechaTexto.text = Movimiento.formatearFecha(elegida);
      });
    }
  }

  Future<void> _guardar() async {
    final concepto = _concepto.text.trim();
    final textoMonto = _monto.text.trim().replaceAll(',', '.');

    if (concepto.isEmpty || textoMonto.isEmpty || _fecha == null) {
      mostrarMensaje(context, 'Completa todos los campos', esError: true);
      return;
    }
    final monto = double.tryParse(textoMonto);
    if (monto == null || monto <= 0) {
      mostrarMensaje(context, 'Escribe un monto mayor a 0', esError: true);
      return;
    }

    setState(() => _cargando = true);
    try {
      if (_editando) {
        await ServicioMovimientos.editar(
          widget.movimiento!,
          concepto,
          monto,
          _fecha!,
          _categoria,
        );
      } else {
        await ServicioMovimientos.crear(concepto, monto, _fecha!, _tipo, _categoria);
      }
      if (!mounted) return;
      mostrarMensaje(context, _editando ? 'Cambios guardados' : 'Movimiento guardado');
      Navigator.pop(context, true); // true = hay que refrescar la lista
    } on SesionExpirada {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Rutas.login, (ruta) => false);
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      mostrarMensaje(context, e.mensaje, esError: true);
    } on StateError catch (e) {
      // Regla del modelo (por ejemplo, monto bloqueado)
      if (!mounted) return;
      mostrarMensaje(context, e.message, esError: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // Opciones en chips. Si alCambiar es null, quedan deshabilitadas.
  Widget _selector<T>(
      String titulo,
      Map<T, String> opciones,
      T valor,
      ValueChanged<T>? alCambiar,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colores.grisAzulado,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opciones.entries.map((e) {
            final elegido = valor == e.key;
            return ChoiceChip(
              label: Text(e.value),
              selected: elegido,
              showCheckmark: false,
              selectedColor: Colores.verdeClaro,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: elegido ? Colores.verdeOscuro : Colores.azulOscuro,
                fontWeight: elegido ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(
                color: elegido ? Colores.verdeOscuro : Colores.verdeClaro,
              ),
              onSelected: alCambiar == null ? null : (_) => alCambiar(e.key),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colores.azulOscuro,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                _editando ? 'Editar movimiento' : 'Nuevo movimiento',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colores.azulOscuro,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _editando ? 'Modifica los datos y guarda.' : 'Se guardará como pendiente.',
                style: const TextStyle(fontSize: 16, color: Colores.grisAzulado),
              ),
              const SizedBox(height: 32),
              _selector<TipoMovimiento>(
                _editando ? 'Tipo (no se puede cambiar)' : 'Tipo',
                {for (final t in TipoMovimiento.values) t: t.texto},
                _tipo,
                _editando ? null : (v) => setState(() => _tipo = v),
              ),
              const SizedBox(height: 20),
              _selector<CategoriaMovimiento>(
                'Categoría',
                {for (final c in CategoriaMovimiento.values) c: c.texto},
                _categoria,
                    (v) => setState(() => _categoria = v),
              ),
              const SizedBox(height: 20),
              CampoTexto(
                controlador: _concepto,
                etiqueta: 'Concepto',
                icono: Icons.description_outlined,
              ),
              const SizedBox(height: 16),
              CampoTexto(
                controlador: _monto,
                etiqueta: 'Monto (Bs)',
                icono: _montoBloqueado ? Icons.lock_outline : Icons.attach_money,
                tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                // Si está bloqueado: solo lectura, y al tocarlo se explica el motivo
                soloLectura: _montoBloqueado,
                alTocar: _montoBloqueado
                    ? () => mostrarMensaje(
                  context,
                  Movimiento.motivoMontoBloqueado,
                  esError: true,
                )
                    : null,
              ),
              if (_montoBloqueado)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colores.grisAzulado),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          Movimiento.motivoMontoBloqueado,
                          style: TextStyle(fontSize: 13, color: Colores.grisAzulado),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              CampoTexto(
                controlador: _fechaTexto,
                etiqueta: 'Fecha',
                icono: Icons.calendar_today_outlined,
                soloLectura: true,
                alTocar: _elegirFecha,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 58,
                child: _cargando
                    ? const Center(
                  child: CircularProgressIndicator(color: Colores.verdeOscuro),
                )
                    : BotonPildora(
                  texto: _editando ? 'Guardar cambios' : 'Guardar',
                  icono: Icons.check,
                  alPresionar: _guardar,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}