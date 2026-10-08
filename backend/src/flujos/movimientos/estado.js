// Regla del cambio de estado, sin base de datos: así se puede probar sola
const ESTADOS = { PENDIENTE: 'pendiente', PAGADO: 'pagado' };

function errorConCodigo(mensaje, codigo) {
  const error = new Error(mensaje);
  error.codigo = codigo;
  return error;
}

function puedeMarcarPagado(movimiento) {
  return movimiento.estado === ESTADOS.PENDIENTE;
}

// Devuelve un movimiento nuevo; el que llega no se modifica
function marcarComoPagado(movimiento, ahora) {
  if (movimiento.estado === ESTADOS.PAGADO) {
    throw errorConCodigo('Este movimiento ya está pagado', 409);
  }
  if (!puedeMarcarPagado(movimiento)) {
    throw errorConCodigo('Estado no válido', 400);
  }
  return { ...movimiento, estado: ESTADOS.PAGADO, pagado_en: ahora };
}

// Tarea 3: restricción para Presupuesto Estudiantil
// "Un movimiento pagado no permite modificar su monto."
function editarMontoPermitido(movimiento) {
  return movimiento.estado !== ESTADOS.PAGADO;
}

module.exports = { ESTADOS, puedeMarcarPagado, marcarComoPagado, editarMontoPermitido };
