-- CreateTable
CREATE TABLE "recurrencias" (
    "id" SERIAL NOT NULL,
    "usuario_id" INTEGER NOT NULL,
    "concepto" VARCHAR(150) NOT NULL,
    "monto" DECIMAL(12,2) NOT NULL,
    "categoria" VARCHAR(20) NOT NULL,
    "frecuencia" VARCHAR(10) NOT NULL,
    "proxima_fecha" DATE NOT NULL,
    "activa" BOOLEAN NOT NULL DEFAULT true,
    "creado_en" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "recurrencias_pkey" PRIMARY KEY ("id")
);

-- AlterTable
ALTER TABLE "movimientos" ADD COLUMN "recurrencia_id" INTEGER;

-- CreateIndex
CREATE INDEX "recurrencias_usuario_id_idx" ON "recurrencias"("usuario_id");

-- CreateIndex
CREATE UNIQUE INDEX "movimientos_recurrencia_id_fecha_key" ON "movimientos"("recurrencia_id", "fecha");

-- AddForeignKey
ALTER TABLE "recurrencias" ADD CONSTRAINT "recurrencias_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "usuarios"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimientos" ADD CONSTRAINT "movimientos_recurrencia_id_fkey" FOREIGN KEY ("recurrencia_id") REFERENCES "recurrencias"("id") ON DELETE SET NULL ON UPDATE CASCADE;
