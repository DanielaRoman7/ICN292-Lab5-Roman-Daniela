-- ============================================================================
-- ICN292 - SISTEMAS DE INFORMACIÓN PARA LA GESTIÓN | LABORATORIO 5
-- ANDES BIKE
-- ============================================================================

-- ============================================================================
-- ENTREGABLE 1 | CREACIÓN DE LA BASE Y TABLAS
-- ============================================================================
DROP DATABASE IF EXISTS andesbike;
CREATE DATABASE andesbike;
USE andesbike;

-- Tabla de tiendas
CREATE TABLE tiendas (
    id_tienda INT AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL,
    comuna VARCHAR(60) NOT NULL,
    PRIMARY KEY (id_tienda)
);

-- Tabla de vendedores, con clave foránea hacia tiendas
CREATE TABLE vendedores (
    id_vendedor INT AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    id_tienda INT,
    fecha_ingreso DATE NOT NULL,
    PRIMARY KEY (id_vendedor),
    FOREIGN KEY (id_tienda) REFERENCES tiendas(id_tienda)
);

-- Tabla de bicicletas
CREATE TABLE bicicletas (
    id_bicicleta INT AUTO_INCREMENT,
    modelo VARCHAR(60) NOT NULL,
    categoria ENUM('Eléctrica', 'Infantil', 'Montaña', 'Ruta', 'Urbana') NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_bicicleta)
);

-- Tabla de ventas, con claves foráneas hacia vendedores y bicicletas
CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT,
    id_vendedor INT NOT NULL,
    id_bicicleta INT NOT NULL,
    fecha DATE NOT NULL,
    unidades INT NOT NULL,
    PRIMARY KEY (id_venta),
    FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor),
    FOREIGN KEY (id_bicicleta) REFERENCES bicicletas(id_bicicleta)
);

-- ============================================================================
-- CARGA OFICIAL
-- ============================================================================
INSERT INTO tiendas (nombre, comuna) VALUES
('Andes Providencia', 'Providencia'),   -- 1
('Andes Maipú', 'Maipú'),               -- 2
('Andes Concepción', 'Concepción'),     -- 3
('Andes La Serena', 'La Serena');       -- 4

INSERT INTO vendedores (nombre, id_tienda, fecha_ingreso) VALUES
('Camila Ortiz', 1, '2024-06-20'),      -- 1
('Diego Fuentes', 1, '2024-01-15'),     -- 2
('Javiera Soto', 2, '2023-07-24'),      -- 3
('Matías Herrera', 2, '2024-01-15'),    -- 4
('Paula Riquelme', 3, '2022-11-02'),    -- 5
('Ignacio Vera', 3, '2024-08-19'),      -- 6
('Fernanda Lillo', 1, '2025-02-03'),    -- 7
('Rubén Castro', NULL, '2025-06-10');   -- 8

INSERT INTO bicicletas (modelo, categoria, precio) VALUES
('Cordillera 29', 'Montaña', 549990.00),      -- 1
('Ruta Austral', 'Ruta', 899990.00),          -- 2
('Urbana Pro', 'Urbana', 329990.00),          -- 3
('Pequeño Andes', 'Infantil', 149990.00),     -- 4
('Volt City', 'Eléctrica', 1249990.00),       -- 5
('Trail Master', 'Montaña', 749990.00),       -- 6
('Urbana Lite', 'Urbana', 229990.00),         -- 7
('Sprint R7', 'Ruta', 1099990.00);            -- 8

INSERT INTO ventas (id_vendedor, id_bicicleta, fecha, unidades) VALUES
(1, 1, '2025-03-04', 2),
(1, 3, '2025-03-18', 1),
(1, 5, '2025-04-02', 1),
(2, 2, '2025-03-04', 1),
(2, 1, '2025-04-11', 3),
(2, 7, '2025-05-06', 2),
(3, 4, '2025-03-21', 4),
(3, 3, '2025-04-15', 2),
(3, 6, '2025-05-20', 1),
(4, 1, '2025-03-27', 1),
(4, 5, '2025-05-09', 2),
(5, 2, '2025-04-08', 1),
(5, 6, '2025-04-23', 2),
(5, 4, '2025-06-02', 5),
(6, 3, '2025-05-13', 3),
(6, 7, '2025-06-17', 1),
(6, 1, '2025-06-24', 2),
(1, 6, '2025-06-30', 1);

-- ============================================================================
-- ENTREGABLE 2 | CONSULTAS
-- ============================================================================

