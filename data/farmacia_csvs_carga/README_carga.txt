CSV generados para la OLTP de red de farmacias.

Orden recomendado de carga:
1. provincia.csv
2. canton.csv
3. distrito.csv
4. sucursal.csv
5. laboratorio.csv
6. categoria_producto.csv
7. producto.csv
8. cliente.csv
9. proveedor.csv
10. compra.csv
11. detalle_compra.csv
12. venta.csv
13. detalle_venta.csv

Cantidad de registros por archivo:
- provincia.csv: 4
- canton.csv: 8
- distrito.csv: 14
- sucursal.csv: 7
- laboratorio.csv: 10
- categoria_producto.csv: 8
- producto.csv: 60
- cliente.csv: 220
- proveedor.csv: 8
- compra.csv: 100
- detalle_compra.csv: 700
- venta.csv: 900
- detalle_venta.csv: 2500

Notas:
- No se incluye inventario_sucursal.csv porque los triggers pueden crear y actualizar inventario automáticamente a partir de compras y ventas.
- No se incluye movimiento_inventario.csv porque los triggers generan entradas y salidas automáticamente.
- Los encabezados de compra y venta se dejan en 0.00 en sus totales para que los triggers los recalculen al cargar los detalles.
