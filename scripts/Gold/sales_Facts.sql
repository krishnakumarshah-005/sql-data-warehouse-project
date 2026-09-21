CREATE VIEW Gold.fact_sale AS
SELECT 
   DISTINCT   sd.sls_ord_num AS Order_Number,
      sls_prd_key,
      pr.Product_Key,
      cu.Customer_Key,
      sd.sls_cust_id,
      sd.sls_order_dt AS Order_Date,
      sd.sls_ship_dt AS Shipping_Date,
      sd.sls_due_dt AS Due_Date,
      sd.sls_sales AS Sales_Amount,
      sd.sls_quantity AS Quantity,
      sd.sls_price AS Price
  FROM Silver.crm_sales_details sd
    LEFT JOIN Gold.dim_product pr
 ON pr.Product_Number=sd.sls_prd_key
  LEFT JOIN Gold.dim_customer cu
  ON cu.Customer_Id=sd.sls_cust_id;


SELECT *
FROM Gold.fact_sale;
