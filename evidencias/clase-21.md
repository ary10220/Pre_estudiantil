# Evidencia Clase 21: Analítica de Interacción ("Dos Eventos, Un Panel, Una Decisión")

## 1. Contexto y Requisitos del Docente
Para esta entrega se solicitó instrumentar la analítica de interacción centrada en el embudo del flujo principal de la aplicación: registrar un movimiento.

Se establecieron premisas y restricciones técnicas fundamentales según las observaciones del docente:
* **Sin APIs de Analítica ni Peticiones POST:** No se debe crear endpoints adicionales en el backend ni realizar llamadas de red (`http.post`) para registrar los eventos de uso.
* **Llamada Directa como Servicio:** El tracking debe registrarse directamente en el cliente mediante un servicio dedicado, ejecutado inmediatamente después de que la acción de guardado se confirme exitosamente.
* **Fluidez en la Experiencia:** No debe requerirse cerrar sesión, recargar forzadamente el navegador ni salirse de la aplicación para consultar los resultados.
* **Privacidad Estricta:** Registrar la interacción, no a la persona. Prohibido almacenar correos, nombres, identificadores de usuario, montos de dinero o descripciones de movimientos. Solo se almacena el tipo de movimiento (`ingreso` o `gasto`).
* **Persistencia sin Complejidad:** La analítica debe persistir frente a recargas, pero sin introducir segundas bases de datos pesadas (como SQLite en entorno web) ni alterar la tabla de auditoría/historial existente en PostgreSQL (la cual contiene datos financieros y personales).

---

## 2. Decisiones Arquitectónicas y de Diseño

1. **Almacenamiento Local Persistente (`shared_preferences`):**
   * En lugar de instalar dependencias nuevas que pudiesen causar fricción en Flutter Web (como SQLite/sqflite), se aprovechó la persistencia local que ya formaba parte del proyecto.
   * Modela de forma lógica la tabla de eventos donde cada registro contiene: `{ evento, props: { tipo }, fecha }`.
   * El cálculo del panel equivale a ejecutar un agrupamiento y conteo (`GROUP BY evento`) a nivel local para calcular el porcentaje de conversión.

2. **Aislamiento y Resiliencia del Servicio:**
   * El servicio de analítica fue diseñado de manera hermética: cualquier posible eventualidad de serialización o escritura es capturada internamente, garantizando que el flujo principal del usuario (guardar movimientos) nunca se interrumpa ni muestre errores falsos.
   * Cuenta con un sanitizador preventivo de tipos para transformar estructuras internas (como enumeradores de Dart) en cadenas legibles y seguras para JSON.

3. **Instrumentación Precisa de los Eventos:**
   * `movimiento_iniciado`: Se dispara una sola vez en el ciclo de vida del formulario (`initState`) y exclusivamente cuando se trata de la creación de un nuevo movimiento (no al editar uno existente).
   * `movimiento_guardado`: Se ejecuta una única vez únicamente después de que el backend ha respondido con éxito la creación del registro.

---

## 3. Archivos Creados y Modificados

### Archivos Nuevos

1. **`lib/servicios/analitica.dart` (Servicio Local de Analítica):**
   * Contiene la lógica del servicio `AnaliticaServicio`.
   * Expone el método `track(evento, props)` para almacenar registros con marca de tiempo UTC de manera secuencial y segura.
   * Expone `obtenerResumen()` para totalizar conteos de aperturas, guardados exitosos, tasa de conversión (%) y la lista cronológica de últimos eventos.
   * Incluye método utilitario para reiniciar datos en entornos de pruebas automatizadas.

2. **`lib/pantallas/pantalla_analitica.dart` (Panel de Métricas):**
   * Interfaz gráfica del panel que consume directamente el servicio local sin emitir llamadas HTTP.
   * Presenta las tarjetas resumen del embudo:
     * Movimientos iniciados (aperturas del formulario).
     * Movimientos guardados (confirmaciones en la base de datos).
     * Tasa de finalización porcentual con indicador visual.
   * Lista detallada de los últimos eventos capturados con fecha y propiedades sanitizadas.

3. **`test/analitica_test.dart` (Pruebas Unitarias de Analítica):**
   * Suite de pruebas deterministas e independientes.
   * Valida que `movimiento_iniciado` se registre con su propiedad `tipo` y sin datos personales/financieros (email, monto, concepto, usuario).
   * Valida que `movimiento_guardado` no se dispare ante fallos de validación o red y únicamente proceda ante éxito confirmado.
   * Comprueba la persistencia y la fórmula matemática del porcentaje de conversión.

---

### Archivos Modificados

1. **`lib/pantallas/pantalla_nuevo_movimiento.dart`:**
   * Se instrumentó el disparo de `movimiento_iniciado` en `initState()` bajo la condición de movimiento nuevo.
   * Se incorporó el llamado a `AnaliticaServicio.track('movimiento_guardado', ...)` dentro del bloque de guardado exitoso, inmediatamente después de la confirmación del servicio de red.

2. **`lib/pantallas/pantalla_movimientos.dart`:**
   * Se integró una acción en la barra superior (`AppBar`) con el botón **Analítica**, manteniendo la misma semántica visual que las opciones existentes (*Historial* y *Límite*).
   * Permite acceder al panel mediante la navegación interna de la aplicación, evitando conflictos de redirección por sesión al escribir rutas directas en el navegador.

3. **`lib/configuracion/rutas.dart`:**
   * Se registró la constante de ruta nombrada `/analitica` y su vinculación con la pantalla correspondiente en el mapa global de rutas.

4. **Backend (`servidor/` e infraestructura Docker):**
   * Se mantuvieron completamente limpios el servidor Node.js/Express (`servidor.js`) y el esquema de Prisma (`schema.prisma`). No se agregaron tablas ni rutas HTTP para analítica.

---

## 4. Verificación y Resultados
* **Pruebas Automatizadas:** La suite en `test/analitica_test.dart` ejecutó las 3 pruebas de embudo y privacidad de forma exitosa (`All tests passed!`).
* **Verificación Funcional:** Se validó en entorno local que al iniciar la creación de movimientos y completarlos, el panel de Analítica actualiza de forma inmediata los contadores y el porcentaje de finalización sin peticiones HTTP adicionales.

