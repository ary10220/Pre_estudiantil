// Límite mensual (#10): mismas reglas y mensajes que servidor/limite.js
const String mensajeLimiteVacio = 'Escribí el límite';
const String mensajeLimiteNoValido = 'El límite debe ser un número mayor a 0';
const String mensajeLimiteDecimales = 'Usá como máximo 2 decimales';

// La coma se acepta en la app y viaja al servidor como punto
String _normalizar(String valor) => valor.trim().replaceAll(',', '.');

String? validarMontoLimite(String valor) {
  final texto = _normalizar(valor);
  if (texto.isEmpty) return mensajeLimiteVacio;
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(texto) || double.parse(texto) <= 0) {
    return mensajeLimiteNoValido;
  }
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(texto)) return mensajeLimiteDecimales;
  return null;
}

double leerLimite(String valor) => double.parse(_normalizar(valor));

String formatearBs(double monto) => 'Bs ${monto.toStringAsFixed(2).replaceAll('.', ',')}';

const List<String> _nombresMeses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

// 'AAAA-MM' → 'octubre'
String nombreMes(String mes) => _nombresMeses[int.parse(mes.substring(5, 7)) - 1];

// Confirmación junto al botón al guardar el límite (clase 15, hallazgo 1)
String textoConfirmacionLimite(ResumenLimite r) =>
    'Límite guardado: ${formatearBs(r.limite!)} para ${nombreMes(r.mes!)}'
    ' · Te quedan ${formatearBs(r.restante!)}';

// Aviso debajo del monto de un gasto (H5.1, #19)
class AvisoGasto {
  final String texto;
  final bool seExcede;
  const AvisoGasto(this.texto, this.seExcede);
}

// montoAnterior: al editar un gasto del mismo mes, su monto vuelve a estar disponible
AvisoGasto avisoGasto(ResumenLimite r, double? monto, {double montoAnterior = 0}) {
  final disponible = (r.restante! * 100).round() + (montoAnterior * 100).round();
  final queda = 'Te quedan ${formatearBs(disponible / 100)} en ${nombreMes(r.mes!)}.';
  if (monto == null || monto <= 0) return AvisoGasto(queda, false);

  final despues = disponible - (monto * 100).round();
  if (despues < 0) {
    return AvisoGasto('$queda Con este gasto te pasarías por ${formatearBs(-despues / 100)}.', true);
  }
  return AvisoGasto('$queda Con este gasto te quedarían ${formatearBs(despues / 100)}.', false);
}

class ResumenLimite {
  final String? mes;
  final double? limite;
  final double gastado;
  final double? restante;

  const ResumenLimite({
    this.mes,
    required this.limite,
    required this.gastado,
    required this.restante,
  });

  factory ResumenLimite.desdeJson(Map<String, dynamic> json) {
    return ResumenLimite(
      mes: json['mes'] as String?,
      limite: (json['limite'] as num?)?.toDouble(),
      gastado: (json['gastado'] as num).toDouble(),
      restante: (json['restante'] as num?)?.toDouble(),
    );
  }

  bool get tieneLimite => limite != null;

  // De 0 a 1, para la barra de progreso
  double get proporcion => tieneLimite ? (gastado / limite!).clamp(0, 1).toDouble() : 0;

  // Color de aviso al pasar el 80 %
  bool get enAviso => tieneLimite && gastado > limite! * 0.8;
}
