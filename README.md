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

The shared **Application Accessibility Specification v1.0** establishes WCAG 2.2 Level AA as the common product target, with WAI-ARIA 1.2 semantics, ARIA APG implementation guidance, and WCAG-EM 2.0 evaluation methodology. Atria's adoption document defines platform/module responsibilities.

The shared **Application UI Design Specification v1.0** defines Thermacube Minimal UI (TMUI): semantic HTML, locally owned CSS/tokens/assets, HTMX-driven progressive interaction, minimal JavaScript, zero uncontrolled remote UI dependencies, and a compact cross-application visual language. Its reference implementation lives in `thermacube/tmui`.

See `SPECIFICATION-INDEX.md` for the imported specification inventory and authority notes.


The shared **HTMX Integration Specification v1.0** defines the cross-application hypermedia contract: locally pinned HTMX, semantic links/forms, progressive enhancement, server-rendered HTML, truthful canonical URLs/history, coherent fragment swaps, minimal client state, accessibility-aware focus/loading/live-region behavior, and server-authoritative security/domain outcomes.

The shared **Application Information Architecture & Screen Layout Specification v1.0** defines the Thermacube application shell and information hierarchy: task-oriented navigation, high-information-scent labels, brand/global-utility placement, search hierarchy, account and Comms placement, notification hierarchy, page structure, optional local navigation, responsive behavior, landmarks, and minimal footer conventions.


The shared **Application Internationalization & Localization Specification v1.0** defines the cross-application multilingual contract: Unicode/UTF-8, BCP 47 locale identity, language/direction metadata, RTL/logical layout, locale selection and persistence, server-side message catalogs, CLDR-compatible plural/date/number/currency semantics, localized accessibility metadata, HTMX locale consistency, pseudo-localization/text-expansion testing, and local/versioned translation assets.
