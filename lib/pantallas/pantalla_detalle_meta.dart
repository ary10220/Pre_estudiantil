import 'package:flutter/material.dart';

import '../configuracion/constantes.dart';
import '../configuracion/rutas.dart';
import '../modelos/meta_ahorro.dart';
import '../servicios/servicio_acceso.dart';
import '../servicios/servicio_metas.dart';
import '../servicios/servicio_movimientos.dart';
import '../widgets/mensajes.dart';
import '../widgets/resumen_metas_card.dart';
import '../servicios/analitica.dart';

class PantallaDetalleMeta extends StatefulWidget {
  final MetaAhorro meta;

  const PantallaDetalleMeta({super.key, required this.meta});

  @override
  State<PantallaDetalleMeta> createState() => _PantallaDetalleMetaState();
}

class _DatosTransferencia {
  final MetaAhorro destino;
  final double monto;

  const _DatosTransferencia(this.destino, this.monto);
}

class _PantallaDetalleMetaState extends State<PantallaDetalleMeta> {
  late MetaAhorro _meta;
  ResumenMetas? _resumen;
  List<MetaAhorro> _metas = [];
  List<MovimientoMeta> _historial = [];
  bool _cargando = true;
  bool _operando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _meta = widget.meta;
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado = await ServicioMetas.listar();
      final meta = resultado.metas.firstWhere(
        (m) => m.id == widget.meta.id,
        orElse: () => _meta,
      );
      final historial = await ServicioMetas.historial(meta.id);
      if (!mounted) return;
      setState(() {
        _meta = meta;
        _metas = resultado.metas;
        _resumen = resultado.resumen;
        _historial = historial;
        _cargando = false;
      });
    } on SesionExpirada {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Rutas.login, (ruta) => false);
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    }
  }

  Future<double?> _pedirMonto({
    required String titulo,
    required String pista,
  }) async {
    final controlador = TextEditingController();
    String? error;

    final resultado = await showDialog<double>(
      context: context,
      builder: (contexto) => StatefulBuilder(
        builder: (contexto, setStateDialogo) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            titulo,
            style: const TextStyle(color: Colores.azulOscuro),
          ),
          content: TextField(
            controller: controlador,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Monto (Bs)',
              hintText: pista,
              errorText: error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contexto),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colores.verdeOscuro),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colores.verdeOscuro,
              ),
              onPressed: () {
                final monto = double.tryParse(
                  controlador.text.trim().replaceAll(',', '.'),
                );
                if (monto == null || monto <= 0) {
                  setStateDialogo(() => error = 'Escribe un monto mayor a 0');
                  return;
                }
                Navigator.pop(contexto, monto);
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );

    controlador.dispose();
    return resultado;
  }

  Future<_DatosTransferencia?> _pedirTransferencia(
    List<MetaAhorro> destinos,
  ) async {
    final controlador = TextEditingController();
    MetaAhorro? destino = destinos.first;
    String? error;

    final resultado = await showDialog<_DatosTransferencia>(
      context: context,
      builder: (contexto) => StatefulBuilder(
        builder: (contexto, setStateDialogo) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text(
            'Transferir fondos',
            style: TextStyle(color: Colores.azulOscuro),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Meta destino',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<MetaAhorro>(
                    isExpanded: true,
                    value: destino,
                    items: destinos
                        .map(
                          (meta) => DropdownMenuItem(
                            value: meta,
                            child: Text(meta.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (valor) =>
                        setStateDialogo(() => destino = valor),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controlador,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Monto (Bs)',
                  errorText: error,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contexto),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colores.verdeOscuro),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colores.verdeOscuro,
              ),
              onPressed: () {
                final monto = double.tryParse(
                  controlador.text.trim().replaceAll(',', '.'),
                );
                if (monto == null || monto <= 0) {
                  setStateDialogo(() => error = 'Escribe un monto mayor a 0');
                  return;
                }
                if (destino == null) {
                  setStateDialogo(() => error = 'Elige una meta de destino');
                  return;
                }
                Navigator.pop(contexto, _DatosTransferencia(destino!, monto));
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );

    controlador.dispose();
    return resultado;
  }

  Future<void> _operar(
    Future<ResultadoMeta> Function() accion,
    String mensaje,
  ) async {
    setState(() => _operando = true);
    try {
      await accion();
      if (!mounted) return;
      mostrarMensaje(context, mensaje);
      await _cargar();
    } on SesionExpirada {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Rutas.login, (ruta) => false);
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      mostrarMensaje(context, e.mensaje, esError: true);
    } finally {
      if (mounted) setState(() => _operando = false);
    }
  }

  Future<void> _asignar() async {
    final monto = await _pedirMonto(
      titulo: 'Asignar fondos',
      pista: 'Dinero desde el saldo disponible',
    );
    if (monto == null) return;
    await _operar(
      () async {
        final res = await ServicioMetas.asignar(_meta.id, monto);
        AnaliticaServicio.track('fondos_meta_operados', {'operacion': 'asignar'});
        return res;
      },
      'Fondos asignados',
    );
  }

  Future<void> _retirar() async {
    final monto = await _pedirMonto(
      titulo: 'Retirar fondos',
      pista: 'Dinero reservado en esta meta',
    );
    if (monto == null) return;
    await _operar(
      () async {
        final res = await ServicioMetas.retirar(_meta.id, monto);
        AnaliticaServicio.track('fondos_meta_operados', {'operacion': 'retirar'});
        return res;
      },
      'Fondos retirados',
    );
  }

  Future<void> _transferir() async {
    final destinos = _metas.where((m) => m.id != _meta.id).toList();
    if (destinos.isEmpty) {
      mostrarMensaje(
        context,
        'Necesitas al menos otra meta para transferir',
        esError: true,
      );
      return;
    }

    final datos = await _pedirTransferencia(destinos);
    if (datos == null) return;
    await _operar(
      () async {
        final res = await ServicioMetas.transferir(_meta.id, datos.destino.id, datos.monto);
        AnaliticaServicio.track('fondos_meta_operados', {'operacion': 'transferir'});
        return res;
      },
      'Transferencia realizada',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_meta.nombre),
        backgroundColor: Colors.transparent,
        foregroundColor: Colores.azulOscuro,
      ),
      body: SafeArea(child: _contenido()),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Colores.verdeOscuro),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colores.grisAzulado),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _cargar,
                child: const Text(
                  'Reintentar',
                  style: TextStyle(color: Colores.verdeOscuro),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        if (_resumen != null) ResumenMetasCard(resumen: _resumen!),
        const SizedBox(height: 16),
        _tarjetaMeta(),
        const SizedBox(height: 16),
        _acciones(),
        const SizedBox(height: 24),
        const Text(
          'Historial',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colores.azulOscuro,
          ),
        ),
        const SizedBox(height: 8),
        _historialWidget(),
      ],
    );
  }

  Widget _tarjetaMeta() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colores.verdeClaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _meta.nombre,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colores.azulOscuro,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Objetivo: ${_meta.montoObjetivoTexto}',
            style: const TextStyle(color: Colores.grisAzulado),
          ),
          Text(
            'Reservado: ${_meta.montoReservadoTexto}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colores.verdeOscuro,
            ),
          ),
          Text(
            'Falta: ${_meta.restanteTexto}',
            style: const TextStyle(color: Colores.grisAzulado),
          ),
          Text(
            'Fecha objetivo: ${_meta.fechaTexto}',
            style: const TextStyle(color: Colores.grisAzulado),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _meta.progreso.clamp(0, 1).toDouble(),
              minHeight: 10,
              color: Colores.verdeOscuro,
              backgroundColor: Colores.verdeClaro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _acciones() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: _operando ? null : _asignar,
          style: FilledButton.styleFrom(backgroundColor: Colores.verdeOscuro),
          icon: const Icon(Icons.add),
          label: const Text('Asignar'),
        ),
        OutlinedButton.icon(
          onPressed: _operando ? null : _retirar,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colores.verdeOscuro,
            side: const BorderSide(color: Colores.verdeOscuro),
          ),
          icon: const Icon(Icons.remove),
          label: const Text('Retirar'),
        ),
        OutlinedButton.icon(
          onPressed: _operando ? null : _transferir,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colores.verdeOscuro,
            side: const BorderSide(color: Colores.verdeOscuro),
          ),
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Transferir'),
        ),
      ],
    );
  }

  Widget _historialWidget() {
    if (_historial.isEmpty) {
      return const Text(
        'Aún no hay movimientos para esta meta.',
        style: TextStyle(color: Colores.grisAzulado),
      );
    }

    return Column(
      children: [
        for (final movimiento in _historial) _itemHistorial(movimiento),
      ],
    );
  }

  Widget _itemHistorial(MovimientoMeta movimiento) {
    final esEntrada =
        movimiento.tipo == 'asignacion' ||
        movimiento.tipo == 'transferencia_entrada';
    final color = esEntrada ? Colores.verdeOscuro : Colores.rojo;
    final signo = esEntrada ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.verdeClaro),
      ),
      child: Row(
        children: [
          Icon(
            esEntrada ? Icons.add_circle_outline : Icons.remove_circle_outline,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimiento.tipoTexto,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colores.azulOscuro,
                  ),
                ),
                if (movimiento.metaRelacionada != null)
                  Text(
                    'Meta: ${movimiento.metaRelacionada}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colores.grisAzulado,
                    ),
                  ),
                Text(
                  movimiento.fechaTexto,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colores.grisAzulado,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$signo${movimiento.montoTexto}',
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
