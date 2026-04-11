CREATE SCHEMA IF NOT EXISTS dw_farmacia;
SET search_path TO dw_farmacia;

-- DIMENSIONES
-- Esta tabla crea la dimensión de tiempo, utilizada para analizar la información
-- a lo largo de diferentes niveles temporales como día, mes, trimestre y año.
CREATE TABLE dim_tiempo (
    tiempo_key INTEGER PRIMARY KEY,
    fecha_completa DATE NOT NULL UNIQUE,
    dia SMALLINT,
    nombre_dia VARCHAR(20),
    semana SMALLINT,
    mes SMALLINT,
    nombre_mes VARCHAR(20),
    trimestre SMALLINT,
    anio INTEGER,
    semestre SMALLINT
);
-- Esta tabla crea la dimensión de sucursal, permitiendo analizar el desempeño
-- de cada punto de venta e incluir su ubicación geográfica.
CREATE TABLE dim_sucursal (
    sucursal_key SERIAL PRIMARY KEY,
    id_sucursal_origen INTEGER UNIQUE,
    codigo_sucursal VARCHAR(20),
    nombre_sucursal VARCHAR(120),
    direccion VARCHAR(250),
    telefono VARCHAR(20),
    distrito VARCHAR(100),
    canton VARCHAR(100),
    provincia VARCHAR(100),
    fecha_apertura DATE,
    estado_sucursal VARCHAR(20)
);
-- Esta tabla crea la dimensión de producto, que permite analizar productos,
-- categorías y laboratorios asociados.
CREATE TABLE dim_producto (
    producto_key SERIAL PRIMARY KEY,
    id_producto_origen INTEGER UNIQUE,
    codigo_producto VARCHAR(30),
    nombre_producto VARCHAR(150),
    categoria_producto VARCHAR(100),
    nombre_laboratorio VARCHAR(120),
    pais_origen_laboratorio VARCHAR(80),
    tipo_producto VARCHAR(30),
    presentacion VARCHAR(80),
    unidad_medida VARCHAR(30),
    precio_venta_referencia NUMERIC(12,2),
    costo_referencia NUMERIC(12,2),
    requiere_receta BOOLEAN,
    estado_producto VARCHAR(20)
);
-- Esta tabla crea la dimensión de cliente, permitiendo analizar el comportamiento
-- de compra según características demográficas y de identificación.
CREATE TABLE dim_cliente (
    cliente_key SERIAL PRIMARY KEY,
    id_cliente_origen INTEGER UNIQUE,
    codigo_cliente VARCHAR(20),
    tipo_identificacion VARCHAR(20),
    numero_identificacion VARCHAR(30),
    nombre_completo VARCHAR(200),
    sexo CHAR(1),
    fecha_nacimiento DATE,
    edad INTEGER,
    rango_etario VARCHAR(50),
    telefono VARCHAR(20),
    correo VARCHAR(120),
    fecha_registro DATE,
    estado_cliente VARCHAR(20)
);

-- TABLAS DE HECHOS
-- Esta tabla crea la tabla de hechos de ventas, que almacena las métricas
-- principales del negocio relacionadas con las transacciones de venta.
CREATE TABLE fact_ventas (
    venta_key BIGSERIAL PRIMARY KEY,
    tiempo_key INTEGER,
    sucursal_key INTEGER,
    producto_key INTEGER,
    cliente_key INTEGER,
    numero_venta VARCHAR(30),
    metodo_pago VARCHAR(30),
    cantidad_vendida INTEGER,
    precio_unitario_venta NUMERIC(12,2),
    costo_unitario_venta NUMERIC(12,2),
    venta_bruta NUMERIC(14,2),
    descuento NUMERIC(14,2),
    impuesto NUMERIC(14,2),
    venta_neta NUMERIC(14,2),
    costo_total NUMERIC(14,2),
    margen_bruto NUMERIC(14,2),
    estado_venta VARCHAR(20),

    FOREIGN KEY (tiempo_key) REFERENCES dim_tiempo(tiempo_key),
    FOREIGN KEY (sucursal_key) REFERENCES dim_sucursal(sucursal_key),
    FOREIGN KEY (producto_key) REFERENCES dim_producto(producto_key),
    FOREIGN KEY (cliente_key) REFERENCES dim_cliente(cliente_key)
);
-- Esta tabla crea la tabla de hechos de inventario, que permite analizar
-- el estado y movimiento de existencias en cada sucursal.
CREATE TABLE fact_inventario (
    inventario_key BIGSERIAL PRIMARY KEY,
    tiempo_key INTEGER,
    sucursal_key INTEGER,
    producto_key INTEGER,
    stock_actual INTEGER,
    stock_minimo INTEGER,
    stock_maximo INTEGER,
    tipo_movimiento VARCHAR(20),
    cantidad_movimiento INTEGER,
    costo_unitario NUMERIC(12,2),
    costo_inventario NUMERIC(14,2),
    referencia_movimiento VARCHAR(50),
-- Relaciones con dimensiones
    FOREIGN KEY (tiempo_key) REFERENCES dim_tiempo(tiempo_key),
    FOREIGN KEY (sucursal_key) REFERENCES dim_sucursal(sucursal_key),
    FOREIGN KEY (producto_key) REFERENCES dim_producto(producto_key)
);
