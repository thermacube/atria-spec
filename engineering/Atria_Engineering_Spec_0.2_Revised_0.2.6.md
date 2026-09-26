**Atria Engineering Spec 0.2**

**Domain Interfaces and Contracts**

**1. Purpose, Scope, and Governance**

**1.1 Purpose**

This document defines the interfaces and contracts by which Atria’s bounded domains communicate.

Its purpose is to:

- preserve the constitutional guarantees of Spec 0.1,

- prevent accidental cross-domain coupling,

- enable high throughput and high availability by design,

- and make domain interactions testable, auditable, and maintainable.

**1.2 Scope**

This specification governs:

- domain-to-domain interface contracts,

- event and message semantics (facts, claims, decisions, requests),

- synchronous vs asynchronous boundaries,

- idempotency, ordering, retry behavior, and backpressure,

- security and validation requirements on interfaces,

- performance and HA guardrails required to support large concurrency.

It does not define:

- concrete schema/table layouts (Spec 0.3),

- deployment topology details (Ops/HA docs),

- UI component-level behavior (UI spec).

**1.3 Normative Language**

The key words SHALL, SHALL NOT, SHOULD, SHOULD NOT, and MAY are to be interpreted as described in RFC 2119.

**1.4 Governance**

This spec has binding authority for all inter-domain integration work. Any interface that violates this spec SHALL NOT be merged.

**2. Interface Philosophy and Non-Negotiables**

**2.1 Interface Principles**

All domain interfaces SHALL satisfy:

- Explicitness: interactions are visible as contracts, not “side effects”

- Minimality: domains exchange the smallest necessary information

- Sovereignty: no domain mutates another domain’s internal state

- Auditability: domain interactions leave evidence (facts/requests/decisions)

- Determinism: Ordin decisions reference exact input fact IDs and evaluated conditions

- Idempotency: repeated delivery must not duplicate effects

**2.2 Prohibited Interaction Patterns**

The following are prohibited:

- Cross-domain direct writes into another domain’s persistence layer

- Chatty synchronous RPC chains across multiple domains on learner hot paths

- Distributed transactions spanning multiple domains or stores

- Inferring canonical learner state from analytics, caches, or external systems

- UI-driven mutation that bypasses domain contracts

- Silent failure, speculative acknowledgement, or “best-effort”progression

**3. Performance and HA Guardrails**

**3.1 Hot Path Definition**

The following are “hot path”operations and SHALL be engineered for high throughput and low tail latency:

- Learner progression transitions (Ordin decisions and canonical state updates)

- Assessment submission completion

- Content resolution and delivery authorization

- Authentication and authorization checks for learner operations

**3.2 Hot Path Contract Requirements**

Hot path interactions SHALL adhere to:

- One synchronous authoritative commit path for canonical progression (Ordin + relational store)

- All other domain interactions SHOULD be asynchronous facts, not blocking calls

- Synchronous calls on hot paths MUST be bounded and constant-time in complexity

- Retry behavior MUST be idempotent and MUST NOT amplify writes

**3.3 Backpressure and Overload**

All inbound interfaces SHALL implement:

- backpressure or admission control,

- tenant-aware throttling,

- bounded queues (or durable ingress buffering),

- explicit overload responses.

No interface may accept unbounded load in memory.

**3.4 Availability Posture**

- Learner-facing correctness SHALL be preserved under partial failure by pausing, not guessing.

- Interfaces MUST be designed to degrade by isolating failures per domain and per tenant.

- Durable ingress buffering MAY be used, but acknowledgement semantics MUST remain strict.

**3.5 Hot Path Constraint**

A Hot Path is any learner- or system-initiated operation that:

- occurs at high frequency under concurrent load,

- directly affects canonical learner progression or learner-visible correctness,

- and must complete with strong consistency guarantees.

Examples include, but are not limited to:

- learner progression transitions evaluated by Ordin,

- assessment submission completion,

- return-from-assessment transitions,

- content resolution and entitlement checks,

- authentication and authorization for learner actions.

For all Hot Path operations, the following constraints SHALL apply:

- The operation SHALL perform **bounded, constant-time work** with respect to tenant size, course size, and user count.

- The operation SHALL NOT perform synchronous call chains across multiple domains.

- The operation SHALL rely only on:

  - indexed relational lookups,

  - immutable references,

  - and canonical state owned by the executing domain.

<!-- -->

- The operation SHALL execute a **single authoritative commit** for canonical state changes.

- All additional domain coordination SHALL occur via asynchronous facts or requests.

- The operation SHALL be idempotent.

Each Hot Path endpoint SHALL explicitly declare:

- required indexed lookup keys,

- maximum synchronous domain calls (typically zero),

- maximum number of database writes,

- idempotency key semantics,

- and maximum payload size.

Violations of Hot Path constraints SHALL be treated as correctness and availability defects.

**4. Canonical Interaction Types**

**4.1 Synchronous Interfaces**

Synchronous interfaces MAY be used only when:

- the caller requires an immediate authoritative answer, and

- the callee can respond without chaining to other domains.

Synchronous interfaces SHALL:

- be idempotent where applicable,

- enforce strict timeouts,

- fail fast and loudly,

