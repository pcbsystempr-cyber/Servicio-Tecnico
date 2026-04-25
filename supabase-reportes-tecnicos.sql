-- ============================================
-- SUPABASE SQL - Tabla de Reportes Técnicos
-- Ejecuta todo este código en el SQL Editor de Supabase
-- ============================================

-- 1. Crear tabla de reportes técnicos (si no existe)
CREATE TABLE IF NOT EXISTS reportes_tecnicos (
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
    
    -- Observaciones
    observations TEXT,
    
    -- Firmas (base64 PNG)
    technician_signature TEXT,
    teacher_signature TEXT,
    
    -- Campos adicionales
    codigo_seguimiento TEXT,
    
    -- Metadatos del sistema
    submitted_by TEXT,
    ip_address TEXT,
    user_agent TEXT
);

-- 2. Crear índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_reportes_created_at ON reportes_tecnicos(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reportes_technician ON reportes_tecnicos(technician);
CREATE INDEX IF NOT EXISTS idx_reportes_teacher ON reportes_tecnicos(teacher);
CREATE INDEX IF NOT EXISTS idx_reportes_service_date ON reportes_tecnicos(service_date);
CREATE INDEX IF NOT EXISTS idx_reportes_codigo ON reportes_tecnicos(codigo_seguimiento);

-- 3. Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_reportes_updated_at ON reportes_tecnicos;
CREATE TRIGGER update_reportes_updated_at
    BEFORE UPDATE ON reportes_tecnicos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 4. Habilitar Row Level Security
ALTER TABLE reportes_tecnicos ENABLE ROW LEVEL SECURITY;

-- 5. Políticas de seguridad
-- Permitir insertar a cualquiera (formulario público)
CREATE POLICY "Allow public inserts" ON reportes_tecnicos
    FOR INSERT WITH CHECK (true);

-- Permitir leer a cualquiera (panel de admin)
CREATE POLICY "Allow public select" ON reportes_tecnicos
    FOR SELECT USING (true);

-- Permitir actualizar a cualquiera (cambios de estado)
CREATE POLICY "Allow public update" ON reportes_tecnicos
    FOR UPDATE USING (true);

-- Permitir eliminar a cualquiera (panel de admin)
CREATE POLICY "Allow public delete" ON reportes_tecnicos
    FOR DELETE USING (true);

-- 6. Comentarios en la tabla para documentación
COMMENT ON TABLE reportes_tecnicos IS 'Tabla de reportes técnicos enviados por técnicos de COMPUTEC';
COMMENT ON COLUMN reportes_tecnicos.service_types IS 'Array de tipos de servicio realizados';
COMMENT ON COLUMN reportes_tecnicos.equipment_types IS 'Array de equipos atendidos';
COMMENT ON COLUMN reportes_tecnicos.technician_signature IS 'Firma del técnico en formato base64 PNG';
COMMENT ON COLUMN reportes_tecnicos.teacher_signature IS 'Firma del maestro/personal atendido en formato base64 PNG';

