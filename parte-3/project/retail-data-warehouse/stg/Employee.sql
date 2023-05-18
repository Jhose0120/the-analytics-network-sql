DROP TABLE IF EXISTS stg.employee;

CREATE TABLE IF NOT EXISTS stg.employee
(
    id_employee integer NOT NULL,
    nombre character varying(100) ,
    apellido character varying(100) ,
    fecha_entrada date,
    fecha_salida date,
    telefono character varying(100) ,
    pais character varying(225) ,
    provincia character varying(225) ,
    codigo_tienda character varying(225) ,
    posicion character varying(225) 
)
