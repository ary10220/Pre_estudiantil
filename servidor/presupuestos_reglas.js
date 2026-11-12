// Reglas de negocio para presupuestos por categoria (Tarea 7 - Cambio 2)

const CATEGORIAS = ['comida', 'transporte', 'estudio', 'otros'];

function aCentavos(monto) {
  return Math.round(Number(monto) * 100);
}

function redondear(n) {
  return Math.round(n * 100) / 100;
}


// Calcula el estado de una categoria por su limite y el gasto ya acumulado
function calcularEstadoCategoria({ limite, gastado }) {
  if (limite == null) {
    return {
      limite: null,
      gastado: redondear(gastado),
      restante: null,
      proporcion: null,
      enAviso: false,
      excedido: false,
      estado: 'sin_limite',
    };
  }

  const gastadoRedondeado = redondear(gastado);
  const limiteNum = Number(limite);
  const restante = redondear(limiteNum - gastadoRedondeado);
  const proporcion = limiteNum > 0 ? redondear(gastadoRedondeado / limiteNum) : null;
  const excedido = gastadoRedondeado > limiteNum;
  const enAviso = !excedido && gastadoRedondeado >= redondear(limiteNum * 0.8);

  let estado = 'normal';
  if (excedido) estado = 'excedido';
  else if (enAviso) estado = 'aviso';

  return {
    limite: limiteNum,
    gastado: gastadoRedondeado,
    restante,
    proporcion,
    enAviso,
    excedido,
    estado,
  };
}

// Agrupa los movimientos por rango de mes y categoria, se cuenta el tipo "gasto"
function calcularConsumoPorCategorias({ movimientos, presupuestos, mes }) {
  const mesFiltro = mes.slice(0, 7);

  const mapaGastos = new Map();
  for (const cat of CATEGORIAS) {
    mapaGastos.set(cat, 0);
  }

  for (const m of movimientos) {

    if (m.tipo !== 'gasto') continue;

    const fechaStr = typeof m.fecha === 'string' ? m.fecha : m.fecha.toISOString().slice(0, 10);
    if (!fechaStr.startsWith(mesFiltro)) continue;

    const cat = m.categoria || 'otros';
    if (mapaGastos.has(cat)) {
      mapaGastos.set(cat, mapaGastos.get(cat) + aCentavos(m.monto));
    }
  }

  const mapaLimites = new Map(
    presupuestos.map((p) => [p.categoria, Number(p.monto)])
  );

  return CATEGORIAS.map((categoria) => {
    const limite = mapaLimites.has(categoria) ? mapaLimites.get(categoria) : null;
    const gastado = (mapaGastos.get(categoria) || 0) / 100;
    const estado = calcularEstadoCategoria({ limite, gastado });

    return {
      categoria,
      ...estado,
    };
  });
}

// Comienza a simular el recalculo cuando se mueve un gasto de categoria o fecha
function recalcularAlMoverGasto({
  movimientos,
  movimientoId,
  nuevaCategoria,
  nuevaFecha,
  nuevoMonto,
}) {
  return movimientos.map((m) => {
    if (m.id === movimientoId) {
      return {
        ...m,
        categoria: nuevaCategoria ?? m.categoria,
        fecha: nuevaFecha ?? m.fecha,
        monto: nuevoMonto ?? m.monto,
      };
    }
    return m;
  });
}

module.exports = {
  CATEGORIAS,
  calcularEstadoCategoria,
  calcularConsumoPorCategorias,
  recalcularAlMoverGasto,
};

