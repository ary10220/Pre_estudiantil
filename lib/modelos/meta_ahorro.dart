import 'limite.dart';
import 'movimiento.dart';

class MetaAhorro {
  final int id;
  final String nombre;
  final double montoObjetivo;
  final double montoReservado;
  final DateTime fechaObjetivo;
  final double progreso;

  const MetaAhorro({
    required this.id,
    required this.nombre,
    required this.montoObjetivo,
    required this.montoReservado,
    required this.fechaObjetivo,
    required this.progreso,
  });

  factory MetaAhorro.desdeJson(Map<String, dynamic> json) {
    return MetaAhorro(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      montoObjetivo: (json['montoObjetivo'] as num).toDouble(),
      montoReservado: (json['montoReservado'] as num).toDouble(),
      fechaObjetivo: DateTime.parse(json['fechaObjetivo'] as String),
      progreso: (json['progreso'] as num).toDouble(),
    );
  }

  double get restante {
    final valor = montoObjetivo - montoReservado;
    return valor < 0 ? 0 : valor;
  }

  String get montoObjetivoTexto => formatearBs(montoObjetivo);
  String get montoReservadoTexto => formatearBs(montoReservado);
  String get restanteTexto => formatearBs(restante);
  String get fechaTexto => Movimiento.formatearFecha(fechaObjetivo);
}

class ResumenMetas {
  final double total;
  final double reservado;
  final double disponible;

  const ResumenMetas({
    required this.total,
    required this.reservado,
    required this.disponible,
  });

  factory ResumenMetas.desdeJson(Map<String, dynamic> json) {
    return ResumenMetas(
      total: (json['total'] as num).toDouble(),
      reservado: (json['reservado'] as num).toDouble(),
      disponible: (json['disponible'] as num).toDouble(),
    );
  }

  String get totalTexto => formatearBs(total);
  String get reservadoTexto => formatearBs(reservado);
  String get disponibleTexto => formatearBs(disponible);
}

class MovimientoMeta {
  final int id;
  final String tipo;
  final double monto;
  final String? metaRelacionada;
  final DateTime creadoEn;

  const MovimientoMeta({
    required this.id,
    required this.tipo,
    required this.monto,
    required this.creadoEn,
    this.metaRelacionada,
  });

  factory MovimientoMeta.desdeJson(Map<String, dynamic> json) {
    return MovimientoMeta(
      id: json['id'] as int,
      tipo: json['tipo'] as String,
      monto: (json['monto'] as num).toDouble(),
      metaRelacionada: json['metaRelacionada'] as String?,
      creadoEn: DateTime.parse(json['creadoEn'] as String),
    );
  }

  String get tipoTexto => switch (tipo) {
    'asignacion' => 'Asignación',
    'retiro' => 'Retiro',
    'transferencia_salida' => 'Transferencia enviada',
    'transferencia_entrada' => 'Transferencia recibida',
    _ => tipo,
  };

  String get montoTexto => formatearBs(monto);

  String get fechaTexto {
    final fecha = creadoEn.toLocal();
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year} $hora:$minuto';
  }
}

class ResultadoMetas {
  final List<MetaAhorro> metas;
  final ResumenMetas resumen;

  const ResultadoMetas(this.metas, this.resumen);
}

class ResultadoMeta {
  final MetaAhorro meta;
  final ResumenMetas resumen;

  const ResultadoMeta(this.meta, this.resumen);
}
