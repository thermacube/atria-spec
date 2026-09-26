**Atria Engineering Spec 0.3**

**Canonical Data Model**

**1. Purpose, Scope, and Governance**

**1.1 Purpose**

This specification defines the canonical physical data model for Atria.

Its purpose is to:

- represent learner truth durably and unambiguously,

- support deterministic replay and audit,

- enable high-throughput hot paths,

- and remain understandable and operable by developers and DBAs over time.

This document translates the conceptual guarantees of Spec 0.1 and the interaction contracts of Spec 0.2 into concrete tables, keys, and write rules.

**1.2 Scope**

This specification governs:

- canonical relational tables,

- append-only evidence and decision ledgers,

- enrollment context and progression state,

- write-path guarantees and indexing expectations.

It does not define:

- UI models,

- API endpoints,

- deployment topology,

- vendor-specific SQL optimizations.

**1.3 Governance**

This spec is binding.

Any schema or write path that violates this document SHALL NOT be merged.

**2. Core Modeling Principles**

The canonical data model SHALL adhere to the following principles:

- Append-only evidence: facts, claims, decisions, and requests are never mutated

- Single source of truth: canonical learner progression lives in one place

- Reference, not copy: large payloads and external artifacts are referenced

- Hot path predictability: hot path writes are bounded and index-only

- Replay sufficiency: no hidden state is required to explain outcomes

- Tenant isolation: each tenant SHALL have a physically isolated database

**3. Tenant Boundary and Naming**

**3.1 Database-per-Tenant**

Atria SHALL use a database-per-tenant model.

- A single institution and its learners occupy one database.

- Cross-tenant queries are prohibited.

- Tenant isolation SHALL be enforced operationally and at the data layer.

Tenant identifiers MAY still be stored in tables for defense-in-depth and for evidentiary export, but the physical boundary is the database.

**4. Canonical Evidence Ledger**

The evidence ledger is the spine of the entire system.

Every cross-domain interaction that affects learner truth, entitlements, credentials, or replay SHALL be recorded here.

**4.1 Time-Partitioned Evidence Tables**

Evidence SHALL be stored in time-partitioned physical tables.

Example naming convention:

- evidence_2025_12

- evidence_2026_01

A unified view MAY be provided for convenience:

- evidence_all as a view or union across partitions

Hot-path writes SHALL target the current evidence partition only.

Archival MAY relocate old partitions to cheaper storage provided replay guarantees remain intact.

**4.2 Table Template: evidence_YYYY_MM**

**Purpose**  
**Stores immutable FACT, CLAIM, and REQUEST records. DECISION records are stored in the decision ledger and projected into evidence_all.**

**Write Pattern**  
Append-only  
High-write volume  
Hot-path eligible (bounded writes only)

**Columns**

- evidence_id (UUID, PK)

- tenant_id (UUID, indexed, optional defense-in-depth)

- message_type (ENUM: FACT, CLAIM, REQUEST)

- subtype (VARCHAR, indexed)

- subject_id (UUID, indexed)

- enrollment_context_id (UUID, indexed, nullable)

- activity_uuid (UUID, indexed, nullable)

- workflow_version (VARCHAR, nullable)

- occurred_at (TIMESTAMP, indexed)

- recorded_at (TIMESTAMP, indexed)  
  *(DB authoritative insertion time)*

- source_domain (VARCHAR)

- actor_id (UUID, nullable)

- correlation_id (UUID, indexed)

- causation_id (UUID, nullable)

- payload_ref (VARCHAR or JSON pointer)

- payload_hash (BINARY / CHAR, nullable)

- schema_version (VARCHAR)

- confidentiality_level (ENUM)

- retention_class (ENUM)

**Constraints**

- Rows SHALL NOT be updated or deleted except under legal erasure rules.

Evidence partitions SHALL NOT store DECISION rows; DECISION records are stored in the decision ledger and projected into evidence_all for unified querying.

- Ordering for audit and replay SHALL rely on (recorded_at, evidence_id) as the authoritative sequence when needed.

- occurred_at is preserved for semantic timing but SHALL NOT be assumed globally monotonic.

**Indexes (minimum)**

- (subject_id, recorded_at)

- (enrollment_context_id, recorded_at)

- (correlation_id)

- (subtype, recorded_at)

**5. Decision Ledger**

Decisions are evidence, but they warrant a first-class table for hot-path efficiency and clarity.

**5.1 Table: decision**

**Purpose**  
Stores Ordin’s pedagogical decisions with explicit references to evidence.

**Write Pattern**  
Append-only  
Hot path

**Columns**

- decision_id (UUID, PK)

- tenant_id (UUID, optional defense-in-depth)

- enrollment_context_id (UUID, indexed)

- workflow_version (VARCHAR)

- decision_type (ENUM: advance, complete, remediate, suspend, no_op)

- decision_reason (VARCHAR)

