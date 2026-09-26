# Thermacube Application Accessibility Specification

## Version 1.0

**Date:** September 26, 2026  
**Status:** Normative cross-application engineering standard  
**Canonical home:** `thermacube/atria-spec`  
**Initial adopters:** Atria, CECPD Bridge, Thermacube Communications (Comms)

---

## 1. Purpose

This specification defines the shared accessibility engineering and conformance baseline for Thermacube web applications.

Its primary normative conformance target is **Web Content Accessibility Guidelines (WCAG) 2.2 Level AA**.

Supporting standards and guidance are:

- **WAI-ARIA 1.2** for ARIA roles, states, properties, and accessibility semantics where ARIA is necessary;
- the **ARIA Authoring Practices Guide (APG)** as implementation guidance for accessible widgets, keyboard interaction, accessible names/descriptions, landmarks, dialogs, grids, tabs, and similar rich-interface patterns;
- **WCAG Evaluation Methodology (WCAG-EM) 2.0** as the methodology for formal product-level conformance evaluation and reporting.

This specification does not replace those standards. It defines how Thermacube applications apply them consistently in a dynamic, HTMX/PWA-oriented application architecture.

---

## 2. Normative conformance target

A conforming Thermacube application SHALL conform to **WCAG 2.2 Level AA** for the application scope being claimed.

Level AA conformance includes all applicable Level A and Level AA success criteria.

Application specifications MAY establish stricter accessibility requirements, but MUST NOT weaken the shared WCAG 2.2 Level AA baseline.

Regulatory mappings such as U.S. Section 508 or EN 301 549 MAY be documented for a deployment, contract, or customer requirement. Such mappings do not replace the shared technical baseline unless an application specification explicitly establishes an additional requirement.

---

## 3. Standards hierarchy

The shared accessibility stack is:

```text
Normative product conformance
    WCAG 2.2 Level AA
            |
            +-- WAI-ARIA 1.2
            |      normative semantics where ARIA is used
            |
            +-- ARIA Authoring Practices Guide
            |      implementation guidance and interaction patterns
            |
            +-- WCAG-EM 2.0
                   evaluation scope, sampling, testing, and reporting
```

### 3.1 WCAG 2.2

WCAG 2.2 Level AA is the normative accessibility outcome standard.

### 3.2 WAI-ARIA 1.2

When ARIA is used, roles, states, and properties MUST conform to WAI-ARIA 1.2.

ARIA MUST NOT be used to recreate native HTML semantics where a native HTML element provides the required semantics and behavior without material loss of functionality.

Incorrect ARIA is a defect, not an accessibility enhancement.

### 3.3 ARIA Authoring Practices Guide

APG is implementation guidance rather than a separate conformance target.

When a Thermacube component implements a recognized APG interaction pattern, its keyboard behavior, focus behavior, roles, states, properties, and accessible-name behavior SHOULD follow the relevant APG pattern unless a documented application-specific reason requires a different but equally accessible behavior.

### 3.4 WCAG-EM 2.0

Formal accessibility evaluations SHALL use WCAG-EM 2.0 as the product-level evaluation methodology unless a customer or regulator requires a stricter documented methodology.

---

## 4. Scope of accessibility

Accessibility applies to the complete user interaction, not only initial page HTML.

The scope includes:

- full page loads;
- HTMX fragments and partial replacements;
- dialogs, drawers, sheets, popovers, and overlays;
- tables, grids, forms, reports, and filters;
- client-side validation and server-returned validation errors;
- loading, success, warning, and error states;
- authentication and account workflows;
- downloadable/rendered content where produced by the application;
- PWA installation and application surfaces;
- embedded application surfaces such as Comms inside Bridge/Atria;
- media controls, recordings, transcripts, and captions where applicable;
- dynamic notification, queue, chat, and calling interfaces;
- mobile/responsive presentations;
- keyboard-only and assistive-technology operation.

