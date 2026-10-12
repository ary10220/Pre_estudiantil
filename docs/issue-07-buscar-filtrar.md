# Issue #7 - Buscar y filtrar movimientos

## Dónde está cada parte

| Parte | Archivos |
|---|---|
| Tipo y categoría (#14) | `base_datos/cambios/003_tipo_categoria.sql`, `lib/modelos/movimiento.dart`, `lib/pantallas/pantalla_nuevo_movimiento.dart` |
| Regla de búsqueda, filtros y total (#15) | `servidor/filtros.js`, `servidor/tests/filtros.test.js`, `lib/modelos/filtros.dart`, `test/filtros_test.dart` |
| Interfaz (#16) | `lib/pantallas/pantalla_movimientos.dart`, `lib/widgets/hoja_filtros.dart` |

## Recorrido

Interfaz → `GET /movimientos?buscar=...&tipo=...` → `leerFiltros` y `filtrarMovimientos` → tabla `movimientos`.
La respuesta trae los movimientos filtrados y sus `totales`, calculados sobre esa misma lista, por eso coinciden con lo que se ve.

## Decisiones

1. La búsqueda es por concepto y no distingue mayúsculas ni tildes.
2. Los filtros se combinan con "y": un movimiento debe cumplirlos todos.
3. El límite mensual (#6) solo cuenta gastos, para que "Gastos de este mes" coincida con "Gastado".
4. El tipo no se puede cambiar al editar; la categoría sí.
5. Los filtros no se guardan al cerrar la app; los datos sí.

## Pruebas

- Servidor: `cd servidor` y `npm test` (`tests/filtros.test.js`)
- App: `flutter test` (`test/filtros_test.dart`)