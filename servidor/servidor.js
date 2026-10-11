const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const pool = require('./conexion');
const { validarLimite } = require('./limite');

const app = express();
app.use(cors());
app.use(express.json());

// ---------- Protección: exige una sesión válida ----------
async function exigirSesion(req, res, next) {
  const token = (req.headers.authorization || '').replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'No hay sesión' });

  const resultado = await pool.query(
    `SELECT u.id, u.nombre, u.correo
     FROM sesiones s JOIN usuarios u ON u.id = s.usuario_id
     WHERE s.token = $1 AND s.expira_en > NOW()`,
    [token]
  );
  if (resultado.rows.length === 0) {
    return res.status(401).json({ error: 'Sesión inválida o expirada' });
  }

  req.usuario = resultado.rows[0];
  req.token = token;
  next();
}

// ---------- Ruta pública ----------
app.get('/ping', (req, res) => res.json({ mensaje: 'Servidor funcionando' }));

// ---------- Registro ----------
app.post('/registro', async (req, res) => {
  const { nombre, correo, contrasena } = req.body;
  if (!nombre || !correo || !contrasena) {
    return res.status(400).json({ error: 'Completa todos los campos' });
  }
  if (contrasena.length < 6) {
    return res.status(400).json({ error: 'La contraseña debe tener mínimo 6 caracteres' });
  }

  try {
    const hash = await bcrypt.hash(contrasena, 10);
    await pool.query(
      'INSERT INTO usuarios (nombre, correo, contrasena_hash) VALUES ($1, $2, $3)',
      [nombre, correo.toLowerCase(), hash]
    );
    res.status(201).json({ mensaje: 'Cuenta creada' });
  } catch (e) {
    if (e.code === '23505') {
      return res.status(409).json({ error: 'Ese correo ya está registrado' });
    }
    throw e;
  }
});

// ---------- Inicio de sesión ----------
app.post('/login', async (req, res) => {
  const { correo, contrasena } = req.body;

  const resultado = await pool.query(
    'SELECT * FROM usuarios WHERE correo = $1',
    [(correo || '').toLowerCase()]
  );
  const usuario = resultado.rows[0];

  if (!usuario || !(await bcrypt.compare(contrasena || '', usuario.contrasena_hash))) {
    return res.status(401).json({ error: 'Correo o contraseña incorrectos' });
  }

  const token = crypto.randomBytes(32).toString('hex');
  await pool.query(
    `INSERT INTO sesiones (token, usuario_id, expira_en)
     VALUES ($1, $2, NOW() + INTERVAL '7 days')`,
    [token, usuario.id]
  );

  res.json({ token, nombre: usuario.nombre });
});

// ---------- Ruta privada: datos de quien tiene sesión ----------
app.get('/perfil', exigirSesion, (req, res) => {
  res.json({ nombre: req.usuario.nombre, correo: req.usuario.correo });
});

// ---------- Cierre de sesión ----------
app.post('/logout', exigirSesion, async (req, res) => {
  await pool.query('DELETE FROM sesiones WHERE token = $1', [req.token]);
  res.json({ mensaje: 'Sesión cerrada' });
});

// ---------- Recuperación: genera un código de 6 dígitos ----------
app.post('/recuperar', async (req, res) => {
  const resultado = await pool.query(
    'SELECT id FROM usuarios WHERE correo = $1',
    [(req.body.correo || '').toLowerCase()]
  );
  if (resultado.rows.length === 0) {
    return res.status(404).json({ error: 'Ese correo no está registrado' });
  }

  const codigo = String(Math.floor(100000 + Math.random() * 900000));
  await pool.query(
    `INSERT INTO recuperaciones (usuario_id, codigo, expira_en)
     VALUES ($1, $2, NOW() + INTERVAL '15 minutes')`,
    [resultado.rows[0].id, codigo]
  );

  // No se envía correo real: el código se devuelve para mostrarlo en la app
  res.json({ codigo });
});

// ---------- Cambio de contraseña con el código ----------
app.post('/cambiar-contrasena', async (req, res) => {
  const { correo, codigo, nuevaContrasena } = req.body;
  if (!nuevaContrasena || nuevaContrasena.length < 6) {
    return res.status(400).json({ error: 'La contraseña debe tener mínimo 6 caracteres' });
  }

  const resultado = await pool.query(
    `SELECT r.id, r.usuario_id
     FROM recuperaciones r JOIN usuarios u ON u.id = r.usuario_id
     WHERE u.correo = $1 AND r.codigo = $2 AND r.usado = FALSE AND r.expira_en > NOW()
     ORDER BY r.id DESC LIMIT 1`,
    [(correo || '').toLowerCase(), codigo]
  );
  if (resultado.rows.length === 0) {
    return res.status(400).json({ error: 'Código incorrecto o vencido' });
  }

  const { id, usuario_id } = resultado.rows[0];
  const hash = await bcrypt.hash(nuevaContrasena, 10);

  await pool.query('UPDATE usuarios SET contrasena_hash = $1 WHERE id = $2', [hash, usuario_id]);
  await pool.query('UPDATE recuperaciones SET usado = TRUE WHERE id = $1', [id]);
  await pool.query('DELETE FROM sesiones WHERE usuario_id = $1', [usuario_id]);

  res.json({ mensaje: 'Contraseña actualizada' });
});

// ---------- Movimientos ----------
// fecha como texto y monto como número, para evitar problemas de zona horaria
const COLUMNAS_MOVIMIENTO = `id, concepto, monto::float8 AS monto,
  to_char(fecha, 'YYYY-MM-DD') AS fecha, estado`;

