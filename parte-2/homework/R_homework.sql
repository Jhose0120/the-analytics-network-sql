--Clase 6
--1. Crear una vista con el resultado del ejercicio de la Parte 1 - Clase 2 - Ejercicio 10, donde unimos la cantidad de gente que ingresa a tienda usando los dos sistemas.
create or replace view stg.total_count as 
SELECT tienda, CAST(fecha as date) as fecha, conteo
	FROM stg.super_store_count
		UNION 
SELECT tienda, cast(cast(fecha as text) as date), conteo
	FROM stg.market_count

--2. Recibimos otro archivo con ingresos a tiendas de meses anteriores. Ingestar el archivo y agregarlo a la vista del ejercicio anterior (Ejercicio 1 Clase 6). Cual hubiese sido la diferencia si hubiesemos tenido una tabla? (contestar la ultima pregunta con un texto escrito en forma de comentario)
--R)La diferencia que se presenta es referente a que la vista almacena la logica de la consulta en el schema y la tabla se debe replicar nuevamente si no se guardo.

--3. Crear una vista con el resultado del ejercicio de la Parte 1 - Clase 3 - Ejercicio 10, donde calculamos el margen bruto en dolares. Agregarle la columna de ventas, descuentos, y creditos en dolares para poder reutilizarla en un futuro.
create or replace view stg.dolarizacion as
with cte_ventas_tc as (
	select *
		,case 
		When ols.moneda = 'ARS' then mar.cotizacion_usd_peso
		When ols.moneda = 'EUR' then mar.cotizacion_usd_eur
		When ols.moneda = 'URU' then mar.cotizacion_usd_uru
	end as tasa_cambio
	from stg.order_line_sale as ols
	left join stg.monthly_average_fx_rate as mar
	on to_char(ols.fecha, 'yyyy-mm') = to_char(mar.mes, 'yyyy-mm')
)
select ols.*
	,((ols.venta+coalesce(ols.descuento,0))/ols.tasa_cambio)-(cos.costo_promedio_usd*ols.cantidad) as Margen_ventas_usd
	,ols.venta/ols.tasa_cambio as venta_usd
	,((coalesce(ols.descuento,0))/ols.tasa_cambio) as descuento_usd
	,coalesce(ols.creditos,0)/ols.tasa_cambio as creditos_usd
	,cos.costo_promedio_usd*ols.cantidad as costo_usd
from cte_ventas_tc as ols
left join stg.cost as cos
on cos.codigo_producto = ols.producto

--4. Generar una query que me sirva para verificar que el nivel de agregacion de la tabla de ventas (y de la vista) no se haya afectado. Recordas que es el nivel de agregacion/detalle? Lo vimos en la teoria de la parte 1! Nota: La orden M999000061 parece tener un problema verdad? Lo vamos a solucionar mas adelante.
select line_key, count(*)
from stg.order_line_sale
group by line_key
having count(*)>1
-- La orden M999000061 esta duplicada

--5. Calcular el margen bruto a nivel Subcategoria de producto. Usar la vista creada.
Select subcategoria, 
	 sum(margen_ventas_usd) as margen
from stg.dolarizacion
inner join stg.product_master
on producto=codigo_producto
group by subcategoria


--6. Calcular la contribucion de las ventas brutas de cada producto al total de la orden. Por esta vez, si necesitas usar una subquery, podes utilizarla.
Select ols.orden, ols.producto, 
	 round((sum(ols.venta_usd)*100/sum(foo.tot_ord)),2) as "%_contribucion"
from stg.dolarizacion as ols
left join (select orden, sum(venta_usd) as tot_ord from stg.dolarizacion group by orden) as foo
on foo.orden = ols.orden
group by ols.orden, ols.producto
order by ols.orden

--7. Calcular las ventas por proveedor, para eso cargar la tabla de proveedores por producto. Agregar el nombre el proveedor en la vista del punto 3.
create table stg.suppliers (
	codigo_producto varchar(250),
	nombre			varchar(250),
	is_primary		boolean
)

