IF OBJECT_ID('Silver.crm_prd_info','U') IS NOT NULL
DROP TABLE Silver.crm_prd_info
CREATE TABLE Silver.crm_prd_info(
prd_id INT,
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE,
dwh_create_dt DATETIME2 DEFAULT GETDATE()
);
/*
--  
USE DataWareHouse;
Cleansing and loading to Silver

*/


SELECT 
prd_id,
prd_key,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key1,
prd_nm,
prd_cost,
ISNULL(prd_cost,0) AS prd_cost1,
-- COALESCE(prd_cost,0) AS prd_cost1,
CASE
	WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
	WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
	WHEN UPPER(TRIM(prd_line))='S' THEN 'Other Sales'
	WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
	ELSE 'None'
END AS prd_line,
prd_start_dt,
/*
-- prd_end_dt,
--CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt1   error 
CAST(
    LEAD(CAST(prd_start_dt AS DATETIME)) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1
    AS DATE
) AS prd_end_dt1,
LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt
*/
CAST(
CASE 
    WHEN LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) IS NULL 
        THEN GETDATE()  -- fallback if no next row
    WHEN LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) <= prd_start_dt 
        THEN prd_start_dt  -- ensures end_date is never less than start_date
    ELSE DATEADD(DAY, -1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt))
END  AS DATE) AS prd_end_dt
FROM Bronze.crm_prd_info;




IF OBJECT_ID('Silver.crm_prd_info','U') IS NOT NULL
DROP TABLE Silver.crm_prd_info;
CREATE TABLE Silver.crm_prd_info(
prd_id INT,
prd_key NVARCHAR(50),
cat_id NVARCHAR(50),
prd_nm   NVARCHAR(50),
prd_cost INT,
prd_line  NVARCHAR(50),
prd_start_dt   DATE,
prd_end_dt  DATE,
dwh_create_dt   DATETIME2 DEFAULT GETDATE()
);


SELECT *
FROM Silver.crm_prd_info;

IF OBJECT_ID('Silver.crm_cust_info','U') IS NOT NULL
DROP TABLE Silver.crm_cust_info
CREATE TABLE Silver.crm_cust_info(
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_marital_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE,
dwh_create_dt DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('Silver.crm_sales_details','U') IS NOT NULL
DROP TABLE Silver.crm_sales_details
CREATE TABLE Silver.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT, 
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT,
dwh_create_dt DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('Silver.erp_loc_a101','U') IS NOT NULL
DROP TABLE Silver.erp_loc_a101
CREATE TABLE Silver.erp_loc_a101(
cid NVARCHAR(50),
CNTRY NVARCHAR(50),
dwh_create_dt DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('Silver.erp_cust_az12','U') IS NOT NULL
DROP TABLE Silver.erp_cust_az12
CREATE TABLE Silver.erp_cust_az12(
cid NVARCHAR(50),
bdate DATE,
gen NVARCHAR(50),
dwh_create_dt DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('Silver.erp_px_cat_g1v2','U') IS NOT NULL
DROP TABLE Silver.erp_px_cat_g1v2
CREATE TABLE Silver.erp_px_cat_g1v2(
id NVARCHAR(50),
cat NVARCHAR(50),
subcat NVARCHAR(50),
maintenance NVARCHAR(50),
dwh_create_dt DATETIME2 DEFAULT GETDATE()
);