- evaluated_evidence_ids (JSON array of UUIDs)

- decided_at (TIMESTAMP, indexed)

- correlation_id (UUID, indexed)

**Constraints**

- Decisions SHALL NOT be updated.

- A decision MUST reference at least one evidence record.

- A decision SHALL be replayable given its evidence set.

**JSON policy**

- JSON SHALL NOT be queried directly on hot paths.

- If specific attributes from evaluated_evidence_ids are required for queries, they SHALL be exposed via generated/indexed columns in a separate decision-evidence join table (preferred) or via precomputed projections.

**6. Enrollment Context**

Enrollment context is the boundary of meaning for learner actions.

**6.1 Table: enrollment_context**

**Purpose**  
Binds a learner to a specific course and workflow version.

**Write Pattern**  
Insert-only  
Low write frequency

**Columns**

- enrollment_context_id (UUID, PK)

- tenant_id (UUID, optional defense-in-depth)

- learner_identity_id (UUID, indexed)

- course_id (UUID, indexed)

- workflow_version (VARCHAR)

- status (ENUM: active, completed, suspended)

- created_at (TIMESTAMP)

- closed_at (TIMESTAMP, nullable)

**Constraints**

- Enrollment contexts are immutable once closed.

- Migration creates a new enrollment_context row.

**7. Canonical Progression State**

This table answers: “Where is the learner right now?”

**7.1 Table: progression_state**

**Purpose**  
Stores the current canonical progression snapshot for an enrollment context.

This is a derived snapshot. The authoritative progression history is the append-only decision table.

**Write Pattern**  
Overwrite on decision  
Hot path  
Single row per enrollment_context

**Columns**

- enrollment_context_id (UUID, PK)

- current_activity_uuid (UUID)

- state_payload (JSON)

- last_decision_id (UUID, FK →decision)

- updated_at (TIMESTAMP)

**Constraints**

- Only Ordin may write this table.

- The decision insert and progression_state update MUST occur in a single DB transaction.

- JSON SHALL NOT be queried directly on hot paths.

  - Hot-path queries SHALL rely on indexed columns and/or generated columns derived from state_payload.

**Index**

- PK on enrollment_context_id only

**8. Requests and Request State Transitions**

Administrative and long-running operations are explicitly modeled.

**8.1 Table: request**

- request_id (UUID, PK)

- tenant_id (UUID, optional defense-in-depth)

- request_type (VARCHAR)

- requested_by (UUID)

- created_at (TIMESTAMP)

**8.2 Table: request_state**

- request_state_id (UUID, PK)

- request_id (UUID, indexed)

- state (ENUM: requested, accepted, in_progress, completed, rejected, failed_retryable, failed_terminal)

- occurred_at (TIMESTAMP)

- evidence_id (UUID, FK reference)

**9. Hot Path Write Guarantees**

For any learner-visible hot path:

- Maximum of one decision insert

- Maximum of one progression_state update

- Optional append to the current evidence_YYYY_MM partition

- All writes MUST occur in a single DB transaction

- No scans, no fan-out, no cross-domain synchronous call chains

Violations SHALL be treated as correctness and availability defects.

**10. Replay Sufficiency Guarantee**

Given:

- evidence partitions (evidence_YYYY_MM / evidence_all)

- decision

- enrollment_context

- progression_state

- immutable content references

Atria SHALL be able to:

- reconstruct the full decision timeline,

- explain why any learner outcome occurred,

- replay workflow execution deterministically.

No additional hidden state is required.

**11. Assessment Model**

**11.1 Purpose**

This section defines canonical relational tables for:

- assessment definitions and versions,

- attempt lifecycles,

- submissions stored by reference,

- scoring outcomes and supersession,

- retake and attempt policy resolution.

This model supports deterministic Ordin decisions based on persisted facts, strict auditability, non-retroactivity, and efficient hot-path operations at scale.

Atria preserves assessment evidence for auditability and replay; it does not itself claim psychometric validity.

**11.2 Assessment Definitions**

Assessment definitions are immutable once published.

**11.2.1 Table: assessment_definition**

**Purpose**  
Represents the conceptual identity of an assessment independent of course context.

**Columns**

- assessment_id (UUID, PK)

- created_by (UUID)

- created_at (TIMESTAMP)

- status (ENUM: draft, published, deprecated)

**Constraints**

- Once published, the conceptual assessment identity remains stable.

- Changes are represented by new version records.

**11.2.2 Table: assessment_version**

**Purpose**  
Stores immutable published versions of an assessment definition.

**Columns**

- assessment_version_id (UUID, PK)

- assessment_id (UUID, indexed, FK)

- version (VARCHAR)

- published_at (TIMESTAMP)

- published_by (UUID)

- definition_ref (VARCHAR pointer to immutable artifact storage)

- definition_hash (BINARY / CHAR)

- standard_type (ENUM: QTI, SCORM, native, other)

