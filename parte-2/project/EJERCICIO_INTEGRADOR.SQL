/*
Nivel de detalle de la tabla:
	Fecha
	SKU
	Tienda
Con los siguientes atributos
	Tienda: Pais, provincia, Nombre de tienda
	SKU: Categoria, Subcategoria, Subsubcategoria, proveedor
	Fecha: dia, mes, año, año fiscal, quarter fiscal
*/

create or replace view stg.pi_parte2 as
with rango as (
	select min(fecha) as mi, max(fecha) as ma from stg.inventory
	union 
	select min(fecha), max(fecha) from stg.order_line_sale
	union
	select min(fecha),max(fecha) from stg.total_count
)
select d.fecha,coalesce(tc.tienda, inv.tienda, ols.tienda) as id_tienda, coalesce(inv.sku, ols.producto) as id_producto
	,sm.pais ,sm.provincia ,sm.nombre as nombre_tienda 
	,pm.categoria ,pm.subcategoria ,pm.subsubcategoria ,s.nombre as proveedor
	,d.dia_semana, d.mes, d.año, d.año_fiscal, d.trimestre_fiscal
	,(round(venta_usd, 2)) as ventas_brutas_usd ,(round(coalesce(descuento_usd), 2)) as descuento_usd, (round(creditos_usd, 2)) as credito_usd , (round((impuestos/tasa_cambio), 2)) as impuesto_usd, (co.costo_promedio_usd) as costo_total_usd
	,round((rm.valor_usd_retornado),2) as valor_retornado_usd
	,round((((inv.inicial+inv.final)/2)*1.0/count(inv.inicial)over(partition by d.fecha,coalesce(tc.tienda, inv.tienda), coalesce(ols.producto, inv.sku))),4) as inventario_promedio
	,ols.orden
	,round((tc.conteo*1.0/count(tc.conteo)over(partition by d.fecha,coalesce(tc.tienda, inv.tienda))),4) as conteo
	,(ols.cantidad) as cant_producto_vendido
from stg.date as d
full outer join stg.total_count as tc
	on d.fecha = tc.fecha
full outer join stg.inventory as inv
	on d.fecha = inv.fecha and tc.tienda=inv.tienda 
full outer join stg.dolarizacion as ols
	on d.fecha = ols.fecha and ols.tienda=coalesce(tc.tienda, inv.tienda, ols.tienda) and  ols.producto = coalesce(inv.sku, ols.producto)
left join stg.store_master as sm
	on sm.codigo_tienda = coalesce(inv.tienda, ols.tienda, tc.tienda)
left join stg.product_master as pm 
 	on pm.codigo_producto = coalesce(inv.sku, ols.producto)
left join stg.suppliers as s
 	on s.codigo_producto = coalesce(inv.sku, ols.producto) and s.is_primary = true
left join stg.v_return_movements as rm
	on rm.item = coalesce(inv.sku, ols.producto) and rm.orden_venta = ols.orden
left join stg.cost as co
	on co.codigo_producto = coalesce(inv.sku, ols.producto)
where d.fecha between (select min(mi) from rango) and (select max(ma) from rango)
	
--y que se pueda calcular las siguiente metricas:
--Ventas brutas
select sum(ventas_brutas_usd) as ventas_brutas
	from stg.pi_parte2
	
--Descuentos
select sum(descuento_usd) as descuentos 
	from stg.pi_parte2
	
--Impuestos
select sum(impuesto_usd) as impuestos 
	from stg.pi_parte2
	
--Creditos
select sum(credito_usd) as creditos
	from stg.pi_parte2
	
--Ventas netas (inluye ventas y descuentos)
select sum(ventas_brutas_usd)+sum(descuento_usd) as ventas_netas
	from stg.pi_parte2
	
--Valor final pagado (incluye ventas, descuentos, impuestos y creditos)
select 
	sum(ventas_brutas_usd)+sum(descuento_usd)+sum(impuesto_usd)+sum(credito_usd) as valor_final
from stg.pi_parte2

--ROI
select concat(round((100.0*avg(inventario_promedio*costo_total_usd)/sum(ventas_brutas_usd)),2),'%') as roi
from stg.pi_parte2

--Days on hand
select fecha, id_tienda, id_producto,cant_producto_vendido, inventario_promedio, 
		round(inventario_promedio/((sum(cant_producto_vendido) over(partition by id_tienda, id_producto order by fecha rows between 7 preceding and 1 preceding))/7.0),2) as doh
from stg.pi_parte2
	
--Costos
select 
	sum(inventario_promedio*costo_total_usd) as costo_prom_inventario
	,sum(cant_producto_vendido*costo_total_usd) as costo_ventas
from stg.pi_parte2

--Margen bruto (gross margin)
select sum(ventas_brutas_usd)+sum(descuento_usd)-sum(costo_total_usd*cant_producto_vendido) as Margen_bruto
from stg.pi_parte2

--AGM (adjusted gross margin)
select 
sum(ventas_brutas_usd)+sum(descuento_usd)-sum(costo_total_usd*cant_producto_vendido)-sum(valor_retornado_usd) as agm
from stg.pi_parte2

--AOV
--Valor promedio de orden 
select round((sum(ventas_brutas_usd)/count(distinct orden)),2) as aov
from stg.pi_parte2

--Numero de devoluciones
select count(valor_retornado_usd) as numero_devoluciones
from stg.pi_parte2

--Ratio de conversion.
select concat(round((100.0*count(orden)/sum(conteo)),4),'%') as ratio_conversion
from stg.pi_parte2
