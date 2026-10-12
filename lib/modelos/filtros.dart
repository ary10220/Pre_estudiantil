import 'movimiento.dart';

enum PeriodoFiltro { esteMes, mesAnterior, rango }

enum ClaveFiltro { buscar, tipo, categoria, estado, periodo }

// Mismos mensajes que servidor/filtros.js
const String mensajeRangoIncompleto = 'Elige las dos fechas del rango';
const String mensajeRangoInvertido = 'La fecha "desde" no puede ser posterior a "hasta"';

// Un filtro activo, para mostrarlo como chip que se puede quitar
class FiltroActivo {
  final ClaveFiltro clave;
  final String texto;
  const FiltroActivo(this.clave, this.texto);
}

class FiltrosMovimientos {
  final String buscar;
  final TipoMovimiento? tipo;
  final CategoriaMovimiento? categoria;
  final EstadoMovimiento? estado;
  final PeriodoFiltro? periodo;
  final DateTime? desde;
  final DateTime? hasta;

  const FiltrosMovimientos({
    this.buscar = '',
    this.tipo,
    this.categoria,
    this.estado,
    this.periodo,
    this.desde,
    this.hasta,
  });

  static const FiltrosMovimientos vacio = FiltrosMovimientos();

  bool get hayFiltros => activos.isNotEmpty;

  FiltrosMovimientos conBuscar(String texto) => FiltrosMovimientos(
    buscar: texto,
    tipo: tipo,
    categoria: categoria,
    estado: estado,
    periodo: periodo,
    desde: desde,
    hasta: hasta,
  );

  // Devuelve los filtros sin uno de ellos (al quitar el periodo se limpian las fechas)
  FiltrosMovimientos quitar(ClaveFiltro clave) => FiltrosMovimientos(
    buscar: clave == ClaveFiltro.buscar ? '' : buscar,
    tipo: clave == ClaveFiltro.tipo ? null : tipo,
    categoria: clave == ClaveFiltro.categoria ? null : categoria,
    estado: clave == ClaveFiltro.estado ? null : estado,
    periodo: clave == ClaveFiltro.periodo ? null : periodo,
    desde: clave == ClaveFiltro.periodo ? null : desde,
    hasta: clave == ClaveFiltro.periodo ? null : hasta,
  );

  // null si está bien; si no, el motivo
  String? validar() {
    if (periodo == PeriodoFiltro.rango) {
      if (desde == null || hasta == null) return mensajeRangoIncompleto;
      if (desde!.isAfter(hasta!)) return mensajeRangoInvertido;
    }
    return null;
  }

  // Parámetros que viajan al servidor (solo los filtros activos)
  Map<String, String> toQuery() {
    final mapa = <String, String>{};
    if (buscar.trim().isNotEmpty) mapa['buscar'] = buscar.trim();
    if (tipo != null) mapa['tipo'] = tipo!.name;
    if (categoria != null) mapa['categoria'] = categoria!.name;
    if (estado != null) mapa['estado'] = estado!.name;
    if (periodo != null) {
      mapa['periodo'] = switch (periodo!) {
        PeriodoFiltro.esteMes => 'este_mes',
        PeriodoFiltro.mesAnterior => 'mes_anterior',
        PeriodoFiltro.rango => 'rango',
      };
      if (periodo == PeriodoFiltro.rango && desde != null && hasta != null) {
        mapa['desde'] = Movimiento.fechaParaServidor(desde!);
        mapa['hasta'] = Movimiento.fechaParaServidor(hasta!);
      }
    }
    return mapa;
  }

  // Lista de chips, en un orden fijo
  List<FiltroActivo> get activos {
    final lista = <FiltroActivo>[];
    if (buscar.trim().isNotEmpty) {
      lista.add(FiltroActivo(ClaveFiltro.buscar, 'Búsqueda: "${buscar.trim()}"'));
    }
    if (tipo != null) lista.add(FiltroActivo(ClaveFiltro.tipo, tipo!.texto));
    if (categoria != null) lista.add(FiltroActivo(ClaveFiltro.categoria, categoria!.texto));
    if (estado != null) lista.add(FiltroActivo(ClaveFiltro.estado, estado!.texto));
    if (periodo != null) lista.add(FiltroActivo(ClaveFiltro.periodo, _textoPeriodo()));
    return lista;
  }

  String _textoPeriodo() {
    switch (periodo!) {
      case PeriodoFiltro.esteMes:
        return 'Este mes';
      case PeriodoFiltro.mesAnterior:
        return 'Mes anterior';
      case PeriodoFiltro.rango:
        if (desde == null || hasta == null) return 'Rango de fechas';
        return 'Del ${Movimiento.formatearFecha(desde!)} al ${Movimiento.formatearFecha(hasta!)}';
    }
  }
}

// Totales que calcula el servidor sobre la misma lista filtrada
class TotalesMovimientos {
  final int cantidad;
  final double ingresos;
  final double gastos;

  const TotalesMovimientos({
    required this.cantidad,
    required this.ingresos,
    required this.gastos,
  });

  factory TotalesMovimientos.desdeJson(Map<String, dynamic> json) {
    return TotalesMovimientos(
      cantidad: (json['cantidad'] as num).toInt(),
      ingresos: (json['ingresos'] as num).toDouble(),
      gastos: (json['gastos'] as num).toDouble(),
    );
  }
}