- standard_version (VARCHAR, nullable)

- status (ENUM: published, deprecated)

**Constraints**

- Rows are immutable once inserted.

- definition_ref MUST point to an immutable artifact (object store or versioned repository).

**Indexes**

- (assessment_id, version)

- (assessment_id, published_at)

**11.3 Attempts**

Attempts are immutable records of learner interaction, bound to an enrollment context and activity UUID.

**11.3.1 Table: assessment_attempt**

**Purpose**  
Represents a learner attempt within a specific enrollment context.

**Columns**

- attempt_id (UUID, PK)

- enrollment_context_id (UUID, indexed)

- activity_uuid (UUID, indexed)

- assessment_id (UUID, indexed)

- assessment_version_id (UUID, indexed)

- attempt_number (INT)

- status (ENUM: started, submitted, completed, exited, timed_out, invalidated)

- started_at (TIMESTAMP, indexed)

- submitted_at (TIMESTAMP, nullable)

- completed_at (TIMESTAMP, nullable)

- created_by (ENUM: learner, system, admin)

- correlation_id (UUID, indexed)

**Constraints**

- Attempt rows SHALL NOT be deleted.

- attempt_number SHALL be assigned deterministically at creation time and SHALL NOT be inferred later.

- Attempt lifecycle transitions SHALL be recorded as append-only evidence; the status column is a cached projection for query convenience.

**Notes**  
Timeout and lock semantics are derived from attempt status, attempt policy, and timestamps rather than explicit lock tables. Explicit lock tables MAY be introduced only if required for enforcement or performance and must remain consistent with append-only evidence and non-retroactivity.

**Indexes**

- (enrollment_context_id, activity_uuid, started_at)

- (enrollment_context_id, activity_uuid, attempt_number)

- (correlation_id)

**11.3.2 Submission Completeness vs Evaluation Completeness**

Atria distinguishes between:

- **Submission completeness**: the learner has provided all required input and it has been durably recorded.

- **Evaluation completeness**: grading, review, and scoring activities have completed.

Submission completeness SHALL be represented by attempt lifecycle evidence (submitted, completed).  
Evaluation completeness SHALL be represented by scoring and review evidence (AssessmentScoreComputed, AssessmentScoreSuperseded) and SHALL NOT block durable recording of learner submissions.

**11.4 Submissions by Reference**

Large or structured learner submissions SHALL be stored by reference.

**11.4.1 Table: assessment_submission**

**Purpose**  
Stores pointers to immutable submission payloads.

**Columns**

- submission_id (UUID, PK)

- attempt_id (UUID, indexed, FK)

- submitted_at (TIMESTAMP, indexed)

- submission_ref (VARCHAR pointer)

- submission_hash (BINARY / CHAR)

- content_type (VARCHAR)

- bytes (BIGINT)

- schema_version (VARCHAR)

**Constraints**

- Submissions are immutable.

- Corrections or re-uploads SHALL be represented as new submission rows and linked via evidence.

**Indexes**

- (attempt_id, submitted_at)

**11.5 Scores and Supersession**

Scores are append-only records; supersession is explicit and auditable.

**11.5.1 Table: assessment_score**

**Purpose**  
Stores scoring outcomes for attempts.

**Columns**

- score_id (UUID, PK)

- attempt_id (UUID, indexed)

- computed_at (TIMESTAMP, indexed)

- score_value (DECIMAL or JSON pointer for structured scoring)

- score_ref (VARCHAR pointer to full scoring report)

- grading_schema_version (VARCHAR)

- computed_by (ENUM: system, human, mixed)

- is_pass (BOOLEAN, nullable)

- correlation_id (UUID, indexed)

**Constraints**

- Scores are immutable.

- Multiple score rows for a single attempt are expected and legitimate.

**Notes**  
Multiple scores may occur due to:

- human grading or re-grading,

- item invalidation or correction,

- scoring bug fixes or grading schema changes applied via explicit regrade requests.

**Indexes**

- (attempt_id, computed_at)

- (correlation_id)

**11.5.2 Table: assessment_score_supersession**

**Purpose**  
Declares that one score supersedes another while preserving both.

**Columns**

- supersession_id (UUID, PK)

- attempt_id (UUID, indexed)

- superseded_score_id (UUID, indexed)

- superseding_score_id (UUID, indexed)

- reason_code (VARCHAR)

- created_at (TIMESTAMP)

- evidence_id (UUID, nullable)

**Constraints**

- Supersession is append-only.

- Ordin determines which score governs progression based on BPMN and evidence.

**11.6 Retake and Attempt Policy**

Retake rules are resolved in the context of the course workflow.

**11.6.1 Table: activity_attempt_policy**

**Purpose**  
Defines attempt rules for an activity UUID within a specific workflow version.

**Columns**

- policy_id (UUID, PK)

- course_id (UUID, indexed)

