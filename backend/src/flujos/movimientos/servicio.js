const pool = require('../../bd');

// to_char deja la fecha como texto 2026-10-01, así no se corre por la zona horaria
const columnas = "id, tipo, concepto, monto, to_char(fecha, 'YYYY-MM-DD') AS fecha, estado, pagado_en";

// pg devuelve NUMERIC como texto ("25.00"), lo pasamos a número
function aMovimiento(fila) {
  return { ...fila, monto: Number(fila.monto) };
}

async function crearGasto(usuarioId, concepto, monto, fecha) {
  const resultado = await pool.query(
    `INSERT INTO movimientos (usuario_id, tipo, concepto, monto, fecha) VALUES ($1, 'gasto', $2, $3, $4) RETURNING ${columnas}`,
    [usuarioId, concepto, monto, fecha]
  );
  return aMovimiento(resultado.rows[0]);
}

async function listarDeUsuario(usuarioId) {
  const resultado = await pool.query(
    `SELECT ${columnas} FROM movimientos
     WHERE usuario_id = $1
     ORDER BY movimientos.fecha DESC, creado_en DESC, id DESC`,
    [usuarioId]
  );
  return resultado.rows.map(aMovimiento);
}

// Busca por id y por dueño: el movimiento de otro usuario es como si no existiera
async function buscarDeUsuario(id, usuarioId) {
  const resultado = await pool.query(
    `SELECT ${columnas} FROM movimientos WHERE id = $1 AND usuario_id = $2`,
    [id, usuarioId]
  );
  return resultado.rows[0] ? aMovimiento(resultado.rows[0]) : null;
}

// El "AND estado = 'pendiente'" evita pagar dos veces si llegan dos pedidos juntos
async function marcarPagado(id, usuarioId) {
  const resultado = await pool.query(
    `UPDATE movimientos SET estado = 'pagado', pagado_en = NOW()
     WHERE id = $1 AND usuario_id = $2 AND estado = 'pendiente'
     RETURNING ${columnas}`,
    [id, usuarioId]
  );
  return resultado.rows[0] ? aMovimiento(resultado.rows[0]) : null;
}

module.exports = { crearGasto, listarDeUsuario, buscarDeUsuario, marcarPagado };
