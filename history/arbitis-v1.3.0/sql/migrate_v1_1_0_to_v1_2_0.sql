-- Rights/ReBAC v1.1.0 -> v1.2.0 concurrency/performance hardening
START TRANSACTION;
ALTER TABLE rights_subject_closure ADD COLUMN path_count BIGINT UNSIGNED NOT NULL DEFAULT 1 AFTER depth;
ALTER TABLE rights_object_closure ADD COLUMN path_count BIGINT UNSIGNED NOT NULL DEFAULT 1 AFTER depth;
COMMIT;

-- Commerce-backed/consumable authorization state. Commerce may issue entitlements; Rights atomically reserves consumption.
CREATE TABLE IF NOT EXISTS rights_entitlements (
 entitlement_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
 subject_entity_id VARCHAR(255) NOT NULL,
 object_entity_id VARCHAR(255) NOT NULL,
 action VARCHAR(96) NOT NULL,
 entitlement_key VARCHAR(128) NULL,
 remaining_uses BIGINT UNSIGNED NULL COMMENT 'NULL means unlimited',
 effective_from DATETIME NULL,
 effective_until DATETIME NULL,
 status VARCHAR(32) NOT NULL DEFAULT 'active' CHECK(status IN('active','suspended','retired')),
 source_ref VARCHAR(255) NULL,
 metadata_json LONGTEXT NULL,
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CONSTRAINT fk_rights_ent_subject FOREIGN KEY(subject_entity_id) REFERENCES rights_entities(entity_id) ON DELETE CASCADE,
 CONSTRAINT fk_rights_ent_object FOREIGN KEY(object_entity_id) REFERENCES rights_entities(entity_id) ON DELETE CASCADE,
 CHECK(metadata_json IS NULL OR JSON_VALID(metadata_json)),
 KEY idx_rights_ent_lookup(subject_entity_id,object_entity_id,action,status,effective_from,effective_until),
 KEY idx_rights_ent_key(entitlement_key,status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rights_obligation_reservations (
 reservation_id CHAR(36) PRIMARY KEY,
 idempotency_key VARCHAR(191) NOT NULL UNIQUE,
 entitlement_id BIGINT UNSIGNED NOT NULL,
 subject_entity_id VARCHAR(255) NOT NULL,
 object_entity_id VARCHAR(255) NOT NULL,
 action VARCHAR(96) NOT NULL,
 quantity BIGINT UNSIGNED NOT NULL DEFAULT 1,
 status VARCHAR(32) NOT NULL DEFAULT 'reserved' CHECK(status IN('reserved','committed','released','expired')),
 expires_at DATETIME NOT NULL,
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CONSTRAINT fk_rights_res_ent FOREIGN KEY(entitlement_id) REFERENCES rights_entitlements(entitlement_id) ON DELETE RESTRICT,
 KEY idx_rights_res_expiry(status,expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- REQUIRED POST-MIGRATION STEP:
-- Run rights_rebuild_closures() once before enabling structural graph writes.
-- It computes exact path_count values for all active member/contains edges.
