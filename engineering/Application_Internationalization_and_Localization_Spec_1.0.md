# Thermacube Application Internationalization & Localization Specification

## Version 1.0

**Date:** September 26, 2026  
**Status:** Normative cross-application engineering standard  
**Canonical home:** `thermacube/atria-spec`  
**Initial adopters:** Atria, CECPD Bridge, Thermacube Communications (Comms)  
**Reference visual implementation:** `thermacube/tmui`

---

## 1. Purpose

This specification defines the shared internationalization (i18n) and localization (l10n) requirements for Thermacube software.

The goal is to ensure that Thermacube applications can support multiple languages, locales, writing directions, scripts, date/number/currency conventions, plural systems, and translated accessibility metadata without redesigning application architecture.

This specification is designed to work directly with:

- Thermacube Application Accessibility Specification;
- Thermacube HTMX Integration Specification;
- Thermacube Application Information Architecture & Screen Layout Specification;
- Thermacube Application UI Design Specification / TMUI;
- application-specific specifications.

The design target is a server-driven, Unicode-native, locale-aware application architecture with minimal client complexity and no external runtime localization dependency.

---

## 2. Governing principle

> **Internationalization is an architectural property; localization is content/configuration applied to that architecture.**

Thermacube applications MUST NOT hard-code assumptions that make another language or locale require redesign.

A conforming application is structurally capable of supporting additional locales even when only one locale is initially shipped.

---

## 3. Definitions

### Internationalization (i18n)

Engineering the application so that multiple languages, locales, scripts, directions, and cultural conventions can be supported.

### Localization (l10n)

Providing language- and locale-specific messages, formats, labels, content variants, and conventions.

### Language

A human language identified using a BCP 47 language tag where applicable.

Examples:

- `en`
- `es`
- `ar`

### Locale

A language plus optional region/script/other subtags used to select presentation conventions.

Examples:

- `en-US`
- `es-US`
- `es-MX`
- `ar-SA`

### Direction

The base text/layout direction:

- left-to-right (LTR);
- right-to-left (RTL).

### Source locale

The locale in which a translatable message is authored and used as the translation baseline.

### Message catalog

A versioned collection of translatable application-interface messages.

---

## 4. Standards basis

Thermacube internationalization follows these external standards and best-practice sources:

- Unicode Standard;
- Unicode Common Locale Data Repository (CLDR);
- Unicode MessageFormat 2 concepts for structured localizable messages;
- IETF BCP 47 language tags (RFC 5646 / RFC 4647);
- W3C Internationalization guidance;
- HTML `lang` and `dir` semantics;
- CSS logical properties and writing modes;
- WCAG language-of-page and language-of-parts requirements.

Thermacube MAY implement a smaller internal runtime than these systems, but must preserve their relevant semantics rather than invent incompatible locale rules.

---

## 5. Unicode everywhere

All Thermacube application text paths MUST be Unicode-native.

UTF-8 is the required transport and storage encoding unless an external protocol mandates otherwise.

This includes:

- HTML;
- HTTP request/response bodies;
- forms;
- PHP source;
- JSON where used;
- CSV exports/imports unless a documented external contract requires another encoding;
- databases;
- message catalogs;
- logs where user text is retained;
- search indexes;
- generated documents where the format supports Unicode.

---

## 6. Database encoding

MariaDB/MySQL text storage MUST use full Unicode support.

New Thermacube schemas SHOULD use `utf8mb4` rather than MySQL's historical three-byte `utf8` alias.

Collation selection must be explicit and appropriate to the data purpose.

Do not assume that one language-specific collation is correct for all user-authored text.

---

## 7. Language identifiers

Thermacube uses BCP 47 language tags.

Applications MUST NOT invent private two-letter or ad hoc language identifiers when a registered BCP 47 tag exists.

Examples:

```text
en-US
es-US
es-MX
fr-CA
ar-SA
```

Use the least-specific tag that correctly represents the localized resource.

Do not add a region merely because the application happens to be deployed in that region if the translation is not region-specific.

---

## 8. Language tag matching

Supported-locale matching should follow BCP 47 lookup/filtering principles.

Applications must validate requested locale identifiers against the application-supported locale set.

