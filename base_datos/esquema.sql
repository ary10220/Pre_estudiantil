-- Esquema de la base de datos: presupuesto_estudiantil
-- Antes de ejecutar: CREATE DATABASE presupuesto_estudiantil;
-- y conectarse a esa base.

-- Cuentas de las personas
CREATE TABLE usuarios (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    correo          VARCHAR(150) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    creado_en       TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Sesiones activas
CREATE TABLE sesiones (
    id          SERIAL PRIMARY KEY,
    token       VARCHAR(255) NOT NULL UNIQUE,
    usuario_id  INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    creado_en   TIMESTAMP NOT NULL DEFAULT NOW(),
    expira_en   TIMESTAMP NOT NULL
);

-- Códigos de 6 dígitos para recuperar la contraseña
CREATE TABLE recuperaciones (
    id          SERIAL PRIMARY KEY,
    usuario_id  INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    codigo      CHAR(6) NOT NULL,
    creado_en   TIMESTAMP NOT NULL DEFAULT NOW(),
    expira_en   TIMESTAMP NOT NULL,
    usado       BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE movimientos (
    id          SERIAL PRIMARY KEY,
    usuario_id  INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    concepto    VARCHAR(150) NOT NULL,
    monto       NUMERIC(12,2) NOT NULL CHECK (monto > 0),
    fecha       DATE NOT NULL,
    tipo        VARCHAR(10) NOT NULL DEFAULT 'gasto'
                CHECK (tipo IN ('ingreso', 'gasto')),
    categoria   VARCHAR(20) NOT NULL DEFAULT 'otros'
                CHECK (categoria IN ('comida', 'transporte', 'estudio', 'otros')),
    estado      VARCHAR(10) NOT NULL DEFAULT 'pendiente'
                CHECK (estado IN ('pendiente', 'pagado')),
    creado_en   TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Límite de gastos: uno por persona y por mes (mes = siempre el día 1)
CREATE TABLE limites_mensuales (
    id              SERIAL PRIMARY KEY,
    usuario_id      INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    mes             DATE NOT NULL,
    monto           NUMERIC(10,2) NOT NULL CHECK (monto > 0),
    actualizado_en  TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (usuario_id, mes)
);