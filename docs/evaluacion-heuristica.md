# Evaluación heurística H1–H10

| Dato | Valor |
|---|---|
| Issue principal | #18 |
| Aplicación evaluada | UniBudget completa: acceso, movimientos, límite del mes, búsqueda y filtros |
| Dispositivo | Emulador Pixel 6a (Android), usuario de prueba |
| Capturas | `docs/evidencias/heuristicas/antes/` y `docs/evidencias/heuristicas/despues/` |
| Severidad (Nielsen) | 0 no es problema · 1 cosmético · 2 menor · 3 mayor · 4 catástrofe |

## 1. Resumen

| H | Heurística | Estado | Sub-issues |
|---|---|---|---|
| H1 | Visibilidad del estado del sistema | Cumple | — |
| H2 | Relación entre el sistema y el mundo real | Corregida | #27, #28, #29 |
| H3 | Control y libertad del usuario | Corregida | #30, #31, #32 |
| H4 | Consistencia y estándares | Corregida | #33, #34, #35, #36 |
| H5 | Prevención de errores | Corregida | #19, #20, #21 |
| H6 | Reconocer antes que recordar | Corregida | #37 |
| H7 | Flexibilidad y eficiencia de uso | Corregida | #22 |
| H8 | Diseño estético y minimalista | Cumple | — |
| H9 | Ayudar a reconocer, diagnosticar y recuperarse de errores | Corregida | #23, #24, #25 |
| H10 | Ayuda y documentación | Corregida | #26 |

## 2. Registro por heurística

### H1 · Visibilidad del estado del sistema

| Campo | Registro |
|---|---|
| Estado | **Cumple** |
| Pantalla o flujo | Límite del mes → Guardar límite · Mis movimientos (tarjeta del límite, totales, filtros activos) |
| Explicación | El sistema informa siempre lo que pasa. Al guardar el límite, la confirmación aparece junto al botón, con el monto, el mes y lo que queda ("Límite guardado: Bs 600,00 para octubre · Te quedan Bs 300,00"), y el botón pasa a **Listo**. En la lista, la tarjeta muestra lo gastado con una barra que cambia de color al 80 %, la línea de totales coincide con lo filtrado, los filtros activos se ven como chips y el ícono de filtros indica cuántos hay. Mientras se guarda, el botón se cambia por un indicador de carga. |
| Captura | `antes/h1-limite-confirmacion-ya-corregida.png` · `antes/h1-h9-busqueda-sin-resultados.png` |
| Referencia al código | `lib/pantallas/pantalla_limite.dart:70`, `:87-107`, `:208-222` · `lib/pantallas/pantalla_movimientos.dart:326-331` (contador), `:338-369` (chips), `:372-397` (totales), `:444-486` (tarjeta) |
| Dónde y cómo se comprobó | En el emulador se guardó un límite de Bs 600: la confirmación apareció junto al botón, sin cerrar la pantalla. En la lista se buscó "zzz" y apareció "Ningún movimiento coincide…", con el botón "Quitar filtros". La mejora del límite viene de la Clase 15 (hallazgo 1). |

### H2 · Relación entre el sistema y el mundo real

