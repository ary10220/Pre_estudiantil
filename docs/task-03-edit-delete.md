# Tarea 3 - Completar el ciclo del elemento

**Producto:** Presupuesto Estudiantil (UniBudget)
**Entidad:** Movimiento
**Restricción por estado:** un movimiento pagado no permite modificar su monto.

## Funcionalidad

| Requisito | Implementación |
|---|---|
| Editar | Botón de lápiz → `PantallaNuevoMovimiento` en modo edición → `PUT /movimientos/:id` |
| Eliminar con confirmación | Botón de papelera → diálogo "¿Deseas eliminar...?" → `DELETE /movimientos/:id` |
| Restricción según estado | Pagado => monto bloqueado (modelo, interfaz y servidor) |

## La restricción en tres capas

1. **Modelo Flutter** (`Movimiento.editar`): lanza `StateError` si el movimiento está pagado y el monto cambia. Es lo que cubren las pruebas.
2. **Interfaz:** en un movimiento pagado el campo Monto aparece con candado y en solo lectura. Al tocarlo, y en una nota fija debajo, se explica: "Un movimiento pagado no permite modificar su monto."
3. **Servidor:** el `UPDATE` solo aplica si el movimiento está pendiente o si el monto enviado es igual al guardado. Si no, responde `409` con el motivo.

En un movimiento pagado sí se pueden editar el concepto y la fecha.

## Eliminar

Todos los movimientos se pueden eliminar, pagados o no, porque la directiva solo restringe el monto. Siempre se pide confirmación y la acción no se puede deshacer. Cada consulta filtra por `usuario_id`: nadie puede editar ni eliminar movimientos ajenos.

## Persistencia

Los cambios se guardan en la tabla `movimientos` de PostgreSQL. Después de cada acción la lista se vuelve a leer del servidor, así que lo que se ve es lo guardado, y tras reabrir la app los cambios permanecen.

## Pruebas unitarias

Archivo: `test/restriccion_monto_test.dart`

| Prueba | Qué verifica |
|---|---|
| Pendiente permite cambiar el monto | `editar` aplica el monto nuevo |
| Pagado rechaza cambiar el monto | Lanza `StateError` con el motivo |
| Pagado permite cambiar concepto y fecha | Solo el monto queda bloqueado |
| Editar conserva id y estado | La edición no altera identidad ni estado |
| `montoBloqueado` depende del estado | `false` en pendiente, `true` en pagado |

**Comando:** `flutter test`

**Resultado:** (pegar aquí la salida, con `All tests passed!`)

## Limitaciones

- No hay papelera: eliminar es definitivo.
- Un movimiento pagado no puede volver a pendiente.