- activity_uuid (UUID, indexed)

- workflow_version (VARCHAR, indexed)

- max_attempts (INT, nullable)

- count_rule (ENUM: highest, latest, average, first)

- cooldown_seconds (INT, nullable)

- created_at (TIMESTAMP)

**Constraints**

- Policies are versioned by workflow version and are not retroactive.

**Precedence Rule**

- If BPMN defines retake limits, pass thresholds, or attempt counting rules, **BPMN SHALL govern**.

- If BPMN is silent, Ordin MAY apply QTI-declared policy from the assessment definition as evidence of intended behavior.

**11.7 Hot Path Write Budget for Assessment Completion**

For assessment completion operations, the canonical hot-path budget SHALL be:

- Insert or update attempt lifecycle projection

- Insert submission reference (if applicable)

- Insert score record (if computed synchronously; otherwise emit later)

- Emit evidence fact(s) to the current evidence partition

Under no circumstance shall assessment completion require:

- scanning for attempts,

- synchronous multi-domain call chains,

- or distributed transactions.

**11.8 Required Evidence Subtypes**

The following message subtypes defined in Spec 0.2 Appendix A SHALL be emitted using the canonical model above:

- AssessmentAttemptStarted

- AssessmentAttemptSubmitted

- AssessmentAttemptCompleted

- AssessmentScoreComputed

- AssessmentScoreSuperseded

- RegradeRequested

All evidence MUST be keyed by deterministic identifiers (attempt_id, enrollment_context_id, activity_uuid).

**12. Content Model**

**12.1 Purpose**

This section defines the canonical data model for **learning content**, including:

- conceptual content identity,

- immutable content versions,

- explicit and default resolution mechanisms,

- lifecycle states,

- learner access evidence,

- and publish, migration, and revocation semantics.

Content artifacts in Atria are immutable instructional materials.  
**Content access events are the recorded evidence** that a specific immutable artifact was delivered to a learner in a specific enrollment context.

**12.2 Conceptual Content Identity**

Atria distinguishes between:

- **Content Identity** —the conceptual learning object (LO / SCO)

- **Content Version** —an immutable artifact

- **Content Resolution** —a mechanism for selecting which version is delivered

This separation enables:

- safe updates,

- non-retroactive learner experiences,

- and deterministic replay.

**12.3 Content Identity**

**12.3.1 Table: content**

**Purpose**  
Represents the conceptual identity of a piece of learning content.

**Columns**

- content_id (UUID, PK)

- created_by (UUID)

- created_at (TIMESTAMP)

- content_type (ENUM: html, video, document, package, other)

- status (ENUM: draft, published, archived)

**Constraints**

- Conceptual identity is stable.

- Changes to content are expressed only through new content versions.

**12.4 Content Versions**

Content versions are immutable, addressable artifacts.

**12.4.1 Table: content_version**

**Purpose**  
Stores immutable published versions of content.

**Columns**

- content_version_id (UUID, PK)

- content_id (UUID, indexed)

- version (VARCHAR)

- published_at (TIMESTAMP)

- published_by (UUID)

- artifact_ref (VARCHAR pointer to object storage)

- artifact_hash (BINARY / CHAR)

- bytes (BIGINT)

- mime_type (VARCHAR)

- standard_type (ENUM: CC, SCORM, QTI, native, other, nullable)

- standard_version (VARCHAR, nullable)

- status (ENUM: published, deprecated)

**Constraints**

- Rows are immutable once inserted.

- artifact_ref MUST reference an immutable artifact.

- artifact_hash is retained for integrity verification and storage validation, not as pedagogical identity.

**Indexes**

- (content_id, version)

- (content_id, published_at)

**12.5 Content Resolution**

Resolution determines which content artifact is served for a given request.

Atria supports **two resolution modes**:

- **Explicit version resolution** —the request specifies the exact content version to serve.

- **Default resolution** —the system resolves a “current version”for convenience.

**Explicit version resolution is the normative mechanism for learner delivery.**

**12.5.1 Table: content_resolution (Default Resolution Pointer)**

**Purpose**  
Provides a default “current version”pointer for content identity.

**Columns**

- content_id (UUID, PK)

- current_content_version_id (UUID, indexed)

- updated_at (TIMESTAMP)

- updated_by (UUID)

**Constraints**

- Default resolution updates MUST be atomic.

- Default resolution changes are not retroactive.

- Default resolution affects only future accesses where explicit versioning is not specified.

**Hot Path Notes**

- Default resolution lookups MUST be constant-time and indexed.

- Learner delivery SHOULD use explicit version resolution whenever possible.

**12.6 Content Lifecycle States**

Content moves through explicit lifecycle states:

- Draft

- Published

- Accessed

- Archived

Lifecycle state reflects **system semantics**, not UI convenience.

**12.6.1 Lifecycle Rules**

- Draft content may be edited freely.

- Published content may be versioned but not mutated.

