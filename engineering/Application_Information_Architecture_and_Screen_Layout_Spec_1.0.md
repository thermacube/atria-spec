# Thermacube Application Information Architecture & Screen Layout Specification

## Version 1.0

**Date:** September 26, 2026  
**Status:** Normative cross-application engineering standard  
**Canonical home:** `thermacube/atria-spec`  
**Reference implementation:** `thermacube/tmui`  
**Initial adopters:** Atria, CECPD Bridge, Thermacube Communications (Comms)

---

## 1. Purpose

This specification defines the shared information architecture, screen hierarchy, navigation placement, landmark structure, global utilities, search placement, account controls, Comms placement, notification placement, page composition, and responsive behavior for Thermacube applications.

The goal is to make Atria, Bridge, Comms, and future Thermacube applications feel like one coherent family while remaining optimized for their specific tasks.

This is an information-architecture and layout standard, not a visual styling specification.

TMUI governs appearance.

The Thermacube Accessibility Specification governs accessibility outcomes.

The HTMX Integration Specification governs server-driven interaction behavior.

---

## 2. Design basis

The standard draws from:

- W3C/WAI page-structure and landmark guidance;
- WCAG 2.2 accessibility requirements;
- ARIA Authoring Practices landmark guidance;
- GOV.UK service-navigation conventions;
- U.S. Web Design System header/navigation guidance;
- Yale information-architecture principles;
- peer-reviewed research on information scent and web navigation;
- empirical research on menu location.

The resulting layout deliberately favors conventional, predictable structures over novelty.

---

## 3. Governing principle

> **Global functions live globally; task-specific functions live close to the task.**

The UI hierarchy should move from broadest context to most specific:

```text
Thermacube/product identity
        ↓
global application navigation/utilities
        ↓
section context
        ↓
page context
        ↓
local task controls
        ↓
task content
```

Do not place a task-specific action in the global header merely because space is available.

Do not bury global utilities inside page-specific content.

---

## 4. Information architecture model

Thermacube IA decisions must consider:

### Context

- product purpose;
- organizational constraints;
- deployment environment;
- security/privacy needs;
- technical architecture.

### Content

- record types;
- workflows;
- reports;
- communication objects;
- learning content;
- administrative objects;
- frequency/volume.

### Users

- audiences;
- tasks;
- terminology;
- permissions;
- frequency of use;
- expertise.

These factors inform:

- organization;
- labeling;
- navigation;
- search.

This model follows Yale's information-architecture framing.

---

## 5. Task-oriented organization

Primary navigation MUST be organized around user-recognizable tasks or information domains rather than implementation modules or organizational ownership.

Prefer:

```text
Work
Courses
Reports
Commerce
Administration
```

over:

```text
Registry subsystem
Enrollment service
Identity subsystem
Payment service
```

unless the latter terms are genuinely the users' established domain vocabulary.

---

## 6. Information scent

Navigation labels must strongly predict the content or task behind them.

Labels SHOULD:

- use vocabulary users recognize;
- be short;
- be mutually distinguishable;
- avoid vague terms such as “Resources” or “Other” when a more specific label exists;
- avoid multiple labels that could plausibly describe the same destination;
- remain stable across the application family where the underlying concept is shared.

When two navigation choices compete semantically for the same user goal, IA should be revised rather than relying on visual emphasis to resolve ambiguity.

---

## 7. Primary shell

The default expanded desktop shell is:

```text
┌──────────────────────────────────────────────────────────────┐
│ Brand + Product              Global Search   Account  Comms │
├──────────────────────────────────────────────────────────────┤
│ Primary navigation                                           │
├──────────────────────────────────────────────────────────────┤
│ Optional service/system notice                               │
├──────────────────────────────────────────────────────────────┤
│ Breadcrumb / section context                                 │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│ Main content                                      Comms /    │
│                                                 context pane │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│ Minimal utility footer                                       │
└──────────────────────────────────────────────────────────────┘
```

Not every page uses every region.

Empty shell regions MUST NOT be rendered merely to preserve visual slots.

---

## 8. Landmark structure

A typical page SHOULD map visually and semantically to:

```html
<body>
  <a href="#main">Skip to main content</a>

  <header>...</header>

  <nav aria-label="Primary">...</nav>

  <div><!-- optional system notice --></div>

  <nav aria-label="Breadcrumb">...</nav>

  <main id="main">...</main>

  <aside aria-label="Communications">...</aside>

  <footer>...</footer>
</body>
```

Native HTML landmark elements are preferred.

Multiple landmarks of the same type must be labeled distinctly.

Landmarks must not proliferate unnecessarily.

