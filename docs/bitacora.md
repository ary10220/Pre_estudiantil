# Bitácora · Presupuesto Estudiantil

Proyecto 2 · Interacción Hombre-Computador · UAGRM
Integrantes: Claure Cota Ariany (Ariany) · Franco Moron Luis Enrique (Luis)

Este documento registra qué se hizo en cada paso, con qué se probó y qué queda pendiente. Va por orden de los commits.

---

## 1. Base del proyecto

Se creó el repositorio con la estructura de tres partes:

```
app/       App Flutter (celular)
backend/   API Node + Express
database/  Migraciones de PostgreSQL
docs/      Documentación de cada tarea
```

Decisión de arquitectura: la app nunca habla directo con PostgreSQL. Todo pasa por el backend, porque si la app se conectara a la base la clave viajaría dentro del APK y cualquiera podría sacarla del teléfono.

Commits: `index.html`, `inicio`.

---

## 2. Tarea 1 · Acceso (registro, login, recuperación)

**Ariany — base de datos, backend y pantallas de acceso**

- Diseño de las tablas `usuarios`, `sesiones` y `recuperaciones` (migración `001_acceso.sql`).
- `POST /auth/registro`, `POST /auth/login`, `POST /auth/recuperar` y `POST /auth/cambiar-contrasena`.
- Contraseñas con bcrypt (costo 10): nunca se guarda la contraseña, solo un hash.
- Token guardado en la tabla `sesiones`, vence a los 7 días. Se puede cerrar una sesión borrando la fila.
- Middleware `requiereSesion`: revisa el token antes de cada ruta protegida y responde 401 si no existe o venció.
- Recuperación con código de 6 dígitos que vence a los 15 minutos y se usa una sola vez. La app lo muestra en pantalla en vez de mandarlo por correo, porque la tarea no exige correo real y el flujo es el mismo.
- Pantallas Flutter: Bienvenida, Login, Registro, Recuperar, Nueva contraseña, Inicio.

Decisiones que vale la pena recordar:

| Decisión | Por qué |
|---|---|
| Backend en el medio | La clave de la base no sale del servidor (`.env`, que no se sube). |
| bcrypt costo 10 | Si alguien roba la base no ve las contraseñas. |
| Token en tabla `sesiones` | Permite cerrar sesiones y cerrar todas al cambiar la contraseña. |
| Mismo mensaje si el correo no existe o la contraseña está mal | "El correo o la contraseña no coinciden" no revela qué correos tienen cuenta. |
| Errores debajo de cada campo | El usuario ve qué corregir y dónde. |
| Botón siempre activo | Valida al tocarlo y explica qué falta, en vez de quedar gris sin decir por qué. |

Commits: `e4febaf tarea 1: acceso (bd, backend y pantallas de login, registro y recuperacion)`, `e1d3af5 inicio`, `8ff1e8d movimiento`.

---

## 3. Tarea 1 (parte Luis) · Flujo de movimientos

**Luis — pantallas de movimientos**

- `POST /movimientos` y `GET /movimientos`. El `usuario_id` sale del token, nunca del cuerpo: cada usuario ve solo lo suyo.
- Migración `002_movimientos.sql` con la tabla `movimientos` y su índice por usuario.
- Pantallas "Mis movimientos" (lista) y "Nuevo gasto" (concepto, monto, fecha).
- Validaciones en la app con los mismos mensajes que el backend, para que se sienta lo mismo en los dos lados.
- El monto acepta coma o punto: en Bolivia se escribe `25,50`.

Commit: `8ff1e8d movimiento`.

---

## 4. Tarea 2 · Cambio de estado (Pendiente → Pagado)

Esta tarea está partida entre los dos. La regla vive en el backend; la pantalla que la muestra vive en la app.

### 4.1 Ariany — datos y backend

