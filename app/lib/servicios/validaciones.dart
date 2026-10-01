// Mismas reglas que backend/src/rutas/auth.js

const String mensajeObligatorio = 'Este campo es obligatorio';

final RegExp formatoCorreo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? validarObligatorio(String valor) {
  if (valor.trim().isEmpty) return mensajeObligatorio;
  return null;
}

String? validarCorreo(String valor) {
  if (valor.trim().isEmpty) return mensajeObligatorio;
  if (!formatoCorreo.hasMatch(valor.trim())) return 'Escribí un correo válido';
  return null;
}

String? validarContrasena(String valor) {
  if (valor.trim().isEmpty) return mensajeObligatorio;
  if (valor.length < 6) return 'Mínimo 6 caracteres';
  return null;
}

String? validarRepetida(String original, String repetida) {
  if (repetida.isEmpty) return mensajeObligatorio;
  if (original != repetida) return 'Las dos contraseñas tienen que ser iguales';
  return null;
}

String? validarCodigo(String valor) {
  if (valor.trim().isEmpty) return mensajeObligatorio;
  if (!RegExp(r'^\d{6}$').hasMatch(valor.trim())) return 'El código tiene 6 dígitos';
  return null;
}
