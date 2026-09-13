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