- **Migración `003_estado_movimiento.sql`:** agrega `estado VARCHAR(10) NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente','pagado'))` y `pagado_en TIMESTAMP NULL`. Los movimientos que ya existían quedan `pendiente` por el default, y el `CHECK` hace que la base rechace cualquier otro estado.
- **`backend/src/flujos/movimientos/estado.js`:** la regla, sin base de datos, para poder probarla sola.
  - `ESTADOS = { PENDIENTE: 'pendiente', PAGADO: 'pagado' }`
  - `puedeMarcarPagado(movimiento)`: `true` solo si está `pendiente`.
  - `marcarComoPagado(movimiento, ahora)`: devuelve un objeto **nuevo** con `estado: 'pagado'` y `pagado_en: ahora`, sin tocar el original. Si ya está pagado lanza error 409; si el estado es raro, error 400.
- **`PATCH /movimientos/:id/pagar`:** no lleva cuerpo.
  1. `validarIdMovimiento(id)`: si no es entero positivo → **400** "Movimiento no válido".
  2. `buscarDeUsuario(id, usuarioId)`: busca por id **y** por el dueño del token. Si no está → **404** "No encontramos ese movimiento". El de otro usuario también da 404, así no se revela que existe.
  3. `marcarComoPagado(...)`: la misma función que prueban los tests → **409** si ya estaba pagado.
  4. `marcarPagado(id, usuarioId)`: `UPDATE ... WHERE id=$1 AND usuario_id=$2 AND estado='pendiente' RETURNING ...`. El `AND estado='pendiente'` evita pagar dos veces si llegan dos pedidos juntos; en ese caso también responde 409.
  5. **200** con el movimiento ya actualizado.
- **7 pruebas** en `backend/tests/movimientos/estado.test.js` con `node --test` (viene con Node, no hay que instalar nada): pendiente pasa a pagado, `pagado_en` queda con la fecha pasada, el original no se modifica, 409 si ya estaba pagado, 400 si el estado es raro, `puedeMarcarPagado`, y `validarIdMovimiento`.
- **Documentación** de la tarea con las respuestas reales del endpoint.
- **Bitácora** y **CLAUDE.md** de este repositorio.

### 4.2 Luis — pantalla y pruebas

- **Modelo `Movimiento`:** ahora lee `estado` y `pagado_en` del JSON, con `esPendiente` / `esPagado` y `copyWith`. Si el backend no manda `estado`, se toma como `pendiente`.
- **`Api.patch`:** método nuevo en `app/lib/comun/servicios/api.dart`, que solo tenía `get` y `post`.
- **`MovimientosServicio.marcarPagado(token, id)`:** llama a `PATCH /movimientos/:id/pagar`.
- **Chip de estado** en cada fila: naranja "Pendiente" o verde "Pagado".
- **Botón "Marcar como pagado"** en cada fila pendiente, con un diálogo de confirmación que avisa que la acción no se puede deshacer. El botón desaparece cuando el movimiento ya está pagado.
- **Actualización en pantalla:** al confirmar, la fila pasa a Pagado sin volver a pedir toda la lista, y sale un snackbar "Movimiento marcado como pagado".
- **Errores:** si el backend responde 401 se vuelve al login; cualquier otro error se muestra en un snackbar sin perder la lista.
- **10 pruebas** en `app/test/movimientos_estado_test.dart` con `flutter_test`:

| N. | Qué prueba |
|---|---|
| 1 | El modelo lee estado pendiente y `pagado_en` vacío |
| 2 | El modelo lee estado pagado y `pagado_en` con fecha |
| 3 | Si el backend no manda estado, se toma como pendiente |
| 4 | Un pendiente muestra chip Pendiente y el botón Marcar como pagado |
| 5 | Un pagado muestra chip Pagado y ya no ofrece el botón |
| 6 | Al marcar como pagado, la fila cambia a Pagado y el botón desaparece |
| 7 | La confirmación pide Confirmar o Cancelar y avisa que no se puede deshacer |
| 8 | Con Cancelar no se marca como pagado |
| 9 | Un gasto recien creado nace Pendiente y sin pagado_en |
| 10 | Al marcar como pagado se conservan concepto, monto y fecha |

- **README:** sección "Pruebas" con los dos comandos, y sección "Pendiente y pagado" que explica el flujo de un solo sentido.

---

