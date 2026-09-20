USE DataWareHouse;

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

SELECT * 
FROM Silver.erp_cust_az12;






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

SELECT * 
FROM Silver.erp_loc_a101;

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

SELECT *
FROM Silver.erp_px_cat_g1v2;
