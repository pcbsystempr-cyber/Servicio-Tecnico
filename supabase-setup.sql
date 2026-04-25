-- ============================================
-- SUPERBASE SQL - Servicio Técnico COMPUTEC
-- Ejecuta todo este código en el SQL Editor de Supabase
-- ============================================

-- 1. Agregar columna de código de seguimiento
ALTER TABLE solicitudes_servicio 
ADD COLUMN IF NOT EXISTS codigo_seguimiento TEXT;

-- 2. Agregar columna de edificio/aula
ALTER TABLE solicitudes_servicio 
ADD COLUMN IF NOT EXISTS edificio TEXT;

ALTER TABLE solicitudes_servicio 
ADD COLUMN IF NOT EXISTS numero_aula TEXT;

-- 3. Agregar columnas de fecha/hora
ALTER TABLE solicitudes_servicio 
ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP DEFAULT NOW();

ALTER TABLE solicitudes_servicio 
ADD COLUMN IF NOT EXISTS fecha_actualizacion TIMESTAMP;

ALTER TABLE solicitudes_servicio 
ADD COLUMN IF NOT EXISTS fecha_resolucion TIMESTAMP;

-- 4. Agregar observaciones del técnico
ALTER TABLE solicitudes_servicio 
ADD COLUMN IF NOT EXISTS observaciones_tecnico TEXT;

ALTER TABLE solicitudes_servicio 
ADD COLUMN IF NOT EXISTS solucion TEXT;

-- 5. Agregar rating del usuario
ALTER TABLE solicitudes_servicio 
ADD COLUMN IF NOT EXISTS rating_usuario INTEGER;

ALTER TABLE solicitudes_servicio 
ADD COLUMN IF NOT EXISTS comentario_usuario TEXT;

-- 6. Actualizar solicitudes existentes sin código (si la tabla ya tiene datos)
-- UPDATE solicitudes_servicio SET codigo_seguimiento = 'ST-' || encode(gen_random_bytes(2), 'hex') WHERE codigo_seguimiento IS NULL;

-- 7. Crear índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_solicitudes_codigo ON solicitudes_servicio(codigo_seguimiento);
CREATE INDEX IF NOT EXISTS idx_solicitudes_estado ON solicitudes_servicio(estado);
CREATE INDEX IF NOT EXISTS idx_solicitudes_fecha ON solicitudes_servicio(fecha_creacion);

-- 8. Tabla de Calificación (Schema completo)
-- Crear tabla si no existe con todas las columnas necesarias
CREATE TABLE IF NOT EXISTS calificaciones_servicio (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Fecha del servicio
    service_date DATE,
    
    -- Datos del técnico
    technician TEXT,
    student_grade TEXT,
    
    -- Datos del maestro / personal atendido
    teacher TEXT,
    area_room TEXT,
    
    -- Tipo de servicio (array de textos)
    service_types TEXT[],
    service_other TEXT,
    
    -- Equipo atendido (array de textos)
    equipment_types TEXT[],
    equipment_other TEXT,
    
    -- Descripción y solución
    problem_description TEXT,
    service_solution TEXT,
    
    -- Estado del servicio
    service_status TEXT DEFAULT 'Pendiente',
    
    -- Calificación (1-5 estrellas)
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    
    -- Firmas (base64 PNG)
    technician_signature TEXT,
    teacher_signature TEXT,
    
    -- Campos adicionales
    observations TEXT,
    comentarios_adicionales TEXT,
    codigo_seguimiento TEXT,
    
    -- Metadatos del sistema
    submitted_by TEXT,
    ip_address TEXT,
    user_agent TEXT
);

-- Migración: agregar columnas si la tabla ya existía con estructura antigua
ALTER TABLE calificaciones_servicio 
ADD COLUMN IF NOT EXISTS codigo_seguimiento TEXT;

ALTER TABLE calificaciones_servicio 
ADD COLUMN IF NOT EXISTS fecha_servicio DATE;

ALTER TABLE calificaciones_servicio 
ADD COLUMN IF NOT EXISTS comentarios_adicionales TEXT;

-- 9. Crear índices para búsquedas rápidas en calificaciones
CREATE INDEX IF NOT EXISTS idx_calificaciones_created_at ON calificaciones_servicio(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_calificaciones_technician ON calificaciones_servicio(technician);
CREATE INDEX IF NOT EXISTS idx_calificaciones_teacher ON calificaciones_servicio(teacher);
CREATE INDEX IF NOT EXISTS idx_calificaciones_service_date ON calificaciones_servicio(service_date);
CREATE INDEX IF NOT EXISTS idx_calificaciones_codigo ON calificaciones_servicio(codigo_seguimiento);

-- 10. Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_calificaciones_updated_at ON calificaciones_servicio;
CREATE TRIGGER update_calificaciones_updated_at
    BEFORE UPDATE ON calificaciones_servicio
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 11. Habilitar Row Level Security
ALTER TABLE calificaciones_servicio ENABLE ROW LEVEL SECURITY;

-- 12. Políticas de seguridad (permitir operaciones públicas desde el formulario web)
CREATE POLICY "Allow public inserts" ON calificaciones_servicio
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public select" ON calificaciones_servicio
    FOR SELECT USING (true);

CREATE POLICY "Allow public update" ON calificaciones_servicio
    FOR UPDATE USING (true);

CREATE POLICY "Allow public delete" ON calificaciones_servicio
    FOR DELETE USING (true);