As a general usability target, ordinary application pages SHOULD remain at approximately seven or fewer top-level landmark regions unless the product structure genuinely requires more.

---

## 9. Skip link

Every application shell with repeated navigation MUST provide a skip link as the first focusable control.

Default text:

```text
Skip to main content
```

The target must be the primary `main` region.

The skip link is visually hidden until focused.

---

## 10. Global header

The global header establishes:

- Thermacube identity;
- product/application identity;
- global search when present;
- user account access;
- Comms launcher.

The global header must remain compact.

It is not a marketing masthead.

---

## 11. Brand placement

A Thermacube identity area is reserved at the upper left.

Preferred presentation:

```text
[Thermacube mark] Product Name
```

Examples:

```text
Thermacube · Atria
Thermacube · Bridge
Thermacube · Comms
```

The brand area should ordinarily fit within approximately:

- 32–40 px mark height;
- 140–220 px total desktop width depending on product name.

These are design targets, not accessibility constraints.

The brand link should lead to the product's logical home.

---

## 12. Logo behavior

A logo may be:

- text;
- local SVG;
- local raster asset when justified.

Remote logo assets are prohibited.

The logo must have an accessible text equivalent.

The logo is not the page H1 except where the homepage information hierarchy genuinely makes that appropriate.

---

## 13. Header graphics

Operational Thermacube applications SHOULD NOT use decorative hero/header graphics.

Do not allocate persistent vertical space to:

- decorative illustrations;
- photographic mastheads;
- large gradients;
- promotional hero panels.

Exceptions require a product-specific content need, not aesthetic preference.

The normal application header should prioritize identity, navigation, search, account, and Comms.

---

## 14. Primary navigation placement

Primary application navigation is horizontal on expanded layouts by default.

This follows:

- strong industry convention;
- empirical evidence favoring top-horizontal and left-vertical menu positions;
- efficient use of wide workstation screens;
- compatibility with dense operational content.

Primary navigation appears below or within the global header depending on space, but must remain visually distinct from page-local tabs.

---

## 15. Primary navigation size

The primary navigation should contain only major application areas.

Target:

```text
3–7 top-level destinations
```

More than this should trigger an IA review before simply adding more items.

Items should appear in task/frequency priority order where possible.

---

## 16. Current location

The current top-level section must be visually and programmatically identifiable.

Use:

```html
aria-current="page"
```

or the appropriate current-state value.

Color alone may not indicate current location.

---

## 17. Left-side local navigation

Persistent left navigation is NOT part of every screen.

Use left-side local navigation only when a section has enough internal depth or repeated lateral navigation to justify it.

Examples:

- Administration;
- system configuration;
- multi-part account/settings;
- deep documentation/content structures.

A useful trigger is when users repeatedly move among several closely related subareas within one primary section.

---

## 18. Left-navigation relationship

When local left navigation exists:

```text
Primary top navigation
    ↓
Section
    ↓
Left local navigation
    ↓
Current page
```

The left navigation MUST NOT duplicate the full global navigation.

It should represent only the local section.

---

## 19. Mobile/navigation collapse

On narrow layouts, horizontal navigation may become:

- a disclosure/drawer;
- a compact navigation panel;
- another accessible collapsed form.

The collapsed navigation must:

- use a native button;
- expose expanded/collapsed state;
- be keyboard operable;
- keep DOM/focus order consistent with visual order;
- close accessibly;
- not rely on hover.

---

## 20. Breadcrumbs

Breadcrumbs are optional contextual navigation.

Use them when hierarchy materially improves orientation.

Good:

```text
Reports > Registry > Completion 28184
```

Avoid adding shallow breadcrumbs that communicate little:

```text
Home > Reports
```

Breadcrumbs should appear after global/service navigation and immediately before the main content region.

This allows a skip link to bypass repeated navigation including breadcrumbs.

---

## 21. Page title

Every substantial page/view has one clear H1 describing the current task/content.

The H1 is page-specific.

The brand/product name is not repeated as the H1 unless it is the actual page topic.

---

## 22. Page header composition

Default page header order:

```text
optional eyebrow/context
H1
short supporting description
page-level status/notice
primary contextual actions
local view navigation/tabs
```

Actions may share the horizontal row with the title on large screens but must follow logical DOM/focus order.

---

## 23. Page-specific actions

Page-specific actions belong near the page heading or relevant record header.

Examples:

- Create course;
- Export CSV;
- Edit record;
- Approve;
- Mark complete.

Do not place such actions in the global header.

If there are many secondary actions, use a disclosure/action list rather than an ever-growing toolbar.

---

## 24. Local tabs

