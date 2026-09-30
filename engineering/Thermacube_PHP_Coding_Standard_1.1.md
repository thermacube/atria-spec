# Thermacube PHP Coding Standard v1.1

**Revision:** 1.1 (2026-09-30) — adds common documentation/maintainability gates, qualified Atria exception, language-scoped configuration and OWASP-derived defensive programming  
**Status:** Governing engineering standard  
**Scope:** New and materially modified PHP code in Thermacube applications, modules, adapters, telemetry services, and deployment tools  
**Authority:** `thermacube/atria-spec`, `engineering/Thermacube_PHP_Coding_Standard_1.1.md`  
**Companion:** `Thermacube_Go_Coding_Standard_1.1.md`

## 1. Governing principle

Use **reductive design, procedural/functional programming, and excellent embedded plain-English documentation**. Build the smallest correct, secure, understandable solution with the least *necessary* code, processor work, memory use, dependencies, and maintenance burden.

Decision order:

1. Correctness, security, data integrity, application behavior, and specified invariants.
2. Directness and comprehensibility of execution.
3. Low code/dependency footprint and efficient CPU, memory, and I/O.
4. Measured optimization only when its value justifies added complexity.

Fewest lines is a **readability-constrained** goal. Do not use compressed syntax, omit validation, sacrifice explicit error paths, or produce code that only its original author can understand.

The project-specific security, procedural PHP, configuration, database, accessibility, HTMX, upgrade, and API specifications remain authoritative where they add stronger or narrower requirements. Adopt this standard incrementally when changing existing code; avoid large cosmetic refactors.

## 2. Reductive architecture

- Prefer the majestic-monolith/module model already chosen for each project. Avoid unnecessary microservices, routing frameworks, service containers, plugin frameworks, ORMs, and architectural scaffolding.
- Implement only required behavior. Do not create unused modules, generic factories, interfaces, repositories, or speculative extension points.
- Favor direct procedural include/function flows over chains of classes and hidden dispatch.
- Use cohesive, responsibility-named PHP include files. Split a growing implementation only when the split materially improves comprehension, reuse, tests, or operational isolation.
- Reuse standard PHP functionality; avoid runtime composer or other third-party dependencies when a small, reliable local implementation or standard library is sufficient.
- Keep application boundaries narrow, explicit, and request-local.
- Remove redundant execution paths safely, without breaking compatibility or silently changing existing contracts.

### 2.1 External dependencies, ownership, and forks

**Dependency avoidance is the default.** Thermacube prefers functionality it owns and can maintain over a runtime, release, or security posture that depends on the continued existence, release schedule, compatibility, packaging service, or goodwill of an outside project.

Apply this decision order before adding third-party code:

1. **Avoid the dependency** if standard-library or already-maintained project code solves the actual requirement simply and safely.
2. **Keep a narrow locally maintained implementation** when the need is small, well understood, and lower risk than adopting a whole package.
3. **Prefer a reviewed, license-compliant fork or vendored source maintained as part of the Thermacube codebase** when substantial open-source functionality is genuinely necessary. Build, test, audit, and release it under our control rather than silently following an upstream moving target.
4. **Permit an externally managed dependency only as a documented exception** when owning it would be impractical, legally incompatible, materially riskier, or more costly than depending on its maintained upstream. Explain the tradeoff and specify the containment and exit plan.

Forking does **not** eliminate maintenance or security work; it transfers responsibility to us. Every adopted fork or vendored component must have a named owning repository, preserved provenance, reviewed license and notice requirements, a pinned upstream version/commit, local build and test coverage, vulnerability monitoring, and an explicit process for reviewing and importing upstream security and compatibility fixes. Do not fork merely to rename a dependency while continuing to rely on upstream unreviewed binaries or automatic updates.

Treat transitive dependencies and build-time tools as dependencies too. Avoid uncontrolled network downloads during production build, install, update, or normal execution where practicable. Pin approved sources and maintain reproducible, auditable builds.

Document the rationale whenever choosing outside code: required capability, alternatives considered, license, maintenance owner, supply-chain exposure, update policy, and what happens if the upstream project disappears. Do not reimplement mature security-sensitive primitives or protocols without sufficient expertise and a stronger reviewed alternative; security and correctness still outrank independence.

### 2.2 Efficient runtime behavior

- Favor bounded, incremental processing over loading whole input files/result sets when not needed.
- Avoid unnecessary repeated parsing, SQL queries, network requests, serialization, and copying.
- Use parameterized queries and efficient filters; avoid `SELECT *`, unbounded queries, and N+1 behavior on significant paths.
- Close/release resources and avoid retaining large intermediate arrays after use.
- Keep state and caches bounded. Never introduce a poller, background worker, or cache merely because it might help.
- Measure consequential CPU/memory/latency claims before adopting a less-readable optimization.
- Preserve long-lived-worker safety where a project runs PHP in a persistent worker (e.g. RoadRunner): no unexpected cross-request identity/configuration or mutable global state.