// Listar los movimientos de la persona con sesión
app.get('/movimientos', exigirSesion, async (req, res) => {
  const resultado = await pool.query(
    `SELECT ${COLUMNAS_MOVIMIENTO} FROM movimientos
     WHERE usuario_id = $1 ORDER BY fecha DESC, id DESC`,
    [req.usuario.id]
  );
  res.json({ movimientos: resultado.rows });
});

// Crear un movimiento (siempre nace "pendiente")
app.post('/movimientos', exigirSesion, async (req, res) => {
  const concepto = String(req.body.concepto || '').trim();
  const monto = Number(req.body.monto);
  const fecha = String(req.body.fecha || '');

  if (!concepto || !fecha) {
    return res.status(400).json({ error: 'Completa todos los campos' });
  }
  if (!(monto > 0 && monto < 1e10)) {
    return res.status(400).json({ error: 'El monto debe ser mayor a 0' });
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(fecha)) {
    return res.status(400).json({ error: 'Fecha inválida' });
  }

  const resultado = await pool.query(
    `INSERT INTO movimientos (usuario_id, concepto, monto, fecha)
     VALUES ($1, $2, $3, $4) RETURNING ${COLUMNAS_MOVIMIENTO}`,
    [req.usuario.id, concepto, monto, fecha]
  );
  res.status(201).json({ movimiento: resultado.rows[0] });
});

// Marcar como pagado: solo si está pendiente
app.post('/movimientos/:id/pagar', exigirSesion, async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) {
    return res.status(400).json({ error: 'Movimiento inválido' });
  }

  const resultado = await pool.query(
    `UPDATE movimientos SET estado = 'pagado'
     WHERE id = $1 AND usuario_id = $2 AND estado = 'pendiente'
     RETURNING ${COLUMNAS_MOVIMIENTO}`,
    [id, req.usuario.id]
  );

  if (resultado.rows.length === 0) {
    const existe = await pool.query(
      'SELECT 1 FROM movimientos WHERE id = $1 AND usuario_id = $2',
      [id, req.usuario.id]
    );
    if (existe.rows.length === 0) {
      return res.status(404).json({ error: 'Movimiento no encontrado' });
    }
    return res.status(409).json({ error: 'El movimiento ya está pagado' });
  }

  res.json({ movimiento: resultado.rows[0] });
});

// Editar: si está pagado, el monto no puede cambiar
app.put('/movimientos/:id', exigirSesion, async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) {
    return res.status(400).json({ error: 'Movimiento inválido' });
  }

  const concepto = String(req.body.concepto || '').trim();
  const monto = Math.round(Number(req.body.monto) * 100) / 100;
  const fecha = String(req.body.fecha || '');

  if (!concepto || !fecha) {
    return res.status(400).json({ error: 'Completa todos los campos' });
  }
  if (!(monto > 0 && monto < 1e10)) {
    return res.status(400).json({ error: 'El monto debe ser mayor a 0' });
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(fecha)) {
    return res.status(400).json({ error: 'Fecha inválida' });
  }

  // La restricción vive en el WHERE: si está pagado, el monto debe ser el mismo
  const resultado = await pool.query(
    `UPDATE movimientos SET concepto = $3, monto = $4, fecha = $5
     WHERE id = $1 AND usuario_id = $2
       AND (estado = 'pendiente' OR monto = $4)
     RETURNING ${COLUMNAS_MOVIMIENTO}`,
    [id, req.usuario.id, concepto, monto, fecha]
  );

  if (resultado.rows.length === 0) {
    const existe = await pool.query(
      'SELECT 1 FROM movimientos WHERE id = $1 AND usuario_id = $2',
      [id, req.usuario.id]
    );
    if (existe.rows.length === 0) {
      return res.status(404).json({ error: 'Movimiento no encontrado' });
    }
    return res.status(409).json({
      error: 'Un movimiento pagado no permite modificar su monto.',
    });
  }

  res.json({ movimiento: resultado.rows[0] });
});

// Eliminar
app.delete('/movimientos/:id', exigirSesion, async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) {
    return res.status(400).json({ error: 'Movimiento inválido' });
  }

  const resultado = await pool.query(
    'DELETE FROM movimientos WHERE id = $1 AND usuario_id = $2 RETURNING id',
    [id, req.usuario.id]
  );
  if (resultado.rows.length === 0) {
    return res.status(404).json({ error: 'Movimiento no encontrado' });
  }
  res.json({ mensaje: 'Movimiento eliminado' });
});

// ---------- Límite mensual (HU-01) ----------
// null si la persona todavía no definió su límite
app.get('/limite', exigirSesion, async (req, res) => {
  const resultado = await pool.query(
    'SELECT limite_mensual::float8 AS limite FROM usuarios WHERE id = $1',
    [req.usuario.id]
  );
  res.json({ limite: resultado.rows[0].limite });
});

app.put('/limite', exigirSesion, async (req, res) => {
  const { limite } = req.body || {};
  const error = validarLimite(limite);
  if (error) {
    return res.status(400).json({ error });
  }

  const resultado = await pool.query(
    'UPDATE usuarios SET limite_mensual = $2 WHERE id = $1 RETURNING limite_mensual::float8 AS limite',
    [req.usuario.id, Number(limite)]
  );
  res.json({ limite: resultado.rows[0].limite });
});

// ---------- Manejo de errores ----------
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Error del servidor' });
});

const puerto = process.env.PUERTO || 3000;
app.listen(puerto, () => console.log(`Servidor en http://localhost:${puerto}`));