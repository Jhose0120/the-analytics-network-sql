## Ejercicio Integrador Parte 3


La empresa en la cual venimos trabajando le gusto lo que hicimos hasta ahora y quiere que podamos escalar los resultados para que se implemente una herramienta de BI - Business Intelligent y pueda recibir los datos que la empresa genera día a día. Para eso le comentamos que nuestra solución es generar un Data Warehouse junto con un proceso de ETL para tener una infraestructura que permite ampliar mas casos de uso y ademas ingerir datos de forma sistemica.
Luego en el ultimo paso así poder implementar una herramienta de BI. 

Debajo vamos a encontrar los pasos que le comunicamos a la empresa y que vamos a tener que realizar para poder hacer realidad el pedido. 

<br>

### Parte 1 - Organización de nuestro repo

El repositorio de git, que actualmente tenemos en Github, es el núcleo de nuestro código. Git nos permite trabajar colaborativamente y de tener versionados nuestros archivos, es decir tener guardado versiones anteriores, los cambios y la capacidad de recuperarlos. 

Todas las empresas, de una u otra manera, usan git. Por eso nosotros también vamos a armar nuestro repositorio. 

#### Estructura de carpetas 
Para organizar la estructura del Data Warehouse (DW) en el repositorio, vamos a crear una carpeta llamada **retail-data-warehouse** dentro de la carpeta actual **project**.  A su vez la carpeta va a tener la siguiente estructura de carpetas: 

- retail-data-warehouse 
    - stg
    - etl
    - fct
    - dim
    - analytics
    - viz
    - bkp
    - log

Dentro de cada carpeta vamos a poner un script por cada "modelo" y cada carpeta representa un esquema del DW. Este paso lo podes hacer una vez que tenes al menos un archivo por carpeta o podes realizarlo al principio y colocando un archivo vacío llamado "placeholder.md" que luego podes borrar. 

1. Crear las carpetas mencionadas previamente.
2. Vamos a reciclar el script de ddl.sql que utilizamos al principio y sumarle los scripts de "returns", "supplier", "employee" y calendario para armar la estructura de nuestra carpeta stg. Crear POR CADA TABLA en stg un archivo en la carpeta stg con el ddl de cada tabla cuyo nombre sera el nombre de la tabla. Ejemplo: "cost.sql". No es necesario correrlos nuevamente, así reutilizamos lo que ya tenemos. 
3. Limpiar cualquier otra tabla (si existiese) que nos haya quedado de las partes anteriores que no corresponda al Data Warehouse. 
    1. Las tablas que deberíamos tener en staging son las siguientes: 
        1. Cost
        2. Inventory 
        3. Market_count 
        4. Monthly_average_fx_rate
        5. Order_line_sale
        6. Product_master
        7. Return_movements
        8. Store_master
        9. Super_store_count
        10. Supplier
        11. Employee
4. Crear una base de datos que se llame "dev". Correr todos los scripts de ddl.sql para tener la estructura en un ambiente que vamos a usar para el desarrollo y testeo de nuevas queries. No es es necesario llenarlo de datos ni de crear nuevos scripts para la base de desarrollo. Los scripts son unicos y deben permanecer en el repositorio. 

Nota: Git se utiliza en todos los trabajos de desarrollo de software y data, es importante que conozcas todas las funcionalidades, como manejarlo por consola y con algún proveedor como puede ser Github o Gitlab.

<br>

### Parte 2 - Creación de un ambiente de desarrollo 

Todos los proyectos de una u otra manera tienen un lugar de desarrollo, es decir un ambiente separado donde se puedan hacer cambios sin influir a los datos que ve el usuario final. Hay muchas formas de aplicar esto dependiendo en dónde estemos trabajando.
Nosotros vamos a montar el ambiente de desarrollo en una nueva base de datos. 

1. Crear una base de datos que se llame "dev". Correr todos los scripts de ddl para tener la estructura en un ambiente que vamos a usar para el desarrollo y testeo de nuevas queries. 

No es es necesario subir ningún dato, vamos a mantener la estructura vacía y manejarnos en la base de datos inicial. Este ejercicio es solamente para mostrar la existencia de un ambiente de desarrollo, que es obligatoria en todo proyecto grande. 

