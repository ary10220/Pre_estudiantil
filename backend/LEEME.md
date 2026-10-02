# Backend · Presupuesto Estudiantil

API en Node + Express que conecta la app con PostgreSQL.

## Requisitos

- Node 18 o más nuevo
- PostgreSQL con la base creada y las migraciones cargadas en orden (ver `database/LEEME.md`)

## Primera vez

Crear la base y cargar las tablas (pide la clave de `postgres`):

```
createdb -U postgres presupuesto_estudiantil
psql -U postgres -d presupuesto_estudiantil -f database/migraciones/001_acceso.sql
```

Instalar y configurar el backend, desde la carpeta `backend/`:

```
npm install
copy .env.ejemplo .env
```

Abrir `.env` y poner el usuario, la clave y el nombre de la base:

```
DATABASE_URL=postgres://postgres:TU_CLAVE@localhost:5432/presupuesto_estudiantil
PUERTO=3000
```

## Levantar el servidor

```
npm run dev
```

Tiene que decir `Servidor escuchando en el puerto 3000`. `npm run dev` se reinicia solo al guardar cambios; `npm start` es el arranque normal.

## Endpoints

| Método | Ruta | Cuerpo | Respuesta |
|---|---|---|---|
| POST | `/auth/registro` | `{ nombre, correo, contrasena }` | 201 `{ usuario }` |
| POST | `/auth/login` | `{ correo, contrasena }` | 200 `{ token, usuario }` |
| POST | `/auth/recuperar` | `{ correo }` | 200 `{ codigo }` |
| POST | `/auth/cambiar-contrasena` | `{ correo, codigo, nueva }` | 200 `{ mensaje }` |
| GET | `/sesion/yo` | header `Authorization: Bearer <token>` | 200 `{ usuario }` |
| POST | `/sesion/salir` | header `Authorization: Bearer <token>` | 204 |
| POST | `/movimientos` | header + `{ concepto, monto }` | 201 `{ movimiento }` |
| GET | `/movimientos` | header `Authorization: Bearer <token>` | 200 `{ movimientos: [...] }` (el más nuevo arriba) |

Cada usuario ve y guarda solo sus movimientos: el `usuario_id` sale del token, nunca del cuerpo.

Los errores siempre vienen como `{ "error": "mensaje para mostrar" }`.
