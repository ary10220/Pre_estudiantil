const { test } = require('node:test');
const assert = require('node:assert/strict');
const { validarLimite } = require('../../src/flujos/limite/validaciones');

test('HU-01 permitido: un límite de 500 es válido', () => {
  assert.equal(validarLimite(500), null);
  assert.equal(validarLimite('500.50'), null);
});

test('HU-01 rechazado: vacío, 0, negativo o con letras', () => {
  for (const limite of ['', 0, -10, 'abc', null]) {
    assert.equal(validarLimite(limite), 'El límite debe ser un número mayor a 0');
  }
});
