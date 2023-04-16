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
Select to_char(fecha, 'YYYY-MM') as mes,
	sum(venta_usd) as ventas_brutas, sum(venta_neta_usd) as ventas_netas, sum(margen_ventas_usd) as margen
from stg_dolares
group by mes

--Margen por categoria de producto
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
	
Select categoria, to_char(fecha, 'YYYY-MM')as mes, 
	 sum(margen_ventas_usd) as margen
from stg_dolares
inner join stg.product_master
on producto=codigo_producto
group by categoria, mes

--ROI por categoria de producto. ROI = Valor promedio de inventario / ventas netas
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
	
Select pm.categoria, to_char(dol.fecha, 'YYYY-MM')as mes, 
	 (((sum(inv.inicial)+sum(inv.final))/2)* sum(dol.costo_promedio_usd))/sum(dol.venta_neta_usd) as ROI
from stg_dolares as dol
inner join stg.product_master as pm
on producto=codigo_producto
inner join stg.inventory as inv
on inv.sku = producto and inv.tienda=dol.tienda
group by pm.categoria, mes

--AOV (Average order value), valor promedio de la orden.
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
	
Select to_char(fecha, 'YYYY-MM')as mes, 
	orden, 
	sum(venta_usd)/sum(cantidad) as AOV
from stg_dolares
group by mes, orden
order by mes

-- CONTABILIDAD
--Impuestos pagados
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
	
Select to_char(fecha, 'YYYY-MM')as mes, 
	sum(impuestos_usd) as impuestos_pagados
from stg_dolares
group by mes

--Tasa de impuesto. Impuestos / Ventas netas
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
	
Select to_char(fecha, 'YYYY-MM')as mes, 
	sum(impuestos_usd)/sum(venta_neta_usd) as tasa_impuesto
from stg_dolares
group by mes

--Cantidad de creditos otorgados
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
	
Select to_char(dol.fecha, 'YYYY-MM')as mes, dol.tienda,
	 (((sum(inv.inicial)+sum(inv.final))/2)* sum(dol.costo_promedio_usd)) as costo_prom_inv
from stg_dolares as dol
inner join stg.inventory as inv
on inv.sku = producto and inv.tienda=dol.tienda
group by mes, dol.tienda
order by mes

--Costo del stock de productos que no se vendieron por tienda
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

--Preguntas de entrevistas
/*
1 -Como encuentro duplicados en una tabla. Dar un ejemplo mostrando duplicados de la columna orden en la tabla de ventas.
	R/ Podemos encontrar duplicados agrupando por la linea de detalle y realizando un conteo asociado a la misma y si alguna de las lineas de detalle cuanta con mas de un registro tendremos duplicados
*/
select line_key, count(orden) 
from bkp.ventas
group by line_key
having count(orden) > 1

--2- Como elimino duplicados?
/*De acuerdo a la información de la tabla podemos determinar las opciones, 
	1-si tenemos un dato extra que nos ayude a determinar cual borrar podemos usarlo con la funcion delete
	2-No tenemos diferenciador, pordriamos crear una tabla provisional sin duplicados, eliminar los datos de la original y alimentarla con los datos de la tabla provisional
	Como ejemplo se crea un respaldo de la tabla ventas llamada bkp.ventas y planteamos el modo de solucion
*/
--Primer escenario 
WITH tabla_auxiliar AS(
    select distinct ve.* 
	from bkp.ventas as ve
)
select * into bkp.prueba from tabla_auxiliar;
delete from bkp.ventas;
insert into bkp.ventas
select *
from bkp.prueba;
drop table bkp.prueba

--Segundo Escenario asumiendo que existe un campo extra tipo contador que nos ayude a diferenciar los valores
DELETE FROM tabla v2 USING (
      SELECT MIN(campo_contador) as campo_contador, linea_detalle
        FROM tabla 
        GROUP BY linea_detalle HAVING COUNT(*) > 1
      ) b
      WHERE v2.linea_detalle = b.linea_detalle 
      AND v2.campo_contador <> b.campo_contador

/* 4- Como encuentro registros en una tabla que no estan en otra tabla.
Para probar podes crear dos tablas con una unica columna id que tengan valores: Tabla 1: 1,2,3,4 Tabla 2: 3,4,5,6
*/
create table bkp.tabla1(
	ide int
);
create table bkp.tabla2(
	ide int
);
insert into bkp.tabla1 
values
(1),
(2),
(3),
(4);
insert into bkp.tabla2
values
(3),
(4),
(5),
(6);

select * from bkp.tabla1 t1
full outer join bkp.tabla2 as t2
on t1.ide = t2.ide
where t1.ide is null or  t2.ide is null

select 
-- 5- Cual es la diferencia entre INNER JOIN y LEFT JOIN. (podes usar la tabla anterior)
--El inner join solo nos mostrara los valores a los cuales se les aplica la condición ON
select * from bkp.tabla1 t1
inner join bkp.tabla2 as t2
on t1.ide = t2.ide
--En cambio el left Join nos muestra todos los valores de la tabla 1 con su respectiva asociacion en la tabla 2
select * from bkp.tabla1 t1
left join bkp.tabla2 as t2
on t1.ide = t2.ide
