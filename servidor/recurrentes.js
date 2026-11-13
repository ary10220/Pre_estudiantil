const FRECUENCIAS = ['semanal', 'mensual'];

function sumarFrecuencia(fecha, frecuencia) {
  const siguiente = new Date(fecha);
  if (frecuencia === 'semanal') {
    siguiente.setUTCDate(siguiente.getUTCDate() + 7);
    return siguiente;
  }

  const dia = siguiente.getUTCDate();
  siguiente.setUTCDate(1);
  siguiente.setUTCMonth(siguiente.getUTCMonth() + 1);
  const ultimoDia = new Date(
    Date.UTC(siguiente.getUTCFullYear(), siguiente.getUTCMonth() + 1, 0)
  ).getUTCDate();
  siguiente.setUTCDate(Math.min(dia, ultimoDia));
  return siguiente;
}

module.exports = {
  FRECUENCIAS,
  sumarFrecuencia,
};