- Once content is **accessed by a learner**, the accessed version is immutable forever.

- Archived content remains accessible for replay but is no longer resolved for new accesses.

**12.7 Learner Content Access Evidence**

Content access is a **first-class pedagogical event**.

**12.7.1 Table: content_access**

**Purpose**  
Records learner-visible delivery of content versions.

**Columns**

- content_access_id (UUID, PK)

- enrollment_context_id (UUID, indexed)

- activity_uuid (UUID, indexed)

- content_id (UUID, indexed)

- content_version_id (UUID, indexed)

- accessed_at (TIMESTAMP, indexed)

- delivery_method (ENUM: direct, proxied, signed_url)

- correlation_id (UUID, indexed)

- artifact_hash (BINARY / CHAR, nullable)

**Constraints**

- Rows are append-only.

- UUID + version identity is sufficient to prove what content was delivered.

- artifact_hash MAY be recorded for integrity verification but is not required for evidentiary identity.

- Access is recorded only when learner-visible delivery occurs (page load, playback start, download).

**Indexes**

- (enrollment_context_id, accessed_at)

- (content_id, content_version_id)

- (correlation_id)

• If content_hash is present, it SHOULD match content_version.artifact_hash for the referenced content_version_id.

• content_version (evidence; optional human-readable version label) is not stored in content_access; it MAY be derived by joining content_access.content_version_id → content_version.version.

Notes:

• content_hash (evidence; optional integrity metadata) → content_access.artifact_hash (nullable)

• accessed_at (evidence) → content_access.accessed_at

• content_version_id (evidence; REQUIRED) → content_access.content_version_id

• content_id (evidence) → content_access.content_id

• activity_uuid (evidence) → content_access.activity_uuid

• enrollment_context_id (evidence) → content_access.enrollment_context_id

Required mapping (normative):

ContentAccessRecorded (FACT), as defined in Spec 0.2 Appendix A, SHALL be emitted for learner-visible delivery and SHALL map 1:1 to a row in content_access.

12.7.2 Evidence Mapping: ContentAccessRecorded

**12.8 Publish Boundary and Atomicity**

Publishing content SHALL follow the rules defined in Spec 0.1 Appendix E.

**12.8.1 Publish Sequence (Normative)**

1.  Artifact is uploaded to object storage.

2.  Artifact hash is computed.

3.  content_version row is inserted.

4.  Default resolution pointer MAY be updated atomically.

5.  ContentVersionPublished (FACT) SHALL be recorded to the current evidence partition (Spec 0.2 Appendix A) as publish evidence.

Evidence mapping (normative): ContentVersionPublished payload fields map 1:1 to content_version as follows:

• content_version_id → content_version.content_version_id

• content_id → content_version.content_id

• version → content_version.version

• artifact_ref → content_version.artifact_ref

• artifact_hash → content_version.artifact_hash

• published_at → content_version.published_at

• published_by → content_version.published_by

If the relational transaction fails, the publish SHALL NOT be considered complete.

Unreferenced artifacts MAY be garbage-collected after a configured TTL.

**12.9 Hot Path Constraints for Content Delivery**

For learner-visible content delivery:

- One indexed lookup to determine the content version (explicit or default)

- One indexed lookup to content_version

- Optional append to content_access

- No synchronous cross-domain calls

- No scans

Learner-facing delivery requests SHOULD reference a specific immutable content version to avoid ambiguity and to minimize dependency on default resolution.

Content delivery MUST NOT block on analytics, logging, or secondary processing.

**12.10 Content and Enrollment Context**

Content access SHALL always be associated with an enrollment_context_id.

This ensures:

- replay correctness,

- non-retroactivity,

- and precise pedagogical interpretation.

Content delivered outside an enrollment context (e.g., author preview) SHALL NOT emit learner access evidence. Authoring actions MAY emit separate edit-only audit records.

**12.11 Content Migration and Legal Constraints**

Content updates and migrations are **administrative operations**, not pedagogical execution.

Atria supports a progressive response to errors or legal requirements:

1.  **Versioning** the content and migrating learners to a new version.

2.  **Tombstoning** a content version, which revokes default resolution and prevents future delivery.

3.  **Legal hold or archival**, preserving access only for replay and audit where required.

Ordin SHALL NOT perform content migration or revocation.

**12.12 Required Evidence Subtypes**

The following message subtypes defined in Spec 0.2 Appendix A SHALL be emitted:

- ContentVersionResolved

- ContentAccessRecorded

- CourseVersionPublished (if applicable)

- EnrollmentMigrated (if applicable)

All evidence MUST reference immutable identifiers.

**13. Identity and Entitlement Model**

**13.1 Purpose**

This section defines the canonical data model for **identity, roles, and entitlements** in Atria.

Its purpose is to:

- establish authoritative identity references,

- model access and permissions explicitly,

- preserve auditability and replay,

