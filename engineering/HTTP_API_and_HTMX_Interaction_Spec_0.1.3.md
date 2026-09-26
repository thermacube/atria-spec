HTTP, API, and HTMX Interaction Spec 0.1

*Server-driven UI and integration endpoints for Atria (MVP)*

Revision: 0.1.3 (2025-12-18)

Status: Draft (binding once accepted into the Thermacube/Atria spec set).

**1. Purpose**

This specification defines the minimum HTTP surface required to implement the Atria LMS UI (HTMX-first) and the core JSON integration endpoints. It constrains UI behavior so that hot-path invariants and evidence/decision recording rules remain enforceable.

**2. Interaction Principles**

• Server-rendered HTML is the default. HTMX is used for partial updates and progressive enhancement.

• All state-changing operations MUST be POST/PUT/PATCH/DELETE and MUST create evidence (FACT/CLAIM/REQUEST) as applicable.

• All domain state transitions that affect learner truth MUST be traceable via correlation_id and causation_id.

• UI endpoints MUST avoid chatty APIs: prefer coarse-grained fragments that render complete components.

**3. Authentication and Session**

• Auth SHOULD be via OIDC (institution identity provider) with session cookies for the UI.

• All non-idempotent requests MUST be CSRF-protected (double-submit cookie or synchronizer token).

• System-to-system integrations (e.g., OneRoster import) SHOULD use OAuth2 client credentials and be scoped per tenant.

**4. Request Headers and Idempotency**

Idempotency is mandatory for write endpoints that may be retried by browsers, HTMX, proxies, or integration clients.

• Idempotency-Key: client-provided UUID/string. Required for POST endpoints that create new immutable records (attempts, submissions, evidence ingestion).

• X-Correlation-Id: UUID. If absent, server generates one and echoes it back. Used to link a chain of events across requests.

• X-Causation-Id: UUID. If present, indicates the triggering message/event.

• For HTMX requests, the server MUST handle HX-Request and may use HX-Trigger to notify the client of updates.

**5. Response and Error Semantics**

• HTML endpoints return full pages (text/html) or fragments (text/html) for HTMX.

• JSON endpoints return application/json with a consistent error object: { code, message, details?, correlation_id }.

• Errors MUST include correlation_id for support and audit.

Non-normative note: Learner-visible 'pending' or 'error' screens (including cases where Ordin suspends execution) are UI renderings of canonical progression_state and SHALL NOT imply pedagogical transitions. The UI MUST NOT advance, remediate, or otherwise alter pedagogy; only Ordin decisions and the resulting progression_state updates constitute pedagogical transitions. UI endpoints MAY present friendly messaging mapped from decision_type/state_payload but MUST preserve evidence-driven semantics.

**6. Endpoint Catalogue (MVP)**

This is the minimum endpoint set required to implement learner navigation, content delivery, assessment attempts, and instructor grading.

|        |                                                                     |                          |                                                                                                                                   |
|--------|---------------------------------------------------------------------|--------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| Method | Path                                                                | Purpose                  | Notes / Evidence                                                                                                                  |
| GET    | /login                                                              | Begin OIDC login         | No evidence; redirects to IdP                                                                                                     |
| POST   | /logout                                                             | End session              | No learner truth changes                                                                                                          |
| GET    | /dashboard                                                          | Learner dashboard        | Reads progression_state and course enrollments                                                                                    |
| GET    | /courses/{course_id}                                                | Course overview          | Shows workflow_version and current activity                                                                                       |
| GET    | /courses/{course_id}/activities/{activity_uuid}                     | Activity view            | Renders content/assessment/tool launcher; reads activity_resolution                                                               |
| POST   | /courses/{course_id}/activities/{activity_uuid}/content/access      | Record content access    | Creates ContentAccessRecorded (FACT) (content_version_id required; content_version and content_hash optional)                     |
| POST   | /courses/{course_id}/activities/{activity_uuid}/assessment/attempts | Create new attempt       | Creates AssessmentAttemptStarted (FACT); allocates attempt_number via counter                                                     |
| POST   | /attempts/{attempt_id}/submissions                                  | Submit attempt           | Creates AssessmentAttemptSubmitted (FACT) and AssessmentAttemptCompleted (FACT)                                                   |
| GET    | /instructor/courses/{course_id}                                     | Instructor course view   | Lists submissions needing grading; role required                                                                                  |
| POST   | /instructor/submissions/{submission_id}/grade                       | Record score             | Creates AssessmentScoreComputed (FACT); may trigger Ordin decisions; regrades emit AssessmentScoreSuperseded (FACT) as applicable |
| POST   | /admin/courses/{course_id}/publish                                  | Publish workflow version | Creates CourseVersionPublished (FACT); writes workflow_definition + activity_resolution                                           |

**7. HTMX Conventions**

• Fragments SHOULD be addressable via GET endpoints (e.g., /courses/{course_id}/\_fragments/progress).

• POST endpoints SHOULD respond with either: (a) 204 + HX-Trigger, or (b) an updated fragment to swap into the page.

• Navigation MUST remain functional without JavaScript (baseline HTML).

**8. Performance Constraints**

• Hot-path learner actions (content access, attempt creation, submission) MUST be bounded to constant-time database operations as required by Spec 0.3.

• Endpoints that trigger Ordin decisions MUST not block on external network calls.