- never perform hidden multi-domain coordination.

**4.2 Asynchronous Interfaces**

Asynchronous interfaces are the preferred mechanism for cross-domain interactions.

Asynchronous delivery SHALL:

- be idempotent,

- tolerate duplicates,

- preserve ordering where required by contract,

- include stable identifiers and correlation IDs.

**4.3 Request Interfaces**

Requests are used when:

- an operation has a lifecycle (Spec 0.1 Appendix F),

- or when fulfillment is performed outside Ordin.

Requests SHALL have explicit state transitions recorded as facts.

**4.4 Fact and Claim Interfaces**

Domains publish facts and claims. Ordin interprets them under BPMN and produces decisions.

Facts and claims SHALL never directly mutate canonical progression state.

**4.5 Decision Interfaces**

Decisions are produced only by Ordin and SHALL be recorded append-only.

Decisions MAY emit downstream requests (e.g., “IssueCredentialRequested” but SHALL NOT directly write into other domains’internal state.

**4.6 Synchronous Execution vs Asynchronous Coordination**

In Atria, **synchronous execution** and **asynchronous coordination** are distinct concepts.

- Individual HTTP requests and function calls MAY execute synchronously.

- Inter-domain coordination SHALL be considered asynchronous if:

  - no domain waits on another domain’s execution to proceed,

  - and coordination occurs exclusively via persisted facts, claims, or requests.

For example:

- A learner posting answers to the QTI runtime is synchronous execution.

- The QTI runtime writing attempt data to the database is evidence publication.

- Ordin evaluating that data on a later learner request is asynchronous coordination.

Ordin SHALL coordinate with other domains via persisted evidence and enrollment context, not via direct synchronous calls.

**5. Standard Message Envelope**

All cross-domain messages (facts, claims, requests, decisions) SHALL use a common envelope.

**5.1 Required Envelope Fields**

Each message SHALL include the following envelope fields. Fields marked “(nullable)” MUST be present but MAY be null when not applicable.

- • message_id (UUID)

- • message_type (ENUM: FACT, CLAIM, REQUEST, DECISION)

- • subtype (string; domain-defined; versioned)

- • tenant_id (UUID)

- • subject_id (UUID; identity_id of the message subject. Usually learner identity_id; for tenant lifecycle facts subject_id = tenant_id)

- • enrollment_context_id (UUID; nullable; explicit scope field)

• workflow_version (string; nullable; explicit scope field)

• activity_uuid (UUID; nullable; explicit scope field)

• course_id (UUID; nullable; explicit scope field)

- • occurred_at (timestamp)

- • recorded_at (timestamp)

- • source (string; emitting domain/service + actor/integration identifier)

- • correlation_id (UUID; ties a chain of related events/requests)

- • causation_id (UUID; nullable; immediate triggering message_id)

- • payload (JSON object; nullable; inline MUST be \<= 32 KiB after serialization. If null, payload_ref and payload_hash are required.)

- • payload_ref (string; nullable; pointer to immutable artifact storage/object storage)

• payload_hash (string; nullable; required when payload_ref is present; MUST use the system-standard hash algorithm)

• schema_version (string or integer; version of the subtype schema)

Deprecated: scope (opaque object) SHALL NOT be emitted. If received, implementations MUST map it to the explicit scope fields above.

**5.2 Optional Fields**

• actor_id (UUID; identity_id of the actor; nullable)

- • idempotency_key (string/UUID) if message_id is not sufficient

- • confidentiality_level (public, internal, restricted)

- • retention_class (standard, long-term, legal-hold)

- • signature or integrity hash (where required)

**6. Idempotency, Ordering, Retries, and Duplicates**

**6.1 Idempotency**

All inbound operations that can be retried SHALL be idempotent.

Idempotency SHALL be achieved via:

- message_id uniqueness and dedupe tables, or

- explicit idempotency_key with bounded retention.

**6.2 Ordering**

Where ordering matters, the contract SHALL specify:

- ordering key (e.g., execution_id, enrollment_id, attempt_id)

- monotonic sequence expectations (if any)

- out-of-order handling policy (store but defer vs store and reject)

Ordin SHALL not apply facts to progression if ordering or applicability is ambiguous.

**6.3 Retries**

Retries SHALL:

- preserve message_id and correlation_id,

- not create new side effects,

- not fan out into multiple requests.

**6.4 Duplicate Handling**

Duplicates SHALL be recorded as evidence where useful but SHALL NOT change canonical outcomes.

**7. Security Requirements for Interfaces**

**7.1 Authentication and Authorization**

All interfaces SHALL enforce:

- tenant isolation,

- least privilege,

- explicit authorization for operations.

Internal domain-to-domain interfaces SHALL authenticate callers and authorize actions by role/service identity.

**7.2 Input Validation**

All inbound payloads SHALL be validated against:

- declared schema_version,

- required fields,

- size limits,

- allowed character sets,

- and semantic constraints where applicable.

Invalid payloads SHALL be rejected and recorded as evidence where required.

**7.3 Confidentiality and Logging**

Interfaces SHALL:

- avoid logging secrets or bearer tokens,

- support redaction policies,

- classify sensitive fields,

- maintain auditable traces without leaking confidential data.

**8. Domain Contracts**

**8.1 Workflow Runtime (Ordin) Contracts**

**8.1.1 Inputs Accepted by Ordin**

Ordin consumes facts and claims relevant to active workflow execution:

- AssessmentAttemptCompleted

- AssessmentScoreComputed

- ContentAccessRecorded

ToolLaunchCompleted

- ToolCompletionClaimReceived (LTI/xAPI)

- ManualOverrideRequested

- EnrollmentMigrated (administrative fact)

- IdentityAttributeChanged (non-pedagogical, may affect display/reporting)

Ordin SHALL treat all inbound data as assertions and SHALL interpret them under BPMN.

**8.1.2 Ordin Outputs**

Ordin produces:

- DecisionRecorded (append-only)

- ProgressionStateUpdated (canonical)

- DomainActionRequested (optional request to other domains)

Ordin SHALL NOT:

- call other domains synchronously on hot paths except for constant-time lookups that do not chain further.

**8.1.3 Decision Recording Contract**

Every decision SHALL reference:

- exact input fact IDs,

- workflow version,

- evaluated conditions,

- outcome.

**8.1.4 ReturnFromQTI Contract**

**8.1.4.1 Purpose**

This contract governs how a learner returns from the QTI runtime to the main course path. Ordin SHALL coordinate with the QTI runtime via **persisted facts and enrollment context**, not direct synchronous calls.

Each user request is synchronous, but inter-domain coordination is asynchronous and evidence-driven.

**8.1.4.2 Trigger**

The learner completes or exits a QTI assessment experience and clicks a “Return to Course”link or button that sends a request to Ordin.

**8.1.4.3 Inputs**

The ReturnFromQTI request SHALL include:

- tenant_id (UUID)

- enrollment_context_id (UUID)

- activity_uuid (UUID)

- qti_attempt_id (UUID) or attempt_reference (stable identifier)

- correlation_id (UUID)

- message_id (UUID) for idempotency

- optional: return_reason (completed, exited, timed_out, error)

The request MUST NOT rely on “latest attempt for this learner”heuristics.

**8.1.4.4 Preconditions**

Ordin SHALL require that QTI runtime completion has produced persisted evidence accessible by deterministic keys.

At minimum, the system SHALL have recorded a fact equivalent to:

- AssessmentAttemptCompleted(enrollment_context_id, activity_uuid, qti_attempt_id, occurred_at, payload)

- and optionally AssessmentScoreComputed(enrollment_context_id, activity_uuid, qti_attempt_id, score, occurred_at, payload)

If only partial evidence exists (e.g., started but not completed), Ordin SHALL treat the return as an assertion and decide according to BPMN.

**8.1.4.5 Ordin Behavior**

On receipt of ReturnFromQTI, Ordin SHALL:

1.  Validate authorization and tenant isolation for enrollment_context_id

2.  Validate schema_version and required fields

3.  Perform bounded, indexed lookups for required facts using qti_attempt_id (preferred) or attempt_reference

4.  Evaluate the governing BPMN workflow for the learner’s active enrollment context

5.  Emit a decision referencing exact fact IDs and evaluated conditions

6.  Update canonical learner progression state atomically if progression changes

Ordin SHALL NOT synchronously call the QTI runtime as part of this request.

**8.1.4.6 Decision Rules**

Ordin SHALL interpret all inbound data as assertions and SHALL determine progression only through BPMN evaluation.

Examples of BPMN-governed outcomes include:

- MarkActivityComplete if attempt completed and score meets threshold

- RequireRemediation if attempt completed and score below threshold

- SuspendExecution if required facts are missing and policy requires completion evidence

- AcceptManualOverride if a classified override exists and policy allows it

**8.1.4.7 Idempotency**

ReturnFromQTI SHALL be idempotent.

If the learner clicks “Return to Course”multiple times, Ordin SHALL:

- deduplicate using message_id and/or (enrollment_context_id + qti_attempt_id + activity_uuid)

- avoid duplicating decisions or double-advancing progression

- return the same effective result

Duplicates MAY be recorded as evidence but SHALL NOT change canonical outcomes.

**8.1.4.8 Ordering and Applicability**

ReturnFromQTI decisions SHALL only be applied when ordering and applicability are unambiguous.

If facts are present but appear out of order or incomplete:

- Ordin MAY record the return fact/claim

- Ordin SHALL either suspend progression or route to an explicit “assessment pending”state as defined by BPMN

- Ordin SHALL NOT infer pass/fail or completion

**8.1.4.9 Performance Requirements**

ReturnFromQTI is a hot path operation and SHALL adhere to these constraints:

- All required reads MUST be served via indexed lookups

- No unbounded scans

- No synchronous multi-domain call chains

- Constant-time work with respect to tenant size and course size

**8.1.4.10 Failure Semantics**

If authoritative commit cannot be completed:

- Ordin SHALL return an explicit error

- No ambiguous state SHALL be recorded

- Durable ingress buffering MAY be used, but acknowledgment SHALL be withheld until commit succeeds

If evidence is missing:

- Ordin SHALL not “guess”

- Ordin SHALL follow BPMN policy (pause, remediation, or error state)

**8.1.4.11 Evidence Outputs**

Ordin SHALL record at minimum:

- ReturnFromQTIReceived (FACT/CLAIM as appropriate)

- DecisionRecorded (DECISION)

- ProgressionStateUpdated (canonical state update, if applicable)

All records SHALL include correlation_id and causation_id links.

**8.2 Assessment Engine Contracts**

**8.2.1 Assessment Engine Outputs**

The Assessment Engine SHALL publish facts including:

- AssessmentAttemptStarted

- AssessmentAttemptSubmitted

- AssessmentAttemptCompleted

- AssessmentScoreComputed

- AssessmentScoreSuperseded (derived correction)

- AssessmentDefinitionPublished (version)

- AssessmentDefinitionDeprecated (if applicable)

**8.2.2 Assessment Engine Requests Accepted**

The Assessment Engine SHALL accept requests such as:

- RegradeRequested

- InvalidateItemRequested (policy-defined)

- AttemptReviewRequested

Fulfillment SHALL produce facts, not direct updates to Ordin.

**8.2.3 QTI Runtime Separation**

If QTI runtime is separate, its completion SHALL emit facts upon exit. Ordin interprets those facts and does not interact via shared in-memory processes.

**8.3 Standards Gateway Contracts**

**8.3.1 Inbound Standards Payload Handling**

The Standards Gateway SHALL:

- validate inbound payloads,

- preserve raw payloads,

- record facts about receipt and interpretation.

**8.3.2 Outbound Standards Export**

Exports SHALL be:

- snapshots,

- versioned,

- reproducible to semantic equivalence,

- recorded as facts with references to inputs.

**8.3.3 Claims vs Conclusions**

Completion and pass/fail assertions from LTI/xAPI SHALL be recorded as claims and never as canonical progression.

**8.4 Learning Resource Store Contracts**

**8.4.1 Resource Identity**

Learning Objects and SCOs are treated as equivalent conceptual entities.

The LRS SHALL publish facts including:

- LearningObjectCreated

- LearningObjectVersionPublished

- LearningObjectMetadataUpdated (versioned)

- AlignmentAdded/Removed

**8.4.2 Asset Access**

Assets MAY be delivered independently of LO/SCO packaging. Delivery SHALL still be mediated through content resolution and entitlement checks.

**8.5 Content Storage and Resolution Contracts**

**8.5.1 Resolution Queries**

Content resolution SHOULD be callable synchronously with constant-time performance, returning:

- resolved content version identity

- immutable object key/hash

- allowed delivery method (signed URL, proxied stream)

- cache validators (ETag/hash/versioned URL)

**8.5.2 Content Access Facts**

When learner-visible access occurs, the system SHALL record:

- ContentAccessRecorded(content_id, content_version_id, accessed_at, enrollment_context_id) with optional content_hash integrity metadata.

**8.5.3 Publish Boundary**

Publishing follows Appendix E:

- object uploaded first

- DB commit updates resolution pointer atomically

- events emitted after commit/outbox

On successful publish commit, the Content domain SHALL emit ContentVersionPublished (FACT) as publish evidence (see Appendix A), referencing the committed content_version_id and immutable artifact reference/hash.

**8.5.4 Cache Semantics**

Caches MUST never serve the wrong version for a version-specific request. Atomicity is at the resolution pointer, not the cache node.

**8.6 Analytics and Evidence Contracts**

**8.6.1 Evidence Ledger**

The evidence ledger SHALL accept:

- facts,

- claims,

- decisions,

- request transitions,  
  all append-only.

**8.6.2 Non-Authority**

Analytics outputs SHALL never be treated as authoritative inputs to Ordin.

**8.7 Identity and Tenancy Contracts**

**8.7.1 Authoritative Attributes**

External systems may be authoritative for declared identity attributes. Changes SHALL be recorded with attribution and rationale where available.

**8.7.2 Identity References**

Identity data SHOULD be referenced, not duplicated, across records. Historical changes are preserved in logs.

**9. Enrollment Context and Migration Contracts**

**9.1 Enrollment Context**

Every learner action SHALL be associated with an enrollment context that binds:

- course identity

- workflow version

- activity UUID references

- relevant entitlement scope

**9.2 Migration**

Migration is an administrative operation performed outside Ordin:

- Migration MAY create new enrollment contexts pointing to new workflow versions

- Historical execution contexts remain immutable

- Migration state SHALL be tracked as a request (Appendix F)

- Ordin interprets progression within the learner’s active enrollment context

**10. Standards Versioning and Conformance Registry**

**10.1 Registry Requirement**

Atria SHALL maintain a Standards Version and Conformance Registry specifying:

- supported standards

- exact versions

- supported profiles/surfaces

- test and validation requirements

- upgrade and deprecation policy

This registry is normative for implementation and SHALL be maintained as part of the engineering documentation set.

**11. Testing Requirements for Contracts**

**11.1 Contract Tests**

Each interface SHALL have automated contract tests covering:

- schema validation

- idempotency behavior

- duplicate handling

- ordering constraints

- error semantics

- authorization boundaries

**11.2 Replay Verification Tests**

Replay tooling SHALL be tested by:

- reconstructing decisions from preserved facts

- verifying canonical progression matches recorded outcomes

11.3 Machine-Readable Contract Artifacts

This specification suite SHALL be accompanied by machine-readable artifacts derived from the prose specifications, including at minimum:

• OpenAPI (OAS3) YAML for HTTP interfaces (from the HTTP/HTMX spec)

• JSON Schema for the Standard Message Envelope and each Appendix A message subtype

• SQL migrations derived from Spec 0.3 (including evidence partition creation strategy and evidence_all projection/view)

If OpenAPI, JSON Schema, or SQL migration artifacts conflict with the prose specifications (Spec 0.1–0.3 and bridge specs), the prose specifications govern, and the machine-readable artifacts MUST be regenerated to match.

Implementations SHALL treat these artifacts as contract-test inputs and SHALL validate conformance in CI.

**12. Deliverables and Definition of Done**

Spec 0.2 is considered implemented when:

- Each domain exposes documented interfaces and message subtypes

- Envelope schema is enforced for all cross-domain messages

Machine-readable artifacts (OpenAPI, JSON Schema, SQL migrations) are generated from this spec suite and are used in CI contract tests.

- Idempotency and duplicate behavior is proven via tests

- Ordering constraints are declared and enforced where required

- Migration is modeled as request lifecycles outside Ordin

- Content publish boundary is implemented per Appendix E

- Cache semantics comply with Appendix G

- Standards Version and Conformance Registry is created and kept current

**Appendix A. Message Subtype Catalog**

**A.1 Purpose**

This appendix defines the **canonical internal message vocabulary** used for inter-domain communication within Atria.

Its purpose is to:

- eliminate ambiguity about which messages exist,

- define required payloads and semantics,

- enforce idempotency, ordering, and authority boundaries,

- and preserve auditability, replayability, performance, and high availability guarantees.

This catalog is **authoritative**.  
New message subtypes SHALL NOT be introduced without explicit addition to this appendix.

All message subtypes use the **Standard Message Envelope** defined in Spec 0.2.

**A.2 Workflow Runtime (Ordin) Message Subtypes**

**A.2.1 Facts Consumed by Ordin**

**AssessmentAttemptCompleted (FACT)**

**Emitted by:** Assessment Engine  
**Consumed by:** Ordin  
**Hot Path:** Yes

**Required Payload Fields**

- enrollment_context_id (UUID)

- activity_uuid (UUID)

- assessment_id (UUID)

- attempt_id (UUID)

- completion_status (completed \| exited \| timed_out)

- occurred_at (timestamp)

- payload_reference (optional)

**Ordering Key**

- enrollment_context_id + activity_uuid + attempt_id

**Idempotency Key**

- attempt_id

**Notes**

- Indicates attempt lifecycle completion only

- Does not imply pass/fail or progression

**AssessmentScoreComputed (FACT)**

**Emitted by:** Assessment Engine  
**Consumed by:** Ordin  
**Hot Path:** Yes

**Required Payload Fields**

- enrollment_context_id (UUID)

- activity_uuid (UUID)

- assessment_id (UUID)

- attempt_id (UUID)

- score (numeric or structured)

- grading_schema_version

- occurred_at (timestamp)

**Ordering Key**

- enrollment_context_id + activity_uuid + attempt_id

**Idempotency Key**

- attempt_id + grading_schema_version

**Notes**

- Multiple score facts may exist for a single attempt

- Supersession handled explicitly

**ContentAccessRecorded (FACT)**

**Emitted by:** Content Storage & Resolution  
**Consumed by:** Ordin  
**Hot Path:** Yes

**Required Payload Fields**

- enrollment_context_id (UUID)

- activity_uuid (UUID)

- content_id (UUID)

- content_version_id (UUID)

content_version (optional)

- content_hash (optional)

- accessed_at (timestamp)

**Ordering Key**

- enrollment_context_id + activity_uuid + accessed_at

**Idempotency Key**

- enrollment_context_id + content_version_id + accessed_at

ToolLaunchCompleted (FACT)

Emitted by: Standards Gateway

Consumed by: Ordin

Hot Path: Yes

Required Payload Fields

enrollment_context_id (UUID)

activity_uuid (UUID)

tool_type (LTI \| xAPI \| other)

tool_instance_id (UUID or stable string)

launch_id (UUID)

occurred_at (timestamp)

raw_payload_reference (optional)

raw_payload_hash (optional)

Ordering Key

enrollment_context_id + activity_uuid + occurred_at

Idempotency Key

launch_id (preferred) or raw_payload_hash

Notes

Represents successful learner-visible tool launch (analogous to ContentAccessRecorded).

Does not assert completion; BPMN policy MAY treat launch as completion for certain tool activities.

**ToolCompletionClaimReceived (CLAIM)**

**Emitted by:** Standards Gateway  
**Consumed by:** Ordin  
**Hot Path:** Yes

**Required Payload Fields**

- enrollment_context_id (UUID)

- activity_uuid (UUID)

- tool_type (LTI \| xAPI \| other)

- claim_type (completed \| passed \| failed)

- raw_payload_reference

- raw_payload_hash

- occurred_at (timestamp)

**Ordering Key**

- enrollment_context_id + activity_uuid + occurred_at

**Idempotency Key**

- raw_payload_hash

**Notes**

- Claims are evidence only

- Never canonical progression

**ManualOverrideRequested (REQUEST)**

**Emitted by:** Admin / Instructor UI  
**Consumed by:** Ordin  
**Hot Path:** No

**Required Payload Fields**

- enrollment_context_id (UUID)

- activity_uuid (UUID)

- override_type (complete \| pass \| waive \| reset)

- reason_code

- requested_by (actor_id)

- requested_at (timestamp)

**Ordering Key**

- enrollment_context_id + activity_uuid + requested_at

**Idempotency Key**

- enrollment_context_id + activity_uuid + override_type + requested_at

**A.2.2 Decisions Emitted by Ordin**

**DecisionRecorded (DECISION)**

**Emitted by:** Ordin  
**Consumed by:** Evidence Ledger, Analytics  
**Hot Path:** Yes

**Required Payload Fields**

- decision_id (UUID)

- enrollment_context_id (UUID)

- workflow_version

- evaluated_fact_ids (array of UUIDs)

- decision_type (advance \| complete \| remediate \| suspend \| no_op)

- decision_reason

- decided_at (timestamp)

**Ordering Key**

- enrollment_context_id + decided_at

**Idempotency Key**

- decision_id

**ProgressionStateUpdated (DECISION)**

**Emitted by:** Ordin  
**Consumed by:** Canonical Progression Store  
**Hot Path:** Yes

**Required Payload Fields**

- enrollment_context_id (UUID)

- prior_state

- new_state

- decision_id

- updated_at (timestamp)

**Ordering Key**

- enrollment_context_id + updated_at

**Idempotency Key**

- decision_id

**A.3 Assessment Engine Message Subtypes**

**A.3.1 Facts Emitted**

**AssessmentAttemptStarted (FACT)**

**Required Payload Fields**

- enrollment_context_id

- activity_uuid

- assessment_id

- attempt_id

- started_at

**AssessmentAttemptSubmitted (FACT)**

**Required Payload Fields**

- attempt_id

- submitted_at

- submission_reference

**AssessmentScoreSuperseded (FACT)**

**Required Payload Fields**

- attempt_id

- superseded_score_fact_id

- new_score

- reason_code

- occurred_at

**A.3.2 Requests Accepted**

**RegradeRequested (REQUEST)**

**Required Payload Fields**

- attempt_id

- requested_by

- reason_code

- requested_at

**A.4 Standards Gateway Message Subtypes**

**A.4.1 Raw Ingress and Classification**

**StandardsPayloadReceived (FACT)**

**Required Payload Fields**

- standard (LTI \| xAPI \| Caliper \| OneRoster \| CASE \| other)

- standard_version

- raw_payload_reference

- raw_payload_hash

- received_at

**StandardsPayloadClassified (FACT)**

**Required Payload Fields**

- standard

- standard_version

- classification_key

- classification_value

- tool_id or source_system_id

- enrollment_context_id (if resolvable)

- raw_payload_reference

- raw_payload_hash

- occurred_at

**Idempotency Key**

- raw_payload_hash

**StandardsPayloadRejected (FACT)**

**Required Payload Fields**

- standard

- standard_version

- rejection_reason_code

- rejection_description

- raw_payload_reference

- raw_payload_hash

- rejected_at

**A.4.2 Canonical Mapping Rule**

Standards payload facts MAY result in emission of **canonical Atria facts or claims**.

Only canonical message subtypes defined in this appendix MAY be consumed by Ordin for BPMN evaluation.

Raw standards payloads and classification facts SHALL NOT be evaluated directly by Ordin.

**A.5 Learning Resource Store Message Subtypes**

**LearningObjectCreated (FACT)**

**Required Payload Fields**

- learning_object_id

- created_by

- created_at

**LearningObjectVersionPublished (FACT)**

**Required Payload Fields**

- learning_object_id

- version

- published_at

**A.6 Content Storage & Resolution Message Subtypes**

**ContentVersionResolved (FACT)**

**Required Payload Fields**

- content_id

- resolved_version

- content_hash

- resolved_at

ContentVersionPublished (FACT)

Emitted by: Content Storage & Resolution

Consumed by: Evidence Ledger, Analytics, Export/Reporting

Hot Path: No

Required Payload Fields

content_id (UUID)

content_version_id (UUID)

version (string)

artifact_ref (string; immutable pointer)

artifact_hash (hash)

published_by (UUID)

published_at (timestamp)

Ordering Key

content_id + published_at

Idempotency Key

content_version_id

Notes

Recorded only after a successful relational publish transaction commits. Draft artifacts MAY exist in object storage prior to publish but SHALL NOT be learner-visible until this fact exists.

**A.7 Identity & Tenancy Message Subtypes**

**IdentityAttributeChanged (FACT)**

**Required Payload Fields**

- identity_id

- attribute_name

- prior_value_reference

- new_value_reference

- authority_source

- changed_at

TenantCreated (FACT)

Emitted by: Tenancy Control Plane  
Consumed by: Evidence Ledger / Operations  
Hot Path: No

Required Payload Fields

tenant_id (UUID)

created_at (timestamp)

created_by (UUID; identity_id of actor/system)

provisioning_request_id (UUID)

Ordering Key

tenant_id + created_at

Idempotency Key

tenant_id + provisioning_request_id

Notes

Represents successful provisioning of a tenant database and bootstrap state. Written into the tenant evidence ledger for auditability.

TenantDeactivated (FACT)

Emitted by: Tenancy Control Plane  
Consumed by: Evidence Ledger / Operations  
Hot Path: No

Required Payload Fields

tenant_id (UUID)

deactivated_at (timestamp)

deactivated_by (UUID; identity_id of actor/system)

reason_code (string)

Ordering Key

tenant_id + deactivated_at

Idempotency Key

tenant_id + deactivated_at

Notes

Deactivation disables logins and new writes but preserves read-only audit access. This fact is administrative and does not alter historical learner truth.

TenantArchived (FACT)

Emitted by: Tenancy Control Plane  
Consumed by: Evidence Ledger / Operations  
Hot Path: No

Required Payload Fields

tenant_id (UUID)

archived_at (timestamp)

archived_by (UUID; identity_id of actor/system)

archive_ref (string; pointer to snapshot/backup artifact)

archive_hash (string or binary; optional)

Ordering Key

tenant_id + archived_at

Idempotency Key

tenant_id + archived_at

Notes

Archival indicates the tenant database has been snapshotted/moved to cold storage. Replay guarantees must remain intact for the archived snapshot.

**A.8 Administrative and Migration Message Subtypes**

**EnrollmentMigrated (FACT)**

**Required Payload Fields**

- prior_enrollment_context_id

- new_enrollment_context_id

- migration_reason

- migrated_at

**CourseVersionPublished (FACT)**

**Required Payload Fields**

- course_id

- workflow_version

- published_at

**A.9 General Rules**

- All message subtypes SHALL include the standard envelope.

- Payloads SHALL be schema-validated.

- Idempotency keys SHALL be enforced.

- Ordering rules SHALL be respected.

- Hot Path messages SHALL contain only identifiers and immutable references.

- No message subtype SHALL directly mutate another domain’s internal state.

- Replay SHALL rely exclusively on these message records.

**A.10 Claim Promotion Rule**

Claims represent externally or provisionally asserted evidence.

A claim MAY be treated as verified fact for BPMN evaluation only when:

- corroborated by authoritative data in the relational store, and

- explicitly evaluated by Ordin.

Claim promotion SHALL:

- preserve the original claim,

- reference corroborating data,

- be recorded as part of a decision.

Claims SHALL NEVER be silently promoted.

**Revision 0.2.1 Addendum (Normative)**

Date: 2025-12-16

This addendum amends Atria Engineering Spec 0.2 (Domain Interfaces and Contracts). Where this addendum conflicts with earlier sections of the document, the requirements in this addendum SHALL take precedence.

**0.2.1-1 Canonical Identifiers and Time Semantics**

Atria SHALL use the following canonical identifier semantics across all domain messages and storage layers:

• tenant_id: UUID identifying the tenant/institution. Even with database-per-tenant isolation, this is retained for defense-in-depth and for evidentiary export.

• identity_id: UUID for an actor identity (learner, instructor, admin, system).

• subject_id: The identity_id of the subject the message is about (usually the learner).

• actor_id: The identity_id of the actor who performed the action (may be null for fully automated system facts).

• enrollment_context_id: UUID binding subject to (course_id + workflow_version). Required for learner progression, content access, and assessment attempts.

• course_id: UUID of the course (may be omitted if deterministically derivable from enrollment_context_id).

• activity_uuid: UUID of the activity within the governing workflow.

• workflow_version: Version identifier of the BPMN workflow governing the enrollment context.

• message_id: Canonical idempotency and dedupe identifier for a message envelope.

• evidence_id: Canonical identifier of an evidence ledger record. For FACT/CLAIM/REQUEST persisted to the evidence ledger, evidence_id SHALL equal message_id.

Historical note: The envelope amendments below have been incorporated into Section 5.1 as of Spec 0.2 Rev 0.2.6. This section is retained for revision history. The field named 'scope' is DEPRECATED in favor of explicit scope fields.

• correlation_id: UUID tying a chain of related events/requests/decisions (e.g., a learner request and all resulting facts and decisions).

• causation_id: UUID of the immediately triggering message (one hop).

Time semantics:

• occurred_at: When the underlying event occurred in its source context (may be non-monotonic across sources).

• recorded_at: When the authoritative store committed the record (database-authoritative insertion time for evidence partitions, decision table, and progression_state).

• For audit ordering when needed, (recorded_at, message_id) is authoritative.

**0.2.1-2 Revised Standard Message Envelope**

Section 5 of Spec 0.2 is amended as follows. The field named 'scope' is DEPRECATED in favor of explicit scope fields.

Required envelope fields:

• message_id (UUID)

• message_type (ENUM: FACT, CLAIM, REQUEST, DECISION)

• subtype (string; domain-defined; versioned)

• tenant_id (UUID)

• subject_id (UUID; identity_id of subject)

• occurred_at (timestamp)

• recorded_at (timestamp; authoritative store commit time where applicable)

• source_domain (string; emitting domain name)

• correlation_id (UUID)

• causation_id (UUID; nullable)

• schema_version (string or integer; MUST be interpreted deterministically)

Explicit scope fields (REQUIRED when applicable; MUST be present for learner truth affecting messages):

• enrollment_context_id (UUID; nullable for non-course-scoped events)

• course_id (UUID; nullable if deterministically derivable from enrollment_context_id)

• activity_uuid (UUID; nullable if not activity-scoped)

• workflow_version (string; nullable if deterministically derivable from enrollment_context_id)

Payload fields (one of payload or payload_ref SHOULD be present unless subtype explicitly declares 'no payload'):

• payload (JSON; inline; MUST be \<= 32 KiB after serialization; nullable)

• payload_ref (string; pointer to immutable artifact storage / object storage)

• payload_hash (required when payload_ref is present; optional when payload present; MUST use the system-standard hash algorithm)

Optional envelope fields:

• actor_id (UUID; identity_id of actor)

• idempotency_key (string/UUID; used when message_id is not sufficient for dedupe)

• confidentiality_level (ENUM: public, internal, restricted)

• retention_class (ENUM: standard, long-term, legal-hold)

• signature / integrity metadata (where required)

Compatibility rule for deprecated 'scope': if an inbound message still contains a 'scope' object, the explicit scope fields SHALL be authoritative. Any mismatch between 'scope' and explicit fields SHALL be treated as a schema validation error.

**0.2.1-3 Persistence Mapping and Canonical IDs**

To align domain contracts with the canonical data model (Spec 0.3), the following persistence mapping is normative:

• FACT/CLAIM/REQUEST: Persist to the current evidence_YYYY_MM partition. evidence_id SHALL equal message_id.

• DECISION: Persist to the decision table (Spec 0.3). decision_id SHALL equal message_id. Decisions are projected into evidence_all for audit/replay via a view/union strategy; hot paths SHALL NOT require a duplicate DECISION row in evidence partitions.

• Progression snapshot updates: progression_state is updated only by Ordin and MUST occur in the same transaction as the decision insert when progression changes.

• Payload storage: inline envelope payload is stored in evidence.payload_json up to 32 KiB; larger payloads MUST be stored out-of-line via payload_ref + payload_hash (see Section 5.1).

**0.2.1-4 Additions to the Message Subtype Catalog**

Appendix A is amended to add the following authorization-relevant fact subtypes (emitted by Identity & Tenancy domain, consumed by Evidence Ledger and analytics; Ordin may treat these as evidence but SHALL NOT directly mutate identity/entitlements):

• RoleAssigned (FACT): identity_id, role_id, scope_type, scope_id, assigned_by, assigned_at.

• RoleRevoked (FACT): identity_id, role_id, scope_type, scope_id, revoked_by, revoked_at.

• EntitlementGranted (FACT): identity_id, entitlement_type, scope_type, scope_id, granted_by, granted_at.

• EntitlementRevoked (FACT): identity_id, entitlement_type, scope_type, scope_id, revoked_by, revoked_at.

**0.2.1-5 Standards Version and Conformance Registry Requirement**

Section 10 is affirmed as normative. Implementation SHALL treat the Standards Version and Conformance Registry document as a required build input. Each standards-handling feature MUST reference the exact version/profile/surface declared in the registry and MUST be covered by contract tests.

Revision 0.2.2 Addendum (Normative)

Date: 2025-12-16

This addendum amends Atria Engineering Spec 0.2 (Domain Interfaces and Contracts). Where conflicts exist, the requirements in this addendum SHALL take precedence.

0.2.2-1 Tenancy Lifecycle Message Subtypes

Appendix A is amended to add the following administrative tenancy lifecycle message subtypes under A.7 Identity & Tenancy Message Subtypes:

• TenantCreated (FACT)

• TenantDeactivated (FACT)

• TenantArchived (FACT)

These messages are emitted by the Tenancy Control Plane and recorded in the tenant evidence ledger. For these messages, subject_id SHOULD equal tenant_id for consistency in evidence queries.

0.2.2-2 ContentAccessRecorded Hash Optionality

Appendix A is amended to clarify that ContentAccessRecorded (FACT) MAY omit content_hash. When present, content_hash is integrity metadata and SHOULD match the immutable artifact hash recorded for the referenced content version (Spec 0.3). Canonical identity for content delivery remains the versioned content identifier(s), not the hash.

0.2.6-1 Editorial Consolidation and Contract Artifact Precedence

**0.2.6-1 Editorial Consolidation and Contract Artifact Precedence**

This revision makes editorial clarifications to improve AI and human implementer determinism without changing system semantics.

• Section 5.1 (Required Envelope Fields) is reformatted so explicit scope fields are unambiguously required envelope keys and the deprecated 'scope' object cannot be misinterpreted as normative.

• Section 11.3 adds a normative rule for machine-readable contract artifacts (OpenAPI, JSON Schema, SQL migrations): prose specifications govern; artifacts must be regenerated on conflict; CI must validate conformance.

• The prior envelope amendment block (0.2.1-2) is retained as revision history and explicitly noted as incorporated into Section 5.1.
