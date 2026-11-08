const MAX_MONTO = 1e10;

function redondear(valor) {
  return Math.round(Number(valor) * 100) / 100;
}

function validarMontoMeta(valor, etiqueta = 'monto') {
  const monto = Number(valor);
  if (!(monto > 0 && monto < MAX_MONTO)) {
    return { ok: false, error: `El ${etiqueta} debe ser mayor a 0` };
  }
  if (Math.abs(monto - redondear(monto)) > 1e-6) {
    return { ok: false, error: `El ${etiqueta} admite máximo 2 decimales` };
  }
  return { ok: true, monto: redondear(monto) };
}

function validarNombreMeta(nombre) {
  const texto = String(nombre || '').trim();
  if (!texto) return { ok: false, error: 'Escribe el nombre de la meta' };
  if (texto.length > 100) {
    return { ok: false, error: 'El nombre de la meta es demasiado largo' };
  }
  return { ok: true, nombre: texto };
}

function validarFechaMeta(texto) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(String(texto || ''))) {
    return { ok: false, error: 'Fecha inválida' };
  }
  const fecha = new Date(`${texto}T00:00:00.000Z`);
  if (Number.isNaN(fecha.getTime())) {
    return { ok: false, error: 'Fecha inválida' };
  }
  return { ok: true, fecha };
}

function calcularSaldos({ ingresos, gastos, reservado }) {
  const total = redondear(Number(ingresos) - Number(gastos));
  const reservadoRedondeado = redondear(reservado);
  return {
    total,
    reservado: reservadoRedondeado,
    disponible: redondear(total - reservadoRedondeado),
  };
}

function validarAsignacion({ disponible, monto }) {
  if (Number(monto) > Number(disponible) + 0.001) {
    return { ok: false, error: 'No hay fondos disponibles suficientes' };
  }
  return { ok: true };
}

function validarRetiro({ reservado, monto }) {
  if (Number(monto) > Number(reservado) + 0.001) {
    return {
      ok: false,
      error: 'No hay fondos reservados suficientes en la meta',
    };
  }
  return { ok: true };
}

function validarTransferencia({ reservado, monto }) {
  if (Number(monto) > Number(reservado) + 0.001) {
    return {
      ok: false,
      error: 'No hay fondos reservados suficientes en la meta de origen',
    };
  }
  return { ok: true };
}

module.exports = {
  MAX_MONTO,
  redondear,
  validarMontoMeta,
  validarNombreMeta,
  validarFechaMeta,
  calcularSaldos,
  validarAsignacion,
  validarRetiro,
  validarTransferencia,
};
