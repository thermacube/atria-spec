# Thermacube Application UI Design Specification

## Version 1.0

**Date:** September 26, 2026  
**Status:** Normative cross-application engineering standard  
**Canonical home:** `thermacube/atria-spec`  
**Reference implementation:** `thermacube/tmui`  
**Initial adopters:** Atria, CECPD Bridge, Thermacube Communications (Comms)

---

## 1. Purpose

This specification defines the common visual, structural, interaction, and implementation standard for Thermacube application user interfaces.

The reference implementation is **Thermacube Minimal UI (TMUI)**.

TMUI is designed for server-rendered, HTMX-driven applications that prioritize:

- semantic HTML;
- accessibility;
- progressive enhancement;
- low client complexity;
- low asset weight;
- low processing cost;
- low bytes in transit;
- small developer learning curve;
- visual consistency;
- deterministic local dependencies;
- long-term maintainability.

The simplest correct interface wins.

---

## 2. Design lineage

TMUI is a Thermacube-owned design system influenced primarily by:

### 2.1 Pico CSS

TMUI adopts Pico's useful design philosophy:

- semantic HTML as the starting point;
- class-light markup;
- attractive defaults for native elements;
- responsive behavior without a large utility vocabulary;
- pure CSS rather than a required JavaScript component runtime;
- design-system behavior expressed through CSS variables/tokens.

TMUI does **not** adopt Pico as a production runtime dependency.

Pico source code may be studied or selectively adapted only where licensing, attribution, and provenance requirements are satisfied. Thermacube applications consume TMUI-owned versioned assets, not an upstream Pico package or CDN.

### 2.2 GOV.UK Design System

TMUI adopts GOV.UK's useful implementation discipline:

- accessibility as a design-system responsibility but not a substitute for application testing;
- semantic HTML first;
- core content available without CSS where practical;
- primary workflows that remain understandable without JavaScript where practical;
- JavaScript as progressive enhancement rather than the foundation of application meaning;
- predictable reusable patterns;
- clarity over decorative novelty;
- tolerance for error;
- low cognitive and physical effort.

TMUI does **not** adopt GOV.UK visual branding.

### 2.3 Thermacube ownership

TMUI is not a theme layered on Pico or GOV.UK.

TMUI owns its:

- design tokens;
- CSS;
- component patterns;
- visual identity;
- spacing;
- typography;
- density;
- icons;
- interaction conventions;
- accessibility integration;
- HTMX conventions;
- tests;
- release artifacts.

---

## 3. Governing principle

> **Prefer native HTML over custom components, CSS over JavaScript, server-rendered state over client state, text over unexplained icons, borders over visual effects, and one reusable pattern over application-specific variation.**

A UI implementation that requires more layers, code, state, network traffic, or developer knowledge must justify why the simpler implementation cannot satisfy the requirement.

---

## 4. Relationship to other Thermacube standards

TMUI depends on and must remain compatible with:

- **Thermacube Application Accessibility Specification v1.0**
- **Thermacube Application Request Perimeter Specification v1.0**
- applicable Atria, Bridge, or Comms application specifications.

Accessibility requirements override purely visual preferences.

Security requirements override convenience-driven client behavior.

TMUI does not own business logic, authorization, request filtering, or application persistence.

---

## 5. Runtime architecture

The preferred UI request model is:

```text
Browser
  ↓
semantic HTML
  ↓
TMUI CSS
  ↓
optional HTMX enhancement
  ↓
server request
  ↓
application/domain logic
  ↓
server-rendered HTML fragment/page
  ↓
HTMX swap or ordinary navigation
```

TMUI MUST NOT require:

- React;
- Vue;
- Angular;
- Svelte;
- a client-side routing framework;
- a virtual DOM;
- client-side JSON rendering;
- CSS-in-JS;
- a JavaScript component runtime;
- remote fonts;
- remote icon services;
- remote CSS;
- remote JavaScript.

---

## 6. Dependency policy

Production TMUI assets MUST be locally owned and versioned.

A conforming application MUST NOT depend at runtime on:

- a third-party CDN;
- an unpinned package;
- a remotely hosted font;
- a remotely hosted icon library;
- a remotely hosted stylesheet;
- a remotely hosted JavaScript component bundle.

If upstream open-source work is incorporated, Thermacube must use one of these models:

