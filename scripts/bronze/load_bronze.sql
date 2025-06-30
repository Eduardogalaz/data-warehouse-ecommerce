/* ============================================================================
   Script:        load_bronze.sql
   Description:   Performs a full load of the Bronze layer tables in the 
                  data warehouse by truncating them and loading data from CSVs.
   Layer:         Bronze (Raw Data)
   Author:        Eduardo Galaz
   Last updated:  2025-06-30
   Usage:         Run via psql:
                  psql --set=ON_ERROR_STOP=on -U your_user -d your_database -f scripts/bronze/load_bronze.sql

   Requirements:
     - Database and schemas must exist: bronze
     - Tables must already exist in the bronze schema
     - CSV files must be present under the datasets/ folder
     - Run from the project root, or adjust file paths accordingly
============================================================================ */

\echo '[START] Full Bronze layer load...'

/* --------------------------------------
   Step 1: Truncate all Bronze tables
-------------------------------------- */
\echo '[TRUNCATE] Clearing Bronze tables...'
TRUNCATE TABLE
    bronze.crm_cust_info,
    bronze.crm_prd_info,
    bronze.crm_sales_details,
    bronze.erp_cust_az12,
    bronze.erp_loc_a101,
    bronze.erp_px_cat_g1v2
RESTART IDENTITY;

/* --------------------------------------
   Step 2: Load CRM source data
-------------------------------------- */
\echo '[LOAD] Loading file: cust_info.csv'
\copy bronze.crm_cust_info(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date) 
FROM 'datasets/source_crm/cust_info.csv' 
WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');

\echo '[LOAD] Loading file: prd_info.csv'
\copy bronze.crm_prd_info(prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt) 
FROM 'datasets/source_crm/prd_info.csv' 
WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');

\echo '[LOAD] Loading file: sales_details.csv'
\copy bronze.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price) 
FROM 'datasets/source_crm/sales_details.csv' 
WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');

/* --------------------------------------
   Step 3: Load ERP source data
-------------------------------------- */
\echo '[LOAD] Loading file: cust_az12.csv'
\copy bronze.erp_cust_az12(cid, bdate, gen) 
FROM 'datasets/source_erp/cust_az12.csv' 
WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');

\echo '[LOAD] Loading file: loc_a101.csv'
\copy bronze.erp_loc_a101(cid, cntry) 
FROM 'datasets/source_erp/loc_a101.csv' 
WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');

\echo '[LOAD] Loading file: px_cat_g1v2.csv'
\copy bronze.erp_px_cat_g1v2(id, cat, subcat, maintenance) 
FROM 'datasets/source_erp/px_cat_g1v2.csv' 
WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');

\echo '[OK] Bronze layer load completed successfully.'