An arbitrary user-supplied locale string must not become:

- a file path;
- an unvalidated catalog name;
- a template include;
- a trust boundary bypass.

---

## 9. Document language

Every complete HTML document MUST declare its default human language.

Example:

```html
<html lang="en-US">
```

A localized Spanish page might use:

```html
<html lang="es-US">
```

The value must describe the actual primary language of the page.

---

## 10. Language of parts

A phrase or passage in a different human language SHOULD be marked with `lang` when required by the accessibility standard.

Example:

```html
<p>Spanish title: <span lang="es">Bienvenidos</span></p>
```

Proper names and commonly adopted technical terms are handled according to WCAG language-of-parts rules.

---

## 11. Base direction

The HTML document MUST declare base direction when it is right-to-left.

Example:

```html
<html lang="ar" dir="rtl">
```

For LTR content, explicit `dir="ltr"` MAY be used but is not required when normal HTML defaults are sufficient.

Direction is semantic information and MUST NOT be represented only through CSS.

---

## 12. Embedded direction changes

When embedded content has a different base direction, use HTML direction semantics such as:

- `dir`;
- `bdi`;
- `bdo` only when intentional direction override is actually required.

Avoid manually inserting Unicode bidi control characters unless markup cannot represent the required semantics and the use is documented.

User-generated strings whose direction cannot be known in advance SHOULD use isolation where necessary to prevent surrounding punctuation/content from being reordered incorrectly.

---

## 13. Direction-neutral layout

Reusable Thermacube UI CSS MUST prefer logical properties.

Prefer:

```css
margin-inline-start
padding-inline-end
border-inline-start
inset-inline-end
inline-size
block-size
```

Avoid physical properties such as `left`, `right`, `margin-left`, or `padding-right` when the intended meaning is logical start/end.

Physical properties remain appropriate when the physical side itself is meaningful.

---

## 14. IA/layout terminology

The shared IA/layout standard must be interpreted logically.

Normative placement terms are:

- **inline start** for brand and local-navigation origin;
- **inline end** for global utilities and contextual sidecar;
- **block start** for top-level shell/header areas;
- **block end** for footer.

In LTR layouts:

```text
inline start = left
inline end   = right
```

In RTL layouts:

```text
inline start = right
inline end   = left
```

---

## 15. Mirroring

Layouts SHOULD mirror appropriately for RTL when logical relationships are directional.

Examples that normally mirror:

- shell brand/utilities order;
- side navigation placement;
- contextual sidecar placement;
- chevrons that mean forward/back;
- directional workflow arrows.

Examples that generally do not mirror merely because the page is RTL:

- media playback symbols whose established meaning is not reading direction;
- mathematical symbols;
- product logos;
- country flags;
- text-independent technical diagrams unless their logic is directional.

---

## 16. Locale is not language

Applications MUST NOT treat language, locale, region, timezone, numbering system, and currency as synonyms.

For example, a user may have:

```text
UI language: Spanish
locale: es-US
timezone: America/Chicago
currency: USD
```

Applications should store or resolve these concepts independently when product requirements require them.

---

## 17. Locale selection precedence

Unless an application has a documented reason otherwise, locale selection follows:

1. explicit authenticated-user preference;
2. explicit current-session preference;
3. tenant/application default;
4. validated browser `Accept-Language` preference;
5. system fallback locale.

An explicit user choice must not be silently overridden by browser negotiation on later requests.

---

## 18. Default/fallback locale

Every application MUST define one explicit fallback locale.

Thermacube applications should normally use a specific locale such as `en-US`, not a vague implicit “English” default.

Fallback behavior must be deterministic.

Missing translations must not cause undefined UI state.

---

## 19. Locale persistence

Authenticated-user locale preference SHOULD persist with the user profile when product requirements support preference storage.

Session-only locale selection may be used for anonymous or transient contexts.

Locale persistence must not depend solely on client-side JavaScript state.

---

## 20. Language switcher

When an application supports multiple user-selectable UI languages, the language control belongs in the shared global utility area defined by the IA/layout specification.

The control should remain available from ordinary authenticated pages.

Do not hide language selection only in a footer when switching language is a normal user need.

---

## 21. Language names

