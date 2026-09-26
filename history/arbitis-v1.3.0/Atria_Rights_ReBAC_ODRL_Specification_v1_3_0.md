# Atria Rights/ReBAC Module Specification v1.3.0

## 1. Purpose

The Rights module is the shared authorization, entitlement-policy, and machine-readable rights capability for the Atria majestic monolith. Arkiv, Atria, Ordin, H5P, and future modules call the same decision interface. The module replaces module-local ACL, role, licensing, sharing, workspace-permission, and export-right engines with one relationship-based model.

Its primary invariant is:

```text
subject + relationship graph + requested action + trusted context -> decision + obligations
```

A license is an external/human/machine expression of the same enforceable policy used internally. It is not a second rights system.

## 2. Design goals

- relationship-based access control as the canonical authorization model;
- default deny and complete mediation;
- small stable action vocabulary with module-specific namespaced extensions;
- subject membership and object containment inheritance;
- conditional relationships with effective dates and trusted contextual facts;
- explicit prohibitions and deny-overrides conflict handling;
- obligations for payment, accounting, attribution, watermarks, or consumable entitlements;
- ODRL 2.2 JSON-LD projection/import through an Atria profile;
- rights discoverability and search filtering;
- in-process use by default, remote API possible later;
- no arbitrary executable policy language.

## 3. Domain model

### 3.1 Entity

Any principal or governed object participating in the graph has a globally unique stable entity ID. Entities may represent users, groups, organizations, workspaces, courses, Arkiv resources, H5P activities, Ordin objects, packages, domains, public/anonymous, or service principals. The owning module controls the entity's domain state; Rights stores only identity and authorization-relevant attributes when necessary.

### 3.2 Relationship

A canonical relationship contains:

```text
subject
relation
object
effect: allow|deny
actions: optional instance action set
effective_from / effective_until
conditions[]
obligations[]
source_policy_id
status
```

The relation definition supplies default actions and whether subject membership or object descendant inheritance applies. A relationship instance may narrow or specialize the actions and conditions for a specific grant/license.

### 3.3 Structural relations

`member` forms subject closure. `contains` forms object ancestry/descendant scope. These are graph structure, not permissions by themselves.

Example:

```text
Alice --member--> Science Editors
Science Editors --editor--> Morrison Science
Morrison Science --contains--> Resource X
```

If `editor` permits membership and descendant inheritance, Alice may edit Resource X.

## 4. Action vocabulary

Initial generic actions are:

`discover`, `view`, `use`, `create`, `edit`, `reuse`, `remix`, `publish`, `export`, `manage`.

Modules MAY register namespaced actions such as `ordin:approve` or `h5p:install-library` when generic actions would distort semantics. Actions never imply other actions except through relation policy definitions.

## 5. Relation definitions

The starter vocabulary contains `viewer`, `user`, `editor`, `remixer`, `publisher`, `exporter`, `manager`, and `licensee`. These names are convenience semantics, not global roles. A subject is always `publisher of X`, never simply a global Publisher.

`licensee` is deliberately broad: the specific relationship may state the actual actions granted by a license. Internal administrative rights and external licenses therefore use the same data model.

## 6. Conditions

Conditions refine whether a relationship is active. Start/end timestamps are first-class columns. Additional conditions are bounded JSON expressions over either trusted request context or registered fact providers. Examples:

- `origin in [...]`;
- `country == US`;
- `mfa == true`;
- `commerce.export_credit >= 1`;
- `subscription.active == true`;
- `resource.workflow_state == approved`.

Client-provided facts are never trusted merely because they appear in a request. Each context field has an authoritative source defined by integration code. Fact providers are explicit module callbacks.

The core condition operators are `eq`, `neq`, `gt`, `gte`, `lt`, `lte`, `in`, and `contains`. The policy language is intentionally not Turing complete.

## 7. Obligations

An authorization decision may carry obligations. If an allow-path requires an unfulfilled duty, the decision is `requires_obligation`. Examples include:

```text
payment
consume_entitlement
record_usage
attribute
watermark
report_royalty
```

