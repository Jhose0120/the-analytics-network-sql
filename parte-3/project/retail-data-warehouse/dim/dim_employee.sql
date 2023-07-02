DROP TABLE IF EXISTS dim.employee;

CREATE TABLE IF NOT EXISTS dim.employee
(
    id_employee integer PRIMARY KEY
    ,nombre character varying(100) 
    ,apellido character varying(100) 
    ,fecha_entrada date NOT NULL
    ,fecha_salida date
    ,telefono character varying(100) 
    ,pais character varying(225) 
    ,provincia character varying(225) 
    ,codigo_tienda character varying(225) 
    ,posicion character varying(225)
    ,is_active boolean
    ,creado timestamp not null DEFAULT now()
	,actualizado timestamp not null
)
