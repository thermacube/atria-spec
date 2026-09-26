Standards Version and Conformance Registry 0.1

*Pinned interoperability standards, versions, profiles, and required tests*

Revision: 0.1 (2025-12-16)

Status: Draft (binding once accepted into the Thermacube/Atria spec set).

**1. Purpose**

Atria Engineering Spec 0.2 requires a versioned, explicit registry of supported standards. This document pins exact versions/profiles and defines what conformance means for each surface (ingest, export, and runtime).

**2. Policy**

• Each standard MUST be pinned to an exact version (and profile, where applicable).

• Support MUST be stated per surface: Import, Export, Runtime/Launch.

• A standard is considered 'supported' only when: (a) implementation exists, (b) automated conformance tests exist, and (c) at least one reference fixture suite passes.

• Upgrades to versions MUST be additive and non-breaking where possible; breaking changes require a new major platform release and explicit migration guidance.

**3. Registry Table (Pinned Versions)**

|                   |                                 |                                  |                          |                                                     |                                                                      |
|-------------------|---------------------------------|----------------------------------|--------------------------|-----------------------------------------------------|----------------------------------------------------------------------|
| Standard          | Pinned Version / Profile        | Surface                          | MVP (v0)                 | Conformance Requirement                             | Notes                                                                |
| LTI Core          | 1.3 Final                       | Runtime/Launch                   | YES                      | JWT/OIDC, platform launch validation fixtures       | Tool Consumer (Platform) role; supports LTI Advantage services below |
| LTI Deep Linking  | 2.0 (v2p0)                      | Runtime/Launch                   | YES                      | Deep link request/response fixtures                 | Instructor selects tool content items                                |
| LTI NRPS          | 2.0 (v2p0)                      | Import (roster via LTI)          | YES                      | NRPS membership retrieval fixtures                  | Roster scoped to LTI context                                         |
| LTI AGS           | 2.0 (v2p0)                      | Export (grades to tool/platform) | YES                      | LineItem/Score service fixtures                     | Grade passback                                                       |
| OneRoster         | 1.2                             | Import                           | YES (CSV); REST optional | CSV import fixtures; REST API fixtures (if enabled) | Roster ingestion from SIS                                            |
| Caliper Analytics | 1.2                             | Export                           | NO (v1)                  | Profile-based event validation fixtures             | Analytics export from Atria                                          |
| QTI               | 3.0 Final Release               | Import/Export/Runtime            | NO (v1)                  | QTI package fixtures + item rendering test suite    | Implement subset first (MCQ, short answer, etc.)                     |
| Common Cartridge  | 1.3 Final                       | Import/Export                    | NO (v1)                  | Round-trip import/export fixtures                   | Packaging course materials                                           |
| SCORM             | 1.2                             | Runtime/Launch                   | NO (v1)                  | Runtime API conformance harness                     | SCORM player and tracking                                            |
| SCORM             | 2004 4th Edition                | Runtime/Launch                   | NO (v2)                  | Sequencing/navigation conformance harness           | Higher complexity than 1.2                                           |
| xAPI              | 1.0.3 (legacy) - v0 target      | Import/Export                    | NO (v1)                  | Statement validation fixtures                       | Common ecosystem baseline                                            |
| xAPI              | 2.0 (future target)             | Import/Export                    | NO                       | Statement validation fixtures                       | Track for later adoption                                             |
| cmi5              | Quartz, 1st Edition (June 2016) | Import/Runtime                   | NO (v2)                  | cmi5 package + xAPI statement profile fixtures      | Profile on top of xAPI                                               |
| Open Badges       | 3.0 (v3p0)                      | Export (credential issuance)     | NO (v1)                  | OB 3.0 assertion validation + VC checks             | Verifiable credentials alignment                                     |
| CLR Standard      | 2.0 (v2p0)                      | Export                           | NO (v2)                  | CLR validator fixtures                              | Comprehensive learner record export                                  |
| CASE              | 1.1                             | Import/Export                    | NO (v2)                  | CASE API fixtures                                   | Competency/standards exchange                                        |

**4. Change Control**

• Any change to MVP (v0) support must be approved with a migration plan.

• Registry updates must include: pinned version, test fixtures, and rollout plan.

**5. References (non-normative)**

This registry is anchored on the publicly published specifications from 1EdTech/IMS Global and ADL/AICC projects. See citations in the project repository readme for canonical links.
