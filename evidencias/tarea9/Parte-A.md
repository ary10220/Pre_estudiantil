# Evidencia — Parte A: Analítica en todo el producto y embudos

## 1. Propósito de la Analítica Global
El objetivo de la Parte A fue extender la telemetría local de interacción a todos los flujos principales de la aplicación para medir con precisión las tasas de finalización, detectar en qué paso se pierden los usuarios (tasas de caída) y descubrir los puntos de fricción reales (errores de validación y búsquedas sin resultados).

---

## 2. Catálogo de Eventos Implementados

Todos los eventos siguen el estándar `objeto_accionPasada` y no transmiten datos por HTTP:

| Flujo Principal | Evento | Ubicación | Propiedades Permitidas | Pregunta de Decisión que Responde |
|---|---|---|---|---|
| **Movimientos** | `movimiento_iniciado` | `pantalla_nuevo_movimiento.dart` (`initState`) | `tipo`: `'gasto'` \| `'ingreso'` | ¿Cuántos usuarios inician la intención de registrar un movimiento? |
| | `movimiento_guardado` | `pantalla_nuevo_movimiento.dart` (tras guardar) | `tipo`: `'gasto'` \| `'ingreso'` | ¿Cuántos usuarios completan el registro exitosamente? |
| | `error_formulario_mostrado` | `pantalla_nuevo_movimiento.dart` (validación fallida) | `motivo`: `'concepto_vacio'`, `'monto_vacio'`, etc. | ¿Qué validación frena con mayor frecuencia al usuario? |
| **Metas de Ahorro (Tarea 8)** | `meta_creacion_iniciada` | `pantalla_nueva_meta.dart` (`initState`) | *(ninguna)* | ¿Cuántos usuarios inician la creación de una alcancía/meta? |
| | `meta_guardada` | `pantalla_nueva_meta.dart` (tras confirmación) | *(ninguna)* | ¿Cuántos usuarios logran configurar y guardar su meta? |
| | `fondos_meta_operados` | `pantalla_detalle_meta.dart` (tras operar) | `operacion`: `'asignar'` \| `'retirar'` \| `'transferir'` | ¿Qué tipo de operación de fondos es la más utilizada? |
| **Límites de Presupuesto** | `limite_iniciado` | `pantalla_limite.dart` (`initState`) | *(ninguna)* | ¿Cuántos usuarios abren la gestión de límites/presupuestos? |
| | `limite_guardado` | `pantalla_limite.dart` (tras guardar) | `alcance`: `'general'` \| `'categoria'` | ¿Cuántos usuarios consolidan un presupuesto mensual o por categoría? |
| **Búsqueda y Filtros** | `busqueda_sin_resultados` | `pantalla_movimientos.dart` (lista = 0 con filtros) | `origen`: `'texto'` \| `'filtros'` | ¿Cuántas búsquedas o combinaciones no devuelven datos? |

---

## 3. Embudos y Cálculo de Caídas

El servicio local `AnaliticaServicio.obtenerResumen()` realiza un agrupamiento local (`GROUP BY`) calculando:
1. **Tasa de Conversión (%):**  
   $$\text{Conversión} = \frac{\text{Éxitos}}{\text{Inicios}} \times 100$$
2. **Tasa de Caída (%):**  
   $$\text{Caída} = \frac{\text{Inicios} - \text{Éxitos}}{\text{Inicios}} \times 100$$

### El paso con la mayor caída y propuesta de mejora:
* **Paso crítico:** Entre `movimiento_iniciado` y `movimiento_guardado`.
* **Motivo detectado:** Los errores de validación (`error_formulario_mostrado`) revelan que `concepto_vacio` y `monto_vacio` son los principales obstáculos. El usuario móvil busca registrar rápido y la carga de llenar todos los campos provoca deserciones.
* **Propuesta IHC:** Sugerir categorías automáticas por horario y ofrecer botones de conceptos comunes ("Almuerzo", "Fotocopias", "Pasaje") para autocompletar en un solo toque.

---

## 4. Principio de Privacidad Estricta

* No se registran montos de dinero de los movimientos ni de las metas.
* No se registran conceptos ni textos libres escritos por el usuario.
* No se almacena correo electrónico ni `usuarioId`.
* Los motivos de error pertenecen a una **lista fija cerrada** predeterminada.

---

## 5. Panel de Métricas (`/analitica`)
La interfaz en `lib/pantallas/pantalla_analitica.dart` se rediseñó manteniendo una presentación simple y accesible:
* Tarjetas resumen por cada embudo (Movimientos, Metas y Límites) mostrando iniciados, guardados, tasa de éxito y tasa de caída.
* Tarjeta de efectividad del aviso de límite (Parte B) con tasa de disuasión.
* Tarjeta de fricción con desglose de motivos de error y búsquedas sin resultados.
* Lista cronológica de últimos eventos capturados.

---

## 6. Pruebas Automatizadas
Se implementó `test/analitica_flujos_test.dart` con 6 pruebas que validan los cálculos matemáticos de embudo, caídas, fricción y el estricto cumplimiento de la regla de privacidad.

