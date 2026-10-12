# UniBudget - Presupuesto Estudiantil

App móvil para que estudiantes organicen sus ingresos y gastos.
Incluye:
- **Tarea 1:** el manejo de acceso (registro, inicio y cierre de sesión, recuperación de contraseña, sesión conservada, una ruta pública y una ruta privada, "Mis movimientos").
- **Tareas 2 y 3:** el ciclo completo de un movimiento (crear, marcar como pagado, editar y eliminar).
- **HU-01:** el límite mensual de gastos.

## Tecnologías

- **App:** Flutter (Dart), probada en el emulador de Android Studio (Pixel 6a)
- **API:** Node.js + Express
- **Base de datos:** PostgreSQL

```
App Flutter  →  API (servidor/)  →  PostgreSQL
```

## Requisitos

- Flutter y Dart
- Android Studio con un emulador Android
- Node.js (v18 o superior)
- PostgreSQL

## Cómo iniciar el proyecto

### 1. Base de datos

En pgAdmin (o `psql`) crea la base y las tablas:

```sql
CREATE DATABASE presupuesto_estudiantil;
```

Conéctate a esa base y ejecuta el contenido de `base_datos/esquema.sql`.

Si tu base se creó antes de la HU-01, no la borres: ejecuta solo `base_datos/cambios/001_limite_mensual.sql`, que agrega la columna `limite_mensual`.

### 2. Servidor (API)

```powershell
cd servidor
copy .env.example .env
```

Abre `servidor/.env` y escribe tu contraseña de PostgreSQL en `DB_PASSWORD`. Luego:

```powershell
npm install
node semilla.js
node servidor.js
```

- `node semilla.js` carga el usuario de prueba (ver más abajo).
- `node servidor.js` deja la API en `http://localhost:3000`. Déjala corriendo.
- Comprobación: abrir `http://localhost:3000/ping` debe mostrar `{"mensaje":"Servidor funcionando"}`.

### 3. App Flutter

Con el emulador de Android encendido, desde la raíz del proyecto:

```powershell
flutter pub get
flutter run
```

La app se conecta a `http://10.0.2.2:3000` (en el emulador, `10.0.2.2` es el `localhost` de la PC). Esta dirección está en `lib/configuracion/constantes.dart`.

## Usuario de prueba (semilla)

| Correo | Contraseña |
|---|---|
| prueba@correo.com | 123456 |

## Recuperación de contraseña

No se envía correo real. Al pedir el código, la app lo muestra en pantalla (6 dígitos, válido 15 minutos).

## Pruebas unitarias

Desde la raíz del proyecto:

```powershell
flutter test
```

Las pruebas están en `test/`:

- `movimiento_test.dart`: estado inicial, transición `pendiente → pagado`, rechazo de transición inválida y conservación de datos.
- `restriccion_monto_test.dart`: un movimiento pagado no permite modificar su monto.
- `limite_validaciones_test.dart`: el límite mensual se acepta si es mayor a 0 y se rechaza si está vacío, en 0, es negativo o tiene letras.

Las pruebas del servidor (la misma regla del límite) se corren desde `servidor/`:

```powershell
npm test
```

## Límite mensual (HU-01)

- En "Mis movimientos", el ícono de la alcancía abre "Límite del mes".
- El límite tiene que ser un número mayor a 0. Si no lo es, el mensaje "El límite debe ser un número mayor a 0" aparece debajo del campo.
- Se guarda en `usuarios.limite_mensual` y se lee con `GET /limite` y `PUT /limite`, con sesión.

## Documentación

- [`docs/task-01-access.md`](docs/task-01-access.md): Tarea 1, acceso.
- [`docs/task-02-state-tests.md`](docs/task-02-state-tests.md): Tarea 2, estado y pruebas.
- [`docs/task-03-edit-delete.md`](docs/task-03-edit-delete.md): Tarea 3, editar y eliminar.
- [`docs/historias/HU-01-limite-mensual.md`](docs/historias/HU-01-limite-mensual.md): HU-01, límite mensual.
- [`docs/bitacora.md`](docs/bitacora.md): bitácora del proyecto.
- [`docs/issue-07-buscar-filtrar.md`](docs/issue-07-buscar-filtrar.md): Buscar y filtrar movimientos.