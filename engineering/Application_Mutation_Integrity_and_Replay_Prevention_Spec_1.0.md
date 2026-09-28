# Thermacube Mutation Integrity and Replay Prevention Specification

## Version 1.0

**Date:** September 28, 2026  
**Status:** Draft normative cross-application engineering standard  
**Canonical home:** `thermacube/atria-spec`  
**Initial adopters:** Atria, CECPD Bridge, Thermacube Communications (Comms)

---

## 1. Purpose

This specification defines how Thermacube applications protect state-changing operations against duplicate submission, request replay, retry ambiguity, concurrent execution, and cross-request mutation confusion.

Its goal is **effectively-once business behavior** where a user or machine intends one operation, even when the underlying HTTP request may be delivered, retried, refreshed, resubmitted, or executed concurrently more than once.

The standard applies to browser forms, HTMX mutations, conventional HTTP POSTs, local bounded-application calls, machine APIs, provider callbacks, background handoff, and other state-changing application entry points.

This specification deliberately distinguishes:

- **CSRF protection** — whether a browser mutation came from an authorized application interaction;
- **replay prevention** — whether a previously valid request/capability may be reused;
- **idempotency** — whether retrying the same intended mutation produces only one business effect;
- **authorization** — whether the current actor may perform the operation;
- **domain validation** — whether the requested operation is valid for current business state.

These controls cooperate but are not interchangeable.

---

## 2. Governing principle

> A state-changing request may be delivered more than once; the application must make the intended business effect safe.

Client behavior is not a correctness boundary.

A conforming application MUST NOT depend on any of the following to prevent duplicate business effects:

- disabling a submit button;
- HTMX `hx-sync`;
- JavaScript flags;
- browser navigation behavior;
- a single PHP process;
- an in-memory mutex;
- the user refraining from refresh/back/retry;
- a reverse proxy delivering a request only once;
- a CSRF token being single-use.

User-interface suppression remains valuable, but durable server-side mutation integrity is authoritative.

---

## 3. Relationship to other Thermacube standards

### 3.1 Application Request Perimeter

The Application Request Perimeter answers:

> Is this request structurally acceptable for application processing?

Mutation Integrity answers:

> If this request is state-changing, is it legitimate to execute now, and can it execute without duplicate business effect?

The Request Perimeter MUST NOT become the durable replay/idempotency store.

### 3.2 Authentication and authorization

Authentication/session establishment identifies the actor or application.

Authorization determines whether that actor/application may perform the operation against the current resource.

Mutation integrity MUST NOT grant authority and MUST NOT reuse a prior authorization decision without re-evaluating current authority where the application contract requires current authorization.

### 3.3 HTMX Integration

HTMX controls such as:

```html
hx-sync="this:drop"
hx-disabled-elt="find button[type=submit]"
```

SHOULD be used where appropriate to suppress accidental concurrent submissions and improve user experience.

They are defense-in-depth only. Server-side mutation integrity remains mandatory.

### 3.4 Accessibility

Security and replay controls MUST preserve accessible forms, keyboard operation, understandable errors, retry behavior, and recovery from validation failures.

A replay/idempotency mechanism MUST NOT require inaccessible client scripting as its only means of operation.

---

## 4. Architectural position

A typical authenticated browser mutation follows:

```text
Ingress / CrowdSec
  -> runtime or host adapter
  -> Application Request Perimeter
  -> authentication / session resolution
  -> browser mutation classification
  -> CSRF / origin / Fetch Metadata checks
  -> current authorization
  -> mutation integrity / replay-idempotency boundary
  -> domain transaction / durable side-effect handoff
  -> audit / response
```

The precise order of authorization and durable mutation reservation MAY vary where an implementation requires current object state before reservation, but:

1. structural perimeter checks occur before normal mutation processing;
2. browser CSRF checks occur before a browser mutation is accepted;
3. authorization is authoritative for the current attempt;
4. the durable replay/idempotency boundary is established **before the first non-repeatable business side effect**;
5. domain effects and mutation state are transactionally coupled where they share the same database.

Anonymous one-time capability workflows, such as account recovery, use capability validation/consumption as their workflow-specific authentication boundary.

---

## 5. Mutation classification

Every application MUST explicitly classify state-changing operations into one of the following behavioral classes.

### 5.1 Class R — read-only

Examples:

- GET a report;
- render a form;
- fetch a message thread;
- retrieve a quote without reserving or purchasing.

Class R operations MUST use safe/read-only HTTP semantics and MUST NOT produce requested business mutations.

