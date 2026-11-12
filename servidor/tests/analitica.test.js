const { after, before, test } = require('node:test');
const assert = require('node:assert/strict');
const app = require('../servidor');
const prisma = require('../conexion');
const { fechaBolivia } = require('../analitica');

const correo = `analitica-test-${Date.now()}@correo.com`;
const contrasena = '123456';

let servidor;
let base;
let token;
let usuarioId;

async function pedir(metodo, ruta, { token, body } = {}) {
  const respuesta = await fetch(`${base}${ruta}`, {
    method: metodo,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    ...(body ? { body: JSON.stringify(body) } : {}),
  });
  const datos = await respuesta.json();
  return { status: respuesta.status, datos };
}

before(async () => {
  servidor = await new Promise((resolve) => {
    const instancia = app.listen(0, () => resolve(instancia));
  });
  base = `http://127.0.0.1:${servidor.address().port}`;

  const registro = await pedir('POST', '/registro', {
    body: { nombre: 'Analitica Test', correo, contrasena },
  });
  assert.equal(registro.status, 201);

  const login = await pedir('POST', '/login', {
    body: { correo, contrasena },
  });
  assert.equal(login.status, 200);
  token = login.datos.token;

  const usuario = await prisma.usuario.findUnique({
    where: { correo },
    select: { id: true },
  });
  usuarioId = usuario.id;
});

after(async () => {
  try {
    await prisma.usuario.deleteMany({ where: { correo } });
  } catch {
    // Si la base no estaba disponible, no hay nada que limpiar.
  }

  if (servidor) {
    await new Promise((resolve) => servidor.close(resolve));
  }
  await prisma.$disconnect();
});

test('registra presupuesto_movimiento_iniciado', async () => {
  const respuesta = await pedir('POST', '/analitica/eventos', {
    token,
    body: {
      evento: 'movimiento_iniciado',
      propiedades: { pantalla: 'nuevo_movimiento' },
    },
  });
  assert.equal(respuesta.status, 201);

  const eventos = await prisma.evento.findMany({
    where: { usuarioId, tipo: 'movimiento_iniciado' },
  });
  assert.equal(eventos.length, 1);
  assert.deepEqual(eventos[0].propiedades, { pantalla: 'nuevo_movimiento' });
  assert.deepEqual(Object.keys(eventos[0].propiedades).sort(), ['pantalla']);
  assert.equal('email' in eventos[0].propiedades, false);
  assert.equal('descripcion' in eventos[0].propiedades, false);
  assert.equal('monto' in eventos[0].propiedades, false);
});

test('registra presupuesto_movimiento_guardado', async () => {
  const respuesta = await pedir('POST', '/analitica/eventos', {
    token,
    body: {
      evento: 'movimiento_guardado',
      propiedades: { pantalla: 'nuevo_movimiento', tipo: 'gasto' },
    },
  });
  assert.equal(respuesta.status, 201);

  const eventos = await prisma.evento.findMany({
    where: { usuarioId, tipo: 'movimiento_guardado' },
  });
  assert.equal(eventos.length, 1);
  assert.deepEqual(eventos[0].propiedades, {
    pantalla: 'nuevo_movimiento',
    tipo: 'gasto',
  });
  assert.deepEqual(
    Object.keys(eventos[0].propiedades).sort(),
    ['pantalla', 'tipo']
  );
  assert.equal('email' in eventos[0].propiedades, false);
  assert.equal('descripcion' in eventos[0].propiedades, false);
  assert.equal('monto' in eventos[0].propiedades, false);
});

test('rechaza propiedades no definidas', async () => {
  const respuesta = await pedir('POST', '/analitica/eventos', {
    token,
    body: {
      evento: 'movimiento_iniciado',
      propiedades: {
        pantalla: 'nuevo_movimiento',
        email: 'no@guardar.com',
      },
    },
  });
  assert.equal(respuesta.status, 400);

  const eventos = await prisma.evento.findMany({
    where: { usuarioId, tipo: 'movimiento_iniciado' },
  });
  assert.equal(eventos.length, 1);
});

test('muestra la fecha en hora boliviana', () => {
  assert.equal(
    fechaBolivia(new Date('2026-11-07T01:45:00.000Z')),
    '06/11/2026 21:45:00'
  );
});

test('muestra el panel de analitica', async () => {
  const respuesta = await fetch(`${base}/analitica`);
  assert.equal(respuesta.status, 200);

  const datos = await respuesta.json();
  assert.match(datos.fecha, /^\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}$/);
  assert.equal(typeof datos.iniciados, 'number');
  assert.equal(typeof datos.completados, 'number');
  assert.ok(datos.iniciados >= 1);
  assert.ok(datos.completados >= 1);
});
