const { test } = require('node:test');
const assert = require('node:assert/strict');
const { FRECUENCIAS, sumarFrecuencia } = require('../recurrentes');

const fecha = (texto) => new Date(`${texto}T00:00:00.000Z`);
const iso = (valor) => valor.toISOString().slice(0, 10);

test('frecuencias válidas: semanal y mensual', () => {
  assert.deepEqual(FRECUENCIAS, ['semanal', 'mensual']);
});

test('semanal suma 7 días', () => {
  assert.equal(iso(sumarFrecuencia(fecha('2026-10-01'), 'semanal')), '2026-10-08');
});

test('semanal cruza el cambio de mes', () => {
  assert.equal(iso(sumarFrecuencia(fecha('2026-10-29'), 'semanal')), '2026-11-05');
});

test('mensual conserva el día del mes', () => {
  assert.equal(iso(sumarFrecuencia(fecha('2026-10-15'), 'mensual')), '2026-11-15');
});

test('mensual usa el último día si el mes siguiente es más corto', () => {
  assert.equal(iso(sumarFrecuencia(fecha('2026-01-31'), 'mensual')), '2026-02-28');
});

test('mensual respeta el 29 de febrero en año bisiesto', () => {
  assert.equal(iso(sumarFrecuencia(fecha('2028-01-31'), 'mensual')), '2028-02-29');
});

test('mensual cruza el cambio de año', () => {
  assert.equal(iso(sumarFrecuencia(fecha('2026-12-31'), 'mensual')), '2027-01-31');
});

test('sumarFrecuencia no modifica la fecha original', () => {
  const original = fecha('2026-10-01');
  sumarFrecuencia(original, 'semanal');
  assert.equal(iso(original), '2026-10-01');
});
