const express = require('express');
const requiereSesion = require('../../comun/middleware/requiereSesion');
const movimientos = require('./servicio');
const { validarConcepto, validarMonto } = require('./validaciones');

const router = express.Router();

// Todas las rutas de este archivo necesitan sesión; req.usuario sale del token
router.use(requiereSesion);

router.post('/', async (req, res) => {
  const { concepto, monto } = req.body || {};

  const error = validarConcepto(concepto) || validarMonto(monto);
  if (error) {
    return res.status(400).json({ error });
  }

  const movimiento = await movimientos.crearGasto(req.usuario.id, concepto.trim(), Number(monto));
  res.status(201).json({ movimiento });
});

router.get('/', async (req, res) => {
  const lista = await movimientos.listarDeUsuario(req.usuario.id);
  res.json({ movimientos: lista });
});

module.exports = router;