<br>

### Parte 3 - Creación de un modelo dimensional

1. Crear un script de ddl para cada tabla dentro de fct y dim, con sus respectivas PK and FK en la creacion de tabla. 
      - Decidir en cada caso si es necesario crear una clave surrogada o no. 
2. Editar el script de la tabla "employee" para que soporte un esquema de SDC (Slow changing dimension) cuyo objetivo debe ser capturar cuales son los empleados activos y el periodo de duracion de cada empleado. 
3. Generar un ERD para el modelo dimensional creado con las tablas de hechos y de dimensiones, descargarlo en PDF y sumarlo al repositorio del proyecto.

<br>

### Parte 4 - Creación de los proceso de transformación

Para nuestro poryecto vamos a realizar las transformaciones de datos dentro de stored procedures del esquema etl. Esta parte es la encargada de limpiar las datos crudos y realizar las transformaciones de negocio hasta la capa de analytics.

stg -> Modelo dimensional (fct/dim)
1. Por default todas las tablas van a seguir el paradigma de truncate and insert, a menos que se indique lo contrario. 
2. El objetivo de este paso es que las tablas fact/dim queden "limpias" y validadas y listas para ser usadas para analisis. Por lo tanto, van a requerir que hagas los cambios necesarios que ya vimos en la parte 1 y 2 para que queden lo mas completa posibles. Te menciono algunos como ejemplo pero la lista puede no esta completa:
```
DROP FUNCTION IF EXISTS stg.applyetl();
CREATE OR REPLACE FUNCTION stg.applyetl()
RETURNS void
AS $$
BEGIN
    --Limpiamos las tablas ya cuenta con las validaciones fk y pk de la parte 2
	TRUNCATE TABLE dim.employee CASCADE;
    TRUNCATE TABLE dim.store_master CASCADE;
    TRUNCATE TABLE dim.product_master CASCADE;
	TRUNCATE TABLE dim.cost;
    TRUNCATE TABLE dim.count_considado;
	TRUNCATE TABLE fact.inventory CASCADE;
    TRUNCATE TABLE dim.monthly_average_fx_rate;
    TRUNCATE TABLE fact.return_movements;
    TRUNCATE TABLE dim.suppliers;
    TRUNCATE TABLE fact.order_line_sale;
    
    --Ingresamos los datos depurados teniendo en cuenta las pk y las llaves foraneas
    INSERT INTO dim.employee SELECT * FROM stg.employee WHERE id_employee IS NOT NULL 
	ON CONFLICT DO NOTHING;
    INSERT INTO dim.store_master SELECT * FROM stg.store_master WHERE codigo_tienda IS NOT NULL 
	ON CONFLICT DO NOTHING;
    INSERT INTO dim.product_master SELECT * FROM stg.product_master WHERE codigo_producto IS NOT NULL 
	ON CONFLICT DO NOTHING;
    INSERT INTO dim.cost SELECT * FROM stg.cost WHERE codigo_producto IS NOT NULL 
	ON CONFLICT DO NOTHING;
    INSERT INTO fact.inventory SELECT * FROM stg.inventory WHERE tienda IS NOT NULL AND sku IS NOT NULL 
	ON CONFLICT DO NOTHING;
    --Como desconocemos si las tablas individuales se pueden borrar de conteo creamos el consolidado y se generan triggers que la alimentan cuando agreguen en una u otra  
    INSERT INTO stg.count_considado SELECT * FROM 
        (SELECT tienda, CAST(fecha as date) as fecha, conteo
            FROM stg.super_store_count
        WHERE tienda IS NOT NULL
        UNION 
        SELECT tienda, cast(cast(fecha as text) as date), conteo
            FROM stg.market_count
        WHERE tienda IS NOT NULL) AS lista;
    INSERT INTO dim.monthly_average_fx_rate SELECT * FROM stg.monthly_average_fx_rate WHERE mes IS NOT NULL 
	ON CONFLICT DO NOTHING;
    INSERT INTO fact.return_movements SELECT * FROM stg.return_movements WHERE orden_venta IS NOT NULL AND item IS NOT NULL 
	ON CONFLICT DO NOTHING;
    INSERT INTO dim.suppliers SELECT * FROM stg.suppliers WHERE codigo_producto IS NOT NULL 
	ON CONFLICT DO NOTHING;
    INSERT INTO fact.order_line_sale SELECT * FROM stg.order_line_sale WHERE orden IS NOT NULL ON CONFLICT DO NOTHING;    
END
$$
LANGUAGE PLPGSQL;
```
    - Agregar columnas: ejemplo marca/"brand" en la tabla de producto.
