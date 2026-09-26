# Thermacube Application Request Perimeter Specification

## Version 1.0

**Date:** September 26, 2026  
**Status:** Draft normative cross-application standard  
**Canonical home:** `thermacube/atria-spec`  
**Initial adopters:** Atria, CECPD Bridge, Thermacube Communications (Comms)

---

## 1. Purpose

The Thermacube Application Request Perimeter is a lightweight, deterministic application-layer guard placed immediately inside a runtime or host adapter and immediately outside the application's ordinary request/application funnel.

Its purpose is to reject malformed, impossible, clearly hostile, or structurally abusive requests cheaply and consistently before normal application dispatch, while leaving network-oriented security heavy lifting to the ingress proxy and CrowdSec.

The perimeter is deliberately smaller than a general-purpose WAF and MUST NOT become a substitute for secure application design.

---

## 2. Architectural position

For Internet-originated requests:

```text
Internet
  -> ingress proxy / CrowdSec
  -> runtime or host adapter
  -> Thermacube Application Request Perimeter
  -> application request funnel
  -> authentication / authorization / business validation
  -> domain logic
```

For same-process local calls:

```text
trusted local caller
  -> documented local adapter/capability boundary
  -> local contract guard
  -> callee application funnel
```

The local contract guard shares structural principles with the HTTP perimeter but MUST NOT blindly apply Internet attack-signature checks to legitimate free-form application content.

---

## 3. Division of responsibility

### 3.1 Ingress proxy and CrowdSec

The ingress layer owns network-oriented controls such as:

- TLS termination and protocol policy;
- source-IP reputation and CrowdSec decisions;
- coarse rate limiting and burst control;
- scanner/bot suppression;
- connection/request timeouts;
- coarse request-size limits;
- malformed HTTP rejection available at the proxy;
- trusted-proxy/source-IP derivation;
- upstream routing and availability.

### 3.2 Application request perimeter

The perimeter owns cheap, deterministic, application-aware checks such as:

- normalized request-structure validation;
- method and route-shape sanity;
- bounded path/query/header/body complexity;
- expected content types;
- key/scalar length limits;
- array depth/element-count limits;
- invalid encoding and NUL/control-character rejection;
- strong traversal/protocol-wrapper indicators in structural locations;
- route/profile-specific structural expectations;
- structured security telemetry.

### 3.3 Application/domain layer

The application/domain layer remains authoritative for:

- authentication;
- authorization;
- CSRF;
- domain/schema validation;
- parameterized SQL;
- context-aware output encoding;
- ownership checks;
- safe file/storage operations;
- safe command execution;
- outbound-network restrictions;
- webhook cryptographic verification;
- business rules and invariants.

A perimeter pass means only that the request is structurally acceptable for application processing.

---

## 4. Core principles

### 4.1 Deterministic and inexpensive

A perimeter decision MUST NOT require database access, network access, provider calls, or mutable shared request state.

### 4.2 Explicit policy profile

Every invocation uses an explicit immutable profile. Initial profiles are:

- `atria_http`
- `bridge_http`
- `comms_http`
- `comms_local`
- `bridge_comms_local`
- `signed_webhook`

Additional profiles require a materially different contract or threat boundary.

### 4.3 Context-aware inspection

The same byte sequence may be hostile in one location and legitimate in another.

Examples:

- `../` in a routing/filesystem parameter may justify rejection.
- `../` inside an email, transcript, support ticket, code sample, or log excerpt is ordinary content.
- `<script>`, SQL words, shell punctuation, or template syntax inside free-form text MUST NOT be treated as sufficient evidence of an attack.

### 4.4 Prefer structural certainty over signature speculation

High-confidence structural rules are preferred:

- invalid UTF-8 where UTF-8 is required;
- NUL bytes;
- malformed percent encoding;
- impossible nesting;
- excessive field counts;
- unsupported methods;
- traversal in path-like input;
- forbidden wrappers/schemes where no URI is allowed;
- forbidden control characters in request metadata.

The perimeter MUST NOT become a large generic regex/signature database for SQLi, XSS, command injection, or template injection.

### 4.5 Secure even when malicious content passes

No implementation may rely on the perimeter as the reason unsafe SQL, unsafe HTML rendering, unsafe shell construction, weak authorization, unsafe file access, or unsafe outbound requests are acceptable.

---

## 5. Normalized request contract

The perimeter inspects normalized application request data, not runtime globals.

Conceptually:

