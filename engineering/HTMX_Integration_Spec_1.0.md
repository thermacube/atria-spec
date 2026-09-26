# Thermacube HTMX Integration Specification

## Version 1.0

**Date:** September 26, 2026  
**Status:** Normative cross-application engineering standard  
**Canonical home:** `thermacube/atria-spec`  
**Initial adopters:** Atria, CECPD Bridge, Thermacube Communications (Comms)  
**Initial validated HTMX runtime:** 2.0.11

---

## 1. Purpose

This specification defines how Thermacube applications use HTMX.

The goal is not merely to use HTMX syntax. The goal is to preserve the architectural intent of hypermedia-driven applications:

- the server remains authoritative for application and domain state;
- HTML remains the primary browser-facing representation of application state;
- ordinary HTTP, links, and forms remain the baseline interaction model;
- HTMX progressively enhances that model;
- behavior remains locally understandable from the markup that invokes it;
- URLs remain meaningful and directly navigable;
- browser/client state is minimized;
- JavaScript remains narrow and exceptional;
- accessibility, security, and resilience remain first-class requirements.

This specification governs HTMX usage across Thermacube applications regardless of runtime implementation.

---

## 2. Governing principle

> **HTMX enhances hypermedia; it does not create a second client application.**

A Thermacube HTMX interaction SHOULD look like an enhanced normal web interaction rather than an RPC call from a JavaScript application.

When two implementations satisfy the requirement, prefer the one with:

- fewer client-side states;
- fewer custom events;
- fewer DOM mutations;
- fewer network requests;
- fewer response formats;
- fewer layers between the HTML and the domain action.

---

## 3. Relationship to other Thermacube standards

This specification operates alongside:

- Thermacube Application Accessibility Specification;
- Thermacube Application Request Perimeter Specification;
- Thermacube Application UI Design Specification / TMUI;
- Thermacube Application Information Architecture & Screen Layout Specification;
- application-specific specifications.

Accessibility requirements override convenience-driven swap behavior.

Security requirements override convenience-driven request behavior.

Application/domain authority remains below the HTMX transport/presentation layer.

---

## 4. Runtime ownership and versioning

HTMX MUST be locally hosted or vendored.

Production applications MUST NOT load HTMX from a public CDN.

Each application MUST pin an exact reviewed HTMX version or exact vendored artifact.

Applications MUST NOT follow a floating `latest`, unbounded semver range, or remote alias.

An HTMX upgrade is a deliberate application dependency change and must pass application regression tests.

---

## 5. Progressive enhancement baseline

Core application workflows SHOULD remain meaningful as ordinary HTML links and forms.

Preferred:

```html
<form method="get"
      action="/records"
      hx-get="/records/fragment"
      hx-target="#records"
      hx-swap="outerHTML">
```

Without HTMX, the browser submits the form normally.

With HTMX, the application may return a smaller replacement region.

If a workflow cannot reasonably support a non-HTMX fallback, that exception must be explicit and justified by the interaction requirement.

---

## 6. Native HTTP semantics first

Navigation is represented by links.

User-submitted state is represented by forms.

GET is used for safe retrieval/navigation.

State-changing browser workflows SHOULD use POST where progressive form fallback is required.

HTMX-specific `PUT`, `PATCH`, or `DELETE` requests MAY be used only when:

- the route semantics materially benefit;
- a meaningful fallback exists or the workflow is explicitly HTMX-required;
- CSRF/authentication protections remain correct;
- the application specification documents the exception.

Do not use an anchor link for a mutation merely because HTMX can intercept it.

---

## 7. HTML, not JSON, is the default UI response

Ordinary Thermacube UI interactions return HTML.

Preferred:

```text
request
 -> domain query/mutation
 -> server renders authoritative HTML
 -> HTMX swaps a coherent region
```

Avoid:

```text
request
 -> JSON
 -> custom browser state layer
 -> client template
 -> DOM patch
```

JSON APIs remain appropriate for actual non-HTML consumers, provider integrations, or capabilities whose protocol genuinely requires JSON.

---

## 8. Full-page and fragment rendering

Applications may use either of two approved patterns.

### 8.1 Separate fragment route

Example:

```text
GET /records
GET /records/fragment
```

Both routes MUST use the same authorization, application service/read model, and rendering semantics.

The fragment route is a presentation route, not a parallel business API.

### 8.2 Same canonical route

An application MAY use one canonical route and vary full-page vs fragment rendering based on `HX-Request`.

If cacheable infrastructure is involved, responses MUST vary correctly on relevant HTMX request headers.

History-restore behavior must be configured so that direct navigation/history misses receive complete pages.

---

## 9. Canonical URLs

Every browser-visible application state that is meaningful to bookmark, refresh, copy, or open in a new tab MUST have a canonical URL that returns a complete usable page.

