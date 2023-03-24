--1. Cuales son los paises donde la empresa tiene tiendas?
SELECT 
	DISTINCT pais 
FROM 
	stg.store_master
	
--2. Cuantos productos por subcategoria tiene disponible para la venta?
SELECT 
	subcategoria, COUNT(codigo_producto) 
FROM 
	stg.product_master 
GROUP BY 
	subcategoria
	
--3. Cuales son las ordenes de venta de Argentina de mayor a $100.000?
SELECT 
	orden, SUM(venta) 
FROM stg.order_line_sale 
WHERE moneda = 'ARS' 
GROUP BY orden 
HAVING SUM(venta)>100000

--4. Obtener los decuentos otorgados durante Noviembre de 2022 en cada una de las monedas?
SELECT 
	fecha, SUM(descuento) AS Descuentos
FROM stg.order_line_sale 
WHERE 
	fecha BETWEEN '2022-11-01' AND '2022-11-30' 
GROUP BY fecha
HAVING SUM(descuento) IS NOT NULL

--5. Obtener los impuestos pagados en Europa durante el 2022.
SELECT 
	moneda, SUM(impuestos) AS Impuestos
FROM stg.order_line_sale
WHERE moneda = 'EUR' 
AND fecha BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY moneda

--6. En cuantas ordenes se utilizaron creditos?
SELECT 
	COUNT(DISTINCT orden)
FROM stg.order_line_sale
WHERE creditos IS NOT NULL

--7. Cual es el % de descuentos otorgados (sobre las ventas) por tienda?
SELECT 
	orden, tienda, SUM(descuento)/SUM(venta)*(-1) as tasa_impuesto
FROM stg.order_line_sale
WHERE descuento is not null
GROUP BY orden, tienda
ORDER BY tienda
--PREGUNTAR

--8. Cual es el inventario promedio por dia que tiene cada tienda?
SELECT tienda, fecha, AVG(inicial)
FROM stg.inventory
GROUP BY tienda, fecha
ORDER BY fecha
--preguntar

--9. Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina.
SELECT producto, SUM(venta) AS Ventas, SUM(descuento)/SUM(venta)*(-1) AS tasa_dcto
FROM stg.order_line_sale
WHERE moneda='ARS'
GROUP BY producto
--PREGUNTAR

--10. Las tablas "market_count" y "super_store_count" representan dos sistemas distintos que usa la empresa para contar la cantidad de gente que ingresa a tienda, uno para las tiendas de Latinoamerica y otro para Europa. Obtener en una unica tabla, las entradas a tienda de ambos sistemas.
SELECT tienda, CAST(REPLACE(fecha,'-','') as INTEGER), conteo 
FROM stg.super_store_count
UNION 
SELECT * FROM stg.market_count

--11. Cuales son los productos disponibles para la venta (activos) de la marca Phillips?
SELECT * FROM stg.product_master 
WHERE nombre LIKE '%PHILIPS%'
AND is_active = true

--12. Obtener el monto vendido por tienda y moneda y ordenarlo de mayor a menor por valor nominal.
SELECT tienda, moneda, SUM(venta) AS Venta
FROM stg.order_line_sale
GROUP BY tienda, moneda
ORDER BY Venta DESC

--13. Cual es el precio promedio de venta de cada producto en las distintas monedas? Recorda que los valores de venta, impuesto, descuentos y creditos es por el total de la linea.
SELECT producto, moneda, sum(venta) AS Venta, 
	sum(descuento) AS descuento, sum(creditos) as creditos, sum(impuestos) as impuesto,
	(
	 sum(venta+impuestos)+
	 sum(case when creditos is not null then creditos else 0 end)+
	 sum(case when descuento is not null then descuento else 0 end)
	)/count(venta) as TOTO
FROM stg.order_line_sale
GROUP BY producto, moneda
ORDER BY producto DESC
--PREGUNTAR

--14. Cual es la tasa de impuestos que se pago por cada orden de venta?
SELECT orden, SUM(impuestos)/sum(venta) AS Tasa_Impuesto
FROM stg.order_line_sale
GROUP BY orden

