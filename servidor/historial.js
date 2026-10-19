// Historial de actividad (Tarea 4): función pura que arma los grupos del día.
// Sin base de datos: se puede probar sola.
const FILTROS = ['todos', 'gastos', 'pagos', 'limite'];

const TIPOS_EVENTO = ['gasto_registrado', 'ingreso_registrado', 'movimiento_pagado', 'limite_definido'];

const MESES = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

// Clave YYYY-MM-DD en hora local (igual criterio que la app)
function claveDelDia(fecha) {
  const anio = fecha.getFullYear();
  const mes = String(fecha.getMonth() + 1).padStart(2, '0');
  const dia = String(fecha.getDate()).padStart(2, '0');
  return `${anio}-${mes}-${dia}`;
}

function diferenciaEnDias(desde, hasta) {
  const unDia = 24 * 60 * 60 * 1000;
  const a = new Date(desde.getFullYear(), desde.getMonth(), desde.getDate());
  const b = new Date(hasta.getFullYear(), hasta.getMonth(), hasta.getDate());
  return Math.round((b - a) / unDia);
}

// Título legible del grupo: Hoy, Ayer o "12 de octubre"
function tituloDelDia(fecha, hoy) {
  const diferencia = diferenciaEnDias(fecha, hoy);
  if (diferencia === 0) return 'Hoy';
  if (diferencia === 1) return 'Ayer';
  return `${fecha.getDate()} de ${MESES[fecha.getMonth()]}`;
}

// Hora HH:mm, para mostrarla junto a cada evento
function horaTexto(fecha) {
  const h = String(fecha.getHours()).padStart(2, '0');
  const m = String(fecha.getMinutes()).padStart(2, '0');
  return `${h}:${m}`;
}

// Chip 'gastos' = solo gasto_registrado. Los ingresos aparecen solo en 'todos'.
// Decidido con la usuaria para no pasar de 4 chips (Hick).
function pasaFiltro(tipo, filtro) {
  if (filtro === 'todos') return true;
  if (filtro === 'gastos') return tipo === 'gasto_registrado';
  if (filtro === 'pagos') return tipo === 'movimiento_pagado';
  if (filtro === 'limite') return tipo === 'limite_definido';
  return false;
}

// eventos: filas tal como salen del SELECT (creado_en es Date).
// filtro: 'todos' | 'gastos' | 'pagos' | 'limite'.
// hoy: Date de referencia, para calcular "Hoy"/"Ayer". Se recibe para hacerlo testable.
function armarHistorial(eventos, filtro = 'todos', hoy = new Date()) {
  if (!FILTROS.includes(filtro)) filtro = 'todos';

  const filtrados = eventos
    .filter((e) => pasaFiltro(e.tipo, filtro))
    .slice()
    .sort((a, b) => b.creado_en - a.creado_en);

  const grupos = [];
  const indicePorClave = new Map();

  for (const evento of filtrados) {
    const clave = claveDelDia(evento.creado_en);
    let indice = indicePorClave.get(clave);
    if (indice === undefined) {
      indice = grupos.length;
      indicePorClave.set(clave, indice);
      grupos.push({ titulo: tituloDelDia(evento.creado_en, hoy), eventos: [] });
    }
    grupos[indice].eventos.push({
      id: evento.id,
      tipo: evento.tipo,
      monto: evento.monto == null ? null : Number(evento.monto),
      descripcion: evento.descripcion ?? '',
      movimientoId: evento.movimiento_id ?? null,
      hora: horaTexto(evento.creado_en),
      creadoEn: evento.creado_en.toISOString(),
    });
  }

  return grupos;
}

module.exports = {
  FILTROS,
  TIPOS_EVENTO,
  armarHistorial,
};
