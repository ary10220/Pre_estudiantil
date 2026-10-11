# Tarea 2 - Funcionalidad vertical

**Producto:** Presupuesto Estudiantil (UniBudget)
**Entidad principal:** Movimiento
**Acción de estado:** "Marcar como pagado" (pendiente → pagado)

## Recorrido completo

| Paso | Implementación |
|---|---|
| Capturar | `PantallaNuevoMovimiento`: concepto, monto y fecha (cualquier fecha, sin restricción) |
| Construir | `ServicioMovimientos.crear` arma un `Movimiento` (`lib/modelos/movimiento.dart`) |
| Guardar | `POST /movimientos` inserta en la tabla `movimientos` de PostgreSQL |
| Mostrar | `PantallaMovimientos` actualiza la lista tras guardar |
| Recuperar | `GET /movimientos` al abrir la pantalla; al reabrir la app los datos siguen |

## Estados y transiciones

```
pendiente --(Marcar como pagado)--> pagado
pagado    --(Marcar como pagado)--> RECHAZADO
```

Todo movimiento nuevo nace `pendiente`. La regla está en dos lugares:

1. **Modelo Flutter** (`Movimiento.marcarComoPagado`): lanza `StateError` si ya está pagado. Es lo que cubren las pruebas.
2. **Servidor** (`POST /movimientos/:id/pagar`): el `UPDATE` solo afecta filas con `estado = 'pendiente'`; si ya está pagado responde `409`.

En la interfaz, el botón "Marcar como pagado" solo aparece en movimientos pendientes.

## Pruebas unitarias

Archivo: `test/movimiento_test.dart`

| Prueba | Qué verifica |
|---|---|
| El estado inicial es pendiente | Un movimiento nuevo empieza como `pendiente` |
| El estado se lee desde el servidor | `desdeJson` interpreta `pendiente` y `pagado` |
| Cambia de pendiente a pagado | `marcarComoPagado` produce estado `pagado` |
| Transición inválida se rechaza | Marcar uno ya pagado lanza `StateError` |
| Conserva los demás datos | `id`, `concepto`, `monto` y `fecha` no cambian |
| El original no se modifica | El objeto previo sigue `pendiente` (inmutable) |

**Comando:**

```powershell
flutter test
```

**Resultado:** (pegar aquí la salida de `flutter test`, con `All tests passed!`)

## Decisiones

1. Cada movimiento pertenece a una persona (`usuario_id`); todas las consultas filtran por la sesión.
2. El modelo es inmutable: la acción devuelve un objeto nuevo en vez de modificar el existente.
3. La fecha se guarda como `DATE` y viaja como texto `YYYY-MM-DD`, para evitar desfases de zona horaria.
4. La lista se vuelve a leer del servidor después de cada cambio, así lo que se ve es lo guardado.
5. "Marcar como pagado" pide confirmación antes de ejecutarse, porque la transición no se puede deshacer.

## Limitaciones

- No se puede editar ni eliminar un movimiento.
- No hay transición de vuelta de `pagado` a `pendiente`.
- Las pruebas cubren el modelo; la API se probó manualmente.