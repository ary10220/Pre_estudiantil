# Tarea 6 — E2E y feature de recurrentes

**Producto:** Presupuesto (UniBudget)  
**Feature:** Recurrentes  
**Fecha:** 03/11/2026  
**Video de la ejecución:** [tarea-6-test.mp4](tarea-6-test.mp4)
**Imagenes1:** [image1-tarea-6.png](image1-tarea-6.png)
**Imagenes2:** [image2-tarea-6.png](image2-tarea-6.png)

## 1. Regla de la feature

| Producto | Feature | Reglas | Lo que comprueba la prueba |
|---|---|---|---|
| Presupuesto | Recurrentes | Gasto semanal o mensual; genera la siguiente ocurrencia; cuenta en el presupuesto | Aparece la próxima ocurrencia y el consumo sube |

## 2. Qué se implementó

### Backend

- Tabla `recurrencias` y columna `movimientos.recurrencia_id`.
- Frecuencias válidas: `semanal` y `mensual`.
- Al crear un gasto recurrente se guarda la ocurrencia actual y se genera la siguiente.
- Al pagar una ocurrencia recurrente se genera la siguiente.
- Las ocurQrencias son movimientos normales, por lo que cuentan en el límite y en el presupuesto según su fecha.
- Endpoint `POST /movimientos` acepta `recurrente` y `frecuencia`.
- La app Express se exporta para poder iniciarla en las pruebas de integración.

### Flutter

- Selector **Recurrencia** en el formulario de nuevo movimiento: No repetir, Semanal o Mensual.
- La frecuencia se envía al backend al crear el gasto.
- Las tarjetas muestran `Recurrente Semanal` o `Recurrente Mensual`.
- La siguiente ocurrencia aparece en la lista de movimientos.

## 3. Suite antes y después de la feature

| Momento | Backend | Flutter unitarias | E2E presupuesto | E2E recurrentes |
|---|---:|---:|---:|---:|
| Antes de la feature | 37 pasan | 36 pasan | 1 pasa | No existía |
| Después de la feature | 46 pasan | 36 pasan | 1 pasa | 1 pasa |

La suite E2E completa se ejecutó en el emulador Android y quedó registrada en el video.

## 4. Comandos ejecutados

Backend, con la base de datos de desarrollo levantada:

```bash
cd servidor
npm test
```

Pruebas unitarias de Flutter:

```bash
flutter test
```

Pruebas E2E en Android, con `API_BASE_URL=http://10.0.2.2:3000`:

```bash
flutter test integration_test -d emulator-5554
```

Pruebas E2E específicas:

```bash
flutter test integration_test/presupuesto_test.dart -d emulator-5554
flutter test integration_test/recurrentes_test.dart -d emulator-5554
```

## 5. Resultados

### Backend

```text
ℹ tests 46
ℹ pass 46
ℹ fail 0
```

Incluye:

- Pruebas unitarias de fechas para frecuencia semanal y mensual.
- Prueba de integración API + base de datos:
  - Crea un gasto recurrente.
  - Verifica la ocurrencia actual y la siguiente.
  - Verifica que ambas cuenten en el límite.
  - Paga una ocurrencia y comprueba que se genere la siguiente.
  - Rechaza un ingreso recurrente y una frecuencia inválida.

### Flutter

```text
36 tests passed
```

### E2E

```text
registrar un gasto cambia el total
crear un gasto recurrente genera la próxima ocurrencia
All tests passed!
```

La ejecución completa está en [tarea-6-test.mp4](tarea-6-test.mp4).

## 6. Matriz de pruebas

