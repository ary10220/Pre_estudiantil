// Formato del correo al registrarse (H5.2, #20): mismo mensaje que servidor/correo.js
const String mensajeCorreoInvalido = 'Escribe un correo válido, como nombre@correo.com';

String? validarCorreo(String valor) {
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(valor.trim())) {
    return mensajeCorreoInvalido;
  }
  return null;
}
