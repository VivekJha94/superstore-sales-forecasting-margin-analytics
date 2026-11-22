SELECT COUNT(*), COUNT(DISTINCT order_id), MIN(order_date), MAX(order_date),
       ROUND(SUM(sales),2), ROUND(SUM(profit),2) FROM orders;

select * from orders

-- Query 1: monthly revenue and MoM growth
WITH m AS (
  SELECT DATE_TRUNC('month', order_date)::date AS month, SUM(sales) AS revenue
  FROM orders GROUP BY 1
)
SELECT month, ROUND(revenue,2) AS revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
             / NULLIF(LAG(revenue) OVER (ORDER BY month),0) * 100, 1) AS mom_growth_pct
FROM m ORDER BY month;

-- Query 2: AOV by month
SELECT DATE_TRUNC('month', order_date)::date AS month,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(sales),2) AS revenue,
       ROUND(SUM(sales)/COUNT(DISTINCT order_id),2) AS aov
FROM orders GROUP BY 1 ORDER BY 1;

-- Query 3: sales and margin by category and sub-category
SELECT category, sub_category, ROUND(SUM(sales),2) AS sales, ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS margin_pct
FROM orders GROUP BY category, sub_category ORDER BY margin_pct;

-- Query 4: new vs repeat customers by year
WITH first_order AS (
  SELECT customer_id, EXTRACT(YEAR FROM MIN(order_date))::int AS first_year
  FROM orders GROUP BY customer_id
)
SELECT EXTRACT(YEAR FROM o.order_date)::int AS year,
       COUNT(DISTINCT o.customer_id) AS active_customers,
       COUNT(DISTINCT o.customer_id) FILTER (WHERE f.first_year = EXTRACT(YEAR FROM o.order_date)::int) AS new_customers,
       COUNT(DISTINCT o.customer_id) FILTER (WHERE f.first_year < EXTRACT(YEAR FROM o.order_date)::int) AS repeat_customers
FROM orders o JOIN first_order f USING (customer_id)
GROUP BY 1 ORDER BY 1;

-- Query 5: profit by region
SELECT region, ROUND(SUM(sales),2) AS sales, ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS margin_pct
FROM orders GROUP BY region ORDER BY margin_pct;