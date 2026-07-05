\set ON_ERROR_STOP on

BEGIN;

DO $$
DECLARE
    object_name TEXT;
BEGIN
    FOREACH object_name IN ARRAY ARRAY[
        'cliente',
        'categoria',
        'producto',
        'venta',
        'detalleventa',
        'repartidor',
        'envio',
        'catalogopublico',
        'vista_auditoriaclientes',
        'resumenventas',
        'reporteenviosporrepartidor'
    ]
    LOOP
        IF to_regclass('public.' || object_name) IS NOT NULL THEN
            RAISE EXCEPTION 'EcoBazaar objects already exist; use an empty disposable database';
        END IF;
    END LOOP;
END
$$;

CREATE TABLE Cliente (
    ClienteID INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Correo VARCHAR(100) NOT NULL,
    Telefono VARCHAR(20),
    FechaRegistro DATE NOT NULL,
    CONSTRAINT uq_cliente_correo UNIQUE (Correo)
);

CREATE TABLE Categoria (
    CategoriaID INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    CONSTRAINT uq_categoria_nombre UNIQUE (Nombre)
);

CREATE TABLE Producto (
    ProductoID INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255),
    Precio NUMERIC(10, 2) NOT NULL,
    Stock INT NOT NULL DEFAULT 0,
    EsOrganico BOOLEAN NOT NULL DEFAULT FALSE,
    Activo BOOLEAN NOT NULL DEFAULT TRUE,
    CategoriaID INT NOT NULL REFERENCES Categoria(CategoriaID),
    CONSTRAINT ck_producto_precio CHECK (Precio >= 0),
    CONSTRAINT ck_producto_stock CHECK (Stock >= 0)
);

CREATE TABLE Venta (
    VentaID INT PRIMARY KEY,
    FechaEmision DATE NOT NULL,
    Total NUMERIC(10, 2) NOT NULL,
    ClienteID INT NOT NULL REFERENCES Cliente(ClienteID),
    Estado VARCHAR(30) NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT ck_venta_total CHECK (Total >= 0)
);

CREATE TABLE DetalleVenta (
    DetalleVentaID INT PRIMARY KEY,
    VentaID INT NOT NULL REFERENCES Venta(VentaID),
    ProductoID INT NOT NULL REFERENCES Producto(ProductoID),
    Cantidad INT NOT NULL,
    PrecioUnitario NUMERIC(10, 2) NOT NULL,
    CONSTRAINT ck_detalle_cantidad CHECK (Cantidad > 0),
    CONSTRAINT ck_detalle_precio CHECK (PrecioUnitario >= 0),
    CONSTRAINT uq_detalle_venta_producto UNIQUE (VentaID, ProductoID)
);

CREATE TABLE Repartidor (
    RepartidorID INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Placa VARCHAR(20) NOT NULL,
    CONSTRAINT uq_repartidor_placa UNIQUE (Placa)
);

CREATE TABLE Envio (
    EnvioID INT PRIMARY KEY,
    VentaID INT NOT NULL REFERENCES Venta(VentaID),
    RepartidorID INT NOT NULL REFERENCES Repartidor(RepartidorID),
    Estatus VARCHAR(30) NOT NULL DEFAULT 'Pendiente',
    Costo NUMERIC(10, 2) NOT NULL,
    CONSTRAINT uq_envio_venta UNIQUE (VentaID),
    CONSTRAINT ck_envio_costo CHECK (Costo >= 0)
);

INSERT INTO Cliente VALUES
(1, 'Cliente', 'Uno', 'cliente1@example.test', '555-1001', '2026-01-05'),
(2, 'Cliente', 'Dos', 'cliente2@example.test', '555-1002', '2026-01-06'),
(3, 'Cliente', 'Tres', 'cliente3@example.test', NULL, '2026-01-07'),
(4, 'Cliente', 'Cuatro', 'cliente4@example.test', '555-1004', '2026-01-08'),
(5, 'Cliente', 'Cinco', 'cliente5@example.test', '555-1005', '2026-01-09');

INSERT INTO Categoria VALUES
(1, 'Limpieza'),
(2, 'Alimentos'),
(3, 'Cuidado Personal'),
(4, 'Hogar'),
(5, 'Reutilizables');