Language selectors SHOULD present each language using its own name and script.

Examples:

```text
English
Español
Français
العربية
```

Do not require users to understand English to identify another language.

---

## 22. Language switching behavior

Switching UI language SHOULD preserve the user's logical location and authorized application state where practical.

Changing language should not unnecessarily return the user to the product homepage.

State-changing operations must not be repeated as a side effect of switching locale.

---

## 23. URL strategy

Each application family must choose a consistent canonical locale strategy.

Acceptable approaches include:

### URL-scoped locale

```text
/en-US/reports/registry
/es-US/reports/registry
```

### User/session locale

```text
/reports/registry
```

with locale resolved from user/session context.

A mixed strategy must be explicitly documented.

Applications SHOULD avoid adding arbitrary locale query parameters to every URL unless the URL architecture intentionally uses them.

---

## 24. HTMX locale consistency

Full-page rendering and HTMX fragment rendering MUST resolve the same locale context.

A fragment request must not accidentally fall back to another language because it bypasses the full document renderer.

HTMX fragment endpoints and canonical full-page routes must share the same:

- locale resolution;
- message catalog;
- number/date formatting;
- direction context;
- authorization.

---

## 25. HTMX history and locale

When HTMX pushes a URL into browser history, that URL must resolve to the same logical locale when loaded directly.

If locale is URL-scoped, the pushed URL must include the locale scope.

If locale is user/session-scoped, a direct request uses the persisted/session locale according to the application's documented model.

---

## 26. HTMX swap direction

Returned HTML fragments do not independently redefine the page's base direction unless the fragment semantically contains a different-language/direction region.

If a locale switch changes the document-wide base direction, the application SHOULD perform a full-document navigation or another mechanism that correctly updates:

- `html lang`;
- `html dir`;
- document title;
- global landmarks;
- all visible strings.

Do not partially swap an RTL interface into an LTR document shell.

---

## 27. Message catalogs

User-interface strings must be externalized from application logic through a message-catalog abstraction.

The minimum conceptual API is:

```text
translate(message_id, values, locale)
```

or equivalent.

The implementation may remain small and Thermacube-owned.

A large third-party localization runtime is not required merely to satisfy this specification.

---

## 28. Stable message identifiers

Message IDs should represent stable semantic purpose rather than English text.

Prefer:

```text
registry.pending.title
common.save
common.cancel
comms.messages.unread
```

Avoid using complete English source strings as long-term program identifiers when doing so makes refactoring or catalog management fragile.

---

## 29. Message ownership

Shared TMUI strings MAY live in a shared TMUI/common catalog.

Application/domain-specific strings belong to the application that owns the concept.

Modules should not duplicate translations for the same shared interface concept when a common message exists.

---

## 30. Do not concatenate translated sentence fragments

Applications MUST NOT construct natural-language sentences by concatenating separately translated grammatical fragments.

Avoid:

```text
"Showing" + start + "to" + end + "of" + total
```

Prefer a complete translatable message:

```text
results.range = "Showing {start}–{end} of {total}"
```

Translators must be able to reorder placeholders.

---

## 31. Named placeholders

Dynamic messages SHOULD use named placeholders rather than positional placeholders.

Prefer:

```text
{learner}
{count}
{date}
```

over:

```text
{0}
{1}
{2}
```

when the message system supports names.

Names improve translation clarity and reduce errors when word order changes.

---

## 32. Structured message semantics

Thermacube message formatting should be compatible in concept with Unicode MessageFormat/CLDR patterns:

- named variables;
- plural selection;
- number/date formatting;
- safe markup when genuinely required.

A minimal Thermacube implementation MAY implement only the subset actually needed, but must not encode English-only grammar rules into application code.

---

## 33. Pluralization

Plural logic MUST be locale-aware.

Do not use:

```php
$count === 1 ? 'record' : 'records'
```

as a general localization model.

Languages may have plural categories such as:

- zero;
- one;
- two;
- few;
- many;
- other.

Thermacube implementations should use CLDR-compatible plural semantics.

---

## 34. Ordinals

Ordinal formatting must also be locale-aware when used.

Do not construct English suffixes such as `st`, `nd`, `rd`, and `th` in generic application code.

---