A workflow is not conforming merely because each isolated screen appears conforming. The end-to-end task must remain operable and understandable.

---

## 5. Native semantics first

Applications MUST prefer semantic HTML over custom elements with reconstructed ARIA behavior.

Examples:

- use `button` for actions;
- use `a` for navigation;
- use `label` for form labels;
- use `fieldset` and `legend` for grouped controls where appropriate;
- use native headings and landmarks;
- use native tables for tabular data;
- use native form controls where they meet the requirement.

Custom widgets MAY be used when native elements cannot satisfy the interaction requirement, but the custom widget must implement the full keyboard, semantic, state, and focus contract expected for that control.

---

## 6. Keyboard accessibility

All application functionality MUST be operable with a keyboard without requiring a pointing device.

Requirements include:

- logical focus order;
- no keyboard traps;
- all interactive controls reachable by keyboard;
- visible focus indication;
- expected keyboard behavior for custom widgets;
- Escape/cancel behavior where appropriate;
- no hover-only functionality;
- drag-and-drop functionality must have an accessible non-drag alternative when dragging is required for a task;
- shortcuts must not interfere with assistive technology or ordinary typing.

Custom widgets modeled on APG patterns SHOULD follow APG keyboard interaction guidance.

---

## 7. Focus management

Focus behavior is part of application state.

Applications MUST:

- provide visible focus;
- preserve a logical focus position after partial updates;
- move focus only when doing so helps the user understand or continue the task;
- restore focus appropriately when dialogs/drawers close;
- prevent focus from entering inactive modal-background content;
- avoid unexpected focus resets to the document start;
- ensure focus is not hidden behind sticky headers, overlays, or other persistent UI;
- ensure focused controls remain perceivable at supported zoom/reflow levels.

HTMX fragment replacement MUST explicitly consider what happens to the active element when the replaced fragment contains or precedes focus.

---

## 8. Dynamic updates and HTMX

Dynamic updates MUST be understandable without requiring visual observation of the changed region.

Applications SHALL distinguish among:

1. **Silent structural updates** that do not need announcement;
2. **Status updates** that should be announced without moving focus;
3. **Task transitions** where moving focus is the correct interaction;
4. **Errors requiring correction**, which must identify the problem and its relationship to affected fields or controls.

ARIA live regions MAY be used for meaningful status updates, but MUST NOT be used indiscriminately.

Applications MUST avoid duplicate announcements caused by combining focus movement, native browser behavior, and live-region announcements for the same event.

---

## 9. Accessible names, descriptions, and states

Every interactive control MUST have a programmatically determinable accessible name.

Where additional context is necessary, controls SHOULD have an accessible description.

Names and descriptions MUST:

- identify the control's purpose;
- remain accurate when state changes;
- avoid duplicate or conflicting naming sources;
- remain meaningful outside purely visual context;
- not rely only on icon shape, position, or color.

State changes such as expanded/collapsed, selected, checked, pressed, invalid, busy, current, or disabled MUST be programmatically exposed when the underlying native element does not already convey the state.

Icon-only controls require accessible names.

---

## 10. Structure and navigation

Application views MUST provide programmatically understandable structure.

Requirements include:

- logical heading hierarchy;
- meaningful page/view titles where applicable;
- landmark regions appropriate to the application shell;
- bypass mechanisms or equivalent efficient navigation where repeated content exists;
- meaningful link/control text;
- current-location/current-item state where needed;
- consistent navigation and control identification across views.

Repeated application chrome must not force keyboard/screen-reader users to traverse unnecessary controls for every HTMX update.

---

## 11. Forms and validation

Forms MUST remain usable with keyboard and assistive technology.

Requirements include:

- persistent programmatic labels;
- clear required-field indication;
- instructions before they are needed;
- programmatic relationships between errors and affected fields;
- human-readable error text;
- error summary or equivalent mechanism for multi-field failures when appropriate;
- focus management after failed submissions;
- preservation of user-entered data unless security or business rules require otherwise;
- identification of format requirements;
- accessible confirmation for consequential actions.

