CREATE OR ALTER PROCEDURE Silver.load_silver as
BEGIN
PRINT 'Trucating the table Silver.crm_cust_info';
TRUNCATE TABLE Silver.crm_cust_info;
PRINT 'Inserting into TABLE Silver.crm_cust_info';
INSERT INTO Silver.crm_cust_info
(
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
COALESCE(TRIM(cst_firstname),'') cst_firstname,
COALESCE(TRIM(cst_lastName),'') cst_lastname,
CASE WHEN TRIM(cst_marital_status) = 'S' THEN 'Single'
	 WHEN TRIM(cst_marital_status) = 'M' THEN 'Married'
	 ELSE 'Relationship'
END cst_marital_status
,
CASE WHEN TRIM(cst_gndr) = 'M' THEN 'Male'
	 WHEN TRIM(cst_gndr) = 'F' THEN 'Female'
	 ELSE 'Other'
END cst_gndr
,
cst_create_date
FROM
(
	SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last 
	FROM Bronze.crm_cust_info
)t
WHERE flag_last=1;




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

PRINT 'Trucating the table Silver.crm_prd_info';
TRUNCATE TABLE Silver.crm_prd_info;
PRINT 'Inserting into TABLE Silver.crm_prd_info';
INSERT INTO Silver.crm_prd_info(
prd_id,
prd_key,
cat_id,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
SELECT 
prd_id,
SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
prd_nm,
ISNULL(prd_cost,0) AS prd_cost,
-- COALESCE(prd_cost,0) AS prd_cost1,
CASE
	WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
	WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
	WHEN UPPER(TRIM(prd_line))='S' THEN 'Other Sales'
	WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
	ELSE 'None'
END AS prd_line,
prd_start_dt,
CAST(
CASE 
    WHEN LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) IS NULL 
        THEN GETDATE()  -- fallback if no next row
    WHEN LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) <= prd_start_dt 
        THEN prd_start_dt  -- ensures end_date is never less than start_date
    ELSE DATEADD(DAY, -1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt))
END  AS DATE) AS prd_end_dt
FROM Bronze.crm_prd_info;




IF OBJECT_ID('Silver.crm_sales_details','U') IS NOT NULL
DROP TABLE Silver.crm_sales_details
CREATE TABLE Silver.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt DATE,
sls_ship_dt DATE, 
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
sls_price INT,
dwh_create_dt DATETIME2 DEFAULT GETDATE()
);	

PRINT 'Trucating the table Silver.crm_sales_details';
TRUNCATE TABLE Silver.crm_sales_details;
PRINT 'Inserting into TABLE Silver.crm_sales_details';
INSERT INTO Silver.crm_sales_details(
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
	WHEN sls_order_dt=0 OR LEN(sls_order_dt)!=8 THEN NULL
	ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
CASE 
	WHEN sls_ship_dt=0 OR LEN(sls_ship_dt)!=8 THEN NULL
	ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
CASE 
	WHEN sls_due_dt=0 OR LEN(sls_due_dt)!=8 THEN NULL
	ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
CASE 
	WHEN sls_sales IS NULL OR sls_sales=0 or sls_sales!=sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price<=0 THEN sls_sales/NULLIF(sls_quantity,0)
	ELSE sls_price
END AS sls_price
FROM Bronze.crm_sales_details;


PRINT 'Trucating the table Silver.erp_cust_az12';
TRUNCATE TABLE Silver.erp_cust_az12;
PRINT 'Inserting into TABLE Silver.erp_cust_az12';
INSERT 
INTO Silver.erp_cust_az12
(
cid,
bdate,
gen)
SELECT
CASE 
	WHEN cid LIKE '%NAS%' THEN SUBSTRING(cid,5,LEN(cid))
	ELSE cid
END AS cid,
CASE 
	WHEN bdate>GETDATE() THEN NULL
	ELSE bdate
END AS bdate, 
CASE 
	WHEN UPPER(TRIM(gen)) IN ('MALE','M') THEN 'Male'
	WHEN UPPER(TRIM(gen)) IN ('FEMALE','F') THEN 'Female'
	ELSE 'Not Available'
END AS gen
FROM Bronze.erp_cust_az12;


PRINT 'Trucating the table Silver.erp_loc_a101';
TRUNCATE TABLE Silver.erp_loc_a101;
PRINT 'Inserting into TABLE Silver.erp_loc_a101';
INSERT INTO Silver.erp_loc_a101(
cid,
CNTRY
)
SELECT 
REPLACE(cid,'-','') AS cid,
CASE WHEN TRIM(CNTRY)='DE' THEN 'Germany'
	 WHEN TRIM(CNTRY) IN ('US','USA') THEN 'United States'
	 WHEN TRIM(CNTRY)='' OR CNTRY IS NULL THEN 'Not available'
	 ELSE TRIM(CNTRY)
END AS cntry
FROM Bronze.erp_loc_a101;

PRINT 'Trucating the table Silver.erp_px_cat_g1v2';
TRUNCATE TABLE Silver.erp_px_cat_g1v2;
PRINT 'Inserting into TABLE Silver.erp_px_cat_g1v2';
INSERT INTO  Silver.erp_px_cat_g1v2(
id,
cat,
subcat,
maintenance)
SELECT * 
FROM Bronze.erp_px_cat_g1v2;
END


EXEC Silver.load_silver;
