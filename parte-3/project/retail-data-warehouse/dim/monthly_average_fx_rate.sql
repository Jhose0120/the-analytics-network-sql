DROP TABLE IF EXISTS dim.monthly_average_fx_rate;

CREATE TABLE IF NOT EXISTS dim.monthly_average_fx_rate
(
    mes date NOT NULL,
    cotizacion_usd_peso numeric,
    cotizacion_usd_eur numeric,
    cotizacion_usd_uru numeric,
    CONSTRAINT mes PRIMARY KEY (mes),
    CONSTRAINT fk_mar_date FOREIGN KEY (mes)
        REFERENCES dim.date (fecha)
);
