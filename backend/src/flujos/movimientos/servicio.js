const pool = require('../../bd');

// to_char deja la fecha como texto 2026-10-01, así no se corre por la zona horaria
const columnas = "id, tipo, concepto, monto, to_char(fecha, 'YYYY-MM-DD') AS fecha";

// pg devuelve NUMERIC como texto ("25.00"), lo pasamos a número
function aMovimiento(fila) {
  return { ...fila, monto: Number(fila.monto) };
}

async function crearGasto(usuarioId, concepto, monto) {
  const resultado = await pool.query(
    `INSERT INTO movimientos (usuario_id, tipo, concepto, monto) VALUES ($1, 'gasto', $2, $3) RETURNING ${columnas}`,
    [usuarioId, concepto, monto]
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

module.exports = { crearGasto, listarDeUsuario };
