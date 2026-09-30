# Thermacube PHP Coding Standard v1.0

**Status:** Governing engineering standard  
**Scope:** New and materially modified PHP code in Thermacube applications, modules, adapters, telemetry services, and deployment tools  
**Authority:** `thermacube/atria-spec`, `engineering/Thermacube_PHP_Coding_Standard_1.0.md`  
**Companion:** `Thermacube_Go_Coding_Standard_1.0.md`

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

- **PHP application configuration is PHP-file-based.** Load explicit, deployment-owned PHP configuration that returns an array. Secrets belong in protected deployment configuration, not Git, browsers, log output, `.env` files, or process environment variables.
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

## 6. Excellent embedded plain-English documentation

Documentation is implementation work. The code and comments together must explain the software to a new maintainer.

### 6.1 File responsibility

Every production PHP include must begin with a plain-English responsibility header after `declare(strict_types=1)` when present, before any application statement or `require`. Explain the file's owned boundary and what it intentionally delegates elsewhere.

### 6.2 Function contracts

Every named production function must have an immediate documentation comment. Explain enough of its contract for a developer to understand it without stepping through every caller.

For a substantive function document, as applicable:

- purpose: why the function exists;
- workflow/caller: when it executes and what it assumes has happened first;
- parameters and return meaning, including null/empty states;
- database and external reads/writes, mutations, and other side effects;
- authentication, authorization, security, privacy, and transaction assumptions;
- error behavior, idempotency, retry, or long-lived-worker concerns.

For an obvious small pure helper, a concise purpose and purity note are preferable to repetitive template sections. For important boundaries, provide the full relevant contract.

Explain **why** an unusual operation or ordering is necessary, not what each line of PHP syntax does. Comments must match present behavior; update them in the same change as the implementation. Do not create noisy comments that restate every statement.

### 6.3 Human-readable reference

Maintain the repository's existing function reference, code map, or human-readable documentation index. Where the repository already has a documentation/conformance CI gate, every changed or added function and boundary must pass it.

Describe important data ownership, runtime flows, configuration/deployment, security boundaries, and recovery in repository documentation. The governing language standard stays in `thermacube/atria-spec`; implementations link to it and document only their project-specific decisions.

## 7. Style and dependencies

- Use consistent indentation and formatting already established by the project. Prefer idiomatic PSR-12-compatible layout when that does not conflict with an explicit repository convention.
- Use descriptive function names and clear variable names. Avoid compressed one-letter production identifiers and unnecessary generic helpers.
- Do not introduce frameworks, Composer dependencies, static-analysis platforms, or code generators by default. A documented concrete benefit must justify each addition.
- Keep domain logic free from direct HTML/transport concerns wherever the project already maintains that separation.
- Preserve procedural APIs and host integration boundaries unless an approved change explicitly replaces them.

## 8. Testing and release checks

Keep tests direct and proportionate. Focus on real invariants, malformed inputs, failure/negative paths, and meaningful real-database integration.

Default checks where supported:

- `php -l` for modified PHP files and the project's configured PHP version;
- existing project unit/integration tests and database fixtures;
- existing documentation/conformance tests;
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

The canonical document is maintained in `thermacube/atria-spec`. Implementations must link to this versioned document instead of maintaining divergent local copies.
