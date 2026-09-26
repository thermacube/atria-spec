**1. Purpose, Scope, and Governance**

**1.1 Purpose**

This document establishes the foundational engineering constraints that govern the design and implementation of **Atria**, a learning management system focused on faithful pedagogical execution, determinism, auditability, and institutional trust.

Its purpose is to **operationalize the commitments articulated in the Atria white paper** by translating them into enforceable engineering invariants and domain boundaries that precede and constrain all subsequent technical decisions.

This document functions as a **constitutional engineering artifact** for the Atria platform.

**1.2 Scope**

This specification applies to all internal technical development activities related to Atria, including but not limited to:

- Core platform engineering

- Runtime engines

- Authoring and tooling systems

- Standards ingestion and export

- Data storage, versioning, and audit mechanisms

- Infrastructure, deployment, and operational design

Detailed schemas, APIs, deployment topologies, performance characteristics, and operational procedures **SHALL be specified in subsequent engineering documents**.  
Those documents **MUST conform** to the constraints defined herein and **MUST NOT contradict** this specification.

**1.3 Relationship to the Atria White Paper**

The Atria white paper defines the philosophical, pedagogical, and strategic vision for the platform.

This document **operationalizes** that vision by expressing it in precise, enforceable engineering terms. It does not reinterpret, revise, or supersede the white paper.

Where ambiguity exists, this document serves as the authoritative guide for **engineering execution of the white paper’s intent**, not as a replacement for it.

**1.4 Intended Audience**

This document is intended for Atria’s **internal technical team**, including:

- Software engineers

- DevOps and infrastructure engineers

- Systems and network administrators

- Security engineers

- UI and UX designers responsible for technical implementation

It is **not** intended for customers, sales, marketing, or business-facing stakeholders.

Readers are expected to be familiar with:

- BPMN and workflow engines

- Learning technology standards

- Relational and event-oriented data systems

- Distributed system design fundamentals

**1.5 Normative Language**

The key words **SHALL**, **SHALL NOT**, **SHOULD**, **SHOULD NOT**, and **MAY** are to be interpreted as described in RFC 2119.

Statements using **SHALL** or **SHALL NOT** define mandatory requirements.  
Statements using **SHOULD** express strong recommendations that require explicit justification to deviate from.  
Statements using **MAY** indicate optional behavior.

**1.6 Governance and Change Control**

This document has **binding authority**.

Any feature, implementation, or architectural change that violates this specification **SHALL NOT be merged**, regardless of convenience, velocity, or short-term business value.

Changes to Sections 1–3 of this document require:

- Explicit written rationale

- Review by core maintainers

- Consideration of impacts on auditability, replayability, and institutional trust

Working code, partial correctness, or expedience are **not sufficient justification** for violating this specification.

**2. System Invariants**

This section defines the non-negotiable invariants of the Atria Learning Management System. These invariants translate the philosophical and pedagogical commitments articulated in the Atria white paper into binding engineering constraints.

All future design, implementation, optimization, and refactoring decisions SHALL conform to these invariants. Any component, integration, or workflow that violates these constraints is considered non-compliant with Atria’s design intent.

**2.1 Pedagogical Execution Invariants**

**2.1.1 Workflow Authority**

The authoritative definition of pedagogical flow—including sequencing, prerequisites, branching, remediation, assessment progression, and completion—SHALL be expressed in BPMN at execution time.

Authoring tools MAY expose simplified abstractions such as prerequisite toggles, templates, or guided builders, provided those abstractions compile deterministically into BPMN definitions prior to execution.

User interfaces SHALL NOT determine or override pedagogical flow.  
No learner state transition SHALL occur unless it corresponds to a valid BPMN event or transition.

**2.1.2 Deterministic Execution**

Given a specific BPMN workflow definition version, a defined learner context, and a sequence of learner inputs, the resulting execution path and learner state SHALL be deterministic, reproducible, and replayable.

**2.1.3 Controlled Variability**

Nondeterministic behavior (for example, randomized item selection, adaptive branching, or generative prompts) MAY be used, provided that all inputs required to reproduce execution—including random seeds, selection sets, or model parameters—ARE recorded as part of the workflow execution record.

**2.1.4 Immutability of Published Workflows**

Once a BPMN workflow definition is published and assigned to learners, it SHALL be treated as immutable and SHALL NOT be retroactively modified.

Any pedagogical change SHALL result in a new workflow version and SHALL NOT alter historical execution state.

**2.1.5 Versioned Progress Composition**

Learner progress MAY span multiple versions of a course or workflow.

Each learner state transition SHALL be associated with the specific workflow version under which it occurred.  
Completion status SHALL be computed as a composition of version-tagged execution segments rather than as a single monolithic workflow instance.

Migration between workflow versions SHALL be explicit and auditable.

**2.1.6 Explicit Intervention**

Manual overrides, instructor actions, or administrative interventions that affect learner state SHALL be logged as explicit state-changing events.

Such events SHALL be auditable and SHALL be classified (for example, pedagogical, administrative maintenance, or corrective).  
Learner records SHALL NOT be silently mutated.

**2.2 Learner State and Assessment Invariants**

**2.2.1 Single Source of Truth**

There SHALL be exactly one canonical system of record for learner progress, workflow execution state, assessment attempts, scores, completion status, and credential eligibility.

This canonical record SHALL reside in the relational data layer.

**2.2.2 Domain-Scoped Authority**

Atria SHALL be authoritative only for the data domains it explicitly owns.

External systems MAY be authoritative for orthogonal domains such as legal name, institutional identifiers, or biometric verification, provided authority boundaries are explicitly declared.

For domains owned by Atria, external systems SHALL NOT override Atria’s canonical record.

**2.2.3 Attempt Integrity**

Assessment attempts SHALL be immutable once submitted.

Each attempt SHALL be associated with a specific workflow execution and workflow version and SHALL retain original responses, scoring context, and timestamps.

Re-scoring, invalidation, or correction SHALL occur only by producing new derived or corrective records and SHALL NOT overwrite original evidence.

**2.2.4 Derived Views**

Grades, dashboards, analytics, and exports SHALL be derived from canonical learner state and attempt records.

Caching and materialized views MAY be used for performance, provided they are invalidatable and traceable to canonical sources and do not introduce independent or conflicting state.

**2.3 Standards Ingestion and Export Invariants**

**2.3.1 Standards as Contracts**

