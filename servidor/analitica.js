const EVENTOS = {
  movimiento_iniciado: {
    pantalla: 'nuevo_movimiento',
  },
  movimiento_guardado: {
    pantalla: 'nuevo_movimiento',
    tipo: ['gasto', 'ingreso'],
  },
};

function fechaBolivia(fecha = new Date()) {
  const partes = new Intl.DateTimeFormat('es-BO', {
    timeZone: 'America/La_Paz',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hourCycle: 'h23',
  }).formatToParts(fecha);

  const valor = (tipo) => partes.find((parte) => parte.type === tipo)?.value ?? '';
  return `${valor('day')}/${valor('month')}/${valor('year')} ${valor('hour')}:${valor('minute')}:${valor('second')}`;
}

function validarEvento(evento, propiedades) {
  const definicion = EVENTOS[evento];
  if (!definicion) {
    return { ok: false, error: 'Evento inválido' };
  }
  if (
    propiedades === null ||
    typeof propiedades !== 'object' ||
    Array.isArray(propiedades)
  ) {
    return { ok: false, error: 'Propiedades inválidas' };
  }

  const esperadas = Object.keys(definicion).sort();
  const recibidas = Object.keys(propiedades).sort();
  const mismas =
    esperadas.length === recibidas.length &&
    esperadas.every((clave, indice) => clave === recibidas[indice]);
  if (!mismas) {
    return { ok: false, error: 'Propiedades inválidas' };
  }

  for (const [clave, regla] of Object.entries(definicion)) {
    const valor = propiedades[clave];
    if (Array.isArray(regla)) {
      if (!regla.includes(valor)) {
        return { ok: false, error: `Valor inválido para ${clave}` };
      }
    } else if (valor !== regla) {
      return { ok: false, error: `Valor inválido para ${clave}` };
    }
  }

  return { ok: true, propiedades };
}

module.exports = {
  EVENTOS,
  fechaBolivia,
  validarEvento,
};