A pay-per-export policy may allow `export` subject to a commerce fact and return `consume_entitlement` quantity 1. The export operation and consumable obligation MUST be atomic or use an idempotent reservation/commit protocol so concurrent requests cannot spend the same entitlement twice.

The Rights module does not become the ecommerce ledger. Commerce remains authoritative for transactions/balances and registers fact/obligation providers.

## 8. Decision algorithm

`rights_check(subject, action, object, context)`:

1. builds the subject closure through `member`;
2. builds object ancestors through inverse `contains`;
3. locates active relationships between the closures;
4. enforces relation inheritance flags;
5. resolves instance/default action sets;
6. evaluates effective dates and conditions;
7. applies explicit prohibitions with deny-overrides;
8. combines obligations from matching allow paths;
9. returns `allow`, `deny`, or `requires_obligation`, plus decision trace metadata.

Traversal depths are bounded and configurable. Production implementations SHOULD add closure/materialized indexes if graph size makes recursive evaluation expensive; those indexes are caches, not policy truth.

## 9. Public API

Required in-process contract:

```php
rights_check(string $subject, string $action, string $object, array $context=[]): array
rights_filter_allowed(string $subject, string $action, array $objects, array $context=[]): array
rights_relate(string $subject, string $relation, string $object, array $options=[]): int
rights_odrl_policy_for_relationship(int $relationshipId): ?array
rights_normalize_odrl(array $policy): array
rights_import_odrl(array $policy, string $issuerEntityId=''): array
```

A later remote service may expose equivalent HTTP operations, but modules in the majestic monolith call the in-process API.

## 10. ODRL representation

The external machine-readable representation uses W3C ODRL 2.2. ODRL's Information Model represents permissions, prohibitions, duties, assets, parties, and constraints, including temporal/spatial constraints and duties such as payment. ODRL Profiles permit communities to define additional semantics.

Atria defines an ODRL Profile IRI and maps generic actions to ODRL where semantics align (`view` -> `odrl:read`, `use` -> `odrl:use`, `edit` -> `odrl:modify`). Atria-specific operations such as `publish`, package `export`, `discover`, or module-specific actions use profile terms.

The ODRL representation is a projection of enforceable relationships. Human-readable terms pages and JSON-LD policies share the same policy identity/provenance.

W3C references:

- https://www.w3.org/TR/odrl-model/
- https://www.w3.org/TR/odrl-vocab/

## 11. Discoverability

Policies may be marked discoverable. Modules may expose a resource's public/offer terms without authenticating a caller, while personalized evaluation remains separate. Search systems may query rights semantics such as:

```text
resources I may remix
resources I may export
resources with an export price under $10
resources licensed to my organization through a given date
```

Discoverability of policy terms does not itself grant the advertised action.

## 12. ODRL import

ODRL import MUST validate the Atria profile and normalize supported ODRL rules into atomic relationships, conditions, and obligations. Unknown profile terms MUST fail closed rather than be silently ignored. The original policy document and provenance SHOULD be preserved for audit.

## 13. Module integrations

### Arkiv

Arkiv owns resources, packages, domains, publishing state, and authenticated credential mapping. It registers/mirrors entities and containment relationships as needed, then calls Rights for discover/view/edit/publish/export decisions.

### H5P

H5P owns activities and authoring runtime. Author/publisher workspaces, licensing, discoverability, edit/remix/export, and delivery rights are Rights relationships.

### Ordin

Ordin registers its governed objects and module-specific actions while using the same membership, scope, conditions, and decision API.

### Atria

Atria application concepts such as courses, instructors, learners, organizations, and services participate directly in the graph, enabling cross-module relationship paths without synchronized ACL copies.

## 14. Workspaces

A workspace is a domain object, not an authorization primitive. A module creates a workspace entity and `contains` relationships. Rights such as `editor` or `publisher` attach to that object and may inherit to descendants. Personal, team, department, publisher, and institutional workspaces require no separate permission engine.

## 15. Security properties