- support high-throughput authorization checks,

- and prevent silent or implicit privilege changes.

Identity and entitlement data affect **what actions were permitted at the moment they occurred**, and therefore are **truth-adjacent** and must be modeled explicitly.

**13.2 Identity Principles**

The identity and entitlement model SHALL adhere to the following principles:

- **Single authoritative identity record** per actor

- **Reference, not copy** identity attributes across tables

- **Append-only change history** for identity attributes and permissions

- **Explicit authority sources** for identity changes

- **No retroactive reinterpretation** of historical actions

- **Persisted entitlements** as the authoritative permission source

- **Constant-time authorization checks** on hot paths

**13.3 Identity**

**13.3.1 Table: identity**

**Purpose**  
Represents the authoritative identity of an actor within a tenant.

**Columns**

- identity_id (UUID, PK)

- external_identity_id (VARCHAR, indexed, nullable)

- identity_type (ENUM: learner, instructor, admin, system)

- display_name (VARCHAR)

- email (VARCHAR, nullable)

- status (ENUM: active, suspended, deactivated)

- created_at (TIMESTAMP)

- updated_at (TIMESTAMP)

**Constraints**

- Identity attributes are mutable only for current state.

- Identity attributes SHALL NOT be copied into other tables.

- Historical identity values are preserved in change logs.

- Identity status SHALL NOT retroactively invalidate historical actions.

**Indexes**

- (external_identity_id)

- (identity_type, status)

**13.4 Identity Attribute Change History**

Identity changes are first-class evidence.

**13.4.1 Table: identity_change_log**

**Purpose**  
Records append-only history of identity attribute changes.

**Columns**

- identity_change_id (UUID, PK)

- identity_id (UUID, indexed)

- attribute_name (VARCHAR)

- prior_value_ref (VARCHAR or JSON pointer)

- new_value_ref (VARCHAR or JSON pointer)

- authority_source (ENUM: idp, sis, admin, system)

- changed_at (TIMESTAMP)

- evidence_id (UUID, FK to evidence)

**Constraints**

- Rows are append-only.

- Only declared authority sources MAY change controlled attributes.

- Unauthorized change attempts SHALL be rejected and recorded as evidence.

**Indexes**

- (identity_id, changed_at)

**13.5 Roles**

Roles describe **capability categories**, not permissions.

**13.5.1 Table: role**

**Purpose**  
Defines roles available within a tenant.

**Columns**

- role_id (UUID, PK)

- role_name (VARCHAR, indexed)

- role_scope (ENUM: global, course, activity)

- created_at (TIMESTAMP)

**Constraints**

- Roles are stable identifiers.

- Roles SHALL NOT directly authorize actions.

- Changes to role meaning SHALL be handled via entitlement policy, not mutation.

**13.6 Role Assignment**

Role assignments are explicit and auditable.

**13.6.1 Table: role_assignment**

**Purpose**  
Assigns roles to identities, optionally scoped.

**Columns**

- role_assignment_id (UUID, PK)

- identity_id (UUID, indexed)

- role_id (UUID, indexed)

- scope_type (ENUM: tenant, course, activity)

- scope_id (UUID, nullable)

- assigned_at (TIMESTAMP)

- assigned_by (UUID)

- revoked_at (TIMESTAMP, nullable)

**Constraints**

- Assignments are append-only; revocation is explicit.

- Absence of revoked_at indicates active assignment.

- Role assignment history SHALL be preserved indefinitely.

**Indexes**

- (identity_id, role_id, revoked_at)

- (scope_type, scope_id)

**13.7 Entitlements**

Entitlements define **permission to perform an action in a context**.

**13.7.1 Table: entitlement**

**Purpose**  
Represents a granted capability within a defined scope.

**Columns**

- entitlement_id (UUID, PK)

- identity_id (UUID, indexed)

- entitlement_type (ENUM: view_content, submit_assessment, grade_assessment, issue_credential, admin_override)

- scope_type (ENUM: tenant, course, enrollment_context, activity)

- scope_id (UUID)

- granted_at (TIMESTAMP)

- granted_by (UUID)

- revoked_at (TIMESTAMP, nullable)

- evidence_id (UUID, FK)

**Constraints**

- Entitlements are append-only.

- Revocation SHALL NOT delete prior grants.

- Effective entitlements are those with revoked_at IS NULL.

**Indexes**

- (identity_id, entitlement_type, revoked_at)

- (scope_type, scope_id)

**13.8 Enrollment and Entitlement Materialization**

Enrollment contexts SHALL result in **materialized entitlements** persisted in the entitlement table.

- When an enrollment context becomes active, the system SHALL create the required entitlements (e.g., view_content, submit_assessment, progress_course).

- When an enrollment context is suspended or closed, the system SHALL explicitly revoke those entitlements.

- Entitlements SHALL NOT exist only as in-memory derivations.

