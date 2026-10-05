# Tarea 2 · Cambio de estado y pruebas (Pendiente → Pagado)

Proyecto 2 · Presupuesto Estudiantil · IHC · UAGRM
Integrantes: Claure Cota Ariany · Franco Moron Luis Enrique

## Objetivo

Que un gasto registrado pueda pasar de **Pendiente** a **Pagado** con la acción **"Marcar como pagado"**. El cambio se guarda en la base, vale una sola vez y está cubierto por pruebas unitarias.

## Regla del cambio

| Estado antes | Acción | Estado después | Si ya está pagado |
|---|---|---|---|
| `pendiente` | Marcar como pagado | `pagado`, con `pagado_en` = fecha y hora del pago | — |
| `pagado` | Marcar como pagado | No cambia | Error 409: "Este movimiento ya está pagado" |
| Otro valor | Marcar como pagado | No cambia | Error 400: "Estado no válido" |

Un gasto nuevo siempre nace `pendiente`. No hay vuelta atrás (de pagado a pendiente): la tarea pide un solo sentido.

La regla vive en `backend/src/flujos/movimientos/estado.js`, separada de la base de datos:

- `ESTADOS = { PENDIENTE: 'pendiente', PAGADO: 'pagado' }`
- `puedeMarcarPagado(movimiento)`: `true` solo si está `pendiente`.
- `marcarComoPagado(movimiento, ahora)`: devuelve un objeto **nuevo** con `estado: 'pagado'` y `pagado_en: ahora`, sin tocar el original. Si no se puede, lanza un error con `codigo` 409 o 400.

## Cambios en la base de datos

Migración `database/migraciones/003_estado_movimiento.sql`:

```sql
ALTER TABLE movimientos
  ADD COLUMN estado VARCHAR(10) NOT NULL DEFAULT 'pendiente'
    CHECK (estado IN ('pendiente', 'pagado')),
  ADD COLUMN pagado_en TIMESTAMP NULL;
```

- Los movimientos que ya existían quedan `pendiente` (por el `DEFAULT`).
- El `CHECK` hace que la base rechace cualquier estado que no sea uno de los dos.
- `pagado_en` queda vacío (`NULL`) hasta que se paga.
- Cómo correrla (con psql o pgAdmin): ver `database/LEEME.md`. La base es `presupuesto_estudiantil`.

## Endpoint

`PATCH /movimientos/:id/pagar`, con header `Authorization: Bearer <token>` (pasa por `requiereSesion`). No lleva cuerpo.

Qué hace, en orden (`backend/src/flujos/movimientos/rutas.js`):

1. `validarIdMovimiento(id)`: si el id no es un entero positivo → **400** "Movimiento no válido".
2. `buscarDeUsuario(id, usuarioId)`: busca por id **y** por el dueño que sale del token. Si no está → **404** "No encontramos ese movimiento". El de otro usuario también da 404, así no se revela que existe.
3. `marcarComoPagado(movimiento, new Date())`: la misma función que prueban los tests. Si ya está pagado → **409**.
4. `marcarPagado(id, usuarioId)`: `UPDATE movimientos SET estado='pagado', pagado_en=NOW() WHERE id=$1 AND usuario_id=$2 AND estado='pendiente' RETURNING ...`. El `AND estado='pendiente'` evita pagar dos veces si llegan dos pedidos al mismo tiempo; en ese caso también responde 409.
5. **200** con el movimiento actualizado.

`GET /movimientos` y `POST /movimientos` también devuelven `estado` y `pagado_en`.

### Respuestas reales (curl, 04/10/2026)

```
PATCH /movimientos/12/pagar
200 {"movimiento":{"id":12,"tipo":"gasto","concepto":"Pasaje micro","monto":2.5,"fecha":"2026-10-04","estado":"pagado","pagado_en":"2026-10-04T17:36:04.380Z"}}

PATCH /movimientos/12/pagar   (otra vez)
409 {"error":"Este movimiento ya está pagado"}

PATCH /movimientos/999999/pagar
404 {"error":"No encontramos ese movimiento"}

PATCH /movimientos/7/pagar    (con el token de otro usuario)
404 {"error":"No encontramos ese movimiento"}

PATCH /movimientos/abc/pagar
400 {"error":"Movimiento no válido"}

PATCH sin token
401 {"error":"Tu sesión terminó, iniciá sesión de nuevo"}
```

`pagado_en` viene en formato ISO y en hora UTC: `17:36Z` son las 13:36 en Bolivia.

Para repetirlas (reemplazar `TOKEN` por el que devuelve `/auth/login` y `12` por un id propio):

```
curl -X PATCH http://localhost:3000/movimientos/12/pagar -H "Authorization: Bearer TOKEN"
```