All supported standards, including but not limited to LTI, QTI, SCORM, xAPI, Caliper, OneRoster, Open Badges, CASE, and LRMI, SHALL be implemented in accordance with their published specifications.

Standards SHALL NOT be partially implemented in ways that alter their semantic meaning.

**2.3.2 Documented Interpretation**

Where a standard is ambiguous, underspecified, or internally inconsistent, Atria SHALL define and publish a documented interpretation and apply it consistently.

**2.3.3 Raw Payload Preservation**

Inbound and outbound standards payloads SHALL be preserved in their original form and retained for audit and reproducibility.

Payloads SHALL NOT be destructively transformed without retention of the original artifact.

**2.3.4 Canonical Interpretation Supremacy**

While raw standards payloads are preserved, Atria’s internal canonical models govern execution and reporting.

External representations are treated as views or exchanges.  
In the event of discrepancies, Atria’s canonical record SHALL serve as the reference point within Atria’s domain of authority.

**2.4 Data Integrity and Storage Invariants**

**2.4.1 Relational Core Truth**

Canonical operational entities—including learners, enrollments, workflow executions, attempts, scores, credentials, permissions, and entitlements—SHALL be stored in a relational database enforcing referential integrity.

**2.4.2 Append-Only Event Records**

Event-oriented data such as xAPI statements, Caliper events, LTI messages, and SCORM runtime calls SHALL be stored as append-only records.

Full payload fidelity SHALL be retained.  
Extracted indexed fields MAY be stored for query efficiency.

**2.4.3 Corrective Semantics**

Erroneous or disputed events SHALL NOT be modified or deleted.

Corrections SHALL be implemented through explicit corrective or superseding records that reference and contextualize the original event.

**2.4.4 Binary Artifact Storage**

Binary and package-based artifacts such as SCORM ZIPs, Common Cartridge files, media assets, and exports SHALL be stored in object storage systems.

Relational databases SHALL store only immutable identifiers, cryptographic hashes, and metadata pointers to these artifacts.

Storing binary artifacts directly in relational tables is prohibited except in explicitly approved exceptional cases.

**2.4.5 Archival and Retention**

Superseded records MAY be archived, compacted, or compressed for performance, provided referential integrity is preserved and replayability guarantees remain intact.

Retention, encryption, and purge policies SHALL be tenant-configurable and compliant with legal and regulatory requirements.

**2.5 Content Identity and Resolution Invariants**

**2.5.1 Conceptual Content Identity**

Learning content identity SHALL be conceptual and independent of file format, encoding, storage location, or localization.

**2.5.2 Immutable Content Objects**

Content objects SHALL be immutable once created and SHALL NOT be modified in place at the file or object-storage level.

Any change, including re-upload, re-encoding, format change, or localization, SHALL result in a new versioned content object.

**2.5.3 Resolution Over Mutation**

Content updates SHALL be implemented through resolution and versioning rather than mutation.

Existing references SHALL remain valid.  
Resolution pointers MAY advance.  
Historical executions SHALL continue to reference the original content version.

**2.6 Auditability and Reproducibility Invariants**

**2.6.1 Evidence Preservation**

Atria SHALL preserve sufficient evidence to explain, prove, and replay learner progress, workflow execution paths, assessment outcomes, and standards exports.

**2.6.2 Reproducible Execution and Exports**

Historical executions and exports SHALL be replayable using preserved workflow definitions, recorded inputs, and captured variability.

Reproduced outputs SHALL be semantically equivalent even if underlying infrastructure evolves.

**2.7 Consistency and Failure Semantics**

**2.7.1 Strong Consistency for Learner State**

Learner-visible state transitions SHALL require strong consistency guarantees and SHALL NOT be acknowledged until durably persisted.

**2.7.2 Eventual Consistency for Derived Views**

Analytics, reporting, and search indexes MAY operate under eventual consistency, provided canonical state remains authoritative.

**2.7.3 Failure Transparency**

On failure, learner state SHALL NOT be left ambiguous.  
Partial transitions SHALL NOT be committed.  
Hard errors SHALL be preferred over silent or deferred resolution.

**2.8 Explicit Non-Negotiables**

The following are explicitly disallowed:

Pedagogical logic encoded primarily in UI workflows  
Silent mutation of learner or assessment records  
Retroactive modification of published workflows  
In-place modification of content or binary artifacts  
Storage of learning packages directly in relational tables  
Best-effort completion without deterministic execution evidence

**3. Bounded Domains and Responsibility Boundaries**

**3.1 Domain-Oriented Architecture**

Atria is composed of a set of **bounded domains**, each of which is sovereign over its internal state, responsibilities, and data ownership.

Domains SHALL interact only through explicit interfaces, events, or contracts.  
Domains SHALL NOT directly mutate another domain’s internal state.

This structure is mandatory and exists to ensure:

- Auditability

- Security

- Testability

- Long-term architectural coherence

**3.2 Core Domains Overview**

The following domains constitute the initial core of the Atria platform:

- Workflow Runtime (Ordin)

- Assessment Engine

- Standards Gateway

- Learning Resource Store

- Content Storage and Resolution

- Analytics and Evidence

- Identity and Tenancy

This list is not exhaustive and SHALL evolve over time under the rules defined in Section 3.2.1.

**3.2.1 Domain Introduction Rules**

New domains MAY be introduced provided they:

- Declare clear ownership of data and responsibilities

- Define explicit authority boundaries

- Specify interaction contracts with existing domains

- Do not retroactively absorb responsibilities already owned by another domain without an explicit amendment to this specification

No domain SHALL exist solely as a miscellaneous or catch-all container.

**3.3 Workflow Runtime Domain (Ordin)**

**Primary Responsibility**  
Execution of pedagogical workflows defined in BPMN and determination of course-level learner progression.

**Owns**

- BPMN workflow definitions (versioned)

- Workflow execution state

- Course-level learner progression and completion ledger

- Pedagogical decision log

**Does Not Own**

- Assessment scoring logic

- Binary content

- External standards representations

**Constraints**

- All pedagogical decisions SHALL be made by Ordin based on BPMN execution.

- Ordin SHALL consume facts produced by other domains and render decisions deterministically.

- Ordin SHALL NOT directly mutate the internal state of other domains.

- Ordin interacts with other runtimes (e.g., QTI) only via persisted state, never via shared in-memory execution.

**3.4 Assessment Engine Domain**

