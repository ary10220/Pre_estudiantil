-- Tarea 02: un movimiento pasa de pendiente a pagado. Los que ya existen quedan pendientes.
ALTER TABLE movimientos
  ADD COLUMN estado VARCHAR(10) NOT NULL DEFAULT 'pendiente'
    CHECK (estado IN ('pendiente', 'pagado')),
  ADD COLUMN pagado_en TIMESTAMP NULL;
