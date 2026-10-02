const { buscarUsuarioPorToken } = require('../sesiones');

const mensajeSesionTerminada = 'Tu sesión terminó, iniciá sesión de nuevo';

async function requiereSesion(req, res, next) {
  const cabecera = req.headers.authorization || '';
  const [tipo, token] = cabecera.split(' ');

  if (tipo !== 'Bearer' || !token) {
    return res.status(401).json({ error: mensajeSesionTerminada });
  }

  const usuario = await buscarUsuarioPorToken(token);
  if (!usuario) {
    return res.status(401).json({ error: mensajeSesionTerminada });
  }

  req.usuario = usuario;
  req.token = token;
  next();
}

module.exports = requiereSesion;
