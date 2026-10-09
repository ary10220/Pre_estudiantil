const pool = require('../../bd');

// pg devuelve NUMERIC como texto; si todavía no hay límite queda null
function aNumero(valor) {
  return valor === null ? null : Number(valor);
}

async function leerLimite(usuarioId) {
  const resultado = await pool.query('SELECT limite_mensual FROM usuarios WHERE id = $1', [usuarioId]);
  return aNumero(resultado.rows[0].limite_mensual);
}

async function guardarLimite(usuarioId, limite) {
  const resultado = await pool.query(
    'UPDATE usuarios SET limite_mensual = $2 WHERE id = $1 RETURNING limite_mensual',
    [usuarioId, limite]
  );
  return aNumero(resultado.rows[0].limite_mensual);
}

module.exports = { leerLimite, guardarLimite };