```
-- Se agregan las columnas tanto para stg como para dim y cuando se actualice en stg y se ejecute la funtion se actualizara correctamente depurando.
ALTER TABLE stg.product_master ADD COLUMN marca character varying(255);
ALTER TABLE dim.product_master ADD COLUMN marca character varying(255);
```
    - Las tablas store_count de ambos sistemas deben centrarlizarse en una tabla. 
```
-- Se consolido en la function en:
INSERT INTO stg.count_considado SELECT * FROM 
        (SELECT tienda, CAST(fecha as date) as fecha, conteo
            FROM stg.super_store_count
        WHERE tienda IS NOT NULL
        UNION 
        SELECT tienda, cast(cast(fecha as text) as date), conteo
            FROM stg.market_count
        WHERE tienda IS NOT NULL) AS lista;
```
    - Limpiar la tabla de supplier dejando uno por producto. 
```
-- Se ejcuta query:
DELETE FROM stg.suppliers WHERE is_primary = false;
```    
    - Nombre de columnas:  cambiar si considerar que no esta claro. Las PK suelen llamarse "id" y las FK "tabla_id" ejemplo: "customer_id"
```
Se aplica en parte 3
```  
    - Tipo de dato: Cambiar el tipo de dato en caso que no sea correcto. 
```
-- Se le cambio el tipo de dato al conteo de las tiendas en el consolidado.
```  
4. Las tablas de "employee" y "cost" van a usar un modelo de actulizacion tipo "upsert". 
    - En caso de no se cumpla la condicion de FK no incluir esos SKUs. Como encadenarias el proceso?
```
-- Lo encadenaria usando la sentencia ON CONFLICT UPDATE SET ..
INSERT INTO table (field 1, field 2)
VALUES(value1, value 2, ..) 
ON CONFLICT (id) 
DO 
   UPDATE SET field 2 = EXCLUDED.field 2|| ';' || table.fiel 2;
```  
5. La tabla de ventas (order_line_sale) y la tabla de inventario va a seguir un modelo incremental basado en la fecha. 
<br>

### Parte 5 - Creación de la “Analytics layer”

La capa de analytics es aquella que se va a conectar con nuestras herramientas de BI. 
1. Crear tres tablas de analytics: 
    - order_sale_line 
        - Nota: Va a ser la misma tabla que hicimos para el TP Integrador de la Parte 2
```
-- Se utiliza vista creada en TP Integrador
CREATE SCHEMA IF NOT EXISTS analytics;
select * into analytics.order_line_sale from ( 
with rango as (
	select min(fecha) as mi, max(fecha) as ma from fact.inventory
	union 
	select min(fecha), max(fecha) from fact.order_line_sale
	union
	select min(fecha),max(fecha) from dim.count_considado
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
from dim.date as d
full outer join dim.count_considado as tc
	on d.fecha = tc.fecha
full outer join fact.inventory as inv
	on d.fecha = inv.fecha and tc.tienda=inv.tienda 
full outer join analytics.dolarizacion as ols
	on d.fecha = ols.fecha and ols.tienda=coalesce(tc.tienda, inv.tienda, ols.tienda) and  ols.producto = coalesce(inv.sku, ols.producto)
left join dim.store_master as sm
	on sm.codigo_tienda = coalesce(inv.tienda, ols.tienda, tc.tienda)
left join dim.product_master as pm 
 	on pm.codigo_producto = coalesce(inv.sku, ols.producto)
left join dim.suppliers as s
 	on s.codigo_producto = coalesce(inv.sku, ols.producto) and s.is_primary = true
left join analytics.returns as rm
	on rm.item = coalesce(inv.sku, ols.producto) and rm.orden_venta = ols.orden
left join dim.cost as co
	on co.codigo_producto = coalesce(inv.sku, ols.producto)
where d.fecha between (select min(mi) from rango) and (select max(ma) from rango)
	) as sales
```
    - return
        - El objetivo es ver las ordenes de devoluciones con las dimensiones/atributos del producto retornado y ademas la tienda y sus atributas en la cual fue originalmente comprado el producto (de la orden de venta) junto con el valor de venta del producto retornado (es nuestra manera de cuantificar el valor de la devolucion)
        - Nota: Obviamente valores de devolucion deben estar en moneda original y moneda comun. 
        - Nota2: La tabla de retornors indica movimientos del item una vez que viene del cliente a nuestra tienda, cuidado con repetir valores, nosotros queremos entender unciamente las ordenes-productos retornados no los movimientos que tuvo cada retorno.
