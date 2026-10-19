const { test } = require('node:test');
const assert = require('node:assert/strict');
const { armarHistorial } = require('../historial');

// "Hoy" fijo para que "Hoy"/"Ayer" sean deterministas en los tests
const HOY = new Date(2026, 9, 15, 10, 0); // 15 de octubre de 2026, 10:00

// Fechas de prueba, en hora local (no UTC)
const AYER_1430 = new Date(2026, 9, 14, 14, 30);
const AYER_0900 = new Date(2026, 9, 14, 9, 0);
const HOY_1200 = new Date(2026, 9, 15, 12, 0);
const HACE_UNA_SEMANA = new Date(2026, 9, 8, 18, 15); // 8 de octubre

const eventos = [
  { id: 1, tipo: 'gasto_registrado', movimiento_id: 10, monto: 25,
    descripcion: 'Almuerzo', creado_en: AYER_1430 },
  { id: 2, tipo: 'ingreso_registrado', movimiento_id: 11, monto: 500,
    descripcion: 'Beca', creado_en: HOY_1200 },
  { id: 3, tipo: 'movimiento_pagado', movimiento_id: 10, monto: 25,
    descripcion: 'Almuerzo', creado_en: AYER_0900 },
  { id: 4, tipo: 'limite_definido', movimiento_id: null, monto: 600,
    descripcion: 'Límite del mes 2026-10', creado_en: HACE_UNA_SEMANA },
];

// ---------- Orden ----------
test('orden: la lista desordenada sale reciente a antigua', () => {
  const grupos = armarHistorial(eventos, 'todos', HOY);
  const ids = grupos.flatMap((g) => g.eventos.map((e) => e.id));
  assert.deepEqual(ids, [2, 1, 3, 4]);
});

// ---------- Agrupación por día ----------
test('agrupación: 3 días distintos devuelven 3 grupos con Hoy, Ayer y día explícito', () => {
  const grupos = armarHistorial(eventos, 'todos', HOY);
  assert.equal(grupos.length, 3);
  assert.equal(grupos[0].titulo, 'Hoy');
  assert.equal(grupos[1].titulo, 'Ayer');
  assert.equal(grupos[2].titulo, '8 de octubre');
});

test('agrupación: dos eventos del mismo día quedan en el mismo grupo, ordenados por hora', () => {
  const grupos = armarHistorial(eventos, 'todos', HOY);
  const ayer = grupos.find((g) => g.titulo === 'Ayer');
  assert.equal(ayer.eventos.length, 2);
  assert.deepEqual(ayer.eventos.map((e) => e.id), [1, 3]); // 14:30 antes que 09:00
});

// ---------- Filtro por tipo ----------
test('filtro gastos: solo gasto_registrado (los ingresos aparecen solo en todos)', () => {
  const grupos = armarHistorial(eventos, 'gastos', HOY);
  const tipos = grupos.flatMap((g) => g.eventos.map((e) => e.tipo));
  assert.deepEqual(tipos, ['gasto_registrado']);
});

test('filtro pagos: solo movimiento_pagado', () => {
  const grupos = armarHistorial(eventos, 'pagos', HOY);
  const tipos = grupos.flatMap((g) => g.eventos.map((e) => e.tipo));
  assert.deepEqual(tipos, ['movimiento_pagado']);
});

test('filtro limite: solo limite_definido', () => {
  const grupos = armarHistorial(eventos, 'limite', HOY);
  const tipos = grupos.flatMap((g) => g.eventos.map((e) => e.tipo));
  assert.deepEqual(tipos, ['limite_definido']);
});

// ---------- Lista vacía ----------
test('lista vacía devuelve [] (no inventa grupos)', () => {
  assert.deepEqual(armarHistorial([], 'todos', HOY), []);
});

test('filtro sin coincidencias devuelve [] (no un grupo vacío)', () => {
  const soloIngreso = [
    { id: 1, tipo: 'ingreso_registrado', movimiento_id: 1, monto: 100,
      descripcion: 'x', creado_en: HOY_1200 },
  ];
  assert.deepEqual(armarHistorial(soloIngreso, 'gastos', HOY), []);
});

// ---------- Hora en cada evento ----------
test('cada evento trae su hora HH:mm', () => {
  const grupos = armarHistorial(eventos, 'todos', HOY);
  const hoy = grupos.find((g) => g.titulo === 'Hoy');
  assert.equal(hoy.eventos[0].hora, '12:00');
});
