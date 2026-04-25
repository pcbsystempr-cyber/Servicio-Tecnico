-- ============================================
-- SUPABASE SQL - Tabla de Calificaciones de Servicio Técnico
-- Ejecuta todo este código en el SQL Editor de Supabase
-- ============================================

-- 1. Crear tabla de calificaciones de servicio (si no existe)
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

-- 2. Crear índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_calificaciones_created_at ON calificaciones_servicio(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_calificaciones_technician ON calificaciones_servicio(technician);
CREATE INDEX IF NOT EXISTS idx_calificaciones_teacher ON calificaciones_servicio(teacher);
CREATE INDEX IF NOT EXISTS idx_calificaciones_service_date ON calificaciones_servicio(service_date);
CREATE INDEX IF NOT EXISTS idx_calificaciones_codigo ON calificaciones_servicio(codigo_seguimiento);

-- 3. Trigger para actualizar updated_at automáticamente
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

-- 4. Habilitar Row Level Security
ALTER TABLE calificaciones_servicio ENABLE ROW LEVEL SECURITY;

-- 5. Políticas de seguridad
-- Permitir insertar a cualquiera (formulario público)
CREATE POLICY "Allow public inserts" ON calificaciones_servicio
    FOR INSERT WITH CHECK (true);

-- Permitir leer a cualquiera (panel de admin)
CREATE POLICY "Allow public select" ON calificaciones_servicio
    FOR SELECT USING (true);

-- Permitir actualizar a cualquiera (cambios de estado)
CREATE POLICY "Allow public update" ON calificaciones_servicio
    FOR UPDATE USING (true);

-- Permitir eliminar a cualquiera (panel de admin)
CREATE POLICY "Allow public delete" ON calificaciones_servicio
    FOR DELETE USING (true);

-- 6. Comentarios en la tabla para documentación
COMMENT ON TABLE calificaciones_servicio IS 'Tabla de evaluaciones/calificaciones del servicio técnico COMPUTEC';
COMMENT ON COLUMN calificaciones_servicio.service_types IS 'Array de tipos de servicio realizados (mantenimiento, troubleshooting, etc.)';
COMMENT ON COLUMN calificaciones_servicio.equipment_types IS 'Array de equipos atendidos (PC, Laptop, Proyector, etc.)';
COMMENT ON COLUMN calificaciones_servicio.technician_signature IS 'Firma del técnico en formato base64 PNG';
COMMENT ON COLUMN calificaciones_servicio.teacher_signature IS 'Firma del maestro/personal atendido en formato base64 PNG';

-- 7. Verificar tabla creada (opcional, para testing)
-- SELECT * FROM calificaciones_servicio LIMIT 1;

