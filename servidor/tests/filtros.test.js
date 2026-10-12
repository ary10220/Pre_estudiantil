const { test } = require('node:test');
const assert = require('node:assert/strict');
const {
  leerFiltros,
  filtrarMovimientos,
  calcularTotales,
  rangoDelPeriodo
} = require('../filtros');

const HOY = '2026-10-11';

const movimientos = [
  { id: 1, concepto: 'Almuerzo', monto: 25, fecha: '2026-10-09', tipo: 'gasto', categoria: 'comida', estado: 'pagado' },
  { id: 2, concepto: 'Pasaje micro', monto: 3.5, fecha: '2026-10-02', tipo: 'gasto', categoria: 'transporte', estado: 'pagado' },
  { id: 3, concepto: 'Fotocopias', monto: 12, fecha: '2026-09-20', tipo: 'gasto', categoria: 'estudio', estado: 'pendiente' },
  { id: 4, concepto: 'Beca mensual', monto: 500, fecha: '2026-10-01', tipo: 'ingreso', categoria: 'otros', estado: 'pagado' },
  { id: 5, concepto: 'Café con leche', monto: 8.1, fecha: '2026-10-10', tipo: 'gasto', categoria: 'comida', estado: 'pendiente' },
];

const SIN_FILTROS = { buscar: '', tipo: '', categoria: '', estado: '', periodo: '', desde: '', hasta: '' };
const filtrar = (cambios) => filtrarMovimientos(movimientos, { ...SIN_FILTROS, ...cambios }, HOY);
const ids = (lista) => lista.map((m) => m.id);

// ---------- Con resultados ----------
test('sin filtros devuelve todos los movimientos', () => {
  assert.deepEqual(ids(filtrar({})), [1, 2, 3, 4, 5]);
});

test('busca por concepto', () => {
  assert.deepEqual(ids(filtrar({ buscar: 'almuerzo' })), [1]);
});

test('la búsqueda ignora mayúsculas y tildes', () => {
  assert.deepEqual(ids(filtrar({ buscar: 'CAFE' })), [5]);
});

test('filtra por tipo', () => {
  assert.deepEqual(ids(filtrar({ tipo: 'ingreso' })), [4]);
});

test('filtra por categoría', () => {
  assert.deepEqual(ids(filtrar({ categoria: 'comida' })), [1, 5]);
});

test('filtra por estado', () => {
  assert.deepEqual(ids(filtrar({ estado: 'pendiente' })), [3, 5]);
});

test('filtra por periodo: este mes y mes anterior', () => {
  assert.deepEqual(ids(filtrar({ periodo: 'este_mes' })), [1, 2, 4, 5]);
  assert.deepEqual(ids(filtrar({ periodo: 'mes_anterior' })), [3]);
});

test('filtra por rango de fechas e incluye los extremos', () => {
  const lista = filtrar({ periodo: 'rango', desde: '2026-10-02', hasta: '2026-10-09' });
  assert.deepEqual(ids(lista), [1, 2]);
});

test('combina búsqueda y filtros', () => {
  assert.deepEqual(ids(filtrar({ tipo: 'gasto', categoria: 'comida', periodo: 'este_mes' })), [1, 5]);
  assert.deepEqual(ids(filtrar({ buscar: 'almuerzo', categoria: 'comida' })), [1]);
});

// ---------- Sin resultados ----------
test('sin coincidencias devuelve lista vacía y total en cero', () => {
  const lista = filtrar({ tipo: 'ingreso', categoria: 'comida' });
  assert.deepEqual(lista, []);
  assert.deepEqual(calcularTotales(lista), { cantidad: 0, ingresos: 0, gastos: 0 });
});

// ---------- Total ----------
test('el total coincide con la lista y con el "gastado del mes" (#6)', () => {
  const lista = filtrar({ tipo: 'gasto', periodo: 'este_mes' });
  assert.deepEqual(ids(lista), [1, 2, 5]);
  assert.deepEqual(calcularTotales(lista), { cantidad: 3, ingresos: 0, gastos: 36.6 });
  assert.deepEqual(calcularTotales(movimientos), { cantidad: 5, ingresos: 500, gastos: 48.6 });
});

// ---------- Periodos y lectura de filtros ----------
test('el mes anterior de enero es diciembre del año anterior', () => {
  assert.deepEqual(rangoDelPeriodo('mes_anterior', '2026-01-15'), {
    desde: '2025-12-01',
    hasta: '2025-12-31'
  });
  assert.deepEqual(rangoDelPeriodo('este_mes', HOY), { desde: '2026-10-01', hasta: '2026-10-31' });
});

test('leerFiltros acepta una consulta vacía y un rango válido', () => {
  assert.deepEqual(leerFiltros({}), { ok: true, filtros: SIN_FILTROS });
  const rango = leerFiltros({ periodo: 'rango', desde: '2026-10-01', hasta: '2026-10-31' });
  assert.equal(rango.ok, true);
  assert.equal(rango.filtros.desde, '2026-10-01');
});

test('leerFiltros rechaza valores inválidos', () => {
  assert.deepEqual(leerFiltros({ tipo: 'otro' }), { ok: false, error: 'Tipo inválido' });
  assert.deepEqual(leerFiltros({ periodo: 'rango' }), { ok: false, error: 'Elige las dos fechas del rango' });
  assert.deepEqual(
    leerFiltros({ periodo: 'rango', desde: '2026-10-09', hasta: '2026-10-01' }),
    { ok: false, error: 'La fecha "desde" no puede ser posterior a "hasta"' }
  );
});