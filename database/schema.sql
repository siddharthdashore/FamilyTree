-- ============================================================================
-- VanshaSetu (वन्शसेतु) — Production Database Schema
-- Specification Reference: Docs/vanshasetu_master_specification.md
-- Compliance: HIPAA (45 CFR § 164.312), DISHA, ABDM, DPDP Act 2023
-- Security: Transparent Data Encryption (TDE), Field-Level AES-256-GCM, E2EE
-- Target DBMS: MySQL 8.0+ (InnoDB)
-- Collation: utf8mb4_unicode_ci
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `vanshasetu_db`
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE `vanshasetu_db`;

-- ----------------------------------------------------------------------------
-- 1. Master Citizens Table (ePHI & PII Hardened)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `citizens` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `vuid` CHAR(12) NOT NULL UNIQUE COMMENT 'Strictly 12 numeric digits: [100000000000, 999999999999]',
    `first_name` VARCHAR(60) NOT NULL,
    `middle_name` VARCHAR(60) DEFAULT NULL,
    `last_name` VARCHAR(60) NOT NULL,
    `gender` ENUM('Male', 'Female', 'Non-Binary', 'Transgender', 'Other') NOT NULL,
    `dob` DATE NOT NULL,
    
    -- Encrypted ePHI & Sensitive Attributes (AES-256-GCM Application Layer)
    -- Supports both plaintext decimal fallback and base64-encoded encrypted payload
    `height_cm` DECIMAL(5,2) DEFAULT NULL COMMENT 'Optional plaintext representation if unencrypted',
    `weight_kg` DECIMAL(5,2) DEFAULT NULL COMMENT 'Optional plaintext representation if unencrypted',
    `ephi_encrypted_data` TEXT DEFAULT NULL COMMENT 'AES-256-GCM encrypted envelope for height, weight, health attributes',
    `ephi_iv` CHAR(24) DEFAULT NULL COMMENT '12-byte initialization vector in base64',
    `ephi_auth_tag` CHAR(24) DEFAULT NULL COMMENT '16-byte authentication tag in base64',
    
    `caste` VARCHAR(80) DEFAULT NULL,
    `category` ENUM('GEN', 'OBC', 'SC', 'ST', 'EWS', 'Other') NOT NULL,
    
    -- Address fields (autofetched from live GPS and manually editable)
    `address_line1` VARCHAR(150),
    `address_line2` VARCHAR(150),
    `pin_code` CHAR(6) NOT NULL,
    `district` VARCHAR(80) NOT NULL,
    `state` VARCHAR(80) NOT NULL,
    `country` VARCHAR(60) DEFAULT 'India',
    `latitude` DECIMAL(10, 8),
    `longitude` DECIMAL(11, 8),
    
    -- Auditing & Lifecycle
    `is_claimed` BOOLEAN DEFAULT FALSE,
    `status` ENUM('Active', 'Missing', 'Deceased', 'Under_Investigation') DEFAULT 'Active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT `chk_vuid_12_digits` CHECK (`vuid` REGEXP '^[0-9]{12}$'),
    INDEX `idx_vuid` (`vuid`),
    INDEX `idx_name_dob` (`last_name`, `dob`),
    INDEX `idx_pincode` (`pin_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ENCRYPTION='Y';

-- ----------------------------------------------------------------------------
-- 2. Kinship Directed Graph Relationships Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `relationships` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `source_vuid` CHAR(12) NOT NULL,
    `target_vuid` CHAR(12) NOT NULL,
    `relationship_type` ENUM('Father', 'Mother', 'Spouse', 'Son', 'Daughter', 'Sibling', 'Guardian') NOT NULL,
    `verification_status` ENUM('Unverified', 'Mutual_Confirmed', 'Document_Backed', 'Conflicted') DEFAULT 'Unverified',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`source_vuid`) REFERENCES `citizens`(`vuid`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`target_vuid`) REFERENCES `citizens`(`vuid`) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY `uq_relationship` (`source_vuid`, `target_vuid`, `relationship_type`),
    INDEX `idx_source` (`source_vuid`),
    INDEX `idx_target` (`target_vuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ENCRYPTION='Y';

-- ----------------------------------------------------------------------------
-- 3. Tokenized Document Vault (Zero-Knowledge OCP / DigiLocker / API Setu)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `citizen_documents` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `vuid` CHAR(12) NOT NULL,
    `doc_type` ENUM('AADHAAR', 'PAN', 'VOTER_ID', 'DRIVING_LICENSE', 'PASSPORT', 'RATION_CARD', 'BIRTH_CERTIFICATE') NOT NULL,
    `doc_hash` CHAR(64) NOT NULL COMMENT 'Salted SHA-256 hash for zero-knowledge deduplication',
    `doc_masked_value` VARCHAR(30) NOT NULL COMMENT 'E.g., XXXX-XXXX-1234 or ABCDE****F',
    `issuer_authority` VARCHAR(120) DEFAULT 'DigiLocker / API Setu',
    `is_ocp_verified` BOOLEAN DEFAULT FALSE,
    `verified_at` DATETIME DEFAULT NULL,
    `raw_payload_encrypted` TEXT DEFAULT NULL COMMENT 'AES-256-GCM encrypted response metadata',
    `doc_iv` CHAR(24) DEFAULT NULL COMMENT '12-byte initialization vector in base64',
    `doc_auth_tag` CHAR(24) DEFAULT NULL COMMENT '16-byte authentication tag in base64',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`vuid`) REFERENCES `citizens`(`vuid`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_doc_hash` (`doc_hash`),
    UNIQUE KEY `uq_vuid_doctype` (`vuid`, `doc_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ENCRYPTION='Y';

-- ----------------------------------------------------------------------------
-- 4. Deduplication & Lineage Conflict Log (SIR / Missing Persons)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `duplicate_conflict_logs` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `flagged_vuid` CHAR(12) NOT NULL,
    `matched_vuid` CHAR(12) NOT NULL,
    `doc_type` ENUM('AADHAAR', 'PAN', 'VOTER_ID', 'DRIVING_LICENSE', 'PASSPORT', 'RATION_CARD', 'BIOMETRIC') NOT NULL,
    `conflict_reason` TEXT NOT NULL,
    `status` ENUM('Open', 'Investigating', 'Resolved_Fraud', 'Resolved_Merged', 'False_Positive') DEFAULT 'Open',
    `severity` ENUM('Low', 'Medium', 'High', 'Critical') DEFAULT 'High',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`flagged_vuid`) REFERENCES `citizens`(`vuid`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`matched_vuid`) REFERENCES `citizens`(`vuid`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_flagged` (`flagged_vuid`),
    INDEX `idx_matched` (`matched_vuid`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ENCRYPTION='Y';

-- ----------------------------------------------------------------------------
-- 5. HIPAA § 164.312(b) Immutable Audit Trail & Access Log
-- Cryptographically chained append-only log tracking all ePHI/PII interactions
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `audit_logs` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `actor_vuid` CHAR(12) DEFAULT NULL COMMENT 'VUID of citizen or officer performing action',
    `action` ENUM('CREATE', 'READ', 'UPDATE', 'DELETE', 'EXPORT', 'VERIFY_OCP', 'SIR_FLAG', 'EMERGENCY_ACCESS') NOT NULL,
    `resource_type` ENUM('CITIZEN', 'RELATIONSHIP', 'DOCUMENT', 'CONFLICT_LOG', 'TREE_GRAPH') NOT NULL,
    `resource_id` VARCHAR(100) NOT NULL COMMENT 'Identifier of accessed record',
    `ip_address` VARCHAR(45) NOT NULL COMMENT 'IPv4 or IPv6 of requester',
    `user_agent` VARCHAR(255) DEFAULT NULL,
    `status` ENUM('SUCCESS', 'UNAUTHORIZED', 'FORBIDDEN', 'FAILED') NOT NULL,
    `details` TEXT DEFAULT NULL COMMENT 'JSON-encoded access metadata without plaintext ePHI',
    `prev_log_hash` CHAR(64) DEFAULT NULL COMMENT 'Cryptographic hash chain pointing to preceding entry',
    `log_hash` CHAR(64) NOT NULL COMMENT 'SHA-256(id + actor + action + timestamp + prev_log_hash)',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_actor` (`actor_vuid`),
    INDEX `idx_action` (`action`),
    INDEX `idx_resource` (`resource_type`, `resource_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ENCRYPTION='Y';
