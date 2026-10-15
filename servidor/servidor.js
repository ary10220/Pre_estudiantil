const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const pool = require('./conexion');

const {
  validarMontoLimite,
  validarLimiteContraGastado,
  puedeRegistrarGasto,
  calcularResumen
} = require('./limite');

const {
  TIPOS,
  CATEGORIAS,
  leerFiltros,
  filtrarMovimientos,
  calcularTotales,
  hoyTexto
} = require('./filtros');

const { validarCorreo } = require('./correo');

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
  const formato = validarCorreo(correo);
  if (!formato.ok) {
    return res.status(400).json({ error: formato.error });
  }
  if (contrasena.length < 6) {
    return res.status(400).json({ error: 'La contraseña debe tener mínimo 6 caracteres' });
  }

  try {
    const hash = await bcrypt.hash(contrasena, 10);
    await pool.query(
      'INSERT INTO usuarios (nombre, correo, contrasena_hash) VALUES ($1, $2, $3)',
      [nombre, correo.trim().toLowerCase(), hash]
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
  to_char(fecha, 'YYYY-MM-DD') AS fecha, tipo, categoria, estado`;

// Listar los movimientos de la persona con sesión, con búsqueda y filtros opcionales
app.get('/movimientos', exigirSesion, async (req, res) => {
  const lectura = leerFiltros(req.query);
  if (!lectura.ok) {
    return res.status(400).json({ error: lectura.error });
  }

  const resultado = await pool.query(
    `SELECT ${COLUMNAS_MOVIMIENTO} FROM movimientos
     WHERE usuario_id = $1 ORDER BY fecha DESC, id DESC`,
    [req.usuario.id]
  );

  // El total sale de la misma lista filtrada que se devuelve: siempre coinciden
  const movimientos = filtrarMovimientos(resultado.rows, lectura.filtros, hoyTexto());
  res.json({ movimientos, totales: calcularTotales(movimientos) });
});

// Crear un movimiento (siempre nace "pendiente")
app.post('/movimientos', exigirSesion, async (req, res) => {
  const concepto = String(req.body.concepto || '').trim();
  const monto = Number(req.body.monto);
  const fecha = String(req.body.fecha || '');
  const tipo = req.body.tipo ?? 'gasto';
  const categoria = req.body.categoria ?? 'otros';

  if (!concepto || !fecha) {
    return res.status(400).json({ error: 'Completa todos los campos' });
  }
  if (!(monto > 0 && monto < 1e10)) {
    return res.status(400).json({ error: 'El monto debe ser mayor a 0' });
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(fecha)) {
    return res.status(400).json({ error: 'Fecha inválida' });
  }
  if (!TIPOS.includes(tipo)) {
    return res.status(400).json({ error: 'Tipo inválido' });
  }
  if (!CATEGORIAS.includes(categoria)) {
    return res.status(400).json({ error: 'Categoría inválida' });
  }

  // Solo los gastos cuentan para el límite mensual (#6); un ingreso no se controla
  if (tipo === 'gasto') {
    const control = await controlarLimite(req.usuario.id, fecha, monto);
    if (!control.ok) {
      return res.status(422).json({ error: control.error });
    }
  }

  const resultado = await pool.query(
    `INSERT INTO movimientos (usuario_id, concepto, monto, fecha, tipo, categoria)
     VALUES ($1, $2, $3, $4, $5, $6) RETURNING ${COLUMNAS_MOVIMIENTO}`,
    [req.usuario.id, concepto, monto, fecha, tipo, categoria]
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

// Editar: si está pagado, el monto no puede cambiar. El tipo no se modifica.
app.put('/movimientos/:id', exigirSesion, async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) {
    return res.status(400).json({ error: 'Movimiento inválido' });
  }

  const concepto = String(req.body.concepto || '').trim();
  const monto = Math.round(Number(req.body.monto) * 100) / 100;
  const fecha = String(req.body.fecha || '');
  const categoria = req.body.categoria ?? null; // null = dejar la categoría como está

  if (!concepto || !fecha) {
    return res.status(400).json({ error: 'Completa todos los campos' });
  }
  if (!(monto > 0 && monto < 1e10)) {
    return res.status(400).json({ error: 'El monto debe ser mayor a 0' });
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(fecha)) {
    return res.status(400).json({ error: 'Fecha inválida' });
  }
  if (categoria !== null && !CATEGORIAS.includes(categoria)) {
    return res.status(400).json({ error: 'Categoría inválida' });
  }

  const actual = await pool.query(
    'SELECT tipo FROM movimientos WHERE id = $1 AND usuario_id = $2',
    [id, req.usuario.id]
  );
  if (actual.rows.length === 0) {
    return res.status(404).json({ error: 'Movimiento no encontrado' });
  }

  // Solo los gastos cuentan para el límite. El monto anterior de este movimiento no se cuenta.
  if (actual.rows[0].tipo === 'gasto') {
    const control = await controlarLimite(req.usuario.id, fecha, monto, id);
    if (!control.ok) {
      return res.status(422).json({ error: control.error });
    }
  }

  // La restricción vive en el WHERE: si está pagado, el monto debe ser el mismo
  const resultado = await pool.query(
    `UPDATE movimientos
     SET concepto = $3, monto = $4, fecha = $5, categoria = COALESCE($6, categoria)
     WHERE id = $1 AND usuario_id = $2
       AND (estado = 'pendiente' OR monto = $4)
     RETURNING ${COLUMNAS_MOVIMIENTO}`,
    [id, req.usuario.id, concepto, monto, fecha, categoria]
  );

  // Como el movimiento existe, no actualizar significa: pagado con otro monto
  if (resultado.rows.length === 0) {
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

// ---------- Límite mensual (#9) ----------
// 'AAAA-MM' → 'AAAA-MM-01'; sin mes, el mes actual; null si el formato no sirve
function primerDiaDelMes(mes) {
  if (mes == null) {
    const hoy = new Date();
    return `${hoy.getFullYear()}-${String(hoy.getMonth() + 1).padStart(2, '0')}-01`;
  }
  if (!/^\d{4}-(0[1-9]|1[0-2])$/.test(mes)) return null;
  return `${mes}-01`;
}

// null si la persona no definió límite para ese mes
async function leerLimite(usuarioId, mes) {
  const resultado = await pool.query(
    'SELECT monto::float8 AS monto FROM limites_mensuales WHERE usuario_id = $1 AND mes = $2',
    [usuarioId, mes]
  );
  return resultado.rows.length === 0 ? null : resultado.rows[0].monto;
}

// Solo los movimientos de tipo gasto cuentan. idExcluido: el que se está editando
async function gastadoDelMes(usuarioId, mes, idExcluido = 0) {
  const resultado = await pool.query(
    `SELECT COALESCE(SUM(monto), 0)::float8 AS gastado FROM movimientos
     WHERE usuario_id = $1 AND id <> $3 AND tipo = 'gasto'
       AND fecha >= $2::date AND fecha < $2::date + INTERVAL '1 month'`,
    [usuarioId, mes, idExcluido]
  );
  return resultado.rows[0].gastado;
}

// Antes de guardar un gasto: ¿entra en el límite del mes de su fecha?
async function controlarLimite(usuarioId, fecha, montoNuevo, idExcluido = 0) {
  const mes = fecha.slice(0, 8) + '01';
  const limite = await leerLimite(usuarioId, mes);
  const gastado = await gastadoDelMes(usuarioId, mes, idExcluido);
  return puedeRegistrarGasto({ limite, gastado, montoNuevo });
}

app.get('/limite', exigirSesion, async (req, res) => {
  const mes = primerDiaDelMes(req.query.mes);
  if (!mes) {
    return res.status(400).json({ error: 'Mes inválido' });
  }

  const limite = await leerLimite(req.usuario.id, mes);
  const gastado = await gastadoDelMes(req.usuario.id, mes);
  res.json({ mes: mes.slice(0, 7), ...calcularResumen({ limite, gastado }) });
});

app.put('/limite', exigirSesion, async (req, res) => {
  const { monto, mes: mesPedido } = req.body || {};
  const mes = primerDiaDelMes(mesPedido);
  if (!mes) {
    return res.status(400).json({ error: 'Mes inválido' });
  }
  const validacion = validarMontoLimite(monto);
  if (!validacion.ok) {
    return res.status(400).json({ error: validacion.error });
  }

  const gastado = await gastadoDelMes(req.usuario.id, mes);
  const contraGastado = validarLimiteContraGastado(monto, gastado);
  if (!contraGastado.ok) {
    return res.status(400).json({ error: contraGastado.error });
  }

  await pool.query(
    `INSERT INTO limites_mensuales (usuario_id, mes, monto) VALUES ($1, $2, $3)
     ON CONFLICT (usuario_id, mes) DO UPDATE SET monto = EXCLUDED.monto, actualizado_en = NOW()`,
    [req.usuario.id, mes, Number(monto)]
  );
  res.json({ mes: mes.slice(0, 7), ...calcularResumen({ limite: Number(monto), gastado }) });
});

// ---------- Manejo de errores ----------
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Error del servidor' });
});

const puerto = process.env.PUERTO || 3000;
app.listen(puerto, () => console.log(`Servidor en http://localhost:${puerto}`));