create or replace view stg.dolarizacion as
with cte_ventas_tc as (
	select *
		,case 
		When ols.moneda = 'ARS' then mar.cotizacion_usd_peso
		When ols.moneda = 'EUR' then mar.cotizacion_usd_eur
		When ols.moneda = 'URU' then mar.cotizacion_usd_uru
	end as tasa_cambio
	from stg.order_line_sale as ols
	left join stg.monthly_average_fx_rate as mar
	on to_char(ols.fecha, 'yyyy-mm') = to_char(mar.mes, 'yyyy-mm')
)
select ols.*
	,((ols.venta+coalesce(ols.descuento,0))/ols.tasa_cambio)-(cos.costo_promedio_usd*ols.cantidad) as Margen_ventas_usd
	,ols.venta/ols.tasa_cambio as venta_usd
	,((coalesce(ols.descuento,0))/ols.tasa_cambio) as descuento_usd
	,coalesce(ols.creditos,0)/ols.tasa_cambio as creditos_usd
	,cos.costo_promedio_usd*ols.cantidad as costo_usd
	,spt.nombre as proveedor
from cte_ventas_tc as ols
left join stg.cost as cos
	on cos.codigo_producto = ols.producto
left join stg.suppliers as spt
	on spt.codigo_producto = ols.producto;

select * from stg.dolarizacion

/*8. Verificar que el nivel de detalle de la vista anterior no se haya modificado, en caso contrario que se deberia ajustar? Que decision tomarias para que no se genereren duplicados?
		-Se pide correr la query de validacion.*/
	select line_key, count(*)
from stg.dolarizacion
group by line_key
having count(*)>1	
--		-Crear una nueva query que no genere duplicacion.
	create or replace view stg.dolarizacion as
with cte_ventas_tc as (
	select *
		,case 
		When ols.moneda = 'ARS' then mar.cotizacion_usd_peso
		When ols.moneda = 'EUR' then mar.cotizacion_usd_eur
		When ols.moneda = 'URU' then mar.cotizacion_usd_uru
	end as tasa_cambio
	from stg.order_line_sale as ols
	left join stg.monthly_average_fx_rate as mar
	on to_char(ols.fecha, 'yyyy-mm') = to_char(mar.mes, 'yyyy-mm')
)
select ols.*
	,((ols.venta+coalesce(ols.descuento,0))/ols.tasa_cambio)-(cos.costo_promedio_usd*ols.cantidad) as Margen_ventas_usd
	,ols.venta/ols.tasa_cambio as venta_usd
	,((coalesce(ols.descuento,0))/ols.tasa_cambio) as descuento_usd
	,coalesce(ols.creditos,0)/ols.tasa_cambio as creditos_usd
	,cos.costo_promedio_usd*ols.cantidad as costo_usd
	,spt.nombre as proveedor
from cte_ventas_tc as ols
left join stg.cost as cos
	on cos.codigo_producto = ols.producto
left join stg.suppliers as spt
on spt.codigo_producto = ols.producto and spt.is_primary = true;

/*		-Explicar brevemente (con palabras escrito tipo comentario) que es lo que sucedia. 
R/Se generan mas lineas de detalle duplicadas y se debe a que hay varios proveedores con un mismo producto, se soluciona agregando sobre el on is_primary = true  */

--Clase 7
--1. Calcular el porcentaje de valores null de la tabla stg.order_line_sale para la columna creditos y descuentos. (porcentaje de nulls en cada columna)
select 
	round(sum(case when creditos is null then +1.0 end)*100.0/count(*),2) as "%_null_cdtos"
	,round(sum(case when descuento is null then +1.0 end)*100.0/count(*),2) as "%_nu)ll_dctos" 
from stg.order_line_sale

--2. La columna "is_walkout" se refiere a los clientes que llegaron a la tienda y se fueron con el producto en la mano (es decia habia stock disponible). Responder en una misma query:
--Cuantas ordenes fueron "walkout" por tienda?
--Cuantas ventas brutas en USD fueron "walkout" por tienda?
--Cual es el porcentaje de las ventas brutas "walkout" sobre el total de ventas brutas por tienda?
select tienda
	,sum(case when is_walkout = true then +1 end) as "cant_ventas_walkaut"
	,round(sum(case when is_walkout = true then +venta_usd end),4) as "ventas_walkout"
	,round(sum(case when is_walkout = true then +venta_usd end)*100.0/sum(venta_usd),2) as "%_ventas_walkout"
from stg.dolarizacion
group by tienda

--3. Siguiendo el nivel de detalle de la tabla ventas, hay una orden que no parece cumplirlo. Como identificarias duplicados utilizando una windows function? Nota: Esto hace referencia a la orden M999000061. Tenes que generar una forma de excluir los casos duplicados, para este caso particular y a nivel general, si llegan mas ordenes con duplicaciones.
--Para encontrar los duplicados
with dup as (
SELECT * , ROW_NUMBER() OVER (PARTITION BY line_key ORDER BY line_key) AS fila_numero
  FROM stg.order_line_sale
)
Select * from dup
where fila_numero > 1
--Realizar consulta sin duplicados con windows funtion
with dup as (
SELECT * , ROW_NUMBER() OVER (PARTITION BY line_key ORDER BY line_key) AS fila_numero
  FROM stg.order_line_sale
)
Select * from dup
where fila_numero = 1