Caching MAY be used for performance, but the authoritative source of entitlements is the persisted table.

**13.9 Authorization Checks (Hot Path)**

Authorization checks are hot-path operations and MUST be efficient.

**Rules**

- Authorization MUST be resolvable with a bounded number of indexed lookups.

- No scans.

- No iteration over unbounded result sets.

Authorization SHOULD require no more than:

- one indexed lookup on identity (status),

- one indexed lookup on entitlement (identity_id + entitlement_type + scope),

- optionally one indexed lookup on role_assignment where roles grant entitlements.

Complex policy logic SHALL be precomputed into entitlements outside hot paths.

**13.10 Entitlement Conflict Resolution**

Authorization conflicts SHALL be resolved deterministically.

**Default precedence rule**

- The most specific scope takes precedence:

  - activity \> enrollment_context \> course \> tenant

**Revocation precedence**

- A revocation at a scope overrides grants at the same scope.

This rule MAY be refined based on formal systems evaluation but SHALL remain deterministic and testable.

**13.11 Identity and Ordin**

Ordin SHALL:

- consume identity and entitlement facts as evidence,

- but SHALL NOT mutate identity, roles, or entitlements.

Identity and entitlement changes are **administrative operations**, not pedagogical execution.

**13.12 System Actors**

System actors (identity_type = system) are first-class identities.

- System actors MAY hold roles and entitlements.

- All actions performed by system actors SHALL be auditable.

- System actors SHALL have narrowly scoped entitlements appropriate to their function.

**13.13 Identity Suspension and Deactivation**

- **Suspended** identities SHALL NOT perform new actions.

- **Deactivated** identities SHALL be fully disabled.

Historical actions remain valid, replayable, and auditable regardless of current identity status.

**13.14 Required Evidence Subtypes**

The following message subtypes defined in Spec 0.2 Appendix A SHALL be emitted:

- IdentityAttributeChanged

- RoleAssigned

- RoleRevoked

- EntitlementGranted

- EntitlementRevoked

All authorization-relevant changes SHALL be preserved as evidence.

**Revision 0.3.1 Addendum (Normative)**

Date: 2025-12-16

This addendum amends Atria Engineering Spec 0.3 (Canonical Data Model). Where this addendum conflicts with earlier sections of the document, the requirements in this addendum SHALL take precedence.

**0.3.1-1 Enrollment Context Subject Identifier Correction**

Enrollment context SHALL reference the learner via learner_identity_id (UUID, indexed), which SHALL reference identity(identity_id) where identity.identity_type = 'learner'.

• enrollment_context.learner_identity_id (UUID, indexed).

• learner_identity_id SHALL reference identity(identity_id) where identity.identity_type = 'learner'.

Amended enrollment_context columns (only affected fields shown):

• learner_identity_id (UUID, indexed).

**0.3.1-2 Entitlement Type Enum Consistency Fix**

The entitlement_type ENUM is amended to include the course progression entitlement referenced elsewhere in the spec.

• Add 'progress_course' to entitlement.entitlement_type ENUM.

Updated entitlement_type (minimum set):

• view_content, submit_assessment, grade_assessment, issue_credential, progress_course, admin_override

**0.3.1-3 Evidence References and Time-Partition Reality**

Because evidence records are stored in time-partitioned physical tables (evidence_YYYY_MM), relational foreign keys to evidence records are not reliably enforceable. All columns described as 'FK to evidence' are amended to be logical references instead.

• Any column named evidence_id SHALL be treated as a logical reference to an evidence ledger record id, not an enforced relational FK.

• Referential integrity between evidence_id references and the evidence ledger SHALL be enforced via contract tests and replay verification tooling (Spec 0.2 testing requirements).

• If a tenant requires DB-enforced FKs, an optional evidence_index table MAY be introduced, but this is non-normative and must not violate hot-path write budgets.

**0.3.1-4 Evidence Payload Storage Clarification (Inline vs By-Reference)**

The evidence_YYYY_MM template is amended to support hybrid payload storage.

• Add column: payload_json (JSON, nullable) for inline payloads.

• payload_json SHALL be used when the serialized payload is \<= 32 KiB.

• If payload_json is omitted, payload_ref + payload_hash MUST be present.

• payload_hash MUST use the system-standard hash algorithm and MUST cover the exact bytes of the stored payload.

This amendment aligns the evidence ledger with Spec 0.2 envelope payload rules.

**0.3.1-5 Decisions as Evidence Without Dual Writes**

To avoid redundant storage and hot-path write amplification, the decision table is the canonical store for DECISION records.

• DECISION messages SHALL be persisted to the decision table only (canonical).

• An evidence_all view (or equivalent query abstraction) SHALL present decisions as evidence records for audit/replay purposes.

• Hot paths SHALL NOT require inserting a duplicate DECISION row into evidence_YYYY_MM partitions.