-- Consulta 1: vendedores con su cantidad de ventas, incluidos los que no tienen ventas
SELECT v.nombre AS `Vendedor`, COUNT(ve.id_venta) AS `Cantidad de ventas`
FROM vendedores v
LEFT JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
GROUP BY v.id_vendedor, v.nombre
ORDER BY `Cantidad de ventas` DESC, v.nombre;

-- Consulta 2: ventas y unidades por tienda, incluidas las tiendas sin vendedores
SELECT t.nombre AS `Tienda`,
       COUNT(ve.id_venta) AS `Ventas`,
       SUM(ve.unidades) AS `Unidades vendidas`
FROM tiendas t
LEFT JOIN vendedores v ON t.id_tienda = v.id_tienda
LEFT JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
GROUP BY t.id_tienda, t.nombre
ORDER BY `Unidades vendidas` DESC;

-- Consulta 3: tiendas sin ningún vendedor asignado
SELECT t.nombre AS `Tienda`, t.comuna AS `Comuna`
FROM tiendas t
LEFT JOIN vendedores v ON t.id_tienda = v.id_tienda
WHERE v.id_vendedor IS NULL;

-- Consulta 4: modelos que no se vendieron en junio de 2025
SELECT b.modelo AS `Modelo`, b.categoria AS `Categoría`
FROM bicicletas b
LEFT JOIN ventas ve ON b.id_bicicleta = ve.id_bicicleta
    AND ve.fecha BETWEEN '2025-06-01' AND '2025-06-30'
WHERE ve.id_venta IS NULL
ORDER BY b.modelo;

-- Consulta 5: vendedores sin ventas y su tienda
SELECT v.nombre AS `Vendedor`, t.nombre AS `Tienda`
FROM vendedores v
LEFT JOIN tiendas t ON v.id_tienda = t.id_tienda
LEFT JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
WHERE ve.id_venta IS NULL
ORDER BY v.nombre;

-- Consulta 6: pares de vendedores de la misma tienda, primero el que ingresó antes
SELECT a.nombre AS `Vendedor 1`,
       a.fecha_ingreso AS `Ingreso 1`,
       b.nombre AS `Vendedor 2`,
       b.fecha_ingreso AS `Ingreso 2`,
       t.nombre AS `Tienda`
FROM vendedores a
JOIN vendedores b ON a.id_tienda = b.id_tienda
    AND a.fecha_ingreso < b.fecha_ingreso
JOIN tiendas t ON a.id_tienda = t.id_tienda
ORDER BY t.nombre, a.fecha_ingreso, b.fecha_ingreso;

-- Consulta 7: monto vendido por tienda en bicicletas de Montaña y Ruta, sobre 2.000.000
SELECT t.nombre AS `Tienda`, SUM(ve.unidades * b.precio) AS `Monto Montaña y Ruta`
FROM tiendas t
JOIN vendedores v ON t.id_tienda = v.id_tienda
JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
JOIN bicicletas b ON ve.id_bicicleta = b.id_bicicleta
WHERE b.categoria IN ('Montaña', 'Ruta')
GROUP BY t.id_tienda, t.nombre
HAVING SUM(ve.unidades * b.precio) > 2000000
ORDER BY `Monto Montaña y Ruta` DESC;

-- Consulta 8: bicicletas con precio sobre el promedio del catálogo
SELECT AVG(precio) AS `Precio promedio`
FROM bicicletas;

SELECT modelo AS `Modelo`, precio AS `Precio`
FROM bicicletas
WHERE precio > (SELECT AVG(precio) FROM bicicletas)
ORDER BY precio DESC;

-- Consulta 9: vendedores cuyo promedio de unidades supera el promedio de la cadena
SELECT v.nombre AS `Vendedor`, AVG(ve.unidades) AS `Promedio de unidades`
FROM vendedores v
JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
GROUP BY v.id_vendedor, v.nombre
HAVING AVG(ve.unidades) > (SELECT AVG(unidades) FROM ventas)
ORDER BY `Promedio de unidades` DESC, v.nombre;

-- Consulta 10: monto total vendido por cada vendedor, incluidos los que no vendieron
SELECT v.nombre AS `Vendedor`, SUM(ve.unidades * b.precio) AS `Monto total`
FROM vendedores v
LEFT JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
LEFT JOIN bicicletas b ON ve.id_bicicleta = b.id_bicicleta
GROUP BY v.id_vendedor, v.nombre
ORDER BY `Monto total` DESC;
