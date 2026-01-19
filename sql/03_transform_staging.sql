/*
03_transform_staging.sql
Purpose: Create staging tables with standardized formats and example mappings.

This is where you:
- normalize email/phone
- map status codes
- prepare relationship keys

Assumes:
  dbo.Source_Account
  dbo.Source_Contact
  dbo.Source_Opportunity
*/

SET NOCOUNT ON;

-----------------------------
-- Helper: normalize phone (simple demo)
-- Replace multiple characters; keep digits and leading +
-----------------------------
-- NOTE: For a real project, handle country codes and extensions more robustly.

IF OBJECT_ID('tempdb..#PhoneClean') IS NOT NULL DROP TABLE #PhoneClean;

-----------------------------
-- Staging: Accounts
-----------------------------
IF OBJECT_ID('dbo.Stage_Account', 'U') IS NOT NULL DROP TABLE dbo.Stage_Account;

SELECT
  a.accountid,
  LTRIM(RTRIM(a.[name])) AS account_name,
  NULLIF(LTRIM(RTRIM(a.accountnumber)), '') AS account_number,
  NULLIF(LTRIM(RTRIM(a.websiteurl)), '') AS website,
  SYSUTCDATETIME() AS staged_at_utc
INTO dbo.Stage_Account
FROM dbo.Source_Account a;

CREATE INDEX IX_Stage_Account_Name ON dbo.Stage_Account(account_name);

-----------------------------
-- Staging: Contacts
-----------------------------
IF OBJECT_ID('dbo.Stage_Contact', 'U') IS NOT NULL DROP TABLE dbo.Stage_Contact;

SELECT
  c.contactid,
  LTRIM(RTRIM(c.firstname)) AS first_name,
  LTRIM(RTRIM(c.lastname))  AS last_name,
  LOWER(NULLIF(LTRIM(RTRIM(c.emailaddress1)), '')) AS email_normalized,

  -- basic phone normalization
  CASE
    WHEN c.mobilephone IS NULL THEN NULL
    ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(c.mobilephone)), ' ', ''), '-', ''), '(', ''), ')', ''), '.', '')
  END AS mobile_normalized,

  -- Dynamics-like statecode mapping example
  CASE
    WHEN c.statecode = 0 THEN 'Active'
    WHEN c.statecode = 1 THEN 'Inactive'
    ELSE 'Unknown'
  END AS status_mapped,

  NULLIF(LTRIM(RTRIM(c.parentcustomerid)), '') AS parentcustomerid_raw,
  SYSUTCDATETIME() AS staged_at_utc
INTO dbo.Stage_Contact
FROM dbo.Source_Contact c;

CREATE INDEX IX_Stage_Contact_Email ON dbo.Stage_Contact(email_normalized);

-----------------------------
-- Staging: Opportunities
-----------------------------
IF OBJECT_ID('dbo.Stage_Opportunity', 'U') IS NOT NULL DROP TABLE dbo.Stage_Opportunity;

SELECT
  o.opportunityid,
  LTRIM(RTRIM(o.[name])) AS opportunity_name,
  o.estimatedvalue,
  o.createdon,
  NULLIF(LTRIM(RTRIM(o.customerid)), '') AS customerid_raw,
  SYSUTCDATETIME() AS staged_at_utc
INTO dbo.Stage_Opportunity
FROM dbo.Source_Opportunity o;

CREATE INDEX IX_Stage_Opportunity_Name ON dbo.Stage_Opportunity(opportunity_name);

-----------------------------
-- Quick staging QA checks
-----------------------------
SELECT 'Stage_Account' AS Tbl, COUNT(1) AS Cnt FROM dbo.Stage_Account
UNION ALL
SELECT 'Stage_Contact', COUNT(1) FROM dbo.Stage_Contact
UNION ALL
SELECT 'Stage_Opportunity', COUNT(1) FROM dbo.Stage_Opportunity;
