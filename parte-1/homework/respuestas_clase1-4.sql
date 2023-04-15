-- CLASE 1
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
SELECT * FROM stg.store_master 
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
SELECT * FROM stg.product_master 
WHERE categoria = 'Electro' 
	AND subsubcategoria != 'Soporte' 
	AND subsubcategoria != 'Control remoto'
	
--9. Mostrar todas las lineas de venta donde el monto sea mayor a $100.000 solo para transacciones en pesos.
SELECT * FROM stg.order_line_sale 
	WHERE moneda = 'ARS' 
	AND venta > 100000
	
--10. Mostrar todas las lineas de ventas de Octubre 2022.
SELECT * FROM stg.order_line_sale 
WHERE fecha BETWEEN '2022-10-01' AND '2022-10-31'

--11. Mostrar todos los productos que tengan EAN.
SELECT * FROM stg.product_master 
WHERE ean IS NOT NULL

--12. Mostrar todas las lineas de venta que que hayan sido vendidas entre 1 de Octubre de 2022 y 10 de Noviembre de 2022.
SELECT * FROM stg.order_line_sale 
WHERE fecha BETWEEN '2022-10-01' AND '2022-11-10'

-- CLASE 2
--1. Cuales son los paises donde la empresa tiene tiendas?
SELECT 
	DISTINCT pais 
FROM 
	stg.store_master
	
--2. Cuantos productos por subcategoria tiene disponible para la venta?
SELECT 	subcategoria, COUNT(codigo_producto) 
FROM 	stg.product_master 
GROUP BY  subcategoria
	
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
	tienda, SUM(descuento)/SUM(venta)*(-1) as tasa_descuentos
FROM stg.order_line_sale
WHERE descuento is not null
GROUP BY tienda
ORDER BY tienda

--8. Cual es el inventario promedio por dia que tiene cada tienda?
SELECT tienda, fecha, (sum(inv.inicial) + sum(inv.final))/2 as inv_promedio
FROM stg.inventory as inv
GROUP BY tienda, fecha
ORDER BY fecha

--9. Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina.
SELECT 
	producto, SUM(venta+coalesce(descuento,0)) AS Ventas_Netas, 
	SUM(descuento)/SUM(venta)*(-1) AS tasa_dcto
FROM stg.order_line_sale
WHERE moneda='ARS'
GROUP BY producto

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
SELECT producto, moneda,
	sum(venta+impuestos+coalesce(descuento,0)+coalesce(creditos,0))/sum(cantidad) as precio_promedio
FROM stg.order_line_sale
GROUP BY producto, moneda
ORDER BY producto DESC

--14. Cual es la tasa de impuestos que se pago por cada orden de venta?
SELECT orden, SUM(impuestos)/sum(venta) AS Tasa_Impuesto
FROM stg.order_line_sale
GROUP BY orden

--Clase 3
--1. Mostrar nombre y codigo de producto, categoria y color para todos los productos de la marca Philips y Samsung, mostrando la leyenda "Unknown" cuando no hay un color disponible
Select 
	nombre, codigo_producto, categoria, coalesce(color, 'Unknown') as Color
from stg.product_master
where nombre like '%PHILIPS%'
	OR nombre like '%Samsung%'
	
--2.Calcular las ventas brutas y los impuestos pagados por pais y provincia en la moneda correspondiente.
select 
	sm.pais, sm.provincia, ols.moneda, 
	sum(ols.venta) as ventas_brutas, sum(ols.impuestos) as impuestos 
from stg.order_line_sale as ols
inner join stg.store_master as sm
on ols.tienda = sm.codigo_tienda
group by sm.pais, sm.provincia, ols.moneda

--3. Calcular las ventas totales por subcategoria de producto para cada moneda ordenados por subcategoria y moneda.
select 
	pm.subcategoria, ols.moneda, 
	sum(ols.venta) as ventas
from stg.order_line_sale as ols
inner join stg.product_master as pm
on ols.producto = pm.codigo_producto
group by pm.subcategoria, ols.moneda
order by pm.subcategoria, ols.moneda

--4. Calcular las unidades vendidas por subcategoria de producto y la concatenacion de pais, provincia; usar guion como separador y usarla para ordernar el resultado.
select 
	pm.subcategoria, concat(sm.pais, '-' ,sm.provincia) as concatenacion,
	sum(ols.cantidad) as und_vendidas
from stg.order_line_sale as ols
inner join stg.product_master as pm
on ols.producto = pm.codigo_producto
inner join stg.store_master as sm
 on ols.tienda = sm.codigo_tienda