1. copy and preserve the exact licensed source needed;
2. fork and maintain it;
3. derive an independent implementation from documented ideas;
4. vendor a pinned, reviewable release artifact.

Applications MUST NOT silently follow an upstream `main`, `latest`, floating package range, or CDN alias.

---

## 7. Deployment model

TMUI releases are versioned independently.

Applications consume an exact TMUI release or exact commit.

Preferred deployment model:

```text
thermacube/tmui
    ↓
TMUI 1.x release
    ↓
vendored/pinned application asset
    ↓
Atria / Bridge / Comms
```

The browser should receive ordinary static assets from the same controlled deployment environment as the application.

A production application must remain functional if all external public CDNs are unavailable.

---

## 8. Semantic HTML as the component foundation

Native HTML elements are the default TMUI component set.

Examples:

- `button` for actions;
- `a` for navigation;
- `input`, `select`, `textarea` for entry;
- `label` for form labels;
- `fieldset` and `legend` for grouped input;
- `table` for tabular data;
- `details` / `summary` where disclosure semantics fit;
- `dialog` where browser support and required behavior are appropriate;
- `progress` where native progress semantics fit;
- `nav`, `main`, `header`, `footer`, `aside`, `section` for document/application structure.

A clickable `div` or `span` is prohibited when a native interactive element can perform the function.

---

## 9. Class-light design

TMUI should style native elements directly whenever the style is broadly correct.

Classes are reserved for:

- layout patterns;
- application-shell structures;
- component variants;
- density modifiers;
- explicit semantic/status variants;
- patterns native HTML cannot distinguish.

TMUI MUST NOT become a utility-class framework.

Markup such as this is discouraged:

```html
<div class="flex row gap-2 p-3 mt-2 radius-2 shadow-sm text-sm">
```

Prefer semantic structure plus a small pattern class:

```html
<section class="tmui-panel">
```

---

## 10. CSS architecture

The initial production target is one canonical stylesheet:

```text
tmui.css
```

A minified release artifact MAY also be produced:

```text
tmui.min.css
```

Development sources MAY be split internally for maintainability, but applications should not need to understand TMUI's internal source tree.

TMUI MUST NOT require Sass, Node, npm, Composer, or another build tool at application runtime.

Build tooling is permitted for TMUI maintainers if release artifacts are deterministic and checked into/releases from the TMUI repository.

---

## 11. Design tokens

TMUI uses a small semantic token vocabulary.

Tokens must describe purpose rather than one-off appearance.

### 11.1 Core color roles

Required baseline roles:

```css
--tmui-color-bg
--tmui-color-surface
--tmui-color-surface-subtle
--tmui-color-text
--tmui-color-text-muted
--tmui-color-border

--tmui-color-primary
--tmui-color-primary-text

--tmui-color-success
--tmui-color-warning
--tmui-color-error
--tmui-color-info

--tmui-color-focus
```

Applications MUST NOT introduce arbitrary brand/status colors directly in component CSS when an existing semantic token fits.

### 11.2 Spacing scale

TMUI uses a deliberately small spacing scale:

```text
4px
8px
12px
16px
24px
32px
48px
```

These map to semantic CSS variables.

Arbitrary one-off spacing values SHOULD NOT be introduced without a documented layout need.

### 11.3 Radius scale

TMUI uses two routine radii:

```text
4px  controls
8px  panels/dialogs
```

Additional radii require a documented component need.

### 11.4 Typography scale

Baseline application typography:

```text
14px  supporting / compact table text
16px  body / control text
20px  section title
28px  page title
36px  rare major heading
```

Responsive adjustments MAY be used where readability requires them, but applications must not invent independent type scales.

---

## 12. Typography

TMUI uses a local system-font stack by default.

No remote webfont is required.

Preferred principle:

```css
font-family:
  system-ui,
  -apple-system,
  BlinkMacSystemFont,
  "Segoe UI",
  sans-serif;
```

Exact implementation is owned by TMUI.

Typography should be neutral, legible, and subordinate to application content.

Decorative typography is outside the default application system.

---

## 13. Visual character

TMUI should appear:

- clean;
- quiet;
- modern;
- compact;
- professional;
- legible;
- predictable.

TMUI should avoid:

- gratuitous gradients;
- excessive shadows;
- oversized cards;
- excessive corner rounding;
- ornamental animation;
- glass effects;
- skeuomorphic surfaces;
- decorative background imagery in operational screens;
- visual novelty that obscures hierarchy.

---

## 14. Surface and elevation model

TMUI favors borders and spacing over shadows.

Baseline levels:

### Level 0

Normal document/page surface.

No shadow.

### Level 1

Panels, cards, toolbars, grouped operational regions.

Prefer border plus surface token.

Shadow generally unnecessary.

### Level 2

Dialogs, temporary overlays, elevated transient surfaces.

One restrained shadow MAY be used.

Applications SHOULD NOT invent additional elevation levels.

---

## 15. Density

TMUI defines two supported density modes.

### 15.1 Standard

Used for:

- learner/user-facing forms;
- reading/content;
- checkout;
- course surfaces;
- ordinary communication;
- general application views.

### 15.2 Compact

Used for:

- staff queues;
- administration;
- financial review;
- Registry processing;
- audit history;
- reports;
- dense data tables;
- operational dashboards.

Compact mode uses the same component semantics and visual hierarchy with reduced vertical spacing and control height.

Density is not permission to violate accessibility target-size or focus requirements.

---

## 16. Layout primitives

TMUI keeps layout vocabulary small.

Initial permitted layout patterns:

- document/container;
- stack;
- cluster;
- columns/grid;
- sidebar;
- toolbar;
- split view;
- centered narrow form;
- full-width operational table;
- overlay/dialog;
- drawer/sheet.

The implementation MAY expose a small number of classes such as:

```text
.tmui-container
.tmui-stack
.tmui-cluster
.tmui-grid
.tmui-sidebar
.tmui-toolbar
.tmui-split
```

The final class vocabulary should remain substantially smaller than utility-first frameworks.

---

## 17. Responsive model

TMUI is responsive by default.

The implementation SHOULD use content-driven layout and CSS features such as:

- flexbox;
- grid;
- min/max/clamp;
- intrinsic sizing;
- container-aware patterns where practical.

Breakpoints should exist only where layout meaningfully changes.

Applications should think in terms of available space:

```text
compact
medium
expanded
wide
```

rather than specific consumer device models.

---

## 18. Application shell

TMUI defines a common shell vocabulary:

- application identity/title;
- primary navigation;
- current-location indication;
- global/user actions;
- page heading;
- main content;
- optional contextual region;
- optional persistent embedded utility surface.

The shell must remain usable without relying on pointer-only interaction.

Atria, Bridge, and Comms may use different arrangements while preserving the same component styling and behavior.

---

## 19. Buttons and actions

TMUI supports a deliberately small action vocabulary:

- primary;
- secondary;
- quiet/text;
- destructive;
- icon-only.

Applications should generally present only one visually dominant primary action in a local decision context.

Button text should describe the action.

Icon-only buttons require accessible names.

Buttons MUST NOT be used for navigation when a link is semantically correct.

---

## 20. Links

Links are visually recognizable as navigation.

Application styling must not make ordinary links indistinguishable from non-interactive text.

A link that triggers state-changing business behavior is prohibited unless the underlying semantics genuinely represent navigation to a state-changing workflow.

---

## 21. Forms

TMUI form design prioritizes directness.

Default structure:

```text
Label
Optional supporting text
Control
Validation/error text when applicable
```

Requirements:

- persistent labels;
- no placeholder-only labeling;
- clear required/optional behavior;
- consistent control height;
- errors next to the relevant field;
- error summary for multi-field failures where appropriate;
- preserved entered values after correctable failures;
- native input types where useful and accessible;
- minimal decorative wrappers.

---

## 22. Tables and operational data

Use native tables when information is tabular.

TMUI tables support:

- normal density;
- compact density;
- sortable headings;
- selected rows;
- row actions;
- status cells;
- numeric alignment;
- responsive overflow or alternate narrow layout where necessary.

ARIA grid behavior is reserved for interfaces that truly behave as composite interactive grids.

A table must not be converted to a grid merely to achieve styling.

---

## 23. Status and semantic color

TMUI defines semantic states:

- success;
- warning;
- error;
- information;
- neutral.

Color alone must never convey state.

A status pattern should include text and MAY include an icon.

Examples:

```text
Complete
Needs review
Failed
Pending
```

Applications should not invent project-specific status color palettes.

