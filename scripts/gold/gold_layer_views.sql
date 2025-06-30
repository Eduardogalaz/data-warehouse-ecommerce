/* =====================================================================
   Script:        gold_layer_views.sql
   Description:   Creates views for the Gold layer (dimensional model)
                  including customers, products and sales fact table.
                  These views are built from cleaned Silver tables and 
                  ready for analytics/reporting.
   Layer:         Gold (Star Schema for Consumption)
   Author:        Eduardo Galaz
   Created:       2025-06-30
   Usage:         Run via psql:
                  psql -U your_user -d your_database -f scripts/gold/gold_layer_views.sql
   ===================================================================== */

\echo '[START] Creating view: gold.dim_customers...'

CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,          -- Surrogate key
	ci.cst_id AS customer_id,                                     -- Natural ID
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr               
		ELSE COALESCE(ca.gen, 'n/a')                              
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
		ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
		ON ci.cst_key = la.cid;

\echo '[OK] View gold.dim_customers created.'

\echo '[START] Creating view: gold.dim_products...'

CREATE OR REPLACE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,  -- Surrogate key
	pn.prd_id AS product_id,                                                  -- Natural ID
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date,
	pc.maintenance
FROM silver.crm_prd_info pn
	LEFT JOIN silver.erp_px_cat_g1v2 pc
		ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL; -- Filter out all inactive (historical) products

\echo '[OK] View gold.dim_products created.'

\echo '[START] Creating view: gold.fact_sales...'

CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
	LEFT JOIN gold.dim_products pr
		ON sd.sls_prd_key = pr.product_number
	LEFT JOIN gold.dim_customers cu
		ON sd.sls_cust_id = cu.customer_id;

\echo '[OK] View gold.fact_sales created.'

\echo '[FINISHED] All Gold layer views created successfully.'
