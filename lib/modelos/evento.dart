// Historial de actividad (Tarea 4): un evento por cada acción con sentido.
// Los tipos deben coincidir con el CHECK de la tabla eventos.
enum TipoEvento {
  gastoRegistrado,
  ingresoRegistrado,
  movimientoPagado,
  limiteDefinido;

  // Nombre tal como viaja en JSON (snake_case, igual que el servidor)
  String get textoServidor => switch (this) {
    TipoEvento.gastoRegistrado => 'gasto_registrado',
    TipoEvento.ingresoRegistrado => 'ingreso_registrado',
    TipoEvento.movimientoPagado => 'movimiento_pagado',
    TipoEvento.limiteDefinido => 'limite_definido',
  };

  static TipoEvento desdeTexto(String texto) {
    for (final t in TipoEvento.values) {
      if (t.textoServidor == texto) return t;
    }
    throw ArgumentError('Tipo de evento desconocido: $texto');
  }
}

// Filtros disponibles en la interfaz. 'gastos' NO incluye ingresos
// (decisión Hick: solo 4 chips, los ingresos aparecen en 'todos').
enum FiltroHistorial {
  todos,
  gastos,
  pagos,
  limite;

  String get textoServidor => name;
  String get etiqueta => switch (this) {
    FiltroHistorial.todos => 'Todos',
    FiltroHistorial.gastos => 'Gastos',
    FiltroHistorial.pagos => 'Pagos',
    FiltroHistorial.limite => 'Límite',
  };
}

class Evento {
  final int id;
  final TipoEvento tipo;
  final double? monto;
  final String descripcion;
  final int? movimientoId;
  final String hora; // 'HH:mm', ya formateada por el servidor
  final DateTime creadoEn;

  const Evento({
    required this.id,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    required this.movimientoId,
    required this.hora,
    required this.creadoEn,
  });

  factory Evento.desdeJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] as int,
      tipo: TipoEvento.desdeTexto(json['tipo'] as String),
      monto: (json['monto'] as num?)?.toDouble(),
      descripcion: (json['descripcion'] as String?) ?? '',
      movimientoId: json['movimientoId'] as int?,
      hora: (json['hora'] as String?) ?? '',
      creadoEn: DateTime.parse(json['creadoEn'] as String),
    );
  }
}

class GrupoDia {
  final String titulo; // 'Hoy' / 'Ayer' / '12 de octubre'
  final List<Evento> eventos;

  const GrupoDia({required this.titulo, required this.eventos});

  factory GrupoDia.desdeJson(Map<String, dynamic> json) {
    final lista = (json['eventos'] as List)
        .map((j) => Evento.desdeJson(j as Map<String, dynamic>))
        .toList();
    return GrupoDia(titulo: json['titulo'] as String, eventos: lista);
  }
}
