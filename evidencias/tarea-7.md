# Tarea 7 — Feedback recibido y control de presupuestos por categoría y mes

**Producto:** Presupuesto Estudiantil (UniBudget)  
**Fecha:** 04/11/2026  
**Rama:** `mendoza`  
**Repositorio:** [https://github.com/ihc-team/Pre_estudiantil](https://github.com/ihc-team/Pre_estudiantil)

---

## 1. Feedback recibido de evaluadores externos

Los reportes completos de evaluación recibidos durante la Clase 19 se encuentran archivados en:

- **Alex Ticlla Choque** (Mascota al Día): [feedback-recibido/alex-ticlla.md](feedback-recibido/alex-ticlla.md)
- **Job Natanael Contreras Garzón** (Trueque U): [feedback-recibido/job-contreras.md](feedback-recibido/job-contreras.md)

### Síntesis de hallazgos y acciones tomadas

| Evaluador | Observación principal | Acción en Tarea 7 |
|---|---|---|
| **Alex Ticlla** | Falta filtrar los ingresos en el historial (Punto 6 del reporte). | **Cambio 1 (`fix`):** Se agregó el chip `Ingresos` al historial en backend y frontend, y se reemplazó el contenedor por `Wrap` para evitar desbordes en pantallas estrechas. |
| **Job Contreras** | Uso de colores de alerta armónicos (sugerencia de naranja para aviso) y distinción clara de que los ingresos no interfieran con las reglas de consumo de gastos. | **Cambio 2 (`feat`):** Modelo de 3 estados con color naranja (`Colores.aviso`) al alcanzar $\ge 80\%$, rojo al superar el $100\%$ y verde normal. Se garantizó por regla que los ingresos no consumen presupuesto de categoría ni global. |

---

## 2. Commits de la entrega

La entrega se divide en dos commits atómicos independientes:

1. **`fix: permitir filtrar ingresos en el historial`**
   - Agrega `'ingresos'` a la lista de filtros del historial en backend (`servidor/historial.js`).
   - Añade el valor `ingresos` al enum `FiltroHistorial` y su etiqueta en `lib/modelos/evento.dart`.
   - Ajusta la barra de filtros en `lib/pantallas/pantalla_historial.dart` con `Wrap` para garantizar adaptabilidad a cualquier ancho de pantalla (Ley de Fitts y heurísticas de diseño responsive).
   - Añade pruebas unitarias en `servidor/tests/historial.test.js`.

2. **`feat: controlar presupuestos por categoría y mes`**
   - Lógica pura de cálculo de estados y recálculo en `servidor/presupuestos_reglas.js`.
   - Suite de pruebas de backend en `servidor/tests/presupuestos.test.js` (8 tests que verifican cálculo, $\ge 80\%$, excedido, ingresos excluidos, recálculo por mover categoría y mes).
   - Helper de estados y cálculo visual en `lib/modelos/presupuesto_categoria.dart`.
   - Selector de mes navegable (`‹ Mes Año ›`) y tarjetas con barra de progreso semántica (`LinearProgressIndicator`) en `lib/pantallas/pantalla_limite.dart`.
   - Corrección de spread de mes en `lib/servicios/servicio_limite.dart`.
   - Suite unitaria Flutter en `test/presupuesto_categoria_test.dart` (5 tests).
   - Suite de integración E2E en `integration_test/presupuesto_test.dart` (3 escenarios: gasto cambia total, ingreso no altera consumo de categoría, y mover gasto recalcula presupuestos).

---

## 3. Reglas de negocio del presupuesto por categoría

1. **Unicidad e idempotencia:** Cada combinación `(usuarioId, mes, categoria)` es única (`@@unique`). Las actualizaciones usan `upsert` evitando duplicaciones.
2. **Consumo exclusivo por gastos:** Solo las transacciones con `tipo: 'gasto'` consumen presupuesto. Los ingresos **no** alteran el gasto acumulado ni reducen el saldo de las categorías.
3. **Semántica de estados:**
   - **Normal (Verde):** Consumo $< 80\%$ del límite.
   - **Aviso (Naranja / Ámbar):** Consumo entre $80\%$ y $100\%$ del límite. Comunica proximidad al límite sin ser alarmista.
   - **Excedido (Rojo):** Consumo $> 100\%$ del límite. Muestra el monto excedido.
   - **Sin límite (Gris):** La categoría no tiene un tope definido para el mes consultado.
4. **Recálculo bidireccional:** Modificar o mover un gasto de categoría o de fecha (mes) actualiza y recalcula de inmediato los presupuestos de ambos periodos/categorías afectados.

---

## 4. Suites de prueba: Antes y Después

| Suite de pruebas | Antes de Tarea 7 | Después de Tarea 7 | Incremento |
|---|---:|---:|---:|
| **Backend (Node.js `--test`)** | 46 pasan | **55 pasan** | +9 tests (2 en historial, 8 en presupuestos - 1 refactor) |
| **Flutter unitarias (`flutter test`)** | 36 pasan | **41 pasan** | +5 tests (`presupuesto_categoria_test.dart`) |
| **Flutter E2E (`integration_test`)** | 1 escenario | **3 escenarios** | +2 escenarios (ingresos sin consumo, recálculo por mover categoría) |

---

## 5. Matriz de verificación

| Criterio evaluado | Archivo de prueba | Qué verifica | Resultado |
|---|---|---|---|
| Filtro de ingresos en historial | `servidor/tests/historial.test.js` | Filtra solo eventos de tipo `ingreso_registrado` | Cubierto |
| Historial no mezcla gastos con ingresos | `servidor/tests/historial.test.js` | El filtro ingresos excluye gastos y pagos | Cubierto |
| Estado normal (< 80%) | `servidor/tests/presupuestos.test.js` | Porcentaje y saldo restante correcto | Cubierto |
| Estado aviso (>= 80%) | `servidor/tests/presupuestos.test.js` | Activa aviso preventivo sin excederse | Cubierto |
| Estado excedido (> 100%) | `servidor/tests/presupuestos.test.js` | Activa alerta de presupuesto superado | Cubierto |
| Ingreso no consume categoría | `servidor/tests/presupuestos.test.js` | Agregar ingreso deja intacto el gasto acumulado | Cubierto |
| Mover gasto entre categorías | `servidor/tests/presupuestos.test.js` | Resta de categoría origen y suma a destino | Cubierto |
| Mover gasto entre meses | `servidor/tests/presupuestos.test.js` | Recalcula el saldo de ambos meses | Cubierto |
| Eliminar gasto | `servidor/tests/presupuestos.test.js` | Devuelve el saldo disponible a la categoría | Cubierto |
| Modelo Flutter estados y progreso | `test/presupuesto_categoria_test.dart` | `estado`, `colorEstado`, `progresoBarra`, `porcentajeTexto` | Cubierto |
| Parsing JSON de presupuesto | `test/presupuesto_categoria_test.dart` | `desdeJson` maneja enteros, doubles y nulos | Cubierto |
| E2E: Flujo general de gastos | `integration_test/presupuesto_test.dart` | Crear gasto impacta total | Cubierto |
| E2E: Ingreso no altera presupuesto | `integration_test/presupuesto_test.dart` | Registrar ingreso en Comida no altera su gasto en pantalla Límite | Cubierto |
| E2E: Mover gasto de categoría | `integration_test/presupuesto_test.dart` | Editar gasto a Transporte actualiza las categorías correspondientes | Cubierto |

---

## 6. Comandos de comprobación

Para reproducir y validar todas las pruebas de esta entrega:

### Backend
```bash
cd servidor
npm test
cd ..
```

### Flutter (Análisis estático y pruebas unitarias)
```bash
flutter analyze
flutter test
```

### Pruebas E2E (con servidor activo y emulador conectado)
```bash
flutter test integration_test/presupuesto_test.dart
```

