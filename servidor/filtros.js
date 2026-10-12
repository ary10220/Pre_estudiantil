// Búsqueda y filtros de movimientos (#7): funciones puras, sin base de datos.
// Las fechas viajan como texto 'AAAA-MM-DD', que se puede comparar directamente.
const TIPOS = ['ingreso', 'gasto'];
const CATEGORIAS = ['comida', 'transporte', 'estudio', 'otros'];
const ESTADOS = ['pendiente', 'pagado'];
const PERIODOS = ['este_mes', 'mes_anterior', 'rango'];

const FORMATO_FECHA = /^\d{4}-\d{2}-\d{2}$/;

function aTexto(anio, mes, dia) {
  return `${anio}-${String(mes).padStart(2, '0')}-${String(dia).padStart(2, '0')}`;
}

function hoyTexto() {
  const hoy = new Date();
  return aTexto(hoy.getFullYear(), hoy.getMonth() + 1, hoy.getDate());
}

// Primer y último día de un mes (mes: 1 a 12)
function mesCompleto(anio, mes) {
  const ultimo = new Date(anio, mes, 0).getDate();
  return { desde: aTexto(anio, mes, 1), hasta: aTexto(anio, mes, ultimo) };
}

// Rango de fechas de "este_mes" o "mes_anterior" según el día de hoy
function rangoDelPeriodo(periodo, hoy) {
  const [anio, mes] = hoy.split('-').map(Number);
  if (periodo === 'este_mes') return mesCompleto(anio, mes);
  if (periodo === 'mes_anterior') {
    return mes === 1 ? mesCompleto(anio - 1, 12) : mesCompleto(anio, mes - 1);
  }
  return null;
}

// Para buscar sin importar mayúsculas ni tildes
function normalizar(texto) {
  return texto.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
}

// Convierte los parámetros de la URL en filtros. Un valor vacío = sin filtro.
function leerFiltros(query = {}) {
  const filtros = {
    buscar: String(query.buscar ?? '').trim(),
    tipo: String(query.tipo ?? ''),
    categoria: String(query.categoria ?? ''),
    estado: String(query.estado ?? ''),
    periodo: String(query.periodo ?? ''),
    desde: '',
    hasta: '',
  };

  if (filtros.buscar.length > 100) {
    return { ok: false, error: 'La búsqueda es demasiado larga' };
  }
  if (filtros.tipo && !TIPOS.includes(filtros.tipo)) {
    return { ok: false, error: 'Tipo inválido' };
  }
  if (filtros.categoria && !CATEGORIAS.includes(filtros.categoria)) {
    return { ok: false, error: 'Categoría inválida' };
  }
  if (filtros.estado && !ESTADOS.includes(filtros.estado)) {
    return { ok: false, error: 'Estado inválido' };
  }
  if (filtros.periodo && !PERIODOS.includes(filtros.periodo)) {
    return { ok: false, error: 'Periodo inválido' };
  }

  if (filtros.periodo === 'rango') {
    filtros.desde = String(query.desde ?? '');
    filtros.hasta = String(query.hasta ?? '');
    if (!FORMATO_FECHA.test(filtros.desde) || !FORMATO_FECHA.test(filtros.hasta)) {
      return { ok: false, error: 'Elige las dos fechas del rango' };
    }
    if (filtros.desde > filtros.hasta) {
      return { ok: false, error: 'La fecha "desde" no puede ser posterior a "hasta"' };
    }
  }

  return { ok: true, filtros };
}

// Deja solo los movimientos que cumplen TODOS los filtros activos
function filtrarMovimientos(lista, filtros, hoy = hoyTexto()) {
  const buscar = normalizar(filtros.buscar || '');

  let rango = null;
  if (filtros.periodo === 'rango') {
    rango = { desde: filtros.desde, hasta: filtros.hasta };
  } else if (filtros.periodo) {
    rango = rangoDelPeriodo(filtros.periodo, hoy);
  }

  return lista.filter((m) => {
    if (buscar && !normalizar(m.concepto).includes(buscar)) return false;
    if (filtros.tipo && m.tipo !== filtros.tipo) return false;
    if (filtros.categoria && m.categoria !== filtros.categoria) return false;
    if (filtros.estado && m.estado !== filtros.estado) return false;
    if (rango && (m.fecha < rango.desde || m.fecha > rango.hasta)) return false;
    return true;
  });
}

// Totales de la lista que recibe, en centavos para evitar errores de decimales
function calcularTotales(lista) {
  let ingresos = 0;
  let gastos = 0;
  for (const m of lista) {
    const centavos = Math.round(m.monto * 100);
    if (m.tipo === 'ingreso') ingresos += centavos;
    else gastos += centavos;
  }
  return { cantidad: lista.length, ingresos: ingresos / 100, gastos: gastos / 100 };
}

module.exports = {
  TIPOS,
  CATEGORIAS,
  ESTADOS,
  hoyTexto,
  rangoDelPeriodo,
  leerFiltros,
  filtrarMovimientos,
  calcularTotales,
};