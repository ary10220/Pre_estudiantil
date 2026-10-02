const crypto = require('crypto');
const pool = require('../../bd');

async function generarCodigo(usuarioId) {
  await pool.query(
    'UPDATE recuperaciones SET usado = TRUE WHERE usuario_id = $1 AND usado = FALSE',
    [usuarioId]
  );
  const codigo = crypto.randomInt(0, 1000000).toString().padStart(6, '0');
  await pool.query(
    "INSERT INTO recuperaciones (usuario_id, codigo, expira_en) VALUES ($1, $2, NOW() + INTERVAL '15 minutes')",
    [usuarioId, codigo]
  );
  return codigo;
}

// Devuelve también el id para poder marcar el código como usado después
async function verificarCodigo(usuarioId, codigo) {
  const resultado = await pool.query(
    `SELECT id, expira_en > NOW() AS vigente
     FROM recuperaciones
     WHERE usuario_id = $1 AND codigo = $2 AND usado = FALSE
     ORDER BY id DESC LIMIT 1`,
    [usuarioId, codigo]
  );
  const fila = resultado.rows[0];
  if (!fila) {
    return { estado: 'no_coincide' };
  }
  if (!fila.vigente) {
    return { estado: 'vencido' };
  }
  return { estado: 'ok', id: fila.id };
}

async function marcarUsado(id) {
  await pool.query('UPDATE recuperaciones SET usado = TRUE WHERE id = $1', [id]);
}

module.exports = { generarCodigo, verificarCodigo, marcarUsado };