Local tabs switch among sibling views of the same task/domain.

Default Thermacube tabs are ordinary server-navigation links with current state.

Examples:

```text
Pending | Complete
Overview | History | Permissions
```

Do not use tabs for unrelated primary application areas.

Do not implement a full ARIA tab widget unless true in-page tab-panel behavior is required.

---

## 25. Search architecture

Thermacube distinguishes:

1. global/product search;
2. local search/filter.

These must not be conflated.

---

## 26. Global search

Global search belongs in the global header/utilities area when the product supports meaningful cross-domain discovery.

It should search only entities the current user is authorized to discover.

The UI must communicate the search scope.

Examples:

```text
Search Bridge
Search Atria
```

Do not add a global search control merely because it is conventional.

---

## 27. Search landmark

A global search region should use the native/search landmark where supported or equivalent ARIA semantics.

If more than one search region exists, each must be labeled distinctly.

Examples:

```text
Global search
Registry search
Course search
```

---

## 28. Local search/filter

Page-local search belongs with filters above the relevant results.

Typical order:

```text
From | To | Course | Search | Rows | Apply
```

Local filters should be in normal document flow and remain associated with the results they control.

HTMX may enhance the interaction under the HTMX Integration Specification.

---

## 29. User account controls

User/account controls belong in the upper-right global utility area.

The collapsed control should identify the current user through:

- name;
- initials/avatar plus accessible name;
- another clear account label.

Typical contents:

```text
Profile
Preferences
Account/security
Sign out
```

Use a disclosure unless a true application menu interaction is necessary.

---

## 30. Comms launcher placement

When Comms is available inside another Thermacube application, the collapsed Comms launcher belongs in the upper-right global utility area near account controls.

Collapsed state:

```text
[Messages] [Chat] [Voice]
```

The three controls remain independently accessible.

This placement establishes Comms as a persistent global capability rather than a page-specific tool.

---

## 31. Comms expanded surface

On expanded desktop layouts, Comms SHOULD open as a right-side contextual application surface.

Preferred model:

```text
main application work area | Comms sidecar
```

The main application remains visible when space permits.

Comms should not permanently consume sidecar width when collapsed.

---

## 32. Comms narrow/mobile surface

On compact layouts, Comms may become:

- a full-width sheet;
- a full-screen application surface;
- a modal-like overlay when correctly implemented.

The user's previous host context must remain recoverable.

Focus transfer and restoration follow the accessibility specification.

---

## 33. Comms iframe/container semantics

If a browser iframe is used for isolation:

- the iframe MUST have a meaningful `title`;
- the host container SHOULD be a labeled complementary/communications region when semantically appropriate;
- host and embedded document retain their own valid landmark structures;
- host and Comms share responsibility for focus transition across the boundary.

Example:

```html
<aside aria-label="Communications">
  <iframe title="Thermacube Communications">
```

Do not expose an unlabeled generic iframe.

---

## 34. Page-level notifications

Action feedback belongs near the page/task that caused it.

Default location:

```text
H1 / page context
notification/status
local navigation
filters/content
```

Examples:

- Saved;
- 4 records completed;
- Payment could not be processed;
- Invalid date range.

Important feedback should remain reviewable.

---

## 35. Global/system notifications

Application-wide service information belongs beneath global navigation/header and above page-specific context.

Examples:

- scheduled maintenance;
- service degradation;
- environment-wide policy notice.

These messages should appear consistently across relevant pages.

Do not use global banners for page-local success/error feedback.

---

## 36. Toast policy

Auto-expiring floating toasts are not the default Thermacube pattern.

Prefer persistent contextual notices.

A transient message may be used only when:

- the information is nonessential;
- loss of the message does not block recovery;
- assistive technology behavior remains appropriate.

Bottom-right toast stacks are not a standard shell requirement.

---

## 37. Tables

Dense operational tables should occupy the main work area and use as much horizontal width as the task requires.

Do not constrain wide data tables to an unnecessarily narrow reading column.

Use:

- compact density for staff operations;
- clear header relationships;
- right/decimal alignment for numeric data where helpful;
- row actions at a predictable edge;
- horizontal overflow when two-dimensional data is essential.

Persistent left navigation should be avoided on especially wide-table views unless its value outweighs lost working width.

---

## 38. Forms

Ordinary forms should use a comfortable reading width rather than full workstation width.

Default pattern:

```text
Page title
supporting text
form in narrow/medium content column
primary action
```

Complex administrative forms may use sections/columns where relationships remain clear.

Labels ordinarily appear above controls.

---

## 39. Lists and queues

Operational queues may use:

