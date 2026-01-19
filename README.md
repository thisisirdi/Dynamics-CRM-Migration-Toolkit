# Dynamics CRM Migration SQL Toolkit (Demo)

This repository contains a lightweight, SQL Server–centric toolkit to support CRM data migrations involving Microsoft Dynamics CRM / Dataverse-style data, with a focus on:

- Source data profiling (row counts, null rates, duplicates)
- Field mapping documentation (template + optional SQL-backed mapping table)
- Staging transformations (standardization + value mapping)
- Load patterns (INSERT + MERGE/UPSERT approach)
- Post-migration validation (counts, orphan checks, reconciliation queries)

> Note: This is a demo toolkit meant to show a repeatable migration approach. The exact Dynamics entities/fields vary by organization and customizations.

---

## Typical Workflow

### Phase 1 — Profile Source Data
Run:
- `sql/01_profile_source.sql`

Outputs:
- Row counts per entity
- Null rate checks for key columns
- Duplicate detection suggestions (email/phone/name)

### Phase 2 — Build Mapping Plan
Use:
- `docs/mapping_sheet_template.csv` (fill it out with the client)

Optional:
- `sql/02_mapping_template.sql` to store mapping rules in SQL.

### Phase 3 — Transform into Staging
Run:
- `sql/03_transform_staging.sql`

Outputs:
- Clean, standardized staging tables (email/phone normalization, simple lookups)
- Value mappings (status/statecode, etc.) as examples

### Phase 4 — Load into Target
Run:
- `sql/04_load_target.sql`

Outputs:
- Example inserts
- Example MERGE (UPSERT) pattern using a business key (email) or an external ID

### Phase 5 — Validate Migration
Run:
- `sql/05_validation_checks.sql`

Outputs:
- Before vs after counts
- Orphan relationship checks
- Duplicate checks in target

---

## Assumptions (Demo)
This demo uses simplified, Dynamics-like entities:

Source tables:
- `Source_Account`
- `Source_Contact`
- `Source_Opportunity`

Target tables:
- `Target_Account`
- `Target_Contact`
- `Target_Opportunity`

In a real Dynamics CRM/Dataverse migration, source data may be extracted via:
- SQL Server (if staged/exported)
- Data Export Service / Synapse Link
- CSV exports
- **API (OData/Web API)** (I personally reccomend this)

---

## What I need from a client to scope accurately
1) Source CRM and target CRM (Dynamics → Dynamics? Dynamics → Salesforce? etc.)
2) Number of entities in scope (Accounts/Contacts/Opportunities + Activities/Notes?)
3) Are custom entities/fields involved?
4) History requirements (Activities, Notes, Emails)
5) Extraction method (SQL access, export, API)
6) Identity rules (external IDs, dedupe rules, merge rules)

---

## Files
- `sql/01_profile_source.sql` — profiling + quality checks
- `sql/02_mapping_template.sql` — mapping storage (optional)
- `sql/03_transform_staging.sql` — staging transformations
- `sql/04_load_target.sql` — load patterns (insert + merge)
- `sql/05_validation_checks.sql` — validation + reconciliation
- `docs/mapping_sheet_template.csv` — mapping sheet template
- `docs/sample_output_report.md` — sample summary format

---

## Disclaimer
This toolkit is a starting point. Actual Dynamics CRM implementations typically have:
- Custom entities and fields
- Option sets requiring value mapping
- Multiple lookup relationships
- Many-to-many associations
- Ownership / business unit considerations
