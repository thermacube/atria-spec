# Atria Application Request Perimeter Adoption

**Adopted standard:** Thermacube Application Request Perimeter Specification v1.0  
**Canonical specification:** `thermacube/atria-spec/engineering/Application_Request_Perimeter_Spec_1.0.md`

## 1. Scope

The Application Request Perimeter is an Atria platform capability. Individual Atria modules do not independently invent or own Internet-facing hostile-request filters when traffic enters through the normal Atria runtime.

The platform perimeter applies before ordinary Atria request dispatch and before module-specific schema or domain validation.

## 2. Required request order

For externally originated requests:

```text
Ingress / CrowdSec
  -> Atria runtime adapter
  -> Application Request Perimeter (atria_http)
  -> transport/API contract validation
  -> identity establishment
  -> Arbitis/application authorization
  -> tenant/module routing and application funnel
  -> module/domain logic
```

The perimeter MUST remain distinct from authentication, Arbitis authorization, tenancy authority, and module-specific schema validation.

## 3. Tenancy interaction

A request MUST NOT gain tenant-database access merely because it passes the perimeter.

Tenant resolution remains governed by the Tenancy Control Plane specification. The perimeter may reject malformed host/path/request structure before tenant resolution, but tenant identity and database routing remain separate responsibilities.

## 4. HTTP and HTMX interaction

The HTTP/HTMX runtime adapter normalizes transport input into the application request representation consumed by the perimeter.

The perimeter may enforce method/path/header/body structural limits and route-profile expectations. HTMX requests remain ordinary authenticated application requests and do not receive a weaker security policy.

CSRF requirements for state-changing browser interactions remain governed by the HTTP/HTMX and application authentication specifications.

## 5. Arbitis interaction

Arbitis remains the authoritative policy decision point for governed-object authorization.

The request perimeter MUST NOT:

- infer or grant Atria roles;
- convert structural allow/deny decisions into rights decisions;
- cache per-user authorization;
- replace Arbitis relationship/policy evaluation.

A perimeter allow result means only that processing may continue to identity and authorization logic.

## 6. Module validation

Module-specific contracts remain downstream.

Examples:

- Quorum OpenAPI validation follows the perimeter.
- Ordin BPMN operation validation follows the perimeter.
- Arkiv/H5P content and publishing validation follows the perimeter.
- future module schemas follow the same pattern.

Modules may define stricter structural bounds where their contract requires them, but must not weaken the platform perimeter.

## 7. Local module calls

Same-process module-to-module calls use bounded local capability contracts rather than Internet-oriented content filtering.

Local callers must provide explicit operation/payload/context; callees retain their own authorization and domain authority.

Free-form technical or communication content must not be rejected merely because it resembles an attack string.

## 8. Persistent-worker invariant

Atria perimeter implementations must be RoadRunner-safe.

Request identity, source, route, decision, violation list, request ID, user state, and mutable counters must not persist between requests. Immutable policy tables may be reused only if they cannot be modified by request processing.

## 9. Telemetry

High-confidence perimeter rejections emit structured security events suitable for central logging and optional CrowdSec parsing.

Application code detects and reports; ingress/CrowdSec owns adaptive blocking and long-term IP reputation.

## 10. Conformance tests

Atria conformance requires:

- structural rejection tests;
- false-positive tests for legitimate code/HTML/SQL/path text;
- same-worker allow/reject isolation tests;
- transport-neutral perimeter tests;
- module-specific tests proving downstream validators still receive accepted requests unchanged.

