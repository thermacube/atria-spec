-- v1.3.0 adoption-contract hardening
CREATE TABLE IF NOT EXISTS rights_action_definitions (
 action VARCHAR(96) PRIMARY KEY, owner_module VARCHAR(64) NOT NULL, odrl_term VARCHAR(255) NULL, description TEXT NULL,
 status VARCHAR(32) NOT NULL DEFAULT 'active', created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT IGNORE INTO rights_action_definitions(action,owner_module,odrl_term,description) VALUES
('discover','platform',NULL,'Discover/list an object.'),('view','platform','read','View rendered representation.'),
('use','platform','use','Use object.'),('create','platform',NULL,'Create descendants.'),('edit','platform','modify','Modify source.'),
('reuse','platform',NULL,'Reuse object.'),('remix','platform','derive','Create derivative.'),('publish','platform',NULL,'Publish object.'),
('export','platform',NULL,'Export/package object.'),('manage','platform',NULL,'Manage governed scope.');
