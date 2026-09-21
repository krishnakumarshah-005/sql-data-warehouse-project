CREATE VIEW Gold.dim_customer AS
SELECT DISTINCT
ROW_NUMBER() OVER(ORDER BY cst_id) AS Customer_Key,
cci.cst_id AS Customer_Id,
cci.cst_key as Customer_Number,
cci.cst_firstname AS Customer_Firstname,
cci.cst_lastname AS Customer_Lastname,
cci.cst_marital_status AS Marital_Status,
eca.bdate AS Birth_Date,
CASE 
	WHEN cci.cst_gndr !='Other' THEN cci.cst_gndr
	ELSE COALESCE(eca.gen,'Not Available')
END AS Gender,

ela.CNTRY AS Country,
cci.cst_create_date AS Created_Date
FROM 
Silver.crm_cust_info cci
LEFT JOIN Silver.erp_cust_az12  eca
ON cci.cst_key=eca.cid
LEFT JOIN Silver.erp_loc_a101 ela
ON cci.cst_key=ela.cid;

SELECT DISTINCT *
FROM Gold.dim_customer;
