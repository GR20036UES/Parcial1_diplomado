-- Descripción: Añade restricciones de dominio, índices para optimización
-- ============================================================================
 
-- ============================================================================
-- SECCIÓN 1: RESTRICCIONES DE DOMINIO (CHECK CONSTRAINTS)
-- ============================================================================
 
-- Tabla: nivel_bioseguridad
ALTER TABLE nivel_bioseguridad ADD CONSTRAINT check_bioseguridad_id_valido
    CHECK (id_bioseguridad BETWEEN 1 AND 4);
 
-- Tabla: rango_investigadores
ALTER TABLE rango_investigadores ADD CONSTRAINT check_rango_id_valido
    CHECK (id_rango BETWEEN 1 AND 3);
 
-- Tabla: laboratorios
ALTER TABLE laboratorios ADD CONSTRAINT check_capacidad_positiva
    CHECK (capacidad_maxima_simultanea > 0);
 
-- Tabla: reservas - Validar que fecha_inicio <= fecha_fin
ALTER TABLE reservas ADD CONSTRAINT check_fechas_validas
    CHECK (
        fecha_inicio < fecha_fin OR 
        (fecha_inicio = fecha_fin AND hora_inicio < hora_fin)
    );
 
-- Tabla: equipos - Estado debe ser válido
ALTER TABLE equipos ADD CONSTRAINT check_estado_valido
    CHECK (estado IN ('DISPONIBLE', 'MANTENIMIENTO', 'FUERA_DE_SERVICIO'));
 
-- ============================================================================
-- SECCIÓN 2: ÍNDICES PARA OPTIMIZAR BÚSQUEDAS
-- ============================================================================
 
-- ============================================================================
-- Índices para tabla RESERVAS (búsquedas más frecuentes)
-- ============================================================================
 
-- Índice 1: Búsquedas por rango de fechas (CRÍTICO)
CREATE INDEX idx_reservas_fecha_inicio_fin 
    ON reservas(fecha_inicio, fecha_fin)
    WHERE estado IN ('PENDIENTE', 'CONFIRMADA');
 
-- Índice 2: Búsquedas por investigador
CREATE INDEX idx_reservas_investigador 
    ON reservas(id_investigador)
    WHERE estado IN ('PENDIENTE', 'CONFIRMADA');
 
-- Índice 3: Búsquedas por laboratorio
CREATE INDEX idx_reservas_laboratorio 
    ON reservas(id_laboratorio)
    WHERE estado IN ('PENDIENTE', 'CONFIRMADA');
 
-- Índice 4: Búsquedas por equipo
CREATE INDEX idx_reservas_equipo 
    ON reservas(id_equipo)
    WHERE id_equipo IS NOT NULL AND estado IN ('PENDIENTE', 'CONFIRMADA');
 
-- Índice 5: Búsquedas por estado
CREATE INDEX idx_reservas_estado 
    ON reservas(estado);
 
-- Índice 6: Detección de conflictos de reservas (investigador + período)
CREATE INDEX idx_reservas_investigador_periodo 
    ON reservas(id_investigador, fecha_inicio, fecha_fin)
    WHERE estado IN ('PENDIENTE', 'CONFIRMADA');
 
-- ============================================================================
-- Índices para tabla INVESTIGADORES
-- ============================================================================
 
-- Índice 1: Búsquedas por email (login)
CREATE UNIQUE INDEX idx_investigadores_email 
    ON investigadores(email)
    WHERE activo = TRUE;
 
-- Índice 2: Búsquedas por rango
CREATE INDEX idx_investigadores_rango 
    ON investigadores(id_rango)
    WHERE activo = TRUE;
 
-- ============================================================================
-- Índices para tabla LABORATORIOS
-- ============================================================================
 
-- Índice 1: Búsquedas por código
CREATE UNIQUE INDEX idx_laboratorios_codigo 
    ON laboratorios(codigo);
 
-- Índice 2: Búsquedas por bioseguridad
CREATE INDEX idx_laboratorios_bioseguridad 
    ON laboratorios(id_bioseguridad)
    WHERE activo = TRUE;
 
-- ============================================================================
-- Índices para tabla EQUIPOS
-- ============================================================================
 
-- Índice 1: Búsquedas por código serial
CREATE UNIQUE INDEX idx_equipos_codigo_serial 
    ON equipos(codigo_serial);
 
-- Índice 2: Búsquedas por laboratorio
CREATE INDEX idx_equipos_laboratorio 
    ON equipos(id_laboratorio)
    WHERE activo = TRUE;
 
-- Índice 3: Búsquedas por estado
CREATE INDEX idx_equipos_estado 
    ON equipos(estado)
    WHERE activo = TRUE;
 
-- ============================================================================
-- Índices para tablas de AUDITORÍA
-- ============================================================================
 
-- Índice 1: Búsquedas por fecha (para reportes de auditoría)
CREATE INDEX idx_auditoria_reservas_fecha_hora 
    ON auditoria_reservas(fecha_hora DESC);
 
CREATE INDEX idx_auditoria_equipos_fecha_hora 
    ON auditoria_equipos(fecha_hora DESC);
 
-- Índice 2: Búsquedas por entidad auditada
CREATE INDEX idx_auditoria_reservas_id_reserva 
    ON auditoria_reservas(id_reserva);
 
CREATE INDEX idx_auditoria_equipos_id_equipo 
    ON auditoria_equipos(id_equipo);
 
-- ============================================================================