# Atria Specification Index

This index describes the governing material currently preserved in `thermacube/atria-spec`.

## Platform engineering specifications

- `engineering/Atria_Engineering_Spec_0.1_Revised_0.1.2.md`
- `engineering/Atria_Engineering_Spec_0.2_Revised_0.2.6.md`
- `engineering/Atria_Engineering_Spec_0.3_Revised_0.3.6.md` — latest supplied constitutional engineering revision
- `engineering/Thermacube_Tech_Architecture_2025_(Revised_Addendum).md`
- `engineering/HTTP_API_and_HTMX_Interaction_Spec_0.1.3.md`
- `engineering/Tenancy_Control_Plane_Spec_0.1.2.md`
- `engineering/Artifact_Storage_and_Reference_Spec_0.1.md`
- `engineering/Standards_Version_and_Conformance_Registry_0.1.md`
- `engineering/Application_Request_Perimeter_Spec_1.0.md`
- `engineering/Application_Request_Perimeter_Adoption_Atria_1.0.md`
- `engineering/Application_Accessibility_Spec_1.0.md`
- `engineering/Application_Accessibility_Adoption_Atria_1.0.md`
- `engineering/Application_UI_Design_Spec_1.0.md`

## Module engineering specifications

### Ordin

- `engineering/Ordin_BPMN_Execution_Spec_0.1.2.md`
- Source-note: the supplied filename identifies 0.1.2 while the internal revision line still states 0.1.1. The discrepancy is preserved, not silently corrected.

### Quorum

- `engineering/quorum/README.md`
- `engineering/quorum/Thermacube_AI_Platform_Roadmap.md`
- `engineering/quorum/OpenAI_Compatible_Facade_Swagger_Spec.md`
- `contracts/quorum/spec/quorum-platform.openapi.yaml`
- `contracts/quorum/spec/openai-compat.openapi.yaml`
- `contracts/quorum/schemas/*.schema.json`

The supplied Quorum contracts identify a v0.1.0 API baseline.

### Arbitis / Rights-ReBAC

Current implementation authority is maintained with the Atria implementation's Arbitis module, presently later than v1.3.0.

The supplied v1.3.0 package is preserved for lineage under:

- `history/arbitis-v1.3.0/`

Historical preservation does not supersede the current Arbitis implementation/specification line.

## Atria machine-readable contracts

The `contracts/atria/` directory contains:

- canonical/core SQL and evidence migrations/views;
- Atria OpenAPI 0.1.2;
- evidence/event JSON Schemas;
- the schema index and common envelope.

These files remain native text rather than being converted to prose.

## Governance

The `governance/` directory contains:

- Atria Partner Community Definition
- Atria Project Governance & Open Source Position Paper
- Atria Project Posture
- Atria Stewardship Agreement
- Thermacube × Atria Deployment Requirements

These documents govern project/stewardship/deployment relationships; they do not silently override technical invariants in the engineering specifications.

## Provenance

`SOURCE-MANIFEST.md` records SHA-256 checksums and byte counts for the supplied source material. Human-readable RTF/DOCX material is stored here as normalized Markdown for meaningful Git diffs. Native YAML, JSON, SQL, and other text contracts are preserved as native formats.
