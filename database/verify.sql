\set ON_ERROR_STOP on

DO $$
DECLARE
    required_object TEXT;
    required_constraint TEXT;
BEGIN
    FOREACH required_object IN ARRAY ARRAY[
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
        'reporteenviosporrepartidor',
        'idx_producto_categoria',
        'idx_venta_cliente_fecha',
        'idx_detalleventa_producto',
        'idx_envio_repartidor'
    ]
    LOOP
        IF to_regclass('public.' || required_object) IS NULL THEN
            RAISE EXCEPTION 'Missing required object: %', required_object;
        END IF;
    END LOOP;

    FOREACH required_constraint IN ARRAY ARRAY[
        'uq_cliente_correo',
        'uq_categoria_nombre',
        'ck_producto_precio',
        'ck_producto_stock',
        'ck_venta_total',
        'ck_detalle_cantidad',
        'ck_detalle_precio',
        'uq_detalle_venta_producto',
        'uq_repartidor_placa',
        'uq_envio_venta',
        'ck_envio_costo'
    ]
    LOOP
        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint
            WHERE conname = required_constraint
        ) THEN
            RAISE EXCEPTION 'Missing required constraint: %', required_constraint;
        END IF;
    END LOOP;

    IF (SELECT COUNT(*) FROM Cliente) <> 5
       OR (SELECT COUNT(*) FROM Categoria) <> 5
       OR (SELECT COUNT(*) FROM Producto) <> 15
       OR (SELECT COUNT(*) FROM Venta) <> 5
       OR (SELECT COUNT(*) FROM DetalleVenta) <> 12
       OR (SELECT COUNT(*) FROM Repartidor) <> 2
       OR (SELECT COUNT(*) FROM Envio) <> 3 THEN
        RAISE EXCEPTION 'Unexpected baseline row counts';
    END IF;

    IF EXISTS (
        SELECT 1 FROM Producto WHERE Precio < 0 OR Stock < 0
    ) OR EXISTS (
        SELECT 1 FROM Venta WHERE Total < 0
    ) OR EXISTS (
        SELECT 1
        FROM DetalleVenta
        WHERE Cantidad <= 0 OR PrecioUnitario < 0
    ) OR EXISTS (
        SELECT 1 FROM Envio WHERE Costo < 0
    ) THEN
        RAISE EXCEPTION 'Baseline contains invalid numeric values';
    END IF;

    IF EXISTS (
        SELECT v.VentaID
        FROM Venta v
        INNER JOIN DetalleVenta d ON d.VentaID = v.VentaID
        GROUP BY v.VentaID, v.Total
        HAVING v.Total <> SUM(d.Cantidad * d.PrecioUnitario)
    ) THEN
        RAISE EXCEPTION 'A sale total differs from its details';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM DetalleVenta d
        LEFT JOIN Venta v ON v.VentaID = d.VentaID
        LEFT JOIN Producto p ON p.ProductoID = d.ProductoID
        WHERE v.VentaID IS NULL OR p.ProductoID IS NULL
    ) OR EXISTS (
        SELECT 1
        FROM Envio e
        LEFT JOIN Venta v ON v.VentaID = e.VentaID
        LEFT JOIN Repartidor r ON r.RepartidorID = e.RepartidorID
        WHERE v.VentaID IS NULL OR r.RepartidorID IS NULL
    ) THEN
        RAISE EXCEPTION 'Baseline contains orphaned relationships';
    END IF;

    IF EXISTS (
        SELECT VentaID
        FROM Envio
        GROUP BY VentaID
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'A sale has more than one shipment';
    END IF;

    IF EXISTS (
        SELECT 1 FROM CatalogoPublico WHERE ProductoID = 15
    ) THEN
        RAISE EXCEPTION 'Public catalog exposes an inactive product';
    END IF;
END
$$;

SELECT 'EcoBazaar API baseline verification passed.' AS resultado;
