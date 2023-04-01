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
