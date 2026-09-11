/*
Stored Procedure: Load Bronze Layer (Source → Bronze)

Script Purpose:  
This stored procedure loads data into the bronze schema from external CSV files.
It performs the following actions:

Truncates the bronze tables before loading data.

Uses the BULK INSERT command to load data from CSV files into bronze tables.

Parameters:  
None.
This stored procedure does not accept any parameters or return any values.

Usage Example:

sql
EXEC Bronze.load_bronze;


*/

CREATE PROCEDURE Bronze.load_bronze AS
BEGIN
PRINT '-------------------------------------------';
PRINT 'MESSAGE';
PRINT '--------------------------------------------';
DECLARE @start_time DATETIME,@end_time DATETIME
SET @start_time=GETDATE()
BULK INSERT Bronze.crm_cust_info
FROM 'C:\DATA ANALYTICS\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
WITH(
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);
BULK INSERT Bronze.crm_prd_info
FROM 'C:\DATA ANALYTICS\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
WITH(
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);
BULK INSERT Bronze.crm_sales_details
FROM 'C:\DATA ANALYTICS\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
WITH(
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);
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
SET @end_time=GETDATE()
PRINT '>> Load Duration: ' 
    + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) 
    + ' seconds';
END

EXEC Bronze.load_bronze
  /*
DROP PROCEDURE Bronze.load_bronze
*/
