DROP TABLE IF EXISTS stg.return_movements;

CREATE TABLE IF NOT EXISTS stg.return_movements
  (
    orden_venta character varying(255) ,
    envio character varying(255) ,
    item character varying(255) ,
    cantidad integer,
    id_movimiento character varying(255) ,
    desde character varying(255) ,
    hasta character varying(255) ,
    recibido_por character varying(255) ,
    fecha date
)
