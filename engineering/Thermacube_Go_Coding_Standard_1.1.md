# Thermacube Go Coding Standard v1.1

**Revision:** 1.1 (2026-09-30) — adds operational state/documentation contracts, qualified Atria exception, native Go configuration and OWASP-derived defensive programming  
**Status:** Governing engineering standard  
**Scope:** New and materially modified Go code in Thermacube application repositories, installers/updaters, development tooling, and security/telemetry daemons  
**Authority:** `thermacube/atria-spec`, `engineering/Thermacube_Go_Coding_Standard_1.1.md`  
**Companion:** `Thermacube_PHP_Coding_Standard_1.1.md`

## 1. Intent and decision order

Write the **smallest correct, secure, understandable, resource-efficient implementation** that performs the required work. This standard translates Thermacube's reductive, procedural PHP philosophy into idiomatic Go.

When principles compete, decide in this order:

1. Preserve correctness, security, data integrity, and specified behavior.
2. Prefer the simplest design that a maintainer can understand and operate.
3. Reduce unnecessary code, dependencies, processor work, memory, and maintenance cost.
4. Optimize a measured bottleneck only when the improvement justifies added complexity.

Fewest lines means fewest **necessary, readable** lines—not condensed control flow, omitted error handling, or code golfing. A direct ten-line function is often better than a three-layer five-line abstraction.

A project-specific architecture, security, configuration, API, or upgrade specification remains authoritative for that project. Adopt this standard incrementally for existing code; do not destabilize working systems through cosmetic rewrites.

## 1.1 Where Go is the preferred language

**Use Go as the default for new system daemons and system-level utilities** when the required operating-system, networking, process-control, deployment, or long-running workload can be implemented cleanly with Go. Examples include installers/updaters, host collectors, service supervisors, security testing daemons, and other standalone system tools. Prefer small, self-contained binaries and an explicit operating-system service lifecycle.

**In applications served by RoadRunner, retain procedural PHP as the normal application and domain language.** Use Go selectively when a specific hot path demands substantially better performance, lower memory usage, or more predictable resource consumption than the equivalent PHP implementation in the existing RoadRunner context can deliver. Where the workload characteristics make the benefit obvious, a small Go implementation may be justified before a production bottleneck appears; otherwise benchmark or profile both options under representative workloads.

A Go hot path must have a narrow, documented call/data boundary. Prefer an appropriate in-process or existing RoadRunner integration over introducing new network services, routing layers, or deployment dependencies merely to switch languages. Measure end-to-end overhead, including serialization, handoff, concurrency, memory, and operational complexity, rather than comparing isolated function execution speed.

A new programming language creates an additional build, debugging, security, staffing and long-term maintenance obligation. Prefer the project's existing languages unless the new language provides a demonstrable system-level, reliability or end-to-end performance benefit. Once a standalone tool/daemon is approved as Go, give it one clear runtime and native configuration contract; do not retain a second implementation merely for configuration parsing.

**Do not migrate ordinary PHP functionality to Go solely because Go may be faster.** Retain a simpler procedural PHP implementation when it meets the performance budget, and document the justification for each mixed-language boundary.

## 2. Reductive design

- Implement current requirements only. Do not add speculative frameworks, plugin systems, interfaces, configuration switches, extension points, or future-module scaffolding.
- Prefer Go's standard library. Add an external module only for a demonstrated capability or material reduction in *total* complexity; pin, document, and review it.
- Favor explicit control flow, direct data transformations, and short call paths. Avoid unnecessary wrappers, repeated serialization/parsing, copies, allocations, and redundant database/network calls.
- Keep the smallest useful package layout. Group code by actual responsibility, not architectural fashion. Do not make a package for every type or function.
- Remove obsolete code and duplicative paths when safely replacing them. Keep compatibility only when the product contract requires it.
- Avoid reinventing existing reliable standard-library functionality.

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

### 2.2 CPU, memory, and I/O

- Choose an algorithm appropriate to real data size and execution frequency.
- Prefer incremental readers, writers, and streaming when whole-dataset materialization is unnecessary. Bound input, response, queue, buffer, retry, and cache sizes where appropriate.
- Avoid unnecessary background jobs, busy loops, polling, and repeated work. Set reasonable timeouts and cancellation boundaries for operations that can block.
- Prefer sequential execution when it meets requirements. Introduce concurrency only when it produces a demonstrated operational benefit.
- Do not trade obvious readability and safety for speculative micro-optimizations. Benchmark/profile consequential improvements using Go's built-in facilities and document the reason for a less-obvious implementation.

**Resource budgets:** If a workflow has a measurable CPU, memory, throughput, binary-size, or startup requirement, record that budget and test it. Do not claim "zero allocation," "lowest memory," or "fastest" without evidence.

### 2.3 Atria and approved platform dependencies