**Primary Responsibility**  
Assessment execution, validation, attempt tracking, and scoring.

**Owns**

- Assessment definitions (canonical form)

- Assessment attempts and responses

- Scoring results and derived metrics

**Does Not Own**

- Pedagogical sequencing

- Course-level completion

- Workflow execution logic

**Constraints**

- Assessment attempts SHALL be immutable once submitted.

- The Assessment Engine SHALL emit facts (e.g., scores, outcomes) upon completion.

- Ordin SHALL interpret assessment facts to make pedagogical decisions.

- The Assessment Engine SHALL NOT assert course completion.

**3.5 Standards Gateway Domain**

**Primary Responsibility**  
Ingestion, validation, interpretation, and export of learning technology standards.

**Owns**

- Standards payload handling

- Validation logic

- Documented interpretation mappings

**Does Not Own**

- Canonical learner progression

- Pedagogical authority

**Constraints**

- Raw inbound and outbound payloads SHALL be preserved.

- External claims (e.g., completion) SHALL be recorded as facts or claims.

- Such claims SHALL NOT determine course-level completion unless accepted by Ordin via BPMN rules.

**3.6 Learning Resource Store Domain**

**Primary Responsibility**  
Management of conceptual learning objects, metadata, discovery, alignment, and reuse.

**Owns**

- Learning Object (LO) / Shareable Content Object (SCO) identity

- Resource metadata and alignments

- Conceptual versioning of learning resources

**Does Not Own**

- Binary artifact storage

- Workflow execution state

**Constraints**

- LO and SCO are treated as equivalent conceptual entities.

- Assets MAY be accessed independently or as part of an LO/SCO.

- Resource identity SHALL be conceptual and versioned.

**3.7 Content Storage and Resolution Domain**

**Primary Responsibility**  
Storage, versioning, and resolution of binary learning artifacts and derived renditions.

**Owns**

- Content object identifiers

- Binary versions and renditions

- Resolution mappings

**Does Not Own**

- Pedagogical meaning

- Learner progression

**Constraints**

- Binary content SHALL be immutable once accessed by a learner.

- New versions SHALL be created for any change.

- Older binary versions MAY be deleted only if they have never been accessed by a learner, provided version history metadata is retained.

**3.8 Analytics and Evidence Domain**

**Primary Responsibility**  
Capture and retention of immutable facts, events, and evidence required for audit, reporting, and replay.

**Owns**

- Evidence ledger

- Event records

- Fact and claim storage

**Does Not Own**

- Canonical learner progression

- Pedagogical rules

**Constraints**

- Events and facts SHALL be append-only.

- Analytics SHALL reflect truth but SHALL NOT modify truth.

- Evidence SHALL support replayability and dispute resolution.

**3.9 Identity and Tenancy Domain**

**Primary Responsibility**  
Management of tenants, users, identity attributes, and authority boundaries.

**Owns**

- Identity mappings

- Role and permission structures

- Tenant isolation rules

**Does Not Own**

- Pedagogical execution

- Assessment outcomes

**Constraints**

- External systems MAY be authoritative for declared identity attributes.

- All identity changes SHALL be recorded with source attribution, timestamps, and rationale where available.

- Pedagogical records SHALL remain stable across identity changes.

**3.10 Cross-Domain Interaction and Decision Resolution**

Domains SHALL publish **facts** about events within their scope and SHALL NOT assert final learner progression outside that scope.

Ordin SHALL act as the **pedagogical decision engine**, consuming domain facts and rendering deterministic decisions according to BPMN workflows.

Disagreements between domains are resolved at the **decision layer**, not by mutating domain state.

Canonical course-level learner state is defined exclusively by Ordin’s execution of BPMN workflows.  
External assertions and domain facts become canonical progression only when explicitly accepted by Ordin.

**4. Sources of Truth and Data Authority**

**4.1 Purpose of This Section**

This section defines **where truth lives** within Atria.

It establishes:

- which domains are authoritative for which classes of data,

- how assertions and facts are interpreted,

- how disagreements are resolved,

- and how canonical learner progression is determined.

The intent is to eliminate ambiguity, prevent silent overrides, and ensure that all learner-facing outcomes are deterministic, auditable, replayable, and defensible.

**4.2 Conceptual Model: Assertions, Facts, Decisions, and Canonical State**

Atria distinguishes between four related concepts:

- **Assertions**: Statements made by systems or humans claiming that something occurred or is true

- **Facts**: Immutable records that an assertion was made, occurred, or was observed

- **Decisions**: Deterministic pedagogical interpretations of facts

- **Canonical State**: The authoritative representation of learner progression within a course

These layers are intentionally separated to preserve domain sovereignty while ensuring a single authoritative learner outcome.

**4.3 Assertions and Facts**

All inbound data to Atria is treated initially as an **assertion**.

Assertions become **facts** when recorded as immutable, append-only evidence of what was asserted, by whom, when, and under what scope.

Examples include:

- A grader asserting that an assessment response is satisfactory

- A learner submitting an assessment attempt

- An LTI tool asserting “completion”

- An xAPI statement asserting “passed”

- A content object being accessed

- An identity attribute being changed by an authoritative source

- An administrator requesting a manual override

Facts:

- SHALL be immutable once recorded

- SHALL include timestamps, source attribution, and scope

- SHALL NOT be retroactively altered or deleted

- MAY be superseded only by additional facts that reference the original

Facts do not, by themselves, determine learner progression.

**4.4 Human Judgment and Manual Assertions**

Human judgments (e.g., grading, instructional evaluation) SHALL be treated as **credible assertions** and recorded as facts with explicit classification and attribution.

Human assertions:

- Are preserved as evidence

- SHALL NOT override canonical pedagogical rules by themselves

- MAY result in a pedagogical decision only when accepted by Ordin via BPMN evaluation

Manual overrides are permitted but SHALL:

- Be explicit

- Be evaluated against the governing BPMN workflow

- Preserve all contradictory evidence

- Be classified and auditable

**4.5 Domain Fact Authority**

Each domain is authoritative only for facts within its declared scope.

Examples:

- The Assessment Engine is authoritative for assessment attempts and scores

- The Standards Gateway is authoritative for receipt and validation of standards payloads

- The Content Storage and Resolution domain is authoritative for content access and version resolution

- The Identity and Tenancy domain is authoritative for declared identity attributes

Domains SHALL NOT assert pedagogical conclusions or canonical learner progression.