```
select * into analytics.returns from (
select distinct rm.orden_venta, rm.item, rm.cantidad
	,(dol.venta_usd/dol.cantidad)*rm.cantidad valor_usd_retornado ,pm.nombre
	,first_value(desde) over(partition by rm.orden_venta, rm.item)
	,last_value(hasta) over(partition by rm.orden_venta, rm.item)
from stg.return_movements as rm
left join analytics.dolarizacion as dol
on rm.orden_venta = dol.orden and rm.item = dol.producto
left join dim.product_master as pm
	on rm.item = pm.codigo_producto) as movements
 ```
    - inventory
       - El objetivo es ver el historico del inventario promedio por dia, con todas las dimensiones/atributos de producto (categoria, descripcion, etc.), dimensiones de la tienda (pais, nombre, etc) y el costo de los productos.
       
 ```
select * into analytics.inventory from (
    SELECT 
	inv.fecha
	,sm.nombre as nombre_tienda ,sm.pais ,sm.provincia  
	,pm.nombre as nombre_producto ,pm.categoria ,pm.subcategoria ,pm.subsubcategoria
	,co.costo_promedio_usd as costo_unitario 
	,co.costo_promedio_usd * inv.inicial as costo_prom_inv
    FROM fact.inventory AS inv
    left join dim.store_master as sm
	on sm.codigo_tienda = inv.tienda
    left join dim.product_master as pm 
 	on pm.codigo_producto = inv.sku
    left join dim.cost as co
	on co.codigo_producto = inv.sku;
) as analytics
 ```

2. Crear los stored procedures para generar las tablas de analytics a partir del modelo dimensional. Los SP van a recrear la tabla cada cada vez que se corra y va a contener toda la logica de cada tabla. 
    - El proceso de creacion de las tablas de analytics va a ser del tipo "truncate and create" ya que estas tablas son las que mayores modificaciones van a tener al codigo dado que las logicas del negocio van mutando constantement o requieren nuevos features.
      
 ```
Como ya creamos anteriormente las tablas de analycts en el punto uno solo restaria mandar el codico para que realice el truncate
CREATE OR REPLACE FUNCTION analytics.actualizar_inventory()
RETURNS void
AS $$
BEGIN
    truncate table analytics.inventory;
    insert into analytics.inventory select * from 
    (
    SELECT 
	inv.fecha
	,sm.nombre as nombre_tienda ,sm.pais ,sm.provincia  
	,pm.nombre as nombre_producto ,pm.categoria ,pm.subcategoria ,pm.subsubcategoria
	,co.costo_promedio_usd as costo_unitario 
	,co.costo_promedio_usd * inv.inicial as costo_prom_inv
    FROM fact.inventory AS inv
    left join dim.store_master as sm
	on sm.codigo_tienda = inv.tienda
    left join dim.product_master as pm 
 	on pm.codigo_producto = inv.sku
    left join dim.cost as co
	on co.codigo_producto = inv.sku;
    ) as da    
END
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION analytics.actualizar_returns()
RETURNS void
AS $$
BEGIN
    truncate table analytics.returns;
    insert into analytics.returns select * from 
    (
select distinct rm.orden_venta, rm.item, rm.cantidad
	,(dol.venta_usd/dol.cantidad)*rm.cantidad valor_usd_retornado ,pm.nombre
	,first_value(desde) over(partition by rm.orden_venta, rm.item)
	,last_value(hasta) over(partition by rm.orden_venta, rm.item)
from stg.return_movements as rm
left join analytics.dolarizacion as dol
on rm.orden_venta = dol.orden and rm.item = dol.producto
left join dim.product_master as pm
	on rm.item = pm.codigo_producto) as movements  
END
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION analytics.actualizar_returns()
RETURNS void
AS $$
BEGIN
    truncate table analytics.order_line_sale;
    insert into analytics.order_line_sale select * from 
    (with rango as (
	select min(fecha) as mi, max(fecha) as ma from fact.inventory
	union 
	select min(fecha), max(fecha) from fact.order_line_sale
	union
	select min(fecha),max(fecha) from dim.count_considado
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
from dim.date as d
full outer join dim.count_considado as tc
	on d.fecha = tc.fecha
full outer join fact.inventory as inv
	on d.fecha = inv.fecha and tc.tienda=inv.tienda 
full outer join analytics.dolarizacion as ols
	on d.fecha = ols.fecha and ols.tienda=coalesce(tc.tienda, inv.tienda, ols.tienda) and  ols.producto = coalesce(inv.sku, ols.producto)
left join dim.store_master as sm
	on sm.codigo_tienda = coalesce(inv.tienda, ols.tienda, tc.tienda)
left join dim.product_master as pm 
 	on pm.codigo_producto = coalesce(inv.sku, ols.producto)
left join dim.suppliers as s
 	on s.codigo_producto = coalesce(inv.sku, ols.producto) and s.is_primary = true
left join analytics.returns as rm
	on rm.item = coalesce(inv.sku, ols.producto) and rm.orden_venta = ols.orden
left join dim.cost as co
	on co.codigo_producto = coalesce(inv.sku, ols.producto)
where d.fecha between (select min(mi) from rango) and (select max(ma) from rango)
	) as sales;
END
$$
LANGUAGE PLPGSQL;
 ```
