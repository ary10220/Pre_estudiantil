# Presupuesto Estudiantil

App móvil para que estudiantes universitarios organicen sus ingresos, gastos y presupuesto del mes.
Proyecto 2 · Interacción Hombre-Computador · UAGRM

Integrantes: Claure Cota Ariany · Franco Moron Luis Enrique

## Cómo está armado

```
App Flutter (celular)  ──HTTP/JSON──▶  Backend Node/Express  ──SQL──▶  PostgreSQL
```

## Cómo correrlo

Necesitás Node 18+, PostgreSQL y Flutter instalados, y un emulador Android.

**1. Base de datos (solo la primera vez).** Desde la carpeta del proyecto:

```
createdb -U postgres presupuesto_estudiantil
psql -U postgres -d presupuesto_estudiantil -f database/esquema.sql
```

**2. Backend.** Desde `backend/`:

```
npm install
copy .env.ejemplo .env
```

Abrir `.env` y poner la clave de PostgreSQL. Después, cada vez que se quiera usar la app:

```
npm run dev
```

**3. App.** Con el emulador abierto, desde `app/`:

```
flutter pub get
flutter run
```

La app se conecta a `http://10.0.2.2:3000`, que es la PC vista desde el emulador. Para un celular real hay que cambiar `urlBase` en `app/lib/servicios/api.dart` por la IP de la PC.

## Pantallas

| Ruta | Pantalla |
|---|---|
| `/` | Bienvenida |
| `/registro` | Crear cuenta |
| `/login` | Iniciar sesión |
| `/recuperar` | Recuperar contraseña (muestra el código) |
| `/nueva-contrasena` | Poner contraseña nueva con el código |
| `/inicio` | Inicio (requiere sesión) |

Si ya hay una sesión guardada, la app abre directo en Inicio.

## Documentación

- [Tarea 1 · Acceso](docs/task-01-access.md)
- [Sistema visual](docs/sistema-visual.md): colores, tipografía y espaciado en múltiplos de 8
- [Backend](backend/LEEME.md): endpoints
