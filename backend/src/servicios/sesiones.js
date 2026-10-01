const crypto = require('crypto');
const pool = require('../bd');

async function crearSesion(usuarioId) {
  const token = crypto.randomBytes(32).toString('hex');
  const resultado = await pool.query(
    "INSERT INTO sesiones (token, usuario_id, expira_en) VALUES ($1, $2, NOW() + INTERVAL '7 days') RETURNING expira_en",
    [token, usuarioId]
  );
  return { token, expiraEn: resultado.rows[0].expira_en };
}

async function buscarUsuarioPorToken(token) {
  const resultado = await pool.query(
    `SELECT u.id, u.nombre, u.correo
     FROM sesiones s JOIN usuarios u ON u.id = s.usuario_id
     WHERE s.token = $1 AND s.expira_en > NOW()`,
    [token]
  );
  return resultado.rows[0] || null;
}

async function borrarSesion(token) {
  await pool.query('DELETE FROM sesiones WHERE token = $1', [token]);
}

async function borrarSesionesDeUsuario(usuarioId) {
  await pool.query('DELETE FROM sesiones WHERE usuario_id = $1', [usuarioId]);
}

module.exports = {
  crearSesion,
  buscarUsuarioPorToken,
  borrarSesion,
  borrarSesionesDeUsuario,
};
