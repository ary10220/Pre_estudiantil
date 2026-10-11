// HU-01: el límite mensual solo es válido si es un número mayor a 0
function validarLimite(limite) {
  const numero = Number(limite);
  if (typeof limite === 'boolean' || String(limite ?? '').trim() === '' || !Number.isFinite(numero) || numero <= 0) {
    return 'El límite debe ser un número mayor a 0';
  }
  return null;
}

module.exports = { validarLimite };
