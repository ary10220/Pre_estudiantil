-- #7: tipo (ingreso/gasto) y categoría de cada movimiento.
-- Para una base que ya tenía la tabla movimientos.
-- Una base nueva no lo necesita: esquema.sql ya trae las columnas.
ALTER TABLE movimientos
  ADD COLUMN tipo VARCHAR(10) NOT NULL DEFAULT 'gasto'
    CHECK (tipo IN ('ingreso', 'gasto')),
  ADD COLUMN categoria VARCHAR(20) NOT NULL DEFAULT 'otros'
    CHECK (categoria IN ('comida', 'transporte', 'estudio', 'otros'));