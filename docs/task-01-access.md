# Tarea 1 · Acceso (registro, login y recuperación)

Proyecto 2 · Presupuesto Estudiantil · IHC · UAGRM
Integrantes: Claure Cota Ariany · Franco Moron Luis Enrique

## Modalidad

**Con IA.** Usamos un asistente de programación con IA para:

- armar la estructura inicial del backend y de las pantallas a partir de nuestra especificación (endpoints, mensajes de error, paleta, tipografía y espaciado),
- escribir y correr las pruebas de cada endpoint (caso feliz y cada error),
- revisar que los espacios de las pantallas respeten la retícula de 8.

Las decisiones de diseño, la base de datos y los mensajes los definimos nosotros; cada archivo lo revisamos y lo podemos explicar.

## Cómo funciona

```
App Flutter  ──HTTP/JSON──▶  Backend Node/Express  ──SQL──▶  PostgreSQL
```

1. **Registro:** la app manda nombre, correo y contraseña. El backend valida, guarda la contraseña como hash bcrypt y crea el usuario.
2. **Login:** el backend compara la contraseña con el hash. Si coincide crea un token, lo guarda en la tabla `sesiones` (vence en 7 días) y se lo devuelve a la app.
3. **Rutas protegidas:** la app manda `Authorization: Bearer <token>`; el middleware `requiereSesion` busca el token en `sesiones` y, si no existe o venció, responde 401.
4. **Recuperación:** el backend genera un código de 6 dígitos (vence en 15 min) y la app lo muestra. Con el código se pone una contraseña nueva; el código queda usado y se cierran todas las sesiones de ese usuario.

## Decisiones

| Decisión | Por qué |
|---|---|
| Backend entre la app y PostgreSQL | Si la app se conectara directo a la base, la clave de la base viajaría dentro del celular y cualquiera podría sacarla del APK. Con el backend la clave queda solo en el servidor (`.env`, que no se sube). |
| Contraseñas con bcrypt (costo 10) | Nunca se guarda la contraseña: se guarda un hash que no se puede revertir. Si alguien roba la base, no ve las contraseñas. |
| Token guardado en la tabla `sesiones` | Podemos cerrar una sesión borrando la fila (`/sesion/salir`) y cerrar todas al cambiar la contraseña. Cada token vence a los 7 días. |
| Código mostrado en pantalla en vez de mandarlo por correo | La tarea no exige enviar correo real. El flujo (código de 6 dígitos, vence en 15 min, se usa una sola vez) es el mismo; solo cambia por dónde llega. |
| Mismo mensaje si el correo no existe o la contraseña está mal | "El correo o la contraseña no coinciden" no revela qué correos tienen cuenta. |
| Errores debajo de cada campo | El usuario ve exactamente qué corregir y dónde. El error se borra apenas empieza a escribir. |
| Botón siempre activo | Valida al tocarlo y explica qué falta, en vez de quedar gris sin decir por qué. Mientras espera al servidor dice "Ingresando…" o "Guardando…" y no se puede tocar dos veces. |
| Espaciado en múltiplos de 8 y tema en una carpeta | Ver `docs/sistema-visual.md`. Todas las pantallas usan las mismas constantes, así se ven consistentes. |
| Fuentes incluidas en la app | Manrope y Plus Jakarta Sans van dentro del APK (`app/assets/google_fonts/`), así se ven bien aunque no haya internet. |

## Archivos principales

### Ariany: backend, base y pantallas de acceso

| Archivo | Qué hace |
|---|---|
| `database/esquema.sql` | Tablas `usuarios`, `sesiones`, `recuperaciones` (diseño de Luis) |
| `backend/src/servidor.js` | Arranca Express, monta `/auth` y `/sesion`, responde errores en JSON |
| `backend/src/bd.js` | Pool de conexiones a PostgreSQL |
| `backend/src/servicios/usuarios.js` | Crear, buscar y cambiar contraseña (bcrypt) |
| `backend/src/servicios/sesiones.js` | Crear token, buscar usuario por token, borrar sesiones |
| `backend/src/servicios/recuperaciones.js` | Generar, verificar y marcar como usado el código |
| `backend/src/middleware/requiereSesion.js` | Revisa el token antes de las rutas protegidas |
| `backend/src/rutas/auth.js` | Registro, login, recuperar y cambiar contraseña |
| `backend/src/rutas/sesion.js` | `/sesion/yo` y `/sesion/salir` |
| `app/lib/tema/` | Colores, tipografía, espaciado y `crearTema()` |
| `app/lib/modelos/usuario.dart` | Modelo del usuario |
| `app/lib/servicios/api.dart` | URL del backend y manejo de errores / sin conexión |
| `app/lib/servicios/auth_servicio.dart` | Llamadas a los 4 endpoints de `/auth` |
| `app/lib/servicios/validaciones.dart` | Mismas reglas que el backend |
| `app/lib/widgets/campo_texto.dart` | Campo con etiqueta, error y ojo para contraseña |
| `app/lib/widgets/boton_principal.dart` | Botón con estado cargando |
| `app/lib/pantallas/publicas/` | Login, Registro, Recuperar y Nueva contraseña |

### Luis: sesión, navegación y pantallas de inicio

| Archivo | Qué hace |
|---|---|
| `database/esquema.sql` | Diseño de las tablas |
| `app/lib/servicios/sesion.dart` | Guardar, leer y borrar la sesión (`shared_preferences`) |
| `app/lib/rutas.dart` | Rutas `/`, `/login`, `/registro`, `/recuperar`, `/nueva-contrasena`, `/inicio` |
| `app/lib/main.dart` | Arranca la app con `theme: crearTema()` |
| `app/lib/pantallas/pantalla_bienvenida.dart` | Primera pantalla |
| `app/lib/pantallas/pantalla_inicio.dart` | Pantalla después del login |
| `README.md` y video | Instrucciones y demostración |
