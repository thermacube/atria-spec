-- Evidence partition for 2025-12
-- NOTE: Spec 0.3 requires time-partitioned physical tables named evidence_YYYY_MM.
-- This migration creates the current partition. Operations should create new partitions monthly.

CREATE TABLE IF NOT EXISTS evidence_2025_12 (
  evidence_id            CHAR(36) PRIMARY KEY,
  tenant_id              CHAR(36) NULL,
  message_type           ENUM('FACT','CLAIM','REQUEST') NOT NULL,
  subtype                VARCHAR(255) NOT NULL,
  subject_id             CHAR(36) NOT NULL,
  enrollment_context_id  CHAR(36) NULL,
  activity_uuid          CHAR(36) NULL,
  workflow_version       VARCHAR(64) NULL,
  course_id              CHAR(36) NULL,
  occurred_at            TIMESTAMP NOT NULL,
  recorded_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  source_domain          VARCHAR(255) NOT NULL,
  actor_id               CHAR(36) NULL,
  correlation_id         CHAR(36) NOT NULL,
  causation_id           CHAR(36) NULL,
  payload_json           JSON NULL,
  payload_ref            VARCHAR(1024) NULL,
  payload_hash           VARCHAR(128) NULL,
  schema_version         VARCHAR(64) NOT NULL,
  confidentiality_level  ENUM('public','internal','restricted') NOT NULL DEFAULT 'internal',
  retention_class        ENUM('standard','long-term','legal-hold') NOT NULL DEFAULT 'standard',

  -- NOTE: No DECISION rows are stored in evidence partitions; decisions live in the decision ledger.
  CHECK (message_type IN ('FACT','CLAIM','REQUEST')),

  KEY idx_ev_subject_recorded (subject_id, recorded_at),
  KEY idx_ev_enrollment_recorded (enrollment_context_id, recorded_at),
  KEY idx_ev_correlation (correlation_id),
  KEY idx_ev_subtype_recorded (subtype, recorded_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
