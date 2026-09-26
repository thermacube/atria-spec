Ordin BPMN Execution Spec 0.1

*Deterministic workflow execution for Atria*

Revision: 0.1.1 (2025-12-16) - Activity resolution alignment.

Status: Draft (binding once accepted into the Thermacube/Atria spec set).

**1. Purpose**

This specification defines the normative runtime semantics for executing BPMN-based course workflows in Ordin. It is required to implement deterministic progression, auditability, and replay as required by Atria Engineering Spec 0.1 and Spec 0.3.

**2. Core Concepts**

• Workflow Definition: A published BPMN model bound to (course_id, workflow_version) and stored immutably (workflow_definition in Spec 0.3).

• Execution Instance: The per-enrollment execution of a workflow, identified by enrollment_context_id.

• Token: A marker representing an enabled path through the BPMN graph.

• Gate: A BPMN element that waits for evidence (FACT/CLAIM/REQUEST) to proceed (e.g., an event, a boundary event, or a condition on a gateway).

• Decision: An Ordin decision row that records the evaluation of evidence and the resulting state transition.

**3. Allowed BPMN Subset (MVP)**

To preserve determinism and constrain implementation complexity, Ordin v0 SHALL support only the following BPMN elements and semantics.

**3.1 Structural Elements**

• StartEvent (none start only).

• EndEvent.

• SequenceFlow.

• ExclusiveGateway (XOR) with condition expressions.

• ParallelGateway (AND split/join).

• SubProcess (embedded, collapsed only; no call activities).

**3.2 Activity Elements**

• UserTask: Represents a learner-facing activity and MUST reference an activity_uuid via extension attributes (Section 4).

• ServiceTask: Represents a system-controlled activity (e.g., automatic issuance, sync). ServiceTask MUST be deterministic and MUST NOT make network calls during hot-path evaluation.

**3.3 Event Elements (Evidence-Driven)**

• IntermediateCatchEvent (message catch): waits for a specified evidence subtype (Section 5).

• BoundaryEvent (timer): optional in v0; when supported, timers are evaluated deterministically from stored timestamps and do not rely on wall-clock schedulers for correctness.

All other BPMN elements (inclusive gateways, event-based gateways, compensation, complex gateways, call activities, ad-hoc subprocesses, choreography, etc.) are out of scope for v0 and SHALL be rejected at publish time.

**4. BPMN Extension Attributes**

Ordin relies on extension attributes on BPMN elements to bind workflow graph nodes to canonical Atria identifiers.

**4.1 Required Extensions on Learner Activities**

Each UserTask representing a learner-facing activity MUST include:

• atria:activity_uuid (UUID, required) - stable activity identity used for completion semantics.

• atria:activity_type (ENUM: content, assessment, tool, external) - used by UI/runtime routing.

• atria:completion_mode (ENUM: evidence_fact, decision_only) - default evidence_fact.

If the workflow requires binding an atria:activity_uuid to a concrete runnable target (content version, assessment version, or external tool deployment), that binding SHALL be persisted at publish time in Spec 0.3 activity_resolution and SHALL be resolvable in constant time at execution time using (course_id, workflow_version) → workflow_definition_id and (workflow_definition_id, activity_uuid). Ordin MAY include the resolved binding identifiers in decision metadata for audit/replay, but Ordin SHALL NOT discover or mutate bindings at runtime.

**4.2 Optional Extensions**

• atria:required_entitlement_type - if present, Ordin MUST verify entitlement before enabling the task.

• atria:grading_policy_ref - reference to grading policy artifact for assessment tasks.

• atria:ui_label - non-normative display label.

**5. Evidence-Driven Semantics**

Ordin progression is driven exclusively by persisted evidence (FACT/CLAIM/REQUEST) and prior decisions. Ordin MUST NOT depend on transient in-memory state for correctness.

**5.1 Evidence Matching**

A catch event or task completion condition matches incoming evidence if ALL of the following hold:

• tenant_id matches the current tenant database.

• enrollment_context_id matches the execution instance.

• If an activity_uuid is specified for the gate, activity_uuid matches.

• subtype matches the expected subtype (exact match; no pattern matching in v0).

• Any additional predicate defined on the BPMN element's condition expression evaluates true against the evidence payload (Section 6).

**5.2 Canonical Completion Evidence**

A learner activity is considered complete when Ordin records a decision that transitions the workflow beyond the activity and references completion evidence. For v0, the canonical completion evidence messages are:

• ContentAccessRecorded (FACT) for content activities (with completion semantics as defined by policy).

• AssessmentAttemptCompleted (FACT) and/or AssessmentScoreComputed (FACT) for assessment activities, depending on BPMN conditions.

• ToolLaunchCompleted (FACT) and/or ToolCompletionClaimReceived (CLAIM) for tool activities, depending on BPMN conditions and tool integration capabilities.

**6. Condition Expressions**

ExclusiveGateway conditions and completion predicates are evaluated deterministically against evidence payloads and cached state. v0 supports a constrained expression language:

• Boolean conjunction/disjunction (AND/OR) and comparison operators (=, !=, \<, \<=, \>, \>=).

• Field references into payload_json using JSON pointer syntax (e.g., /score/value).

• No function calls, loops, network I/O, or access to external time sources.

Any condition expression that cannot be evaluated within this subset SHALL fail publish-time validation.

**7. State Model and Persistence**

Ordin MUST persist enough state to resume execution deterministically.

**7.1 Canonical Persisted State**

• progression_state.current_activity_uuid (for UI convenience).

• progression_state.state_payload JSON containing at minimum: active_bpmn_element_ids (list), active_tokens (list), workflow_version, and any deterministic counters required by the workflow.

• decision table rows recording each evaluation and transition (Spec 0.3).

**7.2 Transition Rules**

• On message ingestion that may affect progression, Ordin evaluates enabled gates and conditions.

• If a transition occurs, Ordin writes one decision row and updates progression_state in the same relational transaction (hot path).

• Ordin MUST reference the triggering evidence via causation_id and store evaluated_evidence_ids for audit.

**8. Determinism and Replay**

Replay SHALL produce the same progression decisions given the same sequence of evidence messages and published workflow definitions.

• Randomness is prohibited unless seeded by an explicit FACT recorded in evidence (Spec 0.1 controlled variability).

• Timer evaluation, if enabled, MUST be computed from recorded evidence timestamps (occurred_at/recorded_at) and MUST not depend on wall-clock scheduling order.

• Side effects (e.g., credential issuance) MUST be modeled as REQUEST/FACT messages and MUST NOT be performed during pure decision evaluation.

**9. Publish-Time Validation**

On publishing a workflow_definition, the system MUST validate:

• Only allowed BPMN elements are used.

• Every UserTask has atria:activity_uuid and atria:activity_type.

• Every referenced activity_uuid has a corresponding activity_resolution row for the governing workflow_definition_id (resolvable from course_id + workflow_version).

• All condition expressions are within the supported subset.

• The workflow has exactly one none StartEvent and at least one EndEvent.
