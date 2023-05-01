/*
Homework
Bienvenidos a la seccion de ejercicios de entrevistas! Te recomiendo realizar estas preguntas luego de la Clase 8 y antes del TP integrador para poder seguir el ritmo a las clases.

Cada pregunta sera respondida con una query que devuelva los datos necesarios para reponder la misma. Muchas de las preguntas pueden tener mas de una manera de ser respondidas y es posible que debas aplicar tu criterio para decidir cual es la mejor opcion.

Si ya forkeaste el repositorio, lo que podes hacer es copiar este archivo clickeando en "Raw" y luego Ctrl + A. Luego podes crear un archivo llamado "homework.md en tu repositorio con el texto copiado.

Ejercicio 1
Ejecutar el siguiente script para crear la tabla turistas dentro del esquema test.
Cuales son las ciudades donde la afluencia de turistas es continuamente creciente.
*/
create schema test;
drop table if exists test.turistas;
create table test.turistas(city varchar(50),days date,personas int);
insert into test.turistas values('CABA','2022-01-01',100);
insert into test.turistas values('CABA','2022-01-02',200);
insert into test.turistas values('CABA','2022-01-03',300);
insert into test.turistas values('Cordoba','2022-01-01',100);
insert into test.turistas values('Cordoba','2022-01-02',100);
insert into test.turistas values('Cordoba','2022-01-03',300);
insert into test.turistas values('Madrid','2022-01-01',100);
insert into test.turistas values('Madrid','2022-01-02',200);
insert into test.turistas values('Madrid','2022-01-03',150);
insert into test.turistas values('Punta del Este','2022-01-01',100);
insert into test.turistas values('Punta del Este','2022-01-02',300);
insert into test.turistas values('Punta del Este','2022-01-03',200);
insert into test.turistas values('Punta del Este','2022-01-04',400);

with crecimiento as (
select *
	,coalesce(lag(personas) over(partition by city),0) as dato_anterior
	,(personas - coalesce(lag(personas) over(partition by city),0)) as crecimiento
from test.turistas 
order by 1,2
),
creto_continuo as (
	select *, case when (min(crecimiento) over(partition by city))>1 then 's' end as crec_continuo 
	from crecimiento where dato_anterior <> 0
)
select * from creto_continuo where crec_continuo='s'
/*
Ejercicio 2
Ejecutar el siguiente script para crear la tabla empleados dentro del esquema test.
Encontrar a los empleados cuyo salario es mayor que el de su manager.
*/
drop table if exists test.empleados;
create table test.empleados (emp_id int, empleado varchar(50), salario bigint, manager_id int);
insert into test.empleados values (1,'Clara',10000,4);
insert into test.empleados values (2,'Pedro',15000,5);
insert into test.empleados values (3,'Daniel',10000,4);
insert into test.empleados values (4,'Hernan',5000,2);
insert into test.empleados values (5,'Debora',12000,6);
insert into test.empleados values (6,'Ricardo',12000,2);
insert into test.empleados values (7,'Luciano',9000,2);
insert into test.empleados values (8,'Romina',5000,2);

select e1.*, e2.salario as salario_manager
from test.empleados as e1
left join test.empleados as e2
on e1.manager_id =e2.emp_id 
where e1.salario > e2.salario
/*
Ejercicio 3
Ejecutar el siguiente script para crear la tabla players y matches dentro del esquema test.
Encontrar el player_id ganador de cada grupo. El ganador es aquel que anota mas puntos (score) en caso de empate, el que tenga menor player_id gana.
*/
drop table if exists test.players;
create table test.players (player_id int, group1 varchar(1));
insert into test.players values (15,'A');
insert into test.players values (25,'A');
insert into test.players values (30,'A');
insert into test.players values (45,'A');
insert into test.players values (10,'B');
insert into test.players values (35,'B');
insert into test.players values (50,'B');
insert into test.players values (20,'C');
insert into test.players values (40,'C');

create table test.matches (match_id int, first_player int, second_player int, first_score int, second_score int);
insert into test.matches values (1,15,45,3,0);
insert into test.matches values (2,30,25,1,2);
insert into test.matches values (3,30,15,2,0);
insert into test.matches values (4,40,20,5,2);
insert into test.matches values (5,35,50,1,1);

with cte_resumen as (
	select ju.*, rs.match_id,
		case 
			when rs.first_score > rs.second_score then rs.first_player
			when rs.first_score < rs.second_score then rs.second_player
			when rs.first_score = rs.second_score then 0 end as ganador
	from test.players as ju
	left join test.matches as rs
	on player_id = first_player or player_id = second_player
	order by player_id
),
puntos_player as (
	select res.player_id, res.group1, sum(case 
	when player_id = ganador then 3 
	when player_id != ganador then 0 else 1 end) as score
	from cte_resumen as res
	where ganador is not null
	group by res.player_id, res.group1
	order by 2,3 desc
),
top_score as (
select *, max(score) over(partition by group1) as xc from puntos_player order by 1
)
select distinct group1 	,first_value(player_id) over(partition by group1) 	,first_value(score) over(partition by group1)
from top_score where score = xc 