Examples:

- report filters;
- pagination;
- current workflow view;
- record detail;
- search results;
- selected administrative section.

Hidden client-only navigation state is prohibited for such views.

---

## 10. Browser history

When an HTMX interaction materially changes the current navigable view, the application SHOULD update browser history using:

- `hx-push-url`; or
- server response header `HX-Push-Url`.

If a URL is pushed into history:

> A direct GET to that URL MUST return a complete page.

Thermacube applications using HTMX history SHOULD set:

```text
htmx.config.historyRestoreAsHxRequest = false
```

unless a documented architecture requires otherwise.

---

## 11. Sensitive history state

Pages containing sensitive information that should not be cached in HTMX local history MUST opt out with `hx-history="false"` or equivalent application policy.

Applications may instead set the HTMX history cache size to zero when product requirements justify disabling HTMX history snapshots globally.

The decision must account for:

- personal information;
- communications;
- financial information;
- administrative security data;
- authenticated content with elevated sensitivity.

Browser HTTP caching policy remains separately governed.

---

## 12. Swap boundary principle

> **Replace the largest coherent region whose authoritative state changed, but no larger.**

A good swap target should:

- represent one understandable application region;
- be renderable independently;
- have one authoritative server representation;
- avoid leaving neighboring stale state;
- preserve sensible focus and landmarks;
- minimize coupling between response markup and unrelated DOM locations.

Do not optimize solely for the smallest number of transferred bytes if doing so creates fragmented state management.

---

## 13. Fragment completeness

A returned fragment SHOULD contain the complete new state of its target region.

Avoid returning tiny imperative patches requiring the client to know how several fields relate.

For example, after approving a Registry record, prefer returning the updated row or Registry application region rather than individually patching:

- status text;
- button visibility;
- comment count;
- row color;
- pagination count.

---

## 14. Out-of-band swaps

`hx-swap-oob` is permitted but exceptional.

Good candidates include genuinely cross-cutting state such as:

- global unread Comms count;
- global notification count;
- application-level status that must change with another response.

OOB swaps MUST NOT become the routine mechanism for coordinating many page regions.

If a response needs several OOB patches to remain coherent, reconsider the primary swap boundary.

---

## 15. Locality of behavior

HTMX behavior SHOULD remain visible in or near the element that causes it.

Prefer:

```html
<button hx-post="/records/42/approve"
        hx-target="#record-42"
        hx-swap="outerHTML">
```

over hidden global JavaScript that attaches the same behavior later.

Shared inheritance such as `hx-boost`, common headers, or stable parent configuration is permitted when it reduces repetition without making behavior surprising.

---

## 16. `hx-boost`

`hx-boost` MAY be used for ordinary links and forms where progressive enhancement and browser history semantics remain clear.

Do not blanket-enable `hx-boost` across an application merely to make every navigation asynchronous.

Exclude flows where ordinary navigation is simpler or safer, such as:

- file downloads;
- external links;
- some authentication boundaries;
- provider redirects;
- payment redirects;
- responses requiring browser-level behavior.

---

## 17. Server-owned navigation outcomes

When domain/application logic determines the next browser location, the server SHOULD communicate that result.

Approved mechanisms include:

- normal HTTP redirect for non-HTMX requests;
- `HX-Redirect`;
- `HX-Location`;
- `HX-Push-Url`;
- `HX-Refresh` when a complete refresh is genuinely required.

Do not duplicate domain navigation rules in browser JavaScript.

---

## 18. Request concurrency

High-frequency or mutation interactions MUST define concurrency behavior.

Use HTMX synchronization mechanisms such as `hx-sync` where appropriate.

Examples:

### Search/filter

A newer search may replace or abort an older pending search.

### Form submission

A form must not produce accidental duplicate mutations from repeated activation.

### Destructive action

The triggering control should become unavailable or otherwise protected during the authoritative request.

### Polling

A repeated request must not accumulate overlapping requests.

The exact policy should reflect domain idempotency and user expectation.

---

## 19. Busy and loading state

HTMX request state must comply with the Thermacube accessibility specification.

Use meaningful combinations of:

- `aria-busy="true"`;
- `hx-indicator`;
- local status text;
- native `progress`;
- disabled/unavailable mutation controls.

A spinner or animation MUST NOT be the only indication of activity.

Rapid operations need not announce trivial loading transitions if doing so would create assistive-technology noise.

---

## 20. Focus management

Every swap pattern must define expected focus behavior.

### 20.1 Filter/pagination refresh

Focus normally remains on the invoking control where possible.

### 20.2 Validation failure

Focus may move to an error summary or first invalid control when that supports recovery.

### 20.3 Dialog close

Focus returns logically to the control that opened the dialog.

### 20.4 Newly created content

