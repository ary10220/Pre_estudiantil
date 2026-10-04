CREATE TABLE movimientos (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo VARCHAR(10) NOT NULL DEFAULT 'gasto' CHECK (tipo IN ('gasto', 'ingreso')),
  concepto VARCHAR(40) NOT NULL,
  monto NUMERIC(10,2) NOT NULL CHECK (monto > 0),
  fecha DATE NOT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT NOW());

CREATE INDEX movimientos_usuario_fecha ON movimientos (usuario_id, fecha DESC);
