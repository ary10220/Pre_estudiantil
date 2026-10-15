import 'limite.dart';

enum EstadoMovimiento { pendiente, pagado }

enum TipoMovimiento { ingreso, gasto }

enum CategoriaMovimiento { comida, transporte, estudio, otros }

// Textos para mostrar en la interfaz (H2.1: el ingreso se cobra, no se paga)
extension TextoEstado on EstadoMovimiento {
  String get texto => this == EstadoMovimiento.pagado ? 'Pagado' : 'Pendiente';

  // Palabra según el tipo: el gasto se paga, el ingreso se cobra.
  String textoPara(TipoMovimiento tipo) {
    final esIngreso = tipo == TipoMovimiento.ingreso;
    if (this == EstadoMovimiento.pagado) {
      return esIngreso ? 'Cobrado' : 'Pagado';
    }
    return esIngreso ? 'Por cobrar' : 'Pendiente';
  }
}

extension TextoTipo on TipoMovimiento {
  String get texto => this == TipoMovimiento.ingreso ? 'Ingreso' : 'Gasto';
}

extension TextoCategoria on CategoriaMovimiento {
  String get texto => switch (this) {
    CategoriaMovimiento.comida => 'Comida',
    CategoriaMovimiento.transporte => 'Transporte',
    CategoriaMovimiento.estudio => 'Estudio',
    CategoriaMovimiento.otros => 'Otros',
  };
}

class Movimiento {
  final int id;
  final String concepto;
  final double monto;
  final DateTime fecha;
  final TipoMovimiento tipo;
  final CategoriaMovimiento categoria;
  final EstadoMovimiento estado;

  // Un movimiento nuevo siempre empieza como pendiente
  const Movimiento({
    required this.id,
    required this.concepto,
    required this.monto,
    required this.fecha,
    this.tipo = TipoMovimiento.gasto,
    this.categoria = CategoriaMovimiento.otros,
    this.estado = EstadoMovimiento.pendiente,
  });

  // Construye el objeto a partir de lo que devuelve el servidor
  factory Movimiento.desdeJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'] as int,
      concepto: json['concepto'] as String,
      monto: (json['monto'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha'] as String),
      tipo: TipoMovimiento.values.byName((json['tipo'] as String?) ?? 'gasto'),
      categoria: CategoriaMovimiento.values.byName((json['categoria'] as String?) ?? 'otros'),
      estado: json['estado'] == 'pagado'
          ? EstadoMovimiento.pagado
          : EstadoMovimiento.pendiente,
    );
  }

  bool get esIngreso => tipo == TipoMovimiento.ingreso;

  // Texto del estado según el tipo (H2.1)
  String get estadoTexto => estado.textoPara(tipo);

  // Texto del botón y del diálogo según el tipo
  String get accionMarcarTexto =>
      esIngreso ? 'Marcar como cobrado' : 'Marcar como pagado';

  // Motivo del monto bloqueado según el tipo
  String get motivoMontoBloqueadoTexto => esIngreso
      ? 'Un movimiento cobrado no permite modificar su monto.'
      : motivoMontoBloqueado;

  // Transición: pendiente -> pagado. Cualquier otra se rechaza.
  // El estado interno sigue siendo 'pagado' (lo espera el servidor);
  // solo cambia la palabra que ve la persona.
  Movimiento marcarComoPagado() {
    if (estado == EstadoMovimiento.pagado) {
      throw StateError(
        esIngreso ? 'El movimiento ya está cobrado' : 'El movimiento ya está pagado',
      );
    }
    return Movimiento(
      id: id,
      concepto: concepto,
      monto: monto,
      fecha: fecha,
      tipo: tipo,
      categoria: categoria,
      estado: EstadoMovimiento.pagado,
    );
  }

  static const String motivoMontoBloqueado =
      'Un movimiento pagado no permite modificar su monto.';

  // Restricción por estado: pagado => el monto no se puede modificar
  bool get montoBloqueado => estado == EstadoMovimiento.pagado;

  // Devuelve un movimiento con los datos nuevos. Rechaza cambiar el monto si está pagado.
  // El tipo no cambia; la categoría solo si se indica una nueva.
  Movimiento editar({
    required String concepto,
    required double monto,
    required DateTime fecha,
    CategoriaMovimiento? categoria,
  }) {
    final cambiaMonto = (monto - this.monto).abs() >= 0.005;
    if (montoBloqueado && cambiaMonto) {
      throw StateError(motivoMontoBloqueado);
    }
    return Movimiento(
      id: id,
      concepto: concepto,
      monto: montoBloqueado ? this.monto : monto,
      fecha: fecha,
      tipo: tipo,
      categoria: categoria ?? this.categoria,
      estado: estado,
    );
  }

  // H4.1: mismo formato con coma que el resto de la app
  String get montoTexto => formatearBs(monto);
  String get fechaTexto => formatearFecha(fecha);

  static String formatearFecha(DateTime f) {
    final dia = f.day.toString().padLeft(2, '0');
    final mes = f.month.toString().padLeft(2, '0');
    return '$dia/$mes/${f.year}';
  }

  // Fecha como la espera el servidor: AAAA-MM-DD
  static String fechaParaServidor(DateTime f) {
    final mes = f.month.toString().padLeft(2, '0');
    final dia = f.day.toString().padLeft(2, '0');
    return '${f.year.toString().padLeft(4, '0')}-$mes-$dia';
  }
}