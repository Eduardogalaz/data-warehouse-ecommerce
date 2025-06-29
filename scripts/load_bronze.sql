-- ============================================================================
-- Script: load_bronze.sql
-- Description: Performs a full load of the Bronze layer tables in the 
--              data warehouse by truncating them and loading data from CSVs.
-- Author: Eduardo Galaz
-- Last updated: 2025-06-28
--
-- How to execute this script:
-- --------------------------------------
-- Open terminal and run:
--   psql -U <your_username> -d data_warehouse -f scripts/load_bronze.sql
--
-- Requirements:
-- - The database 'data_warehouse' must exist.
-- - Schemas must already be created: bronze
-- - Tables must already exist in the bronze schema.
-- - Relative paths assume this is run from the project root directory.
--   If not, adjust file paths accordingly.
-- - Set ON_ERROR_STOP=on to stop on any error (recommended):
--   psql --set=ON_ERROR_STOP=on -U postgres -d data_warehouse -f scripts/load_bronze.sql
-- ============================================================================


\echo === Starting full Bronze layer load ===

\echo Truncating Bronze tables...
TRUNCATE TABLE
    bronze.crm_cust_info,
    bronze.crm_prd_info,
    bronze.crm_sales_details,
    bronze.erp_cust_az12,
    bronze.erp_loc_a101,
    bronze.erp_px_cat_g1v2
RESTART IDENTITY;

\echo Loading file: cust_info.csv
\copy bronze.crm_cust_info(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date) FROM 'datasets/source_crm/cust_info.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');

\echo Loading file: prd_info.csv
\copy bronze.crm_prd_info(prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt) FROM 'datasets/source_crm/prd_info.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');

\echo Loading file: sales_details.csv
\copy bronze.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price) FROM 'datasets/source_crm/sales_details.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');

\echo Loading file: cust_az12.csv
\copy bronze.erp_cust_az12(cid, bdate, gen) FROM 'datasets/source_erp/cust_az12.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');

\echo Loading file: loc_a101.csv
\copy bronze.erp_loc_a101(cid, cntry) FROM 'datasets/source_erp/loc_a101.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');

\echo Loading file: px_cat_g1v2.csv
\copy bronze.erp_px_cat_g1v2(id, cat, subcat, maintenance) FROM 'datasets/source_erp/px_cat_g1v2.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');

\echo === Bronze layer load completed successfully ===
