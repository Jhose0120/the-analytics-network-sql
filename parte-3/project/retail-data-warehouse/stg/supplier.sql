DROP TABLE IF EXISTS stg.suppliers;

CREATE TABLE IF NOT EXISTS stg.suppliers
(
    codigo_producto character varying(250) ,
    nombre character varying(250) ,
    is_primary boolean
)
