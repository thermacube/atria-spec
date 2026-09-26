# Atria Specifications

This repository is the canonical, versioned specification set for the Atria majestic monolith and its modules.

Atria is composed of multiple bounded modules. Some modules are maintained in their own repositories and some remain within the Atria application repository, but all Atria modules are governed by the applicable specifications maintained here.

## Repository structure

- `engineering/` — constitutional Atria engineering specifications and module engineering specifications.
- `governance/` — project, stewardship, partner-community, deployment, and open-source governance documents.
- `contracts/` — machine-readable OpenAPI, JSON Schema, and SQL migration/reference contracts.
- `history/` — preserved historical specification/source snapshots that are no longer the current implementation baseline.
- `SOURCE-MANIFEST.md` — provenance and checksums for imported source documents.

Implementation repositories should identify the exact Atria specification baseline/revision they implement rather than copying governing specifications into each repository.
