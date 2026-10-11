const bcrypt = require('bcryptjs');
const pool = require('./conexion');

async function sembrar() {
  const hash = await bcrypt.hash('123456', 10);

  await pool.query(
    `INSERT INTO usuarios (nombre, correo, contrasena_hash)
     VALUES ($1, $2, $3)
     ON CONFLICT (correo) DO UPDATE SET contrasena_hash = EXCLUDED.contrasena_hash`,
    ['Usuario Prueba', 'prueba@correo.com', hash]
  );

  console.log('Semilla cargada: prueba@correo.com / 123456');
  await pool.end();
}

sembrar();