---

## 24. Panels and cards

Panels are used only when grouping improves comprehension.

Not every section should be a card.

Default grouping preference:

1. heading + whitespace;
2. divider;
3. bordered panel;
4. elevated surface only when interaction requires elevation.

Nested cards SHOULD be avoided.

---

## 25. Dialogs, drawers, and sheets

Use temporary overlay surfaces only when the task benefits from preserving the current context.

Do not use dialogs for routine navigation.

Dialogs/drawers must follow the shared accessibility specification for:

- focus entry;
- focus containment when modal;
- escape/cancel behavior;
- accessible name;
- logical focus restoration.

---

## 26. Icons

TMUI MUST NOT depend on an external icon font or icon CDN.

Icons should be provided as:

- a small TMUI-owned SVG sprite; or
- locally bundled SVG assets.

Icons are supplementary.

Text is preferred when an icon's meaning is not immediately conventional.

Icon-only controls require accessible labels.

---

## 27. Motion

TMUI uses motion sparingly.

Animation is appropriate only when it communicates:

- spatial relationship;
- open/close state;
- progress/state transition;
- continuity.

Decorative motion should be omitted.

Reduced-motion user preferences must be respected.

---

## 28. Dark mode

Dark mode is optional for TMUI v1.0 implementation but the token model must not prevent it.

If implemented:

- it must use semantic tokens rather than component-specific overrides;
- accessibility contrast requirements still apply;
- applications must not independently invent their own dark themes.

---

## 29. Progressive enhancement

The primary application path should be understandable with HTML alone.

CSS enhances presentation.

HTMX enhances interaction.

JavaScript may enhance behavior where HTML/HTMX cannot correctly provide it.

The application must avoid putting business meaning exclusively in client-side ephemeral state.

Where a non-JavaScript fallback is reasonably possible for a core workflow, it SHOULD exist.

---

## 30. HTMX interaction standard

HTMX is the preferred general-purpose browser interaction enhancement for Thermacube applications.

### 30.1 Server authority

The server remains authoritative for application state.

Preferred:

```text
user action
  -> HTMX request
  -> domain mutation/query
  -> server renders authoritative fragment
  -> fragment replaces target
```

Avoid:

```text
server returns JSON
  -> custom JavaScript interprets state
  -> custom JavaScript rebuilds interface
```

unless the use case genuinely requires a non-HTML protocol.

### 30.2 Ordinary HTTP semantics

Where practical, an HTMX-enhanced link/form should remain a meaningful normal link/form.

### 30.3 Fragment completeness

A returned fragment should contain the complete new state of the replaced UI region rather than requiring many client-side patches.

### 30.4 Stable identity

Elements involved in focus preservation, validation association, or targeted replacement should have stable IDs where appropriate.

### 30.5 History

HTMX history behavior should be used only where browser back/forward semantics remain understandable.

### 30.6 Loading and failure

Requests that take noticeable time should expose clear busy state.

Network/server failures must produce a recoverable interface rather than leaving a control indefinitely disabled or visually ambiguous.

---

## 31. JavaScript policy

JavaScript is not prohibited.

It is exceptional.

Before adding custom JavaScript, the implementation must consider, in order:

1. can native HTML solve it?
2. can CSS solve it?
3. can an ordinary HTTP interaction solve it?
4. can HTMX solve it?
5. is custom JavaScript still necessary?

Custom JavaScript should be narrowly scoped to the capability that requires it.

A general client state-management layer is outside TMUI's default architecture.

---

## 32. Client-state policy

Business-authoritative state must not live only in the browser.

Permitted client-local state includes presentation concerns such as:

- whether a non-authoritative panel is open;
- transient focus/presentation state;
- temporary UI preferences;
- local optimistic affordances that cannot override server truth.

Payments, authorization, workflow state, record state, enrollment state, communication authority, or similar domain decisions remain server authoritative.

---

## 33. Accessibility

TMUI implementations MUST conform to the Thermacube Application Accessibility Specification.

TMUI components must be designed and tested for:

- semantic correctness;
- keyboard operation;
- focus visibility/order;
- accessible names/descriptions;
- zoom/reflow;
- contrast;
- target size;
- status/error announcement;
- screen-reader operation;
- reduced motion where applicable.

Using TMUI does not by itself establish application WCAG conformance.

---

