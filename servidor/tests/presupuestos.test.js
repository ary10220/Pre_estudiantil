const { test } = require('node:test');
const assert = require('node:assert/strict');
const {
  calcularEstadoCategoria,
  calcularConsumoPorCategorias,
  recalcularAlMoverGasto,
} = require('../presupuestos_reglas');

// Los estados del presupuesto

test('estado: sin limite definido no lanza aviso ni excedido', () => {
  const res = calcularEstadoCategoria({ limite: null, gastado: 250 });
  assert.equal(res.estado, 'sin_limite');
  assert.equal(res.limite, null);
  assert.equal(res.gastado, 250);
  assert.equal(res.restante, null);
  assert.equal(res.enAviso, false);
  assert.equal(res.excedido, false);
});

test('estado normal: gasto por debajo del 80 % del limite', () => {
  const res = calcularEstadoCategoria({ limite: 200, gastado: 100 });
  assert.equal(res.estado, 'normal');
  assert.equal(res.restante, 100);
  assert.equal(res.proporcion, 0.5);
  assert.equal(res.enAviso, false);
  assert.equal(res.excedido, false);
});

test('estado aviso: gasto alcanza o supera el 80 % sin pasar el 100 %', () => {
  const res80 = calcularEstadoCategoria({ limite: 200, gastado: 160 });
  assert.equal(res80.estado, 'aviso');
  assert.equal(res80.enAviso, true);
  assert.equal(res80.excedido, false);
  assert.equal(res80.restante, 40);

  const res90 = calcularEstadoCategoria({ limite: 200, gastado: 180 });
  assert.equal(res90.estado, 'aviso');
  assert.equal(res90.enAviso, true);
  assert.equal(res90.excedido, false);
});

test('estado excedido: gasto supera el 100 % del limite', () => {
  const res = calcularEstadoCategoria({ limite: 200, gastado: 250 });
  assert.equal(res.estado, 'excedido');
  assert.equal(res.enAviso, false);
  assert.equal(res.excedido, true);
  assert.equal(res.restante, -50);
  assert.equal(res.proporcion, 1.25);
});

// los ingresos no consumen presupuesto

test('regla: un movimiento de tipo ingreso no afecta el gasto ni el saldo de la categoria', () => {
  const movimientos = [
    { id: 1, tipo: 'gasto', categoria: 'comida', monto: 50, fecha: '2026-10-10' },
    { id: 2, tipo: 'ingreso', categoria: 'comida', monto: 500, fecha: '2026-10-15' }, // ingreso no cuenta
  ];
  const presupuestos = [
    { categoria: 'comida', monto: 200 },
  ];

  const resultado = calcularConsumoPorCategorias({
    movimientos,
    presupuestos,
    mes: '2026-10-01',
  });

  const comida = resultado.find((c) => c.categoria === 'comida');
  assert.equal(comida.gastado, 50, 'El ingreso de Bs 500 no debe sumarse ni restarse al consumo');
  assert.equal(comida.restante, 150);
  assert.equal(comida.estado, 'normal');
});

// recalcula al mover gasto entre las categorias


test('escenario minimo: mover un gasto de Comida a Transporte actualiza ambos presupuestos', () => {
  let movimientos = [
    { id: 1, tipo: 'gasto', categoria: 'comida', monto: 80, fecha: '2026-10-05' },
    { id: 2, tipo: 'gasto', categoria: 'transporte', monto: 30, fecha: '2026-10-08' },
  ];
  const presupuestos = [
    { categoria: 'comida', monto: 100 },
    { categoria: 'transporte', monto: 100 },
  ];

  // el estado incial
  const antes = calcularConsumoPorCategorias({ movimientos, presupuestos, mes: '2026-10-01' });
  const comidaAntes = antes.find((c) => c.categoria === 'comida');
  const transporteAntes = antes.find((c) => c.categoria === 'transporte');

  assert.equal(comidaAntes.gastado, 80);
  assert.equal(comidaAntes.estado, 'aviso', '80 de 100 es aviso al 80%');
  assert.equal(transporteAntes.gastado, 30);
  assert.equal(transporteAntes.estado, 'normal');

  // cuando movemos el gasto 1 de "comida" a "transporte"
  movimientos = recalcularAlMoverGasto({
    movimientos,
    movimientoId: 1,
    nuevaCategoria: 'transporte',
  });

  // ambos deben recalculan
  const despues = calcularConsumoPorCategorias({ movimientos, presupuestos, mes: '2026-10-01' });
  const comidaDespues = despues.find((c) => c.categoria === 'comida');
  const transporteDespues = despues.find((c) => c.categoria === 'transporte');

  assert.equal(comidaDespues.gastado, 0, 'Comida debe quedar en 0');
  assert.equal(comidaDespues.restante, 100);
  assert.equal(comidaDespues.estado, 'normal');

  assert.equal(transporteDespues.gastado, 110, 'Transporte suma 30 + 80 = 110');
  assert.equal(transporteDespues.restante, -10);
  assert.equal(transporteDespues.estado, 'excedido', '110 supera el limite de 100');
});



// Se recalcula al mover un gasto a otro mes


test('escenario minimo: mover un gasto de octubre a noviembre actualiza ambos periodos', () => {
  let movimientos = [
    { id: 1, tipo: 'gasto', categoria: 'comida', monto: 90, fecha: '2026-10-12' },
  ];
  const presupuestosOct = [{ categoria: 'comida', monto: 100 }];
  const presupuestosNov = [{ categoria: 'comida', monto: 100 }];


  const octAntes = calcularConsumoPorCategorias({ movimientos, presupuestos: presupuestosOct, mes: '2026-10-01' });
  assert.equal(octAntes.find((c) => c.categoria === 'comida').gastado, 90);


  movimientos = recalcularAlMoverGasto({
    movimientos,
    movimientoId: 1,
    nuevaFecha: '2026-11-05',
  });


  const octDespues = calcularConsumoPorCategorias({ movimientos, presupuestos: presupuestosOct, mes: '2026-10-01' });
  const novDespues = calcularConsumoPorCategorias({ movimientos, presupuestos: presupuestosNov, mes: '2026-11-01' });

  assert.equal(octDespues.find((c) => c.categoria === 'comida').gastado, 0);
  assert.equal(novDespues.find((c) => c.categoria === 'comida').gastado, 90);
});

// Eliminar

test('eliminar un gasto reduce el acumulado y restaura el saldo', () => {
  let movimientos = [
    { id: 1, tipo: 'gasto', categoria: 'estudio', monto: 100, fecha: '2026-10-01' },
    { id: 2, tipo: 'gasto', categoria: 'estudio', monto: 50, fecha: '2026-10-02' },
  ];
  const presupuestos = [{ categoria: 'estudio', monto: 120 }];

  // 150 gastado, se excede por 120
  const inicial = calcularConsumoPorCategorias({ movimientos, presupuestos, mes: '2026-10-01' });
  assert.equal(inicial.find((c) => c.categoria === 'estudio').estado, 'excedido');

  movimientos = movimientos.filter((m) => m.id !== 1);

  const final = calcularConsumoPorCategorias({ movimientos, presupuestos, mes: '2026-10-01' });
  const estudioFinal = final.find((c) => c.categoria === 'estudio');
  assert.equal(estudioFinal.gastado, 50);
  assert.equal(estudioFinal.restante, 70);
  assert.equal(estudioFinal.estado, 'normal');
});

