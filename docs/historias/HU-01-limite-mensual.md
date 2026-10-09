# HU-01 · Límite mensual

## Historia de usuario

Como estudiante, quiero definir un límite mensual de gastos para saber cuánto puedo gastar en el mes y no pasarme.

## Criterios de aceptación

- [ ] Solo se acepta un límite mayor a 0.
- [ ] Un límite vacío, en 0, negativo o con letras se rechaza con el mensaje "El límite debe ser un número mayor a 0".
- [ ] El límite se guarda y permanece después de recargar.
- [ ] Cada usuario ve y cambia solo su propio límite.

## Issues

### Issue A · Regla: validar el límite mensual
- `validarLimite(limite)` separada de la interfaz: devuelve el mensaje de error o `null`.
- Pruebas: un caso permitido (500) y casos rechazados ("", 0, -10, "abc").

### Issue B · Guardar y leer el límite
- Migración `004_limite_mensual.sql`: columna `limite_mensual` en `usuarios`.
- `GET /limite` y `PUT /limite`, con sesión. El usuario sale del token.

### Issue C · Pantalla del límite
- Pantalla "Límite del mes" con el campo y el botón "Guardar límite", a la que se entra desde Inicio.
- El error aparece debajo del campo; al volver a entrar se ve el límite guardado.
