-- Crea y selecciona el esquema de trabajo para la base transaccional.
CREATE SCHEMA oltp_farmacia;
SET search_path TO oltp_farmacia;

-- Crea la tabla de provincias para ubicar geográficamente las sucursales.
CREATE TABLE provincia (
    id_provincia         SERIAL PRIMARY KEY,
    nombre_provincia     VARCHAR(100) NOT NULL UNIQUE
);

-- Crea la tabla de cantones relacionados con cada provincia.
CREATE TABLE canton (
    id_canton            SERIAL PRIMARY KEY,
    id_provincia         INT NOT NULL,
    nombre_canton        VARCHAR(100) NOT NULL,
    CONSTRAINT fk_canton_provincia
        FOREIGN KEY (id_provincia) REFERENCES provincia(id_provincia),
    CONSTRAINT uq_canton UNIQUE (id_provincia, nombre_canton)
);

-- Crea la tabla de distritos relacionados con cada cantón.
CREATE TABLE distrito (
    id_distrito          SERIAL PRIMARY KEY,
    id_canton            INT NOT NULL,
    nombre_distrito      VARCHAR(100) NOT NULL,
    CONSTRAINT fk_distrito_canton
        FOREIGN KEY (id_canton) REFERENCES canton(id_canton),
    CONSTRAINT uq_distrito UNIQUE (id_canton, nombre_distrito)
);

-- Crea la tabla de sucursales de la red de farmacias.
CREATE TABLE sucursal (
    id_sucursal          SERIAL PRIMARY KEY,
    codigo_sucursal      VARCHAR(20) NOT NULL UNIQUE,
    nombre_sucursal      VARCHAR(120) NOT NULL,
    direccion            VARCHAR(250) NOT NULL,
    telefono             VARCHAR(20),
    id_distrito          INT NOT NULL,
    fecha_apertura       DATE,
    estado               VARCHAR(20) NOT NULL DEFAULT 'ACTIVA'
                         CHECK (estado IN ('ACTIVA', 'INACTIVA')),
    CONSTRAINT fk_sucursal_distrito
        FOREIGN KEY (id_distrito) REFERENCES distrito(id_distrito)
);

