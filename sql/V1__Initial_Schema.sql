-- Descripción: Añade las tablas base y sus claves primarias.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
 
-- ============================================================================
-- TIPOS ENUMERADOS
-- ============================================================================
 
CREATE TYPE bioseguridad_nivel AS ENUM ('NIVEL_1', 'NIVEL_2', 'NIVEL_3', 'NIVEL_4');
CREATE TYPE rango_investigador_tipo AS ENUM ('JUNIOR', 'SENIOR', 'DIRECTOR');
CREATE TYPE estado_equipo AS ENUM ('DISPONIBLE', 'MANTENIMIENTO', 'FUERA_DE_SERVICIO');
CREATE TYPE estado_reserva_tipo AS ENUM ('PENDIENTE', 'CONFIRMADA', 'CANCELADA', 'COMPLETADA');
CREATE TYPE tipo_operacion_auditoria AS ENUM ('INSERT', 'UPDATE', 'DELETE');
 
-- ============================================================================
-- TABLA: nivel_bioseguridad
-- ============================================================================
 
CREATE TABLE nivel_bioseguridad (
    id_bioseguridad SMALLINT PRIMARY KEY,
    nivel bioseguridad_nivel NOT NULL UNIQUE,
    nombre VARCHAR(50) NOT NULL
);
 
-- ============================================================================
-- TABLA: rango_investigadores
-- ============================================================================
 
CREATE TABLE rango_investigadores (
    id_rango SMALLINT PRIMARY KEY,
    nombre_rango rango_investigador_tipo NOT NULL UNIQUE,
    nivel_bioseguridad_min SMALLINT NOT NULL,
    
    FOREIGN KEY (nivel_bioseguridad_min) REFERENCES nivel_bioseguridad(id_bioseguridad)
);
 
-- ============================================================================
-- TABLA: investigadores
-- ============================================================================
 
CREATE TABLE investigadores (
    id_investigador UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(150) NOT NULL,
    apellidos VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    id_rango SMALLINT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (id_rango) REFERENCES rango_investigadores(id_rango)
);
 
-- ============================================================================
-- TABLA: laboratorios
-- ============================================================================
 
CREATE TABLE laboratorios (
    id_laboratorio UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    ubicacion VARCHAR(200) NOT NULL,
    id_bioseguridad SMALLINT NOT NULL,
    capacidad_maxima_simultanea SMALLINT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (id_bioseguridad) REFERENCES nivel_bioseguridad(id_bioseguridad)
);
 
-- ============================================================================
-- TABLA: equipos
-- ============================================================================
 
CREATE TABLE equipos (
    id_equipo UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo_serial VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    id_laboratorio UUID NOT NULL,
    estado estado_equipo DEFAULT 'DISPONIBLE' NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (id_laboratorio) REFERENCES laboratorios(id_laboratorio)
);
 
-- ============================================================================
-- TABLA: reservas
-- ============================================================================
 
CREATE TABLE reservas (
    id_reserva UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_investigador UUID NOT NULL,
    id_laboratorio UUID NOT NULL,
    id_equipo UUID,
    fecha_inicio DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    fecha_fin DATE NOT NULL,
    hora_fin TIME NOT NULL,
    estado estado_reserva_tipo DEFAULT 'PENDIENTE' NOT NULL,
    
    FOREIGN KEY (id_investigador) REFERENCES investigadores(id_investigador),
    FOREIGN KEY (id_laboratorio) REFERENCES laboratorios(id_laboratorio),
    FOREIGN KEY (id_equipo) REFERENCES equipos(id_equipo)
);
 
-- =====================