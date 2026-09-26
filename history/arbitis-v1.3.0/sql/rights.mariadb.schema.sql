-- Shared Atria Rights/ReBAC module schema. MariaDB 10.5+ / InnoDB.
CREATE TABLE IF NOT EXISTS rights_entities (
 entity_id VARCHAR(255) PRIMARY KEY,
 entity_type VARCHAR(96) NOT NULL,
 owner_module VARCHAR(64) NOT NULL,
 attributes_json LONGTEXT NULL,
 status VARCHAR(32) NOT NULL DEFAULT 'active' CHECK(status IN('active','disabled','retired')),
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CHECK(attributes_json IS NULL OR JSON_VALID(attributes_json))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS rights_graph_meta (
 id TINYINT UNSIGNED PRIMARY KEY,
 revision BIGINT UNSIGNED NOT NULL DEFAULT 1,
 updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT IGNORE INTO rights_graph_meta(id,revision) VALUES(1,1);

CREATE TABLE IF NOT EXISTS rights_subject_closure (
 descendant_entity_id VARCHAR(255) NOT NULL,
 ancestor_entity_id VARCHAR(255) NOT NULL,
 depth SMALLINT UNSIGNED NOT NULL,
 path_count BIGINT UNSIGNED NOT NULL DEFAULT 1,
 PRIMARY KEY(descendant_entity_id,ancestor_entity_id),
 KEY idx_rights_subject_closure_ancestor(ancestor_entity_id,descendant_entity_id),
 CONSTRAINT fk_rights_sc_desc FOREIGN KEY(descendant_entity_id) REFERENCES rights_entities(entity_id) ON DELETE CASCADE,
 CONSTRAINT fk_rights_sc_anc FOREIGN KEY(ancestor_entity_id) REFERENCES rights_entities(entity_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rights_object_closure (
 descendant_entity_id VARCHAR(255) NOT NULL,
 ancestor_entity_id VARCHAR(255) NOT NULL,
 depth SMALLINT UNSIGNED NOT NULL,
 path_count BIGINT UNSIGNED NOT NULL DEFAULT 1,
 PRIMARY KEY(descendant_entity_id,ancestor_entity_id),
 KEY idx_rights_object_closure_ancestor(ancestor_entity_id,descendant_entity_id),
 CONSTRAINT fk_rights_oc_desc FOREIGN KEY(descendant_entity_id) REFERENCES rights_entities(entity_id) ON DELETE CASCADE,
 CONSTRAINT fk_rights_oc_anc FOREIGN KEY(ancestor_entity_id) REFERENCES rights_entities(entity_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS rights_action_definitions (
 action VARCHAR(96) PRIMARY KEY,
 owner_module VARCHAR(64) NOT NULL,
 odrl_term VARCHAR(255) NULL,
 description TEXT NULL,
 status VARCHAR(32) NOT NULL DEFAULT 'active' CHECK(status IN('active','retired')),
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO rights_action_definitions(action,owner_module,odrl_term,description) VALUES
 ('discover','platform',NULL,'Discover/list an object.'),
 ('view','platform','read','View rendered or human-facing representation.'),
 ('use','platform','use','Use an object in an authorized context.'),
 ('create','platform',NULL,'Create descendants within a governed scope.'),
 ('edit','platform','modify','Modify source-bearing state.'),
 ('reuse','platform',NULL,'Reuse an object without transformation.'),
 ('remix','platform','derive','Create an adapted derivative.'),
 ('publish','platform',NULL,'Publish within an authorized scope.'),
 ('export','platform',NULL,'Export/package an object.'),
 ('manage','platform',NULL,'Manage policy or governed scope.');

CREATE TABLE IF NOT EXISTS rights_relation_definitions (
 relation VARCHAR(96) PRIMARY KEY,
 actions_json LONGTEXT NOT NULL,
 subject_members_inherit TINYINT(1) NOT NULL DEFAULT 0,
 object_descendants_inherit TINYINT(1) NOT NULL DEFAULT 0,
 obligations_json LONGTEXT NULL,
 odrl_term VARCHAR(255) NULL,
 description TEXT NULL,
 CHECK(JSON_VALID(actions_json)), CHECK(obligations_json IS NULL OR JSON_VALID(obligations_json))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rights_policy_documents (
 policy_id VARCHAR(128) PRIMARY KEY,
 uid_uri VARCHAR(512) NULL UNIQUE,
 policy_type VARCHAR(32) NOT NULL DEFAULT 'set',
 profile_uri VARCHAR(512) NULL,
 label VARCHAR(255) NULL,
 human_terms_uri VARCHAR(512) NULL,
 issuer_entity_id VARCHAR(255) NULL,
 provenance_json LONGTEXT NULL,
 status VARCHAR(32) NOT NULL DEFAULT 'active' CHECK(status IN('draft','active','suspended','retired')),
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CHECK(provenance_json IS NULL OR JSON_VALID(provenance_json))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rights_relationships (
 relationship_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
 subject_entity_id VARCHAR(255) NOT NULL,
 relation VARCHAR(96) NOT NULL,
 object_entity_id VARCHAR(255) NOT NULL,
 effect VARCHAR(16) NOT NULL DEFAULT 'allow' CHECK(effect IN('allow','deny')),
 actions_json LONGTEXT NULL,
 effective_from DATETIME NULL,
 effective_until DATETIME NULL,
 conditions_json LONGTEXT NULL,
 obligations_json LONGTEXT NULL,
 source_policy_id VARCHAR(128) NULL,
 discoverable TINYINT(1) NOT NULL DEFAULT 1,
 status VARCHAR(32) NOT NULL DEFAULT 'active' CHECK(status IN('active','suspended','retired')),
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CONSTRAINT fk_rights_rel_subject FOREIGN KEY(subject_entity_id) REFERENCES rights_entities(entity_id) ON DELETE CASCADE,
 CONSTRAINT fk_rights_rel_object FOREIGN KEY(object_entity_id) REFERENCES rights_entities(entity_id) ON DELETE CASCADE,
 CONSTRAINT fk_rights_rel_def FOREIGN KEY(relation) REFERENCES rights_relation_definitions(relation) ON DELETE RESTRICT,
 CONSTRAINT fk_rights_rel_policy FOREIGN KEY(source_policy_id) REFERENCES rights_policy_documents(policy_id) ON DELETE SET NULL,
 CHECK(actions_json IS NULL OR JSON_VALID(actions_json)), CHECK(conditions_json IS NULL OR JSON_VALID(conditions_json)), CHECK(obligations_json IS NULL OR JSON_VALID(obligations_json)),
 UNIQUE KEY uq_rights_relation(subject_entity_id,relation,object_entity_id,effect,source_policy_id),
 KEY idx_rights_subject(subject_entity_id,relation,status), KEY idx_rights_object(object_entity_id,relation,status), KEY idx_rights_effective(effective_from,effective_until,status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO rights_relation_definitions(relation,actions_json,subject_members_inherit,object_descendants_inherit,description) VALUES
 ('member','[]',0,0,'Subject membership edge used for subject closure.'),
 ('contains','[]',0,0,'Object containment edge used for descendant inheritance.'),
 ('viewer','["discover","view"]',1,1,'May discover and view the object and descendants.'),
 ('user','["discover","view","use"]',1,1,'May discover, view, and use the object and descendants.'),
 ('editor','["discover","view","use","edit"]',1,1,'May edit the object and descendants.'),
 ('remixer','["discover","view","use","edit","reuse","remix"]',1,1,'May adapt and remix the object and descendants.'),
 ('publisher','["discover","view","use","create","edit","reuse","remix","publish"]',1,1,'May create/edit/publish within the governed object scope.'),
 ('exporter','["discover","view","use","export"]',1,1,'May export the object and descendants.'),
 ('manager','["discover","view","use","create","edit","reuse","remix","publish","export","manage"]',1,1,'Administrative rights over the object and descendants.'),
 ('licensee','["discover","view","use"]',1,1,'Default license relationship; relationship instances may specify narrower or broader actions.');


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