Atria's existing RoadRunner deployment is a project-specific exception to the default dependency-avoidance rule. Because selected Spiral components come from the same broader upstream ecosystem, Atria may use an existing reviewed Spiral component instead of reimplementing equivalent infrastructure **only if** doing so reduces total code and operational complexity, and only behind a narrow replaceable boundary that preserves procedural/functional application and domain behavior. Evaluate the concrete function, upstream and transitive maintenance exposure, version pinning, tests, local maintenance cost and exit plan. Common upstream stewardship is correlated supply-chain risk, not dependency independence. This exception does not make Spiral an architectural default for Bridge, Comms, Varr, TVS or other projects.

## 3. Procedural and functional style

Go permits procedural programs with first-class functions; use that as the default.

- Organize work around ordinary package-level functions and explicit input/output data.
- Prefer pure transformation functions where possible: no hidden I/O, clock reads, state mutation, or global dependencies.
- Keep side effects at recognizable boundaries: application startup, file/database/network adapters, command execution, or other named operational functions.
- Pass dependencies and configuration explicitly. Avoid mutable package globals and hidden `init()` behavior unless a documented Go integration requires them.
- Use structs chiefly as data records or configuration. Do not introduce receiver methods just to imitate classes.
- Use methods when the operation genuinely belongs to a type or manages its resources/state. Use interfaces at a real implementation or test boundary, preferably defined near the consumer—not one interface per struct.
- Use ordinary loops, conditionals, and error returns when clearer than clever functional chains or generic utilities.
- Use generics, reflection, code generation, `unsafe`, complex callback registries, and dependency-injection frameworks only where a real, documented need outweighs their complexity.
- Prefer one explicit `main` control path: load/validate configuration, open resources, execute work, handle failures, shut down.

Example of the preferred style:

```go
// SumBytes returns the total size of the supplied byte slices.
// It does not modify its input or perform I/O.
func SumBytes(chunks [][]byte) int {
    total := 0
    for _, chunk := range chunks {
        total += len(chunk)
    }
    return total
}
```

Do not add a struct, method, interface, or service object for work like this.

## 4. Concurrency, lifetimes, and failures

- Default to sequential execution. Every goroutine must have a defined purpose, cancellation/shutdown behavior, error-handling policy, and bounded resource usage.
- Make shared-state ownership explicit. Use channels or synchronization only where appropriate, not because the language supports them.
- Return and handle errors explicitly. Add useful context with standard Go wrapping (`fmt.Errorf("...: %w", err)`), without logging secrets or user content.
- Use `panic` for programmer invariants that truly cannot recover, not routine input, network, or database errors.
- Close files, bodies, rows, and other resources deterministically; do not leak resources across error paths.
- Ensure retry semantics are intentional. Consequential writes, installers, and updaters must honor the project's idempotency, data-preservation, atomicity, and rollback/recovery contracts.
- Keep production diagnostics bounded, useful, and privacy-aware.
- Explicitly name and document consequential state mutations, ownership and recovery. For durable daemons, authoritative state must survive process restart/power interruption; do not mistake in-memory state or sending a request for committed success. Make filesystem metadata writes atomic where needed and distinguish local completion from remote acknowledgement.
- State-machine transitions that control hardware, evidence retention, synchronization, authorization, or financial/lifecycle effects must identify permitted transitions, ordering, units and fault behavior at their owning boundary.

### 4.1 OWASP-derived defensive programming: defense in depth

Security is part of ordinary coding at every trust and mutation boundary. Apply these practical OWASP-aligned defaults without building an embedded WAF or duplicating the application's governed request perimeter in every package:

- **Validate structured inputs at ingress:** enforce types, encoding, lengths, formats and bounded nesting; check domain invariants again in the function that owns them. Preserve legitimate free-form text, even when it resembles SQL, HTML, command syntax or test payloads.
- **Authorize sensitive reads and writes:** validate current actor/service identity, permissions, scope and record ownership at the authoritative operation, never on the strength of a browser choice or caller-provided identifier alone.
- **Avoid injection and unsafe rendering:** parameterize database values, strictly allowlist dynamic identifiers, use context-specific output encoding, avoid string-built shell commands and SQL, and keep file and URL access constrained against traversal/SSRF.
- **Protect mutations:** respect request origin/CSRF and signature validation in their appropriate host boundaries; use precise idempotency and replay protection for consequential operations. Verify signed provider payloads against the original bytes where required.
- **Protect resources and data:** use standard-library or well-reviewed cryptography and secure randomness, least-privilege accounts, constrained file permissions, bounded queues/buffers/timeouts/retries, safe cleanup, and data-minimized logs that never expose credentials or authentication artifacts.
- **Prove negative paths:** test wrong identity/ownership, malformed data, interrupted work, repeat delivery, partial success, resource exhaustion and recovery. Preserve immutable originals and provenance where the project's domain contract requires them.

Prefer one small, explicit helper at the correct boundary over scattering redundant validation. Project security specifications and OWASP ASVS profiles are stronger and more specific where adopted.

## 5. Excellent embedded documentation

The source should help a capable developer understand **what happens, why, and what assumptions must hold**, without reconstructing the original author's thoughts.

### 5.1 Package and file purpose

