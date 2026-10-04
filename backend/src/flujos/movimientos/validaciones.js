// Mismas reglas que app/lib/flujos/movimientos/servicios/validaciones.dart

function validarConcepto(concepto) {
  if (typeof concepto !== 'string' || concepto.trim() === '') {
    return 'Escribí el concepto';
  }
  const largo = concepto.trim().length;
  if (largo < 2 || largo > 40) {
    return 'El concepto debe tener entre 2 y 40 letras';
  }
  return null;
}

function validarMonto(monto) {
  if (monto === undefined || monto === null || String(monto).trim() === '') {
    return 'Escribí el monto';
  }
  const texto = String(monto).trim();
  const numero = Number(texto);
  if (typeof monto === 'boolean' || !Number.isFinite(numero) || numero <= 0) {
    return 'El monto debe ser un número mayor a 0';
  }
  if (!/^\d*(\.\d{0,2})?$/.test(texto)) {
    return 'Usá como máximo 2 decimales';
  }
  if (numero > 100000) {
    return 'El monto no puede pasar de Bs 100000';
  }
  return null;
}

// El id llega en la URL como texto: tiene que ser un entero positivo que entre en un INTEGER
function validarIdMovimiento(id) {
  const texto = String(id);
  if (!/^\d+$/.test(texto) || Number(texto) <= 0 || Number(texto) > 2147483647) {
    return 'Movimiento no válido';
  }
  return null;
}

module.exports = { validarConcepto, validarMonto, validarIdMovimiento };
