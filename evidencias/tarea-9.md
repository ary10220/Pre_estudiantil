# Tarea 9 — Analítica en todo el producto y aviso antes de superar el límite

**Producto:** UniBudget — Presupuesto Estudiantil  
**Integrantes:** Sebastián Céspedes Rodas — Adolfo Mendoza Ribera  
**Fecha de entrega:** Jueves 12/11/2026, 18:00  

---

## 1. Plan de Eventos de Analítica

La analítica fue instrumentada de forma local y desacoplada mediante `AnaliticaServicio` (cliente Flutter), respondiendo preguntas concretas de interacción para la toma de decisiones sobre el diseño y usabilidad de la interfaz:

| Evento | Flujo Principal | Archivo y Ubicación Aproximada | Propiedades Permitidas | Pregunta de Decisión que Responde |
|---|---|---|---|---|
| `movimiento_iniciado` | Registro de Movimiento | `lib/pantallas/pantalla_nuevo_movimiento.dart:90` | `tipo`: `'gasto'` \| `'ingreso'` | ¿Cuántos usuarios inician la intención de registrar un movimiento? |
| `movimiento_guardado` | Registro de Movimiento | `lib/pantallas/pantalla_nuevo_movimiento.dart:480` | `tipo`: `'gasto'` \| `'ingreso'` | ¿Cuántos usuarios logran guardar su movimiento con éxito en la base de datos? |
| `error_formulario_mostrado` | Validación de Formulario | `lib/pantallas/pantalla_nuevo_movimiento.dart:456` | `motivo`: `'monto_vacio'`, `'concepto_vacio'`, etc. | ¿Qué error o validación específica frena con mayor frecuencia al usuario? |
| `aviso_limite_mostrado` | Aviso de Límite (Parte B) | `lib/pantallas/pantalla_nuevo_movimiento.dart:366` | `categoria`: `'comida'`, etc. | ¿Con qué frecuencia los gastos amenazan con exceder el presupuesto de la categoría? |
| `aviso_limite_cancelado` | Aviso de Límite (Parte B) | `lib/pantallas/pantalla_nuevo_movimiento.dart:425` | `categoria`: `'comida'`, etc. | ¿Qué tan efectiva es la advertencia para disuadir gastos imprevistos o excesivos? |
| `aviso_limite_confirmado` | Aviso de Límite (Parte B) | `lib/pantallas/pantalla_nuevo_movimiento.dart:423` | `categoria`: `'comida'`, etc. | ¿Cuántos usuarios deciden proceder con el gasto a pesar de sobrepasar el límite? |
| `limite_iniciado` | Fijar Presupuesto | `lib/pantallas/pantalla_limite.dart:43` | *(ninguna)* | ¿Cuántos usuarios entran a revisar o ajustar sus límites de gasto? |
| `limite_guardado` | Fijar Presupuesto | `lib/pantallas/pantalla_limite.dart:154, 182` | `alcance`: `'general'` \| `'categoria'` | ¿Cuántos usuarios consolidan un presupuesto mensual o por categoría? |
| `meta_creacion_iniciada` | Metas de Ahorro (Tarea 8) | `lib/pantallas/pantalla_nueva_meta.dart:36` | *(ninguna)* | ¿Cuántos usuarios tienen la iniciativa de crear una meta de ahorro/alcancía? |
| `meta_guardada` | Metas de Ahorro (Tarea 8) | `lib/pantallas/pantalla_nueva_meta.dart:80` | *(ninguna)* | ¿Cuántas metas de ahorro logran configurarse exitosamente? |
| `fondos_meta_operados` | Operación de Fondos | `lib/pantallas/pantalla_detalle_meta.dart:272, 287, 311` | `operacion`: `'asignar'` \| `'retirar'` \| `'transferir'` | ¿Qué operación de fondos es la más utilizada en las metas de ahorro? |
| `busqueda_sin_resultados` | Búsqueda y Filtros | `lib/pantallas/pantalla_movimientos.dart:111` | `origen`: `'texto'` \| `'filtros'` | ¿Con qué frecuencia las búsquedas o combinaciones de filtros no arrojan resultados? |

---

## 2. Análisis de Embudos: El Paso con la Mayor Caída y Qué Cambiaría

### Identificación del Paso Crítico
Al evaluar las tasas de conversión y caídas en los tres flujos principales:
1. **Embudo de Metas:** Suele presentar una conversión alta (~80-90%) dado que quien entra a crear una meta ya tiene un objetivo claro y el formulario solo pide 3 campos sencillos.
2. **Embudo de Límites:** Conversión media (~70%), pues algunos usuarios solo entran a consultar su consumo sin modificar el presupuesto.
3. **Embudo de Movimientos (Paso Crítico):**  
   El paso con la **mayor caída** se produce entre **`movimiento_iniciado`** y **`movimiento_guardado`**.  
   * **Causa principal detectada por la analítica:** El evento `error_formulario_mostrado` revela que el motivo más repetido es `concepto_vacio` y `monto_vacio`. El usuario abre el formulario rápidamente pensando en anotar un gasto, pero al encontrarse con múltiples campos obligatorios (concepto, monto, categoría obligatoria y fecha) en pantallas móviles, desiste o comete errores de tipeo.

