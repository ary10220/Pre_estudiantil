# CLAUDE.md

Guía para trabajar con IA (Claude Code) en este repositorio.

Proyecto 2 · Interacción Hombre-Computador · UAGRM
Presupuesto Estudiantil · Flutter + Node/Express + PostgreSQL

---

## Qué es este proyecto

App Android para que estudiantes universitarios organicen sus gastos del mes. Tres partes:

```
app/       App Flutter (celular)      ──HTTP/JSON──▶
backend/   API Node + Express                      ──SQL──▶  PostgreSQL
database/  Migraciones SQL
docs/      Documentación por tarea
```

El backend siempre va en el medio: la app nunca habla directo con la base, para que la clave de PostgreSQL no viaje dentro del APK.

## Cómo está repartido el trabajo

| Parte | Quién |
|---|---|
| Base de datos, migraciones, endpoints, pruebas del backend, docs | Ariany |
| Pantallas Flutter, chip de estado, botón de pagar, pruebas de la app, README, video | Luis |

Si vas a tocar una parte, mira primero quién la hizo. Los dos hacemos cambios en `app/`.

---

## Comandos

```bash
# Backend (desde backend/)
npm install
npm run dev      # nodemon, reinicia al guardar
npm start        # arranque normal
npm test         # node --test, 7 pruebas

# App (desde app/)
flutter pub get
flutter run
flutter test     # 13 pruebas
flutter analyze  # debe decir "No issues found!"
```

Probar una ruta sin navegar por la app (con el emulador abierto):

```bash
adb shell am start -a android.intent.action.VIEW -d "presupuesto://app/movimientos"
```

## Base de datos

La base se llama `presupuesto_estudiantil`. Las credenciales van en `backend/.env`, que **nunca** se sube (está en `.gitignore`).

Las migraciones se corren **en orden y una sola vez** cada una:

| Orden | Archivo | Qué hace |
|---|---|---|
| 1 | `001_acceso.sql` | `usuarios`, `sesiones`, `recuperaciones` |
| 2 | `002_movimientos.sql` | `movimientos` |
| 3 | `003_estado_movimiento.sql` | Agrega `estado` y `pagado_en` |

Si una migración ya corrió, PostgreSQL avisa que la columna existe: no hace falta volver a correrla.

---

## Reglas del proyecto

Estas son decisiones que ya tomamos. No las cambies sin avisar.

### La regla del estado vive en el backend

`backend/src/flujos/movimientos/estado.js` tiene la lógica de pendiente → pagado, **sin base de datos**, para poder probarla sola. El endpoint y las pruebas usan esa misma función.

- De un solo sentido: `pendiente` → `pagado`. No hay vuelta atrás.
- `marcarComoPagado(movimiento, ahora)` devuelve un objeto **nuevo**; nunca muta el que recibe.
- Si ya está pagado: error 409 "Este movimiento ya está pagado".
- Si el estado es raro: error 400 "Estado no válido".
- La base además tiene `CHECK (estado IN ('pendiente','pagado'))` y el `UPDATE` lleva `AND estado='pendiente'` para que dos pedidos juntos no paguen dos veces.

### `usuario_id` siempre sale del token

Nunca del cuerpo de la petición. El middleware `requiereSesion` lo deja en `req.usuario`. Así un usuario no puede leer ni pagar movimientos de otro (eso da 404, no 403, para no revelar que existe).

### Los mensajes de error son los mismos en la app y en el backend

Si cambias un mensaje en el backend, cámbialo también en `app/lib/flujos/*/servicios/validaciones.dart` y al revés. Hay pruebas que comparan los dos.

### Espaciado en múltiplos de 8

Usa las constantes de `app/lib/comun/tema/espaciado.dart`: `espacio8`, `espacio16`, `espacio24`, `espacio32`, `espacio48`. No inventes `SizedBox(height: 12)`. La única excepción es `radioControl = 12`, que es un radio, no un espacio. Ver `docs/sistema-visual.md`.

### La app siempre pide la lista al backend

En "Mis movimientos" lo que se ve es lo que está guardado. No confíes en un estado local después de guardar o pagar. Al marcar como pagado sí se actualiza la fila en memoria para que la respuesta sea inmediata, pero la lista se vuelve a pedir al recargar.

### Errores de la app

- 401 → mandar al login con el mensaje del backend.
- Otro error con lista ya cargada → snackbar, no perder lo que está en pantalla.
- Error con lista vacía → mensaje en la pantalla con "deslizá para intentar de nuevo".
- Botón nunca gris: valida al tocarlo y explica qué falta.

---

## Antes de dar algo por terminado

```bash
cd backend && npm test        # 7 deben pasar
cd app && flutter test       # 13 deben pasar
cd app && flutter analyze    # "No issues found!"
```

Y pruébalo a mano en el emulador: levantar backend, `flutter run`, crear cuenta, guardar un gasto, marcarlo como pagado, cerrar la app y volver a abrir para confirmar que el estado sigue ahí.

Si tocaste el backend o la base, actualiza `docs/task-0X-*.md` con las respuestas reales que da el endpoint, no solo con lo que debería dar.