## 35. Number formatting

Numbers displayed to users should be formatted according to locale where the number is prose/presentation.

Examples may differ in:

- decimal separator;
- grouping separator;
- digit grouping;
- numbering system.

Machine-facing values and protocol values remain locale-neutral according to their protocol.

---

## 36. Currency

Money is stored and processed as:

- numeric amount in an application-approved exact representation;
- explicit ISO currency code.

Localized display is presentation.

Do not infer currency solely from UI language.

A Spanish UI in the United States may still correctly display USD.

---

## 37. Dates and times

Application storage and domain logic use canonical date/time representations.

Localized presentation is separate.

User-visible date/time rendering should respect:

- locale;
- timezone;
- explicit application context.

Do not parse ambiguous human-entered dates using one assumed national format without validation.

---

## 38. Timezones

Timezone is distinct from locale.

Applications dealing with absolute timestamps must preserve timezone/offset semantics.

When a user's timezone matters, it should be explicit or resolved through an approved user/tenant preference.

Do not infer timezone solely from language or locale.

---

## 39. Relative time

Relative phrases such as:

```text
3 hours ago
in 2 days
```

must be produced through locale-aware message/format rules.

Do not concatenate an English unit name around a number.

---

## 40. Lists

Human-readable lists should support locale-appropriate separators/conjunctions when practical.

Example English:

```text
Messages, Chat, and Voice
```

Other languages may use different punctuation/conjunction patterns.

---

## 41. Names

Forms and data models MUST NOT assume one universal human-name structure.

Avoid requiring conceptual assumptions such as:

- exactly first + middle + last;
- family name always last;
- one-word names impossible.

Where a legal/external system contract requires specific fields, label them according to that contract rather than presenting them as universal human-name rules.

---

## 42. Addresses

Address forms and validation should not assume one country's format unless the workflow is explicitly country-specific.

If an application only serves a specific jurisdiction, that constraint may be documented and enforced.

Reusable TMUI form components remain locale-neutral.

---

## 43. Telephone numbers

Telephone number storage/validation should preserve international capability where practical.

Display formatting may be locale/context aware.

Do not assume that localized UI language determines telephone numbering country.

---

## 44. Input vs display formatting

User input may accept locale-familiar forms, but domain persistence should normalize to canonical values.

For example:

```text
input: 1.234,50
domain amount: 1234.50
currency: EUR
```

Validation errors must explain the expected input clearly in the user's language.

---

## 45. Sorting and collation

User-facing alphabetical sorting must not assume byte order or ASCII ordering.

Where linguistic collation matters, use locale-aware collation.

Technical identifiers, IDs, hashes, version strings, or explicitly protocol-defined fields may require locale-neutral sorting instead.

---

## 46. String comparison and normalization

Unicode strings may have multiple equivalent code-point sequences.

Systems performing identity/matching on user text should account for Unicode normalization where appropriate.

Do not normalize opaque identifiers, passwords, signatures, hashes, or other values whose exact code-point sequence is semantically significant unless their protocol specifies normalization.

---

## 47. Search

Search must be Unicode-safe.

Search implementations should not assume:

- ASCII input;
- English case rules;
- English stemming;
- space-separated words for all scripts.

Language-aware tokenization/stemming may be introduced when a search subsystem requires it.

The original user query text should be preserved for display/audit where appropriate.

---

## 48. Case conversion

Do not assume ASCII/English upper/lowercase behavior.

Locale-sensitive case transformations must use appropriate Unicode/locale-aware functions when the transformation is linguistically meaningful.

Technical identifiers should normally avoid locale-sensitive case transformation.

---

## 49. UI string translation scope

When the UI is localized, all user-facing application chrome must be included.

Examples:

- page titles;
- navigation;
- button text;
- labels;
- hints;
- validation errors;
- status messages;
- empty states;
- dialogs;
- account controls;
- search labels;
- pagination;
- footer text.

---

## 50. Accessibility metadata localization

Visible translation without accessibility translation is non-conforming.

Localization must include user-facing accessibility metadata such as:

- accessible names;
- `aria-label` text;
- `aria-description` / descriptions where used;
- visually hidden text;
- error text;
- status/live-region text;
- iframe titles;
- image alternative text where the image's meaning is localized;
- document `title`.

