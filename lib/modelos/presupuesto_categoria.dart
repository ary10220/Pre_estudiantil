// Es el estado del presupuesto de una categoria en un mes
// esto corresponde a cada item de ""categorias" en GET presupuestos-categoria
import 'package:flutter/material.dart';

import '../configuracion/constantes.dart';

enum EstadoPresupuesto { sinLimite, normal, aviso, excedido }

// Representa el estado del presupuesto de una categoria en un mes especifico.
class PresupuestoCategoria {
  final String categoria;
  final double? limite;
  final double gastado;
  final double? restante;
  final double? proporcion;

  const PresupuestoCategoria({
    required this.categoria,
    required this.limite,
    required this.gastado,
    required this.restante,
    required this.proporcion,
  });

  factory PresupuestoCategoria.desdeJson(Map<String, dynamic> json) {
    return PresupuestoCategoria(
      categoria: json['categoria'] as String,
      limite: (json['limite'] as num?)?.toDouble(),
      gastado: (json['gastado'] as num).toDouble(),
      restante: (json['restante'] as num?)?.toDouble(),
      proporcion: (json['proporcion'] as num?)?.toDouble(),
    );
  }

  bool get tieneLimite => limite != null && limite! > 0;

  // Es excedido si se supera el 100 % del presupuesto
  bool get excedido => tieneLimite && gastado > limite!;

  // un aviso si alcanza o supera el 80 % sin superar el 100 %
  bool get enAviso =>
      tieneLimite && !excedido && gastado >= (limite! * 0.8 - 0.001);

  EstadoPresupuesto get estado {
    if (!tieneLimite) return EstadoPresupuesto.sinLimite;
    if (excedido) return EstadoPresupuesto.excedido;
    if (enAviso) return EstadoPresupuesto.aviso;
    return EstadoPresupuesto.normal;
  }

  Color get colorEstado => switch (estado) {
    EstadoPresupuesto.excedido => Colores.rojo,
    EstadoPresupuesto.aviso => Colores.aviso,
    EstadoPresupuesto.normal => Colores.verdeOscuro,
    EstadoPresupuesto.sinLimite => Colores.grisAzulado,
  };

  // Progreso  entre 0.0 y 1.0
  double get progresoBarra {
    if (!tieneLimite || limite! <= 0) return 0.0;
    final valor = gastado / limite!;
    if (valor.isNaN || valor < 0) return 0.0;
    if (valor > 1.0) return 1.0;
    return valor;
  }

  String get porcentajeTexto {
    if (!tieneLimite) return '';
    final pct =
        (proporcion != null ? proporcion! * 100 : (gastado / limite! * 100))
            .round();
    return '$pct%';
  }

  // icono segun la categoria
  IconData get icono => switch (categoria.toLowerCase()) {
    'comida' => Icons.restaurant,
    'transporte' => Icons.directions_bus,
    'estudio' => Icons.school,
    _ => Icons.category_outlined,
  };

  String get nombreLegible {
    if (categoria.isEmpty) return '';
    return categoria[0].toUpperCase() + categoria.substring(1).toLowerCase();
  }
}