**Resource budgets:** Document concrete CPU, memory, request, or query targets when material to a workflow and test/profile against them where practical.

### 2.3 Atria's qualified RoadRunner/Spiral exception

Atria has an explicit project-specific exception to the normal preference against externally maintained frameworks. Its existing RoadRunner dependency and the related Spiral ecosystem provide a practical reason to evaluate *selected* Spiral components before writing replacement infrastructure: those components may already solve a real problem within an established upstream maintenance relationship. Atria may adopt an individual Spiral component only where its demonstrated value reduces total code, maintenance, and operational complexity and where its use can remain consistent with reductive design, procedural/functional **application and domain** code, narrow replaceable framework adapters, explicit resource boundaries, and testability.

This exception is **not** a blanket authorization for a Spiral-first architecture, extra OOP layers, speculative dependencies, or unreviewed upgrades. Record each selected component, the requirement it solves, the alternative of using existing code or standard PHP, the relevant upstream and transitive dependency risks, the boundary containing it, and the replacement/exit path. A shared upstream team is a shared failure domain, not elimination of dependency risk; continue to pin, review, test, and monitor both RoadRunner and any adopted Spiral components. Atria's project specifications govern approved component choices. Other projects do not inherit this exception.

## 3. Procedural and functional style

Procedural PHP is the default. Prefer named functions, arrays for simple records, explicit parameters and return values, and predictable request execution.

- Prefer pure functions for validation, formatting, projection, calculations, and data transformations.
- Keep I/O and mutations at explicit function boundaries. Use descriptive names for operations that write records, send messages, or change external systems.
- Pass database connections, configuration, authenticated context, and dependencies explicitly instead of using mutable globals or hidden singletons.
- Use closures/callable parameters for a small genuine integration boundary when appropriate; do not build an elaborate dependency-injection layer.
- Use classes only when an external contract/framework demands them or a specific language capability makes them demonstrably simpler. Keep unavoidable class adapters thin. Avoid inheritance hierarchies, per-domain service/repository classes, traits-as-frameworks, and object graphs used only to imitate enterprise architecture.
- Respect the existing project's database interface (procedural `mysqli_*` for projects that require it; PDO where that is already the governed Bridge boundary). Do not perform database rewrites as a by-product of this coding standard.
- Prefer standard PHP control flow over clever chained functional operators that conceal order, errors, or side effects.

A small function should need no object or container:

```php
<?php
declare(strict_types=1);

/**
 * Return the total number of bytes in the supplied strings.
 *
 * Pure transformation: no I/O or mutation of the source array.
 */
function thermacube_total_bytes(array $chunks): int
{
    $total = 0;

    foreach ($chunks as $chunk) {
        $total += strlen($chunk);
    }

    return $total;
}
```

Do not introduce classes, methods, or interfaces merely to wrap this logic.

## 4. Explicit configuration and resource boundaries

- **All PHP application configuration must be PHP-file-based.** Load explicit, deployment-owned PHP configuration that returns an array. This applies to PHP applications even when hosted by WordPress or RoadRunner. Secrets belong in protected deployment configuration, not Git, browsers, log output, `.env` files, or process environment variables.
- PHP application configuration **may be located inside the filesystem web root** when the deployment requires it, but it must be outside publicly retrievable paths or covered by explicit, verified web-server denial rules, with restricted filesystem permissions. Never treat an untested dotfile convention or PHP execution alone as sufficient protection. Prefer a path outside public document access when deployment permits it.
- This PHP-file rule applies **only to PHP applications and PHP-owned configuration**. Go daemons, Python tools, and other independently operated programs use their own explicitly specified native filesystem configuration, ordinarily outside the web root; do not invoke PHP to parse another language's daemon configuration.
- Distinguish language-level configuration policy from program-specific configuration ownership: a PHP host adapter may have its own PHP bootstrap settings, but another daemon's credentials and runtime settings belong to that daemon's protected configuration file.
- Use an allowlisted, documented project configuration shape. Keep default values explicit and validate security-sensitive settings. Configuration changes must not silently overwrite deployment-owned settings during upgrades.
- Distinguish configuration from request data and application-managed database settings. Browser data never becomes configuration or authority.
- Initialize and dispose of database/network resources at recognizable boundaries. Avoid implicit connections and stateful global caches across worker requests.
- Use timeouts, explicit retry behavior, idempotency, and transaction boundaries for consequential external operations.

A project-specific governed integration may require WordPress or other host adapters. Keep that adapter at the boundary, with the procedural application core independent of host/framework details.

