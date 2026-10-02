const bcrypt = require('bcrypt');
const pool = require('../../bd');

function normalizarCorreo(correo) {
  return correo.trim().toLowerCase();
}

async function crearUsuario(nombre, correo, contrasena) {
  const hash = await bcrypt.hash(contrasena, 10);
  const resultado = await pool.query(
    'INSERT INTO usuarios (nombre, correo, contrasena_hash) VALUES ($1, $2, $3) RETURNING id, nombre, correo',
    [nombre.trim(), normalizarCorreo(correo), hash]
  );
  return resultado.rows[0];
}

async function buscarPorCorreo(correo) {
  const resultado = await pool.query(
    'SELECT id, nombre, correo, contrasena_hash FROM usuarios WHERE correo = $1',
    [normalizarCorreo(correo)]
  );
  return resultado.rows[0] || null;
}

async function buscarPorId(id) {
  const resultado = await pool.query(
    'SELECT id, nombre, correo FROM usuarios WHERE id = $1',
    [id]
  );
  return resultado.rows[0] || null;
}

async function contrasenaCorrecta(contrasena, hash) {
  return bcrypt.compare(contrasena, hash);
}

async function cambiarContrasena(usuarioId, nueva) {
  const hash = await bcrypt.hash(nueva, 10);
  await pool.query(
    'UPDATE usuarios SET contrasena_hash = $1 WHERE id = $2',
    [hash, usuarioId]
  );
}

module.exports = {
  crearUsuario,
  buscarPorCorreo,
  buscarPorId,
  contrasenaCorrecta,
  cambiarContrasena,
};
