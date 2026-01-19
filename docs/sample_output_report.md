# Migration Summary Report (Sample)

## Scope
- Entities: Account, Contact, Opportunity
- Source extraction method: (TBD)
- Target load method: (TBD)

## Source Profiling Highlights
- Total Accounts: (N)
- Total Contacts: (N)
- Total Opportunities: (N)

### Data Quality Issues
- Contacts missing email: (N / %)
- Duplicate emails: (N)
- Accounts missing name: (N)
- Orphan contacts (missing account link): (N)

## Mapping Decisions
- Contact -> Account relationship keyed by: (ExternalID / AccountName / Other)
- Opportunity -> Account relationship keyed by: (ExternalID / AccountName / Other)
- Status mapping:
  - statecode 0 => Active
  - statecode 1 => Inactive

## Migration Results
- Accounts loaded: (N)
- Contacts loaded: (N)
- Opportunities loaded: (N)
- Failed records logged: (N) (see failure table/log)

## Validation
- Record count reconciliation: PASS/FAIL
- Orphan checks: PASS/FAIL
- Duplicate checks in target: PASS/FAIL

## Open Questions / Risks
- Custom entities: (TBD)
- Activities/Notes/Attachments: (TBD)
- Dedupe rules required: (TBD)
