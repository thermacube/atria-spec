# Atria Application Accessibility Adoption

**Adopted standard:** Thermacube Application Accessibility Specification v1.0  
**Canonical specification:** `thermacube/atria-spec/engineering/Application_Accessibility_Spec_1.0.md`

## 1. Scope

Atria adopts the shared accessibility specification at the platform level.

The Atria shell and all Atria-hosted module surfaces must satisfy WCAG 2.2 Level AA within the claimed product scope. Module boundaries do not create accessibility exemptions.

## 2. Platform responsibility

The Atria platform owns shared accessibility behavior for:

- global navigation and landmarks;
- page/view titles and heading structure;
- shared focus styling;
- responsive/reflow conventions;
- common form controls and validation presentation;
- dialogs/drawers/sheets provided by the shell;
- HTMX transition/focus conventions;
- common status and error announcement behavior;
- embedded-module launch and return behavior.

Modules own the accessibility of module-specific controls and content while conforming to the shared platform conventions.

## 3. HTMX and module transitions

HTMX partial updates and module transitions must preserve logical focus and task context.

A module transition must not silently discard keyboard focus, reset assistive-technology context unnecessarily, or require a full page reload merely to achieve accessible behavior.

## 4. Arbitis and authorization

Accessibility does not alter Arbitis authority.

Controls hidden or disabled because of authorization must still produce a coherent accessible interface. Authorization failures must be communicated accessibly and must not rely only on visual styling.

## 5. Tenancy

Tenant resolution and accessibility are separate concerns.

Tenant-specific branding, color, content, or configuration must not reduce the WCAG 2.2 Level AA baseline.

## 6. Module-specific examples

- **Arkiv/H5P:** authored/rendered learning content, media, navigation, and interactive activities must preserve accessibility semantics.
- **Ordin:** workflow visualization and execution controls require keyboard-accessible alternatives and programmatically determinable state.
- **Quorum:** chat/prompt/result/status surfaces require accessible names, focus, live-update discipline, and keyboard operation.
- **Arbitis administration:** rights/policy administration interfaces must expose state and relationships without relying only on visual structure.

## 7. Testing

Atria conformance testing must include representative workflows across:

- authentication and shell navigation;
- learner-facing content;
- staff/admin workflows;
- dynamic HTMX updates;
- module transitions;
- forms and validation;
- dense tables or grids;
- dialogs/drawers;
- responsive/mobile presentation.

Formal product-level evaluation follows WCAG-EM 2.0.

