-- ============================================================================
-- Flyway Migration V3: Auditing Logic
-- Sistema de Gestión de Laboratorios de Bioseguridad
-- ============================================================================
-- Descripción: Funciones PL/pgSQL y triggers para:
--              1. Validar acceso a bioseguridad nivel 4
--              2. Registrar automáticamente cambios en auditoría
-- ============================================================================
 
-- ============================================================================
-- SECCIÓN 1: FUNCIONES PL/pgSQL
-- ============================================================================
 
-- ============================================================================
-- FUNCIÓN: validar_acceso_bioseguridad_nivel_4
-- Descripción: Verifica si un investigador puede acceder a laboratorio nivel 4
--              SOLO DIRECTORES pueden acceder a Bioseguridad Nivel 4
-- Parámetros:
--   p_id_investigador: UUID del investigador
--   p_id_laboratorio: UUID del laboratorio a reservar
-- Retorna: BOOLEAN (TRUE = tiene acceso, FALSE = no tiene acceso)
-- ============================================================================
 
CREATE OR REPLACE FUNCTION validar_acceso_bioseguridad_nivel_4(
    p_id_investigador UUID,
    p_id_laboratorio UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_nivel_bioseguridad SMALLINT;
    v_rango_investigador VARCHAR(50);
BEGIN
    -- Obtener el nivel de bioseguridad del laboratorio
    SELECT id_bioseguridad INTO v_nivel_bioseguridad
    FROM laboratorios
    WHERE id_laboratorio = p_id_laboratorio;
    
    -- Si no existe el laboratorio, denegar acceso
    IF v_nivel_bioseguridad IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Si el laboratorio NO es nivel 4, permitir (será validado en otra función)
    IF v_nivel_bioseguridad != 4 THEN
        RETURN TRUE;
    END IF;
    
    -- Si es nivel 4, verificar que investigador sea DIRECTOR
    SELECT nombre_rango::TEXT INTO v_rango_investigador
    FROM investigadores i
    JOIN rango_investigadores r ON i.id_rango = r.id_rango
    WHERE i.id_investigador = p_id_investigador;
    
    -- Retornar TRUE solo si es DIRECTOR
    RETURN v_rango_investigador = 'DIRECTOR';
    
EXCEPTION WHEN OTHERS THEN
    -- En caso de error, denegar acceso por seguridad
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql STABLE;
 
-- ============================================================================
-- SECCIÓN 2: TRIGGERS
-- ============================================================================
 
-- ============================================================================
-- TRIGGER: Validación ANTES de insertar una reserva
-- Función: trg_validar_reserva_antes_insertar
-- Momento: BEFORE INSERT ON reservas
-- Descripción: Valida que el investigador tenga acceso al laboratorio
--              especialmente a bioseguridad nivel 4
-- ============================================================================
 
CREATE OR REPLACE FUNCTION trg_validar_reserva_antes_insertar()
RETURNS TRIGGER AS $$
DECLARE
    v_tiene_acceso BOOLEAN;
BEGIN
    -- Validar acceso a bioseguridad (especialmente nivel 4)
    v_tiene_acceso := validar_acceso_bioseguridad_nivel_4(
        NEW.id_investigador,
        NEW.id_laboratorio
    );
    
    -- Si no tiene acceso, lanzar excepción
    IF NOT v_tiene_acceso THEN
        RAISE EXCEPTION 'El investigador no tiene permisos para acceder a este laboratorio. Solo DIRECTORES pueden acceder a Bioseguridad Nivel 4.'
            USING ERRCODE = 'PERMISSION_DENIED';
    END IF;
    
    -- Si tiene acceso, permitir la inserción
    RETURN NEW;
    
EXCEPTION WHEN OTHERS THEN
    RAISE;
END;
$$ LANGUAGE plpgsql;
 
-- Crear el trigger
CREATE TRIGGER trg_validar_reserva_antes_insertar
BEFORE INSERT ON reservas
FOR EACH ROW
EXECUTE FUNCTION trg_validar_reserva_antes_insertar();
 
-- =======================================================