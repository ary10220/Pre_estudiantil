# Decisiones de interacción · Tarea 4 (Historial de actividad)

Documento complementario a [`clase-16-decisiones-interaccion.md`](clase-16-decisiones-interaccion.md). Aquí quedan las **tres decisiones aplicadas al Historial nuevo** (issue [#40](https://github.com/ary10220/Pre_estudiantil/issues/40)): una por principio (Fitts, Hick, carga cognitiva), cada una con *antes*, *después* y *código*, como pide el enunciado:

> "Las tres decisiones tienen antes, después y código."
> — Consigna, criterio 6 (ver `evidencias/clase-16/tarea-4/consigna-02-criterios-terminado.jpg`)

## 0. Consigna

> **Tarea 4 · Implementación.** Construyan un historial pequeño, completo y comprobable.
> La tarea se revisa **desde el issue hasta la aplicación**. No está terminado si solo existe la pantalla: debe haber persistencia, consulta, interfaz, prueba y evidencia.

Issues en GitHub:

| Número | Qué | Enlace |
|---|---|---|
| #40 | Principal · Tarea 4 - Historial de actividad | https://github.com/ary10220/Pre_estudiantil/issues/40 |
| #41 | D · Datos (tabla `eventos` + transacciones) | https://github.com/ary10220/Pre_estudiantil/issues/41 |
| #42 | C · Consulta (`GET /historial` + `armarHistorial`) | https://github.com/ary10220/Pre_estudiantil/issues/42 |
| #43 | P · Pruebas (`historial.test.js`) | https://github.com/ary10220/Pre_estudiantil/issues/43 |
| #44 | I · Interfaz + 3 decisiones | https://github.com/ary10220/Pre_estudiantil/issues/44 |

## 1. Fitts (alcanzar) · acceso al Historial

**Tarea observada:** desde "Mis movimientos" la persona quiere revisar su historial de actividad.

- **Antes:** la pantalla Historial **no existía**. No había ninguna forma de llegar.
- **Después:** se agregó un botón **"Historial"** con ícono `Icons.history` + texto, en el `AppBar` de "Mis movimientos", al lado de "Límite". `minimumSize: Size(0, 48)` para que el área activa cumpla el mínimo recomendado por Material (48×48 dp).
- **Por qué Fitts:** el acceso no está escondido en un menú ni es un ícono sin texto; es un objetivo visible, cercano a los otros accesos y con un área activa grande. El tiempo para alcanzarlo es bajo porque **tamaño** (texto + ícono + 48 dp alto) y **distancia** (barra superior, misma zona que "Límite") son los esperados por la persona.
- **Código:**
  - `lib/pantallas/pantalla_movimientos.dart:270-280`: `TextButton.icon` con `Icons.history`, etiqueta `'Historial'` y `minimumSize: Size(0, 48)`.
  - `lib/pantallas/pantalla_movimientos.dart:145-147`: `_abrirHistorial()` hace `Navigator.pushNamed(context, Rutas.historial)`.
  - `lib/configuracion/rutas.dart:20,30`: constante `historial = '/historial'` + entrada en `Rutas.mapa`.

## 2. Hick (elegir) · chips del historial

**Tarea observada:** la persona abre el historial y quiere ver solo los **gastos**, o solo cuándo definió el **límite**.

- **Antes:** si no hubiéramos filtrado, el historial mostraría los 4 tipos de evento mezclados en una lista larga (hoy mismo, ya con pocas pruebas, aparecen `gasto_registrado`, `ingreso_registrado`, `movimiento_pagado` y `limite_definido` en el mismo scroll). Para encontrar "¿cuándo subí el límite?" habría que leer todo.
- **Después:** **4 chips mutuamente excluyentes** arriba de la lista: **Todos · Gastos · Pagos · Límite**. Además, los eventos se agrupan **por día** con títulos "Hoy", "Ayer" o el día explícito ("12 de octubre"), que divide la lista en bloques fáciles de barrer con la vista. Decisión importante: el chip **"Gastos" NO incluye ingresos**; los ingresos aparecen solo en "Todos". Si hubiéramos puesto un quinto chip "Ingresos", sumaríamos una opción que la mayoría de personas casi no usa y haríamos a los chips scrollables en pantallas chicas.
- **Por qué Hick:** el tiempo de decisión crece con la **cantidad** de opciones. Mantener 4 (y no 5) chips y agrupar por día baja la cantidad de "cosas que mirar" en cada decisión. Mismo criterio que ya se aplicó en los filtros de Movimientos (ver sección 5 de `clase-16-decisiones-interaccion.md`).
- **Código:**
  - `lib/pantallas/pantalla_historial.dart:82-108` (`_barraFiltros`): `ChoiceChip` por cada `FiltroHistorial.values` (son 4).
  - `lib/modelos/evento.dart:30-45`: enum `FiltroHistorial { todos, gastos, pagos, limite }`.
  - `servidor/historial.js:46-53` (`pasaFiltro`): `'gastos'` deja pasar solo `gasto_registrado`; los ingresos quedan solo en `'todos'`.
  - `servidor/tests/historial.test.js:48-54`: test que lo prueba.

## 3. Carga cognitiva (comprender) · tarjeta de un evento

**Tarea observada:** la persona lee un evento del historial y quiere entenderlo sin tener que ir a Movimientos a comparar.

- **Antes:** si solo mostráramos "`gasto_registrado · 25 · 14:30`", la persona tendría que:
  1. **recordar** qué significa `gasto_registrado`,
  2. **buscar en Movimientos** cuál era "25" (concepto, fecha), y
  3. **interpretar** el monto sin formato (`25` en vez de `Bs 25,00`).
- **Después:** cada tarjeta trae **ícono + frase completa + monto + hora** en una sola línea:
  - *"Marcaste como pagado: Taxi · Bs 25,00 · 14:30"*
  - *"Registraste gasto: Almuerzo · Bs 20,00 · 12:15"*
  - *"Definiste tu límite: Límite del mes 2026-10 · Bs 600,00 · 09:40"*

  El ícono y los colores **coinciden con los de Movimientos** (rojo para gastos, verde para ingresos y pagos, savings para el límite), para que la persona no tenga que aprender un nuevo lenguaje visual. El monto siempre va en el mismo formato `Bs 25,00` (coma, dos decimales), como ya se usa en el resto de la app (`lib/modelos/limite.dart:21`, `formatearBs`).
- **Por qué carga cognitiva:** no hay nada que recordar, calcular ni traducir. La frase ya tiene todo el contexto; el formato del monto y los colores son los que la persona ya conoce. Mismo criterio que el aviso "Te quedan Bs X" en Nuevo movimiento (H5.1).
- **Código:**
  - `lib/pantallas/pantalla_historial.dart:174-230` (`_tarjetaEvento` + `_estiloDeTipo`): la tarjeta y el mapa de ícono/color/frase por tipo de evento.
  - `servidor/servidor.js:187-220, 240-290, 414-445`: el servidor guarda `descripcion` (el concepto del movimiento o "Límite del mes 2026-10") y `monto` en el evento, para que la frase se arme sin otra consulta.
  - `servidor/historial.js:36-41` (`horaTexto`): la hora `HH:mm` ya viene formateada del servidor.

## 4. Estado vacío

El quinto criterio ("El estado vacío orienta qué hacer después") también se cumple:

- `lib/pantallas/pantalla_historial.dart:118-162` (`_estadoVacio`):
  - Sin filtro, sin eventos: ícono `history`, "Todavía no hay actividad. Registrá tu primer gasto y lo vas a ver acá." + botón **"Registrar gasto"** (`FilledButton.icon`, `minimumSize: Size(220, 48)`) que lleva a `/nuevo-movimiento`.
  - Con filtro, sin coincidencias: "No hay actividad para 'Gastos'." + "Ver todos", que vuelve a `FiltroHistorial.todos`.

## 5. Prueba

- `servidor/tests/historial.test.js` cubre: orden reciente→antiguo, agrupación por día (Hoy/Ayer/explícito), que dos eventos del mismo día quedan juntos ordenados por hora, los 3 filtros (`gastos`/`pagos`/`limite`), lista vacía, filtro sin coincidencias, formato de hora.
- Totales (al 2026-10-18): `npm test` → **37/37** · `flutter test` → **36/36** · `flutter analyze` → 1 `info` heredado (`unnecessary_underscores`).

## 6. Evidencia

Carpeta: `docs/evidencias/clase-16/tarea-4/`

| Archivo | Qué muestra |
|---|---|
| `consigna-01-tarea-4.jpg` | Diapositiva "Tarea 4 - Implementación", con lista de 4 incisos |
| `consigna-02-criterios-terminado.jpg` | Criterios de terminado (6 checks) |
| `consigna-03-portada.jpg` | Portada "Hacerlo posible no significa hacerlo fácil" |

Capturas del *después* (acceso, chips, grupos, tarjetas, estado vacío): pendiente de tomar en el emulador tras aplicar `cambios/004_eventos.sql`.