All domain output is treated as assertions whose interpretation is deferred.

**4.6 Claims Versus Pedagogical Conclusions**

Some assertions represent **claims** rather than intrinsic truth.

Examples include:

- An LTI tool asserting “course complete”

- An xAPI statement asserting “passed”

- An external system asserting enrollment status

Such claims SHALL be recorded as facts of the form:

- “System X asserted Y at time T under scope S”

Claims are evidence, not conclusions.

Learner-facing messaging MAY normalize or reinterpret claim language to avoid confusion, provided original assertions remain preserved internally.

**4.7 Pedagogical Decisions**

All pedagogical decisions are owned exclusively by the **Workflow Runtime (Ordin)**.

Decisions include:

- Advancing or blocking learner progression

- Marking activities or courses complete

- Requiring remediation

- Accepting or rejecting completion claims

- Applying manual overrides

Decisions:

- SHALL be derived solely from BPMN workflow execution

- SHALL reference exact fact identifiers and evaluated conditions

- SHALL be versioned and logged

- SHALL be reproducible given the same workflow version and fact set

No domain other than Ordin may make pedagogical decisions.

**4.8 Canonical Learner Progression State**

Canonical learner progression state answers questions such as:

- “Where is the learner in the course?”

- “Is the learner complete?”

- “Which requirements have been satisfied?”

This state:

- Is owned exclusively by Ordin

- Is derived from BPMN execution and recorded decisions

- SHALL NOT be directly mutated by other domains

- SHALL be reproducible from preserved facts, decisions, and workflow definitions

Canonical progression is authoritative within Atria regardless of external representations.

**4.9 Activity Identity, Versioning, and Completion Semantics**

Learner completion is associated with **activity identity (UUID)** rather than activity version.

- The activity UUID defines what was completed

- The activity version is recorded as metadata for audit and replay

- Completion applies to the activity identity unless BPMN rules specify otherwise

Version changes do not invalidate completion unless explicitly defined in pedagogy.

**4.10 Resolution of Conflicting Assertions**

Conflicts occur when assertions appear to disagree.

Conflicts SHALL be resolved in the following fixed order:

1.  **Authority Scope**  
    Only assertions from domains authoritative for a given fact type are considered.

2.  **Pedagogical Policy (BPMN)**  
    BPMN defines how assertions and facts are interpreted and combined.

3.  **Temporal and Identity Alignment**  
    Assertions must align with the learner’s current activity identity and execution context.

4.  **Explicit Administrative Decisions**  
    Overrides are allowed but must be explicit, classified, and auditable.

Resolution occurs by issuing **new decisions**, never by mutating facts.

**4.11 Identity Changes and Historical Integrity**

Identity attributes MAY change over time when asserted by an authoritative source.

Such changes:

- SHALL be recorded with timestamps, source attribution, and rationale where available

- SHALL NOT retroactively alter historical pedagogical records

- SHALL preserve linkage between prior and current identity representations

Previously issued credentials retain historical identity values unless explicitly reissued.

**4.12 External Systems and Institutional Disagreement**

External systems (e.g., SIS, IdP, proctoring platforms) may be authoritative for declared domains.

However:

- External representations are treated as evidence

- Canonical learner progression is determined only by Ordin

- Atria SHALL provide evidence explaining its conclusions when disagreement arises

Institutions MAY override outcomes externally, but Atria’s internal truth remains intact.

**4.13 Legal, Regulatory, and Deletion Requirements**

When legal or regulatory requirements mandate deletion or erasure:

- The highest applicable authority SHALL be obeyed

- Deletion events SHALL be recorded as facts

- Data MAY be tombstoned, masked, or contextualized rather than silently removed

- Evidence preservation SHALL be attempted unless explicitly prohibited

Compliance actions SHALL preserve auditability to the maximum extent permitted by law.

**4.14 Audit and Replay Guarantees**

Given preserved facts, recorded decisions, workflow definitions, and content identity metadata, Atria SHALL be able to:

- Reconstruct a timeline of learner interaction

- Recreate the full payload of data submitted by the learner

- Recreate the full payload of data presented to the learner

- Explain and prove how outcomes were reached

Replay is defined as **semantic and interactional reconstruction**, not byte-for-byte re-execution.

5\. Versioning, Immutability, and Lifecycle Management

5.1 Purpose of This Section

This section defines how versioning, immutability, and lifecycle transitions are handled across workflows, activities, content, assessments, evidence, identity, and learner state.

Its purpose is to ensure that pedagogical execution remains deterministic, learner outcomes remain reproducible, historical records remain defensible, and operational iteration is possible without compromising trust.

5.2 General Versioning Principles

All versioning within Atria SHALL adhere to the following principles:

Any change after publication SHALL result in a new version, without exception

Versioning is explicit and intentional, never implicit

Published artifacts are immutable

Changes are expressed through new versions, not in-place mutation

Historical versions remain addressable and auditable

Version identifiers SHALL be stable and referenceable.

5.3 Workflow and Course Versioning

5.3.1 Workflow Definition Versioning

BPMN workflow definitions:

SHALL be versioned at publication time

SHALL be immutable once published

SHALL NOT be retroactively modified

Any pedagogical change, regardless of magnitude or urgency, SHALL produce a new workflow version.

5.3.2 Learner Progress Across Workflow Versions

Learners MAY traverse multiple workflow versions over time.

Each workflow execution segment SHALL reference the workflow version under which it occurred

Learner progress SHALL be computed as a composition of version-tagged execution segments

Migration between workflow versions SHALL be explicit and auditable

Migration is a normal and expected operation. It MAY be implemented by reassignment of enrollment context to a new workflow version without rewriting historical execution data.

5.4 Activity Identity and Versioning

5.4.1 Activity Identity

Activities SHALL be assigned stable, globally unique identifiers (UUIDs).

The activity UUID defines the pedagogical unit of completion.

5.4.2 Activity Versioning

Activity definitions MAY evolve over time.

Any change to an activity SHALL result in a new activity version

The activity version SHALL be recorded as metadata alongside learner interaction records

Completion applies to the activity UUID unless BPMN rules explicitly define otherwise

Atria SHALL NOT attempt to evaluate semantic equivalence between activity versions. Pedagogical validity is defined by authored workflow rules, not by automated content analysis.

5.5 Content Versioning and Lifecycle

5.5.1 Content Lifecycle States

Content objects SHALL move through explicit lifecycle states, including at minimum:

Draft

