class Movimiento {
  final int id;
  final String tipo;
  final String concepto;
  final double monto;
  final DateTime fecha;
  final String estado;
  final DateTime? pagadoEn;

  Movimiento({
    required this.id,
    required this.tipo,
    required this.concepto,
    required this.monto,
    required this.fecha,
    required this.estado,
    this.pagadoEn,
  });

  factory Movimiento.desdeJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      tipo: json['tipo'],
      concepto: json['concepto'],
      monto: (json['monto'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha'] as String),
      estado: (json['estado'] as String? ?? 'pendiente'),
      pagadoEn: json['pagado_en'] == null
          ? null
          : DateTime.tryParse(json['pagado_en'] as String),
    );
  }

  bool get esPendiente => estado == 'pendiente';
  bool get esPagado => estado == 'pagado';

  Movimiento copyWith({
    int? id,
    String? tipo,
    String? concepto,
    double? monto,
    DateTime? fecha,
    String? estado,
    DateTime? pagadoEn,
    bool limpiarPagadoEn = false,
  }) {
    return Movimiento(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      concepto: concepto ?? this.concepto,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      pagadoEn: limpiarPagadoEn ? null : (pagadoEn ?? this.pagadoEn),
    );
  }
}
