# Presupuesto Estudiantil

App móvil para que estudiantes universitarios organicen sus ingresos, gastos y presupuesto del mes.
Proyecto 2 · Interacción Hombre-Computador · UAGRM

Integrantes: Claure Cota Ariany · Franco Moron Luis Enrique

## Cómo está armado

```
App Flutter (celular)  ──HTTP/JSON──▶  Backend Node/Express  ──SQL──▶  PostgreSQL
```

## Requisitos

| Herramienta | Versión | Para qué |
|---|---|---|
| Node.js | 18 o más | Backend |
| PostgreSQL | 16 o más | Base de datos |
| Flutter | 3.x con Dart 3 | App Android |
| Android SDK + emulador | API 36 | Correr la app |

## Cómo correrlo

**1. Base de datos (solo la primera vez).** Desde la carpeta del proyecto:

```
createdb -U postgres presupuesto_estudiantil
psql -U postgres -d presupuesto_estudiantil -f database/migraciones/001_acceso.sql
psql -U postgres -d presupuesto_estudiantil -f database/migraciones/002_movimientos.sql
psql -U postgres -d presupuesto_estudiantil -f database/migraciones/003_estado_movimiento.sql
```

Si `psql` no está en el PATH, usar la ruta completa, por ejemplo
`"C:\Program Files\PostgreSQL\18\bin\psql.exe"`. Las migraciones se corren **en orden y una sola vez**.

**2. Backend.** Desde `backend/`:

```
npm install
copy .env.ejemplo .env
```

Abrir `.env` y poner la clave de PostgreSQL:

```
DATABASE_URL=postgres://usuario:clave@localhost:5432/presupuesto_estudiantil
PUERTO=3000
```

Después, cada vez que se quiera usar la app:

```
npm run dev
```

Tiene que decir `Servidor escuchando en el puerto 3000`. `npm run dev` se reinicia solo al guardar cambios; `npm start` es el arranque normal.

**3. App.** Con el emulador abierto, desde `app/`:

```
flutter pub get
flutter run
```

La app se conecta a `http://10.0.2.2:3000`, que es la PC vista desde el emulador. Para un celular real hay que cambiar `urlBase` en `app/lib/comun/servicios/api.dart` por la IP de la PC.

## Pantallas

| Ruta | Pantalla |
|---|---|
| `/` | Bienvenida |
| `/registro` | Crear cuenta |
| `/login` | Iniciar sesión |
| `/recuperar` | Recuperar contraseña (muestra el código) |
| `/nueva-contrasena` | Poner contraseña nueva con el código |
| `/inicio` | Inicio (requiere sesión) |
| `/movimientos` | Mis movimientos: lista de gastos con su estado (requiere sesión) |
| `/movimientos/nuevo` | Nuevo gasto: concepto, monto y fecha (requiere sesión) |

Si ya hay una sesión guardada, la app abre directo en Inicio.

### Probar una ruta escribiéndola

Con el emulador abierto, en una terminal (reemplazar `inicio` por cualquier ruta de la tabla):

```
adb shell am start -a android.intent.action.VIEW -d "presupuesto://app/inicio"
```

Sin sesión, `/inicio` redirige al login con "Tu sesión terminó, iniciá sesión de nuevo". Las rutas públicas se abren igual.

La sesión (token) dura **7 días**: se guarda en la tabla `sesiones` con su `expira_en`, y el backend la rechaza cuando vence.

## Pendiente y pagado

Cada movimiento tiene un estado: `pendiente` (nace así) o `pagado`. En "Mis movimientos", cada fila muestra un chip con el estado y, si está pendiente, el botón **Marcar como pagado** con una confirmación. Al confirmar, la app llama a `PATCH /movimientos/:id/pagar`, el backend guarda `estado = 'pagado'` con su `pagado_en`, y la fila pasa a Pagado. Es de un solo sentido: no hay vuelta atrás.

## Pruebas

### Backend

Las pruebas unitarias de la regla del estado (pendiente → pagado) no necesitan base de datos ni servidor:

```
cd backend
npm test
```

Usa el runner de Node (`node --test`), sin instalar nada. Son 7 pruebas de `tests/movimientos/estado.test.js`.

### App Flutter

Las pruebas del modelo, del chip Pendiente/Pagado, del botón "Marcar como pagado" y de su confirmación:

```
cd app
flutter test
```

Son 8 pruebas de `test/movimientos_estado_test.dart` y 3 de `test/movimientos_validaciones_test.dart` y `test/widget_test.dart`.

## Documentación

- [Tarea 1 · Acceso](docs/task-01-access.md)
- [Tarea 2 · Cambio de estado y pruebas](docs/task-02-state-tests.md)
- [Sistema visual](docs/sistema-visual.md): colores, tipografía y espaciado en múltiplos de 8
- [Backend](backend/LEEME.md): endpoints
- [Base de datos](database/LEEME.md): migraciones
- [Bitácora](docs/bitacora.md): qué se hizo en cada paso
- [CLAUDE.md](CLAUDE.md): guía para trabajar con IA en este repo

## Modalidad

**P2 con IA (Claude Code).** Lo usamos para escribir las migraciones, el backend, las pantallas y las pruebas a partir de nuestra especificación, y para probar los endpoints con `curl` documentando las respuestas reales. Ver `docs/bitacora.md`.