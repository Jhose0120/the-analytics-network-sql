CREATE TABLE IF NOT EXISTS fact.inventory
(
    tienda smallint NOT NULL,
    sku character varying(10) NOT NULL,
    fecha date NOT NULL,
    inicial smallint,
    final smallint,
    CONSTRAINT inventory_pkey PRIMARY KEY (tienda, sku, fecha),
    CONSTRAINT fk_inv_producto FOREIGN KEY (sku)
        REFERENCES dim.product_master (codigo_producto) 
    CONSTRAINT fk_inv_tienda FOREIGN KEY (tienda)
        REFERENCES dim.store_master (codigo_tienda) 
)
