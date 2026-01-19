/*
05_validation_checks.sql
Purpose: Post-migration integrity checks.

Checks:
- record counts source vs target
- orphan relationships
- duplicates in target

In real life Migration Scenario, validation checks will be more extensive to also check for custom business logic that customer might need. 
*/

SET NOCOUNT ON;

---------------------------------------
-- 1) Count reconciliation
---------------------------------------
SELECT
  'Account' AS Entity,
  (SELECT COUNT(1) FROM dbo.Source_Account) AS SourceCount,
  (SELECT COUNT(1) FROM dbo.Target_Account) AS TargetCount;

SELECT
  'Contact' AS Entity,
  (SELECT COUNT(1) FROM dbo.Source_Contact) AS SourceCount,
  (SELECT COUNT(1) FROM dbo.Target_Contact) AS TargetCount;

SELECT
  'Opportunity' AS Entity,
  (SELECT COUNT(1) FROM dbo.Source_Opportunity) AS SourceCount,
  (SELECT COUNT(1) FROM dbo.Target_Opportunity) AS TargetCount;

---------------------------------------
-- 2) Orphan checks
---------------------------------------
-- Contacts that should be linked but have no account_id in target
SELECT TOP 50
  tc.source_contactid,
  tc.email,
  tc.first_name,
  tc.last_name
FROM dbo.Target_Contact tc
WHERE tc.account_id IS NULL
  AND tc.source_contactid IS NOT NULL
ORDER BY tc.email;

-- Opportunities without account links
SELECT TOP 50
  to2.source_opportunityid,
  to2.opportunity_name,
  to2.estimated_value
FROM dbo.Target_Opportunity to2
WHERE to2.account_id IS NULL
  AND to2.source_opportunityid IS NOT NULL
ORDER BY to2.opportunity_name;

---------------------------------------
-- 3) Duplicate checks in target (email)
---------------------------------------
SELECT
  LOWER(LTRIM(RTRIM(email))) AS NormalizedEmail,
  COUNT(1) AS Cnt
FROM dbo.Target_Contact
WHERE NULLIF(LTRIM(RTRIM(email)), '') IS NOT NULL
GROUP BY LOWER(LTRIM(RTRIM(email)))
HAVING COUNT(1) > 1
ORDER BY Cnt DESC;

---------------------------------------
-- 4) Spot check samples
---------------------------------------
SELECT TOP 25 * FROM dbo.Target_Account ORDER BY account_name;
SELECT TOP 25 * FROM dbo.Target_Contact ORDER BY email;
SELECT TOP 25 * FROM dbo.Target_Opportunity ORDER BY opportunity_name;