Published

Accessed

Archived

Lifecycle transitions SHALL be recorded and auditable.

5.5.2 Content Immutability After Access

Once content has entered the Accessed state (i.e., delivered to a learner in the context of a course):

The binary content SHALL be immutable

Any change SHALL result in a new content version

The original version SHALL remain addressable for audit and replay

This requirement applies regardless of the nature of the change, including accessibility fixes, corrections, or improvements.

5.5.3 Deletion Rules for Content

Binary content MAY be deleted only if all of the following are true:

The content has never been accessed by a learner

The lifecycle state is Draft or Published but not Accessed

Version history metadata is preserved

Once content has been accessed by a learner, binary deletion is prohibited.

5.6 Assessment Versioning and Scoring Corrections

Assessment definitions:

SHALL be versioned upon publication

SHALL be immutable once assigned to learners

Assessment attempts:

SHALL be immutable once submitted

SHALL reference the assessment version used

Scoring corrections, rubric changes, item invalidations, or grading adjustments:

SHALL result in new derived records

SHALL NOT overwrite original attempt data

SHALL preserve both original and corrected outcomes with explicit rationale

5.7 Evidence, Facts, and Decision Lifecycles

Facts and decisions follow strict lifecycle rules:

Facts are append-only and immutable

Decisions are append-only and immutable

Supersession occurs only by reference, never by mutation

Corrections, retractions, overrides, or legal actions:

SHALL be represented as new facts or decisions

SHALL reference affected records

SHALL preserve original evidence unless legally prohibited

The cleanest and most trustworthy record is the complete record.

5.8 Identity Lifecycle and Change Management

Identity attributes MAY change over time when asserted by an authoritative source.

Identity handling SHALL follow these rules:

Identity attributes SHALL be stored in a single authoritative master record

Other records SHALL reference identity data rather than copying it

Identity changes SHALL be recorded as versioned facts with timestamps, source attribution, and rationale where available

Historical logs preserve identity changes, while current references resolve to the active identity record. Pedagogical records remain stable and replayable regardless of identity evolution.

5.9 Export, Snapshot, and Reissuance Semantics

Exports such as transcripts, certificates, and standards payloads:

SHALL be generated as snapshots

SHALL reference the versions of workflows, activities, content, and identity attributes in effect at generation time

SHALL NOT be silently regenerated

Reissuance of exports:

IS permitted upon request

SHALL reflect current identity attributes

SHALL NOT invalidate or alter previously issued artifacts

Multiple artifacts for the same course MAY coexist, each correct for its time of issuance.

5.10 Archival, Retention, and Post-Retention Handling

Archival mechanisms MAY be employed to manage storage growth and performance.

Archival:

SHALL preserve referential integrity

SHALL NOT break replayability guarantees

MAY involve compression, tiered storage, or cold storage

Retention and purge policies:

SHALL be tenant-configurable

SHALL respect legal and regulatory requirements

SHALL record purge or deletion actions as auditable events

After institutionally or legally required retention periods have passed, control over retained data MAY be transferred to the learner. Learners MAY choose to receive or delete such data where permitted.

5.11 Operational Guarantees

The lifecycle and versioning rules defined in this section ensure that:

No published learner-facing artifact is overwritten

All change is expressed through explicit versioning, recorded decisions, and preserved evidence

Historical execution is never reinterpreted, only extended

No learner outcome becomes ambiguous due to change

No historical execution becomes irreproducible

These guarantees are foundational to Atria’s credibility as a learning execution platform.

**6. Consistency, Availability, and Failure Guarantees**

**6.1 Purpose of This Section**

This section defines Atria’s guarantees and intentional tradeoffs with respect to data consistency, system availability, and failure handling.

Its purpose is to ensure that learner-facing outcomes are never ambiguous, pedagogical execution remains correct under failure, audit and replay guarantees are preserved, and operational decisions around high availability and recovery are constrained by explicit principles rather than ad hoc behavior.

This section specifies **behavioral guarantees**, not specific infrastructure implementations.

**6.2 Guiding Principles**

Atria’s consistency and availability behavior SHALL be governed by the following principles:

- Correctness is prioritized over availability for learner-facing state

- Failure is explicit rather than hidden

- Partial state is never acknowledged

- Recovery favors determinism and verifiability over speed

- Availability optimizations SHALL NOT weaken auditability or truth guarantees

These principles are non-negotiable.

**6.3 Consistency Model by Data Class**

Atria applies different consistency guarantees depending on the class of data involved.

**6.3.1 Canonical Learner Progression State**

Canonical learner progression state owned by Ordin:

- SHALL require strong consistency guarantees

- SHALL be durably persisted before acknowledgement

- SHALL NOT be subject to eventual consistency

Learner-visible progression, completion, and remediation decisions SHALL never be based on stale, speculative, or inferred data.

**6.3.2 Workflow Execution and Decisions**

Workflow execution state and pedagogical decisions:

- SHALL be strongly consistent

- SHALL be recorded atomically

- SHALL reference the exact facts, assertions, and workflow versions evaluated

A workflow transition SHALL either complete fully or not at all.

**6.3.3 Facts, Evidence, and Event Records**

Facts and evidence records:

- SHALL be append-only and immutable

- SHALL be durably persisted before acknowledgement

- MAY be replicated asynchronously provided ordering and immutability are preserved

Temporary unavailability of downstream stores SHALL NOT cause loss of received facts.

**6.3.4 Derived Views and Analytics**

Derived data such as dashboards, reports, search indexes, and analytics:

- MAY operate under eventual consistency

- SHALL NOT be treated as authoritative

- SHALL degrade gracefully under failure

Stale or delayed analytics SHALL NOT influence pedagogical decisions or learner progression.

**6.4 Availability Expectations**

Atria SHALL make the following availability guarantees:

- Learner progression and assessment submission MAY be temporarily unavailable rather than incorrect

- Administrative, reporting, and analytics functions MAY degrade independently of learner-facing execution

- Partial outages SHALL be isolated to the smallest possible domain

High availability mechanisms SHALL NOT introduce ambiguity into learner state.

**6.5 Failure Handling Semantics**

**6.5.1 Learner-Facing Operations**

If a failure occurs during a learner-facing operation (e.g., assessment submission, activity completion):

- The operation SHALL either complete fully or not at all

- The learner SHALL receive an explicit error message

- No ambiguous or partially applied state SHALL be recorded

