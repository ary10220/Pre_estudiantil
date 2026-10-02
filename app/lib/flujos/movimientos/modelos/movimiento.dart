class Movimiento {
  final int id;
  final String tipo;
  final String concepto;
  final double monto;
  final DateTime fecha;

  Movimiento({
    required this.id,
    required this.tipo,
    required this.concepto,
    required this.monto,
    required this.fecha,
  });

  factory Movimiento.desdeJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      tipo: json['tipo'],
      concepto: json['concepto'],
      monto: (json['monto'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha']),
    );
  }
}