Placeholder text MUST NOT be the sole label.

Color MUST NOT be the sole indicator of invalid, required, selected, successful, or warning state.

---

## 12. Authentication

Authentication workflows MUST satisfy applicable WCAG 2.2 Level A and AA requirements, including accessible authentication requirements.

Applications SHOULD avoid requiring users to solve cognitive-function tests when an accessible alternative can be provided.

Password managers, copy/paste, passkeys, one-time-code autofill, and similar accessibility-supporting mechanisms MUST NOT be unnecessarily blocked.

Security controls remain mandatory; accessibility requirements govern how users can satisfy them, not whether security is enforced.

---

## 13. Visual presentation, contrast, zoom, and reflow

Applications MUST satisfy WCAG 2.2 Level AA contrast and non-text contrast requirements.

Interfaces MUST remain usable at required zoom/reflow conditions without loss of information or functionality.

Requirements include:

- avoid horizontal scrolling for ordinary reflow content at applicable viewport/zoom conditions, except where two-dimensional layout is essential;
- do not clip focused controls or error messages;
- do not require color perception to understand state;
- maintain sufficient contrast for text, controls, focus indicators, and meaningful graphical objects;
- support text spacing without loss of content or functionality;
- avoid fixed dimensions that make controls unusable at enlarged text/zoom.

Responsive layouts must preserve reading and interaction order.

---

## 14. Target size and pointer input

Interactive targets MUST meet applicable WCAG 2.2 Level AA target-size requirements.

Closely spaced controls require sufficient separation or an applicable exception.

Functionality MUST NOT depend exclusively on precise pointer movement, hover, or multipoint gestures when an accessible alternative is required.

---

## 15. Motion and animation

Applications MUST respect reduced-motion preferences where animation is non-essential.

Animation, transitions, auto-updating content, and motion effects must not prevent operation or understanding.

Flashing content that violates applicable WCAG thresholds is prohibited.

---

## 16. Tables, grids, and dense operational interfaces

Thermacube applications frequently use dense operational tables.

Use a native HTML table when the interaction is fundamentally tabular reading, sorting, filtering, or row action.

Use an ARIA grid only when the interaction genuinely requires composite-widget grid behavior.

Tables and grids MUST expose:

- header relationships;
- sortable state where sorting exists;
- row/column identity where necessary;
- selected/current state where applicable;
- keyboard-accessible row actions;
- accessible names for icon actions.

Responsive transformations from tables to cards/lists must preserve equivalent information and programmatic relationships.

---

## 17. Dialogs, drawers, sheets, and embedded sidecars

Modal dialogs MUST:

- expose dialog semantics and an accessible name;
- move focus into the dialog appropriately;
- contain keyboard focus while modal;
- provide an accessible close/cancel mechanism;
- restore focus logically on close;
- not leave background content available as an accidental keyboard target.

Nonmodal drawers/panels must preserve logical focus order and clear relationship to the triggering control.

Embedded Comms sidecars or similar isolated application surfaces must maintain their own accessible structure while the host remains responsible for an accessible host container, launcher, and presentation transition.

---

## 18. Notifications, status, chat, and real-time communication

Real-time interfaces require deliberate announcement behavior.

Applications MUST ensure:

- unread/pending state is not communicated by color alone;
- new status information can be perceived without visual monitoring;
- chat message arrival announcements are useful but not excessively verbose;
- message history remains navigable;
- typing/presence indicators do not create unusable announcement noise;
- call status, connection state, mute state, hold state, and call-ending state are programmatically exposed;
- urgent alerts are distinguishable from ordinary status updates;
- users can review missed information rather than relying only on transient announcements.

---

## 19. Media, recordings, transcripts, and captions