## 5. Error handling and security

- Validate untrusted input at the request boundary and again where domain invariants demand it; return predictable domain/error outcomes.
- Use strict types where compatible with the project and declare meaningful parameter/return types. Do not trade compatibility or clear behavior for gratuitous type complexity.
- Escape output at its destination, use prepared SQL statements, and preserve least privilege, authorization, replay prevention, and transactional/idempotency guarantees specified for each operation.
- Never treat client-side state, a browser token, or a UI control as authority for data changes.
- Preserve the application's security/request perimeter, HTMX progressive behavior, accessibility, and internationalization requirements when modifying UI code.
- Log actionable bounded failure metadata without exposing credentials, raw authentication tokens, private payloads, or arbitrary exception content.
- Do not suppress failures in consequential mutations. Optional integrations may fail independently when the application's declared degradation behavior allows it.
- Avoid unexpected side effects inside rendering and other nominally pure functions.

### 5.1 OWASP-derived defensive programming: defense in depth

Every function handling untrusted data, identity, external I/O, durable state, or a consequential operation participates in application security. Apply the following practical secure-coding defaults, drawing on OWASP secure-coding and cheat-sheet guidance. This is **not** an instruction to embed a WAF or repeat structural request scanning throughout business code. Preserve the governed ingress, application request perimeter, and mutation-integrity controls, then enforce each domain invariant at the layer that owns it.

- **Trust boundaries and input:** Normalize and validate inputs once at their ingress boundary for type, format, size, encoding, and allowed structure; recheck business invariants at the domain boundary that owns them. Do not use broad SQL/HTML/attack-keyword blacklists: legitimate messages and source code may contain those strings.
- **Authorization on every operation:** Independently enforce authenticated actor/application authority, scope, ownership and current record state at each sensitive read or mutation. Never trust hidden form fields, the browser, an upstream role claim, a record identifier, or a previously rendered button as authorization.
- **Injection and safe output:** Use prepared/parameterized database operations; keep dynamic SQL identifiers strictly allowlisted. Encode each output for its actual HTML, attribute, URL, JavaScript, JSON, header, or other destination; avoid constructing executable markup or shell commands from input. Prefer data-to-template over string-built execution.
- **Browser and provider mutations:** Preserve same-origin/CSRF protections for browser writes, reject unsafe method confusion, verify provider webhook signatures over the specified unmodified raw bytes, and use short-lived purpose-bound one-use artifacts where required. Durable consequential operations must remain idempotent across double clicks, retries, timeouts, and delayed callbacks.
- **Sensitive operations and data:** Use proven platform cryptography and secure random generation; do not invent cryptographic protocols. Apply least-privilege database/provider identities, minimize retained data, use narrow secret access, and prevent secrets, session identifiers, recovery tokens and private payloads from entering logs, errors or telemetry.
- **I/O and availability:** Limit payload sizes, memory allocation, query cardinality, upload types, path access, remote URLs/redirects, timeouts and retry budgets at the relevant boundary. Prevent traversal, unsafe file placement and SSRF where the feature accepts paths or URLs. Fail closed on authentication/authorization errors; define safe failure and recovery for partial external side effects.
- **Review and evidence:** Include malformed, unauthenticated, unauthorized, wrong-owner, replay, duplicate-submit, partial-failure and resource-limit cases in the tests appropriate to the changed operation. Do not describe a single test or external scanner as proof that the application is secure.

Avoid copy-pasting checks into every function. Put reusable structural checks in the governed perimeter, then use small explicit authorization, validation, encoding and transaction helpers where their contract materially improves correctness. Project-specific OWASP/ASVS, accessibility, HTMX and security specifications add stronger requirements where applicable.

## 6. Excellent embedded plain-English documentation

Documentation is implementation work. The code and comments together must explain the software to a new maintainer.

### 6.1 File responsibility

Every production PHP include must begin with a concise plain-English responsibility header after `declare(strict_types=1)` when present, before any application statement or `require`. The header must communicate the following concepts (literal labels are encouraged, not required):

- **PURPOSE:** the system/business reason the file exists and the main entry points it provides;
- **THIS FILE OWNS:** state, operations and contracts for which it is authoritative;
- **THIS FILE DOES NOT OWN:** important responsibilities and provider/domain behaviors delegated elsewhere;
- **RUNTIME / HARDWARE ASSUMPTIONS:** PHP runtime/host, request lifetime, relevant hardware or other operating conditions when material.

Explain ownership clearly without duplicating lengthy package/project documents. A file header does not substitute for a separate immediate documentation block above its first function.

### 6.2 Function contracts

Every named production function must have an immediate documentation comment. Explain enough of its contract for a developer to understand it without stepping through every caller.