---

## 51. Accessible language switching

The language selector must:

- be keyboard accessible;
- have an accessible name;
- expose its current selection;
- present target languages in recognizable native names/scripts;
- not rely on flags as the sole representation of language.

Flags identify countries, not languages, and must not be used as the only language-selection cue.

---

## 52. Translation and user-generated content

Localization of application chrome does not imply translation of authored or user-generated content.

Examples that remain in their authored language unless an explicit translation feature exists:

- chat messages;
- support tickets;
- notes;
- course content;
- uploaded documents;
- learner responses.

The application must not misrepresent untranslated content as localized.

---

## 53. Content language metadata

Where authored/user content language is known and useful, systems SHOULD preserve it as metadata.

Comms messages, learning content, and published documents may benefit from explicit language metadata.

The value should use BCP 47 where practical.

---

## 54. Machine translation

Machine translation is a separate application capability.

If added, the product must distinguish:

- original content;
- machine-translated content;
- human-reviewed translation.

Machine translation must not silently overwrite authoritative source content.

---

## 55. Images and text

Do not embed translatable UI text inside images.

If an image contains essential textual content that cannot be avoided, localized alternatives must be provided where required.

Prefer text rendered as actual HTML/SVG text over rasterized labels.

---

## 56. Icons and cultural assumptions

Icons must be reviewed for cross-cultural meaning.

Text labels are preferred when icon meaning is not universally conventional.

Direction-dependent icons should mirror when their semantic meaning follows reading/navigation direction.

---

## 57. Fonts

TMUI's default system-font strategy is preferred for multilingual support.

Applications MUST NOT require a remote webfont to render localized UI.

If a product intentionally vendors a custom font, it must verify:

- required script coverage;
- readable glyph design;
- fallback behavior;
- licensing;
- performance impact.

---

## 58. Line height and glyph metrics

Components must tolerate scripts with taller glyphs/diacritics than Latin text.

Avoid fixed control heights that clip text at increased line-height or zoom.

TMUI control sizing must satisfy accessibility target size while allowing text metrics to grow.

---

## 59. Text expansion

TMUI and application layouts MUST tolerate translated text expansion.

Reference testing should include approximately 30–50% expansion of typical English UI strings.

No essential label may:

- clip;
- overlap;
- disappear;
- become inaccessible;
- force unusable horizontal scrolling

solely because the localized string is longer.

---

## 60. Fixed widths

Avoid fixed text-container widths when content length is language-dependent.

Use:

- intrinsic sizing;
- flex/grid;
- min/max constraints;
- wrapping.

Icon-only controls may use fixed dimensions when their accessible name is not rendered visually.

---

## 61. Truncation

Do not truncate essential labels, errors, form instructions, or action names merely to preserve an English-designed layout.

Ellipsis may be used for secondary/user-generated content when:

- the complete value remains available;
- the truncation does not obscure the meaning required to complete the task.

---

## 62. Responsive + RTL behavior

Responsive rules must work in both LTR and RTL.

Do not implement a mobile layout that depends on physical left/right ordering that differs from DOM/focus order.

The accessibility rule that meaningful reading and focus order match presentation remains in force.

---

## 63. Tables

Table semantics do not change by locale.

Direction-aware alignment may change where appropriate.

Numeric data may use locale-formatted display while underlying sort/filter values remain canonical.

Column labels must be translated.

Horizontal overflow behavior must remain usable in both directions.

---

## 64. Forms

Form labels, hints, placeholders, validation text, legends, and button labels must be localized.

Placeholder text must not become a substitute for persistent labels.

Input direction may differ from document direction for certain fields.

Examples:

- email;
- URL;
- code;
- phone;
- technical identifiers.

Use field-level direction/isolation only where appropriate.

---

## 65. Comms integration

The collapsed Messages / Chat / Voice launcher must be localized, including accessible names and unread/missed-call state.

Example conceptual messages:

```text
comms.messages
comms.messages.unread(count)
comms.chat
comms.chat.unread(count)
comms.voice
comms.voice.missed(count)
```

The expanded Comms surface inherits the user's UI locale but must preserve the authored language of communications.

