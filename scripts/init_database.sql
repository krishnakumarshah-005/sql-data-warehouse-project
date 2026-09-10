/*
Create Databaseand Schemas
Script Purpose:
This script creates a new database named 'DataWarehouse' after checking if it already exists.
if the database exists , it is dropped and recreated. Additionally, the script sets
up three schemas within the database: 'bronze','silver' and 'Gold'.

WARNING:
Running this script will drop the entire'Datatwarehouse' database if it exists. 
All data in the database will be permannently deleetd. 
Proceed with caution and ensure you have proper backups before running this script.

*/

USE master
GO

/*
SELECT name 
FROM sys.databases;

EXEC sp_databases;

SELECT name 
FROM master.dbo.sysdatabases
*/

CREATE DATABASE DataWareHouse
GO

USE DataWareHouse
GO

CREATE SCHEMA Bronze
GO
CREATE SCHEMA Silver
GO
CREATE SCHEMA Gold
GO

USE master;
USE DataWareHouse
GO
/*
Created SCHEMA in Database
.............................
CREATE SCHEMA Bronze
GO
CREATE SCHEMA Silver
GO
CREATE SCHEMA Gold
GO
*/

SELECT name 
FROM sys.schemas
GO

IF OBJECT_ID('Bronze.crm_prd_info','U') IS NOT NULL
DROP TABLE Bronze.crm_prd_info
CREATE TABLE Bronze.crm_prd_info(
prd_id INT,
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE
);

IF OBJECT_ID('Bronze.crm_cust_info','U') IS NOT NULL
DROP TABLE Bronze.crm_cust_info
CREATE TABLE Bronze.crm_cust_info(
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_marital_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE
);

IF OBJECT_ID('Bronze.crm_sales_details','U') IS NOT NULL
DROP TABLE Bronze.crm_sales_details
CREATE TABLE Bronze.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT, 
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
);

IF OBJECT_ID('Bronze.erp_loc_a101','U') IS NOT NULL
DROP TABLE Bronze.erp_loc_a101
CREATE TABLE Bronze.erp_loc_a101(
cid NVARCHAR(50),
CNTRY NVARCHAR(50)
);

IF OBJECT_ID('Bronze.erp_cust_az12','U') IS NOT NULL
DROP TABLE Bronze.erp_cust_az12
CREATE TABLE Bronze.erp_cust_az12(
cid NVARCHAR(50),
bdate DATE,
gen NVARCHAR(50)
);

IF OBJECT_ID('Bronze.erp_px_cat_g1v2','U') IS NOT NULL
DROP TABLE Bronze.erp_px_cat_g1v2
CREATE TABLE Bronze.erp_px_cat_g1v2(
id NVARCHAR(50),
cat NVARCHAR(50),
subcat NVARCHAR(50),
maintenance NVARCHAR(50)
);

/*
Section 2
*/
use DataWareHouse
GO

BULK INSERT Bronze.crm_cust_info
FROM 'C:\DATA ANALYTICS\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
WITH(
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);

/*
SELECT *
FROM Bronze.crm_cust_info;
*/

BULK INSERT Bronze.crm_prd_info
FROM 'C:\DATA ANALYTICS\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
WITH(
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);

/*
SELECT * FROM Bronze.crm_prd_info;
*/


BULK INSERT Bronze.crm_sales_details
FROM 'C:\DATA ANALYTICS\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
WITH(
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);
/*
SELECT * 
FROM Bronze.crm_sales_details;
*/
BULK INSERT Bronze.erp_loc_a101
FROM 'C:\DATA ANALYTICS\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
WITH(
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);


BULK INSERT Bronze.erp_cust_az12
FROM 'C:\DATA ANALYTICS\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
WITH(
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);

BULK INSERT Bronze.erp_px_cat_g1v2
FROM 'C:\DATA ANALYTICS\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
WITH(
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);