## Pruebas unitarias del backend

Archivo: `backend/tests/movimientos/estado.test.js`. Usa `node:test` y `node:assert/strict`, que vienen con Node, así que no hay que instalar nada. Prueban la regla sin base de datos ni servidor.

| Nº | Qué prueba | Resultado |
|---|---|---|
| 1 | Un movimiento pendiente pasa a pagado | ✔ Pasa |
| 2 | `pagado_en` queda con la fecha que se le pasa | ✔ Pasa |
| 3 | El objeto original no se modifica (sigue pendiente y con `pagado_en` vacío) | ✔ Pasa |
| 4 | Si ya está pagado, lanza "Este movimiento ya está pagado" con código 409 | ✔ Pasa |
| 5 | Si el estado es raro (`cancelado`), lanza "Estado no válido" con código 400 | ✔ Pasa |
| 6 | `puedeMarcarPagado` da `true` para pendiente y `false` para pagado | ✔ Pasa |
| 7 | `validarIdMovimiento` rechaza `"abc"`, `0` y `-3`, y acepta `5` | ✔ Pasa |

## Cómo ejecutarlas

```
cd backend
npm test
```

## Salida real de `npm test`

```
> presupuesto-estudiantil-backend@1.0.0 test
> node --test

✔ 1. un movimiento pendiente pasa a pagado (1.5198ms)
✔ 2. pagado_en queda con la fecha que se le pasa (0.1863ms)
✔ 3. el objeto original no se modifica (0.1701ms)
✔ 4. si ya está pagado, lanza "Este movimiento ya está pagado" (409) (2.0299ms)
✔ 5. si el estado es raro, lanza "Estado no válido" (400) (1.6215ms)
✔ 6. puedeMarcarPagado da true para pendiente y false para pagado (0.2061ms)
✔ 7. validarIdMovimiento rechaza "abc", 0 y -3 y acepta 5 (0.2873ms)
ℹ tests 7
ℹ suites 0
ℹ pass 7
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 144.6735
```

## Pruebas de Flutter

Archivo: `app/test/movimientos_estado_test.dart`. Usa `flutter_test`, sin instalar nada extra. Cubren el modelo, la fila con su chip y su boton, y el dialogo de confirmacion.

| N. | Que prueba | Resultado |
|---|---|---|
| 1 | El modelo lee estado pendiente y pagado_en vacio | Pasa |
| 2 | El modelo lee estado pagado y pagado_en con fecha (17:36 UTC) | Pasa |
| 3 | Si el backend no manda estado, se toma como pendiente | Pasa |
| 4 | Un pendiente muestra chip Pendiente y el boton Marcar como pagado | Pasa |
| 5 | Un pagado muestra chip Pagado y ya no ofrece el boton | Pasa |
| 6 | Al marcar como pagado, la fila cambia a Pagado y el boton desaparece | Pasa |
| 7 | La confirmacion pide Confirmar o Cancelar y avisa que no se puede deshacer | Pasa |
| 8 | Con Cancelar no se marca como pagado | Pasa |

Las pruebas anteriores (validaciones de concepto y monto, y la de la pantalla de bienvenida) siguen en `app/test/`.

## Como ejecutarlas

```
cd app
flutter test
```

## Salida real de `flutter test`

```
00:00 +0: 1. el modelo lee estado pendiente y pagado_en vacio
00:00 +1: 2. el modelo lee estado pagado y pagado_en con fecha
00:00 +2: 3. si el backend no manda estado, se toma como pendiente
00:00 +3: 4. un pendiente muestra chip Pendiente y el boton Marcar como pagado
00:00 +4: 5. un pagado muestra chip Pagado y ya no ofrece el boton
00:00 +5: 6. al marcar como pagado, la fila cambia a Pagado sin boton
00:00 +6: 7. la confirmacion pide Confirmar o Cancelar y avisa que no se deshace
00:00 +7: 8. con Cancelar no se marca como pagado
00:02 +11: All tests passed!
```

## Quién hizo qué

| Integrante | Parte |
|---|---|
| Ariany | Migración 003, lógica del estado (`estado.js`), validación del id, endpoint `PATCH /movimientos/:id/pagar`, `estado`/`pagado_en` en GET y POST, pruebas unitarias del backend y este documento |
| Luis | Pantallas Flutter (mostrar Pendiente/Pagado y el botón "Marcar como pagado"), pruebas de Flutter, README y video |

## Modalidad

**P2 con IA (Claude Code).** Lo usamos para:
- escribir la migración, la regla del estado y el endpoint a partir de nuestra especificación (mensajes, códigos 400/404/409, consultas con `$1, $2`);
- armar las pruebas unitarias con el runner de Node;
- probar el endpoint con curl y documentar las respuestas reales.
