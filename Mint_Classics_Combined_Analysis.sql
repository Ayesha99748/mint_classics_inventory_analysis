-- Mint Classics Inventory Analysis
-- Combined from the two uploaded SQL files.
-- Run queries separately in MySQL Workbench.

-- ===== Source 1: mintclassics analysics.sql =====

USE mintclassics;
SELECT
    p.productLine,
    SUM(p.quantityInStock) AS total_inventory,
    COALESCE(SUM(s.units_sold), 0) AS total_units_sold
FROM products p
LEFT JOIN (
    SELECT
        productCode,
        SUM(quantityOrdered) AS units_sold
    FROM orderdetails
    GROUP BY productCode
) s
ON p.productCode = s.productCode
GROUP BY p.productLine
ORDER BY total_inventory DESC;


SELECT
    p.productCode,
    p.productName,
    p.productLine,
    p.warehouseCode,
    p.quantityInStock,
    COALESCE(SUM(od.quantityOrdered), 0) AS unitsSold
FROM products p
LEFT JOIN orderdetails od
    ON p.productCode = od.productCode
GROUP BY
    p.productCode,
    p.productName,
    p.productLine,
    p.warehouseCode,
    p.quantityInStock
HAVING COALESCE(SUM(od.quantityOrdered), 0) = 0
ORDER BY p.quantityInStock DESC;


SELECT
    p.productCode,
    p.productName,
    p.productLine,
    p.warehouseCode,
    p.quantityInStock,
    COALESCE(SUM(od.quantityOrdered), 0) AS unitsSold
FROM products p
LEFT JOIN orderdetails od
    ON p.productCode = od.productCode
GROUP BY
    p.productCode,
    p.productName,
    p.productLine,
    p.warehouseCode,
    p.quantityInStock
ORDER BY
    unitsSold ASC,
    p.quantityInStock DESC
LIMIT 15;


SELECT
    p.productCode,
    p.productName,
    p.productLine,
    p.warehouseCode,
    p.quantityInStock,
    COALESCE(SUM(od.quantityOrdered), 0) AS unitsSold,
    ROUND(
        p.quantityInStock /
        NULLIF(SUM(od.quantityOrdered), 0),
        2
    ) AS stock_to_sales_ratio
FROM products p
LEFT JOIN orderdetails od
    ON p.productCode = od.productCode
GROUP BY
    p.productCode,
    p.productName,
    p.productLine,
    p.warehouseCode,
    p.quantityInStock
ORDER BY stock_to_sales_ratio DESC
LIMIT 15;

SELECT *
FROM warehouses;


SELECT
    MIN(orderDate) AS first_order_date,
    MAX(orderDate) AS latest_order_date,
    COUNT(*) AS total_orders
FROM orders;


SELECT
    p.warehouseCode,
    SUM(p.quantityInStock) AS inventory_units,
    SUM(COALESCE(s.units_last_12m, 0)) AS units_sold_last_12m
FROM products p
LEFT JOIN (
    SELECT
        od.productCode,
        SUM(od.quantityOrdered) AS units_last_12m
    FROM orderdetails od
    JOIN orders o
        ON o.orderNumber = od.orderNumber
    WHERE o.orderDate >= DATE_SUB(
        (SELECT MAX(orderDate) FROM orders),
        INTERVAL 12 MONTH
    )
    GROUP BY od.productCode
) s
    ON s.productCode = p.productCode
GROUP BY p.warehouseCode
ORDER BY p.warehouseCode;


SELECT
    p.productCode,
    p.productName,
    p.productLine,
    p.warehouseCode,
    p.quantityInStock,
    COALESCE(s.units_sold_last_12m, 0) AS units_sold_last_12m
FROM products p
LEFT JOIN (
    SELECT
        od.productCode,
        SUM(od.quantityOrdered) AS units_sold_last_12m
    FROM orderdetails od
    JOIN orders o
        ON o.orderNumber = od.orderNumber
    WHERE o.orderDate >= DATE_SUB(
        (SELECT MAX(orderDate) FROM orders),
        INTERVAL 12 MONTH
    )
    GROUP BY od.productCode
) s
    ON s.productCode = p.productCode
WHERE COALESCE(s.units_sold_last_12m, 0) = 0
  AND p.quantityInStock > 0
ORDER BY p.quantityInStock DESC;


SELECT
    p.productCode,
    p.productName,
    p.productLine,
    p.warehouseCode,
    p.quantityInStock,
    COALESCE(s.units_sold_last_12m, 0) AS units_sold_last_12m
FROM products p
LEFT JOIN (
    SELECT
        od.productCode,
        SUM(od.quantityOrdered) AS units_sold_last_12m
    FROM orderdetails od
    JOIN orders o
        ON o.orderNumber = od.orderNumber
    WHERE o.orderDate >= DATE_SUB(
        (SELECT MAX(orderDate) FROM orders),
        INTERVAL 12 MONTH
    )
    GROUP BY od.productCode
) s
    ON s.productCode = p.productCode
ORDER BY units_sold_last_12m ASC, p.quantityInStock DESC
LIMIT 15;


SELECT
    p.productCode,
    p.productName,
    p.quantityInStock,
    COALESCE(SUM(od.quantityOrdered), 0) AS total_units_sold
FROM products p
LEFT JOIN orderdetails od
    ON p.productCode = od.productCode
WHERE p.productCode = 'S18_3233'
GROUP BY
    p.productCode,
    p.productName,
    p.quantityInStock;
    
