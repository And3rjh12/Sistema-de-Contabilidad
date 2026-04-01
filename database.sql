-- ============================================================
-- SISTEMA DE REGISTRO DIARIO v2 - BASE DE DATOS POSTGRESQL
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- TABLA: sucursales
-- ============================================================
CREATE TABLE sucursales (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    activa BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABLA: usuarios
-- ============================================================
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('admin', 'usuario')),
    sucursal_id INTEGER REFERENCES sucursales(id) ON DELETE SET NULL,
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABLA: servicios (para registro diario)
-- ============================================================
CREATE TABLE servicios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

-- ============================================================
-- TABLA: registros (registro diario de servicios)
-- ============================================================
CREATE TABLE registros (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    sucursal_id INTEGER NOT NULL REFERENCES sucursales(id) ON DELETE CASCADE,
    servicio_id INTEGER NOT NULL REFERENCES servicios(id) ON DELETE CASCADE,
    valor NUMERIC(10, 2) NOT NULL CHECK (valor >= 0),
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    hora TIME NOT NULL DEFAULT CURRENT_TIME,
    creado_en TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABLA: registros_banco
-- banco: 'pichincha' | 'guayaquil'
-- tipo_movimiento: 'pago_servicio' | 'deposito' | 'retiro'
-- ============================================================
CREATE TABLE registros_banco (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    sucursal_id INTEGER NOT NULL REFERENCES sucursales(id) ON DELETE CASCADE,
    banco VARCHAR(20) NOT NULL CHECK (banco IN ('pichincha', 'guayaquil')),
    tipo_movimiento VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN ('pago_servicio', 'deposito', 'retiro')),
    valor NUMERIC(10, 2) NOT NULL CHECK (valor >= 0),
    descripcion VARCHAR(200),
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    hora TIME NOT NULL DEFAULT CURRENT_TIME,
    creado_en TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_registros_fecha ON registros(fecha);
CREATE INDEX idx_registros_sucursal ON registros(sucursal_id);
CREATE INDEX idx_registros_usuario ON registros(usuario_id);
CREATE INDEX idx_banco_fecha ON registros_banco(fecha);
CREATE INDEX idx_banco_sucursal ON registros_banco(sucursal_id);
CREATE INDEX idx_banco_banco ON registros_banco(banco);
CREATE INDEX idx_banco_tipo ON registros_banco(tipo_movimiento);

-- ============================================================
-- VISTAS
-- ============================================================

-- Resumen diario servicios por sucursal
CREATE VIEW vista_resumen_diario AS
SELECT
    r.fecha, s.id AS sucursal_id, s.nombre AS sucursal,
    COUNT(r.id) AS total_registros,
    SUM(r.valor) AS total_valor
FROM registros r
JOIN sucursales s ON s.id = r.sucursal_id
GROUP BY r.fecha, s.id, s.nombre
ORDER BY r.fecha DESC, s.nombre;

-- Resumen diario bancos por sucursal
CREATE VIEW vista_resumen_banco_diario AS
SELECT
    rb.fecha, rb.banco, rb.tipo_movimiento,
    s.id AS sucursal_id, s.nombre AS sucursal,
    u.id AS usuario_id, u.nombre AS usuario,
    COUNT(rb.id) AS total_registros,
    SUM(rb.valor) AS total_valor
FROM registros_banco rb
JOIN sucursales s ON s.id = rb.sucursal_id
JOIN usuarios u ON u.id = rb.usuario_id
GROUP BY rb.fecha, rb.banco, rb.tipo_movimiento, s.id, s.nombre, u.id, u.nombre
ORDER BY rb.fecha DESC;

-- ============================================================
-- DATOS INICIALES
-- ============================================================

-- Sucursales
INSERT INTO sucursales (nombre, direccion) VALUES
    ('Sucursal Norte', 'Av. Norte 123'),
    ('Sucursal Sur', 'Calle Sur 456'),
    ('Sucursal Centro', 'Plaza Central 789'),
    ('Sucursal Este', 'Av. Este 101'),
    ('Sucursal Oeste', 'Calle Oeste 202'),
    ('Sucursal Valle', 'Av. Valle 303');

-- Servicios
INSERT INTO servicios (nombre) VALUES
    ('CABINAS'), ('SISTEMA CYBER'), ('REPORTES'), ('GANANCIA'),
    ('PLANOS'), ('CARTULINA PLIEGO'), ('GOLOSINAS'),
    ('IMPRESIONES CON TRANSFERENCIA'), ('TRABAJOS VARIOS'),
    ('MERCADERIA SEÑORA JIME'), ('IMPRESIONES BN'),
    ('IMPRESIONES COLOR'), ('COPIAS BLANCO/NEGRO'),
    ('PAPELERIA'), ('DESCUENTO JULY-ALEX FAJARDO'),
    ('COPIAS COLOR'), ('COPIAS POR TRANSFERENCIA'),
    ('PLANOS POR TRANSFERENCIA'), ('PREFACTURAS'),
    ('TRABAJOS VARIOS CON TRANSFERENCIA'),
    ('MERCADERIA CON TRANSFERENCIA');

-- Admin por defecto (password: Admin1234)
INSERT INTO usuarios (nombre, email, password_hash, rol, sucursal_id) VALUES
    ('Administrador', 'admin@empresa.com',
     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/lewKyNQlXCiS2mGq2',
     'admin', NULL);