--4. Obtener las ventas totales en USD de productos que NO sean de la categoria "TV" NI esten en tiendas de Argentina.
select 
	round(sum(case when pm.categoria != 'TV' and sm.pais != 'Argentina' then +dol.venta_usd end),2) as ventas
from stg.dolarizacion as dol
left join stg.store_master as sm
	on dol.tienda = sm.codigo_tienda
left join stg.product_master as pm
	on dol.producto = pm.codigo_producto
  
--5. El gerente de ventas quiere ver el total de unidades vendidas por dia junto con otra columna con la cantidad de unidades vendidas una semana atras y la diferencia entre ambos. Nota: resolver en dos querys usando en una CTEs y en la otra windows functions.
--Consulta con cte 
with cte_fechas as (
	select fecha, sum(cantidad) as ventas_dia
	from stg.dolarizacion
	group by fecha
	order by fecha
)
select ct1.* ,coalesce(ct2.ventas_dia,0) as vta_sem_pasada ,ct1.ventas_dia - coalesce(ct2.ventas_dia,0) as diferencia
from cte_fechas as ct1
left join cte_fechas as ct2
on ct2.fecha = ct1.fecha-7

-- Aplicando windows funcion pero igualando el calculo a los 7 dias 
with recursive cte1 as (
	select max(fecha) as max_f, min(fecha) as dia
	from stg.dolarizacion
	union 
	select max_f , dia+1 as dia
	from cte1
	where dia+1 <= max_f
),
cte2 as (
	select distinct dia, coalesce(sum(cantidad) over(partition by fecha),0) as vta_dia
	from  cte1 
	left join stg.dolarizacion
		on dia=fecha
)
select *, coalesce(lag (vta_dia,7) over(),0) as vt_semana_anterior, coalesce(vta_dia -lag (vta_dia,7) over(), 0) as diferencia
from cte2
where vta_dia !=0

--6. Crear una vista de inventario con la cantidad de inventario por dia, tienda y producto, que ademas va a contar con los siguientes datos:
--Nombre y categorias de producto
--Pais y nombre de tienda
--Costo del inventario por linea (recordar que si la linea dice 4 unidades debe reflejar el costo total de esas 4 unidades)
--Una columna llamada "is_last_snapshot" para el ultimo dia disponible de inventario.
--Ademas vamos a querer calcular una metrica llamada "Average days on hand (DOH)" que mide cuantos dias de venta nos alcanza el inventario. Para eso DOH = Unidades en Inventario Promedio / Promedio diario Unidades vendidas ultimos 7 dias.
--Notas:
--Antes de crear la columna DOH, conviene crear una columna que refleje el Promedio diario Unidades vendidas ultimos 7 dias.
--El nivel de agregacion es dia/tienda/sku.
--El Promedio diario Unidades vendidas ultimos 7 dias tiene que calcularse para cada dia.

create or replace view stg.vista_inventario as 
with hepl as (
select foo.*, lag(sum2, 7) over(partition by foo.tienda, foo.sku) as d 
	from 
	(
	select inv.fecha, inv.tienda, inv.sku, ols.cantidad,inv.inicial
		,sum(ols.cantidad) over(partition by inv.tienda, inv.sku order by inv.fecha) as sum2
	from stg.inventory as inv
		left join stg.order_line_sale as ols
		on inv.sku = ols.producto and inv.tienda = ols.tienda and inv.fecha = ols.fecha
	) as foo
)
select inv.fecha, inv.tienda, inv.sku, pm.nombre as nombre_producto, pm.categoria, sm.nombre as nombre_tienda, sm.pais
	,inv.inicial, (inv.inicial*co.costo_promedio_usd) as costo_inv, coalesce(inv.cantidad, 0) as cant_ventas
	,inv.fecha+7 as is_last_snapshot
	,lag(round(inv.inicial/(case when ((inv.sum2-coalesce(inv.d,0))/7.0) = 0 then null else ((inv.sum2-coalesce(inv.d,0))/7.0) end),0),1) over(partition by inv.tienda, inv.sku order by inv.fecha) as doh
from hepl as inv
left join stg.product_master as pm
	on inv.sku = pm.codigo_producto