group by pm.subcategoria, concatenacion
order by concatenacion

--5. Mostrar una vista donde sea vea el nombre de tienda y la cantidad de entradas de personas que hubo desde la fecha de apertura para el sistema "super_store".
select 
	sm.nombre, sum(ssc.conteo) as cant_visitas
from stg.super_store_count as ssc
inner join stg.store_master as sm
on ssc.tienda = sm.codigo_tienda
group by sm.nombre

--6. Cual es el nivel de inventario promedio en cada mes a nivel de codigo de producto y tienda; mostrar el resultado con el nombre de la tienda.
select  
	sm.nombre, inv.sku, substring(cast(inv.fecha as text) from 1 for 6) as anio_mes,
	sum(inv.inicial + inv.final)/2
from stg.inventory as inv
inner join stg.store_master as sm
on sm.codigo_tienda = inv.tienda
group by sm.nombre, inv.sku, anio_mes

--7. Calcular la cantidad de unidades vendidas por material. Para los productos que no tengan material usar 'Unknown', homogeneizar los textos si es necesario.
select foo.material, sum(foo.cant_by_mat) 
from (
		select coalesce(upper(pm.material),'unknown') as material, sum(ols.cantidad) as cant_by_mat
		from stg.product_master as pm
		left join stg.order_line_sale as ols
			on pm.codigo_producto = ols.producto
		group by  material
	) as foo
group by foo.material

--8. Mostrar la tabla order_line_sales agregando una columna que represente el valor de venta bruta en cada linea convertido a dolares usando la tabla de tipo de cambio.
select *, 
	case 
		When ols.moneda = 'ARS' then ols.venta/mar.cotizacion_usd_peso
		When ols.moneda = 'EUR' then ols.venta/mar.cotizacion_usd_eur
		When ols.moneda = 'URU' then ols.venta/mar.cotizacion_usd_uru
	end as venta_dolares
from stg.order_line_sale as ols
left join stg.monthly_average_fx_rate as mar
on substring(cast(ols.fecha as text) from 1 for 7) = substring(cast(mar.mes as text) from 1 for 7)

--9. Calcular cantidad de ventas totales de la empresa en dolares.
select sum(vendol.venta_dolares) from
(select *,
	case 
		When ols.moneda = 'ARS' then ols.venta/mar.cotizacion_usd_peso
		When ols.moneda = 'EUR' then ols.venta/mar.cotizacion_usd_eur
		When ols.moneda = 'URU' then ols.venta/mar.cotizacion_usd_uru
	end as venta_dolares
from stg.order_line_sale as ols
left join stg.monthly_average_fx_rate as mar
on substring(cast(ols.fecha as text) from 1 for 7) = substring(cast(mar.mes as text) from 1 for 7)
 ) as vendol
--10. Mostrar en la tabla de ventas el margen de venta por cada linea. Siendo margen = (venta - promociones) - costo expresado en dolares.
select ols.*,
	case 
		When ols.moneda = 'ARS' then ((ols.venta+coalesce(ols.descuento,0))/mar.cotizacion_usd_peso)-(cos.costo_promedio_usd*ols.cantidad)
		When ols.moneda = 'EUR' then ((ols.venta+coalesce(ols.descuento,0))/mar.cotizacion_usd_eur)-(cos.costo_promedio_usd*ols.cantidad)
		When ols.moneda = 'URU' then ((ols.venta+coalesce(ols.descuento,0))/mar.cotizacion_usd_uru)-(cos.costo_promedio_usd*ols.cantidad)
	end as Margen_ventas
from stg.order_line_sale as ols
left join stg.cost as cos
on cos.codigo_producto = ols.producto
left join stg.monthly_average_fx_rate as mar
on substring(cast(ols.fecha as text) from 1 for 7) = substring(cast(mar.mes as text) from 1 for 7)

--11. Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.
select ols.orden, count(distinct pm.subsubcategoria) as subcategorias_diferentes
		from stg.order_line_sale as ols
		left join stg.product_master as pm
			on pm.codigo_producto = ols.producto
group by  ols.orden

-- Clase 4
-- 1. Crear un backup de la tabla product_master. Utilizar un esquema llamada "bkp" y agregar un prefijo al nombre de la tabla con la fecha del backup en forma de numero entero.
create schema if not exists bkp;

select *,
	cast((replace((cast(current_date as varchar(10))),'-','')) as integer) as fecha_backup
