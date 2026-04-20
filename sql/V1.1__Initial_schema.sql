-- ============================================================================
-- TABLA: auditoria_reservas
-- ============================================================================
 
CREATE TABLE auditoria_reservas (
    id_auditoria UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_reserva UUID NOT NULL,
    tipo_operacion tipo_operacion_auditoria NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_reserva) REFERENCES reservas(id_reserva)
);
 
-- ============================================================================
-- TABLA: auditoria_equipos
-- ============================================================================
 
CREATE TABLE auditoria_equipos (
    id_auditoria UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_equipo UUID NOT NULL,
    tipo_operacion tipo_operacion_auditoria NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_anterior estado_equipo,
    estado_nuevo estado_equipo,
    
    FOREIGN KEY (id_equipo) REFERENCES equipos(id_equipo)
);