left join stg.store_master as sm
	on inv.tienda = sm.codigo_tienda
left join stg.cost as co
	on inv.sku = co.codigo_producto
  
  --Clase 8
--1. Realizar el Ejercicio 5 de la clase 6 donde calculabamos la contribucion de las ventas brutas de cada producto utilizando una window function.

Select ols.orden, ols.producto, concat(round(( 100*ols.venta_usd/sum(venta_usd) over(partition by ols.orden)),2),'%') as contribucion
from stg.dolarizacion as ols

--2. La regla de pareto nos dice que aproximadamente un 20% de los productos generan un 80% de las ventas. Armar una vista a nivel sku donde se pueda identificar por orden de contribucion, ese 20% aproximado de SKU mas importantes. (Nota: En este ejercicios estamos construyendo una tabla que muestra la regla de Pareto)

create or replace view stg.pareto as
with cte_porp as (
	Select distinct pm.codigo_producto
	,coalesce((sum(ols.venta_usd) over(partition by pm.codigo_producto)),0) as venta_producto
	,(sum(ols.venta_usd) over(partition by pm.codigo_producto))/(sum(ols.venta_usd) over()) as por_venta	
	from stg.product_master as pm
	left join stg.dolarizacion as ols
	on ols.producto = pm.codigo_producto
	order by coalesce((sum(ols.venta_usd) over(partition by pm.codigo_producto)),0) desc
),
cte_porp2 as (
	select 100*row_number() over()/count(codigo_producto) over() as por_pro, *
		,100*(row_number() over() - 1)/count(codigo_producto) over() as por_pro2
	from cte_porp
)
select codigo_producto, por_pro as porcentaje_producto
	,round(100*sum(por_venta) over(order by por_pro),0) as acumulado_contribucion
from cte_porp2
where por_pro <=20 or por_pro2<20

--3. Calcular el crecimiento de ventas por tienda mes a mes, con el valor nominal y el valor % de crecimiento.
with crecimiento as (
	select tienda,to_char(fecha, 'YYYY-MM') as mes ,sum(round(venta_usd,2)) as venta_mes
	from stg.dolarizacion
	group by tienda, to_char(fecha, 'YYYY-MM')
	order by 1,2
)
select *, round(100*(venta_mes-lag(venta_mes) over(partition by tienda))/venta_mes, 2) as "%_crecimiento"
from crecimiento

--4. Crear una vista a partir de la tabla "return_movements" que este a nivel Orden de venta, item y que contenga las siguientes columnas:
--Orden
--Sku
--Cantidad unidated retornadas
--Valor USD retornado (resulta de la cantidad retornada * valor USD del precio unitario bruto con que se hizo la venta)
--Nombre producto
--Primera_locacion (primer lugar registrado, de la columna "desde", para la orden/producto)
--Ultima_locacion (el ultimo lugar donde se registro, de la columna "hasta", el producto/orden)

create or replace view stg.v_return_movements as 
select distinct rm.orden_venta, rm.item, rm.cantidad
	,(dol.venta_usd/dol.cantidad)*rm.cantidad valor_usd_retornado ,pm.nombre
	,first_value(desde) over(partition by rm.orden_venta, rm.item)
	,last_value(hasta) over(partition by rm.orden_venta, rm.item)
from stg.return_movements as rm
left join stg.dolarizacion as dol
on rm.orden_venta = dol.orden and rm.item = dol.producto
left join stg.product_master as pm
	on rm.item = pm.codigo_producto

--5. Crear una tabla calendario llamada "date" con las fechas del 2022 incluyendo el año fiscal y trimestre fiscal (en ingles Quarter). El año fiscal de la empresa comienza el primero Febrero de cada año y dura 12 meses. Realizar la tabla para 2022 y 2023. La tabla debe contener:
--Fecha (date)
--Mes (date)
--Año (date)
--Dia de la semana (text, ejemplo: "Monday")
--"is_weekend" (boolean, indicando si es Sabado o Domingo)
--Mes (text, ejemplo: June)
--Año fiscal (date)
--Año fiscal (text, ejemplo: "FY2022")
--Trimestre fiscal (text, ejemplo: Q1)
--Fecha del año anterior (date, ejemplo: 2021-01-01 para la fecha 2022-01-01)
--Nota: En general una tabla date es creada para muchos años mas (minimo 10), por el momento nos ahorramos ese paso y de la creacion de feriados.
with recursive cte_dias as (
	select cast('2022-01-01' as date) as fecha
	union 
	select fecha+1 as fecha
	from cte_dias
	where fecha+1 <= date('2023-12-31')
)
select 
	fecha
	,extract(month from fecha) as mes
	,extract(year from fecha) as "año"
	,to_char(fecha,'DAY') as dia_semana
	,(case when extract(dow from fecha) in (0,6) then true else false end) as is_weekend
	,to_char(fecha, 'MONTH') as mes_name
	,extract(year from cast(fecha - interval '1 month' as date)) as "año_fiscal"
	,concat('FY',extract(year from cast(fecha - interval '1 month' as date))) as fiscal_year
	,concat('Q',extract(quarter from cast(fecha - interval '1 month' as date))) as trimestre_fiscal
	,cast(fecha - interval '1 year' as date) as "año_anterior"