Do not automatically focus new content merely because it appeared. Move focus only when the new content is the user's next required interaction or necessary to understand the transition.

### 20.5 Route-like navigation

The resulting page/view must provide a logical main heading and landmark destination. Applications should avoid arbitrary focus stealing on routine fragment swaps.

Stable element IDs SHOULD be used where HTMX/browser focus preservation depends on identity.

---

## 21. Live regions

Do not wrap large dynamic application regions or complete tables in `aria-live`.

Announce concise semantic outcomes instead.

Preferred:

```html
<div role="status" aria-live="polite">
  24 records found.
</div>
```

Avoid making every changed row or large replacement region a live announcement.

Errors requiring immediate attention may use `role="alert"` when appropriate.

---

## 22. Forms and validation

HTMX form submissions use the same server validation rules as full-page submissions.

The server remains authoritative for:

- validation;
- authorization;
- CSRF;
- domain rules;
- mutation result.

On validation failure, the returned fragment/page should:

- preserve user-entered values where safe;
- identify invalid fields programmatically;
- provide human-readable error text;
- return the complete relevant form state.

Browser-only validation may improve feedback but cannot replace server validation.

---

## 23. Confirmation patterns

Do not use client confirmation as the sole protection for consequential domain actions.

`hx-confirm` MAY be used for low-risk convenience confirmations.

For consequential, destructive, financial, or difficult-to-reverse actions, prefer an accessible server-rendered confirmation state or properly implemented dialog when confirmation is required.

Authorization and idempotency remain server responsibilities.

---

## 24. Request security defaults

Thermacube HTMX deployments SHOULD configure:

```text
selfRequestsOnly = true
allowScriptTags = false
```

unless an application specification documents a justified exception.

Loaded fragments should not rely on executable `script` tags.

Custom JavaScript required for a component should be locally shipped, explicitly initialized, and narrowly scoped.

---

## 25. CSRF and authentication

HTMX does not create a separate trust boundary.

Browser HTMX requests use the same authenticated application session and CSRF policy as equivalent ordinary requests.

Applications may supply CSRF material through:

- normal form fields;
- trusted request headers populated from server-rendered page context;
- another application-approved mechanism.

HTMX headers such as `HX-Request` MUST NOT be treated as authentication or authorization proof.

---

## 26. Request perimeter

Internet-originated HTMX requests pass through the Thermacube Application Request Perimeter like all other browser requests.

The perimeter must not assume that an HTMX request is safer because it expects an HTML fragment.

Fragment endpoints receive the same structural/security protections as full-page endpoints.

---

## 27. Response caching

Applications must account for whether a URL can return:

- a full page;
- a fragment;
- different authenticated content.

If the same URL returns different representations based on HTMX headers and the response is cacheable, correct `Vary` behavior is mandatory.

Private authenticated responses should use application-appropriate cache policy.

Versioned static assets may use long-lived immutable caching.

---

## 28. Error handling

HTMX failures must not leave the interface in an ambiguous or permanently disabled state.

Applications must define behavior for:

- validation errors;
- authorization errors;
- expired sessions;
- CSRF failures;
- server errors;
- network failures;
- request timeouts where applicable.

The user must receive a recoverable interface.

Do not rely only on developer-console errors.

---

## 29. Session expiration

When an authenticated HTMX request discovers an expired or invalid browser session, the server should return an outcome that leads the user to an appropriate re-authentication/full-page state.

Do not inject an entire login document into an arbitrary page fragment.

---

## 30. Polling

Polling is allowed only when its frequency and server cost are justified.

Prefer event-driven mechanisms for truly real-time systems when appropriate.

Polling must:

- not overlap itself;
- stop when no longer needed;
- avoid polling hidden/irrelevant surfaces where practical;
- use a cadence proportional to how quickly the information changes;
- remain accessible when updates arrive.

HTMX polling is not the default solution for Comms real-time voice/chat transport.

---

## 31. Server-Sent Events, WebSockets, and real-time systems

HTMX extensions MAY be used when appropriate, but they are not automatically preferred over direct, narrowly scoped browser APIs.

Comms real-time communication may require WebSocket, WebRTC, or provider/browser capabilities beyond ordinary HTMX.

Such capabilities should still use HTMX/TMUI for ordinary application navigation, forms, history, and server-rendered durable state where appropriate.

Do not force real-time media/control transport into HTMX merely for consistency.

---

## 32. Custom JavaScript

Before adding custom browser JavaScript, consider in order:

1. native HTML;
2. CSS;
3. ordinary request/navigation;
4. HTMX attributes;
5. HTMX response headers/extensions;
6. narrowly scoped custom JavaScript.

Custom JavaScript should not recreate:

- routing;
- client-side application stores;
- generic DOM rendering;
- form serialization;
- HTTP request abstractions

