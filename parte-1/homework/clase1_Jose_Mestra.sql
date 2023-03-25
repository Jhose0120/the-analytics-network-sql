--1. Mostrar todos los productos dentro de la categoria electro junto con todos los detalles.
SELECT * 
FROM stg.product_master 
WHERE categoria = 'Electro'

--2. Cuales son los producto producidos en China?
SELECT * 
FROM stg.product_master 
WHERE origen = 'China'

--3. Mostrar todos los productos de Electro ordenados por nombre.
SELECT * 
FROM stg.product_master
WHERE categoria = 'Electro' 
ORDER BY nombre

--4. Cuales son las TV que se encuentran activas para la venta?
SELECT * 
FROM stg.product_master 
WHERE subcategoria = 'TV' AND is_active = true

--5. Mostrar todas las tiendas de Argentina ordenadas por fecha de apertura de las mas antigua a la mas nueva.
SELECT * 
FROM stg.store_master 
WHERE pais = 'Argentina' 
ORDER BY fecha_apertura

--6. Cuales fueron las ultimas 5 ordenes de ventas?
SELECT * 
FROM stg.order_line_sale 
ORDER BY fecha DESC limit 5

--7. Mostrar los primeros 10 registros de el conteo de trafico por Super store ordenados por fecha.
SELECT tienda, cast(fecha as date), conteo 
FROM stg.super_store_count 
ORDER BY fecha 
LIMIT 10

--8. Cuales son los producto de electro que no son Soporte de TV ni control remoto.
SELECT * 
FROM stg.product_master 
WHERE categoria = 'Electro' 
	AND subsubcategoria != 'Soporte' 
	AND subsubcategoria != 'Control remoto'
	
--9. Mostrar todas las lineas de venta donde el monto sea mayor a $100.000 solo para transacciones en pesos.
SELECT * FROM stg.order_line_sale 
	WHERE moneda = 'ARS' 
	AND venta > 100000
	
--10. Mostrar todas las lineas de ventas de Octubre 2022.
SELECT * 
FROM stg.order_line_sale 
WHERE 
  fecha BETWEEN '2022-10-01' AND '2022-10-31'

--11. Mostrar todos los productos que tengan EAN.
SELECT * 
FROM stg.product_master 
WHERE ean IS NOT NULL

--12. Mostrar todas las lineas de venta que que hayan sido vendidas entre 1 de Octubre de 2022 y 10 de Noviembre de 2022.
SELECT * 
FROM stg.order_line_sale 
WHERE 
  fecha BETWEEN '2022-10-01' AND '2022-11-10'