---

## 66. Atria learning content

Atria application chrome follows the selected UI locale.

Learning objects/course content remain governed by their authored/localized-content metadata.

A course may contain content in a language different from the Atria shell.

That language difference should be marked where required for accessibility.

---

## 67. Bridge operational data

Bridge labels, workflow text, status explanations, report headings, filters, and validation messages are localizable.

External registry/provider field names that are contractual may remain fixed or be paired with localized explanations as appropriate.

Exports must follow the export contract; user-interface locale must not silently change machine-facing CSV schemas unless the export specification explicitly defines localized output.

---

## 68. PWA and offline behavior

Localized catalogs required for offline/PWA operation must be packaged locally with the application.

A localized offline shell must not depend on an external translation CDN.

Cache/version behavior must prevent mixed catalog/application versions from creating broken message IDs.

---

## 69. Emails and notifications

Application-generated email/SMS/push content should resolve the recipient's locale independently of the current browser session where possible.

Templates must use the same message-formatting principles:

- complete messages;
- locale-aware pluralization;
- locale-aware dates/numbers;
- correct language metadata where the medium supports it.

---

## 70. Logging and diagnostics

Developer logs may use a canonical operational language for maintainability.

User-facing error messages are localized separately.

Logs should record stable message/error identifiers so support can diagnose an issue regardless of UI language.

Do not use localized message text as the sole machine-readable error identity.

---

## 71. Error codes

Domain/application errors should have stable language-neutral identifiers.

Example:

```text
registry.invalid_completion_date
```

The UI maps the identifier plus structured values to a localized message.

This prevents business logic from returning English prose as its contract.

---

## 72. Localization files and dependencies

Production translation catalogs must be:

- locally stored;
- versioned;
- deployable with the application;
- reviewable;
- deterministic.

A third-party translation-management service MAY be used during authoring/workflow, but production rendering must not require that service to be online.

---

## 73. Runtime dependency policy

Internationalization must follow Thermacube's general dependency philosophy.

If an open-source i18n library is used:

- pin/vendor it;
- fork it; or
- implement the required subset internally based on standard semantics.

No production UI should break because a remote localization runtime, catalog CDN, or font service is unavailable.

---

## 74. Server-first formatting

Thermacube's default architecture is server-rendered.

Locale-sensitive formatting SHOULD happen server-side when the server already renders the HTML.

Browser `Intl` APIs may be used for genuinely browser-local dynamic behavior, but must not create inconsistent formatting between full-page and HTMX-rendered content.

---

## 75. Client-side Intl

When JavaScript is required, use standards-based locale APIs such as ECMAScript `Intl` rather than hand-written locale rules.

Possible uses include:

- `Intl.NumberFormat`;
- `Intl.DateTimeFormat`;
- `Intl.PluralRules`;
- `Intl.ListFormat`;
- `Intl.RelativeTimeFormat`;
- `Intl.Locale`.

The client-side locale must match the authoritative application locale.

---

## 76. Message safety and markup

Translated messages should be plain text by default.

When rich markup is required:

- translators must not inject arbitrary executable markup;
- values must remain contextually escaped;
- markup placeholders must map to an approved safe set;
- HTML generation remains under application control.

Localization must not bypass output-encoding/security rules.

---

## 77. Translation workflow

Translation resources should support:

- stable message IDs;
- source text;
- description/context;
- placeholders and their meaning;
- plural variants;
- review status;
- locale;
- version.

Developer comments/context should be available for ambiguous short labels.

---

## 78. Source-string quality

Source-language messages should be:

- concise;
- grammatically complete;
- contextually clear;
- free from unnecessary idioms;
- free from concatenated fragments;
- explicit about placeholders.

Poor source strings create poor translations.

---

## 79. Punctuation

Do not hard-code punctuation outside translated messages when punctuation participates in sentence grammar.

Technical separators that are structural rather than linguistic may remain outside the message.

---

## 80. Capitalization

Do not assume English title-case rules apply across locales.

Message catalogs own localized capitalization.

CSS text-transform SHOULD NOT be used to force uppercase/title case on translated prose/navigation unless the visual convention is known to be appropriate across supported scripts.

---

## 81. Keyboard shortcuts

