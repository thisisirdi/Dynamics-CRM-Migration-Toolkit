/*
01_profile_source.sql
Purpose: Source profiling for a Dynamics-centric CRM migration using SQL Server staging tables.

Assumes existence of:
  dbo.Source_Account
  dbo.Source_Contact
  dbo.Source_Opportunity

Replace table names if your source staging differs.
*/

SET NOCOUNT ON;

--------------------------
-- 1) Row counts per entity
--------------------------
SELECT 'Source_Account' AS Entity, COUNT(1) AS RowCount FROM dbo.Source_Account
UNION ALL
SELECT 'Source_Contact'  AS Entity, COUNT(1) AS RowCount FROM dbo.Source_Contact
UNION ALL
SELECT 'Source_Opportunity' AS Entity, COUNT(1) AS RowCount FROM dbo.Source_Opportunity;

----------------------------------------
-- 2) Null rate checks for key attributes
----------------------------------------
SELECT
  'Source_Account' AS Entity,
  SUM(CASE WHEN NULL IF(LTRIM(RTRIM([name])), '') IS NULL THEN 1 ELSE 0 END) AS NullOrBlank_Name,
  COUNT(1) AS Total
FROM dbo.Source_Account;

SELECT
  'Source_Contact' AS Entity,
  SUM(CASE WHEN NULL IF(LTRIM(RTRIM(emailaddress1)), '') IS NULL THEN 1 ELSE 0 END) AS NullOrBlank_Email,
  SUM(CASE WHEN NULL IF(LTRIM(RTRIM(mobilephone)), '') IS NULL THEN 1 ELSE 0 END) AS NullOrBlank_Mobile,
  COUNT(1) AS Total
FROM dbo.Source_Contact;

SELECT
  'Source_Opportunity' AS Entity,
  SUM(CASE WHEN NULL IF(LTRIM(RTRIM([name])), '') IS NULL THEN 1 ELSE 0 END) AS NullOrBlank_Name,
  COUNT(1) AS Total
FROM dbo.Source_Opportunity;

-----------------------------------
-- 3) Duplicate detection (Contacts)
-- Dynamics often uses email as a business key in downstream systems.
-----------------------------------
SELECT
  LOWER(LTRIM(RTRIM(emailaddress1))) AS NormalizedEmail,
  COUNT(1) AS Cnt
FROM dbo.Source_Contact
WHERE NULL IF(LTRIM(RTRIM(emailaddress1)), '') IS NOT NULL
GROUP BY LOWER(LTRIM(RTRIM(emailaddress1)))
HAVING COUNT(1) > 1
ORDER BY Cnt DESC;

-----------------------------------
-- 4) Basic relationship integrity (example)
-- If you have account linkage in parentcustomerid, validate fill rate.
-----------------------------------
SELECT
  SUM(CASE WHEN NULL IF(LTRIM(RTRIM(parentcustomerid)), '') IS NULL THEN 1 ELSE 0 END) AS MissingParentCustomerId,
  COUNT(1) AS TotalContacts
FROM dbo.Source_Contact;
