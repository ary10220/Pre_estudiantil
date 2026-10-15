const { test } = require('node:test');
const assert = require('node:assert/strict');
const {
  validarMontoLimite,
  validarLimiteContraGastado,
  puedeRegistrarGasto,
  calcularResumen
} = require('../limite');

const MENSAJE_NUMERO = 'El límite debe ser un número mayor a 0';

// ---------- Permitidos ----------
test('permitido: un límite de "500" es válido', () => {
  assert.deepEqual(validarMontoLimite('500'), { ok: true });
});

test('permitido: un gasto que queda debajo del límite', () => {
  assert.deepEqual(puedeRegistrarGasto({ limite: 500, gastado: 100, montoNuevo: 50 }), { ok: true });
});

test('permitido: un gasto que llega JUSTO al límite', () => {
  assert.deepEqual(puedeRegistrarGasto({ limite: 500, gastado: 450.25, montoNuevo: 49.75 }), { ok: true });
});

test('permitido: sin límite definido, cualquier gasto pasa', () => {
  assert.deepEqual(puedeRegistrarGasto({ limite: null, gastado: 9000, montoNuevo: 500 }), { ok: true });
});

// ---------- Rechazados ----------
test('rechazado: límite vacío', () => {
  assert.deepEqual(validarMontoLimite(''), { ok: false, error: 'Escribe el límite' });
});

test('rechazado: límite "0"', () => {
  assert.deepEqual(validarMontoLimite('0'), { ok: false, error: MENSAJE_NUMERO });
});

test('rechazado: límite "-10"', () => {
  assert.deepEqual(validarMontoLimite('-10'), { ok: false, error: MENSAJE_NUMERO });
});

test('rechazado: límite "abc"', () => {
  assert.deepEqual(validarMontoLimite('abc'), { ok: false, error: MENSAJE_NUMERO });
});

test('rechazado: límite "10.555" (más de 2 decimales)', () => {
  assert.deepEqual(validarMontoLimite('10.555'), { ok: false, error: 'Usa como máximo 2 decimales' });
});

test('rechazado: límite menor a lo ya gastado', () => {
  assert.deepEqual(validarLimiteContraGastado(100, 150.5), {
    ok: false,
    error: 'Ya gastaste Bs 150,50 este mes. El límite no puede ser menor.'
  });
});

test('rechazado: un gasto que supera el límite', () => {
  assert.deepEqual(puedeRegistrarGasto({ limite: 500, gastado: 450, montoNuevo: 60.5 }), {
    ok: false,
    error: 'Con este gasto llegarías a Bs 510,50 y tu límite es Bs 500,00. Te quedan Bs 50,00.'
  });
});

// ---------- Resumen ----------
test('resumen: con límite calcula lo que queda; sin límite, restante null', () => {
  assert.deepEqual(calcularResumen({ limite: 500, gastado: 120.3 }), { limite: 500, gastado: 120.3, restante: 379.7 });
  assert.deepEqual(calcularResumen({ limite: null, gastado: 80 }), { limite: null, gastado: 80, restante: null });
});
