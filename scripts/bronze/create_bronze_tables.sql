/* ============================================================================
   Script:        create_bronze_tables.sql
   Description:   Recreates all Bronze layer tables for the Data Warehouse.
                  - Drops tables if they already exist.
                  - Reflects raw CSV input structure with no constraints.
                  - Organized into CRM and ERP source sections.
                  - Naming convention: bronze.[source_table_name]
   Layer:         Bronze (Raw Data)
   Author:        Eduardo Galaz
   Last updated:  2025-06-30
   Usage:         Run via psql:
                  psql -U your_user -d your_database -f scripts/bronze/create_bronze_tables.sql
============================================================================ */

\echo '[START] Creating Bronze layer tables...'

/* ==============================
   CRM (Customer Relationship Management) Tables
   ============================== */

\echo '[CREATE] bronze.crm_cust_info'
DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
	cst_id INT,
	cst_key VARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status VARCHAR(50),
	cst_gndr VARCHAR(50),
	cst_create_date DATE
);

\echo '[CREATE] bronze.crm_prd_info'
DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
	prd_id INT,
	prd_key VARCHAR(50),
	prd_nm VARCHAR(50),
	prd_cost INT,
	prd_line VARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE
);

\echo '[CREATE] bronze.crm_sales_details'
DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
	sls_ord_num VARCHAR(50),
	sls_prd_key VARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

/* ==============================
   ERP (Enterprise Resource Planning) Tables
   ============================== */

\echo '[CREATE] bronze.erp_cust_az12'
DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
	cid VARCHAR(50),
	bdate DATE,
	gen VARCHAR(50)
);

\echo '[CREATE] bronze.erp_loc_a101'
DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
	cid VARCHAR(50),
	cntry VARCHAR(50)
);

\echo '[CREATE] bronze.erp_px_cat_g1v2'
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50)
);

\echo '[OK] All Bronze layer tables created successfully.'