SELECT
    productLine,
    COUNT(*) AS number_of_products,
    SUM(quantityInStock) AS total_inventory
FROM products
GROUP BY productLine
ORDER BY total_inventory DESC;

SELECT
    p.productLine,
    COUNT(*) AS number_of_products,
    SUM(p.quantityInStock) AS inventory_units,
    SUM(COALESCE(s.units_sold_last_12m, 0))
        AS units_sold_last_12m
FROM products p
LEFT JOIN (
    SELECT
        od.productCode,
        SUM(od.quantityOrdered) AS units_sold_last_12m
    FROM orderdetails od
    JOIN orders o
        ON o.orderNumber = od.orderNumber
    WHERE o.orderDate >= DATE_SUB(
        (SELECT MAX(orderDate) FROM orders),
        INTERVAL 12 MONTH
    )
    GROUP BY od.productCode
) s
    ON s.productCode = p.productCode
GROUP BY p.productLine
ORDER BY inventory_units DESC;

SELECT *
FROM orders
LIMIT 5;

SELECT
    COUNT(*) AS shipped_orders,
    ROUND(AVG(DATEDIFF(shippedDate, orderDate)), 2)
        AS avg_days_to_ship,
    MAX(DATEDIFF(shippedDate, orderDate))
        AS maximum_days_to_ship,
    SUM(
        CASE
            WHEN DATEDIFF(shippedDate, orderDate) <= 1
            THEN 1
            ELSE 0
        END
    ) AS shipped_within_1_day
FROM orders
WHERE status = 'Shipped'
  AND shippedDate IS NOT NULL;
  
  
  SELECT
    p.productCode,
    p.productName,
    p.productLine,
    p.warehouseCode,
    p.quantityInStock,
    COALESCE(s.units_sold_last_12m, 0)
        AS units_sold_last_12m,
    ROUND(
        p.quantityInStock /
        NULLIF(s.units_sold_last_12m, 0),
        2
    ) AS stock_to_sales_ratio
FROM products p
LEFT JOIN (
    SELECT
        od.productCode,
        SUM(od.quantityOrdered) AS units_sold_last_12m
    FROM orderdetails od
    JOIN orders o
        ON o.orderNumber = od.orderNumber
    WHERE o.orderDate >= DATE_SUB(
        (SELECT MAX(orderDate) FROM orders),
        INTERVAL 12 MONTH
    )
    GROUP BY od.productCode
) s
    ON s.productCode = p.productCode
WHERE COALESCE(s.units_sold_last_12m, 0) > 0
ORDER BY stock_to_sales_ratio DESC
LIMIT 15;


SELECT
    p.productCode,
    p.productName,
    p.warehouseCode,
    p.quantityInStock,

    SUM(
        CASE
            WHEN o.orderDate < '2004-12-01'
            THEN od.quantityOrdered
            ELSE 0
        END
    ) AS first_6_months_sales,

    SUM(
        CASE
            WHEN o.orderDate >= '2004-12-01'
            THEN od.quantityOrdered
            ELSE 0
        END
    ) AS last_6_months_sales

FROM products p

LEFT JOIN orderdetails od
    ON p.productCode = od.productCode

LEFT JOIN orders o
    ON od.orderNumber = o.orderNumber
    AND o.orderDate >= '2004-06-01'
    AND o.orderDate <= '2005-05-31'

GROUP BY
    p.productCode,
    p.productName,
    p.warehouseCode,
    p.quantityInStock

ORDER BY
    first_6_months_sales ASC,
    last_6_months_sales ASC;
    
    SELECT
    p.productCode,
    p.productName,
    p.warehouseCode,
    p.quantityInStock,

    SUM(
        CASE
            WHEN o.orderDate >= '2004-06-01'
             AND o.orderDate < '2004-12-01'
            THEN od.quantityOrdered
            ELSE 0
        END
    ) AS first_6_months_sales,

    SUM(
        CASE
            WHEN o.orderDate >= '2004-12-01'
             AND o.orderDate < '2005-06-01'
            THEN od.quantityOrdered
            ELSE 0
        END
    ) AS last_6_months_sales,

    SUM(
        CASE
            WHEN o.orderDate >= '2004-06-01'
             AND o.orderDate < '2004-12-01'
            THEN od.quantityOrdered
            ELSE 0
        END
    )
    -
    SUM(
        CASE
            WHEN o.orderDate >= '2004-12-01'
             AND o.orderDate < '2005-06-01'
            THEN od.quantityOrdered
            ELSE 0
        END
    ) AS sales_decrease

FROM products p
LEFT JOIN orderdetails od
    ON p.productCode = od.productCode
LEFT JOIN orders o
    ON od.orderNumber = o.orderNumber

GROUP BY
    p.productCode,
    p.productName,
    p.warehouseCode,
    p.quantityInStock

HAVING first_6_months_sales > last_6_months_sales

ORDER BY sales_decrease DESC
LIMIT 15;

-- ===== Source 2: Mint classcics inventory project.sql =====




SELECT * FROM warehouse;

SELECT COUNT(*) AS warehouse_count
FROM warehouses;

SELECT warehouseCode, warehouseName, warehousePctCap
FROM warehouses;

SELECT
    w.warehouseCode,
    w.warehouseName,
    w.warehousePctCap,
    SUM(p.quantityInStock) AS inventory_units
FROM warehouses w
JOIN products p
    ON w.warehouseCode = p.warehouseCode
GROUP BY
    w.warehouseCode,
    w.warehouseName,
    w.warehousePctCap
ORDER BY w.warehousePctCap ASC;