<br>

### Parte 6 - Logging

Logging es la practica que nos permite guardar registro de los cambios que se van produciendo en el DW y es una forma de auditar en caso de haya errores en los datos. 
1. Crear una tabla de logging que indique cada vez que se realicen modificaciones a una tabla con la siguiente información: 
    - Tabla modificada (fct, dim o analytics)
    - Fecha de modificación.
    - Stored procedure responsable de la modificación. 
    - Lineas insertadas/modificadas.
    - Usuario que corrio el stored procedures
2. Crear un stored procedure que llene la tabla de log. 
3. Poner el "call" del SP de logging en cada stored procedure creado en la parte de transformacion de las tablas stg a dim y fact y de las tablas de analytics.

<br>

### Parte 7 - Funciones

1. Encapsular la lógica de conversion de moneda en una función y reutilizarla en los scripts donde sea necesario. 
2. (Opcional) Que otra logica podemos encapsular en una funcion? La idea es encontrar transformaciones que se repitan en varios lados. Si encontraste y crees que tiene sentido crear una funcion, hacelo!

<br>

### Parte 8 - Optimizacion de queries

1. Que acciones podrias tomar para mejorar la performance de las queries que tenemos segun lo que vimos en clase? 
Algunas cosas a tener en cuenta son: 
- Tipos de joins
- Columnas seleccionada
- Columnas usadas en la clausula on del join. 
- Posibilidad de crear indices. 
- Posibilidad de crear covering index.
- Mira el plan de ejecucion de las queries complejas e identifica si algun paso se puede evitar. 
- Mira ordenamientos innecesarios.

<br>

### Parte 9 - Testing

Cada proyecto tiene que tener como minimo testeos de nivel de agregacion del nivel de detalle. En este caso estamos cubiertos por que las PK y las FK son retricciones de unicidad y nulidad. En este punto no hay que hacer nada a menos que consideres agregar algun testeo extra de las PK y FK! 

<br>

### Parte 10 - Otros

1. Crear una Guia de estilo que va a a marcar los estándares de sintaxis para cualquier desarrollo del DW. (podes usar la misma que mostramos en clase o editarla!) 

<br>

### Parte 11 - Opcional

1. Opcional - Conectar la tabla de order_sale_line a PowerBI y realizar una visualización que resuma el estado de ventas y ganancias de la empresa.