into bkp.product_master_20230329
from stg.product_master

-- 2. Hacer un update a la nueva tabla (creada en el punto anterior) de product_master agregando la leyendo "N/A" para los valores null de material y color. Pueden utilizarse dos sentencias.
update bkp.product_master_20230329
set material = coalesce(material,'N/A'), color = coalesce(color,'N/A')
where material = null or color = null;

select * from bkp.product_master_20230329 where subsubcategoria='Control remoto'
-- 3. Hacer un update a la tabla del punto anterior, actualizando la columa "is_active", desactivando todos los productos en la subsubcategoria "Control Remoto".
update bkp.product_master_20230329
set is_active = false
where subsubcategoria='Control remoto'

-- 4. Agregar una nueva columna a la tabla anterior llamada "is_local" indicando los productos producidos en Argentina y fuera de Argentina.
alter table bkp.product_master_20230329 
add column is_local boolean;

update bkp.product_master_20230329
set is_local = (case when origen = 'Argentina' then true else false end)
where is_local = null;

-- 5. Agregar una nueva columna a la tabla de ventas llamada "line_key" que resulte ser la concatenacion de el numero de orden y el codigo de producto.
select * 
into bkp.ventas
from stg.order_line_sale;

alter table bkp.ventas add column line_key varchar(50);

update bkp.ventas set line_key = concat(orden,producto) where line_key = null;
-- 6. Eliminar todos los valores de la tabla "order_line_sale" para el POS 1.
delete from bkp.ventas 
where pos = 1;

-- 7. Crear una tabla llamada "employees" (por el momento vacia) que tenga un id (creado de forma incremental), nombre, apellido, fecha de entrada, fecha salida, telefono, pais, provincia, codigo_tienda, posicion. Decidir cual es el tipo de dato mas acorde.
create table bkp.employees 
(
	id_employee serial, 
	nombre varchar(100), 
	apellido varchar(100), 
	fecha_entrada date, 
	fecha_salida date, 
	telefono varchar(100), 
	pais varchar(225), 
	provincia varchar(225), 
	codigo_tienda varchar(225), 
	posicion varchar(225)
);
drop table bkp.employees
-- 8. Insertar nuevos valores a la tabla "employees" para los siguientes 4 empleados:
-- Juan Perez, 2022-01-01, telefono +541113869867, Argentina, Santa Fe, tienda 2, Vendedor.
-- Catalina Garcia, 2022-03-01, Argentina, Buenos Aires, tienda 2, Representante Comercial
-- Ana Valdez, desde 2020-02-21 hasta 2022-03-01, España, Madrid, tienda 8, Jefe Logistica
-- Fernando Moralez, 2022-04-04, España, Valencia, tienda 9, Vendedor.
insert into bkp.employees
(nombre, apellido, fecha_entrada, fecha_salida, telefono, pais, provincia, codigo_tienda, posicion)
values
('Juan', 'Perez',  '2022-01-01',null, '+541113869867',  'Argentina',  'Santa Fe',  'tienda 2',  'Vendedor'),
('Catalina', 'Garcia',  '2022-03-01',null,null,  'Argentina',  'Buenos Aires',  'tienda 2',  'Representante Comercial'),
('Ana', 'Valdez', '2020-02-21', '2022-03-01',null,  'España',  'Madrid',  'tienda 8',  'Jefe Logistica'),
('Fernando', 'Moralez',  '2022-04-04',null,null,  'España',  'Valencia',  'tienda 9',  'Vendedor')

-- 9. Crear un backup de la tabla "cost" agregandole una columna que se llame "last_updated_ts" que sea el momento exacto en el cual estemos realizando el backup en formato datetime.
select *
	, current_timestamp as last_updated_ts
into bkp.cost
from stg.cost;

-- 10. El cambio en la tabla "order_line_sale" en el punto 6 fue un error y debemos volver la tabla a su estado original, como lo harias?

--Indagando un poco encontré que se puede hacer uso de "rollback" siempre y cuando el borrado se hubiese ejecutado por medio de una transacción, caso contrario no se puede revertir, por lo cual el único modo de restablecer la información es a través del backup, si no se tiene se perdió la información.
--Dado que las acciones las realice en la tabla backup puedo recuperar los datos ejecutando las siguientes sentencias:
drop table if exists bkp.ventas;
select * 
into bkp.ventas
from stg.order_line_sale;
alter table bkp.ventas add column line_key varchar(50);
update bkp.ventas as vent 
set line_key = concat(orden, producto) 
where line_key is null;