INSERT INTO Producto VALUES
(1, 'Producto Eco 01', 'Fixture de catalogo 01', 10.00, 100, TRUE, TRUE, 1),
(2, 'Producto Eco 02', 'Fixture de catalogo 02', 15.00, 80, FALSE, TRUE, 2),
(3, 'Producto Eco 03', 'Fixture de catalogo 03', 20.00, 60, TRUE, TRUE, 3),
(4, 'Producto Eco 04', 'Fixture de catalogo 04', 25.00, 50, FALSE, TRUE, 4),
(5, 'Producto Eco 05', 'Fixture de catalogo 05', 30.00, 40, TRUE, TRUE, 5),
(6, 'Producto Eco 06', 'Fixture de catalogo 06', 35.00, 35, FALSE, TRUE, 1),
(7, 'Producto Eco 07', 'Fixture de catalogo 07', 40.00, 30, TRUE, TRUE, 2),
(8, 'Producto Eco 08', 'Fixture de catalogo 08', 45.00, 25, FALSE, TRUE, 3),
(9, 'Producto Eco 09', 'Fixture de catalogo 09', 50.00, 20, TRUE, TRUE, 4),
(10, 'Producto Eco 10', 'Fixture de catalogo 10', 55.00, 18, FALSE, TRUE, 5),
(11, 'Producto Eco 11', 'Fixture de catalogo 11', 60.00, 16, TRUE, TRUE, 1),
(12, 'Producto Eco 12', 'Fixture de catalogo 12', 65.00, 14, FALSE, TRUE, 2),
(13, 'Producto Eco 13', 'Fixture de catalogo 13', 70.00, 12, TRUE, TRUE, 3),
(14, 'Producto Eco 14', NULL, 75.00, 10, FALSE, TRUE, 4),
(15, 'Producto Eco 15', 'Fixture inactivo', 80.00, 8, TRUE, FALSE, 5);

INSERT INTO Venta VALUES
(1001, '2026-02-01', 55.00, 1, 'Pagada'),
(1002, '2026-02-02', 80.00, 2, 'Pagada'),
(1003, '2026-02-03', 120.00, 3, 'Pagada'),
(1004, '2026-02-04', 160.00, 4, 'Pendiente'),
(1005, '2026-02-05', 190.00, 5, 'Pagada');

INSERT INTO DetalleVenta VALUES
(1, 1001, 1, 2, 10.00),
(2, 1001, 2, 1, 15.00),
(3, 1001, 3, 1, 20.00),
(4, 1002, 4, 2, 25.00),
(5, 1002, 5, 1, 30.00),
(6, 1003, 6, 1, 35.00),
(7, 1003, 7, 1, 40.00),
(8, 1003, 8, 1, 45.00),
(9, 1004, 9, 1, 50.00),
(10, 1004, 10, 2, 55.00),
(11, 1005, 11, 1, 60.00),
(12, 1005, 12, 2, 65.00);

INSERT INTO Repartidor VALUES
(1, 'Repartidor Norte', 'API-001'),
(2, 'Repartidor Sur', 'API-002');

INSERT INTO Envio VALUES
(1, 1001, 1, 'En transito', 20.00),
(2, 1002, 1, 'Entregado', 25.00),
(3, 1003, 2, 'Pendiente', 30.00);

CREATE VIEW CatalogoPublico AS
SELECT
    p.ProductoID,
    p.Nombre AS Producto,
    p.Descripcion,
    p.Precio,
    p.Stock,
    c.Nombre AS Categoria
FROM Producto p
INNER JOIN Categoria c ON c.CategoriaID = p.CategoriaID
WHERE p.Activo = TRUE
  AND p.Stock > 0;

CREATE VIEW Vista_AuditoriaClientes AS
SELECT ClienteID, Nombre, Apellido, FechaRegistro
FROM Cliente;

CREATE VIEW ResumenVentas AS
SELECT
    v.VentaID,
    v.FechaEmision,
    v.Estado,
    c.ClienteID,
    c.Nombre || ' ' || c.Apellido AS Cliente,
    SUM(d.Cantidad) AS Unidades,
    SUM(d.Cantidad * d.PrecioUnitario) AS TotalCalculado,
    v.Total AS TotalRegistrado
FROM Venta v
INNER JOIN Cliente c ON c.ClienteID = v.ClienteID
INNER JOIN DetalleVenta d ON d.VentaID = v.VentaID
GROUP BY
    v.VentaID,
    v.FechaEmision,
    v.Estado,
    c.ClienteID,
    c.Nombre,
    c.Apellido,
    v.Total;

CREATE VIEW ReporteEnviosPorRepartidor AS
SELECT
    r.RepartidorID,
    r.Nombre AS Repartidor,
    COUNT(e.EnvioID) AS TotalPaquetes,
    COALESCE(SUM(e.Costo), 0) AS TotalCostosEnvio
FROM Repartidor r
LEFT JOIN Envio e ON e.RepartidorID = r.RepartidorID
GROUP BY r.RepartidorID, r.Nombre;

CREATE INDEX idx_producto_categoria
    ON Producto (CategoriaID);

CREATE INDEX idx_venta_cliente_fecha
    ON Venta (ClienteID, FechaEmision);

CREATE INDEX idx_detalleventa_producto
    ON DetalleVenta (ProductoID);

CREATE INDEX idx_envio_repartidor
    ON Envio (RepartidorID);

COMMIT;
