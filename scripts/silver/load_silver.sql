/*=====================================================================
	Script:        load_silver.sql
	Description:   Cleans and loads data from Bronze to Silver layer
	               applying standard transformations, mappings and
	               deduplication rules.
	Layer:         Silver (Cleaned & Structured)
	Author:        Eduardo Galaz
	Created:       2025-06-30
	Usage:         Run via psql CLI: 
	                psql -U your_user -d your_db -f scripts/silver/load_silver.sql
=====================================================================
*/

\echo '[START] Loading table silver.crm_cust_info...'
TRUNCATE silver.crm_cust_info;

INSERT INTO silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
)
SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname),
	TRIM(cst_lastname),
	CASE 
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		ELSE 'n/a'
	END,
	CASE 
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'n/a'
	END,
	cst_create_date
FROM (
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
) t
WHERE flag_last = 1;

\echo '[OK] silver.crm_cust_info loaded.'

\echo '[START] Loading table silver.crm_prd_info...'
TRUNCATE silver.crm_prd_info;

INSERT INTO silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
	SUBSTRING(prd_key, 7, LENGTH(prd_key)),
	prd_nm,
	COALESCE(prd_cost, 0),
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END,
	prd_start_dt,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1
FROM bronze.crm_prd_info;

\echo '[OK] silver.crm_prd_info loaded.'

\echo '[START] Loading table silver.crm_sales_details...'
TRUNCATE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)
SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE
		WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::text) != 8 THEN NULL
		ELSE TO_DATE(sls_order_dt::text, 'YYYYMMDD')
	END,
	CASE
		WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::text) != 8 THEN NULL
		ELSE TO_DATE(sls_ship_dt::text, 'YYYYMMDD')
	END,
	CASE
		WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::text) != 8 THEN NULL
		ELSE TO_DATE(sls_due_dt::text, 'YYYYMMDD')
	END,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
		THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END
FROM bronze.crm_sales_details;

\echo '[OK] silver.crm_sales_details loaded.'

\echo '[START] Loading table silver.erp_cust_az12...'
TRUNCATE silver.erp_cust_az12;

INSERT INTO silver.erp_cust_az12(
	cid,
	bdate,
	gen
)
SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		ELSE cid
	END,
	CASE WHEN bdate > CURRENT_DATE THEN NULL
		ELSE bdate
	END,
	CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		ELSE 'n/a'
	END
FROM bronze.erp_cust_az12;

\echo '[OK] silver.erp_cust_az12 loaded.'

\echo '[START] Loading table silver.erp_loc_a101...'
TRUNCATE silver.erp_loc_a101;

INSERT INTO silver.erp_loc_a101(
	cid,
	cntry
)
SELECT
	REPLACE(cid, '-', ''),
	CASE
		WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
		WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
		WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
		ELSE TRIM(cntry)
	END
FROM bronze.erp_loc_a101;

\echo '[OK] silver.erp_loc_a101 loaded.'

\echo '[START] Loading table silver.erp_px_cat_g1v2...'
TRUNCATE silver.erp_px_cat_g1v2;

INSERT INTO silver.erp_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance
)
SELECT 
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;

\echo '[OK] silver.erp_px_cat_g1v2 loaded.'

\echo '[FINISHED] All Silver tables loaded successfully.'