Incidental logging/telemetry does not convert a read into a business mutation.

### 5.2 Class S — state-set / naturally idempotent mutation

Examples:

- mark a record opened;
- close an already-closed conversation;
- set a preference to a specific value;
- revoke an already-revoked credential.

Repeating the same intended operation produces the same business state.

The domain invariant MAY itself provide idempotency when protected by durable database constraints/conditional updates and concurrency tests.

### 5.3 Class C — create / append / consequential mutation

Examples:

- create a ticket;
- send a message;
- append a reply;
- send a chat message;
- create an application;
- create an enrollment;
- issue a credential;
- create an order;
- initiate payment/refund;
- submit a survey where duplicate rows would be incorrect;
- enqueue an outbound communication.

Class C operations MUST have durable idempotency identity.

The same intended mutation retried with the same idempotency identity MUST NOT create another business effect.

### 5.4 Class O — one-time capability

Examples:

- passwordless/magic sign-in link;
- account-recovery confirmation;
- browser launch exchange;
- single-use invitation or approval capability where policy requires one use.

A successful Class O capability is consumed exactly once.

Subsequent replay MUST fail closed rather than reproduce the original privileged action.

### 5.5 Class P — provider/webhook event

Provider callbacks MUST use the provider's authenticated event identity where available and MUST durably deduplicate already-processed events.

Cryptographic provider verification occurs independently of replay/idempotency state.

Where a provider supplies an event timestamp/replay window, the application SHOULD enforce it in addition to durable event-ID deduplication.

### 5.6 Class M — machine/application mutation

External machine consumers and retryable cross-application mutations MUST carry or derive a stable idempotency identity.

Application credentials authenticate the caller; they do not make repeated mutations safe.

---

## 6. Browser CSRF integrity

State-changing browser operations MUST be protected against CSRF independently of replay/idempotency.

For stateful browser applications, the application MUST use a server-validated, session/user-bound CSRF mechanism appropriate to the host/runtime.

Acceptable patterns include:

- synchronizer CSRF tokens maintained by the application session;
- a host-native CSRF mechanism that provides equivalent authenticated request binding, such as a correctly validated WordPress action/user nonce.

CSRF tokens are not replay-prevention identifiers. A token MAY remain valid for multiple legitimate mutations according to the host security model.

Browser mutation defenses SHOULD additionally include, where deployment/runtime supports them:

- `SameSite` session-cookie policy;
- exact `Origin` validation for mutations;
- Fetch Metadata validation such as `Sec-Fetch-Site`;
- POST or another explicitly unsafe mutation method rather than GET.

A valid CSRF decision does not make a request idempotent.

---

## 7. Server-issued mutation identity

Class C browser forms MUST carry a high-entropy opaque mutation/submission identifier generated by the server.

Recommended baseline:

- at least 128 bits of CSPRNG entropy;
- 256 bits preferred for generic opaque identifiers;
- URL/form-safe encoding;
- no embedded identity, role, object, authorization, or business claims.

Suggested conceptual field:

```text
mutation_id
```

Applications MAY use a domain-specific name such as `submission_id`, `checkout_attempt`, or `idempotency_key` when the meaning is clearer, provided the same integrity guarantees apply.

The identifier is not an authorization credential.

---

## 8. Scope binding

A durable idempotency identity MUST be scoped tightly enough that unrelated actions cannot collide or replay one another.

The effective uniqueness scope SHOULD include, as applicable:

- application;
- authenticated human or machine actor;
- operation/mutation type;
- target resource or workflow when required;
- mutation/idempotency identifier.

A key issued to one actor MUST NOT be reusable by another actor.

A key issued for one operation MUST NOT authorize or deduplicate a different operation.

Session binding MAY be added where useful, but actor-bound business retries that legitimately survive session renewal SHOULD use an actor/application scope rather than unnecessarily failing after session rotation.

---

## 9. Canonical payload binding

For Class C operations, the application MUST bind the idempotency identity to the material meaning of the accepted mutation.

After schema/domain normalization and before non-repeatable side effects, the application SHOULD compute a canonical payload fingerprint over the fields that materially determine the business effect.

The fingerprint MUST exclude irrelevant transport/security values such as:

- CSRF token;
- cookie/session token;
- request ID/correlation ID;
- HTMX headers;
- presentation locale unless locale changes the authoritative business effect;
- transient client timestamps not authoritative to the operation.

The fingerprint SHOULD include:

- normalized authoritative user input;
- target/resource identity;
- selected method/option where it changes the effect;
- server-derived values necessary to distinguish materially different business operations.