- default deny;
- complete mediation at every protected operation;
- deny-overrides for explicit prohibitions;
- bounded traversal and condition evaluation;
- trusted context attribution;
- no client-asserted entitlements;
- no arbitrary code in policies;
- decision traces avoid sensitive fact values by default;
- credentials authenticate subjects but do not embed large permission graphs;
- cached decisions are short-lived and invalidated/versioned on relationship changes.

## 16. Storage

MariaDB tables use the `rights_` prefix. `rights_entities` stores graph identities, `rights_relation_definitions` supplies reusable semantics, `rights_relationships` stores canonical tuples and instance conditions, and `rights_policy_documents` stores provenance/terms metadata. Module business state remains in its owning module.

## 17. Migration strategy

For each adopting module:

1. register stable entity IDs;
2. define containment and membership edges;
3. convert current grants/licenses/roles to relationships;
4. compare old and new decisions using parity fixtures;
5. switch enforcement to Rights;
6. retain old ACL data read-only for an audit interval;
7. remove old authorization logic after parity.

Arkiv is the first migration and must complete before H5P workspace/licensing integration begins.

## 18. Testing

Tests MUST cover direct grants, group membership, nested membership, descendant inheritance, combined membership+containment paths, start/end boundaries, trusted-context conditions, fact-provider failures, explicit deny, obligations, pay-per-export concurrency protocol at integration level, ODRL projection, ODRL import rejection of unknown profile semantics, and cross-module entity paths.

## 19. Reductive boundary

The Rights module is not an identity provider, ecommerce system, workflow engine, repository, learning-record store, or content service. It consumes stable identities and trusted facts from those modules and answers rights questions consistently.


## v1.1.0 Production Evaluation Architecture

### Batch-first authorization

The primary evaluator is `rights_check_many(principals, action, objects, context)`. Single-object `rights_check()` and `rights_filter_allowed()` are convenience wrappers around the batch evaluator. Search, discovery, collection rendering, package export, and other list operations MUST use the batch interface. Authorization complexity must not grow as an N+1 sequence of independent graph traversals.

### Materialized structural closure

`member` and `contains` are structural relations. Their transitive closure is materialized in `rights_subject_closure` and `rights_object_closure`. Each table includes zero-depth self rows. Authorization reads closure rows through indexed lookups rather than recursively traversing `rights_relationships` at request time. Structural relation creation extends the closure transactionally. Structural revocation invokes a closure rebuild; direct SQL mutation of structural relationships is unsupported unless followed by `rights_rebuild_closures()`. Cycles are rejected.

### Worker-local structural cache

RoadRunner workers maintain bounded LRU caches of materialized subject/object closures. Cache entries are keyed by the current `rights_graph_meta.revision`; structural writes increment the revision and clear the writing worker cache. Callers should fetch the revision once per request and pass it in trusted context, preventing repeated revision reads during one request while ensuring authorization changes invalidate cached topology. Cache is an accelerator only; closure tables remain authoritative.

### Unified active-principal evaluation

A request may simultaneously act through a user identity, group ancestry, signed session, deployment/package identity, domain identity, service identity, and public principal. These are submitted together. The engine computes their union closure once and evaluates candidate relationships in one pass. Explicit prohibitions take precedence across the active principal set.

### Temporal conditions

Effective start/end filtering is pushed into the relationship SQL query using a single request timestamp. Custom temporal conditions use `context.now_epoch`. The evaluator MUST NOT instantiate `DateTimeImmutable` for every candidate relationship.

### Complexity target

For a batch decision over P active principals and N candidate objects, after worker cache hits, the normal database path is: one graph revision read per request if not supplied, at most one batched subject-closure query, at most one batched object-closure query, and one candidate-relationship query. The number of SQL round trips is therefore bounded rather than proportional to N or graph depth.


## v1.2.0 Graph Mutation, Revocation, and Atomic Obligation Hardening

### Structural mutation serialization

`member` and `contains` mutations acquire a row lock on `rights_graph_meta` before cycle validation or closure mutation. Structural writes are therefore serialized while ordinary grants, denials, and authorization reads remain concurrent. This prevents reciprocal concurrent inserts from each passing cycle validation against stale topology.

