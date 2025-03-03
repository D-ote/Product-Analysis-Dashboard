ALTER TABLE clean_product_data
RENAME to product_data;

select * from product_sales;
select * from product_data;
select * from discount_data;

ALTER TABLE product_data
RENAME COLUMN `Product ID` TO Product_ID;

SELECT LOWER(COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'product_data';


UPDATE product_sales
SET Date = CASE
	WHEN Date LIKE '%/%' THEN date_format(str_to_date(Date, '%d/%m/%Y'), '%Y/%m/%d')
    ELSE NULL
END;

ALTER TABLE product_data 
ADD COLUMN date_converted DATE;

UPDATE product_data
SET date_converted = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE product_data 
CHANGE COLUMN sale_price_decimal sale_price DECIMAL(10,2),
CHANGE COLUMN cost_price_decimal cost_price DECIMAL(10,2);

ALTER TABLE discount_data
RENAME COLUMN `Discount Band` TO discount_band;

ALTER TABLE product_data 
ADD COLUMN sale_price_decimal DECIMAL(10,2),
ADD COLUMN cost_price_decimal DECIMAL(10,2);

UPDATE product_data 
SET sale_price_decimal = CAST(REPLACE(`Sale Price`, '$', '') AS DECIMAL(10,2)),
    cost_price_decimal = CAST(REPLACE(`Cost Price`, '$', '') AS DECIMAL(10,2));

ALTER TABLE product_data 
DROP COLUMN `Sale Price`, 
DROP COLUMN `Cost Price`;

