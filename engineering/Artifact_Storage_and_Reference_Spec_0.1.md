Artifact Storage and Reference Spec 0.1

*Immutable storage for content, assessments, workflows, and raw standards payloads*

Revision: 0.1 (2025-12-16)

Status: Draft (binding once accepted into the Thermacube/Atria spec set).

**1. Purpose**

This specification defines how Atria stores and references immutable artifacts (BPMN workflows, content packages, assessment definitions, raw standards payloads, exports, and redaction certificates). It ensures reproducibility, auditability, and safe handling of sensitive data.

**2. Artifact Model**

• Artifact: a byte sequence with an associated content_type (MIME) and optional metadata.

• artifact_hash: SHA-256 hash over the canonical stored bytes (hex-encoded or binary; consistent within a deployment).

• artifact_ref: an opaque reference string that can be resolved to bytes using the Artifact Store backend.

• Immutability: artifact bytes MUST NOT change once written. Replacing bytes MUST create a new artifact_ref and new artifact_hash.

**3. Reference Format**

v0 defines an opaque URL-like reference format. Implementations MAY choose concrete backends; the ref must be stable and portable within the tenant.

• artifact_ref format: atria-artifact://{tenant_id}/{namespace}/{artifact_hash}\[?meta...\]

• namespace examples: workflow, content, assessment, standards-raw, export, redaction

• artifact_hash MUST be SHA-256 of the stored bytes.

Implementations MAY store additional backend locator info (e.g., bucket/key) in a resolver map, but MUST preserve the stable atria-artifact:// ref for evidence and tables.

**4. Backend Requirements**

The Artifact Store backend SHALL support the following operations:

• Put(tenant_id, namespace, bytes, content_type, metadata) -\> (artifact_ref, artifact_hash).

• Get(artifact_ref) -\> bytes (or stream).

• Head(artifact_ref) -\> metadata (size, content_type, hash).

• Exists(artifact_ref) -\> boolean.

• Delete(artifact_ref) -\> allowed only under explicit erasure rules; otherwise prohibited.

**5. Access Control and Signed URLs**

• Artifact access MUST be authorized using Atria identity/roles/entitlements (Spec 0.3).

• When using object storage, implementations SHOULD serve artifacts via short-lived signed URLs (e.g., 60 seconds) to avoid proxying large bytes through the app server.

• Signed URLs MUST be scoped to tenant_id and namespace and MUST NOT be reusable across tenants.

**6. Confidentiality and Retention**

Artifacts MUST carry a confidentiality_level and retention_class consistent with evidence storage (Spec 0.2/0.3).

• workflow/content/assessment published artifacts are typically retention_class=long-term.

• raw standards payloads may be retention_class=standard and confidentiality_level=restricted.

• redaction certificates are retention_class=long-term and confidentiality_level=restricted.

**7. Erasure Behavior**

Artifact deletion is a last resort and is permitted only under explicit erasure rules (Spec 0.3 Section 16). When deletion is permitted:

• The system MUST create an erasure_action record and evidence.

• The system MUST replace any payload_ref pointing to the deleted artifact with a redaction certificate artifact_ref, preserving audit continuity without retaining PII bytes.
