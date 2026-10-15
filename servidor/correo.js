// Formato del correo al registrarse (H5.2, #20): mismo mensaje que lib/modelos/correo.dart
const MENSAJE_CORREO = 'Escribe un correo válido, como nombre@correo.com';

function validarCorreo(valor) {
  const texto = String(valor ?? '').trim();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(texto)) {
    return { ok: false, error: MENSAJE_CORREO };
  }
  return { ok: true };
}

module.exports = { validarCorreo };