Visible letter-based access keys or shortcuts must not assume one English mnemonic across all locales.

Global shortcuts based on physical/non-language keys may be shared if accessible and non-conflicting.

Any user-facing shortcut label must be localized as needed.

---

## 82. Testing locales

TMUI and applications SHOULD maintain at least these test classes:

1. baseline LTR locale;
2. expanded pseudo-locale;
3. RTL locale;
4. locale with differing number/date conventions.

Production support for a language is not implied merely because it is used as a test fixture.

---

## 83. Pseudo-localization

A pseudo-locale SHOULD:

- expand visible text;
- preserve placeholders;
- make untranslated source strings obvious;
- exercise Unicode glyph handling.

Pseudo-localization is a development/test mechanism and is not exposed as a normal production language.

---

## 84. RTL reference testing

TMUI must maintain an RTL reference fixture.

The fixture should verify:

- `html dir="rtl"`;
- brand/global utilities swap logical sides;
- contextual sidecar moves to inline end;
- breadcrumbs/navigation remain coherent;
- icons with directional meaning mirror when required;
- tables/forms remain usable;
- focus order follows DOM/logical task order.

---

## 85. Accessibility testing

Internationalization testing must include accessibility concerns.

For each production-supported locale, representative testing should confirm:

- correct page `lang`;
- correct language of parts;
- correct direction;
- accessible names translated;
- screen-reader pronunciation reasonably follows declared language;
- no keyboard regressions caused by mirrored layout;
- text expansion remains usable;
- zoom/reflow still works;
- status/error announcements are localized.

---

## 86. Automated conformance checks

Where practical, CI SHOULD detect:

- missing `lang` in canonical documents;
- RTL fixtures lacking `dir="rtl"`;
- physical left/right CSS in reusable TMUI styles where logical properties are expected;
- hard-coded translatable strings in designated localized templates;
- missing catalog keys;
- placeholder mismatch between source and translations;
- untranslated accessibility labels;
- invalid BCP 47 supported-locale identifiers.

Automated checks do not prove translation quality.

---

## 87. Translation quality

Machine-valid catalogs can still contain poor translations.

Production language support requires human review appropriate to the product risk and audience.

For safety-, legal-, financial-, or accessibility-critical text, review requirements may be higher.

---

## 88. Fallback behavior

Missing translation behavior must be deterministic.

Recommended order:

1. exact locale;
2. supported parent/fallback locale according to application policy;
3. system fallback/source locale;
4. visibly logged missing-message error in development.

Production UIs must not expose raw message IDs as a normal fallback.

---

## 89. Catalog version compatibility

Application code and translation catalogs must be version-compatible.

Deployments must not serve catalogs that are missing required keys for the deployed code version.

Atomic deployment or versioned catalog loading is preferred.

---

## 90. Caching

Localized HTML and fragments must be cached with locale as part of the cache key when a shared cache is used.

Do not serve cached content in the wrong language.

The same applies to:

- rendered fragments;
- generated navigation;
- emails queued from templates;
- localized API-facing presentation where applicable.

---

## 91. Authorization and locale

Locale must never affect authorization.

Changing locale cannot:

- reveal inaccessible navigation;
- alter permissions;
- select a less-protected route;
- bypass request-perimeter rules.

Authorization is evaluated independently of localization.

---

## 92. Security

Locale/message IDs are structured input and must be validated.

Translation values remain untrusted for output-context purposes unless explicitly trusted and controlled.

Do not use locale selection to construct arbitrary filesystem paths.

---

## 93. Domain separation

Domain models should store semantic values, not localized presentation strings.

Prefer:

```text
status = pending
```

then localize at presentation time.

Avoid storing:

```text
status = "Pending"
```

as the authoritative domain value.

---

## 94. Audit history

Audit/history events SHOULD store:

- stable event type;
- structured values;
- canonical timestamps;
- actor identifiers.

Localized prose should be rendered at view time when practical.

If immutable prose snapshots are legally/business required, store them separately from structured event identity.

---

## 95. Exports and integrations

External machine contracts remain language-neutral unless the contract explicitly specifies localization.

Do not localize:

- field names;
- enum values;
- API keys;
- machine identifiers

