-- ============================================================================
-- VanshaSetu (वन्शसेतु) — Multi-Generational Seed Data
-- Specification Reference: Docs/vanshasetu_master_specification.md Section 5.3
-- ============================================================================

USE `vanshasetu_db`;

-- Disable foreign key checks for clean re-seeding
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE `duplicate_conflict_logs`;
TRUNCATE TABLE `citizen_documents`;
TRUNCATE TABLE `relationships`;
TRUNCATE TABLE `citizens`;
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- 1. Insert Multi-Generational Citizens (Generation 1 through 4)
-- ----------------------------------------------------------------------------
INSERT INTO `citizens` (
    `vuid`, `first_name`, `middle_name`, `last_name`, `gender`, `dob`,
    `height_cm`, `weight_kg`, `caste`, `category`,
    `address_line1`, `address_line2`, `pin_code`, `district`, `state`, `country`,
    `latitude`, `longitude`, `is_claimed`, `status`
) VALUES
-- Gen 1: Paternal Grandfather
('109284729102', 'Kailash', 'Prasad', 'Sharma', 'Male', '1948-03-12',
 168.0, 65.0, 'Brahmin', 'GEN',
 '42 Heritage Enclave', 'Civil Lines', '452001', 'Indore', 'Madhya Pradesh', 'India',
 22.7196, 75.8577, TRUE, 'Active'),

-- Gen 2: Parents
('510928340192', 'Ramesh', 'Chandra', 'Sharma', 'Male', '1972-07-24',
 175.5, 74.0, 'Brahmin', 'GEN',
 '104 Lotus Heights', 'Vijay Nagar', '452010', 'Indore', 'Madhya Pradesh', 'India',
 22.7533, 75.8937, TRUE, 'Active'),

('510928340193', 'Sunita', NULL, 'Sharma', 'Female', '1975-11-05',
 160.0, 62.0, 'Brahmin', 'GEN',
 '104 Lotus Heights', 'Vijay Nagar', '452010', 'Indore', 'Madhya Pradesh', 'India',
 22.7533, 75.8937, TRUE, 'Active'),

-- Gen 3: Self (Aarav Sharma) & Spouse
('284910293847', 'Aarav', NULL, 'Sharma', 'Male', '1998-05-18',
 178.0, 71.0, 'Brahmin', 'GEN',
 'Flat 302, Green Meadows', 'HSR Layout Sector 2', '560102', 'Bengaluru Urban', 'Karnataka', 'India',
 12.9116, 77.6499, TRUE, 'Active'),

('928174019284', 'Pooja', 'Kumari', 'Sharma', 'Female', '2000-09-22',
 165.0, 56.0, 'Brahmin', 'GEN',
 'Flat 302, Green Meadows', 'HSR Layout Sector 2', '560102', 'Bengaluru Urban', 'Karnataka', 'India',
 12.9116, 77.6499, TRUE, 'Active'),

-- Gen 4: Child (Vihaan Sharma)
('819204918274', 'Vihaan', NULL, 'Sharma', 'Male', '2024-01-15',
 54.0, 4.2, 'Brahmin', 'GEN',
 'Flat 302, Green Meadows', 'HSR Layout Sector 2', '560102', 'Bengaluru Urban', 'Karnataka', 'India',
 12.9116, 77.6499, TRUE, 'Active'),

-- Missing Relative (Case for SIR Anomaly Workflow)
('391029485710', 'Deepak', 'Kumar', 'Sharma', 'Male', '1976-02-14',
 172.0, 68.0, 'Brahmin', 'GEN',
 'Old Market Ward 4', 'Ganj', '452002', 'Indore', 'Madhya Pradesh', 'India',
 22.7150, 75.8600, FALSE, 'Missing');

-- ----------------------------------------------------------------------------
-- 2. Insert Directed Kinship Relationships
-- ----------------------------------------------------------------------------
INSERT INTO `relationships` (`source_vuid`, `target_vuid`, `relationship_type`, `verification_status`) VALUES
-- Kailash -> Ramesh (Father)
('109284729102', '510928340192', 'Father', 'Document_Backed'),

-- Ramesh <-> Sunita (Spouse)
('510928340192', '510928340193', 'Spouse', 'Mutual_Confirmed'),
('510928340193', '510928340192', 'Spouse', 'Mutual_Confirmed'),

-- Ramesh -> Aarav (Father), Sunita -> Aarav (Mother)
('510928340192', '284910293847', 'Father', 'Mutual_Confirmed'),
('510928340193', '284910293847', 'Mother', 'Mutual_Confirmed'),

-- Aarav <-> Pooja (Spouse)
('284910293847', '928174019284', 'Spouse', 'Mutual_Confirmed'),
('928174019284', '284910293847', 'Spouse', 'Mutual_Confirmed'),

-- Aarav -> Vihaan (Father), Pooja -> Vihaan (Mother)
('284910293847', '819204918274', 'Father', 'Mutual_Confirmed'),
('928174019284', '819204918274', 'Mother', 'Mutual_Confirmed'),

-- Ramesh -> Deepak (Sibling - Missing)
('510928340192', '391029485710', 'Sibling', 'Unverified');

-- ----------------------------------------------------------------------------
-- 3. Insert Tokenized Zero-Knowledge Documents
-- ----------------------------------------------------------------------------
-- Salted SHA-256 tokens using HASH_SALT: VANSHA_SETU_SECURE_SALT_9841
INSERT INTO `citizen_documents` (
    `vuid`, `doc_type`, `doc_hash`, `doc_masked_value`, `issuer_authority`, `is_ocp_verified`, `verified_at`
) VALUES
-- Aarav Sharma (Aadhaar & PAN)
('284910293847', 'AADHAAR', SHA2('894729104820VANSHA_SETU_SECURE_SALT_9841', 256), 'XXXXXXXX4820', 'DigiLocker / UIDAI', TRUE, '2026-01-10 10:30:00'),
('284910293847', 'PAN', SHA2('ABCDE1234FVANSHA_SETU_SECURE_SALT_9841', 256), 'ABCDE****F', 'Income Tax Department / NSDL', TRUE, '2026-01-10 10:32:00'),

-- Ramesh Sharma (Aadhaar & Voter ID)
('510928340192', 'AADHAAR', SHA2('592019482710VANSHA_SETU_SECURE_SALT_9841', 256), 'XXXXXXXX2710', 'DigiLocker / UIDAI', TRUE, '2025-11-14 14:15:00'),
('510928340192', 'VOTER_ID', SHA2('MP0492817294VANSHA_SETU_SECURE_SALT_9841', 256), 'MP04****7294', 'Election Commission of India', TRUE, '2025-11-14 14:20:00'),

-- Vihaan Sharma (Birth Certificate)
('819204918274', 'BIRTH_CERTIFICATE', SHA2('BC2024KA891029VANSHA_SETU_SECURE_SALT_9841', 256), 'BC2024****1029', 'Municipal Corporation Bengaluru', TRUE, '2026-02-01 09:00:00');

-- ----------------------------------------------------------------------------
-- 4. Sample Duplicate Conflict Log Entry (SIR Demonstration)
-- ----------------------------------------------------------------------------
INSERT INTO `duplicate_conflict_logs` (
    `flagged_vuid`, `matched_vuid`, `doc_type`, `conflict_reason`, `status`, `severity`
) VALUES (
    '284910293847', '391029485710', 'RATION_CARD',
    'Cross-district ration quota claimed simultaneously in Indore and Bengaluru',
    'Open', 'High'
);