For a substantive function document, as applicable:

- purpose: why the function exists;
- workflow/caller: when it executes and what it assumes has happened first;
- parameters and return meaning, including null/empty states;
- database and external reads/writes, mutations, and other side effects;
- authentication, authorization, security, privacy, and transaction assumptions;
- error behavior, idempotency, retry, or long-lived-worker concerns;
- units/formats for quantities, dates and external values where ambiguity could cause an error;
- state-machine preconditions and postconditions, including durable transitions, ordering and recovery assumptions where material.

For an obvious small pure helper, a concise purpose and purity note are preferable to repetitive template sections. For important boundaries, provide the full relevant contract.

Consequential state changes must be explicitly named and documented; hidden writes to payments, authorization, evidence, retention, lifecycle or other durable state are prohibited. Functions should have one primary responsibility. If a purpose sentence becomes unwieldy or a function combines independent workflows, split it into smaller documented functions when that makes the complete path easier to maintain.

Explain **why** an unusual operation or ordering is necessary, not what each line of PHP syntax does. Comments must match present behavior; update them in the same change as the implementation. Do not create noisy comments that restate every statement.

### 6.3 Human-readable reference

Every substantive application must maintain a human-readable **Function/Service Reference or Code Map**, grouped by product and source file, identifying each production application-defined function, its short purpose, major workflow entry points and external/provider boundaries. Update it when functions are added, removed, renamed or materially changed. Small single-purpose tools may use their README and source documentation as an equivalent index when that is genuinely easier to navigate. Immediate code docblocks remain authoritative; do not duplicate full implementation comments in the reference.

Human maintainability is a **release requirement**. New or changed code must update source documentation, indexes and externally observable contract documentation in the *same change*. Wherever practical, CI must verify documentation presence, reference coverage for changed functions, absence of leaked credentials, and the relevant conformance tests. Automated checks are a floor: review must still ensure that documentation is factually correct, not merely present.

Describe important data ownership, runtime flows, configuration/deployment, security boundaries, and recovery in repository documentation. The governing language standard stays in `thermacube/atria-spec`; implementations link to it and document only their project-specific decisions.

## 7. Style and dependencies

- Use consistent indentation and formatting already established by the project. Prefer idiomatic PSR-12-compatible layout when that does not conflict with an explicit repository convention.
- Use descriptive function names and clear variable names. Avoid compressed one-letter production identifiers and unnecessary generic helpers.
- Do not introduce frameworks, Composer dependencies, static-analysis platforms, or code generators by default. A documented concrete benefit must justify each addition.
- Keep domain logic free from direct HTML/transport concerns wherever the project already maintains that separation.
- Preserve procedural APIs and host integration boundaries unless an approved change explicitly replaces them.
- Name business constants, states and significant protocol values centrally instead of repeating unexplained magic strings/numbers.
- Keep complex SQL readable and briefly document the business question and ordering/locking invariants that make the query necessary.
- Document each consequential schema migration or backfill in plain English, including the data transformation, compatibility implications, rollback/recovery limits, and verification.
- Use provider-neutral names and data semantics in domain functions. Confine vendor-specific names, SDK objects and integration details to narrow provider adapters, documenting the stable contract the core expects.

## 8. Testing and release checks

Keep tests direct and proportionate. Focus on real invariants, malformed inputs, failure/negative paths, and meaningful real-database integration.

Default checks where supported:

- `php -l` for modified PHP files and the project's configured PHP version;
- existing project unit/integration tests and database fixtures;
- existing documentation/conformance tests and review of affected Function/Service Reference entries;
- existing security, request-perimeter, accessibility, i18n/l10n, and HTMX gates where applicable.

Profile material optimization changes rather than claiming savings by inspection alone.

For consequential writes/updaters, test duplicate submission, retries, data preservation, transaction boundaries, and failure recovery where the project requires them.

Review each change:

1. Is the solution the smallest **readable complete** implementation?
2. Does it preserve procedural/functional design and explicit boundaries?
3. Is resource use appropriate and bounded?
4. Is every new production function accurately documented in plain English?
5. Is deployment configuration protected and PHP-file-based?
6. Are security, error behavior, relevant tests, and project-specific specs preserved?

## 9. Conformance and adoption

New PHP code and material changes should comply. Existing projects may retain justified legacy code until their normal maintenance work touches it; this standard is not an instruction to rewrite working applications wholesale. If a local constraint requires an exception, document why and retain all governing security and data guarantees.

The canonical document is maintained in `thermacube/atria-spec`. Implementations must link to this versioned document instead of maintaining divergent local copies. Atria's qualified RoadRunner/Spiral exception is governed by Section 2.3; an exception in one product is not automatically permission in another.
