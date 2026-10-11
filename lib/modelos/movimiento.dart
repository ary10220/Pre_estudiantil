enum EstadoMovimiento { pendiente, pagado }

class Movimiento {
  final int id;
  final String concepto;
  final double monto;
  final DateTime fecha;
  final EstadoMovimiento estado;

  // Un movimiento nuevo siempre empieza como pendiente
  const Movimiento({
    required this.id,
    required this.concepto,
    required this.monto,
    required this.fecha,
    this.estado = EstadoMovimiento.pendiente,
  });

  // Construye el objeto a partir de lo que devuelve el servidor
  factory Movimiento.desdeJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'] as int,
      concepto: json['concepto'] as String,
      monto: (json['monto'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha'] as String),
      estado: json['estado'] == 'pagado'
          ? EstadoMovimiento.pagado
          : EstadoMovimiento.pendiente,
    );
  }

  // Transición: pendiente -> pagado. Cualquier otra se rechaza.
  Movimiento marcarComoPagado() {
    if (estado == EstadoMovimiento.pagado) {
      throw StateError('El movimiento ya está pagado');
    }
    return Movimiento(
      id: id,
      concepto: concepto,
      monto: monto,
      fecha: fecha,
      estado: EstadoMovimiento.pagado,
    );
  }

  static const String motivoMontoBloqueado =
      'Un movimiento pagado no permite modificar su monto.';

  // Restricción por estado: pagado => el monto no se puede modificar
  bool get montoBloqueado => estado == EstadoMovimiento.pagado;

  // Devuelve un movimiento con los datos nuevos. Rechaza cambiar el monto si está pagado.
  Movimiento editar({
    required String concepto,
    required double monto,
    required DateTime fecha,
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
      estado: estado,
    );
  }

  String get montoTexto => 'Bs ${monto.toStringAsFixed(2)}';
  String get fechaTexto => formatearFecha(fecha);

  static String formatearFecha(DateTime f) {
    final dia = f.day.toString().padLeft(2, '0');
    final mes = f.month.toString().padLeft(2, '0');
    return '$dia/$mes/${f.year}';
  }
}