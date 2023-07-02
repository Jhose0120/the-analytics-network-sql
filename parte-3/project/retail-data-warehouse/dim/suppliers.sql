DROP TABLE IF EXISTS dim.suppliers;

CREATE TABLE IF NOT EXISTS dim.suppliers
(
    codigo_producto character varying(250),
    nombre character varying(250),
    is_primary boolean,
    CONSTRAINT suppliers_pkey PRIMARY KEY (codigo_producto, nombre),
    CONSTRAINT fk_suppliers_producto FOREIGN KEY (codigo_producto)
        REFERENCES dim.product_master (codigo_producto)
);