Silent failure and speculative acknowledgement are prohibited.

**6.5.2 Durable Ingress and Delayed Acknowledgement**

Inbound data MAY be accepted into a **durable ingress buffer** even when all authoritative stores are temporarily unavailable.

In such cases:

- Acknowledgement of success SHALL be withheld until authoritative commit succeeds

- Learner-visible state SHALL remain unchanged until commit completes

- Buffered data SHALL NOT be interpreted as canonical state

This mechanism preserves correctness without requiring rejection or retransmission of already-received data.

**6.5.3 Domain-Level Failures**

If a domain becomes unavailable:

- Other domains SHALL NOT fabricate, infer, or substitute missing data

- Ordin SHALL suspend dependent decisions until required facts are available

- Suspension SHALL be explicit, observable, and auditable

Temporary unavailability SHALL NOT result in inferred learner progression.

**6.6 Recovery and Replay**

**6.6.1 Recovery Principles**

Recovery from failure SHALL prioritize:

- preservation of facts and decisions

- correctness of canonical learner state

- verifiability of restored outcomes

Routine recovery is expected to rely on replication, backups, and failover mechanisms, not on replay.

Manual data mutation during recovery is prohibited except through explicit, auditable mechanisms defined elsewhere in this specification.

**6.6.2 Replay as Verification and Forensics**

Replay exists to **verify**, not to bootstrap, system correctness.

Replay MAY be used to:

- reconstruct learner execution timelines

- validate that recovered state matches original decisions

- investigate anomalies or disputes

- support audit, accreditation, or legal review

Replay SHALL be deterministic and SHALL reproduce outcomes given the same facts, decisions, and workflow versions.

**6.7 Idempotency and Duplicate Handling**

All externally triggered operations (e.g., assessment submissions, standards events, administrative actions):

- SHALL be idempotent

- SHALL tolerate retries without duplicating effects

- SHALL detect and record duplicates explicitly

Duplicate detection SHALL rely on stable identifiers and recorded state, not heuristic inference.

**6.8 Ordering Guarantees**

Where ordering matters (e.g., assessment attempts, workflow transitions):

- Events SHALL be ordered deterministically

- Ordering SHALL be preserved across replication and recovery

- Out-of-order events MAY be recorded but SHALL NOT violate execution correctness

Ordin SHALL evaluate assertions only when ordering and applicability are unambiguous.

**6.9 Isolation and Multi-Tenancy**

Tenant isolation SHALL be enforced across:

- data storage

- workflow execution

- failure domains

- recovery operations

A failure, overload, or misbehavior in one tenant SHALL NOT corrupt or contaminate another tenant’s learner state.

Operational controls such as throttling or circuit breaking MAY be employed to preserve system integrity.

**6.10 Operational Transparency**

Failures, degradations, buffering, suspensions, and recoveries:

- SHALL be logged

- SHALL be attributable

- SHALL be auditable

Operational transparency is required to preserve institutional trust and enable post-incident analysis.

**6.11 Explicit Tradeoffs**

Atria explicitly accepts the following tradeoffs:

- It is preferable to block an operation than to record ambiguous state

- It is preferable to pause learner progression than to infer completion

- It is preferable to recover slowly and correctly than quickly and incorrectly

These tradeoffs are intentional and foundational.

**6.12 Guarantee Summary**

The guarantees in this section ensure that:

- Learner-facing truth is never speculative

- Failures do not corrupt pedagogical execution

- Recovery preserves determinism and verifiability

- Availability optimizations do not compromise trust

These guarantees complete the constitutional definition of Atria’s runtime behavior under real-world operating conditions.

**Appendix A. Event, Fact, Claim, Decision, and Request Taxonomy**

**A.1 Purpose**

This appendix defines a shared vocabulary and structural taxonomy for events, facts, claims, decisions, and requests within Atria.

Its purpose is to ensure consistent interpretation, storage, replay, and auditability across all domains.

**A.2 Assertion**

An **Assertion** is any statement made by a system or human claiming that something occurred or is true.

Assertions are not authoritative conclusions.

Examples include:

- “Learner completed this activity”

- “Score is 85”

- “This identity attribute changed”

**A.3 Fact**

A **Fact** is an immutable, append-only record that an assertion was made or an event occurred.

Facts SHALL include:

- A unique identifier (UUID)

- Timestamp

- Source (system, user, or integration)

- Scope (tenant, course, activity, domain)

- Payload (raw or structured)

- Optional references to related facts

Facts SHALL NOT be deleted or mutated except where legally required.

**A.4 Claim**

A **Claim** is a type of fact representing an assertion that implies a pedagogical conclusion but does not itself determine one.

Examples include:

- LTI tool asserting “course complete”

- xAPI statement asserting “passed”

Claims are evidence, not canonical progression.

**A.5 Decision**

A **Decision** is a deterministic pedagogical interpretation of one or more facts, made exclusively by **Ordin** under BPMN governance.

Decisions SHALL include:

- Decision identifier

- Workflow version

- Referenced fact identifiers

- Evaluated conditions

- Resulting action or state transition

Decisions are append-only and immutable.

**A.6 Request**

A **Request** represents an intent to perform an action that requires evaluation or fulfillment.

Examples include:

- Manual override requests

- Enrollment migration requests

- Regrade requests

- Administrative corrections

Requests become facts once recorded and may result in decisions.

**A.7 Event Flow Summary**

1.  An assertion occurs

2.  The assertion is recorded as a fact

3.  Ordin evaluates relevant facts

4.  Ordin emits a decision

5.  Canonical learner state updates if applicable

No assertion bypasses this flow.

**Appendix B. Storage and Schema Conventions**

**B.1 Purpose**

This appendix defines storage rules and schema conventions that support the guarantees in Sections 1–6.

It establishes required patterns without prescribing specific table layouts.

**B.2 Relational Core**

The relational database is the system of record for:

- Canonical learner progression

- Workflow execution state

- Decisions

- Fact metadata

- Enrollment context

- Identity master records

All canonical state SHALL be relational.

**B.3 Append-Only Records**

The following SHALL be append-only:

- Facts

- Claims

- Decisions

- Requests

- Identity change logs

- Audit logs

Corrections SHALL reference prior records rather than mutate them.

**B.4 Structured Payloads**

Structured payloads (e.g., xAPI, Caliper, LTI):

- MAY be stored as JSON

- SHALL preserve original structure

- MAY include indexed projections

