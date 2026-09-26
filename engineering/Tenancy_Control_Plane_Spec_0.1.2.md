Tenancy Control Plane Spec 0.1

*Database-per-tenant provisioning, routing, and migrations*

Revision: 0.1.2 (2025-12-18)

Status: Draft (binding once accepted into the Thermacube/Atria spec set).

**1. Purpose**

This specification defines how Atria provisions and routes database-per-tenant deployments while maintaining strong isolation guarantees and operability.

**2. Tenancy Model**

• Each tenant SHALL have an isolated primary MariaDB database (DB-per-tenant).

• A single system/control database MAY exist to store tenant routing metadata and operational configuration. It MUST NOT store learner PII.

• tenant_id is a UUID assigned at tenant creation time and MUST remain stable.

**3. Routing and Tenant Resolution**

Each incoming request MUST resolve to exactly one tenant context before any database access.

• Supported routing modes: host-based (tenant.example.org) or path-based (/t/{tenant_slug}/...).

• The resolver MUST map tenant_slug/host to tenant_id and database connection info from the control database.

• Requests that cannot resolve a tenant MUST fail fast with HTTP 404 (UI) or a structured error (API).

**4. Provisioning Lifecycle**

**4.1 Create Tenant**

Provisioning MUST be idempotent and auditable.

• Allocate tenant_id and tenant_slug.

• Create a new MariaDB database schema for the tenant.

• Run migrations to the current schema version.

• Create initial system identities and bootstrap admin role assignments.

**4.1.1 Bootstrap and Seed Data (Normative)**

At tenant creation time, the control plane SHALL ensure the tenant database is bootstrapped to a valid 'time zero' state before emitting TenantCreated (FACT). Bootstrap SHALL be idempotent and safe to retry.

Minimum required seed data:

• System identity: create at least one identity row with identity_type = system to represent automated actions (workers, migrations, control-plane initiated operations).

• Baseline roles: create stable role records (e.g., tenant_admin, instructor, learner, system_worker) as the canonical role vocabulary for the tenant.

• Baseline entitlements: grant required entitlements to system identities and initial administrators as appropriate for provisioning and ongoing operations. Entitlements MUST be persisted (not inferred) and MUST remain auditable per Spec 0.3.

• Optional initial administrator: if provisioning includes an initial human administrator identity, create the identity record and assign the tenant_admin role with appropriate tenant-scoped entitlements.

Bootstrap completeness rule: TenantCreated (FACT) SHALL be recorded only after schema migrations and the bootstrap seed steps have completed successfully. If provisioning fails, no TenantCreated fact SHALL be emitted and the tenant SHALL be treated as non-existent or incomplete by the resolver.

• Record TenantCreated (FACT) in the tenant's evidence ledger (Spec 0.2 subtype TenantCreated).

**4.2 Deactivate / Archive Tenant**

• Deactivation MUST disable logins and new writes but must preserve read-only access for audit as required.

• Archival MAY snapshot the tenant database and move it to cold storage, preserving evidence replay guarantees.

• Record TenantDeactivated (FACT) in the tenant's evidence ledger when deactivation occurs (Spec 0.2 subtype TenantDeactivated).

• Record TenantArchived (FACT) in the tenant's evidence ledger prior to snapshot/cold-storage archival (Spec 0.2 subtype TenantArchived).

**5. Migrations and Rollouts**

Schema migrations must be safe across many tenant databases.

• Migrations MUST be forward-only and must include a compatibility window for application rollout.

• The control plane SHOULD roll out migrations in batches with backoff and observability.

• For any migration that modifies hot-path tables, performance impact MUST be measured and documented.

**6. Secrets and Connection Management**

• Database credentials MUST be stored in a secrets manager (or equivalent) and not in source control.

• Application instances MUST not share tenant database connections across tenants.

• Connection pools MUST be per-tenant and bounded.