---

## Endpoints

Base: `http://localhost:3000`. Desde el emulador la app usa `http://10.0.2.2:3000` (la PC vista desde el emulador), definido en `app/lib/comun/servicios/api.dart`.

| Método | Ruta | Cuerpo | Respuesta |
|---|---|---|---|
| POST | `/auth/registro` | `{ nombre, correo, contrasena }` | 201 `{ usuario }` |
| POST | `/auth/login` | `{ correo, contrasena }` | 200 `{ token, usuario }` |
| POST | `/auth/recuperar` | `{ correo }` | 200 `{ codigo }` |
| POST | `/auth/cambiar-contrasena` | `{ correo, codigo, nueva }` | 200 `{ mensaje }` |
| GET | `/sesion/yo` | header `Authorization: Bearer <token>` | 200 `{ usuario }` |
| POST | `/sesion/salir` | header | 204 |
| POST | `/movimientos` | header + `{ concepto, monto, fecha }` (`AAAA-MM-DD`) | 201 `{ movimiento }` |
| GET | `/movimientos` | header | 200 `{ movimientos: [...] }` (el más nuevo arriba) |
| PATCH | `/movimientos/:id/pagar` | header | 200 `{ movimiento }` · 400 id inválido · 404 no existe o es de otro · 409 ya pagado |

Los errores siempre vienen como `{ "error": "mensaje para mostrar" }`.

## Rutas de la app

| Ruta | Pantalla |
|---|---|
| `/` | Bienvenida |
| `/registro` | Crear cuenta |
| `/login` | Iniciar sesión |
| `/recuperar` | Recuperar contraseña |
| `/nueva-contrasena` | Contraseña nueva con el código |
| `/inicio` | Inicio (requiere sesión) |
| `/movimientos` | Mis movimientos (requiere sesión) |
| `/movimientos/nuevo` | Nuevo gasto (requiere sesión) |

Las rutas privadas revisan la sesión con `app/lib/comun/servicios/guardia.dart`.

---

## Dónde está cada cosa

| Archivo | Qué hace |
|---|---|
| `backend/src/servidor.js` | Arranca Express, monta las rutas, errores en JSON |
| `backend/src/bd.js` | Pool de conexiones a PostgreSQL |
| `backend/src/comun/middleware/requiereSesion.js` | Revisa el token antes de rutas protegidas |
| `backend/src/flujos/acceso/rutas.js` | Registro, login, recuperar, cambiar contraseña |
| `backend/src/flujos/acceso/rutasSesion.js` | `/sesion/yo`, `/sesion/salir` |
| `backend/src/flujos/movimientos/rutas.js` | `POST`, `GET` y `PATCH /movimientos/:id/pagar` |
| `backend/src/flujos/movimientos/servicio.js` | Consultas a la tabla `movimientos` |
| `backend/src/flujos/movimientos/estado.js` | La regla de pendiente → pagado |
| `backend/src/flujos/movimientos/validaciones.js` | `validarConcepto`, `validarMonto`, `validarIdMovimiento` |
| `app/lib/main.dart` | Arranca la app: con sesión abre Inicio, sin sesión la Bienvenida |
| `app/lib/rutas.dart` | El mapa de rutas |
| `app/lib/comun/servicios/api.dart` | `get`, `post`, `patch` + `ErrorApi` |
| `app/lib/comun/servicios/guardia.dart` | `leerTokenOIrAlLogin`, `mandarAlLogin` |
| `app/lib/comun/servicios/sesion.dart` | Guarda y lee el token |
| `app/lib/comun/formato.dart` | `fechaCorta`, `fechaParaApi`, `montoEnBs` |
| `app/lib/comun/tema/` | Colores, espaciado y tipografía |
| `app/lib/flujos/movimientos/modelos/movimiento.dart` | Modelo con `estado` y `pagadoEn` |
| `app/lib/flujos/movimientos/widgets/fila_movimiento.dart` | Fila con el chip de estado y el botón de pagar |
| `app/lib/flujos/movimientos/widgets/confirmacion_pagar.dart` | Diálogo Confirmar / Cancelar |

## Pruebas

| Archivo | Cuántas | Qué cubren |
|---|---|---|
| `backend/tests/movimientos/estado.test.js` | 7 | La regla del estado y `validarIdMovimiento` |
| `app/test/movimientos_estado_test.dart` | 10 | Modelo, chip, botón, confirmación y datos conservados |
| `app/test/movimientos_validaciones_test.dart` | 2 | Mensajes de concepto y monto |
| `app/test/widget_test.dart` | 1 | Arranque sin sesión |

## Documentación

| Archivo | Qué hay |
|---|---|
| `docs/project-card.md` | Datos de la entrega |
| `docs/task-01-access.md` | Tarea 1: acceso |
| `docs/task-02-state-tests.md` | Tarea 2: cambio de estado y pruebas |
| `docs/sistema-visual.md` | Colores, tipografía y espaciado |
| `docs/bitacora.md` | Qué se hizo en cada paso, con qué se probó |
| `backend/LEEME.md` | Endpoints del backend |
| `database/LEEME.md` | Migraciones |