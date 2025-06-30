/* ============================================================================
   Script:        create_schemas.sql
   Description:   Creates the three base schemas used in the layered
                  Data Warehouse architecture (Bronze, Silver, Gold).
                  Schemas isolate data by processing stage.
   Layer:         Initial setup
   Author:        Eduardo Galaz
   Last updated:  2025-06-30
   Usage:         Run via psql:
                  psql -U your_user -d your_database -f scripts/setup/create_schemas.sql
============================================================================ */

\echo '[START] Creating base schemas for the DW...'

CREATE SCHEMA IF NOT EXISTS bronze;
\echo '[OK] Schema bronze created.'

CREATE SCHEMA IF NOT EXISTS silver;
\echo '[OK] Schema silver created.'

CREATE SCHEMA IF NOT EXISTS gold;
\echo '[OK] Schema gold created.'

\echo '[FINISHED] All schemas created successfully.'
