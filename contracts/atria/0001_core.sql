-- Atria LMS - Canonical Schema (Core) - Generated from Atria Engineering Spec 0.3 (rev line)
-- Target: MariaDB / InnoDB
-- Notes:
--  * UUIDs are stored as CHAR(36) for implementation simplicity (may be migrated to BINARY(16) later).
--  * Evidence partitions are created in separate migration(s).
--  * Decisions are stored in the decision ledger (no dual-write into evidence partitions).

SET sql_mode = 'STRICT_ALL_TABLES';

-- ---------- Identity ----------
CREATE TABLE IF NOT EXISTS identity (
  identity_id           CHAR(36) PRIMARY KEY,
  external_identity_id  VARCHAR(255) NULL,
  identity_type         ENUM('learner','instructor','admin','system') NOT NULL,
  display_name          VARCHAR(255) NOT NULL,
  email                 VARCHAR(255) NULL,
  status                ENUM('active','suspended','deactivated') NOT NULL DEFAULT 'active',
  created_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_identity_external (external_identity_id),
  KEY idx_identity_type_status (identity_type, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS identity_change_log (
  identity_change_id  CHAR(36) PRIMARY KEY,
  identity_id         CHAR(36) NOT NULL,
  attribute_name      VARCHAR(255) NOT NULL,
  prior_value_ref     TEXT NULL,
  new_value_ref       TEXT NULL,
  authority_source    ENUM('idp','sis','admin','system') NOT NULL,
  changed_at          TIMESTAMP NOT NULL,
  evidence_id         CHAR(36) NULL, -- logical reference to evidence_id (no FK due to partitioning)
  KEY idx_identity_change_identity (identity_id, changed_at),
  CONSTRAINT fk_identity_change_identity
    FOREIGN KEY (identity_id) REFERENCES identity(identity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- Roles / Entitlements ----------
CREATE TABLE IF NOT EXISTS role (
  role_id      CHAR(36) PRIMARY KEY,
  role_name    VARCHAR(128) NOT NULL,
  role_scope   ENUM('global','course','activity') NOT NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_role_name (role_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS role_assignment (
  role_assignment_id  CHAR(36) PRIMARY KEY,
  identity_id         CHAR(36) NOT NULL,
  role_id             CHAR(36) NOT NULL,
  scope_type          ENUM('tenant','course','activity') NOT NULL,
  scope_id            CHAR(36) NULL,
  assigned_at         TIMESTAMP NOT NULL,
  assigned_by         CHAR(36) NOT NULL,
  revoked_at          TIMESTAMP NULL,
  KEY idx_role_assignment_identity (identity_id, role_id, revoked_at),
  KEY idx_role_assignment_scope (scope_type, scope_id),
  CONSTRAINT fk_role_assignment_identity FOREIGN KEY (identity_id) REFERENCES identity(identity_id),
  CONSTRAINT fk_role_assignment_role FOREIGN KEY (role_id) REFERENCES role(role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS entitlement (
  entitlement_id     CHAR(36) PRIMARY KEY,
  identity_id        CHAR(36) NOT NULL,
  entitlement_type   ENUM('view_content','submit_assessment','grade_assessment','issue_credential','admin_override','progress_course') NOT NULL,
  scope_type         ENUM('tenant','course','enrollment_context','activity') NOT NULL,
  scope_id           CHAR(36) NOT NULL,
  granted_at         TIMESTAMP NOT NULL,
  granted_by         CHAR(36) NOT NULL,
  revoked_at         TIMESTAMP NULL,
  evidence_id        CHAR(36) NULL, -- logical reference (no FK)
  KEY idx_entitlement_identity (identity_id, entitlement_type, revoked_at),
  KEY idx_entitlement_scope (scope_type, scope_id),
  CONSTRAINT fk_entitlement_identity FOREIGN KEY (identity_id) REFERENCES identity(identity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- Course / Workflow / Activity Catalog ----------
CREATE TABLE IF NOT EXISTS course (
  course_id     CHAR(36) PRIMARY KEY,
  created_by    CHAR(36) NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status        ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
  CONSTRAINT fk_course_created_by FOREIGN KEY (created_by) REFERENCES identity(identity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS workflow_definition (
  workflow_definition_id  CHAR(36) PRIMARY KEY,
  course_id               CHAR(36) NOT NULL,
  workflow_version        VARCHAR(64) NOT NULL,
  bpmn_ref                VARCHAR(1024) NOT NULL,
  bpmn_hash               VARCHAR(128) NOT NULL,
  published_at            TIMESTAMP NOT NULL,
  published_by            CHAR(36) NOT NULL,
  UNIQUE KEY uq_workflow_course_version (course_id, workflow_version),
  KEY idx_workflow_course (course_id),
  CONSTRAINT fk_workflow_course FOREIGN KEY (course_id) REFERENCES course(course_id),
  CONSTRAINT fk_workflow_published_by FOREIGN KEY (published_by) REFERENCES identity(identity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS activity (
  activity_uuid   CHAR(36) PRIMARY KEY,
  activity_type   ENUM('content','assessment','tool') NOT NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS workflow_activity_map (
  workflow_definition_id  CHAR(36) NOT NULL,
  activity_uuid           CHAR(36) NOT NULL,
  bpmn_task_id            VARCHAR(255) NOT NULL,
  PRIMARY KEY (workflow_definition_id, activity_uuid),
  KEY idx_workflow_activity_task (workflow_definition_id, bpmn_task_id),
  CONSTRAINT fk_wam_workflow FOREIGN KEY (workflow_definition_id) REFERENCES workflow_definition(workflow_definition_id),
  CONSTRAINT fk_wam_activity FOREIGN KEY (activity_uuid) REFERENCES activity(activity_uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Activity resolution resolves an activity_uuid to a concrete immutable version reference.
CREATE TABLE IF NOT EXISTS activity_resolution (
  activity_resolution_id   CHAR(36) PRIMARY KEY,
  workflow_definition_id   CHAR(36) NOT NULL,
  activity_uuid            CHAR(36) NOT NULL,
  resolution_type          ENUM('content','assessment','tool') NOT NULL,
  content_version_id       CHAR(36) NULL,
  assessment_version_id    CHAR(36) NULL,
  tool_ref                 VARCHAR(1024) NULL,
  created_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_activity_resolution (workflow_definition_id, activity_uuid),
  KEY idx_activity_resolution_workflow (workflow_definition_id),
  CONSTRAINT fk_ar_workflow FOREIGN KEY (workflow_definition_id) REFERENCES workflow_definition(workflow_definition_id),
  CONSTRAINT fk_ar_activity FOREIGN KEY (activity_uuid) REFERENCES activity(activity_uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- Enrollment Context ----------
CREATE TABLE IF NOT EXISTS enrollment_context (
  enrollment_context_id  CHAR(36) PRIMARY KEY,
  learner_identity_id    CHAR(36) NOT NULL,
  course_id              CHAR(36) NOT NULL,
  workflow_version       VARCHAR(64) NOT NULL,
  status                 ENUM('active','completed','suspended') NOT NULL DEFAULT 'active',
  created_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closed_at              TIMESTAMP NULL,
  KEY idx_enrollment_learner (learner_identity_id),
  KEY idx_enrollment_course (course_id),
  CONSTRAINT fk_enrollment_learner FOREIGN KEY (learner_identity_id) REFERENCES identity(identity_id),
  CONSTRAINT fk_enrollment_course FOREIGN KEY (course_id) REFERENCES course(course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- Decision Ledger ----------
CREATE TABLE IF NOT EXISTS decision (
  decision_id              CHAR(36) PRIMARY KEY,
  enrollment_context_id    CHAR(36) NOT NULL,
  workflow_version         VARCHAR(64) NOT NULL,
  decision_type            ENUM('advance','complete','remediate','suspend','no_op') NOT NULL,
  decision_reason          VARCHAR(1024) NOT NULL,
  evaluated_evidence_ids   JSON NOT NULL,
  decided_at               TIMESTAMP NOT NULL,
  correlation_id           CHAR(36) NOT NULL,
  KEY idx_decision_enrollment (enrollment_context_id, decided_at),
  KEY idx_decision_correlation (correlation_id),
  CONSTRAINT fk_decision_enrollment FOREIGN KEY (enrollment_context_id) REFERENCES enrollment_context(enrollment_context_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- Progression Snapshot ----------
CREATE TABLE IF NOT EXISTS progression_state (
  enrollment_context_id  CHAR(36) PRIMARY KEY,
  current_activity_uuid  CHAR(36) NULL,
  state_payload          JSON NOT NULL,
  last_decision_id       CHAR(36) NOT NULL,
  updated_at             TIMESTAMP NOT NULL,
  CONSTRAINT fk_progression_last_decision FOREIGN KEY (last_decision_id) REFERENCES decision(decision_id),
  CONSTRAINT fk_progression_activity FOREIGN KEY (current_activity_uuid) REFERENCES activity(activity_uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- Requests ----------
CREATE TABLE IF NOT EXISTS request (
  request_id     CHAR(36) PRIMARY KEY,
  request_type   VARCHAR(255) NOT NULL,
  requested_by   CHAR(36) NOT NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_request_requested_by FOREIGN KEY (requested_by) REFERENCES identity(identity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS request_state (
  request_state_id  CHAR(36) PRIMARY KEY,
  request_id        CHAR(36) NOT NULL,
  state             ENUM('requested','accepted','in_progress','completed','rejected','failed_retryable','failed_terminal') NOT NULL,
  occurred_at        TIMESTAMP NOT NULL,
  evidence_id        CHAR(36) NULL, -- logical reference
  KEY idx_request_state_request (request_id, occurred_at),
  CONSTRAINT fk_request_state_request FOREIGN KEY (request_id) REFERENCES request(request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- Assessments ----------
CREATE TABLE IF NOT EXISTS assessment_definition (
  assessment_id  CHAR(36) PRIMARY KEY,
  created_by     CHAR(36) NOT NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status         ENUM('draft','published','deprecated') NOT NULL DEFAULT 'draft',
  CONSTRAINT fk_assessment_created_by FOREIGN KEY (created_by) REFERENCES identity(identity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS assessment_version (
  assessment_version_id  CHAR(36) PRIMARY KEY,
  assessment_id          CHAR(36) NOT NULL,
  version                VARCHAR(64) NOT NULL,
  published_at           TIMESTAMP NOT NULL,
  published_by           CHAR(36) NOT NULL,
  definition_ref         VARCHAR(1024) NOT NULL,
  definition_hash        VARCHAR(128) NOT NULL,
  standard_type          ENUM('QTI','SCORM','native','other') NOT NULL,
  standard_version       VARCHAR(64) NULL,
  status                 ENUM('published','deprecated') NOT NULL DEFAULT 'published',
  UNIQUE KEY uq_assessment_version (assessment_id, version),
  KEY idx_assessment_published (assessment_id, published_at),
  CONSTRAINT fk_assessment_version_assessment FOREIGN KEY (assessment_id) REFERENCES assessment_definition(assessment_id),
  CONSTRAINT fk_assessment_version_published_by FOREIGN KEY (published_by) REFERENCES identity(identity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS assessment_attempt_counter (
  enrollment_context_id  CHAR(36) NOT NULL,
  activity_uuid          CHAR(36) NOT NULL,
  next_attempt_number    INT NOT NULL DEFAULT 1,
  updated_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (enrollment_context_id, activity_uuid),
  CONSTRAINT fk_aac_enrollment FOREIGN KEY (enrollment_context_id) REFERENCES enrollment_context(enrollment_context_id),
  CONSTRAINT fk_aac_activity FOREIGN KEY (activity_uuid) REFERENCES activity(activity_uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS assessment_attempt (
  attempt_id            CHAR(36) PRIMARY KEY,
  enrollment_context_id CHAR(36) NOT NULL,
  activity_uuid         CHAR(36) NOT NULL,
  assessment_id         CHAR(36) NOT NULL,
  assessment_version_id CHAR(36) NOT NULL,
  attempt_number        INT NOT NULL,
  status                ENUM('started','submitted','completed','exited','timed_out','invalidated') NOT NULL,
  started_at            TIMESTAMP NOT NULL,
  submitted_at          TIMESTAMP NULL,
  completed_at          TIMESTAMP NULL,
  created_by            ENUM('learner','system','admin') NOT NULL DEFAULT 'learner',
  correlation_id        CHAR(36) NOT NULL,
  KEY idx_attempt_enrollment_activity_started (enrollment_context_id, activity_uuid, started_at),
  KEY idx_attempt_enrollment_activity_number (enrollment_context_id, activity_uuid, attempt_number),
  KEY idx_attempt_correlation (correlation_id),
  CONSTRAINT fk_attempt_enrollment FOREIGN KEY (enrollment_context_id) REFERENCES enrollment_context(enrollment_context_id),
  CONSTRAINT fk_attempt_activity FOREIGN KEY (activity_uuid) REFERENCES activity(activity_uuid),
  CONSTRAINT fk_attempt_assessment FOREIGN KEY (assessment_id) REFERENCES assessment_definition(assessment_id),
  CONSTRAINT fk_attempt_assessment_version FOREIGN KEY (assessment_version_id) REFERENCES assessment_version(assessment_version_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS assessment_submission (
  submission_id      CHAR(36) PRIMARY KEY,
  attempt_id         CHAR(36) NOT NULL,
  submitted_at       TIMESTAMP NOT NULL,
  submission_ref     VARCHAR(1024) NOT NULL,
  submission_hash    VARCHAR(128) NOT NULL,
  content_type       VARCHAR(128) NOT NULL,
  bytes              BIGINT NOT NULL,
  schema_version     VARCHAR(64) NOT NULL,
  KEY idx_submission_attempt (attempt_id, submitted_at),
  CONSTRAINT fk_submission_attempt FOREIGN KEY (attempt_id) REFERENCES assessment_attempt(attempt_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS assessment_score (
  score_id              CHAR(36) PRIMARY KEY,
  attempt_id            CHAR(36) NOT NULL,
  computed_at           TIMESTAMP NOT NULL,
  score_value           DECIMAL(18,6) NULL,
  score_ref             VARCHAR(1024) NULL,
  grading_schema_version VARCHAR(64) NOT NULL,
  computed_by           ENUM('system','human','mixed') NOT NULL,
  is_pass               BOOLEAN NULL,
  correlation_id         CHAR(36) NOT NULL,
  KEY idx_score_attempt (attempt_id, computed_at),
  KEY idx_score_correlation (correlation_id),
  CONSTRAINT fk_score_attempt FOREIGN KEY (attempt_id) REFERENCES assessment_attempt(attempt_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS assessment_score_supersession (
  supersession_id       CHAR(36) PRIMARY KEY,
  attempt_id            CHAR(36) NOT NULL,
  superseded_score_id   CHAR(36) NOT NULL,
  superseding_score_id  CHAR(36) NOT NULL,
  reason_code           VARCHAR(255) NOT NULL,
  created_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  evidence_id           CHAR(36) NULL,
  KEY idx_supersession_attempt (attempt_id),
  KEY idx_supersession_scores (superseded_score_id, superseding_score_id),
  CONSTRAINT fk_supersession_attempt FOREIGN KEY (attempt_id) REFERENCES assessment_attempt(attempt_id),
  CONSTRAINT fk_superseded_score FOREIGN KEY (superseded_score_id) REFERENCES assessment_score(score_id),
  CONSTRAINT fk_superseding_score FOREIGN KEY (superseding_score_id) REFERENCES assessment_score(score_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS activity_attempt_policy (
  policy_id         CHAR(36) PRIMARY KEY,
  course_id         CHAR(36) NOT NULL,
  activity_uuid     CHAR(36) NOT NULL,
  workflow_version  VARCHAR(64) NOT NULL,
  max_attempts      INT NULL,
  count_rule        ENUM('highest','latest','average','first') NOT NULL DEFAULT 'latest',
  cooldown_seconds  INT NULL,
  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_policy_course_activity (course_id, activity_uuid, workflow_version),
  CONSTRAINT fk_policy_course FOREIGN KEY (course_id) REFERENCES course(course_id),
  CONSTRAINT fk_policy_activity FOREIGN KEY (activity_uuid) REFERENCES activity(activity_uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- Content ----------
CREATE TABLE IF NOT EXISTS content (
  content_id     CHAR(36) PRIMARY KEY,
  created_by     CHAR(36) NOT NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  content_type   ENUM('html','video','document','package','other') NOT NULL,
  status         ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
  CONSTRAINT fk_content_created_by FOREIGN KEY (created_by) REFERENCES identity(identity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS content_version (
  content_version_id  CHAR(36) PRIMARY KEY,
  content_id          CHAR(36) NOT NULL,
  version             VARCHAR(64) NOT NULL,
  published_at        TIMESTAMP NOT NULL,
  published_by        CHAR(36) NOT NULL,
  artifact_ref        VARCHAR(1024) NOT NULL,
  artifact_hash       VARCHAR(128) NOT NULL,
  bytes               BIGINT NOT NULL,
  mime_type           VARCHAR(128) NOT NULL,
  standard_type       ENUM('CC','SCORM','QTI','native','other') NULL,
  standard_version    VARCHAR(64) NULL,
  status              ENUM('published','deprecated') NOT NULL DEFAULT 'published',
  UNIQUE KEY uq_content_version (content_id, version),
  KEY idx_content_published (content_id, published_at),
  CONSTRAINT fk_content_version_content FOREIGN KEY (content_id) REFERENCES content(content_id),
  CONSTRAINT fk_content_version_published_by FOREIGN KEY (published_by) REFERENCES identity(identity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS content_resolution (
  content_id                CHAR(36) PRIMARY KEY,
  current_content_version_id CHAR(36) NOT NULL,
  updated_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  updated_by               CHAR(36) NOT NULL,
  KEY idx_content_resolution_current (current_content_version_id),
  CONSTRAINT fk_content_resolution_content FOREIGN KEY (content_id) REFERENCES content(content_id),
  CONSTRAINT fk_content_resolution_version FOREIGN KEY (current_content_version_id) REFERENCES content_version(content_version_id),
  CONSTRAINT fk_content_resolution_updated_by FOREIGN KEY (updated_by) REFERENCES identity(identity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS content_access (
  content_access_id     CHAR(36) PRIMARY KEY,
  enrollment_context_id CHAR(36) NOT NULL,
  activity_uuid         CHAR(36) NOT NULL,
  content_id            CHAR(36) NOT NULL,
  content_version_id    CHAR(36) NOT NULL,
  accessed_at           TIMESTAMP NOT NULL,
  delivery_method       ENUM('direct','proxied','signed_url') NOT NULL,
  correlation_id        CHAR(36) NOT NULL,
  artifact_hash         VARCHAR(128) NULL,
  KEY idx_content_access_enrollment (enrollment_context_id, accessed_at),
  KEY idx_content_access_content_version (content_id, content_version_id),
  KEY idx_content_access_correlation (correlation_id),
  CONSTRAINT fk_content_access_enrollment FOREIGN KEY (enrollment_context_id) REFERENCES enrollment_context(enrollment_context_id),
  CONSTRAINT fk_content_access_activity FOREIGN KEY (activity_uuid) REFERENCES activity(activity_uuid),
  CONSTRAINT fk_content_access_content FOREIGN KEY (content_id) REFERENCES content(content_id),
  CONSTRAINT fk_content_access_version FOREIGN KEY (content_version_id) REFERENCES content_version(content_version_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- Compliance: Legal Hold / Erasure (minimal) ----------
CREATE TABLE IF NOT EXISTS legal_hold (
  legal_hold_id   CHAR(36) PRIMARY KEY,
  hold_reason     VARCHAR(1024) NOT NULL,
  created_by      CHAR(36) NOT NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  active          BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_legal_hold_created_by FOREIGN KEY (created_by) REFERENCES identity(identity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS erasure_action (
  erasure_action_id  CHAR(36) PRIMARY KEY,
  subject_id         CHAR(36) NOT NULL,
  requested_by       CHAR(36) NOT NULL,
  requested_at       TIMESTAMP NOT NULL,
  status             ENUM('requested','in_progress','completed','rejected') NOT NULL DEFAULT 'requested',
  completed_at       TIMESTAMP NULL,
  reason_code        VARCHAR(255) NULL,
  KEY idx_erasure_subject (subject_id, requested_at),
  CONSTRAINT fk_erasure_requested_by FOREIGN KEY (requested_by) REFERENCES identity(identity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
