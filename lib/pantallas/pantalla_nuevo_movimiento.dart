import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';
import '../configuracion/rutas.dart';
import '../modelos/limite.dart';
import '../modelos/movimiento.dart';
import '../servicios/servicio_acceso.dart';
import '../servicios/servicio_limite.dart';
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
  // Sin categoría al crear: la persona la elige (H5.3)
  CategoriaMovimiento? _categoria;
  String? _errorCategoria;
  bool _cargando = false;
  ResumenLimite? _resumen;

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
    _cargarResumen();
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
      _cargarResumen();
    }
  }

  // Límite del mes de la fecha elegida (sin fecha, el mes actual)
  Future<void> _cargarResumen() async {
    final mes = _fecha == null ? null : Movimiento.fechaParaServidor(_fecha!).substring(0, 7);
    try {
      final resumen = await ServicioLimite.leer(mes);
      if (!mounted) return;
      setState(() => _resumen = resumen);
    } on SesionExpirada {
      // Se vuelve al login al guardar
    } on ErrorAcceso {
      // Sin el aviso igual se puede guardar: el servidor controla el límite
    }
  }

  // Debajo del monto: cuánto queda del límite y cuánto quedaría con este gasto (H5.1)
  Widget? _avisoLimite() {
    final r = _resumen;
    if (_tipo != TipoMovimiento.gasto || _montoBloqueado || r == null || !r.tieneLimite) {
      return null;
    }
    // Al editar, el monto anterior se descuenta solo si es del mismo mes
    final original = widget.movimiento;
    final montoAnterior =
        original != null && Movimiento.fechaParaServidor(original.fecha).startsWith(r.mes!)
            ? original.monto
            : 0.0;
    final aviso = avisoGasto(
      r,
      double.tryParse(_monto.text.trim().replaceAll(',', '.')),
      montoAnterior: montoAnterior,
    );
    final color = aviso.seExcede ? Colores.rojo : Colores.grisAzulado;

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.savings_outlined, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              aviso.texto,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: aviso.seExcede ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardar() async {
    final concepto = _concepto.text.trim();
    final textoMonto = _monto.text.trim().replaceAll(',', '.');

    if (concepto.isEmpty || textoMonto.isEmpty || _fecha == null) {
      mostrarMensaje(context, 'Completa todos los campos', esError: true);
      return;
    }
    if (_categoria == null) {
      setState(() => _errorCategoria = 'Elige una categoría');
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
          _categoria!,
        );
      } else {
        await ServicioMovimientos.crear(concepto, monto, _fecha!, _tipo, _categoria!);
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

  // Opciones en chips. Si alCambiar es null, quedan deshabilitadas. valor null = ninguna elegida.
  Widget _selector<T>(
      String titulo,
      Map<T, String> opciones,
      T? valor,
      ValueChanged<T>? alCambiar, {
        String? error,
      }) {
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
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Text(error, style: const TextStyle(fontSize: 13, color: Colores.rojo)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final aviso = _avisoLimite();

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
                    (v) => setState(() {
                  _categoria = v;
                  _errorCategoria = null;
                }),
                error: _errorCategoria,
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
                // Recalcula el aviso del límite mientras se escribe
                alCambiar: (_) => setState(() {}),
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
              ?aviso,
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