/*  Ejercicio Integrador
Luego de un tiempo de haber respondido todas las preguntas puntuales por los gerentes, la empresa decide ampliar el contrato para mejorar las bases de reporte de datos. 
Para esto quiere definir una serie de KPIs (Key Performance Indicator) que midan la salud de la empresa en diversas areas y ademas mostrar el valor actual y la evolucion 
en el tiempo. Por cada KPI listado vamos a tener que generar al menos una query (pueden ser mas de una) que nos devuelva el valor del KPI en cada mes, mostrando el 
resultado para todos los meses disponibles.
Todos los valores monetarios deben ser calculados en dolares usando el tipo de cambio promedio mensual.
El objetivo no es solo encontrar la query que responda la metrica sino entender que datos necesitamos, que es lo que significa y como armar el KPI General 
Por otro lado tambien necesitamos crear y subir a nuestra DB la tabla "return_movements" para poder utilizarla en la segunda parte.*/

-- *KPIs General*
-- · Ventas brutas, netas y margen
with stg_dolares as (
select ols.*, 
	case 
		When ols.moneda = 'ARS' then ols.venta/mar.cotizacion_usd_peso
		When ols.moneda = 'EUR' then ols.venta/mar.cotizacion_usd_eur
		When ols.moneda = 'URU' then ols.venta/mar.cotizacion_usd_uru
	end as venta_usd,
	case 
		When ols.moneda = 'ARS' then ((ols.venta+coalesce(ols.descuento,0))/mar.cotizacion_usd_peso)
		When ols.moneda = 'EUR' then ((ols.venta+coalesce(ols.descuento,0))/mar.cotizacion_usd_eur)
		When ols.moneda = 'URU' then ((ols.venta+coalesce(ols.descuento,0))/mar.cotizacion_usd_uru)
	end as venta_neta_usd,
	case 
		When ols.moneda = 'ARS' then ((ols.venta+coalesce(ols.descuento,0))/mar.cotizacion_usd_peso)-(cos.costo_promedio_usd*ols.cantidad)
		When ols.moneda = 'EUR' then ((ols.venta+coalesce(ols.descuento,0))/mar.cotizacion_usd_eur)-(cos.costo_promedio_usd*ols.cantidad)
		When ols.moneda = 'URU' then ((ols.venta+coalesce(ols.descuento,0))/mar.cotizacion_usd_uru)-(cos.costo_promedio_usd*ols.cantidad)
	end as Margen_ventas_usd,
	case 
		When ols.moneda = 'ARS' then ols.impuestos/mar.cotizacion_usd_peso
		When ols.moneda = 'EUR' then ols.impuestos/mar.cotizacion_usd_eur
		When ols.moneda = 'URU' then ols.impuestos/mar.cotizacion_usd_uru
	end as impuestos_usd,
	cos.costo_promedio_usd
from stg.order_line_sale as ols
left join stg.cost as cos
on cos.codigo_producto = ols.producto
left join stg.monthly_average_fx_rate as mar
on to_char(ols.fecha, 'yyyy-mm') = to_char(mar.mes, 'yyyy-mm')
)
/*
Select to_char(fecha, 'YYYY-MM') as mes,
	sum(venta_usd) as ventas_brutas, sum(venta_neta_usd) as ventas_netas, sum(margen_ventas_usd) as margen
from stg_dolares
group by mes

--Margen por categoria de producto
Select categoria, to_char(fecha, 'YYYY-MM')as mes, 
	 sum(margen_ventas_usd) as margen
from stg_dolares
inner join stg.product_master
on producto=codigo_producto
group by categoria, mes

--ROI por categoria de producto. ROI = Valor promedio de inventario / ventas netas
Select pm.categoria, to_char(dol.fecha, 'YYYY-MM')as mes, 
	 (((sum(inv.inicial)+sum(inv.final))/2)* sum(dol.costo_promedio_usd))/sum(dol.venta_neta_usd) as ROI
from stg_dolares as dol
inner join stg.product_master as pm
on producto=codigo_producto
inner join stg.inventory as inv
on inv.sku = producto and inv.tienda=dol.tienda
group by pm.categoria, mes

--AOV (Average order value), valor promedio de la orden.
Select to_char(fecha, 'YYYY-MM')as mes, 
	orden, 
	sum(venta_usd)/sum(cantidad) as AOV
from stg_dolares
group by mes, orden
order by mes

-- CONTABILIDAD
--Impuestos pagados
Select to_char(fecha, 'YYYY-MM')as mes, 
	sum(impuestos_usd) as impuestos_pagados
from stg_dolares
group by mes

--Tasa de impuesto. Impuestos / Ventas netas
Select to_char(fecha, 'YYYY-MM')as mes, 
	sum(impuestos_usd)/sum(venta_neta_usd) as tasa_impuesto
from stg_dolares
group by mes

--Cantidad de creditos otorgados
Select to_char(fecha, 'YYYY-MM')as mes, 
	count(creditos) as creditos_otorgados
from stg_dolares
group by mes

--Valor pagado final por order de linea. Valor pagado: Venta - descuento + impuesto - credito
select ols.*,
	case 
		When ols.moneda = 'ARS' then ((ols.venta+coalesce(ols.descuento,0)+impuestos+coalesce(creditos,0))/mar.cotizacion_usd_peso)
		When ols.moneda = 'EUR' then ((ols.venta+coalesce(ols.descuento,0)+impuestos+coalesce(creditos,0))/mar.cotizacion_usd_eur)
		When ols.moneda = 'URU' then ((ols.venta+coalesce(ols.descuento,0)+impuestos+coalesce(creditos,0))/mar.cotizacion_usd_uru)
	end as valor_pagado_order
from stg.order_line_sale as ols
inner join stg.monthly_average_fx_rate as mar
on to_char(ols.fecha, 'yyyy-mm') = to_char(mar.mes, 'yyyy-mm')

--Supply Chain--
--Costo de inventario promedio por tienda
Select to_char(dol.fecha, 'YYYY-MM')as mes, dol.tienda,
	 (((sum(inv.inicial)+sum(inv.final))/2)* sum(dol.costo_promedio_usd)) as costo_prom_inv
from stg_dolares as dol
inner join stg.inventory as inv
on inv.sku = producto and inv.tienda=dol.tienda
group by mes, dol.tienda
order by mes

--Costo del stock de productos que no se vendieron por tienda
Select to_char(dol.fecha, 'YYYY-MM')as mes, dol.tienda,
	 sum(inv.final)* sum(dol.costo_promedio_usd) as costo_stock
from stg_dolares as dol
inner join stg.inventory as inv
on inv.sku = producto and inv.tienda=dol.tienda
group by mes, dol.tienda
order by mes

--Cantidad y costo de devoluciones
CREATE TABLE stg.return_movements(
	orden_venta   varchar(255),
	envio         varchar(255),
	item          varchar(255),
	cantidad      int,
	id_movimiento varchar(255),
	desde         varchar(255),
	hasta         varchar(255),
	recibido_por  varchar(255),
	fecha         date
)
;
--Como no tenemos el costo de reenvio o generado en cada uno de los puntos, solo se asumiran el costo del producto cuando este es desechado en vez de ser revendido.
*/
select to_char(rmt.fecha, 'YYYY-MM') as mes, 
	sum(rmt.cantidad) as cantidad, 
	sum(rmt.cantidad)* sum(cos.costo_promedio_usd) as costo