Derived projections SHALL NOT replace original payloads.

**B.5 Object Storage**

Binary artifacts (e.g., SCORM packages, media, documents):

- SHALL reside in object storage

- SHALL be immutable once accessed by a learner

- SHALL be referenced by identifiers and cryptographic hashes

Relational tables SHALL store pointers, not binaries.

**B.6 Identity Storage**

Identity attributes:

- SHALL be stored in a single authoritative master record

- SHALL be referenced, not duplicated

- SHALL produce append-only change records when updated

Historical logs preserve prior values; current references resolve dynamically.

**Appendix C. Identifier and Versioning Conventions**

**C.1 Identifiers**

All primary entities SHALL use true UUIDs, including:

- Learners

- Enrollments

- Activities

- Content objects

- Workflow executions

- Facts

- Decisions

- Requests

Identifiers SHALL be globally unique and stable.

**C.2 Version Identifiers**

Version identifiers SHALL be:

- Explicit

- Stored alongside immutable artifacts

- Used for audit and replay

Version identifiers SHALL NOT imply semantic equivalence.

**C.3 Completion Semantics**

Completion applies to **activity identity (UUID)**.

Version metadata is preserved for audit and replay but SHALL NOT invalidate completion unless explicitly defined by pedagogy.

**Appendix D. High Availability and Operational Reference Patterns**

**D.1 Purpose**

This appendix provides reference patterns for implementing Section 6 guarantees.

These are guidance patterns, not mandates.

**D.2 Acceptable Patterns**

Acceptable patterns MAY include:

- Primary–replica relational databases for canonical state

- Asynchronous replication for append-only evidence

- Durable ingress buffers

- Object storage with immutable versioning

- Front-end and back-end clustering with health checks

**D.3 Prohibited Patterns**

The following are prohibited:

- Eventual consistency for canonical learner progression

- In-place mutation of published learner-facing artifacts

- Silent failure or speculative acknowledgement

- UI-driven progression logic

- Cross-domain direct state mutation

**D.4 Replay Tooling**

Replay tooling:

- SHALL be deterministic

- SHALL use preserved facts, decisions, and workflow definitions

- SHALL support audit, dispute resolution, and verification

- SHALL NOT be required for routine recovery

**Appendix E. Publish, Commit, and Resolution Boundaries**

**E.1 Purpose**

This appendix defines authoritative commit boundaries for publishing workflows, content, and course updates.

**E.2 Publish Without Distributed Transactions**

Atria SHALL NOT require distributed transactions across relational storage, object storage, and event delivery.

Publishing SHALL follow this pattern:

1.  Artifacts are uploaded or prepared

2.  A single relational transaction:

    - creates the new version record

    - binds identifiers, hashes, and metadata

    - updates resolution pointers if publishing

    - records a publish fact

<!-- -->

1.  Events are emitted after commit or via a transactional outbox

If the relational transaction does not commit, the publish SHALL be considered not to have occurred.

E.2.1 Learner-Visibility Gate (Normative)

Any artifact, workflow, assessment, or other learner-facing resource SHALL be considered learner-visible only after a successful relational publish transaction commits and records the corresponding Published fact in the evidence ledger (Spec 0.2).

Draft artifacts MAY exist in object storage prior to publish, but SHALL NOT be resolvable by learner delivery endpoints or referenced by active enrollment contexts until the publish transaction commits.

Learner delivery endpoints MUST authorize access against canonical published version records (e.g., workflow definition/version records, assessment_version, content_version) and MUST NOT serve artifacts that lack a committed published version record.

E.2.2 Publish Trigger and Validation (Normative)

Publish operations are initiated by an authorized actor (human or system identity) via an authoring surface or administrative API. Implementations MAY model publish as a REQUEST lifecycle (Appendix F), but MUST, at minimum, record the committed version record(s), the Published fact, and the actor identity responsible for the publish.

Publish validation MUST complete before the relational transaction commits. At minimum: (a) workflow publish MUST validate BPMN subset and determinism constraints (see Ordin BPMN Execution Spec), (b) assessment publish MUST validate the assessment definition and declared standard profile and compute/store a definition hash, and (c) content publish MUST verify artifact upload and compute/store an artifact hash bound to an immutable artifact reference.

On validation failure, the publish SHALL NOT commit, and no new version SHALL become learner-visible. Partial or unreferenced artifacts MAY be garbage-collected according to E.5.

**E.3 Content Publish Boundary**

Publishing content SHALL:

- Upload binaries first

- Commit metadata and resolution pointer updates atomically in the database

- Transition lifecycle state explicitly

**E.4 Workflow Publish Boundary**

Publishing a BPMN workflow SHALL be a relational transaction that:

- creates a new workflow version record

- records hash, author, and timestamp

- optionally marks the version as production

**E.5 Garbage Collection**

Unreferenced artifacts MAY be garbage collected after a TTL.

Artifacts referenced by learner-accessed executions SHALL NOT be deleted.

**Appendix F. Request and Administrative State Machines**

**F.1 Purpose**

This appendix prevents roadblock states in long-running or administrative operations.

**F.2 Request Types**

The following SHALL be modeled as requests:

- Manual overrides

- Enrollment migrations

- Course update publishes

- Regrade actions

- Identity authority changes requiring approval

**F.3 Required States**

Requests SHALL follow these states:

- REQUESTED

- ACCEPTED

- IN_PROGRESS

- COMPLETED

- REJECTED

- FAILED_RETRYABLE

- FAILED_TERMINAL

All transitions SHALL be recorded as facts.

**F.4 Idempotency**

Requests SHALL have stable UUIDs and SHALL be idempotent.

Retries SHALL reference the same request identifier.

**F.5 Ordin Interaction**

Administrative execution occurs outside Ordin.

Ordin MAY reference request facts when making pedagogical decisions.

**Appendix G. Cache Semantics and Resolution Guarantees**

**G.1 Purpose**

This appendix defines enforceable cache semantics consistent with distributed systems reality.

**G.2 Atomicity at the Resolution Layer**

Atomicity is required at the **resolution pointer**, not at cache nodes.

Resolution pointer updates SHALL be atomic and strongly consistent.

**G.3 Content Addressing**

Learner-accessed content SHALL be immutable and uniquely addressable by identifier, version, and hash.

Caches SHALL NOT serve content that does not match the requested version identity.

**G.4 Versioned URLs and Validators**

