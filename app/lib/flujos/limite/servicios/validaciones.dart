// Misma regla y mensaje que backend/src/flujos/limite/validaciones.js
const String mensajeLimiteNoValido = 'El límite debe ser un número mayor a 0';

String? validarLimite(String valor) {
  final numero = double.tryParse(valor.trim().replaceAll(',', '.'));
  if (numero == null || numero <= 0) return mensajeLimiteNoValido;
  return null;
}

double leerLimite(String valor) {
  return double.parse(valor.trim().replaceAll(',', '.'));
}
