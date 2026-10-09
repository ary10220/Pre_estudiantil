const express = require('express');
const requiereSesion = require('../../comun/middleware/requiereSesion');
const { leerLimite, guardarLimite } = require('./servicio');
const { validarLimite } = require('./validaciones');

const router = express.Router();

// El usuario sale del token: cada uno ve y cambia solo su propio límite
router.use(requiereSesion);

router.get('/', async (req, res) => {
  const limite = await leerLimite(req.usuario.id);
  res.json({ limite });
});

router.put('/', async (req, res) => {
  const { limite } = req.body || {};
  const error = validarLimite(limite);
  if (error) {
    return res.status(400).json({ error });
  }
  const guardado = await guardarLimite(req.usuario.id, Number(limite));
  res.json({ limite: guardado });
});

module.exports = router;
