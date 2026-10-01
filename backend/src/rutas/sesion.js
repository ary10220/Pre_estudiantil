const express = require('express');
const requiereSesion = require('../middleware/requiereSesion');
const { borrarSesion } = require('../servicios/sesiones');

const router = express.Router();

router.get('/yo', requiereSesion, (req, res) => {
  res.json({ usuario: req.usuario });
});

router.post('/salir', requiereSesion, async (req, res) => {
  await borrarSesion(req.token);
  res.status(204).end();
});

module.exports = router;
