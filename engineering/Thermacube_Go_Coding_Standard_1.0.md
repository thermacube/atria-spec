# Thermacube Go Coding Standard v1.0

**Status:** Governing engineering standard  
**Scope:** New and materially modified Go code in Thermacube application repositories, installers/updaters, development tooling, and security/telemetry daemons  
**Authority:** `thermacube/atria-spec`, `engineering/Thermacube_Go_Coding_Standard_1.0.md`  
**Companion:** `Thermacube_PHP_Coding_Standard_1.0.md`

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

## 5. Excellent embedded documentation

The source should help a capable developer understand **what happens, why, and what assumptions must hold**, without reconstructing the original author's thoughts.

### 5.1 Package and file purpose

Each substantive package must have a clear English package description. Substantial files may add a short responsibility comment describing their operational boundary. Do not duplicate the same lengthy description in every file.

### 5.2 Function contracts

Every exported function/type must have idiomatic Go documentation beginning with its identifier. Every substantive internal function must have an immediate plain-English purpose comment.

Where relevant, describe:

- purpose and the workflow/caller it supports;
- inputs, outputs, and important invariants;
- file, database, network, or shared-state side effects;
- security, privacy, or authorization assumptions;
- failure, retry, recovery, or concurrency behavior.

Do not add a seven-section template to a self-evident one-line helper. For a consequential function, cover the applicable contract fully.

**Explain decisions, not syntax.** The comment for `if err != nil` should not say "check the error." Explain *why* an unusual check or ordering is required (e.g., a second update must not overwrite installed configuration).

Update documentation in the same change as behavior. Outdated documentation is a defect.

### 5.3 Operational documentation

Document real setup/configuration, commands, data/upgrade invariants, external boundaries, and troubleshooting in human-readable repository documentation. Keep comments close to code and avoid generating an unreadable duplicate of the source.

## 6. Idiomatic Go constraints

- Format with `gofmt`; keep names idiomatic, concise, and unambiguous.
- Use typed configuration loaded explicitly from project-approved files/sources. Do not silently add environment-variable, `.env`, or remote configuration layers contrary to a project's configuration contract.
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

The canonical document is maintained in `thermacube/atria-spec`. Other repositories must link to the versioned standard rather than fork divergent local copies.