merely because the user's UI locale changed.

Human-facing exports MAY provide localized headings only when the export contract explicitly allows it.

---

## 96. Documentation

Each application adopting this specification must document:

- supported production locales;
- fallback locale;
- locale selection/persistence model;
- URL strategy;
- timezone policy if relevant;
- translation catalog location;
- translation review workflow;
- application-specific exceptions.

---

## 97. TMUI conformance

TMUI MUST conform to this specification.

TMUI reference implementation must provide evidence for:

- logical CSS properties;
- LTR and RTL shell behavior;
- text expansion;
- translated accessible names;
- flexible controls/layout;
- language/direction attributes in fixtures;
- no remote font/i18n dependency;
- localized Comms launcher examples.

---

## 98. Interaction with Accessibility Specification

The Accessibility Specification remains higher precedence where requirements overlap.

Internationalization specifically supports accessibility through:

- correct language metadata;
- language-of-parts marking;
- direction semantics;
- localized accessible names;
- readable layout under text expansion;
- screen-reader pronunciation context.

A translated visual interface with untranslated accessibility metadata is non-conforming.

---

## 99. Interaction with HTMX Specification

The HTMX Integration Specification remains authoritative for hypermedia interaction.

Internationalization adds:

- consistent locale resolution for pages/fragments;
- locale-safe history URLs;
- localized status/errors;
- direction-safe swaps;
- full-document handling when base language/direction changes;
- locale-aware cache keys.

---

## 100. Interaction with IA/Layout Specification

The IA/layout hierarchy remains unchanged across languages.

Physical placement follows logical writing direction.

Terms such as “upper left/right” in informal diagrams are interpreted normatively as inline-start/inline-end according to this specification.

Navigation labels must preserve high information scent in each localized language; literal translation that creates ambiguity is insufficient.

---

## 101. Interaction with TMUI Design Language

TMUI visual tokens and components remain shared across locales.

Localization may alter:

- text;
- direction;
- intrinsic component width;
- line wrapping;
- typographic fallback.

Localization must not create a parallel component system.

---

## 102. Conformance

An application conforms to Thermacube Application Internationalization & Localization Specification v1.0 when:

1. Unicode/UTF-8 is used end to end;
2. supported locales use valid BCP 47 tags;
3. full documents declare language and direction correctly;
4. layout is direction-neutral and RTL-capable;
5. locale selection is explicit, validated, and persistent according to policy;
6. user-facing UI strings are externalized;
7. dynamic messages do not rely on English sentence concatenation;
8. plurals/numbers/dates/currency are locale-aware where applicable;
9. accessibility metadata is localized;
10. HTMX fragments share authoritative locale context;
11. canonical URLs/history preserve locale semantics;
12. production localization assets are local/versioned;
13. layout tolerates text expansion;
14. domain values remain language-neutral;
15. automated and manual localization/accessibility testing is performed appropriate to supported locales.

---

## 103. References

- W3C Internationalization Quick Tips — https://www.w3.org/International/quicktips/
- W3C Internationalization resources — https://www.w3.org/International/
- W3C Strings on the Web: Language and Direction Metadata — https://www.w3.org/TR/string-meta/
- W3C CSS Logical Properties and Values — https://www.w3.org/TR/css-logical-1/
- WCAG 2.2 Understanding Language of Page — https://www.w3.org/WAI/WCAG22/Understanding/language-of-page
- WCAG 2.2 Understanding Language of Parts — https://www.w3.org/WAI/WCAG22/Understanding/language-of-parts
- IETF BCP 47 / RFC 5646 — https://www.rfc-editor.org/rfc/rfc5646
- IETF BCP 47 / RFC 4647 — https://www.rfc-editor.org/rfc/rfc4647
- Unicode Standard — https://www.unicode.org/standard/standard.html
- Unicode CLDR — https://cldr.unicode.org/
- Unicode CLDR Plural Rules — https://cldr.unicode.org/index/cldr-spec/plural-rules
- Unicode MessageFormat 2 — https://messageformat.unicode.org/
- ECMAScript Internationalization API / Intl — https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Internationalization

These sources define the external standards and best-practice basis. This document defines the Thermacube implementation contract.