Where an application provides prerecorded or live media, it MUST satisfy applicable WCAG 2.2 Level A/AA media requirements.

When Comms or another application provides call recordings and generated transcripts:

- playback controls must be keyboard accessible and labeled;
- transcript availability must be programmatically discoverable;
- corrected transcripts must remain accessible;
- transcript presentation must not depend on audio playback;
- caption/transcript requirements must be evaluated according to the media type and applicable WCAG success criteria.

A generated transcript is not assumed to satisfy every caption requirement merely because text exists.

---

## 20. Error, loading, and busy states

Asynchronous application behavior MUST provide accessible state feedback.

Where a delay is meaningful, affected regions or controls SHOULD expose busy/loading state.

Errors must be recoverable without requiring the user to infer failure from disappearance, color, or lack of change.

Loading indicators that are purely decorative need not be announced.

---

## 21. Language and text alternatives

Documents/views MUST expose the correct primary human language.

Changes of language within content SHOULD be identified where required by WCAG.

Meaningful non-text content requires appropriate text alternatives. Decorative imagery must not create unnecessary assistive-technology output.

Iconography alone must not carry essential meaning without an accessible textual equivalent.

---

## 22. Accessibility and application security

Accessibility implementation MUST NOT weaken authentication, authorization, CSRF protection, privacy, or other security controls.

Conversely, security controls MUST NOT unnecessarily block accessibility mechanisms such as:

- password-manager fill;
- clipboard use;
- browser zoom;
- assistive-technology keyboard interaction;
- accessible alternative authentication methods.

The Application Request Perimeter and accessibility specifications are independent. A request may be security-valid and accessibility-invalid, or vice versa.

---

## 23. Component-level engineering contract

Reusable components SHOULD have an explicit accessibility contract documenting:

- semantic role/native element;
- accessible name source;
- states and properties;
- keyboard interaction;
- focus-entry and focus-exit behavior;
- announcement behavior;
- error/busy behavior;
- responsive/reflow behavior;
- relevant automated tests;
- required manual checks.

A component library pattern should not be considered complete until its accessibility contract is tested.

---

## 24. Automated accessibility testing

Automated accessibility checks SHOULD run in CI for stable application surfaces and reusable components.

Automated testing SHOULD cover issues that tools can reliably detect, including examples such as:

- missing accessible names;
- invalid ARIA roles/states/properties;
- duplicate IDs where accessibility relationships depend on them;
- form-label association;
- landmark/heading defects detectable by tooling;
- some contrast failures;
- prohibited focusability/hidden-content combinations;
- basic semantic misuse.

Automated tooling is evidence, not proof of WCAG conformance.

Passing an automated scan MUST NOT be represented as WCAG 2.2 Level AA conformance.

---

## 25. Manual and assistive-technology testing

Manual evaluation is required for behavior that automation cannot reliably determine.

At minimum, representative workflows SHALL be evaluated for:

- keyboard-only operation;
- visible and logical focus;
- zoom/reflow;
- form validation and recovery;
- dialogs/drawers;
- dynamic HTMX updates;
- meaningful status announcements;
- screen-reader navigation and control operation;
- task completion without relying on color, pointer precision, or visual-only context.

The formal evaluation plan SHALL identify the assistive technologies, browsers, operating systems, and viewport classes used for evaluation.

No single screen reader/browser combination is treated as proof of universal accessibility.

---

## 26. WCAG-EM 2.0 evaluation process

Formal product-level conformance evaluations SHALL use WCAG-EM 2.0 to define:

1. evaluation scope;
2. product/application boundaries;
3. essential functionality and user tasks;
4. representative views/states/workflows;
5. evaluation sample;
6. applicable WCAG 2.2 success criteria;
7. findings and failures;
8. conformance conclusion;
9. limitations and untested areas;
10. remediation/retest evidence where applicable.

