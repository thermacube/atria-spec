-- Unified evidence view
-- This view unions all evidence partitions and projects decisions as evidence records.
-- NOTE: This is regenerated when new evidence partitions are created.

CREATE OR REPLACE VIEW evidence_all AS
SELECT
  e.evidence_id,
  e.tenant_id,
  CAST(e.message_type AS CHAR) AS message_type,
  e.subtype,
  e.subject_id,
  e.enrollment_context_id,
  e.activity_uuid,
  e.workflow_version,
  e.course_id,
  e.occurred_at,
  e.recorded_at,
  e.source_domain,
  e.actor_id,
  e.correlation_id,
  e.causation_id,
  e.payload_json,
  e.payload_ref,
  e.payload_hash,
  e.schema_version,
  e.confidentiality_level,
  e.retention_class
FROM evidence_2025_12 e

UNION ALL

SELECT
  d.decision_id AS evidence_id,
  NULL AS tenant_id,
  'DECISION' AS message_type,
  'DecisionRecorded' AS subtype,
  ec.learner_identity_id AS subject_id,
  d.enrollment_context_id,
  NULL AS activity_uuid,
  d.workflow_version,
  ec.course_id AS course_id,
  d.decided_at AS occurred_at,
  d.decided_at AS recorded_at,
  'ordin' AS source_domain,
  NULL AS actor_id,
  d.correlation_id,
  NULL AS causation_id,
  JSON_OBJECT(
    'decision_id', d.decision_id,
    'decision_type', d.decision_type,
    'decision_reason', d.decision_reason,
    'evaluated_evidence_ids', d.evaluated_evidence_ids,
    'decided_at', d.decided_at
  ) AS payload_json,
  NULL AS payload_ref,
  NULL AS payload_hash,
  '0.2' AS schema_version,
  'internal' AS confidentiality_level,
  'standard' AS retention_class
FROM decision d
JOIN enrollment_context ec ON ec.enrollment_context_id = d.enrollment_context_id;
