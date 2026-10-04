const { test } = require('node:test');
const assert = require('node:assert/strict');
const { ESTADOS, puedeMarcarPagado, marcarComoPagado } = require('../../src/flujos/movimientos/estado');
const { validarIdMovimiento } = require('../../src/flujos/movimientos/validaciones');

function movimientoDePrueba(estado) {
  return { id: 1, tipo: 'gasto', concepto: 'Transporte', monto: 25, fecha: '2026-10-04', estado, pagado_en: null };
}

const ahora = new Date('2026-10-04T10:30:00');

test('1. un movimiento pendiente pasa a pagado', () => {
  const pagado = marcarComoPagado(movimientoDePrueba(ESTADOS.PENDIENTE), ahora);
  assert.equal(pagado.estado, 'pagado');
});

test('2. pagado_en queda con la fecha que se le pasa', () => {
  const pagado = marcarComoPagado(movimientoDePrueba(ESTADOS.PENDIENTE), ahora);
  assert.equal(pagado.pagado_en, ahora);
});

test('3. el objeto original no se modifica', () => {
  const original = movimientoDePrueba(ESTADOS.PENDIENTE);
  const pagado = marcarComoPagado(original, ahora);
  assert.equal(original.estado, 'pendiente');
  assert.equal(original.pagado_en, null);
  assert.notEqual(pagado, original);
});

test('4. si ya está pagado, lanza "Este movimiento ya está pagado" (409)', () => {
  assert.throws(
    () => marcarComoPagado(movimientoDePrueba(ESTADOS.PAGADO), ahora),
    { message: 'Este movimiento ya está pagado', codigo: 409 }
  );
});

test('5. si el estado es raro, lanza "Estado no válido" (400)', () => {
  assert.throws(
    () => marcarComoPagado(movimientoDePrueba('cancelado'), ahora),
    { message: 'Estado no válido', codigo: 400 }
  );
});

test('6. puedeMarcarPagado da true para pendiente y false para pagado', () => {
  assert.equal(puedeMarcarPagado(movimientoDePrueba(ESTADOS.PENDIENTE)), true);
  assert.equal(puedeMarcarPagado(movimientoDePrueba(ESTADOS.PAGADO)), false);
});

test('7. validarIdMovimiento rechaza "abc", 0 y -3 y acepta 5', () => {
  assert.equal(validarIdMovimiento('abc'), 'Movimiento no válido');
  assert.equal(validarIdMovimiento('0'), 'Movimiento no válido');
  assert.equal(validarIdMovimiento('-3'), 'Movimiento no válido');
  assert.equal(validarIdMovimiento('5'), null);
});