when HTMX/native browser behavior already supplies them.

---

## 33. Events

HTMX events may be used for narrow integration points such as:

- accessibility focus correction;
- telemetry;
- integration with a truly client-only browser capability;
- lifecycle initialization of a complex widget.

Do not build a hidden application event bus out of HTMX events.

Event handlers should remain local, documented, and minimal.

---

## 34. DOM identity

Stable IDs SHOULD be assigned to:

- HTMX swap targets;
- focus-critical controls;
- validation relationships;
- live/status regions;
- regions referenced by `aria-controls`;
- durable record rows when independently replaced.

IDs must remain unique after swaps.

---

## 35. DOM complexity

HTMX does not justify unnecessary wrapper markup.

Returned fragments should use semantic elements and the fewest structural nodes necessary for:

- meaning;
- layout;
- accessibility;
- swap targeting.

TMUI classes should be applied without creating wrapper-only DOM where practical.

---

## 36. Accessibility contract per interaction

Every reusable HTMX pattern should document:

- trigger element;
- request method and URL;
- target;
- swap strategy;
- focus behavior;
- history behavior;
- busy behavior;
- error behavior;
- announcement behavior;
- non-HTMX fallback;
- security/CSRF behavior.

A component is incomplete until these are known.

---

## 37. Testing

Automated tests SHOULD verify:

- full-page route works directly;
- fragment route/HTMX representation works;
- authorization is identical;
- CSRF behavior is identical for mutations;
- URL/history behavior is canonical;
- important response headers are correct;
- fragments contain stable target IDs where expected;
- no unexpected script execution dependency;
- no CDN dependency;
- same-worker/RoadRunner state isolation remains intact.

Browser-level tests SHOULD verify representative:

- Back/Forward behavior;
- focus preservation;
- keyboard operation;
- loading/error recovery;
- repeated/rapid activation;
- session expiration.

---

## 38. Anti-patterns

The following are non-conforming by default:

- HTMX request returning JSON for ordinary UI rendering;
- client template rendering of routine application views;
- hidden browser state as the sole source of current view;
- pushed URL that does not return a complete page;
- blanket OOB patching of many unrelated regions;
- giant `aria-live` swap regions;
- CDN-hosted HTMX;
- script tags embedded in returned fragments;
- client-side authorization decisions;
- business state existing only in the DOM;
- replacing a complete shell when one coherent inner region changed without justification;
- dozens of tiny requests for one logical user action.

---

### 38.1 Internationalization and locale context

The Thermacube Application Internationalization & Localization Specification governs locale resolution and multilingual rendering.

Full-page and fragment responses MUST resolve the same authoritative locale context. Canonical/history URLs must preserve the application's documented locale semantics.

A locale change that changes document-wide `lang` or `dir` SHOULD use a full-document transition rather than partially swapping an opposite-language/direction shell into the current document.

Localized status, error, loading, validation, and accessible-name strings follow the same catalog and locale context as the surrounding application.

---

## 39. Initial Thermacube profiles

### Atria

HTMX is the preferred server-driven interaction layer for the platform shell and application/module surfaces that fit the hypermedia model.

### Bridge

HTMX enhances learner/staff forms, reports, commerce, Registry, imports, surveys, certificates, and operational workflows while preserving full-page server fallbacks.

### Comms

HTMX governs ordinary application navigation, forms, settings, ticket/history workflows, and server-rendered durable state. Real-time chat/voice media transport may use specialized browser/network mechanisms.

---

## 40. Conformance

An application conforms to Thermacube HTMX Integration Specification v1.0 when:

1. it pins and locally serves an approved HTMX runtime;
2. core workflows use semantic links/forms and progressive enhancement where practical;
3. ordinary UI responses are server-rendered HTML;
4. canonical navigable states have truthful direct URLs;
5. history is configured safely;
6. sensitive history caching is addressed;
7. swap regions are coherent and complete;
8. focus/loading/error/live-region behavior follows the accessibility specification;
9. security/CSRF/authentication remain server authoritative;
10. OOB swaps and custom JavaScript remain exceptional and justified;
11. tests exercise both HTMX and direct/full-page behavior.

---

## 41. References

Primary technical references:

- HTMX documentation — https://htmx.org/docs/
- HTMX reference — https://htmx.org/reference/
- HTMX `hx-boost` — https://htmx.org/attributes/hx-boost/
- HTMX `hx-sync` — https://htmx.org/attributes/hx-sync/
- HTMX `hx-indicator` — https://htmx.org/attributes/hx-indicator/
- HTMX Locality of Behaviour — https://htmx.org/essays/locality-of-behaviour/
- HTMX essays / hypermedia architecture — https://htmx.org/essays/

These references define the upstream interaction model. This document defines the Thermacube integration contract.
