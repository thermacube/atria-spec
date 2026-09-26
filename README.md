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

## Specification authority

The specification set is intentionally split by role:

- **Engineering specifications** define Atria platform and module architecture.
- **Machine-readable contracts** define schemas, OpenAPI surfaces, and SQL baselines used to verify implementations.
- **Governance documents** define stewardship, project posture, deployment expectations, partner participation, and open-source posture.
- **History** preserves superseded or older specification lines for traceability; historical files are not automatically current authority.

The current supplied Atria constitutional engineering line culminates in `Atria_Engineering_Spec_0.3_Revised_0.3.6.md`. Earlier 0.1/0.2 documents remain part of the governing lineage and should be read together where later documents build on them.

The shared **Application Request Perimeter Specification v1.0** and Atria adoption document are maintained alongside these governing specifications and apply to the Atria runtime boundary.

See `SPECIFICATION-INDEX.md` for the imported specification inventory and authority notes.
