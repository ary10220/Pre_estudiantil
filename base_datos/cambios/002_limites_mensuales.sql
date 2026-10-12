-- #9: un límite por persona y por mes. Reemplaza a usuarios.limite_mensual.
-- Para una base que ya corrió 001_limite_mensual.sql.
-- Una base nueva no lo necesita: esquema.sql ya trae la tabla.
CREATE TABLE limites_mensuales (
    id              SERIAL PRIMARY KEY,
    usuario_id      INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    mes             DATE NOT NULL,
    monto           NUMERIC(10,2) NOT NULL CHECK (monto > 0),
    actualizado_en  TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (usuario_id, mes)
);

-- El límite que ya tenía cada persona pasa a ser el del mes actual
INSERT INTO limites_mensuales (usuario_id, mes, monto)
SELECT id, date_trunc('month', CURRENT_DATE)::date, limite_mensual
FROM usuarios
WHERE limite_mensual IS NOT NULL;

ALTER TABLE usuarios DROP COLUMN limite_mensual;
