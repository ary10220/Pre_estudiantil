-- Esquema de la base de datos: presupuesto_estudiantil
-- Antes de ejecutar: CREATE DATABASE presupuesto_estudiantil;
-- y conectarse a esa base.

-- Cuentas de las personas
CREATE TABLE usuarios (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    correo          VARCHAR(150) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    creado_en       TIMESTAMP NOT NULL DEFAULT NOW(),
    -- HU-01: vacío hasta que la persona define su límite del mes
    limite_mensual  NUMERIC(10,2) NULL CHECK (limite_mensual > 0)
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
    estado      VARCHAR(10) NOT NULL DEFAULT 'pendiente'
                CHECK (estado IN ('pendiente', 'pagado')),
    creado_en   TIMESTAMP NOT NULL DEFAULT NOW()
);