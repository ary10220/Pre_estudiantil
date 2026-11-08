# UniBudget - Presupuesto Estudiantil

App móvil para que estudiantes organicen sus ingresos y gastos.

> Para levantar el proyecto paso a paso, incluidos Docker, emulador y pruebas de integración, consulta [INICIO_RAPIDO.md](INICIO_RAPIDO.md).

## Tabla de contenido

- [Descripción](#descripción)
- [Tecnologías](#tecnologías)
- [Inicio rápido](#inicio-rápido)
- [Usuario de prueba](#usuario-de-prueba)
- [Funcionalidades](#funcionalidades)
- [Pruebas](#pruebas)
- [Documentación](#documentación)

## Descripción

UniBudget permite registrar ingresos y gastos, marcarlos como pagados, editarlos, eliminarlos, definir un límite mensual y consultar un historial de actividad.

## Tecnologías

- **App:** Flutter (Dart).
- **API:** Node.js + Express + Prisma.
- **Base de datos:** PostgreSQL 16.
- **Desarrollo:** Docker Compose con hot-reload.

```text
App Flutter  →  API (servidor/)  →  PostgreSQL
```

## Inicio rápido

1. Levanta el backend y la base de datos:

```bash
cd servidor
docker compose -f docker-compose.dev.yml up -d --build
```

2. Configura el `.env` de la raíz para Flutter:

```env
API_BASE_URL=http://10.0.2.2:3000
APP_NAME="UniBudget"
```

Usa `http://localhost:3000` en macOS o web.

3. Ejecuta la app:

```bash
flutter pub get
flutter run -d <ID_DEL_DISPOSITIVO>
```

Los pasos completos, la configuración de IP por plataforma y las pruebas de integración están en [INICIO_RAPIDO.md](INICIO_RAPIDO.md).

## Usuario de prueba

| Correo | Contraseña |
|---|---|
| prueba@correo.com | 123456 |

La semilla se ejecuta automáticamente al levantar el backend en desarrollo. Si el usuario ya existe, no se duplica. También deja dos metas de prueba: `Fondo de emergencia` y `Viaje`.

## Funcionalidades

- Acceso: registro, inicio y cierre de sesión, recuperación de contraseña y sesión persistente.
- Movimientos: crear, marcar como pagado, editar y eliminar; búsqueda y filtros.
- Límite mensual: definir y consultar el límite; aviso al superarlo.
- Recurrentes: gastos semanales o mensuales que generan la siguiente ocurrencia y cuentan en el presupuesto.
- Metas de ahorro: crear metas, asignar, retirar y transferir fondos reservados sin alterar ingresos ni gastos.
- Historial: eventos agrupados por día y filtros (Todos, Gastos, Pagos, Límite).

## Pruebas

Unitarias de Flutter:

```bash
flutter test
```

Pruebas del backend, con la base de datos de desarrollo levantada:

```bash
cd servidor
npm test
```

Integración, con el backend y un dispositivo o emulador funcionando:

```bash
flutter test integration_test -d <ID_DEL_DISPOSITIVO>
```

Para ejecutar una prueba de integración específica:

```bash
flutter test integration_test/presupuesto_test.dart -d <ID_DEL_DISPOSITIVO>
flutter test integration_test/recurrentes_test.dart -d <ID_DEL_DISPOSITIVO>
```

Consulta [INICIO_RAPIDO.md](INICIO_RAPIDO.md) para preparar el entorno.

## Documentación

- [`INICIO_RAPIDO.md`](INICIO_RAPIDO.md): pasos para levantar el proyecto.
- [`docs/task-01-access.md`](docs/task-01-access.md): Tarea 1, acceso.
- [`docs/task-02-state-tests.md`](docs/task-02-state-tests.md): Tarea 2, estado y pruebas.
- [`docs/task-03-edit-delete.md`](docs/task-03-edit-delete.md): Tarea 3, editar y eliminar.
- [`docs/historias/HU-01-limite-mensual.md`](docs/historias/HU-01-limite-mensual.md): HU-01, límite mensual.
- [`docs/clase-15-heuristicas.md`](docs/clase-15-heuristicas.md): clase 15, evaluación heurística H1-H10.
- [`docs/clase-16-decisiones-interaccion.md`](docs/clase-16-decisiones-interaccion.md): clase 16, decisiones de interacción (filtros).
- [`docs/decisiones-interaccion.md`](docs/decisiones-interaccion.md): Tarea 4 (clase 16), decisiones aplicadas al Historial.
- [`docs/bitacora.md`](docs/bitacora.md): bitácora del proyecto.
- [`docs/issue-07-buscar-filtrar.md`](docs/issue-07-buscar-filtrar.md): buscar y filtrar movimientos.