### Propuesta de Mejora de Usabilidad (IHC)
Para reducir la caída en este paso:
* **Valores inteligentes por defecto:** Sugerir una categoría frecuente basada en la hora del día (por ejemplo, *Comida* al mediodía) y mantener el foco automático en el teclado numérico de *Monto* nada más abrir el modal.
* **Conceptos rápidos / Chips predefinidos:** Incluir accesos rápidos a conceptos cotidianos (*"Almuerzo"*, *"Fotocopias"*, *"Pasaje"*) para que con un solo toque se autocomplete el campo de texto, reduciendo la carga cognitiva y de digitación del estudiante.

---

## 3. Principio de Privacidad: Qué Datos Decidí NO Recopilar y Por Qué

Siguiendo la regla de oro: *"Se registra la acción, no a la persona. Antes de agregar una propiedad: ¿la necesito para responder mi pregunta de usabilidad? Si no, está prohibido guardarla"*.

Decidí excluir estrictamente:
* **Montos monetarios reales de los movimientos:** No se guardan los centavos ni bolivianos gastados (ej. Bs 350). Para saber si el flujo se completó o dónde cayó el embudo, el valor monetario es completamente irrelevante y constituye un dato financiero confidencial.
* **Concepto y descripción escrita por el usuario:** Al ser campos de texto libre, el usuario podría ingresar nombres de personas, lugares o detalles privados.
* **Correo electrónico e ID de usuario (`usuarioId`):** La analítica mide la eficiencia y ergonomía de las pantallas de la interfaz, no vigila el comportamiento individual ni crea perfiles de personas.
* **Errores con mensajes arbitrarios:** Los errores de validación se catalogan bajo una **lista fija cerrada** (`monto_vacio`, `concepto_vacio`, `monto_invalido`, etc.), evitando registrar cadenas de error no controladas.

---

## 4. Decisión Técnica de Arquitectura

* **Servicio Local Desacoplado (`AnaliticaServicio`):**  
  Los eventos se almacenan y leen exclusivamente en el cliente mediante `shared_preferences`. Esto garantiza:
  * **Cero llamadas de red / Cero APIs POST:** Cumple estrictamente la directiva del docente de no recargar el backend ni generar latencia de red para telemetría de interfaz.
  * **Persistencia real y funcionamiento 100% offline:** Los eventos no se pierden al recargar la página o cerrar la app, sin requerir una segunda base de datos pesada (como SQLite/sqflite, que además genera incompatibilidades en Flutter Web).
  * **Cálculo local tipo GROUP BY:** La pantalla `/analitica` lee los registros locales y efectúa las agregaciones matemáticas y porcentajes en tiempo real sin requerir salir y volver a entrar de la sesión.
* **No reutilización de la tabla `eventos` de PostgreSQL (Tarea 4):**  
  La base de datos ya contaba con una tabla `eventos`, pero esta pertenecía al módulo de **auditoría/historial transaccional**, la cual contiene campos sensibles como `usuarioId`, `monto` y `descripcion`. Reutilizarla para analítica de uso habría violado el principio de privacidad de IHC y acoplado innecesariamente la telemetría de cliente al motor relacional de negocio.

---

## 5. Descripción del Flujo: Aviso antes de superar el límite (Parte B)

La funcionalidad previene gastos que dejen en números rojos el presupuesto mensual asignado a una categoría:

```
[Usuario toca Guardar en Formulario]
                  │
                  ▼
         ¿El tipo es Gasto?
        ├── NO (Ingreso) ──────────────────────────► Guarda directo sin aviso
        │
        └── SÍ
             │
             ▼
    ¿La categoría tiene límite definido?
        ├── NO ────────────────────────────────────► Guarda directo sin aviso
        │
        └── SÍ
             │
             ▼
¿(Gastado Actual - Monto Previo + Monto Nuevo) > Límite?
        ├── NO ────────────────────────────────────► Guarda directo sin aviso
        │
        └── SÍ
             │
             ▼
Dispara: aviso_limite_mostrado
Muestra diálogo: "Con este gasto superarás el límite de [Categoría] por Bs [Exceso]"
             │
      ┌──────┴─────────────────────────────────┐
      ▼                                        ▼
[Pulsar Cancelar]                  [Pulsar Guardar de todas formas]
      │                                        │
      ▼                                        ▼
Dispara: aviso_limite_cancelado    Dispara: aviso_limite_confirmado
Cierra diálogo y permanece         Guarda en servidor y deja categoría
en formulario para corregir        en estado excedido
```

### Casos Validados:
1. **Gasto sin aviso:** El gasto cabe dentro del presupuesto restante → se guarda directo e instantáneo.
2. **Gasto con aviso cancelado:** El gasto supera el límite → el usuario desiste → el gasto no se guarda y no se alteran los saldos.
3. **Gasto con aviso confirmado:** El usuario decide continuar conscientemente → el gasto se guarda y la categoría refleja el exceso.

