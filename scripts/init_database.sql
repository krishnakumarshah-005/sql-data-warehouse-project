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