into stg.date
from cte_dias

Select * from stg.date

--Clase 9
--1. Calcular el crecimiento de ventas por tienda mes a mes, con el valor nominal y el valor % de crecimiento. Utilizar self join.with 
with consolidado as (
	select tienda, to_char(fecha,'YYYY-MM') as mes, sum(venta_usd) as vta_mes_actual
	from stg.dolarizacion
	group by tienda, to_char(fecha,'YYYY-MM')
	order by 1,2
)
select c1.*, c2.vta_mes_actual as vta_mes_anterior , (c1.vta_mes_actual - c2.vta_mes_actual)/c2.vta_mes_actual as contribucion
from consolidado as c1
inner join consolidado as c2
on c1.tienda = c2.tienda and c1.mes > c2.mes
--2. Hacer un update a la tabla de product_master agregando una columna llamada "marca", con la marca de cada producto con la primer letra en mayuscula. 
--Sabemos que las marcas que tenemos son: Levi's, Tommy Hilfiger, Samsung, Phillips, Acer, JBL y Motorola. 
--En caso de no encontrarse en la lista usar 'Unknown'.
alter table stg.product_master add column marca text;

with cte as (
	Select ('Levi''s') as marcas
union
	select	('Tommy Hilfiger')
union
	select ('Samsung')
union 
	select	('Philips')
union
	select ('Acer')
union
	select	('JBL')
union
	select
	('Motorola')
),
cte2 as (
	select pm.codigo_producto as cpr, pm.nombre
		,concat(upper(left(coalesce(ct1.marcas,'Unknown'),1)),lower(right(coalesce(ct1.marcas,'Unknown'), length(coalesce(ct1.marcas,'Unknown'))-1))) as mdef
	from stg.product_master as pm
	left join cte as ct1
		on upper(pm.nombre) like concat('%',upper(ct1.marcas),'%')
)
update stg.product_master as pm set marca = lol.mdef
from cte2 as lol
where pm.codigo_producto = lol.cpr

select * from stg.product_master
--3. Un jefe de area tiene una tabla que contiene datos sobre las principales empresas de distintas industrias en rubros que pueden ser competencia:
/*
empresa				rubro				facturacion
El Corte Ingles		Departamental		$110.99B
Mercado Libre		ECOMMERCE			$115.86B
Fallabela			departamental		$20.46M
Tienda Inglesa		Departamental		$10,78M
Zara				INDUMENTARIA		$999.98M
*/
--Armar una query que refleje lo siguiente:
--Rubro
--FacturacionTotal (total de facturación por rubro).
--Ordenadas por la columna rubro en orden ascendente.
--La columna FacturacionTotal debe estar expresada en millones/billones según corresponda y con 2 decimales después de la coma. Los elementos de la columna rubro debe estar expresados en letra minúscula.
--Output esperado:
--Se toma billones y millones en dolares, multiplicando los valores con B*1000.000.000 y M*1000.000
with cte_empresas as (
select 'El Corte Ingles' as empresa, 'Departamental' as rubro, 110990000000 as facturacion
	union
select 'Mercado Libre' , 'ECOMMERCE' , 115860000000 
	union
select 'Fallabela' , 'departamental' , 20460000 
	union
select 'Tienda Inglesa' , 'Departamental' , 10780000 
	union
select 'Zara' , 'INDUMENTARIA' , 999980000 
),
cte_agrupado as (
select lower(rubro) as rubro, sum(facturacion) as facturacion
from cte_empresas
group by lower(rubro)
order by 1
)
select rubro 
	,case 
	when length(cast(facturacion as text))>9 then concat(round((facturacion/1000000000),2),'B') 
	else concat(round((facturacion/1000000),2),'M') end as facturacion_total
from cte_agrupado
