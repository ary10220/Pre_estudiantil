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

class ResumenLimite {
  final double? limite;
  final double gastado;
  final double? restante;

  const ResumenLimite({required this.limite, required this.gastado, required this.restante});

  factory ResumenLimite.desdeJson(Map<String, dynamic> json) {
    return ResumenLimite(
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
