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

-------------------------------------------------------------------------------------------
CREATE VIEW Gold.dim_product AS
SELECT 
ROW_NUMBER() OVER(ORDER BY prd_start_dt,prd_key) AS Product_Key,
cpi.prd_id AS Product_Id,
cpi.prd_key AS Product_Number,
cpi.prd_nm AS Product_Name,
cpi.cat_id AS Category_Id,
epcg.cat AS Category,
epcg.subcat AS SubCategory,
epcg.maintenance AS Maintenance,
cpi.prd_cost AS Product_Cost,
cpi.prd_line AS Product_Line,
cpi.prd_start_dt AS Product_Start_Date
FROM Silver.crm_prd_info AS cpi
LEFT JOIN
Silver.erp_px_cat_g1v2 AS epcg
ON cpi.cat_id=epcg.id;

SELECT *
FROM
Gold.dim_product;
