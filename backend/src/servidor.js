require('dotenv').config();
const express = require('express');
const rutasAuth = require('./flujos/acceso/rutas');
const rutasSesion = require('./flujos/acceso/rutasSesion');
const rutasMovimientos = require('./flujos/movimientos/rutas');
const rutasLimite = require('./flujos/limite/rutas');

const app = express();
app.use(express.json());

app.use('/auth', rutasAuth);
app.use('/sesion', rutasSesion);
app.use('/movimientos', rutasMovimientos);
app.use('/limite', rutasLimite);

app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
});

app.use((err, req, res, next) => {
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ error: 'Los datos enviados no son válidos' });
  }
  console.error(err);
  res.status(500).json({ error: 'Algo salió mal en el servidor, probá de nuevo' });
});

const puerto = process.env.PUERTO || 3000;
app.listen(puerto, '0.0.0.0', () => {
  console.log(`Servidor escuchando en el puerto ${puerto}`);
});
