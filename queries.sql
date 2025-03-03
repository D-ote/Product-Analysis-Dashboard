-- Feature Engineering --

with cte as (
select 
    a.Category,
    a.Brand,
    a.product,
    a.Description,
    a.`Image url` as image_url,
    a.sale_price,
    a.cost_price,
    b.Date,
    b.`Customer Type` as customer_type,
    b.Country,
    TRIM(LOWER(b.`Discount Band`)) AS discount_band,
    b.`Units Sold` as units_sold,
	(sale_price * `Units Sold`) as revenue,
	(cost_price * `Units Sold`) as total_cost,
    DATE_FORMAT(Date, '%M') AS month,  
    DATE_FORMAT(Date, '%Y') AS year 
from product_data a
join product_sales b
on a.Product_ID = b.Product)

select *,
	ROUND((1 - discount * 1.0/100) * revenue, 2) as discount_revenue
from cte a
join discount_data b
ON a.discount_band = b.discount_band
and  a.month = b.Month;


-- Total Revenue by Month & Year (Monthly Trends) --
SELECT 
	DATE_FORMAT(Date, '%M') AS month,  
    DATE_FORMAT(Date, '%Y') AS year,
	SUM(sale_price * `Units Sold`) as total_revenue
from product_data a
join product_sales b
on a.Product_ID = b.Product
GROUP BY year, month
ORDER BY year, month;

-- YoY
SELECT 
    DATE_FORMAT(Date, '%Y') AS year,
    SUM(sale_price * `Units Sold`) AS total_revenue,
    LAG(SUM(sale_price * `Units Sold`)) OVER (ORDER BY DATE_FORMAT(Date, '%Y')) AS prev_year_revenue,
    ROUND(((SUM(sale_price * `Units Sold`) - LAG(SUM(sale_price * `Units Sold`)) OVER (ORDER BY DATE_FORMAT(Date, '%Y'))) / 
          LAG(SUM(sale_price * `Units Sold`)) OVER (ORDER BY DATE_FORMAT(Date, '%Y'))) * 100, 2) AS yoy_growth_percent
from product_data a
join product_sales b
on a.Product_ID = b.Product
GROUP BY year
ORDER BY year;


-- Revenue Breakdown by Year & Customer Type --
SELECT  
    DATE_FORMAT(Date, '%Y') AS year,
    `customer type`,
	SUM(sale_price * `Units Sold`) as total_revenue
from product_data a
join product_sales b
on a.Product_ID = b.Product
GROUP BY year, `customer type`
ORDER BY year, total_revenue DESC;

-- Top Customer Segments Driving Profit--
SELECT 
    `customer type`,
    SUM((sale_price * `Units Sold`) - (cost_price * `Units Sold`)) AS total_profit
from product_data a
join product_sales b
on a.Product_ID = b.Product
GROUP BY `customer type`
ORDER BY total_profit DESC;

-- Percentage Revenue Contribution by Customer Segment --
SELECT 
    b.`Customer Type`,
    SUM(a.sale_price * b.`Units Sold`) AS total_revenue,
    (SUM(a.sale_price * b.`Units Sold`) / 
    (SELECT SUM(a.sale_price * b.`Units Sold`) 
     FROM product_data a 
     JOIN product_sales b 
     ON a.Product_ID = b.Product) * 100) AS revenue_percentage
FROM product_data a
JOIN product_sales b
ON a.Product_ID = b.Product
GROUP BY b.`Customer Type`
ORDER BY total_revenue DESC;