Atria SHOULD use versioned URLs and/or strong validators (ETag/hash) such that:

- new versions bypass stale caches

- old versions remain reachable for replay

**G.5 Cache Non-Authority**

Caches are never authoritative.

Canonical truth is defined by:

- relational resolution pointers

- immutable artifacts

- Ordin decisions

**Appendix H. Prospective Change, Migration, and Credential Finality**

**H.1 Credential Finality**

Atria SHALL NOT retroactively invalidate, reinterpret, or revoke a completed course, activity, or credential due to later changes.

Completions and credentials are evaluated under the workflow and artifact versions in effect at the time of completion.

**H.2 Prospective Updates**

Institutions MAY update requirements prospectively by:

- publishing new workflow or content versions

- migrating active enrollments

- applying changes to future cohorts

**H.3 Recertification and Re-Enrollment**

If updated requirements must apply to prior completers, this SHALL be implemented through:

- recertification programs, or

- new enrollment contexts

and SHALL result in new completion records.

**H.4 Separation from Ordin**

Course updates, migrations, and recertification mechanics are administrative lifecycle operations and SHALL NOT be implemented via BPMN or Ordin.

Ordin evaluates pedagogy within an enrollment context; it does not perform bulk administrative changes.

**Revision Addendum 0.1.1 (Normative)**

This addendum is normative and SHALL be considered part of Atria Engineering Spec 0.1. Where it conflicts with earlier text, this addendum SHALL govern.

The purpose of this addendum is to remove implementer ambiguity (including AI-assisted implementation) by defining canonical identifier and time semantics and by enumerating the required “bridge specifications” that MUST exist before the system can be implemented end-to-end.

**Appendix I. Canonical Identifier and Time Semantics (Normative)**

**I.1 Canonical Identifier Classes**

The following identifiers are canonical across all domains, messages, and storage models:

\- tenant_id: UUID identifying the tenant. Physical tenant isolation is enforced by database-per-tenant; tenant_id may still be stored for defense-in-depth.

\- identity_id: UUID of an actor within the tenant. Learners, instructors, admins, and system actors are all identities.

\- subject_id: the identity_id that a fact/claim/request/decision is about (typically the learner). subject_id MUST be an identity_id.

\- actor_id: the identity_id that performed or caused the action (may be the learner, an instructor/admin, or a system actor). actor_id MUST be an identity_id when present.

\- course_id: UUID identifying the conceptual course (or course definition) within the tenant.

\- workflow_version: string or semver identifying the immutable published BPMN workflow version in effect for an enrollment context.

\- enrollment_context_id: UUID binding a subject (learner identity) to a course_id and workflow_version, plus any cohort/session binding required for deterministic execution.

\- activity_uuid: UUID identifying the conceptual pedagogical activity referenced by BPMN tasks and learner interactions.

\- request_id: UUID identifying an administrative or long-running request lifecycle.

\- message_id / evidence_id: UUID identifying an immutable fact, claim, or request transition record in the Evidence Ledger. For persisted evidence records, evidence_id MUST equal message_id (single identifier rule).

\- decision_id: UUID identifying a pedagogical decision produced by Ordin.

\- attempt_id / submission_id / score_id: UUIDs identifying assessment attempt lifecycle, submissions-by-reference, and scoring records.

**I.2 Learner Identity Canonicalization**

“Learner” is not a separate identifier class. The learner identifier used across the platform SHALL be identity_id where identity_type = learner.

Any schema, API, or message that uses the field name learner_id SHALL treat that value as an identity_id unless a more specific type is explicitly defined.

**I.3 Causation, Correlation, and Reference Semantics**

\- correlation_id ties a chain of related messages and decisions (e.g., a learner submission, scoring, and the resulting progression decision).

\- causation_id references the immediate triggering record.

\- correlation_id and causation_id SHALL reference canonical record identifiers (message_id/evidence_id for FACT/CLAIM/REQUEST records, and decision_id for DECISION records).

\- Where a DECISION is projected into the Evidence Ledger (e.g., via an evidence_all view), the projected evidence_id SHALL equal decision_id.

**I.4 Time Semantics**

All timestamps SHALL be stored in UTC.

\- occurred_at: the semantic time at which the underlying event occurred (e.g., learner clicked Submit, tool emitted a completion assertion).

\- recorded_at: the authoritative database insertion time for immutable evidence records.

\- decided_at: the authoritative database insertion time for Ordin decisions.

Ordering for audit and deterministic replay SHALL rely on (recorded_at, evidence_id) for evidence and (decided_at, decision_id) for decisions, not on occurred_at.

occurred_at is preserved for semantic reporting and compliance but SHALL NOT be assumed to be globally monotonic.

**I.5 Determinism and “Time as Input”**

Any workflow behavior that depends on time (deadlines, timers, grace periods) SHALL treat time as an explicit input:

\- BPMN timers SHALL be evaluated using recorded facts that include the relevant timestamp values.

\- If the system must capture “current time” for a decision, it SHALL record that value explicitly as evidence so replay can reproduce the same outcome.

**Appendix J. Required Bridge Specifications (Normative)**

**J.1 Requirement**

The following bridge specifications MUST exist and MUST be treated as binding inputs to implementation. The platform SHALL NOT be considered “spec complete” for end-to-end build until these documents are present and consistent with Specs 0.1–0.3.

**J.2 Required Bridge Specs**

\- Ordin BPMN Execution Spec (defines BPMN subset, extension fields, deterministic runtime semantics, event correlation rules, and workflow publishing/versioning rules).

\- Standards Version and Conformance Registry (pins exact standard versions and supported profiles/surfaces; defines test vectors and upgrade/deprecation policy).

\- Artifact Storage and Reference Spec (defines artifact_ref/payload_ref conventions, hashing algorithms, immutability guarantees, signed URL vs proxied delivery rules, and retention interaction with evidence).

\- HTTP API and HTMX Interaction Spec (defines endpoint contracts, HTMX fragment conventions, error semantics, and OpenAPI coverage requirements).

\- Tenancy Control Plane Spec (defines tenant provisioning, routing, credentials management, migrations across tenants, and isolation enforcement).

**J.3 AI-Assisted Implementation Constraint**

If any bridge spec is missing, ambiguous, or contradictory, implementation SHALL pause and the gap SHALL be resolved by amending the specs. Implementers (human or AI) SHALL NOT “invent” missing semantics that affect learner truth, standards compliance, or audit/replay guarantees.