## 34. Performance and transfer philosophy

TMUI has no fixed byte budget in v1.0, but the implementation is governed by these requirements:

- no unused general-purpose client framework;
- no remote fonts;
- no icon font;
- no runtime theme engine;
- no hydration;
- no client template runtime;
- no framework JavaScript merely to style controls;
- avoid sending markup wrappers that exist only to satisfy styling.

Release reviews SHOULD track:

- uncompressed CSS bytes;
- compressed CSS bytes;
- icon asset bytes;
- optional JavaScript bytes;
- DOM complexity of representative components.

Growth in runtime asset weight should require a concrete capability justification.

---

## 35. Network efficiency

HTMX fragments should be scoped to the smallest coherent region that can be replaced safely and accessibly.

Do not resend a complete application shell when only one row or panel changed unless full replacement simplifies correctness enough to justify the additional transfer.

Do not split one logical update into many requests merely to minimize individual response size.

Correctness and comprehensibility come before micro-optimization.

---

## 36. Browser capability policy

TMUI targets maintained modern browsers used by supported Thermacube deployments.

Progressive enhancement should reduce dependence on fragile browser-specific behavior.

A new CSS/HTML feature may be used when:

- support is adequate for the supported deployment population; or
- a simple acceptable fallback exists.

---

## 37. Component vocabulary

TMUI v1 should remain deliberately small.

### Structure

- application shell;
- navigation;
- page header;
- section header;
- toolbar;
- panel;
- divider.

### Actions

- button;
- link;
- icon button;
- menu when required.

### Forms

- text input;
- textarea;
- select;
- checkbox;
- radio;
- switch only where binary immediate-state semantics fit;
- field group;
- error summary.

### Data

- table;
- data list;
- filter bar;
- pagination;
- status/badge.

### Feedback

- inline alert;
- status region;
- progress;
- loading/busy state;
- empty state;
- error state;
- confirmation state.

### Overlays/navigation

- tabs;
- dialog;
- drawer/sheet;
- disclosure.

Additional components require a demonstrated reusable need.

---

## 38. Component acceptance rule

A TMUI component is not complete until it has:

- intended semantic element/role;
- supported variants;
- keyboard behavior;
- focus behavior;
- responsive behavior;
- accessibility requirements;
- HTMX behavior where relevant;
- example markup;
- tests;
- documentation describing when **not** to use it.

---

## 39. Source organization

The reference implementation should begin approximately as:

```text
thermacube/tmui/
├── README.md
├── LICENSE
├── css/
│   ├── tmui.css
│   └── tmui.min.css
├── icons/
│   └── tmui-icons.svg
├── examples/
│   ├── forms.html
│   ├── tables.html
│   ├── navigation.html
│   ├── dialogs.html
│   └── htmx-patterns.html
├── tests/
└── docs/
    └── implementation-contract.md
```

This structure is guidance; unnecessary files/directories should not be created merely to satisfy the diagram.

---

## 40. Naming

Public implementation names use the `tmui-` prefix where a class is necessary.

Examples:

```text
.tmui-container
.tmui-stack
.tmui-panel
.tmui-button--danger
.tmui-compact
```

Classes should describe stable component/layout meaning rather than visual accidents.

Avoid names such as:

```text
.red
.mt-12
.shadow-lg
.rounded-xl
.left-20
```

---

## 41. Application-specific CSS

Applications MAY add local CSS for domain-specific interfaces.

Local application CSS:

- must consume TMUI tokens where applicable;
- must not redefine shared primitives inconsistently;
- must not create a parallel button/form/table design language;
- should remain smaller than the shared TMUI layer;
- should be promoted into TMUI when a pattern becomes cross-application.

---

## 42. Visual consistency enforcement

Conformance review should detect:

- arbitrary colors outside approved tokens;
- arbitrary spacing values where a token exists;
- unauthorized button variants;
- duplicate local form/control styling;
- utility-class proliferation;
- clickable non-interactive elements;
- inline style attributes except documented exceptional cases;
- remote UI dependencies;
- inconsistent status semantics;
- inaccessible icon-only controls.

Static linting MAY automate some of these checks.

---

## 43. Accessibility and interaction testing

TMUI must maintain test fixtures for shared patterns.

Testing should include:

- keyboard-only behavior;
- focus states;
- high zoom/reflow;
- forced colors where practical;
- reduced motion;
- screen-reader smoke tests for complex shared widgets;
- HTMX fragment replacement/focus behavior;
- form validation;
- dialogs/drawers;
- compact tables.

Application-level formal conformance remains governed by WCAG-EM through the accessibility specification.

---

## 44. Visual regression testing

Visual regression testing MAY be used for stable reference fixtures.

It must not become the only proof of UI correctness.

A visual snapshot cannot prove:

- semantics;
- accessible naming;
- keyboard behavior;
- focus behavior;
- screen-reader behavior;
- progressive enhancement.

---

## 45. Documentation style

TMUI documentation should favor executable examples over abstract descriptions.

Each pattern should answer:

- what is it?
- when should it be used?
- when should it not be used?
- what HTML should be written?
- what accessibility behavior is required?
- what HTMX behavior is supported?
- what variants exist?

---

## 46. Licensing and provenance

TMUI must maintain clear provenance for any third-party-derived implementation material.

Pico CSS is MIT licensed.

GOV.UK Frontend code is generally distributed under the MIT License, while its documentation is separately licensed.

Conceptual inspiration does not require importing either project as a runtime dependency.

If code is copied or substantially adapted, the relevant copyright/license notices must be preserved according to the applicable license.

---

## 47. Versioning

The specification and implementation are versioned separately.

Example:

```text
Application UI Design Specification v1.0
        ↓
TMUI 1.0.0
        ↓
Atria pins TMUI 1.0.0
Bridge pins TMUI 1.0.0
Comms pins TMUI 1.0.0
```

A TMUI release must identify which UI specification revision it implements.

Applications do not automatically follow newer TMUI releases.

---

## 48. Backward compatibility

Patch releases should not intentionally break documented markup.

Minor releases may add backward-compatible tokens, styles, and patterns.

Breaking markup, token, semantic, or behavioral changes require a major release.

Applications update deliberately.

---

### 48.1 Internationalization and localization

The Thermacube Application Internationalization & Localization Specification governs multilingual presentation requirements.

TMUI and application-specific CSS MUST remain direction-neutral where the layout meaning is logical, prefer CSS logical properties, tolerate translated text expansion, support system-font fallback for required scripts, and localize the accessibility surface together with visible UI text.

Localization MUST NOT create an alternate component system, RTL-only component family, or remote font/runtime dependency.

---

## 49. Initial application adoption

### 49.1 Atria

Atria uses TMUI for platform shell, navigation, forms, learning/application surfaces, administration, and shared module presentation.

Learning content itself may have additional authored-content requirements.

### 49.2 Bridge

Bridge uses TMUI standard density for learner-facing workflows and compact density for reporting, Registry, payments, queues, imports, and staff operations.

### 49.3 Comms

Comms uses TMUI for standalone/PWA and embedded interfaces.

Messages, Chat, and Voice remain visually coherent with Atria/Bridge while supporting communication-specific real-time interaction.

---

## 50. Conformance

An application conforms to Thermacube Application UI Design Specification v1.0 when:

1. its governing application specification explicitly adopts this version;
2. it consumes a pinned TMUI implementation version or an approved equivalent implementation;
3. shared primitives are not independently restyled into a conflicting design language;
4. semantic HTML is used as the default component foundation;
5. HTMX/server-rendered HTML is the default dynamic interaction model;
6. custom JavaScript is justified and narrowly scoped;
7. production has no uncontrolled remote UI dependency;
8. accessibility requirements are satisfied through the shared accessibility specification;
9. internationalization/localization requirements are satisfied through the shared i18n/l10n specification;
10. application-specific CSS follows TMUI tokens and conventions;
11. testing covers representative shared components and application workflows.

---

## 51. External references

Design influences and source references:

- Pico CSS mission — https://picocss.com/docs/mission
- Pico CSS documentation — https://picocss.com/docs
- Pico CSS class-less model — https://picocss.com/docs/classless
- Pico CSS source/license — https://github.com/picocss/pico
- GOV.UK Design System — https://design-system.service.gov.uk/
- GOV.UK accessibility strategy — https://design-system.service.gov.uk/accessibility/accessibility-strategy/
- GOV.UK accessibility guidance — https://design-system.service.gov.uk/accessibility/

These references document influences and provenance. They are not runtime dependencies.
