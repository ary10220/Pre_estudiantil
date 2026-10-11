-- HU-01: para una base que se creó con el esquema anterior (sin limite_mensual).
-- Una base nueva no lo necesita: esquema.sql ya trae la columna.
ALTER TABLE usuarios
  ADD COLUMN limite_mensual NUMERIC(10,2) NULL CHECK (limite_mensual > 0);
