const { test } = require('node:test');
const assert = require('node:assert/strict');
const { validarCorreo } = require('../correo');

const MENSAJE = 'Escribe un correo válido, como nombre@correo.com';

test('permitido: un correo con @ y dominio', () => {
  assert.deepEqual(validarCorreo('prueba@correo.com'), { ok: true });
  assert.deepEqual(validarCorreo('  ana.perez@uagrm.edu.bo '), { ok: true });
});

test('rechazado: sin @, sin dominio o con espacios', () => {
  for (const valor of ['correo-sin-arroba', 'ana@', 'ana@correo', 'ana perez@correo.com', '']) {
    assert.deepEqual(validarCorreo(valor), { ok: false, error: MENSAJE });
  }
});