If the same idempotency identity is presented with a different material fingerprint after the key has been claimed, the request MUST fail closed as an idempotency conflict.

It MUST NOT silently perform the changed action under the old identity.

---

## 10. Durable mutation record

A Class C implementation SHOULD maintain a durable mutation record or an equivalent domain uniqueness structure.

A generic record may contain:

- mutation/idempotency key digest;
- application/operation;
- actor/application scope;
- target/resource scope if applicable;
- canonical payload fingerprint;
- state such as `pending`, `succeeded`, `failed_retryable`, `failed_final`;
- stable business-result reference;
- creation/update/expiry timestamps;
- bounded non-sensitive failure metadata.

Raw secrets and request bodies MUST NOT be copied into the mutation record.

Random mutation identifiers are normally not credentials, but telemetry SHOULD still avoid logging complete reusable identifiers. Implementations MAY store only a cryptographic digest.

---

## 11. Concurrency and atomicity

Duplicate prevention MUST remain correct when two or more workers receive the same mutation concurrently.

A conforming implementation MUST use durable database primitives such as:

- a unique constraint;
- conditional insert/update;
- row locking;
- transactionally protected domain uniqueness;
- an equivalent durable compare-and-set mechanism.

Process memory, PHP statics, file-local booleans, JavaScript state, or a single-worker assumption are insufficient.

Where the mutation record and business rows share the same MariaDB authority, the idempotency claim and authoritative business effect SHOULD commit atomically in one transaction whenever practical.

---

## 12. Retry behavior

### 12.1 Same key, same accepted payload

If a Class C request repeats the same key with the same material fingerprint:

- it MUST NOT repeat the business effect;
- if the first mutation succeeded, the application SHOULD return the established result or a current representation of it;
- if the first mutation is still processing, the application SHOULD return a deterministic pending/in-progress result rather than start another execution;
- if the first attempt failed before any durable effect and policy permits retry, the same key MAY resume/retry through an explicit retryable state.

### 12.2 Same key, different payload

The request MUST fail as an idempotency conflict.

### 12.3 Missing or malformed key

For an operation classified as requiring durable idempotency, absence or invalid format MUST fail before the consequential effect.

### 12.4 New intentional action

After a completed action, a newly rendered form/action for a genuinely new business operation MUST receive a new mutation identity.

A user must be able to intentionally send a second message or submit a second valid business operation; replay prevention must not become accidental permanent deduplication by content.

---

## 13. Validation errors

Syntactic/schema validation SHOULD occur before a Class C key is durably bound to a material fingerprint when no business side effect has occurred.

This permits a user to correct validation errors without being trapped by the original invalid submission.

Once a mutation identity has crossed the durable consequential-operation boundary, payload binding is fixed.

Applications MUST preserve accessible error recovery and SHOULD preserve entered form values where security/business rules allow.

---

## 14. External side effects and provider handoff

Database idempotency alone is insufficient when a mutation causes an external side effect such as:

- payment-provider action;
- email delivery;
- SMS/PSTN action;
- webhook publication;
- file/object-store publication;
- another external service mutation.

The application MUST establish a durable local intent/claim before provider handoff.

Preferred patterns include:

- transactional outbox;
- durable provider-neutral job/handoff record;
- provider idempotency key derived from the authoritative mutation identity;
- provider event reconciliation where supported.

If the provider supports idempotency keys, the application SHOULD reuse the same stable provider idempotency identity for retries of the same business action.

A timeout after provider submission MUST be treated as an ambiguous outcome requiring reconciliation/retry-safe handling, not as proof that the provider did nothing.

---

## 15. One-time capability semantics

Class O capabilities MUST:

- be generated from a CSPRNG;
- be short-lived;
- be bound to the intended purpose and relevant subject/context;
- avoid embedding mutable authorization claims when server-side state can be used;
- be stored as a cryptographic digest where practical;
- be consumed atomically;
- fail identically for expired, fabricated, wrong-purpose, wrong-binding, and replayed values where information disclosure would be harmful.

The capability MUST be consumed before the privileged side effect it authorizes.

A GET request SHOULD NOT consume a login/recovery capability when email/link scanners may retrieve the URL automatically. A confirmation POST or equivalent explicit unsafe action SHOULD perform consumption.

Class O replay returns failure; it does not return the prior privileged effect.

---

## 16. HTMX and progressive enhancement

HTMX-enhanced mutations MUST retain the same server-authoritative replay/idempotency semantics as ordinary form submissions.

Where appropriate, forms SHOULD use:

```html
hx-sync="this:drop"
hx-disabled-elt="find button[type=submit]"
```

or an equivalent documented interaction policy.

These controls reduce accidental in-flight duplication but MUST NOT replace durable mutation identity.

The same mutation identifier MUST normally survive an automatic/ambiguous retry of the same intended action.

A newly rendered fresh-action form receives a new identifier.

---

## 17. Local bounded-application calls

Same-process calls are not exempt from mutation integrity.

For retryable Class C local operations:

- the caller MUST provide or deterministically derive a stable idempotency identity for the intended business action;
- the callee MUST own the durable duplicate-effect boundary for the state it owns;
- the caller MUST NOT generate a fresh random key for each retry of the same intended action;
- local transport does not permit bypassing current callee authorization or domain validation.

Read-only Bridge↔Comms calls remain unaffected.

---

## 18. Machine APIs

Machine/application mutations MUST authenticate the application separately from idempotency.

For Class M create/append/consequential operations, the API contract MUST define where the idempotency identity appears, for example:

- an application field;
- an HTTP idempotency header;
- a stable external operation/event ID.

The application MUST scope the key to the authenticated machine application and operation.

Machine retries after connection loss must not produce duplicate business effects.

---

## 19. Provider callbacks and webhooks

Signed webhook processing follows this order conceptually:

```text
signed_webhook perimeter
  -> exact raw-body signature verification
  -> provider timestamp/replay-window checks where applicable
  -> provider event identity normalization
  -> durable event deduplication
  -> domain processing
```

The Request Perimeter MUST NOT alter signed bytes.

A valid signature does not imply the event has not already been processed.

Provider event IDs, call/message IDs, checkout/session IDs, or equivalent stable identifiers SHOULD be used for durable deduplication according to provider semantics.

---

## 20. Response and status behavior

Applications SHOULD provide deterministic responses for retries.

Recommended behavior:

- successful first execution: normal success;
- same-key/same-payload retry after success: return/reconstruct the established result;
- same-key/same-payload while pending: pending/in-progress response;
- same-key/different-payload: conflict;
- expired/invalid one-time capability: generic unavailable/expired response;
- replayed one-time capability: same generic unavailable response where disclosure is undesirable.

Exact HTTP status codes MAY vary by application contract, but semantics must be documented and testable.

---

## 21. Retention and cleanup

Mutation/idempotency records need not be retained forever.

Each application MUST define retention long enough to cover realistic:

- user refresh/back behavior;
- client retries;
- proxy/network ambiguity;
- background retry windows;
- provider reconciliation windows.

Cleanup MUST NOT occur so early that an ordinary delayed retry can recreate the business effect.

Long-lived domain uniqueness MAY supersede a temporary generic mutation record where the domain itself permanently prevents duplication.

One-time capability retention follows its explicit short TTL.

---

## 22. Security telemetry and audit

Mutation-integrity telemetry SHOULD record bounded metadata such as:

- application;
- operation;
- outcome (`first_execution`, `replay_result`, `conflict`, `expired`, `capability_replay`);
- actor/application identifier where policy allows;
- business-result identifier where non-sensitive;
- correlation/request ID;
- stable rule/event identifier.

Telemetry and audit MUST NOT include:

- CSRF tokens;
- session cookies/tokens;
- one-time capability plaintext;
- passwords;
- provider secrets;
- full form/message/chat bodies merely for replay logging;
- full payment instruments.

A legitimate same-key retry after an ambiguous timeout is not automatically a security incident.

Repeated cross-user, wrong-operation, conflicting-payload, or fabricated-key attempts MAY be emitted as security telemetry.

---

## 23. Persistent-worker / RoadRunner requirements

All mutation integrity state MUST be request-local or durable.

No conforming implementation may rely on mutable process-global/static state for:

- used mutation IDs;
- CSRF decisions;
- current actor;
- replay counters;
- pending mutation ownership;
- payload fingerprints;
- provider event deduplication.

Two unrelated users processed sequentially by one worker must remain fully isolated.

Concurrency tests MUST include multiple database connections/process-equivalent execution where practical.

---

## 24. Required conformance tests

Each adopter MUST test the mutation classes it implements.

### 24.1 Browser / Class C

Required tests include:

- ordinary first submission succeeds;
- immediate double submission creates one business effect;
- sequential exact replay creates one business effect;
- two concurrent submissions with the same key create one business effect;
- refresh/retry after simulated lost response returns the established result;
- same key with changed material payload fails;
- same key from another actor fails;
- same key for another operation fails;
- malformed/missing key fails where required;
- validation failure remains recoverable without duplicate effect;
- fresh intentional second action with a new key succeeds;
- HTMX duplicate-suppression controls exist where required but server tests prove correctness without relying on them.