```php
[
    'method' => 'POST',
    'path' => '/example',
    'query' => [...],
    'body' => [...],
    'headers' => [...],
    'files' => [...],
    'content_type' => 'application/json',
    'content_length' => 1234,
    'is_htmx' => false,
]
```

Runtime adapters own superglobal, PSR, RoadRunner, WordPress, or server-object access.

Reusable application/perimeter code MUST NOT depend directly on `$_GET`, `$_POST`, `$_SERVER`, `$_COOKIE`, or `$_FILES`.

Signed webhook raw bodies MUST remain byte-identical for provider signature verification.

---

## 6. Structural inspection

Profiles SHALL bound, as applicable:

- allowed methods;
- path length and segment count;
- header count;
- header name/value lengths;
- query parameter count;
- form/JSON field count;
- key length;
- scalar length;
- total normalized size;
- nesting depth;
- array element count;
- file count and declared upload size.

Route-specific exceptions MUST be explicit.

### 6.1 Paths and route metadata

High-confidence rejection candidates include:

- embedded NUL;
- forbidden control characters;
- malformed percent encoding;
- unresolved traversal in path-like input;
- forbidden `php://`, `data://`, `file://`, or equivalent wrappers in locations that do not accept URIs;
- impossible absolute-URI forms when the adapter requires application-relative paths.

Adapters SHOULD canonicalize paths once. Repeated ambiguous decoding passes are prohibited.

### 6.2 Headers

The perimeter may enforce bounded header structure and reject CR/LF/NUL in normalized values.

The application MUST NOT independently trust arbitrary client-supplied `X-Forwarded-For`, `Forwarded`, or similar values. Trusted proxy configuration determines source identity.

### 6.3 Uploads

The perimeter may validate upload descriptor structure, count, and coarse size.

Application/domain code remains responsible for content/type rules, authorization, naming, storage destination, retention, and any malware/content scanning required by the feature.

---

## 7. Local procedural calls

Local calls are not automatically trusted, but their threat model differs from Internet requests.

A local contract guard SHOULD verify:

- the operation is in the declared local capability set;
- payload shape/type/depth/size is bounded;
- required context is present;
- caller/application identity is explicit;
- the callee re-resolves its own user/application authorization where required;
- caller-controlled context cannot replace callee-owned database handles, roles, or authority;
- request-specific state does not survive the call.

A local guard normally MUST NOT reject free-form content merely because it resembles an Internet attack payload.

---

## 8. RoadRunner and persistent-worker requirements

All conforming implementations MUST be safe when many requests execute sequentially in one PHP worker.

The following MUST NOT survive between requests:

- current user identity;
- authorization results;
- source IP;
- request ID;
- security decision;
- violation list;
- route/query/body values;
- provider callbacks;
- transaction ownership;
- mutable request-specific counters.

Immutable policy/configuration data MAY be loaded once per worker only when it cannot be mutated by request processing.

Rejecting one request MUST NOT poison subsequent requests. The PHP worker MUST NOT become an in-memory ban list.

---

## 9. Decision contract

Perimeter code SHOULD return a bounded decision rather than emit/terminate HTTP itself.

Example:

```php
[
    'allow' => false,
    'reason' => 'path_traversal',
    'rule' => 'request.path.traversal.v1',
    'severity' => 'high',
]
```

The runtime adapter owns HTTP conversion.

Recommended external responses:

- 400 for malformed request structure;
- 413 for size excess where appropriate;
- 415 for unsupported media type;
- 403 only where deployment policy deliberately treats a high-confidence hostile request as forbidden.

Responses MUST NOT reveal rule internals, regexes, filesystem paths, stack traces, or sensitive request material.

---

## 10. Security telemetry

Rejected requests and selected high-confidence observations SHOULD emit structured events.

Conceptual event:

```json
{
  "event": "security.request_rejected",
  "application": "bridge",
  "profile": "bridge_http",
  "rule": "request.path.traversal.v1",
  "severity": "high",
  "request_id": "opaque-correlation-id",
  "route": "/example",
  "source": "trusted-derived-source",
  "timestamp": "2026-09-26T10:00:00Z"
}
```

Telemetry MUST:

- use stable machine-readable rule IDs;
- identify application and profile;
- include correlation/request ID when available;
- avoid credentials, cookies, auth headers, tokens, passwords, and session IDs;
- avoid full request bodies and free-form communications by default;
- truncate/hash attacker-controlled values where appropriate;
- preserve enough metadata for ingress-log correlation.

The intended response loop is:

```text
application detects high-confidence hostile request
  -> structured security event
  -> central logs / CrowdSec parser or scenario
  -> ingress-level decision for repeat offenders
```

The application does not own long-term IP reputation.

---

## 11. Signed webhooks

The `signed_webhook` profile may enforce method, route, content type, coarse size, header shape, and raw-body availability.

It MUST NOT mutate or semantically normalize the signed raw body before the provider signature verifier sees it.

Cryptographic signature verification, replay handling, and idempotency remain application/provider responsibilities.

---

## 12. Application adoption

### 12.1 Atria

```text
Ingress / CrowdSec
  -> Atria runtime adapter
  -> atria_http perimeter
  -> Atria application request funnel
  -> Atria authentication / authorization / domain
```

The perimeter is the lightweight application-aware screening layer between ingress and Atria dispatch.

### 12.2 CECPD Bridge

WordPress-era browser path:

```text
Browser
  -> WordPress / Bridge WP
  -> WordPress authentication + nonce/CSRF
  -> Bridge request normalization
  -> bridge_http perimeter
  -> bridge_handle_request()
```

Future standalone/RoadRunner path:

```text
Ingress / CrowdSec
  -> Bridge runtime adapter
  -> bridge_http perimeter
  -> bridge_handle_request()
```

Bridge-to-Comms calls use the local contract profile.

### 12.3 Comms

External path:

```text
Ingress / CrowdSec
  -> Comms runtime adapter
  -> comms_http or signed_webhook perimeter
  -> Comms application/provider funnel
```

Local Bridge/Atria path:

```text
Bridge/Atria
  -> approved local Comms adapter
  -> comms_local / bridge_comms_local guard
  -> comms_handle_request()
```

The local profile MUST allow legitimate emails, chats, transcripts, code, logs, SQL examples, HTML, shell syntax, and security-related text when structurally valid.

Comms continues to resolve its own authorization and MUST NOT trust a host-supplied role.

---

## 13. Required tests

Each adopter MUST test:

- overlong path;
- excessive parameter count;
- excessive nesting;
- invalid container type;
- unsupported method where profile-owned;
- NUL/control-character rejection;
- traversal in structural input;
- forbidden wrapper/scheme in structural input;
- oversize body/field behavior.

False-positive tests MUST demonstrate that legitimate free-form content containing SQL, HTML/script text, shell syntax, `../../etc/passwd`, URLs, source code, or logs is accepted where the route allows free-form content.

Persistent-worker tests MUST alternate allowed and rejected requests in one PHP process and prove no identity/source/decision/reason/route/payload/violation state leaks.

Local-call tests MUST prove unsupported operations and malformed payloads fail closed, host role injection is ignored, callee authorization is re-resolved, and repeated local calls remain isolated.

---

## 14. Implementation constraints

Initial implementations SHOULD favor:

- small procedural rule functions where the host is procedural;
- explicit arrays/value objects;
- stable rule IDs;
- no database/network dependency during inspection;
- no third-party WAF/signature engine;
- no opaque classifier;
- no request-content persistence;
- no direct ingress-ban API call from application code.

A shared runtime package SHOULD be extracted only after multiple implementations demonstrate enough stable common code to justify the dependency.

---

## 15. Non-goals

The perimeter is not a replacement for:

- CrowdSec or the reverse proxy;
- a full WAF/IDS/IPS;
- malware/antivirus scanning;
- DLP/content moderation;
- authentication/authorization;
- CSRF;
- parameterized SQL;
- context-aware output encoding;
- webhook signatures;
- safe file/network/command APIs;
- deployment hardening.

---

## 16. Conformance

An application conforms to v1.0 when:

1. its external runtime path invokes an adopted HTTP/signed-webhook perimeter before normal application dispatch;
2. local cross-application calls use the appropriate structural contract guard;
3. persistent-worker isolation requirements are met;
4. telemetry uses stable IDs and avoids sensitive/raw-body logging;
5. secure domain practices do not depend on perimeter filtering;
6. required structural, false-positive, local-contract, and worker-isolation tests exist;
7. the application specification or implementation baseline identifies this exact perimeter version.

---

## 17. Versioning

This specification is versioned independently of Atria, Bridge, and Comms.

Applications explicitly adopt a version; they do not automatically conform to a newer revision merely because this document changes.

---

## 18. Security philosophy summary

> Reject what the application can identify cheaply and confidently as malformed, structurally abusive, or clearly hostile; log the event safely; leave adaptive network blocking to CrowdSec; and require the application to remain secure even when malicious content passes the perimeter.
