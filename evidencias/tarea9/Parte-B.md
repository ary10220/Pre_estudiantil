# Evidencia — Parte B: Aviso antes de superar el límite en gastos nuevos y editados

## 1. Propósito de la Funcionalidad
La funcionalidad fue diseñada para prevenir gastos impulsivos y proteger el presupuesto del usuario. Antes de confirmar un gasto en la base de datos, el sistema verifica si este provocará que se sobrepase el límite asignado a su categoría en el mes correspondiente. 

Si existe un exceso:
* Informa de forma transparente el monto exacto por el cual se excederá (`exceso = totalResultante - limiteCategoria`).
* Solicita una confirmación explícita mediante un diálogo modal accesible.
* Permite al usuario cancelar para conservar su presupuesto intacto o continuar asumiendo el gasto excedido.

---

## 2. Reglas de Negocio e Interacción Implementadas

1. **Exclusivo para Gastos:**
   * Los movimientos de tipo **ingreso** nunca generan advertencia de límite.
2. **Aplicable tanto a Gastos Nuevos como Editados:**
   * **Gasto nuevo:** Evalúa `(gastadoActualEnCategoria + montoNuevo) > limiteCategoria`.
   * **Gasto editado:** Descuenta el monto previo del mismo movimiento para evitar una doble contabilidad del gasto modificado:  
     `(gastadoActualEnCategoria - montoPrevio + montoNuevo) > limiteCategoria`.
3. **Comportamiento ante Decisión del Usuario:**
   * **Cancelar ("Seguir editando" / "Cancelar"):** No aplica ningún cambio, no realiza peticiones al backend y mantiene el formulario abierto para corregir el monto o descartar. Emite el evento de analítica `aviso_limite_cancelado`.
   * **Confirmar ("Guardar de todas formas"):** Procede con la persistencia del movimiento en el servidor, dejando la categoría en estado excedido. Emite el evento `aviso_limite_confirmado`.
4. **Cero Impacto en Backend:**
   * No requirió modificar controladores, modelos de Prisma ni esquemas de base de datos. La información de presupuestos por categoría y mes ya se consulta mediante el servicio existente `ServicioLimite.leerPorCategoria(mes)` (`GET /presupuestos-categoria`).

---

## 3. Instrumentación de Eventos de Analítica Asociados

Para responder a la pregunta de usabilidad: *¿La advertencia disuade eficazmente a los usuarios de exceder su presupuesto?*, se integraron 3 eventos específicos:

| Evento | Momento de Disparo | Propiedades Permitidas | Propósito de Decisión |
|---|---|---|---|
| `aviso_limite_mostrado` | Inmediatamente al desplegarse el diálogo modal de advertencia | `categoria` (ej. `'comida'`) | Conocer la frecuencia con que los usuarios intentan sobrepasar sus límites. |
| `aviso_limite_confirmado` | Cuando el usuario pulsa "Guardar de todas formas" | `categoria` (ej. `'comida'`) | Medir cuántos usuarios priorizan el gasto sobre la advertencia. |
| `aviso_limite_cancelado` | Cuando el usuario pulsa "Cancelar" | `categoria` (ej. `'comida'`) | Medir la efectividad del diálogo como freno a gastos excesivos. |

*Todos los eventos cumplen con la regla estricta de privacidad: no registran montos, conceptos, correos ni identificadores de usuario.*

---

## 4. Archivos Creados y Modificados

* **Modificado: `lib/pantallas/pantalla_nuevo_movimiento.dart`**
  * Se importó el modelo `PresupuestoCategoria`.
  * En `_cargarResumen()`, se agregó la carga concurrente y resiliente de los presupuestos por categoría (`ServicioLimite.leerPorCategoria(mes)`).
  * Se implementó el método `_verificarExcesoCategoria(montoNuevo)` con lógica para gastos nuevos y editados.
  * Se implementó el modal accesible `_pedirConfirmacionSuperacionLimite(...)` con cálculo y formateo de moneda en bolivianos (`Bs`).
  * En `_guardar()`, se interrumpió el guardado si hay exceso y el usuario desiste de continuar.
* **Creado: `test/aviso_limite_test.dart`**
  * Suite con pruebas unitarias para los 3 casos: (1) gasto sin aviso, (2) cálculo de exceso y exención de ingresos, (3) descuento de monto previo en edición, y (4) trazabilidad de los 3 eventos de analítica.

---

## 5. Casos de Prueba Verificados

1. **Caso 1: Gasto sin aviso**
   * Categoría con límite de Bs 100 y gasto acumulado de Bs 30.
   * Se registra un nuevo gasto por Bs 30.
   * **Resultado:** Se guarda de manera directa e instantánea sin interrumpir el flujo.
2. **Caso 2: Gasto con aviso cancelado**
   * Se intenta registrar un gasto por Bs 90 en la misma categoría (total acumulado sería Bs 120, excediendo por Bs 20).
   * **Resultado:** Se muestra el diálogo informando *"Con este gasto superarás el límite de la categoría Comida por Bs 20,00"*. Al pulsar "Cancelar", la base de datos no se altera y el formulario permanece activo.
3. **Caso 3: Gasto con aviso confirmado**
   * Ante la misma advertencia, el usuario pulsa "Guardar de todas formas".
   * **Resultado:** El gasto se registra exitosamente en el backend, la lista de movimientos se actualiza y la categoría pasa a estado excedido.

