DROP TABLE IF EXISTS fact.return_movements;

CREATE TABLE IF NOT EXISTS fact.return_movements
(
    orden_venta character varying(255) NOT NULL,
    envio character varying(255) NOT NULL,
    item character varying(255) NOT NULL,
    cantidad integer,
    id_movimiento character varying(255) NOT NULL,
    desde character varying(255) COLLATE pg_catalog."default",
    hasta character varying(255) COLLATE pg_catalog."default",
    recibido_por character varying(255) COLLATE pg_catalog."default",
    fecha date,
    CONSTRAINT pk_rm PRIMARY KEY (id_movimiento),
    CONSTRAINT fk_rm_producto FOREIGN KEY (item)
        REFERENCES dim.product_master (codigo_producto) 
)
