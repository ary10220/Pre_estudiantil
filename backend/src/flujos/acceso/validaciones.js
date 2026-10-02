function estaVacio(valor) {
  return typeof valor !== 'string' || valor.trim() === '';
}

function correoValido(correo) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(correo.trim());
}

module.exports = { estaVacio, correoValido };
