// Regla del límite mensual (#8): 
function aCentavos(monto) {
  return Math.round(Number(monto) * 100);
}

function formatearBs(centavos) {
  return 'Bs ' + (centavos / 100).toFixed(2).replace('.', ',');
}

function validarMontoLimite(valor) {
  const texto = String(valor ?? '').trim();
  if (texto === '') {
    return { ok: false, error: 'Escribe el límite' };
  }
  if (!/^\d+(\.\d+)?$/.test(texto) || Number(texto) <= 0) {
    return { ok: false, error: 'El límite debe ser un número mayor a 0' };
  }
  if (!/^\d+(\.\d{1,2})?$/.test(texto)) {
    return { ok: false, error: 'Usa como máximo 2 decimales' };
  }
  return { ok: true };
}

function validarLimiteContraGastado(limite, gastado) {
  if (aCentavos(limite) < aCentavos(gastado)) {
    return {
      ok: false,
      error: `Ya gastaste ${formatearBs(aCentavos(gastado))} este mes. El límite no puede ser menor.`
    };
  }
  return { ok: true };
}

function puedeRegistrarGasto({ limite, gastado, montoNuevo }) {
  if (limite == null) {
    return { ok: true };
  }
  const total = aCentavos(gastado) + aCentavos(montoNuevo);
  if (total > aCentavos(limite)) {
    const quedan = aCentavos(limite) - aCentavos(gastado);
    return {
      ok: false,
      error: `Con este gasto llegarías a ${formatearBs(total)} y tu límite es ${formatearBs(aCentavos(limite))}. Te quedan ${formatearBs(quedan)}.`
    };
  }
  return { ok: true };
}

function calcularResumen({ limite, gastado }) {
  if (limite == null) {
    return { limite: null, gastado, restante: null };
  }
  return { limite, gastado, restante: (aCentavos(limite) - aCentavos(gastado)) / 100 };
}

module.exports = {
  validarMontoLimite,
  validarLimiteContraGastado,
  puedeRegistrarGasto,
  calcularResumen
};
