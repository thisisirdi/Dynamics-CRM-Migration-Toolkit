/*
02_mapping_template.sql
Purpose: Optional SQL-based mapping table to store field mappings + transformations.

Useful when you want mappings tracked in SQL (in addition to the CSV).
*/

IF OBJECT_ID('dbo.FieldMapping', 'U') IS NOT NULL
  DROP TABLE dbo.FieldMapping;
GO

CREATE TABLE dbo.FieldMapping (
  MappingId INT IDENTITY(1,1) PRIMARY KEY,
  SourceEntity SYSNAME NOT NULL,
  SourceField SYSNAME NOT NULL,
  SourceType  NVARCHAR(128) NULL,

  TargetEntity SYSNAME NOT NULL,
  TargetField SYSNAME NOT NULL,
  TargetType  NVARCHAR(128) NULL,

  TransformRule NVARCHAR(4000) NULL,
  LookupRule    NVARCHAR(4000) NULL,
  DefaultValue  NVARCHAR(4000) NULL,
  Notes         NVARCHAR(4000) NULL,

  CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- Example seed rows
INSERT INTO dbo.FieldMapping (SourceEntity, SourceField, SourceType, TargetEntity, TargetField, TargetType, TransformRule, Notes)
VALUES
('Contact', 'emailaddress1', 'nvarchar', 'Contact', 'email', 'nvarchar', 'lower(trim)', 'Normalize casing and whitespace'),
('Contact', 'mobilephone', 'nvarchar', 'Contact', 'phone', 'nvarchar', 'normalize_phone', 'Remove symbols/spaces; keep +country if available'),
('Account', 'name', 'nvarchar', 'Account', 'name', 'nvarchar', 'trim', 'Account name is typically required'),
('Contact', 'statecode', 'int', 'Contact', 'status', 'nvarchar', 'map_statecode', '0=Active, 1=Inactive');
GO

SELECT * FROM dbo.FieldMapping ORDER BY MappingId;
