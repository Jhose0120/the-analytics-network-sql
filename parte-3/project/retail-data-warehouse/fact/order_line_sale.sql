CREATE TABLE IF NOT EXISTS fact.order_line_sale
(
    orden character varying(10)  NOT NULL,
    producto character varying(10)  NOT NULL,
    tienda smallint,
    fecha date,
    cantidad integer,
    venta numeric(18,5),
    descuento numeric(18,5),
    impuestos numeric(18,5),
    creditos numeric(18,5),
    moneda character varying(3) COLLATE pg_catalog."default",
    pos smallint,
    is_walkout boolean,
    line_key character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT order_line_sale_pkey PRIMARY KEY (orden, producto),
    CONSTRAINT fk_ols_prod FOREIGN KEY (producto)
        REFERENCES dim.product_master (codigo_producto) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT fk_ols_tienda FOREIGN KEY (tienda)
        REFERENCES dim.store_master (codigo_tienda) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
