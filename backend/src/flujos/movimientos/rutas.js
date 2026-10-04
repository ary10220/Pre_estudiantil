const express = require('express');
const requiereSesion = require('../../comun/middleware/requiereSesion');
const movimientos = require('./servicio');
const { validarConcepto, validarMonto, validarIdMovimiento } = require('./validaciones');
const { marcarComoPagado } = require('./estado');

const router = express.Router();

// Todas las rutas de este archivo necesitan sesión; req.usuario sale del token
router.use(requiereSesion);

router.post('/', async (req, res) => {
  const { concepto, monto, fecha } = req.body || {};

  const error = validarConcepto(concepto) || validarMonto(monto);
  if (error) {
    return res.status(400).json({ error });
  }

  const movimiento = await movimientos.crearGasto(req.usuario.id, concepto.trim(), Number(monto), fecha);
  res.status(201).json({ movimiento });
});

router.get('/', async (req, res) => {
  const lista = await movimientos.listarDeUsuario(req.usuario.id);
  res.json({ movimientos: lista });
});

router.patch('/:id/pagar', async (req, res) => {
  const errorId = validarIdMovimiento(req.params.id);
  if (errorId) {
    return res.status(400).json({ error: errorId });
  }

  const movimiento = await movimientos.buscarDeUsuario(Number(req.params.id), req.usuario.id);
  if (!movimiento) {
    return res.status(404).json({ error: 'No encontramos ese movimiento' });
  }

  // La misma regla que prueban los tests: si ya está pagado o el estado es raro, corta acá
  try {
    marcarComoPagado(movimiento, new Date());
  } catch (error) {
    return res.status(error.codigo).json({ error: error.message });
  }

  const pagado = await movimientos.marcarPagado(movimiento.id, req.usuario.id);
  if (!pagado) {
    return res.status(409).json({ error: 'Este movimiento ya está pagado' });
  }
  res.json({ movimiento: pagado });
});

module.exports = router;
