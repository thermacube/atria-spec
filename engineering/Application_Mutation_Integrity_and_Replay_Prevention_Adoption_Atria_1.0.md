# Atria Mutation Integrity and Replay Prevention Adoption

**Adopted standard:** Thermacube Mutation Integrity and Replay Prevention Specification v1.0  
**Canonical specification:** `thermacube/atria-spec/engineering/Application_Mutation_Integrity_and_Replay_Prevention_Spec_1.0.md`

## 1. Scope

Atria adopts the shared mutation-integrity standard at the platform/application-funnel level.

Atria modules MUST NOT invent weaker retry/replay semantics for state-changing operations merely because a module executes inside the majestic monolith or through a local call.

This adoption is normative immediately. Implementation conformance is considered pending until the corresponding platform/module code and conformance tests are completed.

## 2. Required request order

For externally originated browser mutations:

```text
Ingress / CrowdSec
  -> Atria runtime adapter
  -> Application Request Perimeter
  -> identity/session establishment
  -> CSRF/origin/fetch-metadata checks
  -> Arbitis/application authorization
  -> mutation integrity / replay-idempotency boundary
  -> module/domain transaction
  -> audit/response
```

For external machine consumers:

```text
Ingress / CrowdSec
  -> Atria runtime adapter
  -> Application Request Perimeter
  -> machine/application authentication
  -> application authorization
  -> mutation integrity / idempotency boundary
  -> module/domain transaction
```

## 3. Arbitis interaction

Arbitis remains the authoritative policy decision point for governed-object authorization.

Mutation IDs, submission IDs, idempotency keys, provider event IDs, and one-time capabilities MUST NOT grant Arbitis rights.

Current authorization is re-evaluated as required by the application contract before mutation effects occur.

## 4. Mutation classification

Atria platform and module entry points SHALL classify state-changing operations according to the shared standard:

- Class R — read-only;
- Class S — state-set / naturally idempotent;
- Class C — create / append / consequential;
- Class O — one-time capability;
- Class P — provider/webhook event;
- Class M — machine/application mutation.

Class C and Class M create/append/consequential operations require durable idempotency identity.

Class O capabilities require atomic consume-once semantics.

Class P callbacks require provider authentication plus durable event deduplication.

## 5. Browser mutations

State-changing browser operations SHALL use Atria's authoritative browser CSRF mechanism and SHOULD apply exact-origin / Fetch Metadata defense-in-depth where the runtime contract supports it.

CSRF state is independent of idempotency.

A valid CSRF token does not permit the same consequential mutation to execute twice.

## 6. Module boundaries

Where one Atria module invokes another locally:

- the caller carries or derives stable idempotency identity for retryable consequential actions;
- the callee owns duplicate-effect prevention for the domain state it owns;
- local execution does not bypass current authorization or domain validation;
- read-only calls do not require mutation identity merely because they cross a module boundary.

## 7. Database and concurrency

Atria implementations MUST use durable MariaDB/domain constraints, conditional writes, row locks, unique keys, or equivalent durable compare-and-set semantics.

No replay or duplicate-effect guarantee may depend on PHP process memory, request globals, worker identity, or client-side state.

Where mutation metadata and domain state share one database authority, they SHOULD commit atomically.

## 8. External provider handoff

When Atria mutations trigger external effects, the platform/module SHALL establish a durable local intent before provider handoff.

Provider idempotency keys SHOULD derive from the authoritative Atria mutation identity where supported.

Timeouts after provider submission are treated as ambiguous outcomes and reconciled rather than blindly repeated.

## 9. Persistent-worker invariant

Replay/idempotency state is either request-local or durable.

The following MUST NOT leak across RoadRunner worker invocations:

- current mutation identity;
- actor/session authority;
- CSRF decision;
- payload fingerprint;
- replay outcome;
- provider event identity;
- pending-operation ownership.

## 10. Conformance testing

Atria implementation conformance requires tests for the mutation classes actually implemented, including:

- first execution;
- sequential replay;
- concurrent replay;
- same-key/different-payload conflict;
- cross-actor and cross-operation reuse;
- retry after simulated lost response;
- fresh intentional second action;
- one-time capability replay/concurrency;
- provider-event deduplication where applicable;
- same-process unrelated-user isolation;
- persistence of successful duplicate-effect prevention across worker/process restart.

## 11. Implementation status

This adoption document establishes the Atria requirement.

It does not itself claim that every existing Atria mutation already conforms. Code and test changes are tracked separately and must be completed before implementation conformance is asserted.
