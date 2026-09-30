# Atria RoadRunner and Spiral Dependency Exception v1.0

**Status:** Atria-specific implementation policy  
**Date:** September 30, 2026  
**Companion standards:** [Thermacube PHP Coding Standard v1.1](Thermacube_PHP_Coding_Standard_1.1.md) and [Thermacube Go Coding Standard v1.1](Thermacube_Go_Coding_Standard_1.1.md)

## Purpose

Atria remains bound by reductive design, procedural/functional **application/domain** code, narrow adapter boundaries, explicit state/resource ownership and a preference for few maintained dependencies. Atria already deliberately uses RoadRunner, an externally maintained component in the broader Spiral ecosystem. This established relationship permits **selective reuse of reviewed Spiral components** when they satisfy an actual requirement more simply than a locally maintained implementation.

## Decision rule

Atria may use a specific Spiral component when all of the following are true:

1. It solves an identified existing problem and is compatible with the governing Atria architectural and domain contracts; do not adopt a framework or module merely because it is available.
2. A concise comparison against PHP/Go standard libraries, current project code and a narrow locally maintained solution demonstrates lower **total** code complexity, operational complexity or maintenance risk.
3. It can be kept behind a documented, replaceable framework/runtime adapter. Core business/domain functions should remain directly callable and understandable without inheriting the component's object model or service container.
4. Its source/release is pinned and reviewed; licenses, upstream and transitive dependency risks, deployment behavior, update/testing policy, monitoring responsibility and a credible replacement/exit path are documented.
5. Representative tests cover expected behavior, edge/error paths and relevant long-lived-worker isolation. A component must not silently change application authority, persistence or public contracts.

Sharing an upstream organization/team with RoadRunner can reduce ecosystem proliferation and duplicated maintenance work, but also **concentrates** vendor/supply-chain and maintainer availability risk. It is not a blanket dependency waiver and does not imply that every Spiral component belongs in Atria.

Project-specific Atria requirements decide which components are approved; neither Bridge, Comms, Varr, TVS nor other repositories inherit the exception. Where an older architectural narrative favors broad dependency injection/framework ownership, interpret it through this narrower, later implementation policy and the applicable PHP/Go v1.1 standards.

## Source documentation and defensive coding

Adopt the applicable standard's source-embedded ownership/function documentation, Function/Service Reference, and OWASP-derived defensive programming at each trust/mutation boundary. Existing Atria request-perimeter, mutation-integrity, accessibility, HTMX and other governing project specifications remain independently enforceable. This policy is not permission to build a new embedded WAF or bypass an existing security perimeter.