## 5. Tarea 3 · Completar el ciclo: editar y eliminar

Ariany (backend, pruebas y documentación) y Luis (pantallas, servicios y pruebas de la app).

### 5.1 Ariany — backend

- **`PUT /movimientos/:id`** con `{ concepto, monto, fecha }`, mismo recorrido que pagar: validar id (400), buscar por id **y** `usuario_id` del token (404, también para movimientos de otro), y responder 200 con el movimiento actualizado.
- **`DELETE /movimientos/:id`:** misma validación y 404; responde **204** sin cuerpo. Borrar el mismo dos veces da 404.
- **La regla nueva vive en `estado.js`:** `editarMontoPermitido(movimiento)` devuelve `false` si `estado === 'pagado'`. El `PUT` lo usa con una comparación de montos: si el monto que llega es distinto al guardado y el movimiento está pagado → **409** "No se puede modificar el monto porque el movimiento ya está pagado". Concepto y fecha sí se pueden editar.
- **Prueba 8** en `backend/tests/movimientos/estado.test.js`: pagado no permite cambiar el monto, pendiente sí.
- Arreglos que aparecieron en el camino: `module.exports` de `servicio.js` y de `rutas.js` no incluían las funciones nuevas (y `module.exports` de `rutas.js` estaba a mitad de archivo), y dos archivos quedaron con UTF-8 doble codificado (`sesiÃ³n`) tras editarlos; se corrigió todo antes de probar.

### 5.2 Luis — app

- **`Api.put(ruta, cuerpo, {token})` y `Api.delete(ruta, {token})`** en `api.dart`, con `Uri.parse('$urlBase$ruta')`.
- **`MovimientosServicio.editarMovimiento` y `eliminarMovimiento`**, con los mismos mensajes de error que el backend.
- **Pantalla "Editar gasto"** (`pantalla_editar_gasto.dart`): precarga concepto, monto y fecha. Si el movimiento está pagado, el campo monto queda **solo lectura** y al tocarlo avisa "No se puede modificar el monto porque el movimiento ya está pagado".
- **Menú (⋮) en cada fila** con **Editar** y **Eliminar** (en vez de dos botones, para no desbordar la fila) y **diálogo de confirmación** antes de borrar ("Cancelar" / "Eliminar").
- Al editar, vuelve a la lista con snackbar "Gasto actualizado" y la recarga; al eliminar, quita la fila de la lista y muestra "Gasto eliminado".
- **5 pruebas nuevas** en `app/test/movimientos_edicion_test.dart`.

Decisiones que vale la pena recordar:

| Decisión | Por qué |
|---|---|
| Bloquear solo el monto, no toda la edición | La consigna dice "un movimiento pagado no permite modificar su monto": concepto y fecha sí se pueden corregir. |
| 409 solo si el monto cambió | Si el monto que llega es igual al guardado, no hay nada que proteger; así un "guardar" sin tocar el monto no falla. |
| Eliminar sin restricción de estado | La restricción es sobre modificar el monto; borrar es otra decisión y la app lo confirma antes. |
| Editar se abre con `MaterialPageRoute`, sin ruta nueva | No es una pantalla a la que se navegue de arriba; se llega desde la fila. |
| Menú ⋮ en la fila | Dos botones de texto más los desbordaban en pantallas angostas. |

Pruebas automáticas: **8** en el backend y **18** en la app. Respuestas reales del endpoint, documentadas en `docs/task-03-editar-eliminar.md`: 409 con monto distinto en un pagado, 200 con el mismo monto, 200 en un pendiente, 204 al borrar, 404 de otro usuario y de un id ya borrado, 400 con id `abc`, 401 sin token. Todo verificado además contra PostgreSQL: los cambios quedan guardados en la base.

---

## 6. Cómo se probó

### Pruebas automáticas

```
cd backend && npm test        →  8 pasan, 0 fallan
cd app && flutter test       →  18 pasan (10 de T2 + 5 de T3 + 3 anteriores), 0 fallan
cd app && flutter analyze    →  No issues found
```

### Pruebas manuales en el emulador

