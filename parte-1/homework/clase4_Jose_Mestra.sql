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