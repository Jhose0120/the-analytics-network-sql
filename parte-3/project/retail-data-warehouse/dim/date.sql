DROP TABLE IF EXISTS dim.date;

CREATE TABLE IF NOT EXISTS dim.date
(
    fecha date NOT NULL,
    mes numeric,
    "año" numeric,
    dia_semana text,
    is_weekend boolean,
    mes_name text,
    "año_fiscal" numeric,
    fiscal_year text,
    trimestre_fiscal text,
    "año_anterior" date,
    CONSTRAINT fecha PRIMARY KEY (fecha)
)
