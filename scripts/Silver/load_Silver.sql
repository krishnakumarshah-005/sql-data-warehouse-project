/*
Analayze
  */
SELECT *
FROM Bronze.crm_cust_info;

/*

Inserting into Silver after Data Cleansing

*/

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

/*
Analyze
*/

SELECT *
FROM Silver.crm_cust_info;

/*
Checking quality

*/

SELECT cst_id, COUNT(*)
FROM Silver.crm_cust_info 
WHERE cst_marital_status IS NULL
OR cst_gndr IS NULL
OR cst_firstname != TRIM(cst_firstname)
OR cst_lastname != TRIM(cst_lastname)
GROUP BY cst_id
HAVING COUNT(*)>1;




/*
Cleansing of Bronze.crm_prd_info
and loading in Silver.crm_prd_info
*/

USE DataWareHouse;

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



SELECT *
FROM Silver.crm_prd_info;
