import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';
import '../modelos/filtros.dart';
import '../modelos/movimiento.dart';

// Abre el panel y devuelve los filtros elegidos (null si lo cierran sin aplicar)
Future<FiltrosMovimientos?> mostrarHojaFiltros(
    BuildContext context,
    FiltrosMovimientos actual,
    ) {
  return showModalBottomSheet<FiltrosMovimientos>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _HojaFiltros(actual: actual),
  );
}

class _HojaFiltros extends StatefulWidget {
  final FiltrosMovimientos actual;
  const _HojaFiltros({required this.actual});

  @override
  State<_HojaFiltros> createState() => _HojaFiltrosState();
}

class _HojaFiltrosState extends State<_HojaFiltros> {
  late TipoMovimiento? _tipo = widget.actual.tipo;
  late CategoriaMovimiento? _categoria = widget.actual.categoria;
  late EstadoMovimiento? _estado = widget.actual.estado;
  late PeriodoFiltro? _periodo = widget.actual.periodo;
  late DateTime? _desde = widget.actual.desde;
  late DateTime? _hasta = widget.actual.hasta;
  String? _error;

  FiltrosMovimientos _armar() => FiltrosMovimientos(
    buscar: widget.actual.buscar,
    tipo: _tipo,
    categoria: _categoria,
    estado: _estado,
    periodo: _periodo,
    desde: _periodo == PeriodoFiltro.rango ? _desde : null,
    hasta: _periodo == PeriodoFiltro.rango ? _hasta : null,
  );

  void _aplicar() {
    final filtros = _armar();
    final error = filtros.validar();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, filtros);
  }

  void _limpiar() {
    setState(() {
      _tipo = null;
      _categoria = null;
      _estado = null;
      _periodo = null;
      _desde = null;
      _hasta = null;
      _error = null;
    });
  }

  Future<void> _elegirFecha({required bool esDesde}) async {
    final inicial = (esDesde ? _desde : _hasta) ?? DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (elegida == null) return;
    setState(() {
      if (esDesde) {
        _desde = elegida;
      } else {
        _hasta = elegida;
      }
      _error = null;
    });
  }

  // Un grupo de opciones; la clave null significa "sin filtro"
  Widget _grupo<T>(
      String titulo,
      Map<T?, String> opciones,
      T? valor,
      ValueChanged<T?> alCambiar,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colores.azulOscuro,
          ),
        ),
        const SizedBox(height: 8),
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
              onSelected: (_) => alCambiar(e.key),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _botonFecha(String etiqueta, DateTime? fecha, VoidCallback alPresionar) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: alPresionar,
        icon: const Icon(Icons.calendar_today_outlined, size: 18, color: Colores.verdeOscuro),
        label: Text(
          fecha == null ? etiqueta : Movimiento.formatearFecha(fecha),
          style: const TextStyle(color: Colores.azulOscuro),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colores.verdeClaro),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colores.azulOscuro,
              ),
            ),
            const SizedBox(height: 20),
            _grupo<TipoMovimiento>(
              'Tipo',
              <TipoMovimiento?, String>{
                null: 'Todos',
                for (final t in TipoMovimiento.values) t: t.texto,
              },
              _tipo,
                  (v) => setState(() => _tipo = v),
            ),
            _grupo<CategoriaMovimiento>(
              'Categoría',
              <CategoriaMovimiento?, String>{
                null: 'Todas',
                for (final c in CategoriaMovimiento.values) c: c.texto,
              },
              _categoria,
                  (v) => setState(() => _categoria = v),
            ),
            _grupo<EstadoMovimiento>(
              'Estado',
              <EstadoMovimiento?, String>{
                null: 'Todos',
                for (final e in EstadoMovimiento.values) e: e.texto,
              },
              _estado,
                  (v) => setState(() => _estado = v),
            ),
            _grupo<PeriodoFiltro>(
              'Periodo',
              const <PeriodoFiltro?, String>{
                null: 'Todos',
                PeriodoFiltro.esteMes: 'Este mes',
                PeriodoFiltro.mesAnterior: 'Mes anterior',
                PeriodoFiltro.rango: 'Rango de fechas',
              },
              _periodo,
                  (v) => setState(() {
                _periodo = v;
                _error = null;
              }),
            ),
            if (_periodo == PeriodoFiltro.rango) ...[
              Row(
                children: [
                  _botonFecha('Desde', _desde, () => _elegirFecha(esDesde: true)),
                  const SizedBox(width: 12),
                  _botonFecha('Hasta', _hasta, () => _elegirFecha(esDesde: false)),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colores.rojo)),
              ),
            Row(
              children: [
                TextButton(
                  onPressed: _limpiar,
                  child: const Text('Limpiar', style: TextStyle(color: Colores.verdeOscuro)),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _aplicar,
                  style: FilledButton.styleFrom(backgroundColor: Colores.verdeOscuro),
                  child: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}