- tables for comparable columnar data;
- lists/cards when entries are heterogeneous or narrative;
- split list/detail views when rapid triage benefits.

The data structure determines the component—not a preference for cards.

---

## 40. Record/detail views

A record detail view should use:

```text
breadcrumb/context
record H1
record type / status / key metadata
primary actions
local tabs if needed
content sections
history/audit as appropriate
```

Metadata relationships should use semantic lists/definition lists rather than visual-only tiles where practical.

---

## 41. Context panels

A right-side context panel may be used for:

- Comms;
- record metadata;
- related activity;
- help/context;
- secondary preview.

Only one persistent contextual side panel should normally compete with the main work area at a time.

Do not create dashboards with multiple equally weighted sidebars.

---

## 42. Footer

Thermacube applications use a minimal utility footer.

Typical contents:

- Thermacube identity/copyright if required;
- Accessibility;
- Privacy;
- Support/help;
- application version/build where useful;
- environment indicator where operationally useful.

Avoid:

- marketing columns;
- giant sitemaps;
- social-media promotion;
- repeated primary navigation.

---

## 43. Footer semantics

The top-level footer represents the page's `contentinfo` landmark.

Only one top-level contentinfo landmark should normally exist.

A nested component footer does not act as the application footer.

---

## 44. Standard desktop proportions

TMUI should support a normal application content maximum width around the existing shared content token, while allowing full-width operational views.

Approximate design targets:

- global header: 48–64 px high;
- primary nav: 40–48 px when separate;
- logo mark: 32–40 px;
- right sidecar: approximately 320–420 px when expanded;
- reading/form column: roughly 640–760 px;
- operational content: up to the available viewport/container width.

These are layout targets, not rigid accessibility constraints.

Content, zoom, localization, and user settings may require expansion.

---

## 45. Vertical economy

Thermacube operational applications prioritize useful content above the fold without sacrificing readability.

Avoid stacking:

- oversized logo area;
- separate decorative masthead;
- oversized primary navigation;
- large breadcrumb row;
- oversized page title block;
- large empty card padding

before the user reaches the task.

A normal desktop staff page should reach useful controls/content quickly.

---

## 46. Responsive hierarchy

Responsive layouts must preserve semantic and task hierarchy.

A typical transformation:

### Expanded

```text
brand + nav + utilities
main work + optional sidecar
```

### Medium

```text
brand + utilities
wrapped/collapsed nav
main work
sidecar narrower or overlay
```

### Compact

```text
compact header
navigation disclosure
main work
Comms full-width sheet when open
```

Do not use CSS ordering that creates a different keyboard/focus order from visual order.

---

## 47. Consistent placement

Shared functions must appear in consistent locations across applications.

Examples:

- brand: upper left;
- account: upper right;
- Comms: upper right;
- global search: upper-right utility area when present;
- primary navigation: top horizontal;
- local navigation: left only when deep;
- page title: start of main content;
- filters: above controlled results;
- pagination: after results;
- page feedback: near page heading/task;
- global notices: below application navigation;
- footer: bottom utility region.

Consistency may be broken only for a concrete task reason.

---

## 48. Cognitive load

A screen should avoid presenting several equally dominant action groups.

Hierarchy should make clear:

- where am I?
- what is this page?
- what can I do here?
- what changed?
- where do I go next?

Visual hierarchy should reinforce information hierarchy, not substitute for it.

---

## 49. Naming consistency

The same concept must use the same label across Thermacube applications unless the audience genuinely uses different terminology.

Examples:

- “Sign out” should not become “Log off” elsewhere without reason;
- “Reports” should not become “Analytics” for the same function;
- “Messages” / “Chat” / “Voice” should remain stable Comms labels.

Terminology changes are IA changes and should be reviewed accordingly.

---

## 50. Role-aware navigation

Authorization may remove inaccessible destinations.

However, the remaining navigation structure should remain coherent.

Do not leave:

- empty headings;
- unexplained gaps;
- disabled links to unauthorized areas;
- navigation groups containing no visible destinations.

Authorization does not change the meaning of shared navigation labels.

---

## 51. Empty states

Empty states appear within the region that would otherwise contain results.

They should explain:

- that no content is present;
- why, when known;
- the next useful action, when one exists.

An empty state should not displace the global/page navigation structure.

---

## 52. Error states

Page-level errors remain within the normal shell whenever possible so users retain orientation and recovery options.

A recoverable report error should not replace the entire application with a blank error page.

Authentication/security boundaries may require a full-page transition.

---

## 53. IA research process

Before adding a new primary navigation destination or major shell region, teams SHOULD evaluate:

- user task frequency;
- user terminology;
- relationship to existing destinations;
- whether an existing destination can contain the function;
- whether the label creates ambiguity with another choice.

For significant navigation changes, useful methods include:

- task analysis;
- card sorting;
- tree testing;
- usability testing;
- search/log analysis;
- support-ticket analysis.

The design system does not replace user research.

---

## 54. Information-scent acceptance test

For each top-level or local navigation label, reviewers should ask:

> If a user states the task they are trying to accomplish, is this destination clearly more semantically relevant than the competing choices?

If two choices appear equally plausible, revise the labels or grouping.

Visual prominence alone is not an acceptable solution to weak information scent.

---

## 55. Layout conformance tests

Application tests SHOULD verify stable structural requirements such as:

- one primary `main`;
- skip link target exists;
- primary navigation is labeled;
- current page/section exposed;
- breadcrumbs are not duplicated;
- global and local search are distinguishable;
- Comms launcher remains in the global utility region;
- iframe has a meaningful title where used;
- footer remains minimal;
- landmark count remains reasonable;
- DOM order matches meaningful reading/focus order.

Visual regression tests MAY verify positioning but do not prove IA/accessibility correctness.

---

## 56. Standard shell reference

The canonical conceptual shell is:

```text
Skip link

HEADER
  Thermacube / Product
  optional Global Search
  Account
  Comms: Messages / Chat / Voice

PRIMARY NAVIGATION
  task-oriented major destinations

OPTIONAL SYSTEM NOTICE

OPTIONAL BREADCRUMB

MAIN
  Page heading
  Supporting context
  Page status/error
  Page actions
  Optional local tabs
  Optional filters
  Primary task content
  Pagination / task continuation

OPTIONAL COMPLEMENTARY SURFACE
  Comms or another singular contextual panel

FOOTER
  Accessibility / Privacy / Support / Version
```

---

## 57. Initial application profiles

### 57.1 Atria

Atria uses the shared shell with learner/staff context-specific primary navigation. Learning/content pages may use narrower reading layouts; administration may use optional local left navigation.

### 57.2 Bridge

Bridge uses wide operational layouts for Registry, payments, reports, imports, and staff queues. Learner pages use standard/narrower forms and content layouts.

### 57.3 Comms

Standalone Comms uses the same brand/global hierarchy. When embedded, the collapsed Messages/Chat/Voice controls occupy the host global-utility position and the expanded application uses the contextual right-side surface.

---

## 58. Conformance

An application conforms to Thermacube Application Information Architecture & Screen Layout Specification v1.0 when:

1. navigation reflects recognizable user tasks/information domains;
2. labels provide strong information scent;
3. brand is upper left and global utilities are upper right;
4. primary navigation is conventional and consistent;
5. local left navigation appears only when section depth justifies it;
6. global vs local search are distinguished;
7. account and Comms placement follow the shared shell;
8. page/system notifications appear at the appropriate hierarchy;
9. main content uses a clear H1 and logical region order;
10. responsive behavior preserves semantic/focus order;
11. landmark structure follows accessibility guidance;
12. footer remains a minimal utility region;
13. application-specific deviations are documented.

---

## 59. References

Accessibility and layout:

- W3C/WAI Page Structure Tutorial — https://www.w3.org/WAI/tutorials/page-structure/
- W3C/WAI Page Regions — https://www.w3.org/WAI/tutorials/page-structure/regions/
- W3C/WAI Labeling Regions — https://www.w3.org/WAI/tutorials/page-structure/labels/
- WAI-ARIA APG Landmark Regions — https://www.w3.org/WAI/ARIA/apg/practices/landmark-regions/
- WAI-ARIA APG Landmarks Pattern — https://www.w3.org/WAI/ARIA/apg/patterns/landmarks/

Information architecture and navigation:

- YaleSites, Basic Principles of Information Architecture — https://yalesites.yale.edu/explore-resources/basic-principles-of-information-architecture
- GOV.UK Design System, Navigate a service — https://design-system.service.gov.uk/patterns/navigate-a-service/
- U.S. Web Design System, Header — https://designsystem.digital.gov/components/header/

Research:

- Blackmon, M. H. (2012), “Information scent determines attention allocation and link selection among multiple information patches on a webpage,” Behaviour & Information Technology, 31(1), 3–15. DOI: 10.1080/0144929X.2011.599041.
- Murano, P. & Lomas, T. J. (2015), “Menu Positioning on Web Pages. Does it Matter?”, International Journal of Advanced Computer Science and Applications, 6(4). DOI: 10.14569/IJACSA.2015.060419.

The research informs this standard; Thermacube retains responsibility for testing the resulting information architecture with its own users.