| Criterio o flujo | Prueba | Qué verifica | Resultado |
|---|---|---|---|
| Crear gasto recurrente semanal | E2E `recurrentes_test.dart` | El formulario permite elegir Semanal y guardar | Cubierto |
| Aparece la ocurrencia actual | E2E `recurrentes_test.dart` | El concepto aparece en la lista | Cubierto |
| Aparece la próxima ocurrencia | E2E `recurrentes_test.dart` | El mismo concepto aparece dos veces | Cubierto |
| El consumo sube | E2E `recurrentes_test.dart` | El total de gastos aumenta el doble del monto | Cubierto |
| Cuenta en el presupuesto | Backend `recurrentes.integration.test.js` | `GET /limite` pasa de 10 a 15 | Cubierto |
| Frecuencia mensual | Backend `recurrentes.test.js` | Suma un mes y ajusta fin de mes | Cubierto |
| Frecuencia semanal | Backend `recurrentes.test.js` | Suma 7 días y cruza de mes | Cubierto |
| Frecuencia inválida | Backend `recurrentes.integration.test.js` | Responde 400 | Cubierto |
| Ingreso recurrente | Backend `recurrentes.integration.test.js` | Responde 400: solo gastos | Cubierto |
| Pago genera la siguiente ocurrencia | Backend `recurrentes.integration.test.js` | La lista pasa de 2 a 3 movimientos | Cubierto |
| Semilla | E2E + backend | Inicia sesión con `prueba@correo.com` y la semilla se ejecuta al levantar el backend | Cubierto |
| Flujo alternativo de UI | No automatizado | Cancelar, error de validación o sesión expirada en la interfaz | Parcial |
| Accesibilidad por rol y nombre | No automatizado | Búsqueda por rol/nombre semántico | Parcial: se usan etiquetas visibles |
| Visual | Video de la ejecución | La app muestra la ocurrencia actual y la siguiente | Parcial: evidencia manual |
| Regresión visual | No automatizado | Comparación contra una captura de referencia | Pendiente |

## 7. Evidencia de la ejecución

- Video: [tarea-6-test.mp4](tarea-6-test.mp4)
- Imagen1: [image1-tarea-6.png](image1-tarea-6.png)
- Imagen2: [image2-tarea-6.png](image2-tarea-6.png)
- Backend: `npm test` con 46 pruebas aprobadas.
- Flutter: `flutter test` con 36 pruebas aprobadas.
- E2E: `flutter test integration_test -d emulator-5554` con las pruebas de presupuesto y recurrentes aprobadas.

Entorno de la ejecución:

| Elemento | Valor |
|---|---|
| Flutter | 3.47.8 |
| Dart | 3.13.7 |
| Emulador | Pixel 4a API 33 (`emulator-5554`) |
| Backend | Node.js 24 + Express + Prisma |
| Base de datos | PostgreSQL 16 en Docker |
| API desde el emulador | `http://10.0.2.2:3000` |

## 8. Cómo reproducir

1. Levantar el backend y la base de datos:

```bash
cd servidor
docker compose -f docker-compose.dev.yml up -d --build
```

2. Configurar el `.env` de la raíz para el emulador Android:

```env
API_BASE_URL=http://10.0.2.2:3000
APP_NAME="UniBudget"
```

3. Encender el emulador y ejecutar:

```bash
flutter test integration_test -d emulator-5554
```

Para probar en web, cambiar `API_BASE_URL` a `http://localhost:3000` y ejecutar:

```bash
flutter run -d chrome
```

## 9. Archivos principales

Backend:

- `servidor/recurrentes.js`
- `servidor/servidor.js`
- `servidor/prisma/schema.prisma`
- `servidor/prisma/migrations/20261030120000_recurrentes/migration.sql`
- `servidor/tests/recurrentes.test.js`
- `servidor/tests/recurrentes.integration.test.js`

Flutter:

- `lib/modelos/movimiento.dart`
- `lib/servicios/servicio_movimientos.dart`
- `lib/pantallas/pantalla_nuevo_movimiento.dart`
- `lib/pantallas/pantalla_movimientos.dart`
- `integration_test/presupuesto_test.dart`
- `integration_test/recurrentes_test.dart`

## 10. Observaciones

- Los E2E dejan movimientos de prueba en la cuenta semilla.
- La prueba de integración del backend crea un usuario temporal y lo elimina al finalizar.
- Para ejecutar el E2E en Android, el `.env` debe apuntar a `10.0.2.2`; para web, a `localhost`.
- La matriz marca como parciales los flujos alternativos de UI, la accesibilidad por rol/nombre y la regresión visual porque todavía no tienen pruebas automatizadas específicas.
