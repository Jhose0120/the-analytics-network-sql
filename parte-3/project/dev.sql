--CREATE DATABASE dev;

-- Crear schema stg
CREATE SCHEMA IF NOT EXISTS stg;

/* Crear tabla products
Maestro de productos que posee la empresa. 
is_active indica que productos estan actualmente a la venta
*/

DROP TABLE IF EXISTS stg.product_master ;
    
CREATE TABLE stg.product_master
                 (
                              codigo_producto VARCHAR(255)
                            , nombre          VARCHAR(255)
                            , categoria       VARCHAR(255)
                            , subcategoria    VARCHAR(255)
                            , subsubcategoria VARCHAR(255)
                            , material        VARCHAR(255)
                            , color           VARCHAR(255)
                            , origen          VARCHAR(255)
                            , ean             bigint
                            , is_active       boolean
                            , has_bluetooth   boolean
                            , talle           VARCHAR(255)
                 );
    
/* Crea tabla cost
Costo promedio actual por producto
*/
DROP TABLE IF EXISTS stg.cost;
    
CREATE TABLE stg.cost
                 (
                              codigo_producto    VARCHAR(10)
                            , costo_promedio_usd DECIMAL
                 );
    
DROP TABLE IF EXISTS stg.inventory;
    
/* Crea tabla inventory
Conteo de inventario al inicio y final del dia por fecha, tienda y codigo
*/
CREATE TABLE stg.inventory
                 (
                              tienda  SMALLINT
                            , sku     VARCHAR(10)
                            , fecha   DATE
                            , inicial SMALLINT
                            , final   SMALLINT
                 );
    
/* Crea tabla market_count
Proveedor 1 de ingresos a tienda por fecha
*/
DROP TABLE IF EXISTS stg.market_count;
    
CREATE TABLE stg.market_count
                 (
                              tienda SMALLINT
                            , fecha  INTEGER
                            , conteo SMALLINT
                 );
    
/* Crea tabla monthly_average_fx_rate
Promedio de cotizacion mensual de USD a ARS, EUR a ARS y USD a URU
*/
DROP TABLE IF EXISTS stg.monthly_average_fx_rate;
    
CREATE TABLE stg.monthly_average_fx_rate
                 (
                              mes                 DATE
                            , cotizacion_usd_peso DECIMAL
                            , cotizacion_usd_eur DECIMAL
                            , cotizacion_usd_uru  DECIMAL
                 );
    

/* Crea tabla store_master
Tabla maestra de tiendas 
*/
DROP TABLE IF EXISTS stg.store_master;
      
CREATE TABLE stg.store_master
                 (
                              codigo_tienda  SMALLINT
                            , pais           VARCHAR(100)
                            , provincia      VARCHAR(100)
                            , ciudad         VARCHAR(100)
                            , direccion      VARCHAR(255)
                            , nombre         VARCHAR(255)
                            , tipo           VARCHAR(100)
                            , fecha_apertura DATE
                            , latitud        DECIMAL(10, 8)
                            , longitud       DECIMAL(11, 8)
                 );
    
/* Crea tabla super_store_count
Proveedor 2 de ingresos a tienda por fecha
*/
DROP TABLE IF EXISTS stg.super_store_count;
    
CREATE TABLE stg.super_store_count
                 (
                              tienda SMALLINT
                            , fecha  VARCHAR(10)
                            , conteo SMALLINT
                 );
    
/* Crea tabla order_sales_units
Ventas a nivel numero de orden, item.
*/
DROP TABLE IF EXISTS stg.order_line_sale;
    
CREATE TABLE stg.order_line_sale
                 (
                              orden      VARCHAR(10)
                            , producto   VARCHAR(10)
                            , tienda     SMALLINT
                            , fecha      date
                            , cantidad   int
                            , venta      decimal(18,5)
                            , descuento  decimal(18,5)
                            , impuestos  decimal(18,5)
                            , creditos   decimal(18,5)
                            , moneda     varchar(3)
                            , pos        SMALLINT
                            , is_walkout BOOLEAN
                 );

DROP TABLE IF EXISTS stg.employee;

CREATE TABLE IF NOT EXISTS stg.employee
(
    id_employee integer NOT NULL,
    nombre character varying(100) ,
    apellido character varying(100) ,
    fecha_entrada date,
    fecha_salida date,
    telefono character varying(100) ,
    pais character varying(225) ,
    provincia character varying(225) ,
    codigo_tienda character varying(225) ,
    posicion character varying(225) 
)

DROP TABLE IF EXISTS stg.suppliers;

CREATE TABLE IF NOT EXISTS stg.suppliers
(
    codigo_producto character varying(250) ,
    nombre character varying(250) ,
    is_primary boolean
)

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
