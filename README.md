# Proyecto 1 - Inteligencia de Negocios: Red de Farmacias

## Descripción general

Este repositorio contiene el desarrollo del Proyecto 1 del curso TI6900 Inteligencia de Negocios del Tecnológico de Costa Rica. El proyecto consiste en el diseño e implementación de una solución de Inteligencia de Negocios para una red de farmacias, con el propósito de transformar datos operativos en información útil para la toma de decisiones comerciales, operativas y estratégicas.

La solución permite analizar el desempeño de las sucursales, las ventas, los márgenes brutos, el comportamiento del inventario, los productos comercializados y los clientes atendidos. El caso se enfoca en comparar sucursales de manera objetiva, considerando simultáneamente ventas, rentabilidad y rotación de inventario.

## Problema de negocio

La red de farmacias necesita comparar el desempeño de sus sucursales de forma objetiva y consistente. No basta con identificar cuál sucursal vende más, sino que también es necesario determinar cuáles puntos de venta presentan mejores resultados al analizar ventas totales, margen bruto y rotación de inventario.

La ausencia de este análisis limita la capacidad de la organización para detectar sucursales con desempeño sobresaliente, identificar prácticas replicables y reconocer sedes que requieren ajustes en su gestión comercial o en la administración de existencias.

## Objetivo general

Diseñar e implementar una solución integral de Inteligencia de Negocios para una red de farmacias, mediante la construcción de una base de datos transaccional en PostgreSQL, un modelo dimensional, un proceso ETL en Pentaho Data Integration y un dashboard analítico en Metabase.

## Preguntas de negocio

1. ¿Qué sucursales presentan mayores ventas totales durante el periodo analizado y cómo varía ese comportamiento entre meses o trimestres?
2. ¿Qué sucursales obtienen mejores márgenes brutos y cuáles muestran diferencias importantes entre nivel de ventas y rentabilidad alcanzada?
3. ¿Qué sucursales presentan una mejor rotación de inventario y cuáles logran el mejor desempeño conjunto al comparar ventas, margen y movimiento de existencias?

## KPIs principales

- Ventas totales por sucursal.
- Margen bruto por sucursal.
- Rotación de inventario por sucursal.

## Arquitectura de la solución

La solución está organizada en cuatro capas principales:

1. **Fuente operacional / OLTP**  
   Base de datos transaccional diseñada en PostgreSQL para almacenar la operación diaria de la red de farmacias, incluyendo sucursales, productos, laboratorios, clientes, proveedores, compras, ventas e inventario.

2. **Modelo dimensional / DW**  
   Modelo analítico implementado en PostgreSQL bajo el esquema `dw_farmacia`, compuesto por dimensiones y tablas de hechos.

3. **Proceso ETL**  
   Proceso desarrollado en Pentaho Data Integration para extraer datos desde `oltp_farmacia`, transformarlos mediante reglas de limpieza, homologación y derivación, y cargarlos hacia `dw_farmacia`.

4. **Dashboard analítico**  
   Dashboard implementado en Metabase para visualizar indicadores clave y responder las preguntas de negocio planteadas.

## Herramientas utilizadas

| Herramienta | Uso dentro del proyecto |
|---|---|
| PostgreSQL | Gestión de la base de datos transaccional y del modelo dimensional |
| pgAdmin 4 | Administración, ejecución de scripts SQL y validación de datos |
| Pentaho Data Integration | Desarrollo y ejecución del proceso ETL |
| Metabase | Construcción del dashboard analítico |
| GitHub | Control de versiones y almacenamiento de archivos del proyecto |

## Integrantes del grupo

| Integrante | Carné |
|---|---|
| Brandon Badilla Rodríguez | 2023047817 |
| David A. Ramírez Vargas | 2023087580 |
| Emanuel Alves Mata | 2023111119 |
| Michelle Reyes Flores | 2023281947 |
| Caleb Segura Rodríguez | 2024105617 |

## Estructura del repositorio

```text
proyecto1-BI-red-farmacias/
│
├── README.md
│
├── database/
│   ├── oltp_red_farmacias.sql
│   ├── dw_red_farmacias.sql
│   └── backup_red_farmacias.backup
│   └── backup_OTPL_DW_Post_ETL_Redfarmacias.backup
│
├── data/
│   └── farmacia_csvs_carga/
│       ├── provincia.csv
│       ├── canton.csv
│       ├── distrito.csv
│       ├── sucursal.csv
│       ├── laboratorio.csv
│       ├── categoria_producto.csv
│       ├── producto.csv
│       ├── cliente.csv
│       ├── proveedor.csv
│       ├── compra.csv
│       ├── detalle_compra.csv
│       ├── venta.csv
│       ├── detalle_venta.csv
│
├── etl/
│   ├── tr_dim_tiempo.ktr
│   ├── tr_dim_sucursal.ktr
│   ├── tr_dim_producto.ktr
│   ├── tr_dim_cliente.ktr
│   ├── tr_fact_ventas.ktr
│   ├── tr_fact_inventario.ktr
│   └── job_carga_dw_farmacia.kjb
│
├── docs/
│   ├── Documento Apoyo Proyecto 1 - BI - FINAL.pdf
│   └── Proyecto01_BI_Red Farmacias.pdf
│   └── Documento Acceso Repositorio GitHub Proyecto 1 - BI - FINAL.pdf
│   └── ReadMe.txt
│   └── Carpeta: Scripts y Backups
│ 
├── dashboard/
    └── Archivo de código en GitHub / Evidencia en Documento Apoyo Proyecto 1 - BI - FINAL.pdf