• The authoritative commit for learner-visible progression changes remains: decision insert + progression_state update in one DB transaction.

**0.3.1-6 Deterministic Attempt Number Allocation (No Scans)**

To satisfy attempt_number determinism while preserving 'no scans' hot-path constraints, the assessment subsystem SHALL allocate attempt_number using an explicit per-(enrollment_context_id, activity_uuid) counter row.

Add table: assessment_attempt_counter

• enrollment_context_id (UUID, PK part)

• activity_uuid (UUID, PK part)

• next_attempt_number (INT) -- the next number to allocate

• updated_at (TIMESTAMP)

Allocation rule (normative):

• On attempt creation, atomically increment next_attempt_number and assign attempt_number = prior next_attempt_number value. This operation MUST be constant-time and MUST NOT query MAX(attempt_number).

**0.3.1-7 Minimal Course, Workflow Definition, and Activity Catalog Tables**

Spec 0.3 is amended to include minimal canonical tables required to ground course_id, workflow_version, and activity_uuid in durable storage.

Add table: course

• course_id (UUID, PK)

• created_at (TIMESTAMP)

• created_by (UUID)

• status (ENUM: draft, published, archived)

Add table: workflow_definition

• workflow_definition_id (UUID, PK)

• course_id (UUID, indexed)

• workflow_version (VARCHAR, indexed)

• bpmn_ref (VARCHAR pointer to immutable artifact storage)

• bpmn_hash (BINARY/CHAR)

• published_at (TIMESTAMP)

• published_by (UUID)

Add table: activity

• activity_uuid (UUID, PK)

• activity_type (ENUM: content, assessment, external_tool, other)

• created_at (TIMESTAMP)

• created_by (UUID)

Add table: workflow_activity_map

• workflow_definition_id (UUID, indexed)

• activity_uuid (UUID, indexed)

• bpmn_node_id (VARCHAR) -- stable node id in BPMN

• PRIMARY KEY(workflow_definition_id, activity_uuid)

These tables do not prescribe authoring UI; they only provide canonical storage and referential anchors for execution and audit.

**0.3.1-8 Legal Hold and Erasure Actions (Minimal Mechanism)**

Spec 0.3 references legal erasure rules but does not define minimal mechanics. The following minimal tables and rules are added.

Add table: legal_hold

• legal_hold_id (UUID, PK)

• subject_id (UUID, indexed)

• hold_scope (ENUM: tenant, course, enrollment_context, global)

• scope_id (UUID, nullable)

• reason_code (VARCHAR)

• created_at (TIMESTAMP)

• created_by (UUID)

• released_at (TIMESTAMP, nullable)

Add table: erasure_action

• erasure_action_id (UUID, PK)

• subject_id (UUID, indexed)

• action_type (ENUM: tombstone, anonymize, delete_payload_only)

• requested_at (TIMESTAMP)

• performed_at (TIMESTAMP, nullable)

• performed_by (UUID)

• evidence_id (UUID, logical reference)

Rule: Evidence rows remain append-only. Erasure SHALL be represented as new evidence and/or erasure_action records. Payload erasure (where legally required) SHALL preserve hashes/metadata sufficient to keep decision replay semantically valid, unless prohibited by law.

Revision 0.3.2 Addendum (Normative)

Date: 2025-12-16

This addendum amends Atria Engineering Spec 0.3 (Canonical Data Model). Where conflicts exist, the requirements in this addendum SHALL take precedence.

0.3.2-1 Activity Resolution Table (Workflow → Runnable Binding)

Spec 0.3 is amended to add a minimal activity resolution table that binds a workflow-defined activity_uuid to a concrete runnable target for a given published workflow_definition. This enables constant-time activity launch and deterministic replay without BPMN parsing on hot paths.

Add table: activity_resolution

• workflow_definition_id (UUID, indexed) -- references workflow_definition.workflow_definition_id

• activity_uuid (UUID, indexed) -- references activity.activity_uuid

• resolution_type (ENUM: content, assessment, external_tool, other)

• content_version_id (UUID, nullable) -- references content_version.content_version_id

• assessment_version_id (UUID, nullable) -- references assessment_version.assessment_version_id

• tool_ref (VARCHAR, nullable) -- stable tool/deployment reference (e.g., LTI deployment id)

• created_at (TIMESTAMP)

• created_by (UUID)

• PRIMARY KEY(workflow_definition_id, activity_uuid)

Constraints (Normative)

• Exactly one of content_version_id, assessment_version_id, tool_ref SHALL be non-null consistent with resolution_type.

• activity_resolution rows are immutable after insertion. New bindings require publishing a new workflow_definition (new workflow_version).

Publish Rule (Normative)

On publishing a workflow_definition, the system MUST populate workflow_activity_map and activity_resolution for every UserTask (activity_uuid) referenced in the BPMN definition. HTTP activity launch endpoints MUST resolve runnable targets exclusively via these tables.