### 24.2 CSRF

Required tests include:

- valid same-session CSRF submission succeeds;
- missing/invalid CSRF token fails for authenticated browser mutations;
- cross-origin browser mutation fails where Origin enforcement is used;
- contradictory Fetch Metadata fails where that defense is enabled;
- CSRF token reuse alone does not bypass idempotency/replay rules.

### 24.3 One-time capabilities / Class O

Required tests include:

- valid capability succeeds once;
- exact replay fails;
- concurrent consumption permits only one success;
- expired capability fails;
- wrong purpose/binding fails;
- stored state does not retain plaintext capability where hashing is required;
- GET does not consume login/recovery capability when scanner-safe confirmation is required.

### 24.4 Provider/webhook / Class P

Required tests include:

- signature verification receives exact raw bytes;
- first valid provider event processes;
- duplicate provider event does not repeat domain effect;
- invalid signature never reaches domain mutation;
- configured timestamp/replay-window policy is enforced where applicable.

### 24.5 Persistent-worker and concurrency

Required tests include:

- alternating actors in one process;
- retries through separate database connections;
- rollback/failure does not leave an incorrectly successful mutation record;
- succeeded mutation cannot be re-executed after worker restart.

---

## 25. Application adoption requirements

An application conforms to v1.0 when:

1. the application specification adopts this exact standard/version;
2. state-changing operations are explicitly classifiable under Section 5;
3. browser mutations have an appropriate CSRF boundary;
4. Class C operations have durable server-side idempotency identity;
5. Class O capabilities are atomically consume-once;
6. Class P provider events are durably deduplicated;
7. same-key/different-payload conflicts fail closed;
8. concurrent duplicate execution is prevented by durable database/domain primitives;
9. provider/external side effects have retry-safe durable handoff;
10. HTMX/client suppression is not treated as the correctness boundary;
11. persistent-worker isolation requirements are met;
12. required conformance tests exist and pass.

An application MAY adopt the specification normatively before implementation conformance is complete, but its project documentation MUST state that implementation conformance is pending rather than claiming completed conformance.

---

## 26. Initial application guidance

### 26.1 CECPD Bridge

Bridge already contains specialized patterns that align with this standard:

- WordPress-authenticated mutation CSRF validation;
- one-time account-recovery form capabilities;
- one-time magic-link consumption;
- checkout-attempt/idempotency identity;
- domain-level duplicate handling in selected workflows.

Bridge adoption SHALL generalize the standard across consequential browser/domain mutations rather than replace sound existing specialized behavior.

### 26.2 Thermacube Communications (Comms)

Comms already contains:

- POST-only browser mutation classification;
- exact-origin and Fetch Metadata browser mutation checks;
- secure session cookies;
- one-time browser-launch grants;
- HTMX in-flight duplicate suppression;
- idempotent domain transitions for selected state-set operations.

Comms adoption SHALL add a session-bound CSRF token mechanism for authenticated browser mutations and durable idempotency identity for create/append/consequential operations such as message creation, ticket submission, replies, chat sends, and other applicable mutations.

### 26.3 Atria

Atria platform/runtime adoption SHALL apply the same mutation classes at the application funnel and module boundaries.

Arbitis authorization remains independent and authoritative. Mutation identity does not grant rights.

---

## 27. Non-goals

This standard does not replace:

- Application Request Perimeter screening;
- authentication;
- authorization;
- rate limiting/anti-abuse controls;
- parameterized SQL;
- output encoding;
- provider signature verification;
- CrowdSec/ingress controls;
- domain invariants;
- audit logging;
- transaction design.

It does not promise exactly-once network delivery.

It defines the controls necessary for effectively-once intended business effects despite duplicate delivery.

---

## 28. References

Normative application behavior is defined by this Thermacube specification.

External references informing the standard include:

- RFC 9110, **HTTP Semantics**, especially safe and idempotent method semantics;
- OWASP Cheat Sheet Series, **Cross-Site Request Forgery Prevention**, including synchronizer-token and defense-in-depth browser guidance.

Applications do not automatically adopt future revisions of those external documents without review.

---

## 29. Security philosophy summary

> Assume state-changing requests can be duplicated. Authenticate and authorize the current actor, bind browser mutations to a legitimate interaction, give consequential actions durable identity, make retries return the already-established result instead of repeating the effect, and consume true one-time capabilities atomically.
