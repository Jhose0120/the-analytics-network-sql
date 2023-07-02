DROP TABLE IF EXISTS dim.store_count;

CREATE TABLE IF NOT EXISTS dim.store_count
(
    tienda smallint NOT NULL,
    fecha integer NOT NULL,
    conteo smallint,
    CONSTRAINT market_count_pkey PRIMARY KEY (tienda, fecha),
    CONSTRAINT fk_mark_tienda FOREIGN KEY (tienda)
        REFERENCES dim.store_master (codigo_tienda) 
)
