# HU-01 · Límite mensual · Implementada (issues #1 a #4)

## Historia de usuario

Como estudiante, quiero definir un límite mensual de gastos para saber cuánto puedo gastar en el mes y no pasarme.

## Criterios de aceptación

- [x] Solo se acepta un límite mayor a 0.
- [x] Un límite vacío, en 0, negativo o con letras se rechaza con el mensaje "El límite debe ser un número mayor a 0".
- [x] El límite se guarda y permanece después de recargar.
- [x] Cada usuario ve y cambia solo su propio límite.

## Issues

### Issue A · Regla: validar el límite mensual
- `validarLimite(limite)` separada de la interfaz: devuelve el mensaje de error o `null`.
  - En el servidor: `servidor/limite.js`.
  - En la app: `lib/modelos/limite.dart`.
- Pruebas: un caso permitido (500) y casos rechazados ("", 0, -10, "abc").
  - `servidor/tests/limite.test.js` (`npm test`).
  - `test/limite_validaciones_test.dart` (`flutter test`).

### Issue B · Guardar y leer el límite
- Columna `limite_mensual` en `usuarios`:
  - en `base_datos/esquema.sql`, para una base nueva;
  - en `base_datos/cambios/001_limite_mensual.sql`, para una base que ya existía.
- `GET /limite` y `PUT /limite` en `servidor/servidor.js`, con sesión (`exigirSesion`). El usuario sale del token.

### Issue C · Pantalla del límite
- Pantalla "Límite del mes" (`lib/pantallas/pantalla_limite.dart`) con el campo y el botón "Guardar límite". Se entra desde el ícono de la alcancía en "Mis movimientos".
- El error aparece debajo del campo; al volver a entrar se ve el límite guardado.

## Reorganización (11/10/2026)
Al pasar el repositorio a la estructura de la versión de Luis, la HU-01 se trasladó sin cambiar su comportamiento:
- misma regla y mismo mensaje;
- mismos endpoints y mismas respuestas (200, 400, 401);
- misma columna.

Lo único que cambió es el punto de entrada: antes era la pantalla Inicio, que no existe en esta versión; ahora es "Mis movimientos".

Verificado contra la API:

| Pedido | Respuesta |
|---|---|
| `GET` sin límite | `{"limite":null}` (200) |
| `PUT` con `"abc"`, `0`, vacío o sin cuerpo | 400 "El límite debe ser un número mayor a 0" |
| `PUT` con `500.5` y después `GET` | `{"limite":500.5}` |
| `PUT` sin token | 401 |