### Path-counted materialized closure

Both closure tables add `path_count`. The value records the number of active DAG paths from descendant to ancestor. Zero-depth self rows have a count of one. Adding one structural edge increments only the affected descendant x ancestor cross-product. Removing one edge subtracts exactly the paths that traverse that edge; alternate paths remain authorized while rows whose count reaches zero are deleted.

Ordinary structural revocation MUST NOT rebuild the global closure tables. `rights_rebuild_closures()` remains an administrative repair/migration operation only.

### Consistent authorization during concurrent mutation

Authorization reads remain lock-free. `rights_check_many()` performs optimistic graph-version validation: read committed graph revision, evaluate closures and policy rows, then re-read revision. If a structural mutation committed during the evaluation, the mixed-version result is discarded and retried. Retries are bounded; sustained mutation fails closed with `graph_changing` rather than returning an inconsistent decision.

Callers MUST NOT pin a graph revision across an entire HTTP request. The Rights module owns revision selection and retry semantics at each authorization decision. Worker-local caches remain revision-keyed accelerators.

A revocation committed before a new decision starts is therefore visible to that decision. A decision already in flight may linearize immediately before the revocation commit; the module does not lock every authorization read behind mutation traffic.

### Mutation performance contract

Structural write cost is proportional to the affected closure cross-product, not total graph size. Non-structural grants/revocations do not bump structural graph revision because relationship candidate rows are read directly for every decision; avoiding unnecessary revision churn preserves worker cache hit rates.

### Atomic commerce-backed obligations

The module adds `rights_entitlements` and `rights_obligation_reservations`. Commerce/licensing systems may issue an entitlement keyed to subject, object, and action. `rights_reserve_entitlement()` uses `SELECT ... FOR UPDATE`, an idempotency key, and a conditional decrement to ensure two concurrent requests cannot consume the same remaining use.

The lifecycle is:

```text
authorize
  -> reserve entitlement atomically
  -> perform bounded external/domain operation
  -> commit reservation on success
  -> release reservation on failure
```

Reservations have an expiry and may be released by a bounded cleanup job. Unlimited entitlements use `remaining_uses = NULL`. Payment settlement remains owned by commerce; Rights owns the atomic authorization-side reservation of the entitlement created by that settlement.

### Migration

The v1.1.0 -> v1.2.0 migration adds `path_count` and the entitlement/reservation tables. Before enabling structural writes, deployments MUST run `rights_rebuild_closures()` once to populate exact path counts for the existing graph.


## 24. v1.3.0 Module Adoption Contract

Before any module switches enforcement to Rights, it MUST pass a common adoption gate. Stable object identities use `urn:atria:{module}:{type}:{local-id}`. Adopting modules MUST NOT persist local database primary keys in cross-module relationship columns as their external identity. Existing legacy identifiers may be migrated during a shadow period, but new relationships use canonical IDs.

Generic actions are registered by the platform. A module action that cannot truthfully use the generic vocabulary MUST be registered explicitly using a namespaced key such as `h5p:install-library` or `ordin:approve`. Unregistered actions fail closed. An adopting module may not overload `edit`, `publish`, or another generic action with materially different semantics merely to avoid registration.

Migration proceeds through entity registration, relationship conversion, and shadow parity fixtures. A parity fixture records the active principals, action, object, trusted context, and legacy decision. The Rights decision MUST match the legacy evaluator before enforcement is switched. Legacy ACL data remains read-only during an audit interval.

Each adopting module declares an operational health domain `module:{module}` and an operator-controlled mutable storage root. Module runtime code used by RoadRunner MUST return response descriptors and MUST NOT call `exit` or `die`. Temporary files, generated packages, caches, and scratch rendering state MUST live beneath the module storage root outside any public web root.

The packet includes `module-adoption.schema.json`, `parity-fixture.schema.json`, a sample adoption manifest, and a parity runner. These are integration contracts rather than a second plugin framework.