Each substantive package must have a clear, idiomatic English package description. Every substantial source file/module must clearly communicate **PURPOSE**, **THIS FILE OWNS**, **THIS FILE DOES NOT OWN**, and relevant **RUNTIME / HARDWARE ASSUMPTIONS**, using concise comments near the top or an immediately discoverable package-level explanation. Avoid a repeated multi-page header on every file; preserve normal Go package-comment and exported-identifier conventions. Explicitly identify the authoritative service, durable state, protocol, hardware control and provider boundaries where applicable.

### 5.2 Function contracts

Every exported function/type must have idiomatic Go documentation beginning with its identifier. Every substantive internal function must have an immediate plain-English purpose comment. Trivial one-line helpers may use a concise comment; important operational boundaries require fuller contracts. A package or file header cannot replace the documentation of an independently meaningful exported operation.

Where relevant, describe:

- purpose and the workflow/caller it supports;
- inputs, outputs, and important invariants;
- file, database, network, or shared-state side effects;
- security, privacy, or authorization assumptions;
- failure, retry, recovery, or concurrency behavior;
- expected **units and formats** (milliseconds versus seconds, byte counts, timestamps, CAN values, coordinates or identifiers) whenever ambiguous;
- durable state ownership, state-machine preconditions/transitions, shutdown/restart conditions, hardware or network effects, and confirmation/acknowledgement semantics when applicable.

Do not add a seven-section template to a self-evident one-line helper. For a consequential function, cover the applicable contract fully.

**Explain decisions, not syntax.** The comment for `if err != nil` should not say "check the error." Explain *why* an unusual check or ordering is required (e.g., a second update must not overwrite installed configuration).

Update documentation in the same change as behavior. Outdated documentation is a defect.

### 5.3 Operational documentation

Maintain a human-readable **Service/Function Reference or Code Map** for substantive multi-module applications, grouped by product/package/source file. Summarize important exported and substantive internal operations, service entry points, workflow ownership, provider/hardware adapters and externally observable contracts. A tiny single-purpose program may use a well-organized README as its equivalent index. Keep detailed function contracts in source rather than copying them into the reference.

Human maintainability is a **release requirement**. Update file/function docs, the reference and relevant operational/contract specifications in the same change as behavior. CI should check exported documentation, reference coverage where practical, formatting, important test/contract gates and absence of committed credentials; human review must verify accuracy.

Document real setup/configuration, commands, data/upgrade invariants, external boundaries, and troubleshooting in human-readable repository documentation. Keep comments close to code and avoid generating an unreadable duplicate of the source.

## 6. Idiomatic Go constraints

- Format with `gofmt`; keep names idiomatic, concise, and unambiguous.
- Use typed configuration loaded explicitly from project-approved files/sources. Standalone Go daemons and system tools should normally use their own protected **native filesystem configuration outside the web root**, with predictable permissions, schema validation, explicit defaults and documented upgrade behavior. Go configuration is **not** required to be PHP and must not launch PHP merely to parse settings. Do not silently add environment-variable, `.env`, or remote configuration layers contrary to a project's configuration contract.
- Document protocol payload versions, units, stable identifiers, provider-neutral domain naming, external adapter responsibilities and compatibility/recovery behavior. Keep vendor-specific types and naming out of core domain state.
- Prefer small explicit return types over `map[string]any` for internal domain data.
- Use `context.Context` where cancellation or deadlines must propagate, especially for network/process operations.
- Make errors actionable, but never include secrets, authentication artifacts, private data, or raw credentials in logs.
- Avoid a new HTTP router, ORM, service layer, or framework when the required workflow is served more simply by the standard library.

## 7. Verification and review

Use Go's built-in tooling before seeking more tooling:

- `gofmt` / formatting verification;
- `go test ./...` with focused unit, negative-path, and integration fixtures;
- `go vet ./...`;
- `go test -race ./...` for concurrent/shared-state code;
- maintainability review of changed package/file/function documentation and Service/Function Reference entries;
- `go test -bench` or profiling for material performance claims.

Tests should cover meaningful boundaries, malformed inputs, privacy/security assumptions, resource cleanup, and relevant retry/recovery behavior. Keep test scaffolding proportional to implementation complexity.

Review every substantial change against the following questions:

1. Is each abstraction and dependency necessary **now**?
2. Is there a simpler procedural/functional flow that preserves correctness?
3. Are CPU, memory, I/O, and concurrent work bounded appropriately?
4. Does the plain-English documentation explain the purpose and important decisions?
5. Are the failure, security, and data-integrity paths tested?
6. Does the change comply with the governing project-specific specs?

**Installer/updater profile:** A routine update must preserve existing data, user-owned configuration, and recoverability. Failed operations need a clearly documented safe recovery path. Implementation details are governed by the relevant installation/upgrade specification.

## 8. Conformance and adoption

This is a shared language standard, **not** an authorization to rewrite a mature project. New Go code and material changes should comply. Each implementation repository must reference this canonical v1.0 document and retain its additional project-specific contracts. Exceptions must be documented with a concrete reason; measure resource optimizations that increase complexity.

The canonical document is maintained in `thermacube/atria-spec`. Other repositories must link to the versioned standard rather than fork divergent local copies. The Atria platform exception in Section 2.3 is limited to that project.
