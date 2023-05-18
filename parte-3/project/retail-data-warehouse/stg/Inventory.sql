DROP TABLE IF EXISTS stg.inventory;
    
CREATE TABLE stg.inventory
                 (
                              tienda  SMALLINT
                            , sku     VARCHAR(10)
                            , fecha   DATE
                            , inicial SMALLINT
                            , final   SMALLINT
                 );
