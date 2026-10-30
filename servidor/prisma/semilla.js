const bcrypt = require('bcryptjs');
const prisma = require('../conexion');

async function sembrar() {
  const correo = 'prueba@correo.com';
  const existente = await prisma.usuario.findUnique({
    where: { correo },
    select: { id: true },
  });

  if (existente) {
    console.log('La semilla ya existe: prueba@correo.com');
    return;
  }

  const hash = await bcrypt.hash('123456', 10);
  await prisma.usuario.create({
    data: {
      nombre: 'Usuario Prueba',
      correo,
      contrasenaHash: hash,
    },
  });

  console.log('Semilla cargada: prueba@correo.com / 123456');
}

sembrar()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
