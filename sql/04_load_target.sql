/*
04_load_target.sql
Purpose: Demonstrate load patterns into target tables.

Assumes simplified targets:
  dbo.Target_Account (account_id uniqueidentifier, name, account_number, website)
  dbo.Target_Contact (contact_id uniqueidentifier, first_name, last_name, email, phone, status, account_id)
  dbo.Target_Opportunity (opportunity_id uniqueidentifier, name, estimated_value, created_on, account_id)

In real migrations, target may be:
- another SQL schema
- a destination CRM via API
- a Dynamics instance where you load via integration tooling
- a CSV File ready for upload in new CRM
- Use a third party ETL Tool to send directly to CRM (ex. SSIS) 
*/

SET NOCOUNT ON;

---------------------------------------
-- 0) Demo target tables (create if missing)
---------------------------------------
IF OBJECT_ID('dbo.Target_Account', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.Target_Account (
    account_id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    account_name NVARCHAR(200) NOT NULL,
    account_number NVARCHAR(50) NULL,
    website NVARCHAR(500) NULL,
    source_accountid UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_Target_Account PRIMARY KEY (account_id)
  );
  CREATE INDEX IX_Target_Account_SourceId ON dbo.Target_Account(source_accountid);
  CREATE INDEX IX_Target_Account_Name ON dbo.Target_Account(account_name);
END

IF OBJECT_ID('dbo.Target_Contact', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.Target_Contact (
    contact_id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    first_name NVARCHAR(100) NULL,
    last_name NVARCHAR(100) NULL,
    email NVARCHAR(320) NULL,
    phone NVARCHAR(50) NULL,
    status NVARCHAR(50) NULL,
    account_id UNIQUEIDENTIFIER NULL,
    source_contactid UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_Target_Contact PRIMARY KEY (contact_id)
  );
  CREATE INDEX IX_Target_Contact_SourceId ON dbo.Target_Contact(source_contactid);
  CREATE INDEX IX_Target_Contact_Email ON dbo.Target_Contact(email);
END

IF OBJECT_ID('dbo.Target_Opportunity', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.Target_Opportunity (
    opportunity_id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    opportunity_name NVARCHAR(200) NOT NULL,
    estimated_value DECIMAL(18,2) NULL,
    created_on DATETIME2 NULL,
    account_id UNIQUEIDENTIFIER NULL,
    source_opportunityid UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_Target_Opportunity PRIMARY KEY (opportunity_id)
  );
  CREATE INDEX IX_Target_Opp_SourceId ON dbo.Target_Opportunity(source_opportunityid);
END

---------------------------------------
-- 1) Load Accounts (MERGE by source_accountid)
---------------------------------------
MERGE dbo.Target_Account AS tgt
USING (
  SELECT accountid AS source_accountid, account_name, account_number, website
  FROM dbo.Stage_Account
) AS src
ON tgt.source_accountid = src.source_accountid
WHEN MATCHED THEN
  UPDATE SET
    tgt.account_name = src.account_name,
    tgt.account_number = src.account_number,
    tgt.website = src.website
WHEN NOT MATCHED THEN
  INSERT (account_name, account_number, website, source_accountid)
  VALUES (src.account_name, src.account_number, src.website, src.source_accountid);

---------------------------------------
-- 2) Load Contacts
-- Demo relationship join: if parentcustomerid_raw matches a Source accountid, link it
---------------------------------------
;WITH ContactWithAccount AS (
  SELECT
    sc.contactid AS source_contactid,
    sc.first_name,
    sc.last_name,
    sc.email_normalized AS email,
    sc.mobile_normalized AS phone,
    sc.status_mapped AS status,
    ta.account_id AS target_account_id
  FROM dbo.Stage_Contact sc
  LEFT JOIN dbo.Target_Account ta
    ON TRY_CONVERT(UNIQUEIDENTIFIER, sc.parentcustomerid_raw) = ta.source_accountid
)
MERGE dbo.Target_Contact AS tgt
USING ContactWithAccount AS src
ON tgt.source_contactid = src.source_contactid
WHEN MATCHED THEN
  UPDATE SET
    tgt.first_name = src.first_name,
    tgt.last_name = src.last_name,
    tgt.email = src.email,
    tgt.phone = src.phone,
    tgt.status = src.status,
    tgt.account_id = src.target_account_id
WHEN NOT MATCHED THEN
  INSERT (first_name, last_name, email, phone, status, account_id, source_contactid)
  VALUES (src.first_name, src.last_name, src.email, src.phone, src.status, src.target_account_id, src.source_contactid);

---------------------------------------
-- 3) Load Opportunities (link to account via customerid_raw)
---------------------------------------
;WITH OppWithAccount AS (
  SELECT
    so.opportunityid AS source_opportunityid,
    so.opportunity_name,
    TRY_CONVERT(DECIMAL(18,2), so.estimatedvalue) AS estimated_value,
    so.createdon AS created_on,
    ta.account_id AS target_account_id
  FROM dbo.Stage_Opportunity so
  LEFT JOIN dbo.Target_Account ta
    ON TRY_CONVERT(UNIQUEIDENTIFIER, so.customerid_raw) = ta.source_accountid
)
MERGE dbo.Target_Opportunity AS tgt
USING OppWithAccount AS src
ON tgt.source_opportunityid = src.source_opportunityid
WHEN MATCHED THEN
  UPDATE SET
    tgt.opportunity_name = src.opportunity_name,
    tgt.estimated_value = src.estimated_value,
    tgt.created_on = src.created_on,
    tgt.account_id = src.target_account_id
WHEN NOT MATCHED THEN
  INSERT (opportunity_name, estimated_value, created_on, account_id, source_opportunityid)
  VALUES (src.opportunity_name, src.estimated_value, src.created_on, src.target_account_id, src.source_opportunityid);

---------------------------------------
-- Quick summary
---------------------------------------
SELECT 'Target_Account' AS Tbl, COUNT(1) AS Cnt FROM dbo.Target_Account
UNION ALL
SELECT 'Target_Contact', COUNT(1) FROM dbo.Target_Contact
UNION ALL
SELECT 'Target_Opportunity', COUNT(1) FROM dbo.Target_Opportunity;
