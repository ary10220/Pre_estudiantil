-- Tarea 4 · Historial de actividad: una fila por cada acción con sentido
-- (gasto o ingreso registrado, movimiento pagado, límite definido).
-- Para una base que ya tenía las tablas anteriores.
-- Una base nueva no lo necesita: esquema.sql ya trae la tabla.
CREATE TABLE eventos (
    id             SERIAL PRIMARY KEY,
    usuario_id     INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    tipo           VARCHAR(30) NOT NULL
                     CHECK (tipo IN ('gasto_registrado', 'ingreso_registrado',
                                     'movimiento_pagado', 'limite_definido')),
    movimiento_id  INTEGER NULL REFERENCES movimientos(id) ON DELETE SET NULL,
    monto          NUMERIC(12,2) NULL,
    descripcion    VARCHAR(200) NULL,
    creado_en      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_eventos_usuario_fecha ON eventos (usuario_id, creado_en DESC);
