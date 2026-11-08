-- CreateTable
CREATE TABLE "metas_ahorro" (
    "id" SERIAL NOT NULL,
    "usuario_id" INTEGER NOT NULL,
    "nombre" VARCHAR(100) NOT NULL,
    "monto_objetivo" DECIMAL(12,2) NOT NULL,
    "fecha_objetivo" DATE NOT NULL,
    "monto_reservado" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "creado_en" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "metas_ahorro_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "movimientos_meta" (
    "id" SERIAL NOT NULL,
    "usuario_id" INTEGER NOT NULL,
    "meta_id" INTEGER NOT NULL,
    "meta_relacionada_id" INTEGER,
    "tipo" VARCHAR(30) NOT NULL,
    "monto" DECIMAL(12,2) NOT NULL,
    "creado_en" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "movimientos_meta_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "metas_ahorro_usuario_id_nombre_key" ON "metas_ahorro"("usuario_id", "nombre");

-- CreateIndex
CREATE INDEX "metas_ahorro_usuario_id_idx" ON "metas_ahorro"("usuario_id");

-- CreateIndex
CREATE INDEX "idx_movimientos_meta_usuario_fecha" ON "movimientos_meta"("usuario_id", "creado_en" DESC);

-- CreateIndex
CREATE INDEX "movimientos_meta_meta_id_idx" ON "movimientos_meta"("meta_id");

-- AddForeignKey
ALTER TABLE "metas_ahorro" ADD CONSTRAINT "metas_ahorro_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "usuarios"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimientos_meta" ADD CONSTRAINT "movimientos_meta_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "usuarios"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimientos_meta" ADD CONSTRAINT "movimientos_meta_meta_id_fkey" FOREIGN KEY ("meta_id") REFERENCES "metas_ahorro"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimientos_meta" ADD CONSTRAINT "movimientos_meta_meta_relacionada_id_fkey" FOREIGN KEY ("meta_relacionada_id") REFERENCES "metas_ahorro"("id") ON DELETE SET NULL ON UPDATE CASCADE;