-- Crea la tabla de laboratorios o fabricantes de productos.
CREATE TABLE laboratorio (
    id_laboratorio       SERIAL PRIMARY KEY,
    codigo_laboratorio   VARCHAR(20) NOT NULL UNIQUE,
    nombre_laboratorio   VARCHAR(120) NOT NULL UNIQUE,
    pais_origen          VARCHAR(80),
    estado               VARCHAR(20) NOT NULL DEFAULT 'ACTIVO'
                         CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

-- Crea la tabla de categorías para clasificar productos.
CREATE TABLE categoria_producto (
    id_categoria         SERIAL PRIMARY KEY,
    codigo_categoria     VARCHAR(20) NOT NULL UNIQUE,
    nombre_categoria     VARCHAR(100) NOT NULL UNIQUE,
    descripcion          VARCHAR(250)
);

-- Crea la tabla de productos comercializados por la red.
CREATE TABLE producto (
    id_producto              SERIAL PRIMARY KEY,
    codigo_producto          VARCHAR(30) NOT NULL UNIQUE,
    nombre_producto          VARCHAR(150) NOT NULL,
    id_categoria             INT NOT NULL,
    id_laboratorio           INT NOT NULL,
    tipo_producto            VARCHAR(30) NOT NULL
                             CHECK (tipo_producto IN (
                                 'MEDICAMENTO',
                                 'CUIDADO_PERSONAL',
                                 'HIGIENE',
                                 'SUPLEMENTO',
                                 'DISPOSITIVO_MEDICO',
                                 'BEBE',
                                 'DERMOCOSMETICO'
                             )),
    presentacion             VARCHAR(80),
    unidad_medida            VARCHAR(30),
    precio_venta_referencia  NUMERIC(12,2) NOT NULL CHECK (precio_venta_referencia >= 0),
    costo_referencia         NUMERIC(12,2) NOT NULL CHECK (costo_referencia >= 0),
    requiere_receta          BOOLEAN NOT NULL DEFAULT FALSE,
    estado                   VARCHAR(20) NOT NULL DEFAULT 'ACTIVO'
                             CHECK (estado IN ('ACTIVO', 'INACTIVO')),
    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (id_categoria) REFERENCES categoria_producto(id_categoria),
    CONSTRAINT fk_producto_laboratorio
        FOREIGN KEY (id_laboratorio) REFERENCES laboratorio(id_laboratorio)
);

-- Crea la tabla de clientes que realizan compras en las sucursales.
CREATE TABLE cliente (
    id_cliente               SERIAL PRIMARY KEY,
    codigo_cliente           VARCHAR(20) NOT NULL UNIQUE,
    tipo_identificacion      VARCHAR(20) NOT NULL
                             CHECK (tipo_identificacion IN ('CEDULA', 'DIMEX', 'PASAPORTE')),
    numero_identificacion    VARCHAR(30) NOT NULL UNIQUE,
    nombre                   VARCHAR(80) NOT NULL,
    apellido_1               VARCHAR(80) NOT NULL,
    apellido_2               VARCHAR(80),
    sexo                     CHAR(1) NOT NULL CHECK (sexo IN ('M', 'F')),
    fecha_nacimiento         DATE NOT NULL,
    telefono                 VARCHAR(20),
    correo                   VARCHAR(120),
    fecha_registro           DATE NOT NULL DEFAULT CURRENT_DATE,
    estado                   VARCHAR(20) NOT NULL DEFAULT 'ACTIVO'
                             CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

-- Crea la tabla de proveedores para registrar el abastecimiento de productos.
CREATE TABLE proveedor (
    id_proveedor             SERIAL PRIMARY KEY,
    codigo_proveedor         VARCHAR(20) NOT NULL UNIQUE,
    nombre_proveedor         VARCHAR(150) NOT NULL UNIQUE,
    tipo_identificacion      VARCHAR(20) NOT NULL
                             CHECK (tipo_identificacion IN ('CEDULA_JURIDICA', 'CEDULA_FISICA', 'DIMEX', 'PASAPORTE')),
    numero_identificacion    VARCHAR(30) NOT NULL UNIQUE,
    telefono                 VARCHAR(20),
    correo                   VARCHAR(120),
    direccion                VARCHAR(250),
    contacto_principal       VARCHAR(120),
    estado                   VARCHAR(20) NOT NULL DEFAULT 'ACTIVO'
                             CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

-- Crea la tabla de encabezado de compras realizadas a proveedores.
CREATE TABLE compra (
    id_compra                BIGSERIAL PRIMARY KEY,
    numero_compra            VARCHAR(30) NOT NULL UNIQUE,
    fecha_compra             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_proveedor             INT NOT NULL,
    id_sucursal              INT NOT NULL,
    subtotal                 NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
    descuento_total          NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (descuento_total >= 0),
    impuesto_total           NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (impuesto_total >= 0),
    total_compra             NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (total_compra >= 0),
    estado                   VARCHAR(20) NOT NULL DEFAULT 'RECIBIDA'
                             CHECK (estado IN ('REGISTRADA', 'RECIBIDA', 'ANULADA')),
    observacion              VARCHAR(250),
    CONSTRAINT fk_compra_proveedor
        FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor),
    CONSTRAINT fk_compra_sucursal
        FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal)
);

-- Crea el detalle de productos incluidos en cada compra.
CREATE TABLE detalle_compra (
    id_detalle_compra        BIGSERIAL PRIMARY KEY,
    id_compra                BIGINT NOT NULL,
    id_producto              INT NOT NULL,
    cantidad                 INT NOT NULL CHECK (cantidad > 0),
    costo_unitario_compra    NUMERIC(12,2) NOT NULL CHECK (costo_unitario_compra >= 0),
    descuento_linea          NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (descuento_linea >= 0),
    impuesto_linea           NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (impuesto_linea >= 0),
    subtotal_linea           NUMERIC(14,2) NOT NULL CHECK (subtotal_linea >= 0),
    total_linea              NUMERIC(14,2) NOT NULL CHECK (total_linea >= 0),
    CONSTRAINT fk_detalle_compra
        FOREIGN KEY (id_compra) REFERENCES compra(id_compra) ON DELETE CASCADE,
    CONSTRAINT fk_detalle_compra_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

-- Crea la tabla de inventario actual por sucursal y producto.
CREATE TABLE inventario_sucursal (
    id_inventario              SERIAL PRIMARY KEY,
    id_sucursal                INT NOT NULL,
    id_producto                INT NOT NULL,
    stock_actual               INT NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
    stock_minimo               INT NOT NULL DEFAULT 0 CHECK (stock_minimo >= 0),
    stock_maximo               INT NOT NULL DEFAULT 0 CHECK (stock_maximo >= 0),
    fecha_ultima_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventario_sucursal
        FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),
    CONSTRAINT fk_inventario_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT uq_inventario UNIQUE (id_sucursal, id_producto)
);

-- Agrega una restricción para asegurar que el stock máximo no sea menor que el mínimo.
ALTER TABLE inventario_sucursal
ADD CONSTRAINT ck_inventario_rangos
CHECK (stock_maximo >= stock_minimo);

-- Crea la tabla histórica de movimientos de inventario.
CREATE TABLE movimiento_inventario (
    id_movimiento            BIGSERIAL PRIMARY KEY,
    id_sucursal              INT NOT NULL,
    id_producto              INT NOT NULL,
    fecha_movimiento         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo_movimiento          VARCHAR(20) NOT NULL
                             CHECK (tipo_movimiento IN ('ENTRADA', 'SALIDA', 'AJUSTE_POSITIVO', 'AJUSTE_NEGATIVO')),
    cantidad                 INT NOT NULL CHECK (cantidad > 0),
    costo_unitario           NUMERIC(12,2) NOT NULL CHECK (costo_unitario >= 0),
    referencia               VARCHAR(50),
    observacion              VARCHAR(250),
    CONSTRAINT fk_movimiento_sucursal
        FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),
    CONSTRAINT fk_movimiento_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

-- Crea la tabla de encabezado de ventas realizadas en las sucursales.
CREATE TABLE venta (
    id_venta                 BIGSERIAL PRIMARY KEY,
    numero_venta             VARCHAR(30) NOT NULL UNIQUE,
    fecha_venta              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_sucursal              INT NOT NULL,
    id_cliente               INT,
    metodo_pago              VARCHAR(30) NOT NULL
                             CHECK (metodo_pago IN ('EFECTIVO', 'TARJETA', 'SINPE', 'TRANSFERENCIA')),
    subtotal                 NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
    descuento_total          NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (descuento_total >= 0),
    impuesto_total           NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (impuesto_total >= 0),
    total_venta              NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (total_venta >= 0),
    estado                   VARCHAR(20) NOT NULL DEFAULT 'FINALIZADA'
                             CHECK (estado IN ('FINALIZADA', 'ANULADA')),
    CONSTRAINT fk_venta_sucursal
        FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),
    CONSTRAINT fk_venta_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

-- Crea el detalle de productos vendidos en cada venta.
CREATE TABLE detalle_venta (
    id_detalle_venta         BIGSERIAL PRIMARY KEY,
    id_venta                 BIGINT NOT NULL,
    id_producto              INT NOT NULL,
    cantidad                 INT NOT NULL CHECK (cantidad > 0),
    precio_unitario_venta    NUMERIC(12,2) NOT NULL CHECK (precio_unitario_venta >= 0),
    costo_unitario_venta     NUMERIC(12,2) NOT NULL CHECK (costo_unitario_venta >= 0),
    descuento_linea          NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (descuento_linea >= 0),
    impuesto_linea           NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (impuesto_linea >= 0),
    subtotal_linea           NUMERIC(14,2) NOT NULL CHECK (subtotal_linea >= 0),
    total_linea              NUMERIC(14,2) NOT NULL CHECK (total_linea >= 0),
    CONSTRAINT fk_detalle_venta
        FOREIGN KEY (id_venta) REFERENCES venta(id_venta) ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

-- Crea índices para acelerar consultas geográficas y comerciales frecuentes.
CREATE INDEX idx_sucursal_distrito ON sucursal(id_distrito);
CREATE INDEX idx_producto_categoria ON producto(id_categoria);
CREATE INDEX idx_producto_laboratorio ON producto(id_laboratorio);
CREATE INDEX idx_inventario_sucursal_producto ON inventario_sucursal(id_sucursal, id_producto);
CREATE INDEX idx_movimiento_fecha ON movimiento_inventario(fecha_movimiento);
CREATE INDEX idx_movimiento_sucursal_producto ON movimiento_inventario(id_sucursal, id_producto);
CREATE INDEX idx_venta_fecha ON venta(fecha_venta);
CREATE INDEX idx_venta_sucursal_fecha ON venta(id_sucursal, fecha_venta);
CREATE INDEX idx_detalle_venta_venta ON detalle_venta(id_venta);
CREATE INDEX idx_detalle_venta_producto ON detalle_venta(id_producto);
CREATE INDEX idx_compra_proveedor ON compra(id_proveedor);
CREATE INDEX idx_compra_sucursal_fecha ON compra(id_sucursal, fecha_compra);
CREATE INDEX idx_detalle_compra_compra ON detalle_compra(id_compra);
CREATE INDEX idx_detalle_compra_producto ON detalle_compra(id_producto);

-- Crea una función para asegurar la existencia del registro de inventario por sucursal y producto.
CREATE OR REPLACE FUNCTION fn_asegurar_inventario(
    p_id_sucursal INT,
    p_id_producto INT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO inventario_sucursal (
        id_sucursal,
        id_producto,
        stock_actual,
        stock_minimo,
        stock_maximo
    )
    VALUES (
        p_id_sucursal,
        p_id_producto,
        0,
        0,
        0
    )
    ON CONFLICT (id_sucursal, id_producto) DO NOTHING;
END;
$$;

-- Crea una función para incrementar stock en inventario.
CREATE OR REPLACE FUNCTION fn_incrementar_stock(
    p_id_sucursal INT,
    p_id_producto INT,
    p_cantidad INT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM fn_asegurar_inventario(p_id_sucursal, p_id_producto);

    UPDATE inventario_sucursal
    SET stock_actual = stock_actual + p_cantidad
    WHERE id_sucursal = p_id_sucursal
      AND id_producto = p_id_producto;
END;
$$;

-- Crea una función para disminuir stock validando disponibilidad suficiente.
CREATE OR REPLACE FUNCTION fn_disminuir_stock(
    p_id_sucursal INT,
    p_id_producto INT,
    p_cantidad INT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock_actual INT;
BEGIN
    PERFORM fn_asegurar_inventario(p_id_sucursal, p_id_producto);

    SELECT stock_actual
    INTO v_stock_actual
    FROM inventario_sucursal
    WHERE id_sucursal = p_id_sucursal
      AND id_producto = p_id_producto
    FOR UPDATE;

    IF v_stock_actual < p_cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente. Sucursal: %, Producto: %, Stock actual: %, Cantidad requerida: %',
            p_id_sucursal, p_id_producto, v_stock_actual, p_cantidad;
    END IF;

    UPDATE inventario_sucursal
    SET stock_actual = stock_actual - p_cantidad
    WHERE id_sucursal = p_id_sucursal
      AND id_producto = p_id_producto;
END;
$$;

-- Crea una función para actualizar automáticamente la fecha de modificación del inventario.
CREATE OR REPLACE FUNCTION fn_actualizar_fecha_inventario()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.fecha_ultima_actualizacion := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Crea un trigger para actualizar la fecha cada vez que cambie el inventario.
CREATE TRIGGER trg_actualizar_fecha_inventario
BEFORE UPDATE ON inventario_sucursal
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_fecha_inventario();

-- Crea una función para calcular subtotales y totales de cada línea de compra.
CREATE OR REPLACE FUNCTION fn_calcular_detalle_compra()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.subtotal_linea := NEW.cantidad * NEW.costo_unitario_compra;
    NEW.total_linea := NEW.subtotal_linea - NEW.descuento_linea + NEW.impuesto_linea;
    RETURN NEW;
END;
$$;

-- Crea un trigger que calcula automáticamente los montos del detalle de compra.
CREATE TRIGGER trg_calcular_detalle_compra
BEFORE INSERT OR UPDATE ON detalle_compra
FOR EACH ROW
EXECUTE FUNCTION fn_calcular_detalle_compra();

-- Crea una función para recalcular los totales del encabezado de compra.
CREATE OR REPLACE FUNCTION fn_recalcular_total_compra()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_compra BIGINT;
BEGIN
    v_id_compra := COALESCE(NEW.id_compra, OLD.id_compra);

    UPDATE compra
    SET subtotal = COALESCE((
            SELECT SUM(subtotal_linea)
            FROM detalle_compra
            WHERE id_compra = v_id_compra
        ), 0),
        impuesto_total = COALESCE((
            SELECT SUM(impuesto_linea)
            FROM detalle_compra
            WHERE id_compra = v_id_compra
        ), 0),
        descuento_total = COALESCE((
            SELECT SUM(descuento_linea)
            FROM detalle_compra
            WHERE id_compra = v_id_compra
        ), 0),
        total_compra = COALESCE((
            SELECT SUM(total_linea)
            FROM detalle_compra
            WHERE id_compra = v_id_compra
        ), 0)
    WHERE id_compra = v_id_compra;

    RETURN NULL;
END;
$$;

-- Crea un trigger que recalcula los montos del encabezado de compra al cambiar el detalle.
CREATE TRIGGER trg_recalcular_total_compra
AFTER INSERT OR UPDATE OR DELETE ON detalle_compra
FOR EACH ROW
EXECUTE FUNCTION fn_recalcular_total_compra();

-- Crea una función para sincronizar inventario y movimientos cuando cambie el detalle de compra.
CREATE OR REPLACE FUNCTION fn_sync_inventario_compra()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_sucursal INT;
    v_numero_compra VARCHAR(30);
    v_estado VARCHAR(20);
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT id_sucursal, numero_compra, estado
        INTO v_id_sucursal, v_numero_compra, v_estado
        FROM compra
        WHERE id_compra = NEW.id_compra;

        IF v_estado = 'RECIBIDA' THEN
            PERFORM fn_incrementar_stock(v_id_sucursal, NEW.id_producto, NEW.cantidad);

            INSERT INTO movimiento_inventario (
                id_sucursal,
                id_producto,
                fecha_movimiento,
                tipo_movimiento,
                cantidad,
                costo_unitario,
                referencia,
                observacion
            )
            VALUES (
                v_id_sucursal,
                NEW.id_producto,
                CURRENT_TIMESTAMP,
                'ENTRADA',
                NEW.cantidad,
                NEW.costo_unitario_compra,
                'COMPRA:' || v_numero_compra,
                'Entrada generada automáticamente por detalle de compra'
            );
        END IF;

        RETURN NULL;
    ELSIF TG_OP = 'UPDATE' THEN
        SELECT id_sucursal, numero_compra, estado
        INTO v_id_sucursal, v_numero_compra, v_estado
        FROM compra
        WHERE id_compra = NEW.id_compra;

        IF v_estado = 'RECIBIDA' THEN
            PERFORM fn_disminuir_stock(v_id_sucursal, OLD.id_producto, OLD.cantidad);

            INSERT INTO movimiento_inventario (
                id_sucursal,
                id_producto,
                fecha_movimiento,
                tipo_movimiento,
                cantidad,
                costo_unitario,
                referencia,
                observacion
            )
            VALUES (
                v_id_sucursal,
                OLD.id_producto,
                CURRENT_TIMESTAMP,
                'AJUSTE_NEGATIVO',
                OLD.cantidad,
                OLD.costo_unitario_compra,
                'REV_COMPRA:' || v_numero_compra,
                'Reverso automático por actualización de detalle de compra'
            );

            PERFORM fn_incrementar_stock(v_id_sucursal, NEW.id_producto, NEW.cantidad);

            INSERT INTO movimiento_inventario (
                id_sucursal,
                id_producto,
                fecha_movimiento,
                tipo_movimiento,
                cantidad,
                costo_unitario,
                referencia,
                observacion
            )
            VALUES (
                v_id_sucursal,
                NEW.id_producto,
                CURRENT_TIMESTAMP,
                'ENTRADA',
                NEW.cantidad,
                NEW.costo_unitario_compra,
                'COMPRA:' || v_numero_compra,
                'Entrada automática por actualización de detalle de compra'
            );
        END IF;

        RETURN NULL;
    ELSIF TG_OP = 'DELETE' THEN
        SELECT id_sucursal, numero_compra, estado
        INTO v_id_sucursal, v_numero_compra, v_estado
        FROM compra
        WHERE id_compra = OLD.id_compra;

        IF v_estado = 'RECIBIDA' THEN
            PERFORM fn_disminuir_stock(v_id_sucursal, OLD.id_producto, OLD.cantidad);

            INSERT INTO movimiento_inventario (
                id_sucursal,
                id_producto,
                fecha_movimiento,
                tipo_movimiento,
                cantidad,
                costo_unitario,
                referencia,
                observacion
            )
            VALUES (
                v_id_sucursal,
                OLD.id_producto,
                CURRENT_TIMESTAMP,
                'AJUSTE_NEGATIVO',
                OLD.cantidad,
                OLD.costo_unitario_compra,
                'REV_COMPRA:' || v_numero_compra,
                'Reverso automático por eliminación de detalle de compra'
            );
        END IF;

        RETURN NULL;
    END IF;

    RETURN NULL;
END;
$$;

-- Crea un trigger para impactar inventario automáticamente desde las compras recibidas.
CREATE TRIGGER trg_sync_inventario_compra
AFTER INSERT OR UPDATE OR DELETE ON detalle_compra
FOR EACH ROW
EXECUTE FUNCTION fn_sync_inventario_compra();

-- Crea una función para revertir inventario cuando una compra es anulada.
CREATE OR REPLACE FUNCTION fn_anular_compra_reversa_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    IF OLD.estado = 'RECIBIDA' AND NEW.estado = 'ANULADA' THEN
        FOR r IN
            SELECT dc.id_producto, dc.cantidad, dc.costo_unitario_compra
            FROM detalle_compra dc
            WHERE dc.id_compra = NEW.id_compra
        LOOP
            PERFORM fn_disminuir_stock(NEW.id_sucursal, r.id_producto, r.cantidad);

            INSERT INTO movimiento_inventario (
                id_sucursal,
                id_producto,
                fecha_movimiento,
                tipo_movimiento,
                cantidad,
                costo_unitario,
                referencia,
                observacion
            )
            VALUES (
                NEW.id_sucursal,
                r.id_producto,
                CURRENT_TIMESTAMP,
                'AJUSTE_NEGATIVO',
                r.cantidad,
                r.costo_unitario_compra,
                'ANULACION_COMPRA:' || NEW.numero_compra,
                'Reverso automático por anulación de compra'
            );
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$;

-- Crea un trigger para revertir inventario al anular compras recibidas.
CREATE TRIGGER trg_anular_compra_reversa_stock
AFTER UPDATE OF estado ON compra
FOR EACH ROW
EXECUTE FUNCTION fn_anular_compra_reversa_stock();

-- Crea una función para calcular subtotales y totales de cada línea de venta.
CREATE OR REPLACE FUNCTION fn_calcular_detalle_venta()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.subtotal_linea := NEW.cantidad * NEW.precio_unitario_venta;
    NEW.total_linea := NEW.subtotal_linea - NEW.descuento_linea + NEW.impuesto_linea;
    RETURN NEW;
END;
$$;

-- Crea un trigger que calcula automáticamente los montos del detalle de venta.
CREATE TRIGGER trg_calcular_detalle_venta
BEFORE INSERT OR UPDATE ON detalle_venta
FOR EACH ROW
EXECUTE FUNCTION fn_calcular_detalle_venta();

-- Crea una función para recalcular los totales del encabezado de venta.
CREATE OR REPLACE FUNCTION fn_recalcular_total_venta()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_venta BIGINT;
BEGIN
    v_id_venta := COALESCE(NEW.id_venta, OLD.id_venta);

    UPDATE venta
    SET subtotal = COALESCE((
            SELECT SUM(subtotal_linea)
            FROM detalle_venta
            WHERE id_venta = v_id_venta
        ), 0),
        impuesto_total = COALESCE((
            SELECT SUM(impuesto_linea)
            FROM detalle_venta
            WHERE id_venta = v_id_venta
        ), 0),
        descuento_total = COALESCE((
            SELECT SUM(descuento_linea)
            FROM detalle_venta
            WHERE id_venta = v_id_venta
        ), 0),
        total_venta = COALESCE((
            SELECT SUM(total_linea)
            FROM detalle_venta
            WHERE id_venta = v_id_venta
        ), 0)
    WHERE id_venta = v_id_venta;

    RETURN NULL;
END;
$$;

-- Crea un trigger que recalcula los montos del encabezado de venta al cambiar el detalle.
CREATE TRIGGER trg_recalcular_total_venta
AFTER INSERT OR UPDATE OR DELETE ON detalle_venta
FOR EACH ROW
EXECUTE FUNCTION fn_recalcular_total_venta();

-- Crea una función para sincronizar inventario y movimientos cuando cambie el detalle de venta.
CREATE OR REPLACE FUNCTION fn_sync_inventario_venta()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_sucursal INT;
    v_numero_venta VARCHAR(30);
    v_estado VARCHAR(20);
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT id_sucursal, numero_venta, estado
        INTO v_id_sucursal, v_numero_venta, v_estado
        FROM venta
        WHERE id_venta = NEW.id_venta;

        IF v_estado = 'FINALIZADA' THEN
            PERFORM fn_disminuir_stock(v_id_sucursal, NEW.id_producto, NEW.cantidad);

            INSERT INTO movimiento_inventario (
                id_sucursal,
                id_producto,
                fecha_movimiento,
                tipo_movimiento,
                cantidad,
                costo_unitario,
                referencia,
                observacion
            )
            VALUES (
                v_id_sucursal,
                NEW.id_producto,
                CURRENT_TIMESTAMP,
                'SALIDA',
                NEW.cantidad,
                NEW.costo_unitario_venta,
                'VENTA:' || v_numero_venta,
                'Salida generada automáticamente por detalle de venta'
            );
        END IF;

        RETURN NULL;
    ELSIF TG_OP = 'UPDATE' THEN
        SELECT id_sucursal, numero_venta, estado
        INTO v_id_sucursal, v_numero_venta, v_estado
        FROM venta
        WHERE id_venta = NEW.id_venta;

        IF v_estado = 'FINALIZADA' THEN
            PERFORM fn_incrementar_stock(v_id_sucursal, OLD.id_producto, OLD.cantidad);

            INSERT INTO movimiento_inventario (
                id_sucursal,
                id_producto,
                fecha_movimiento,
                tipo_movimiento,
                cantidad,
                costo_unitario,
                referencia,
                observacion
            )
            VALUES (
                v_id_sucursal,
                OLD.id_producto,
                CURRENT_TIMESTAMP,
                'AJUSTE_POSITIVO',
                OLD.cantidad,
                OLD.costo_unitario_venta,
                'REV_VENTA:' || v_numero_venta,
                'Reverso automático por actualización de detalle de venta'
            );

            PERFORM fn_disminuir_stock(v_id_sucursal, NEW.id_producto, NEW.cantidad);

            INSERT INTO movimiento_inventario (
                id_sucursal,
                id_producto,
                fecha_movimiento,
                tipo_movimiento,
                cantidad,
                costo_unitario,
                referencia,
                observacion
            )
            VALUES (
                v_id_sucursal,
                NEW.id_producto,
                CURRENT_TIMESTAMP,
                'SALIDA',
                NEW.cantidad,
                NEW.costo_unitario_venta,
                'VENTA:' || v_numero_venta,
                'Salida automática por actualización de detalle de venta'
            );
        END IF;

        RETURN NULL;
    ELSIF TG_OP = 'DELETE' THEN
        SELECT id_sucursal, numero_venta, estado
        INTO v_id_sucursal, v_numero_venta, v_estado
        FROM venta
        WHERE id_venta = OLD.id_venta;

        IF v_estado = 'FINALIZADA' THEN
            PERFORM fn_incrementar_stock(v_id_sucursal, OLD.id_producto, OLD.cantidad);

            INSERT INTO movimiento_inventario (
                id_sucursal,
                id_producto,
                fecha_movimiento,
                tipo_movimiento,
                cantidad,
                costo_unitario,
                referencia,
                observacion
            )
            VALUES (
                v_id_sucursal,
                OLD.id_producto,
                CURRENT_TIMESTAMP,
                'AJUSTE_POSITIVO',
                OLD.cantidad,
                OLD.costo_unitario_venta,
                'REV_VENTA:' || v_numero_venta,
                'Reverso automático por eliminación de detalle de venta'
            );
        END IF;

        RETURN NULL;
    END IF;

    RETURN NULL;
END;
$$;

-- Crea un trigger para impactar inventario automáticamente desde las ventas finalizadas.
CREATE TRIGGER trg_sync_inventario_venta
AFTER INSERT OR UPDATE OR DELETE ON detalle_venta
FOR EACH ROW
EXECUTE FUNCTION fn_sync_inventario_venta();

-- Crea una función para revertir inventario cuando una venta es anulada.
CREATE OR REPLACE FUNCTION fn_anular_venta_reversa_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    IF OLD.estado = 'FINALIZADA' AND NEW.estado = 'ANULADA' THEN
        FOR r IN
            SELECT dv.id_producto, dv.cantidad, dv.costo_unitario_venta
            FROM detalle_venta dv
            WHERE dv.id_venta = NEW.id_venta
        LOOP
            PERFORM fn_incrementar_stock(NEW.id_sucursal, r.id_producto, r.cantidad);

            INSERT INTO movimiento_inventario (
                id_sucursal,
                id_producto,
                fecha_movimiento,
                tipo_movimiento,
                cantidad,
                costo_unitario,
                referencia,
                observacion
            )
            VALUES (
                NEW.id_sucursal,
                r.id_producto,
                CURRENT_TIMESTAMP,
                'AJUSTE_POSITIVO',
                r.cantidad,
                r.costo_unitario_venta,
                'ANULACION_VENTA:' || NEW.numero_venta,
                'Reverso automático por anulación de venta'
            );
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$;

-- Crea un trigger para revertir inventario al anular ventas finalizadas.
CREATE TRIGGER trg_anular_venta_reversa_stock
AFTER UPDATE OF estado ON venta
FOR EACH ROW
EXECUTE FUNCTION fn_anular_venta_reversa_stock();

-- Crea una vista operativa que muestra ventas con ingresos, costos y margen por línea.
CREATE OR REPLACE VIEW vw_ventas_detalle_margen AS
SELECT
    v.id_venta,
    v.numero_venta,
    v.fecha_venta,
    v.id_sucursal,
    s.codigo_sucursal,
    s.nombre_sucursal,
    dv.id_producto,
    p.codigo_producto,
    p.nombre_producto,
    dv.cantidad,
    dv.precio_unitario_venta,
    dv.costo_unitario_venta,
    dv.total_linea AS ingreso_linea,
    (dv.costo_unitario_venta * dv.cantidad) AS costo_linea,
    (dv.total_linea - (dv.costo_unitario_venta * dv.cantidad)) AS margen_linea
FROM venta v
JOIN detalle_venta dv
    ON v.id_venta = dv.id_venta
JOIN sucursal s
    ON v.id_sucursal = s.id_sucursal
JOIN producto p
    ON dv.id_producto = p.id_producto
WHERE v.estado = 'FINALIZADA';

-- Crea una vista operativa del inventario actual por sucursal y producto.
CREATE OR REPLACE VIEW vw_inventario_actual AS
SELECT
    i.id_inventario,
    s.id_sucursal,
    s.codigo_sucursal,
    s.nombre_sucursal,
    p.id_producto,
    p.codigo_producto,
    p.nombre_producto,
    i.stock_actual,
    i.stock_minimo,
    i.stock_maximo,
    i.fecha_ultima_actualizacion
FROM inventario_sucursal i
JOIN sucursal s
    ON i.id_sucursal = s.id_sucursal
JOIN producto p
    ON i.id_producto = p.id_producto;

-- Crea una vista resumen de salidas de inventario por sucursal, producto y mes.
CREATE OR REPLACE VIEW vw_salidas_inventario AS
SELECT
    mi.id_sucursal,
    s.codigo_sucursal,
    s.nombre_sucursal,
    mi.id_producto,
    p.codigo_producto,
    p.nombre_producto,
    DATE_TRUNC('month', mi.fecha_movimiento)::date AS periodo_mes,
    SUM(mi.cantidad) AS unidades_salida,
    SUM(mi.cantidad * mi.costo_unitario) AS costo_salida
FROM movimiento_inventario mi
JOIN sucursal s
    ON mi.id_sucursal = s.id_sucursal
JOIN producto p
    ON mi.id_producto = p.id_producto
WHERE mi.tipo_movimiento IN ('SALIDA', 'AJUSTE_NEGATIVO')
GROUP BY
    mi.id_sucursal,
    s.codigo_sucursal,
    s.nombre_sucursal,
    mi.id_producto,
    p.codigo_producto,
    p.nombre_producto,
    DATE_TRUNC('month', mi.fecha_movimiento)::date;

-- Agrega comentarios de documentación para facilitar la trazabilidad de las tablas operativas.
COMMENT ON TABLE sucursal IS 'Fuente operacional de las sucursales de la red de farmacias.';
COMMENT ON TABLE laboratorio IS 'Catálogo operacional de laboratorios o fabricantes.';
COMMENT ON TABLE categoria_producto IS 'Catálogo operacional de categorías de producto.';
COMMENT ON TABLE producto IS 'Catálogo operacional de productos vendidos en la red.';
COMMENT ON TABLE cliente IS 'Registro operacional de clientes.';
COMMENT ON TABLE proveedor IS 'Catálogo operacional de proveedores de productos para la red de farmacias.';
COMMENT ON TABLE compra IS 'Encabezado de compras realizadas por las sucursales o la red a proveedores.';
COMMENT ON TABLE detalle_compra IS 'Detalle operacional de productos adquiridos en cada compra.';
COMMENT ON TABLE inventario_sucursal IS 'Existencia actual por sucursal y producto.';
COMMENT ON TABLE movimiento_inventario IS 'Historial operacional de entradas, salidas y ajustes de inventario.';
COMMENT ON TABLE venta IS 'Encabezado de transacciones de venta.';
COMMENT ON TABLE detalle_venta IS 'Detalle operacional de productos vendidos por venta.';
