# Tarea 3 · Completar el ciclo del elemento: editar y eliminar

Proyecto 2 · Interacción Hombre-Computador · UAGRM
Presupuesto Estudiantil · Flutter + Node/Express + PostgreSQL

---

## Objetivo

Que cada movimiento se pueda **editar** y **eliminar**, cumpliendo la regla:

> Un movimiento pagado no permite modificar su monto.

---

## Decisiones

- **La restricción protege solo el monto.** Si el movimiento está `pagado`, se puede cambiar el concepto y la fecha, pero no el monto. El campo monto aparece bloqueado en la pantalla de edición con el mismo mensaje que devuelve el backend.
- **Eliminar no tiene restricción de estado.** Se puede borrar un movimiento pagado o pendiente, siempre que sea del usuario, y siempre pidiendo confirmación antes.
- **La regla vive en el backend**, en `backend/src/flujos/movimientos/estado.js`, como `editarMontoPermitido(movimiento)`: devuelve `false` cuando `estado === 'pagado'`. El endpoint `PUT /movimientos/:id` la usa junto con una comparación de montos (`Number(monto) !== movimiento.monto`) para decidir si responde 409.
- **El backend no distingue "editó el monto" solo con el cuerpo:** si el monto que llega es igual al guardado, se permite aunque esté pagado; si es distinto y está pagado, responde 409.
- **Editar es de un solo movimiento del usuario:** el `usuario_id` sale del token, igual que en el resto de los endpoints (buscar por `id` y `usuario_id`).

---

## Endpoints nuevos

| Método | Ruta | Cuerpo | Respuesta |
|---|---|---|---|
| PUT | `/movimientos/:id` | header + `{ concepto, monto, fecha }` | 200 `{ movimiento }` · 400 id inválido o datos inválidos · 404 no existe o es de otro · 409 monto de un movimiento pagado |
| DELETE | `/movimientos/:id` | header | 204 sin cuerpo · 400 id inválido · 404 no existe o es de otro |

### Respuestas reales (curl, 08/10/2026)

```
PUT  /movimientos/9  pagado, monto 80 → 99
  409 {"error":"No se puede modificar el monto porque el movimiento ya está pagado"}

PUT  /movimientos/9  pagado, mismo monto, concepto cambiado
  200 {"movimiento":{... concepto:"Café con leche", monto:15.5, estado:"pagado" ...}}

PUT  /movimientos/8  pendiente, monto 15.5 → 99
  200 {"movimiento":{... monto:99 ...}}

PUT  /movimientos/abc
  400 {"error":"Movimiento no válido"}

PUT  sin header Authorization
  401

PUT  /movimientos/9  con el token de otro usuario
  404 {"error":"No encontramos ese movimiento"}

DELETE /movimientos/9  (dueño)
  204

DELETE /movimientos/9  con el token de otro usuario
  404 {"error":"No encontramos ese movimiento"}

DELETE /movimientos/9  (ya borrado)
  404 {"error":"No encontramos ese movimiento"}
```

Verificado además que el cambio **queda guardado en PostgreSQL**: después del PUT, un `GET /movimientos` devuelve el concepto nuevo, y después del DELETE la lista ya no lo incluye.

---

## Cambios en la app

| Archivo | Qué hace |
|---|---|
| `app/lib/comun/servicios/api.dart` | `put(ruta, cuerpo, {token})` y `delete(ruta, {token})` |
| `app/lib/flujos/movimientos/servicios/movimientos_servicio.dart` | `editarMovimiento(...)` y `eliminarMovimiento(token, id)` |
| `app/lib/flujos/movimientos/pantallas/pantalla_editar_gasto.dart` | Pantalla nueva: precarga los datos y guarda los cambios |
| `app/lib/flujos/movimientos/widgets/fila_movimiento.dart` | Menú de la fila con **Editar** y **Eliminar** |
| `app/lib/flujos/movimientos/widgets/confirmacion_eliminar.dart` | Diálogo de confirmación antes de borrar |
| `app/lib/flujos/movimientos/pantallas/pantalla_movimientos.dart` | `editarGasto` y `eliminarGasto`: llaman al servicio, actualizan la lista y muestran snackbar |

El recorrido en la app:

1. En "Mis movimientos", cada fila tiene un menú (**⋮**) con **Editar** y **Eliminar**.
2. **Editar** abre "Editar gasto" con concepto, monto y fecha ya cargados.
   - Si el movimiento está pagado, el campo monto está bloqueado: al tocarlo aparece *"No se puede modificar el monto porque el movimiento ya está pagado."* y no se puede escribir.
   - Concepto y fecha sí se pueden cambiar.
   - Al guardar se llama a `PUT /movimientos/:id`, se vuelve a la lista con el snackbar "Gasto actualizado" y la lista se recarga.
3. **Eliminar** pide confirmación ("¿Eliminar este gasto?" con Cancelar / Eliminar).
   - Al confirmar se llama a `DELETE /movimientos/:id`, la fila se quita de la lista y aparece el snackbar "Gasto eliminado".
4. Errores: 401 → login; 409 → se muestra el mensaje del backend en la pantalla de edición; otros → snackbar sin perder lo que está en pantalla.

---

## Pruebas de la restricción

### Backend (`backend/tests/movimientos/estado.test.js`, con `node --test`)

Incluye la prueba 8: `editarMontoPermitido` devuelve `false` si el movimiento está pagado y `true` si está pendiente.

```
cd backend
npm test        → 8 pruebas pasan
```

### App (`app/test/movimientos_edicion_test.dart`, con `flutter test`)

| N. | Qué prueba |
|---|---|
| 1 | Con el movimiento pagado el campo monto queda bloqueado |
| 2 | Con el movimiento pendiente el campo monto se puede editar |
| 3 | La fila ofrece Editar y Eliminar en el menú |
| 4 | Elegir Eliminar del menú dispara el callback de eliminar |
| 5 | Eliminar pide confirmación antes de borrar |

```
cd app
flutter test        → 18 pruebas pasan (13 anteriores + 5 nuevas)
flutter analyze     → No issues found
```

---

## Quién hizo qué

| Integrante | Parte |
|---|---|
| Ariany | Endpoints `PUT` y `DELETE` (`rutas.js`, `servicio.js`), regla `editarMontoPermitido` en `estado.js`, prueba del backend, respuestas reales con `curl` y este documento |
| Luis | Pantalla "Editar gasto", menú de la fila, diálogo de eliminar, servicios `editarMovimiento`/`eliminarMovimiento`, pruebas de Flutter y README |

---

## Modalidad

P2 con IA (Claude Code). La IA escribió los endpoints, las pantallas y las pruebas a partir de nuestra especificación; las decisiones (qué campos se bloquean, que eliminar sí esté permitido, el mensaje exacto del 409) y la revisión final son nuestras. Todo se probó con `npm test`, `flutter test`, `flutter analyze` y `curl` contra el servidor corriendo y la base en PostgreSQL.