from stg.return_movements as rmt
inner join stg.cost as cos
on cos.codigo_producto = item
where hasta = 'Productos Obsoletos'
group by mes

--Tiendas--

--Ratio de conversion. Cantidad de ordenes generadas / Cantidad de gente que entra
with stg_conteo as (
	select foo.fecha, foo.tienda, sum(conteo) as conteo
	from (	SELECT tienda, to_char(CAST(fecha as date),'YYYY-MM') as fecha, conteo
			FROM stg.super_store_count
			UNION 
			SELECT tienda, concat(substring(cast(fecha as text) from 1 for 4),'-',substring(cast(fecha as text) from 5 for 2)), conteo
			FROM stg.market_count) as foo
	group by foo.fecha, foo.tienda
)

select con.fecha, con.tienda, coalesce(opt.norden,0), con.conteo, sum(opt.norden)/sum(con.conteo) as ratio
from stg_conteo as con
left join 
	(SELECT to_char(fecha,'YYYY-MM') as mes , tienda, count(distinct orden) as norden
	from stg.order_line_sale 
	group by mes, tienda) as opt
on con.fecha = opt.mes and con.tienda = opt.tienda
group by con.fecha, con.tienda, opt.norden, con.conteo
order by con.fecha, con.tienda
--Se unen las dos tablas de conteo para tener un panorama real, se agrupa por mes y tienda con el fin de tener un reporte mensual y detallado por tienda.
