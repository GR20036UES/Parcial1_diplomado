-- ============================================================================
-- Flyway Migration V5: Seed Data
-- Sistema de Gestión de Laboratorios de Bioseguridad
-- ============================================================================
-- Descripción:
-- Inserta datos de prueba para validar:
-- - Restricciones de integridad
-- - Relaciones entre entidades
-- - Funcionamiento de triggers y auditoría
-- ============================================================================

-- ============================================================================
-- SECCIÓN 1: nivel_bioseguridad
-- ============================================================================

INSERT INTO nivel_bioseguridad (id_bioseguridad, nivel, nombre) VALUES
(1, 'NIVEL_1', 'Básico'),
(2, 'NIVEL_2', 'Intermedio'),
(3, 'NIVEL_3', 'Alto'),
(4, 'NIVEL_4', 'Máximo'); -- (intencionalmente inválido si quieres probar constraint, puedes quitarlo si no)

-- ============================================================================
-- SECCIÓN 2: rango_investigadores
-- ============================================================================

INSERT INTO rango_investigadores (id_rango, nombre_rango, nivel_bioseguridad_min) VALUES
(1, 'JUNIOR', 1),
(2, 'SENIOR', 2),
(3, 'DIRECTOR', 4);

-- ============================================================================
-- SECCIÓN 3: investigadores
-- ============================================================================

INSERT INTO investigadores (nombre, apellidos, email, id_rango) VALUES
('Carlos', 'Martinez', 'carlos1@lab.com', 1),
('Ana', 'Lopez', 'ana1@lab.com', 2),
('Luis', 'Gomez', 'luis1@lab.com', 3),
('Maria', 'Perez', 'maria1@lab.com', 2),
('Jorge', 'Ramirez', 'jorge1@lab.com', 1);

-- ============================================================================
-- SECCIÓN 4: laboratorios
-- ============================================================================

INSERT INTO laboratorios (codigo, nombre, ubicacion, id_bioseguridad, capacidad_maxima_simultanea) VALUES
('LAB-001', 'Laboratorio Básico', 'Edificio A', 1, 10),
('LAB-002', 'Laboratorio Intermedio', 'Edificio B', 2, 8),
('LAB-003', 'Laboratorio Alto', 'Edificio C', 3, 6),
('LAB-004', 'Laboratorio Máximo', 'Edificio D', 4, 4),
('LAB-005', 'Laboratorio Secundario', 'Edificio E', 2, 5);

-- ============================================================================
-- SECCIÓN 5: equipos
-- ============================================================================

INSERT INTO equipos (codigo_serial, nombre, id_laboratorio, estado) VALUES
('EQ-001', 'Microscopio', (SELECT id_laboratorio FROM laboratorios WHERE codigo='LAB-001'), 'DISPONIBLE'),
('EQ-002', 'Centrífuga', (SELECT id_laboratorio FROM laboratorios WHERE codigo='LAB-002'), 'MANTENIMIENTO'),
('EQ-003', 'Incubadora', (SELECT id_laboratorio FROM laboratorios WHERE codigo='LAB-003'), 'DISPONIBLE'),
('EQ-004', 'Analizador', (SELECT id_laboratorio FROM laboratorios WHERE codigo='LAB-004'), 'DISPONIBLE'),
('EQ-005', 'Refrigerador', (SELECT id_laboratorio FROM laboratorios WHERE codigo='LAB-005'), 'FUERA_DE_SERVICIO');

-- ============================================================================
-- SECCIÓN 6: reservas
-- (IMPORTANTE: aquí se ejecutan triggers)
-- ============================================================================

-- Reserva válida (debe pasar)
INSERT INTO reservas (id_investigador, id_laboratorio, fecha_inicio, hora_inicio, fecha_fin, hora_fin)
VALUES (
    (SELECT id_investigador FROM investigadores WHERE email='carlos1@lab.com'),
    (SELECT id_laboratorio FROM laboratorios WHERE codigo='LAB-001'),
    '2026-04-21', '08:00', '2026-04-21', '10:00'
);

-- Reserva válida nivel 4 (solo DIRECTOR)
INSERT INTO reservas (id_investigador, id_laboratorio, fecha_inicio, hora_inicio, fecha_fin, hora_fin)
VALUES (
    (SELECT id_investigador FROM investigadores WHERE email='luis1@lab.com'),
    (SELECT id_laboratorio FROM laboratorios WHERE codigo='LAB-004'),
    '2026-04-22', '09:00', '2026-04-22', '11:00'
);

-- Más reservas válidas
INSERT INTO reservas (id_investigador, id_laboratorio, fecha_inicio, hora_inicio, fecha_fin, hora_fin) VALUES
((SELECT id_investigador FROM investigadores WHERE email='ana1@lab.com'),
 (SELECT id_laboratorio FROM laboratorios WHERE codigo='LAB-002'),
 '2026-04-23', '10:00', '2026-04-23', '12:00'),

((SELECT id_investigador FROM investigadores WHERE email='maria1@lab.com'),
 (SELECT id_laboratorio FROM laboratorios WHERE codigo='LAB-003'),
 '2026-04-24', '13:00', '2026-04-24', '15:00'),

((SELECT id_investigador FROM investigadores WHERE email='jorge1@lab.com'),
 (SELECT id_laboratorio FROM laboratorios WHERE codigo='LAB-005'),
 '2026-04-25', '08:00', '2026-04-25', '09:30');

-- ============================================================================
-- SECCIÓN 7: actualización de equipos (dispara trigger auditoría)
-- ============================================================================

UPDATE equipos 
SET estado = 'MANTENIMIENTO'
WHERE codigo_serial = 'EQ-001';

UPDATE equipos 
SET estado = 'DISPONIBLE'
WHERE codigo_serial = 'EQ-002';

-- ============================================================================
-- FIN DE MIGRACIÓN V5
-- ============================================================================