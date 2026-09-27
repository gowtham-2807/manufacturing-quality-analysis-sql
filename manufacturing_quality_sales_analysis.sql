/*
Project: Manufacturing Quality and Sales Analytics
Author: Gowtham V
Purpose: Portfolio demonstration using synthetic data
Database: PostgreSQL
*/

DROP TABLE IF EXISTS manufacturing_sales;

CREATE TABLE manufacturing_sales (
    record_id INT PRIMARY KEY,
    report_date DATE NOT NULL,
    plant VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    product VARCHAR(100) NOT NULL,
    supplier VARCHAR(100) NOT NULL,
    production_qty INT NOT NULL,
    rejected_qty INT NOT NULL,
    rma_qty INT NOT NULL,
    revenue DECIMAL(14,2) NOT NULL,
    supplier_score DECIMAL(5,2),
    target_rejection_rate DECIMAL(6,4)
);

INSERT INTO manufacturing_sales VALUES
(1,'2026-01-05','Plant A','SMT','Controller A','Supplier X',1200,18,4,145000,92,0.015),
(2,'2026-01-12','Plant B','Assembly','Controller B','Supplier Y',980,21,6,118000,86,0.015),
(3,'2026-01-20','Plant C','Testing','Power Unit A','Supplier Z',1100,12,3,162000,95,0.015),
(4,'2026-02-04','Plant A','SMT','Controller A','Supplier X',1280,16,4,153000,93,0.015),
(5,'2026-02-11','Plant B','Assembly','Controller B','Supplier Y',1020,25,7,124000,84,0.015),
(6,'2026-02-19','Plant C','Testing','Power Unit A','Supplier Z',1160,10,2,171000,96,0.015),
(7,'2026-03-03','Plant A','Wave Soldering','Controller C','Supplier W',1350,27,8,166000,82,0.015),
(8,'2026-03-10','Plant B','Coating','Controller B','Supplier Y',1080,19,5,131000,85,0.015),
(9,'2026-03-18','Plant C','Testing','Power Unit B','Supplier Z',1210,11,3,179000,96,0.015),
(10,'2026-04-02','Plant A','SMT','Controller A','Supplier X',1400,17,4,174000,94,0.015),
(11,'2026-04-09','Plant B','Assembly','Controller C','Supplier W',1120,29,9,138000,80,0.015),
(12,'2026-04-17','Plant C','Testing','Power Unit A','Supplier Z',1260,13,3,186000,95,0.015),
(13,'2026-05-06','Plant A','Wave Soldering','Controller C','Supplier W',1460,31,10,181000,79,0.015),
(14,'2026-05-13','Plant B','Coating','Controller B','Supplier Y',1180,18,5,144000,87,0.015),
(15,'2026-05-21','Plant C','Testing','Power Unit B','Supplier Z',1320,12,2,194000,97,0.015),
(16,'2026-06-04','Plant A','SMT','Controller A','Supplier X',1500,15,3,188000,95,0.015),
(17,'2026-06-11','Plant B','Assembly','Controller C','Supplier W',1230,34,11,151000,77,0.015),
(18,'2026-06-19','Plant C','Testing','Power Unit A','Supplier Z',1380,10,2,203000,98,0.015);

-- Data-quality checks
SELECT record_id, COUNT(*) AS duplicate_count
FROM manufacturing_sales
GROUP BY record_id
HAVING COUNT(*) > 1;

SELECT *
FROM manufacturing_sales
WHERE production_qty < 0
   OR rejected_qty < 0
   OR rma_qty < 0
   OR revenue < 0
   OR rejected_qty > production_qty;

-- Overall KPIs
SELECT
    SUM(production_qty) AS total_production,
    SUM(rejected_qty) AS total_rejected,
    SUM(rma_qty) AS total_rma,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(100.0 * SUM(rejected_qty) / NULLIF(SUM(production_qty), 0), 2) AS rejection_rate_percent,
    ROUND(1000000.0 * SUM(rejected_qty) / NULLIF(SUM(production_qty), 0), 0) AS defects_ppm,
    ROUND(100.0 * SUM(rma_qty) / NULLIF(SUM(production_qty), 0), 2) AS rma_rate_percent
FROM manufacturing_sales;

-- Plant performance
SELECT
    plant,
    SUM(production_qty) AS production_qty,
    SUM(rejected_qty) AS rejected_qty,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(100.0 * SUM(rejected_qty) / NULLIF(SUM(production_qty), 0), 2) AS rejection_rate_percent,
    RANK() OVER (ORDER BY SUM(revenue) DESC) AS revenue_rank
FROM manufacturing_sales
GROUP BY plant
ORDER BY revenue_rank;

-- Monthly trend
SELECT
    DATE_TRUNC('month', report_date) AS reporting_month,
    SUM(production_qty) AS production_qty,
    SUM(rejected_qty) AS rejected_qty,
    SUM(rma_qty) AS rma_qty,
    ROUND(SUM(revenue), 2) AS revenue
FROM manufacturing_sales
GROUP BY DATE_TRUNC('month', report_date)
ORDER BY reporting_month;

-- Department quality performance
SELECT
    department,
    SUM(rejected_qty) AS total_rejected,
    ROUND(100.0 * SUM(rejected_qty) / NULLIF(SUM(production_qty), 0), 2) AS rejection_rate_percent
FROM manufacturing_sales
GROUP BY department
ORDER BY total_rejected DESC;

-- Supplier ranking
SELECT
    supplier,
    ROUND(AVG(supplier_score), 2) AS average_supplier_score,
    SUM(rejected_qty) AS total_rejected,
    RANK() OVER (ORDER BY AVG(supplier_score) DESC) AS supplier_rank
FROM manufacturing_sales
GROUP BY supplier
ORDER BY supplier_rank;

-- Suppliers requiring attention
SELECT
    supplier,
    ROUND(AVG(supplier_score), 2) AS average_supplier_score
FROM manufacturing_sales
GROUP BY supplier
HAVING AVG(supplier_score) < 85
ORDER BY average_supplier_score;

-- Product RMA performance
SELECT
    product,
    SUM(rma_qty) AS total_rma,
    ROUND(100.0 * SUM(rma_qty) / NULLIF(SUM(production_qty), 0), 2) AS rma_rate_percent
FROM manufacturing_sales
GROUP BY product
ORDER BY total_rma DESC;

