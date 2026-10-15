# Evaluación heurística H1–H10

Issue principal: #18 · Aplicación evaluada: UniBudget completa (acceso, movimientos, límite del mes, búsqueda y filtros) · Dispositivo: emulador Pixel 6a · Capturas: `docs/evidencias/heuristicas/`

Severidad (Nielsen): 0 no es problema · 1 cosmético · 2 menor · 3 mayor · 4 catástrofe.

## 1. Estado de cada heurística

| H | Heurística | Estado | Pantalla o flujo | Explicación | Código |
|---|---|---|---|---|---|
| H1 | Visibilidad del estado del sistema | Cumple | Límite del mes · Mis movimientos | Al guardar el límite, la confirmación aparece junto al botón, con el monto, el mes y el restante. La lista muestra lo gastado con una barra, los totales, los filtros activos y un indicador de carga al guardar. | `pantalla_limite.dart:87-107` · `pantalla_movimientos.dart:338-397`, `:444-486` |
| H2 | Relación entre el sistema y el mundo real | Falla | Nuevo movimiento · Mis movimientos | Un ingreso se "paga", el calendario está en inglés y el monto en Bs usa el ícono `$`. | `pantalla_nuevo_movimiento.dart:187`, `:214` · `pantalla_movimientos.dart:531-566` · `main.dart:14-20` |
| H3 | Control y libertad del usuario | Falla | Nuevo movimiento · Recuperar contraseña · Mis movimientos | La flecha atrás borra el formulario sin preguntar, en Recuperar no se puede corregir el correo y cerrar sesión no pide confirmación. | `pantalla_nuevo_movimiento.dart:165-169` · `pantalla_recuperar.dart:118-124` · `pantalla_movimientos.dart:264-268` |
| H4 | Consistencia y estándares | Falla | Mis movimientos · Límite del mes · botones | El monto se escribe con punto y con coma, el gasto sale en verde en la tarjeta y en rojo en los totales, el límite usa voseo y "Listo" muestra flechas en los dos sentidos. | `movimiento.dart:105` · `limite.dart:2-4`, `:21` · `pantalla_movimientos.dart:513-520` · `boton_pildora.dart:49` |
| H5 | Prevención de errores | Corregida (#19, #20, #21) | Nuevo movimiento · Crear cuenta | Antes: no se veía cuánto quedaba del límite, el registro aceptaba un correo sin "@" y la categoría venía en "Otros". Ahora: el formulario avisa cuánto queda y si el gasto se pasa, el correo se valida en la app y en el servidor, y la categoría se elige. | `limite.dart:37-55` · `pantalla_nuevo_movimiento.dart:95-106`, `:165-200`, `:213` · `correo.dart` · `servidor/correo.js` · `servidor.js:58-61` |
| H6 | Reconocer antes que recordar | Falla | Mis movimientos (barra superior) | El límite y el cierre de sesión son solo íconos. Su nombre aparece únicamente si se mantiene presionado el ícono. | `pantalla_movimientos.dart:259-268` |
| H7 | Flexibilidad y eficiencia de uso | Corregida (#22) | Nuevo movimiento | Antes: la fecha empezaba vacía y había que abrir el calendario siempre. Ahora: empieza en hoy y se puede cambiar. | `pantalla_nuevo_movimiento.dart:57-62` |
| H8 | Diseño estético y minimalista | Cumple | Mis movimientos · Filtros · formularios | Cada pantalla muestra solo lo necesario. Los filtros están en una hoja aparte y sus chips aparecen solo si hay alguno activo. | `pantalla_movimientos.dart:283-302`, `:338-341` · `hoja_filtros.dart` |
| H9 | Reconocer, diagnosticar y recuperarse de errores | Corregida (#23, #24, #25) | Nuevo movimiento · Login · Registro · Recuperar · Arranque | Antes: el bloqueo no tenía salida, "Completa todos los campos" no decía cuál faltaba y sin conexión la app mandaba a Inicio sin avisar. Ahora: el bloqueo ofrece "Cambiar monto" y "Subir límite", cada campo vacío se marca con su error y sin conexión aparece un aviso con "Reintentar". | `servicio_acceso.dart:8-13` · `pantalla_nuevo_movimiento.dart:109-160`, `:245` · `mensajes.dart:4-5` · `pantalla_login.dart:34-38` · `pantalla_arranque.dart:28-33`, `:43-85` |
| H10 | Ayuda y documentación | Corregida (#26) | Límite del mes | Antes: la pantalla no explicaba sus reglas. Ahora: un recuadro "Cómo funciona" dice que un gasto que supera el límite no se guarda, que solo cuentan los gastos y que es por mes. | `pantalla_limite.dart:110-150`, `:186` |

## 2. Hallazgos y mejoras

| # | Observación | Heurística | Severidad | Mejora | Comprobación | Sub-issue |
|---|---|---|---|---|---|---|
| 2.1 | Un ingreso se guarda "como pendiente" y tiene el botón "Marcar como pagado". | H2 · Mundo real | 2 · Menor | Si es ingreso: "Por cobrar", "Cobrado" y "Marcar como cobrado". La regla de estado no cambia. | Otra persona registra un sueldo y explica qué significa su estado sin preguntar. | — |
| 2.2 | El calendario dice "Select date", "Cancel", "OK" y muestra los días en inglés. | H2 · Mundo real | 2 · Menor | Configurar la app en español (`flutter_localizations`, `locale: es`). | Al abrir Fecha, todo el calendario está en español. | — |
| 2.3 | El campo "Monto (Bs)" usa el ícono de dólar `$`. | H2 · Mundo real | 1 · Cosmético | Cambiar el ícono por uno neutro de dinero, o poner "Bs" al inicio del campo. | El campo ya no muestra ningún símbolo de otra moneda. | — |
| 3.1 | La flecha atrás borra un formulario lleno sin avisar. | H3 · Control y libertad | 2 · Menor | Si hay datos escritos, preguntar "¿Descartar el movimiento?" con las opciones Seguir editando y Descartar. | Otra persona escribe un gasto, toca atrás por error y recupera lo que escribió. | — |
| 3.2 | En Recuperar, paso 2, el correo queda bloqueado y no se puede corregir. | H3 · Control y libertad | 2 · Menor | Agregar "Cambiar correo", que vuelve al paso 1 sin salir de la pantalla. | Otra persona escribe mal su correo y lo corrige sin salir de la pantalla. | — |
| 3.3 | "Cerrar sesión" actúa con un solo toque, al lado del ícono del límite. | H3 · Control y libertad | 1 · Cosmético | Pedir confirmación con el diálogo que ya existe (`_pedirConfirmacion`). | Un toque por error en ⏻ ya no saca a la persona de su cuenta. | — |
| 4.1 | La tarjeta dice "Bs 300.00" y los totales dicen "Bs 300,00". | H4 · Consistencia | 2 · Menor | Usar `formatearBs` (con coma) en todos los montos. | En la lista, la tarjeta del límite, los totales y el formulario, todos los montos tienen el mismo formato. | — |
| 4.2 | El monto de un gasto sale en verde, pero en los totales los gastos van en rojo. | H4 · Consistencia | 2 · Menor | Pintar el monto según el tipo: ingreso en verde y gasto en rojo, como en los totales. | Otra persona distingue ingresos y gastos en la lista sin leer el texto chico. | — |
| 4.3 | Solo la pantalla del límite usa voseo ("querés", "Escribí", "Usá"). | H4 · Consistencia | 1 · Cosmético | Pasar esos textos a "tú" en la app y en el servidor ("quieres", "Escribe", "Usa"). | No queda ningún texto con voseo en la app. | — |
| 4.4 | Todos los botones llevan "→", y "Listo" muestra "←" y "→" a la vez. | H4 · Consistencia | 1 · Cosmético | Mostrar la flecha solo cuando el botón avanza, y una sola flecha por botón. | Ningún botón muestra flechas que se contradicen. | — |
| 5.1 | El formulario no muestra cuánto queda del límite: la persona escribe el monto sin saber si entra. | H5 · Prevención de errores (y H6) | 3 · Mayor | Mostrar "Te quedan Bs X en octubre" y, mientras se escribe, cuánto quedaría, con color de aviso si se pasa. | Otra persona registra un gasto que no entra y lo nota antes de tocar Guardar. | #19 |
| 5.2 | El registro acepta un correo sin "@". | H5 · Prevención de errores | 2 · Menor | Validar el formato en el modelo, en la pantalla (error debajo del campo) y en el servidor (400). | Al registrar "abc", la app explica el error y no crea la cuenta. | #20 |
| 5.3 | La categoría viene preelegida en "Otros" y se guarda así si no se cambia. | H5 · Prevención de errores | 1 · Cosmético | Empezar sin categoría y pedir que se elija una. | Los movimientos nuevos ya no quedan en "Otros" por olvido. | #21 |
| 6.1 | 🐷 (Límite del mes) y ⏻ (Cerrar sesión) no tienen texto. | H6 · Reconocer antes que recordar | 2 · Menor | Dar un texto visible al acceso del límite (por ejemplo, un botón "Límite" con su ícono). | Otra persona encuentra dónde definir el límite sin que se lo digan. | — |
| 7.1 | La fecha empieza vacía y hay que abrir el calendario en cada movimiento. | H7 · Flexibilidad y eficiencia | 2 · Menor | Poner la fecha de hoy por defecto al crear, y que se pueda cambiar. | Registrar un gasto de hoy no exige abrir el calendario. | #22 |
| 9.1 | El bloqueo por límite dice el problema, pero no ofrece una salida, y el mensaje desaparece solo. | H9 · Recuperarse de errores | 2 · Menor | Agregar las acciones "Cambiar monto" (pone el foco en el monto) y "Subir límite" (abre Límite del mes). | Otra persona bloqueada por el límite sigue sola, por uno de los dos caminos. | #23 |
| 9.2 | "Completa todos los campos" no dice cuál falta y ningún campo se marca. | H9 · Recuperarse de errores | 2 · Menor | Mostrar el error debajo de cada campo vacío, como ya lo hacen el límite y los filtros. | Otra persona deja un campo vacío y sabe al instante cuál es. | #24 |
| 9.3 | Sin conexión al abrir la app, aparece Inicio como si la sesión se hubiera cerrado. | H9 · Recuperarse de errores | 2 · Menor | Avisar "No se pudo conectar con el servidor" y ofrecer "Reintentar". | Con el servidor apagado, la persona entiende que es la conexión y no su cuenta. | #25 |
| 10.1 | La pantalla del límite no explica sus reglas. | H10 · Ayuda y documentación | 2 · Menor | Agregar una nota corta: "Si un gasto supera el límite no se guarda. Solo cuentan los gastos del mes." | Otra persona explica qué pasa al superar el límite antes de probarlo. | #26 |

## 3. Heurísticas que cumplen

| H | Dónde se comprobó | Cómo se comprobó | Código |
|---|---|---|---|
| H1 | Límite del mes, Mis movimientos | Se guardó un límite de Bs 600: la confirmación apareció junto al botón ("Límite guardado: Bs 600,00 para octubre · Te quedan Bs 300,00"). En la lista, la tarjeta, los totales y los chips cambian con cada acción. Corregida en la Clase 15. | `pantalla_limite.dart:87-107`, `:165-180` · `pantalla_movimientos.dart:326-397` |
| H8 | Mis movimientos, Filtros, formularios | Se recorrió cada pantalla: no hay información repetida ni de adorno. Los filtros solo se ven al abrirlos y la tarjeta del límite solo aparece si hay un límite. | `pantalla_movimientos.dart:283-302`, `:292-296`, `:338-341` |
