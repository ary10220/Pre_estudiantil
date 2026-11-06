const { test } = require('node:test');
const assert = require('node:assert/strict');
const {
  calcularSaldos,
  validarMontoMeta,
  validarNombreMeta,
  validarFechaMeta,
  validarAsignacion,
  validarRetiro,
  validarTransferencia,
} = require('../metas');

test('saldos: total, reservado y disponible', () => {
  assert.deepEqual(calcularSaldos({ ingresos: 1000, gastos: 400, reservado: 0 }), {
    total: 600,
    reservado: 0,
    disponible: 600,
  });
});

test('saldos: el disponible baja al reservar', () => {
  assert.deepEqual(calcularSaldos({ ingresos: 1000, gastos: 400, reservado: 300 }), {
    total: 600,
    reservado: 300,
    disponible: 300,
  });
});

test('monto de meta: válido con dos decimales', () => {
  assert.deepEqual(validarMontoMeta('500.25'), { ok: true, monto: 500.25 });
});

test('monto de meta: rechaza cero, negativo y más de dos decimales', () => {
  assert.equal(validarMontoMeta('0').ok, false);
  assert.equal(validarMontoMeta('-10').ok, false);
  assert.equal(validarMontoMeta('10.555').ok, false);
});

test('nombre de meta: válido y rechazo de vacío', () => {
  assert.deepEqual(validarNombreMeta('  Viaje  '), { ok: true, nombre: 'Viaje' });
  assert.equal(validarNombreMeta('   ').ok, false);
});

test('fecha de meta: válida e inválida', () => {
  assert.equal(validarFechaMeta('2027-01-01').ok, true);
  assert.equal(validarFechaMeta('01/01/2027').ok, false);
});

test('asignación: permite hasta el disponible y rechaza de más', () => {
  assert.deepEqual(validarAsignacion({ disponible: 400, monto: 400 }), { ok: true });
  assert.equal(validarAsignacion({ disponible: 400, monto: 500 }).ok, false);
});

test('retiro: permite hasta lo reservado y rechaza de más', () => {
  assert.deepEqual(validarRetiro({ reservado: 150, monto: 150 }), { ok: true });
  assert.equal(validarRetiro({ reservado: 150, monto: 200 }).ok, false);
});

test('transferencia: permite hasta lo reservado y rechaza de más', () => {
  assert.deepEqual(validarTransferencia({ reservado: 150, monto: 50 }), { ok: true });
  assert.equal(validarTransferencia({ reservado: 150, monto: 200 }).ok, false);
});