| Campo | Registro |
|---|---|
| Estado | **Corregida** (#27, #28, #29) |
| Pantalla o flujo | Nuevo movimiento (tipo Ingreso, Fecha, Monto) · Mis movimientos (tarjeta de un ingreso) · Filtros → Rango de fechas |
| Explicación | **Antes:** un ingreso se "pagaba", el calendario estaba en inglés y el monto en bolivianos tenía el ícono del dólar. **Ahora:** el ingreso muestra "Por cobrar" / "Cobrado" y "Marcar como cobrado" (el gasto sigue con "Pendiente" / "Pagado"); los dos calendarios están en español ("Seleccionar fecha", "jue, 15 oct", "Cancelar" / "ACEPTAR"); el campo Monto (Bs) usa un ícono neutro de dinero. |
| Captura | **Antes:** `antes/h2-ingreso-se-guarda-como-pendiente.png` · `antes/h2-h4-calendario-en-ingles.png` · `antes/h5-h6-h7-formulario-nuevo-vacio.png` — **Después:** `despues/h2-1-ingreso-por-cobrar.png` · `despues/h2-1-ingreso-cobrado.png` · `despues/h2-2-calendario-nuevo-espanol.png` · `despues/h2-2-calendario-filtros-espanol.png` · `despues/h2-3-monto-sin-dolar.png` |
| Referencia al código | `lib/modelos/movimiento.dart:14` (`textoPara`), `:74` (`estadoTexto`), `:77` (`accionMarcarTexto`) · `lib/pantallas/pantalla_movimientos.dart:192` (diálogo según tipo), `:558` (chip), `:583` (botón) · `lib/pantallas/pantalla_nuevo_movimiento.dart:423` (subtítulo "por cobrar"), `:460` (`Icons.payments_outlined`), `:77` (calendario) · `lib/main.dart:20-25` (`locale: es`, `localizationsDelegates`) · `pubspec.yaml` (`flutter_localizations`) · `lib/widgets/hoja_filtros.dart:73` (hereda el locale) |
| Problema y severidad | **2.1** Un ingreso se guarda "como pendiente" y tiene "Marcar como pagado": un sueldo o una beca no se pagan, se cobran · **2 Menor** |
| | **2.2** El calendario dice "Select date", "Cancel", "OK" y muestra los días en inglés · **2 Menor** |
| | **2.3** El campo "Monto (Bs)" usa el ícono `$` · **1 Cosmético** |
| Cómo se comprobó la corrección | La tarjeta de Beca Mensual (ingreso) dice "Por cobrar" con "Marcar como cobrado", y un ingreso de prueba cobrado muestra el chip verde "Cobrado" sin botón. Los calendarios de Nuevo movimiento y de Filtros → Desde se abrieron en el emulador y están en español. El campo Monto (Bs) ya no muestra `$`. |

### H3 · Control y libertad del usuario

| Campo | Registro |
|---|---|
| Estado | **Corregida** (#30, #31, #32) |
| Pantalla o flujo | Nuevo/Editar movimiento → flecha atrás · Recuperar contraseña → paso 2 · Mis movimientos → Cerrar sesión |
| Explicación | **Antes:** la flecha atrás borraba el formulario sin avisar, el correo del paso 2 no se podía corregir y cerrar sesión era de un solo toque. **Ahora:** con cambios sin guardar aparece "¿Descartar los cambios?" ("Seguir editando" conserva lo escrito, "Descartar" cierra; sin cambios vuelve directo); el paso 2 tiene "Cambiar correo" que vuelve al paso 1 conservando lo escrito; cerrar sesión pide "¿Cerrar sesión?" con "Cancelar" y "Cerrar sesión". Eliminar y marcar como pagado/cobrado ya pedían confirmación, y los filtros se quitan uno por uno o todos juntos. |
| Captura | **Antes:** `antes/h3-atras-descarta-formulario-sin-aviso.png` · `antes/h3-recuperar-paso2-correo-bloqueado.png` · `antes/h3-h6-inicio-tras-cerrar-sesion-sin-confirmar.png` · lo que ya cumplía: `antes/h3-h5-confirmar-eliminar.png`, `antes/h3-confirmar-pagado-irreversible.png` — **Después:** `despues/h3-1-pregunta-descartar.png` · `despues/h3-2-paso2-cambiar-correo.png` · `despues/h3-3-pregunta-cerrar-sesion.png` |
| Referencia al código | `lib/pantallas/pantalla_nuevo_movimiento.dart:92` (`_hayCambios`), `:111` (`_confirmarSalida`), `:392` (`PopScope`), `:312` (tras guardar no pregunta) · `lib/pantallas/pantalla_recuperar.dart:58` (`_cambiarCorreo`), `:145-147` (botón) · `lib/pantallas/pantalla_movimientos.dart:243` (cerrar sesión con `_pedirConfirmacion`) |
| Problema y severidad | **3.1** La flecha atrás borra un formulario lleno sin preguntar · **2 Menor** |
| | **3.2** En Recuperar, paso 2, el correo queda bloqueado y no se puede corregir · **2 Menor** |
| | **3.3** "Cerrar sesión" actúa con un solo toque, al lado del ícono del límite · **1 Cosmético** |
| Cómo se comprobó la corrección | Con texto escrito en Concepto, la flecha atrás mostró "¿Descartar los cambios?" con "Seguir editando" y "Descartar". En Recuperar se pidió un código para prueba@correo.com y apareció "Cambiar correo" bajo el campo. Al tocar el ícono de salir apareció "¿Cerrar sesión?" con "Cancelar" y "Cerrar sesión". |

### H4 · Consistencia y estándares

| Campo | Registro |
|---|---|
| Estado | **Corregida** (#33, #34, #35, #36) |
| Pantalla o flujo | Mis movimientos (tarjeta y totales) · Editar movimiento · Límite del mes · botones de toda la app |
| Explicación | **Antes:** el monto iba con punto o con coma según la pantalla, el gasto salía en verde en la tarjeta y en rojo en los totales, el límite trataba de "vos" y "Listo" mostraba "←" y "→" a la vez. **Ahora:** todos los montos usan `formatearBs` (coma); el monto es verde en ingresos y rojo en gastos, igual que los totales; el límite trata de "tú" en la app y en el servidor; "Listo" lleva ✓ a la izquierda y la → de la derecha, como los demás botones. |
| Captura | **Antes:** `antes/h4-h8-lista-formato-y-color-monto.png` · `antes/h4-limite-vacio-voseo-escribi.png` · `antes/h2-h4-h10-pantalla-limite.png` · `antes/h1-limite-confirmacion-ya-corregida.png` (botón "Listo") — **Después:** `despues/h4-1-formato-bs-unico.png` · `despues/h4-2-monto-por-tipo.png` · `despues/h4-3-limite-tuteo.png` · `despues/h4-4-listo-una-flecha.png` |
| Referencia al código | `lib/modelos/movimiento.dart:1` (usa `formatearBs`), `:135` (`montoTexto`) · `lib/pantallas/pantalla_movimientos.dart:533-538` (color según tipo) · `lib/modelos/limite.dart:2`, `:4` ("Escribe", "Usa") · `lib/pantallas/pantalla_limite.dart:174` ("quieres"), `:213` (`Icons.check`) · `servidor/limite.js:13`, `:19` · pruebas: `test/limite_validaciones_test.dart`, `servidor/tests/limite.test.js` |
| Problema y severidad | **4.1** La tarjeta dice "Bs 300.00" y los totales "Bs 300,00" · **2 Menor** |
| | **4.2** El monto de un gasto sale en verde, pero en los totales los gastos van en rojo · **2 Menor** |
| | **4.3** Solo la pantalla del límite usa voseo ("querés", "Escribí", "Usá") · **1 Cosmético** |
| | **4.4** Todos los botones llevan "→", y "Listo" muestra "←" y "→" a la vez · **1 Cosmético** |
| Cómo se comprobó la corrección | La lista muestra "Bs 10,00" y "Bs 500,00" con coma en tarjetas y totales; el gasto en rojo y el ingreso en verde. La pantalla del límite dice "Cuánto quieres…" y el error "Escribe el límite" (el servidor responde lo mismo). Tras guardar, el botón es "✓ Listo →". `flutter test` 36/36 y `npm test` 28/28 pasan. |

### H5 · Prevención de errores

| Campo | Registro |
|---|---|
| Estado | **Corregida** (#19, #20, #21) |
| Pantalla o flujo | Nuevo movimiento (monto de un gasto, categoría) · Crear cuenta (correo) |
| Explicación | **Antes:** la persona escribía el monto sin saber cuánto le quedaba del límite y se enteraba recién con el bloqueo; el registro aceptaba un correo sin "@"; la categoría venía en "Otros" y se guardaba así por olvido. **Ahora:** debajo del monto aparece "Te quedan Bs X en octubre" y, mientras se escribe, cuánto quedaría o por cuánto se pasaría (en rojo); el correo se valida en la app y en el servidor; la categoría se elige o aparece "Elige una categoría". |
| Captura | **Antes:** `antes/h5-h6-formulario-lleno-sin-restante.png` · `antes/h5-2-formulario-correo-sin-arroba.png` · `antes/h5-2-registro-acepta-correo-sin-arroba.png` · `antes/h5-h6-h7-formulario-nuevo-vacio.png` — **Después:** `despues/h5-1-aviso-monto-que-entra.png` · `despues/h5-1-aviso-monto-que-se-pasa.png` · `despues/h5-2-registro-rechaza-correo-sin-arroba.png` · `despues/h5-3-formulario-sin-categoria-elegida.png` · `despues/h5-3-error-elige-categoria.png` |
| Referencia al código | `lib/modelos/limite.dart:37-55` (`avisoGasto`) · `lib/servicios/servicio_limite.dart:26-29` (`leer([mes])`) · `lib/pantallas/pantalla_nuevo_movimiento.dart:95-106` (`_cargarResumen`), `:165-200` (`_avisoLimite`), `:213` (categoría) · `lib/modelos/correo.dart` · `servidor/correo.js` · `servidor/servidor.js:58-61` · `lib/pantallas/pantalla_registro.dart:45` · pruebas: `test/limite_validaciones_test.dart`, `test/correo_test.dart`, `servidor/tests/correo.test.js` |
| Problema y severidad | **5.1** El formulario no muestra cuánto queda del límite · **3 Mayor** |
| | **5.2** El registro acepta un correo sin "@" · **2 Menor** |
| | **5.3** La categoría viene preelegida en "Otros" · **1 Cosmético** |
| Cómo se comprobó la corrección | Con Bs 300 disponibles se escribió 120 (dice "te quedarían Bs 180,00") y 400 (en rojo, "te pasarías por Bs 100,00") antes de tocar Guardar. Con tipo Ingreso el aviso desaparece. Registrar "correo-sin-arroba" ya no crea la cuenta (la app lo explica, y el servidor responde 400). Guardar sin categoría muestra "Elige una categoría", que se va al elegir una. |

### H6 · Reconocer antes que recordar

| Campo | Registro |
|---|---|
| Estado | **Corregida** (#37) |
| Pantalla o flujo | Mis movimientos → barra superior |
| Explicación | **Antes:** el acceso al límite (🐷) era solo un ícono y su nombre aparecía únicamente al mantenerlo presionado. **Ahora:** la barra muestra "🐷 Límite" con ícono y texto, sin depender del tooltip. El cierre de sesión sigue con su ícono, pero desde #32 pide "¿Cerrar sesión?" antes de salir. |
| Captura | **Antes:** `antes/h6-iconos-sin-texto-solo-tooltip.png` — **Después:** `despues/h6-1-acceso-limite-con-texto.png` |
| Referencia al código | `lib/pantallas/pantalla_movimientos.dart:272` (`TextButton.icon` "Límite") |
| Problema y severidad | **6.1** 🐷 (Límite del mes) y ⏻ (Cerrar sesión) no tienen texto visible · **2 Menor** |
| Cómo se comprobó la corrección | La barra superior muestra "Mis movimientos", "🐷 Límite" y el ícono de salir en el emulador, sin recortes. |

### H7 · Flexibilidad y eficiencia de uso

| Campo | Registro |
|---|---|
| Estado | **Corregida** (#22) |
| Pantalla o flujo | Nuevo movimiento → Fecha |
| Explicación | **Antes:** la fecha empezaba vacía y había que abrir el calendario y tocar OK en cada movimiento, aunque casi siempre es hoy. **Ahora:** empieza en la fecha de hoy y se puede cambiar tocando el campo. La búsqueda mientras se escribe y los periodos rápidos ("Este mes", "Mes anterior") ya cumplían. |
| Captura | **Antes:** `antes/h5-h6-h7-formulario-nuevo-vacio.png` — **Después:** `despues/h7-1-fecha-de-hoy-por-defecto.png` · lo que ya cumplía: `antes/h7-hoja-filtros.png` |
| Referencia al código | `lib/pantallas/pantalla_nuevo_movimiento.dart:57-62` |
| Problema y severidad | **7.1** La fecha empieza vacía y hay que abrir el calendario cada vez · **2 Menor** |
| Cómo se comprobó la corrección | Al abrir Nuevo movimiento, el campo Fecha ya muestra la fecha del día (14/10/2026). |

### H8 · Diseño estético y minimalista

| Campo | Registro |
|---|---|
| Estado | **Cumple** |
| Pantalla o flujo | Mis movimientos · Filtros · formularios |
| Explicación | Cada pantalla muestra solo lo necesario para su tarea: saludo, tarjeta del límite (solo si hay uno), buscador, total y tarjetas. Los filtros están en una hoja aparte y sus chips solo aparecen cuando hay alguno activo. Los formularios siguen el mismo orden y espaciado. |
| Captura | `antes/h4-h8-lista-formato-y-color-monto.png` · `antes/h7-hoja-filtros.png` |
| Referencia al código | `lib/pantallas/pantalla_movimientos.dart:283-302` (estructura), `:292-296` (tarjeta solo con límite), `:338-341` (chips solo si hay activos) · `lib/widgets/hoja_filtros.dart:153-243` |
| Dónde y cómo se comprobó | Se recorrieron la lista, la hoja de filtros y los formularios en el emulador. No hay información repetida ni de adorno: la tarjeta del límite desaparece sin límite, y los chips y "Quitar todos" solo aparecen con filtros activos. |

### H9 · Ayudar a reconocer, diagnosticar y recuperarse de errores

| Campo | Registro |
|---|---|
| Estado | **Corregida** (#23, #24, #25) |
| Pantalla o flujo | Nuevo movimiento → Guardar un gasto que supera el límite · Guardar con campos vacíos (también en Login, Registro y Recuperar) · Abrir la app sin conexión |
| Explicación | **Antes:** el bloqueo por límite decía el problema pero no daba salida y desaparecía solo; "Completa todos los campos" no decía cuál faltaba; sin conexión, la app mandaba a Inicio como si la sesión se hubiera cerrado. **Ahora:** el bloqueo queda en un recuadro con "Cambiar monto" (pone el cursor en el monto) y "Subir límite" (abre Límite del mes); cada campo con error se marca en rojo con su mensaje; sin conexión aparece "No se pudo conectar con el servidor. Tu sesión sigue guardada", con "Reintentar". |
| Captura | **Antes:** `antes/h9-bloqueo-limite-sin-salida.png` · `antes/h9-error-campos-vacios-snackbar.png` · `antes/h9-login-error-snackbar-lejos.png` · `antes/h9-3-sin-conexion-va-a-inicio.png` — **Después:** `despues/h9-1-bloqueo-con-salidas.png` · `despues/h9-1-cambiar-monto-selecciona.png` · `despues/h9-1-subir-limite-abre-limite.png` · `despues/h9-2-formulario-errores-por-campo.png` · `despues/h9-2-login-errores-por-campo.png` · `despues/h9-2-registro-errores-por-campo.png` · `despues/h9-3-sin-conexion-avisa-y-reintentar.png` · `despues/h9-3-reintentar-entra-con-la-sesion.png` |
| Referencia al código | `lib/servicios/servicio_acceso.dart:8-13` (`ErrorAcceso.codigo`) · `lib/pantallas/pantalla_nuevo_movimiento.dart:109-160` (salidas del bloqueo), `:245` (422) · `lib/widgets/campo_texto.dart` (`nodoFoco`) · `lib/widgets/mensajes.dart:4-5` (`mensajeCampoVacio`) · `lib/pantallas/pantalla_login.dart:34-38` · `lib/pantallas/pantalla_registro.dart:43-58` · `lib/pantallas/pantalla_recuperar.dart:62-67` · `lib/pantallas/pantalla_arranque.dart:31`, `:43-85` |
| Problema y severidad | **9.1** El bloqueo por límite no ofrece salida · **2 Menor** |
| | **9.2** "Completa todos los campos" no dice cuál falta · **2 Menor** |
| | **9.3** Sin conexión al abrir, la app manda a Inicio sin avisar · **2 Menor** |
| Cómo se comprobó la corrección | Un gasto de 400 con 300 disponibles muestra el recuadro: "Cambiar monto" abre el teclado con el 400 seleccionado y "Subir límite" abre Límite del mes, sin perder lo escrito. Guardar el formulario vacío marca categoría, concepto y monto, cada uno con su mensaje. Con el emulador en modo avión aparece el aviso; al volver la conexión, "Reintentar" entra directo a Mis movimientos. |

### H10 · Ayuda y documentación

| Campo | Registro |
|---|---|
| Estado | **Corregida** (#26) |
| Pantalla o flujo | Límite del mes |
| Explicación | **Antes:** la pantalla solo decía "Cuánto querés gastar como máximo este mes", sin explicar las reglas que después sorprenden. **Ahora:** un recuadro "Cómo funciona" dice que un gasto que supera el límite no se guarda, que solo cuentan los gastos y que es el límite del mes y no puede ser menor a lo ya gastado. Ya había ayudas en otras pantallas: la lista vacía indica cómo crear el primer movimiento, el campo del límite tiene "Ej.: 500" y el monto bloqueado explica su motivo. |
| Captura | **Antes:** `antes/h2-h4-h10-pantalla-limite.png` — **Después:** `despues/h10-1-limite-explica-como-funciona.png` |
| Referencia al código | `lib/pantallas/pantalla_limite.dart:110-150` (`_comoFunciona`), `:186` · las reglas: `servidor/servidor.js` (solo gastos, 422) y `servidor/limite.js:24-47` |
| Problema y severidad | **10.1** La pantalla del límite no explica cómo funciona · **2 Menor** |
| Cómo se comprobó la corrección | Al abrir Límite del mes, las tres reglas se ven antes del campo, sin tener que provocar un bloqueo. |

## 3. Hallazgos y mejoras

| # | Observación | Heurística | Severidad | Mejora | Comprobación | Sub-issue |
|---|---|---|---|---|---|---|
| 2.1 | Un ingreso se guarda "como pendiente" y tiene el botón "Marcar como pagado". | H2 · Mundo real | 2 · Menor | Si es ingreso: "Por cobrar", "Cobrado" y "Marcar como cobrado". La regla de estado no cambia. | Otra persona registra un sueldo y explica qué significa su estado sin preguntar. | #27 |
| 2.2 | El calendario dice "Select date", "Cancel", "OK" y muestra los días en inglés. | H2 · Mundo real | 2 · Menor | Configurar la app en español (`flutter_localizations`, `locale: es`). | Al abrir Fecha, todo el calendario está en español. | #28 |
| 2.3 | El campo "Monto (Bs)" usa el ícono de dólar `$`. | H2 · Mundo real | 1 · Cosmético | Cambiar el ícono por uno neutro de dinero, o poner "Bs" al inicio del campo. | El campo ya no muestra ningún símbolo de otra moneda. | #29 |
| 3.1 | La flecha atrás borra un formulario lleno sin avisar. | H3 · Control y libertad | 2 · Menor | Si hay datos escritos, preguntar "¿Descartar el movimiento?" con las opciones Seguir editando y Descartar. | Otra persona escribe un gasto, toca atrás por error y recupera lo que escribió. | #30 |
| 3.2 | En Recuperar, paso 2, el correo queda bloqueado y no se puede corregir. | H3 · Control y libertad | 2 · Menor | Agregar "Cambiar correo", que vuelve al paso 1 sin salir de la pantalla. | Otra persona escribe mal su correo y lo corrige sin salir de la pantalla. | #31 |
| 3.3 | "Cerrar sesión" actúa con un solo toque, al lado del ícono del límite. | H3 · Control y libertad | 1 · Cosmético | Pedir confirmación con el diálogo que ya existe (`_pedirConfirmacion`). | Un toque por error en ⏻ ya no saca a la persona de su cuenta. | #32 |
| 4.1 | La tarjeta dice "Bs 300.00" y los totales dicen "Bs 300,00". | H4 · Consistencia | 2 · Menor | Usar `formatearBs` (con coma) en todos los montos. | En la lista, la tarjeta del límite, los totales y el formulario, todos los montos tienen el mismo formato. | #33 |
| 4.2 | El monto de un gasto sale en verde, pero en los totales los gastos van en rojo. | H4 · Consistencia | 2 · Menor | Pintar el monto según el tipo: ingreso en verde y gasto en rojo, como en los totales. | Otra persona distingue ingresos y gastos en la lista sin leer el texto chico. | #34 |
| 4.3 | Solo la pantalla del límite usa voseo ("querés", "Escribí", "Usá"). | H4 · Consistencia | 1 · Cosmético | Pasar esos textos a "tú" en la app y en el servidor ("quieres", "Escribe", "Usa"). | No queda ningún texto con voseo en la app. | #35 |
| 4.4 | Todos los botones llevan "→", y "Listo" muestra "←" y "→" a la vez. | H4 · Consistencia | 1 · Cosmético | Mostrar la flecha solo cuando el botón avanza, y una sola flecha por botón. | Ningún botón muestra flechas que se contradicen. | #36 |
| 5.1 | El formulario no muestra cuánto queda del límite: la persona escribe el monto sin saber si entra. | H5 · Prevención de errores (y H6) | 3 · Mayor | Mostrar "Te quedan Bs X en octubre" y, mientras se escribe, cuánto quedaría, con color de aviso si se pasa. | Otra persona registra un gasto que no entra y lo nota antes de tocar Guardar. | #19 |
| 5.2 | El registro acepta un correo sin "@". | H5 · Prevención de errores | 2 · Menor | Validar el formato en el modelo, en la pantalla (error debajo del campo) y en el servidor (400). | Al registrar "abc", la app explica el error y no crea la cuenta. | #20 |
| 5.3 | La categoría viene preelegida en "Otros" y se guarda así si no se cambia. | H5 · Prevención de errores | 1 · Cosmético | Empezar sin categoría y pedir que se elija una. | Los movimientos nuevos ya no quedan en "Otros" por olvido. | #21 |
| 6.1 | 🐷 (Límite del mes) y ⏻ (Cerrar sesión) no tienen texto. | H6 · Reconocer antes que recordar | 2 · Menor | Dar un texto visible al acceso del límite (por ejemplo, un botón "Límite" con su ícono). | Otra persona encuentra dónde definir el límite sin que se lo digan. | #37 |
| 7.1 | La fecha empieza vacía y hay que abrir el calendario en cada movimiento. | H7 · Flexibilidad y eficiencia | 2 · Menor | Poner la fecha de hoy por defecto al crear, y que se pueda cambiar. | Registrar un gasto de hoy no exige abrir el calendario. | #22 |
| 9.1 | El bloqueo por límite dice el problema, pero no ofrece una salida, y el mensaje desaparece solo. | H9 · Recuperarse de errores | 2 · Menor | Agregar las acciones "Cambiar monto" (pone el foco en el monto) y "Subir límite" (abre Límite del mes). | Otra persona bloqueada por el límite sigue sola, por uno de los dos caminos. | #23 |
| 9.2 | "Completa todos los campos" no dice cuál falta y ningún campo se marca. | H9 · Recuperarse de errores | 2 · Menor | Mostrar el error debajo de cada campo vacío, como ya lo hacen el límite y los filtros. | Otra persona deja un campo vacío y sabe al instante cuál es. | #24 |
| 9.3 | Sin conexión al abrir la app, aparece Inicio como si la sesión se hubiera cerrado. | H9 · Recuperarse de errores | 2 · Menor | Avisar "No se pudo conectar con el servidor" y ofrecer "Reintentar". | Con el servidor apagado, la persona entiende que es la conexión y no su cuenta. | #25 |
| 10.1 | La pantalla del límite no explica sus reglas. | H10 · Ayuda y documentación | 2 · Menor | Agregar una nota corta: "Si un gasto supera el límite no se guarda. Solo cuentan los gastos del mes." | Otra persona explica qué pasa al superar el límite antes de probarlo. | #26 |
