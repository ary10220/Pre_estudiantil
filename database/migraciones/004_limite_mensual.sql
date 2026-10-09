-- HU-01: cada usuario tiene un solo límite mensual (vacío hasta que lo define)
ALTER TABLE usuarios
  ADD COLUMN limite_mensual NUMERIC(10,2) NULL CHECK (limite_mensual > 0);