For dynamic applications, representative views include meaningful application states, not only URL-addressable pages.

---

## 27. Representative workflow coverage

Each adopter SHALL maintain a set of representative high-value workflows.

Examples include:

- authentication;
- account/profile actions;
- creating and editing records;
- search/filter/reporting;
- submitting and correcting forms;
- completing consequential actions;
- launching embedded applications;
- responding to validation errors;
- using dialogs and overlays;
- viewing dense operational data;
- mobile/responsive use.

Application-specific adoption documents identify additional required workflows.

---

## 28. Defect severity

Accessibility defects SHOULD be prioritized by user impact rather than by whether an automated tool detects them.

A defect is especially severe when it:

- blocks task completion;
- traps keyboard focus;
- makes a control unavailable to assistive technology;
- hides an error or required action;
- makes authentication impossible;
- causes destructive or financial action ambiguity;
- prevents access to communications or learning content;
- causes repeated or unusable announcement behavior.

---

## 29. Exceptions

A claimed exception must identify:

- the affected WCAG success criterion;
- the exact application surface;
- why the criterion is not applicable or why an exception is being claimed;
- the accessibility impact;
- any alternative accommodation;
- owner and review date.

Temporary implementation difficulty is not itself a standards exception.

---

### 29.1 Internationalization and localization

The Thermacube Application Internationalization & Localization Specification governs language and direction metadata, translated accessibility strings, and multilingual layout behavior.

Accessibility remains the higher-precedence requirement where the standards overlap.

A localized interface is non-conforming when visible text is translated but accessible names, errors, status announcements, alternative text, iframe titles, document language, or language-of-parts metadata remain incorrect.

---

## 30. Application adoption

### 30.1 Atria

Atria applies this specification to the platform shell and all Atria-hosted module surfaces, including HTMX interactions and module transitions.

Atria modules retain responsibility for module-specific semantics and interactions while the platform owns shared shell/navigation/focus conventions.

### 30.2 Bridge

Bridge applies this specification to learner, staff, commerce, Registry, reporting, certificate, import/review, and operational HTMX surfaces.

Bridge WP host integration does not reduce the accessibility obligation merely because WordPress owns the outer browser session.

### 30.3 Comms

Comms applies this specification to standalone/PWA and embedded sidecar experiences, including Messages, Chat, Voice, ticket forms, history, administration, voicemail, recordings, transcripts, and real-time status.

The embedded host and Comms each retain accessibility responsibility for the surfaces they own.

---

## 31. Conformance requirements

An application conforms to Thermacube Application Accessibility Specification v1.0 when:

1. its application specification explicitly adopts this version;
2. WCAG 2.2 Level AA is the normative product target;
3. WAI-ARIA 1.2 is used correctly where ARIA is required;
4. native HTML is preferred where practical;
5. dynamic interaction, keyboard, focus, error, and announcement behavior follow this specification;
6. reusable components have accessibility-aware tests;
7. automated checks are supplemented by manual testing;
8. representative workflows undergo manual keyboard and assistive-technology evaluation;
9. formal product-level evaluation uses WCAG-EM 2.0;
10. exceptions are documented rather than silently ignored.

---

## 32. Versioning

This specification is versioned independently of Atria, Bridge, and Comms.

Applications explicitly adopt a version. They do not automatically conform to future revisions merely because this document changes.

---

## 33. Standards references

Normative and supporting references:

- W3C Web Content Accessibility Guidelines (WCAG) 2.2 — https://www.w3.org/TR/WCAG22/
- W3C Accessible Rich Internet Applications (WAI-ARIA) 1.2 — https://www.w3.org/TR/wai-aria-1.2/
- W3C/WAI ARIA Authoring Practices Guide (APG) — https://www.w3.org/WAI/ARIA/apg/
- W3C/WAI WCAG Evaluation Methodology (WCAG-EM) 2.0 — https://www.w3.org/TR/WCAG-EM/