Con backend arriba (`Servidor escuchando en el puerto 3000`) y el emulador Android 17 abierto:

1. Crear cuenta e iniciar sesión → abre Inicio con el saludo.
2. "Mis movimientos" → "Registrar gasto" → poner concepto, monto y fecha → "Guardar gasto".
   Verificado en PostgreSQL: `id=2, concepto='Cafe', monto=15.50, estado='pendiente'`.
3. La fila aparece con chip **Pendiente** y botón **Marcar como pagado**.
4. Tap en el botón → aparece la confirmación con Cancelar / Confirmar.
5. "Confirmar" → la fila pasa a chip **Pagado**, el botón desaparece, sale el snackbar.
   Verificado en PostgreSQL: `estado='pagado', pagado_en='2026-10-05 18:16:00'`.
6. Cerrar la app por completo y volver a abrir → la fila sigue en **Pagado**.
   Esto confirma que el estado quedó guardado, no solo en memoria.
7. Sin sesión, `/inicio` redirige al login con "Tu sesión terminó, iniciá sesión de nuevo".

### Pruebas del endpoint con `curl`

Documentadas en `docs/task-02-state-tests.md`: 200 al pagar, 409 al pagar dos veces, 404 si no existe o es de otro usuario, 400 si el id no es válido, 401 sin token.

Para editar y eliminar (`docs/task-03-editar-eliminar.md`): 409 al cambiar el monto de un movimiento pagado, 200 al editarlo con el mismo monto o a un pendiente, 204 al borrar, 404 de otro usuario y de un id ya borrado, 400 con id `abc`, 401 sin token. Verificado además que el cambio queda en PostgreSQL: después del `PUT`, un `GET` devuelve el concepto nuevo, y después del `DELETE` la lista ya no lo incluye.

`pagado_en` viene en ISO y en UTC: `17:36Z` son las 13:36 en Bolivia.

---

## 7. Problemas que encontramos

| Problema | Qué pasaba | Cómo se resolvió |
|---|---|---|
| APK viejo en el emulador | El login funcionaba pero la app crasheaba al navegar: `Could not find a generator for route RouteSettings("/inicio", null)`. El APK instalado venía de una versión anterior del código (rutas viejas). | Recompilar desde el código clonado (`flutter build apk --debug`) y reinstalar con `adb install -r`. |
| `npm install` bloqueó `bcrypt` | npm 11 avisa que hay scripts de instalación sin aprobar. | Se verificó que `require('bcrypt')` funciona con el binario precompilado; no hizo falta compilar nada. |
| Sin `psql` en el PATH | `psql` no se reconocía en Windows. | Se usó la ruta completa `"C:\Program Files\PostgreSQL\18\bin\psql.exe`. |
| Flutter doctor avisa del SDK con espacios | `C:\Users\Gabbonet PC\...` tiene un espacio y el Android SDK avisa que puede dar problemas con el NDK. | Para este proyecto no dio ningún problema; el warning sigue ahí. |
| No se podía escribir con `adb shell input text` a veces | El texto se duplicaba al cambiar de campo por el teclado en pantalla. | Se reinicia la app antes de escribir y se usan los `bounds` del `uiautomator dump` para tocar los elementos correctos. |

---

## 8. Modalidad

**P2 con IA (Claude Code).** Lo usamos para:

- escribir las migraciones, la regla del estado y el endpoint a partir de nuestra especificación (mensajes, códigos 400/404/409, consultas con `$1, $2`);
- armar las pruebas unitarias del backend con el runner de Node y las de la app con `flutter_test`;
- probar los endpoints con `curl` y documentar las respuestas reales;
- revisar que los espaciados de la pantalla respeten la retícula de 8.

Lo que NO hizo la IA: las decisiones de diseño (dónde vive la regla, por qué el estado es de un solo sentido, qué se muestra en cada fila) y la revisión final. Cada cambio se probó a mano antes de darlo por terminado.

---

## 9. Qué falta

- **Video de 2 minutos** (grabado por Luis).
- **Bitácora final** con los aportes de cada integrante para la entrega.