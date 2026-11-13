# Inicio rápido

Guía para levantar el backend con Docker y ejecutar las pruebas de integración de Flutter en Linux, macOS o Android.

## Tabla de contenido

- [Requisitos](#requisitos)
- [1. Levantar el backend y la base de datos](#1-levantar-el-backend-y-la-base-de-datos)
- [2. Configurar la URL de la API en Flutter](#2-configurar-la-url-de-la-api-en-flutter)
- [3. Iniciar el emulador o simulador](#3-iniciar-el-emulador-o-simulador)
- [4. Ejecutar la app](#4-ejecutar-la-app)
- [5. Ejecutar las pruebas de integración](#5-ejecutar-las-pruebas-de-integración)
- [6. Pruebas unitarias (opcional)](#6-pruebas-unitarias-opcional)
- [7. Apagar el backend](#7-apagar-el-backend)
- [Problemas comunes](#problemas-comunes)

## Requisitos

- Docker con `docker compose`.
- Flutter instalado.
- Un dispositivo o emulador:
  - Linux/Windows: Android Studio con un emulador Android.
  - macOS: Xcode con el simulador de iOS (o la app de escritorio de macOS).
- Terminal en la raíz del proyecto.

## 1. Levantar el backend y la base de datos

Entra a la carpeta del servidor:

```bash
cd servidor
```

Crea el `.env` del backend si todavía no existe:

```bash
[ -f .env ] || cp .env.example .env
```

Levanta los contenedores:

```bash
docker compose -f docker-compose.dev.yml up -d --build
```

Verifica que estén funcionando:

```bash
docker compose -f docker-compose.dev.yml ps
```

Espera hasta ver `healthy` en `pre_estudiantil_db_dev` y `pre_estudiantil_api_dev`.

Prueba la API:

```bash
curl http://localhost:3000/ping
```

Respuesta esperada:

```json
{"mensaje":"Servidor funcionando"}
```

El contenedor aplica las migraciones y ejecuta la semilla automáticamente. Si el usuario de prueba ya existe, la semilla no falla: solo lo omite.

Para ver los logs:

```bash
docker compose -f docker-compose.dev.yml logs -f pre_estudiantil-api
```

Salir de los logs: `Ctrl + C`.

Si necesitas ejecutar la semilla manualmente:

```bash
docker compose -f docker-compose.dev.yml exec -T pre_estudiantil-api npx prisma db seed
```

Usuario de prueba:

```text
Correo: prueba@correo.com
Contraseña: 123456
```

## 2. Configurar la URL de la API en Flutter

En la raíz del proyecto debe existir un archivo `.env`. La URL depende del dispositivo donde vas a ejecutar la app.

### Emulador de Android

```env
API_BASE_URL=http://10.0.2.2:3000
APP_NAME="UniBudget"
```

`10.0.2.2` es el `localhost` de la computadora visto desde el emulador de Android.

### macOS: simulador de iOS o app de escritorio

```env
API_BASE_URL=http://localhost:3000
APP_NAME="UniBudget"
```

El simulador de iOS y la app de escritorio comparten la red de la Mac, por eso usan `localhost`.

### iPhone físico

Usa la IP local de la Mac. Para obtenerla:

```bash
ipconfig getifaddr en0
```

Si `en0` no devuelve una IP, prueba con `en1`.

Luego configura el `.env` con esa IP:

```env
API_BASE_URL=http://192.168.1.50:3000
APP_NAME="UniBudget"
```

Requisitos para el iPhone físico:

- La Mac y el iPhone deben estar en la misma red Wi-Fi.
- El firewall de la Mac debe permitir el puerto `3000`.
- El backend debe estar levantado.

Después de cambiar el `.env`, cierra y vuelve a abrir la app.

## 3. Iniciar el emulador o simulador

### En Linux o Windows: emulador de Android

Desde la raíz del proyecto:

```bash
flutter emulators
flutter emulators --launch Pixel_4a_API_33
flutter devices
```

Anota el ID del emulador. Normalmente es `emulator-5554`.

### En macOS: simulador de iOS

Verifica el entorno y abre el simulador:

```bash
flutter doctor
open -a Simulator
```

Si no aparece, también puedes usar:

```bash
flutter emulators
flutter emulators --launch apple_ios_simulator
```

Verifica que Flutter lo detecte:

```bash
flutter devices
```

Anota el ID del simulador de iOS. Puede ser un nombre como `iPhone 15` o un identificador largo.

Si prefieres usar la app de escritorio de macOS, el dispositivo se llama `macos` y no necesitas abrir el simulador.

## 4. Ejecutar la app

Desde la raíz del proyecto:

```bash
flutter pub get
flutter run -d <ID_DEL_DISPOSITIVO>
```

Ejemplos:

```bash
flutter run -d emulator-5554
flutter run -d "iPhone 15"
flutter run -d macos
```

Usa el ID que apareció en `flutter devices`.

## 5. Ejecutar las pruebas de integración

Los tests están en la carpeta `integration_test/`. Con el backend, la base de datos y el dispositivo funcionando, ejecuta desde la raíz:

```bash
flutter test integration_test/presupuesto_test.dart -d <ID_DEL_DISPOSITIVO>
```

Ejemplos:

```bash
flutter test integration_test/presupuesto_test.dart -d emulator-5554
flutter test integration_test/presupuesto_test.dart -d "iPhone 15"
flutter test integration_test/presupuesto_test.dart -d macos
```

La prueba:

- Inicia sesión con el usuario de prueba si no hay sesión activa.
- Entra a **Nuevo movimiento**.
- Registra un gasto de **Comida** por **Bs 1,23**.
- Verifica que el total de gastos aumente y que el movimiento aparezca en la lista.

La primera ejecución compila e instala la app, por lo que puede tardar varios minutos. Al final debe mostrar:

```text
All tests passed!
```

La prueba deja un movimiento creado en la base de datos.

Para ejecutar solo la prueba de recurrentes:

```bash
flutter test integration_test/recurrentes_test.dart -d <ID_DEL_DISPOSITIVO>
```

Esta prueba crea un gasto semanal y comprueba que aparezcan la ocurrencia actual y la siguiente, y que el total de gastos suba.

Para ejecutar todas las pruebas de integración de la carpeta:

```bash
flutter test integration_test -d <ID_DEL_DISPOSITIVO>
```

Ejemplos:

```bash
flutter test integration_test -d emulator-5554
flutter test integration_test -d "iPhone 15"
flutter test integration_test -d macos
```

## 6. Pruebas unitarias (opcional)

Flutter:

```bash
flutter test
```

Backend, con la base de datos de desarrollo levantada:

```bash
cd servidor
npm test
```

## 7. Apagar el backend

```bash
cd servidor
docker compose -f docker-compose.dev.yml down
```

Esto conserva los datos de PostgreSQL.

Si quieres borrar también la base de datos:

```bash
docker compose -f docker-compose.dev.yml down -v
```

Advertencia: `down -v` elimina los datos guardados.

## Problemas comunes

- **No aparece ningún dispositivo:** ejecuta `flutter devices` y revisa que el emulador o simulador esté abierto.
- **En macOS no aparece el simulador:** abre Xcode, descarga un simulador de iOS y vuelve a ejecutar `open -a Simulator`.
- **En macOS el simulador no conecta con la API:** usa `API_BASE_URL=http://localhost:3000` en el `.env` de la raíz y reinicia la app.
- **En un iPhone físico no conecta:** usa la IP local de la Mac, verifica que estén en la misma Wi-Fi y permite el puerto `3000` en el firewall.
- **La API no responde:** revisa `docker compose -f docker-compose.dev.yml ps` y los logs del contenedor.
- **El test dice que el backend no responde:** vuelve a levantar el backend y comprueba `curl http://localhost:3000/ping`.
- **La app no conecta con la API:** revisa `API_BASE_URL` en el `.env` de la raíz y reinicia la app.
- **El puerto 3000 está ocupado:** detén el proceso que lo usa antes de levantar el backend.
- **El puerto 55432 está ocupado:** detén el contenedor o proceso que lo usa.
- **Cambiaste dependencias del backend:** vuelve a ejecutar `docker compose -f docker-compose.dev.yml up -d --build`.
- **Android pide aceptar licencias:** ejecuta `flutter doctor --android-licenses`.
- **El hot-reload no detecta cambios:** revisa los logs; el contenedor usa `nodemon --legacy-watch`.
