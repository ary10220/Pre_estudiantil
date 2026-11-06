const bcrypt = require('bcryptjs');
const prisma = require('../conexion');

async function sembrar() {
  const correo = 'prueba@correo.com';
  const hash = await bcrypt.hash('123456', 10);

  const usuario = await prisma.usuario.upsert({
    where: { correo },
    update: { contrasenaHash: hash },
    create: {
      nombre: 'Usuario Prueba',
      correo,
      contrasenaHash: hash,
    },
  });

  const movimientos = await prisma.movimiento.count({
    where: { usuarioId: usuario.id },
  });
  if (movimientos === 0) {
    await prisma.movimiento.createMany({
      data: [
        {
          usuarioId: usuario.id,
          concepto: 'Ingreso de prueba',
          monto: '1000.00',
          fecha: new Date('2026-11-01T00:00:00.000Z'),
          tipo: 'ingreso',
          categoria: 'otros',
          estado: 'pagado',
        },
        {
          usuarioId: usuario.id,
          concepto: 'Gasto de prueba',
          monto: '400.00',
          fecha: new Date('2026-11-02T00:00:00.000Z'),
          tipo: 'gasto',
          categoria: 'comida',
          estado: 'pagado',
        },
      ],
    });
  }

  const metas = await prisma.metaAhorro.count({
    where: { usuarioId: usuario.id },
  });
  if (metas === 0) {
    await prisma.metaAhorro.createMany({
      data: [
        {
          usuarioId: usuario.id,
          nombre: 'Fondo de emergencia',
          montoObjetivo: '500.00',
          fechaObjetivo: new Date('2027-02-01T00:00:00.000Z'),
        },
        {
          usuarioId: usuario.id,
          nombre: 'Viaje',
          montoObjetivo: '300.00',
          fechaObjetivo: new Date('2027-05-01T00:00:00.000Z'),
        },
      ],
    });
  }

  console.log('Semilla cargada: prueba@correo.com / 123456');
}

sembrar()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
