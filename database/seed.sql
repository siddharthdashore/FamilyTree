-- ============================================================================
-- VanshaSetu (वन्शसेतु) — Multi-Generational Seed Data
-- Specification Reference: Docs/vanshasetu_master_specification.md Section 5.3
-- ============================================================================

USE `vanshasetu_db`;

-- Disable foreign key checks for clean re-seeding
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE `audit_logs`;
TRUNCATE TABLE `marriages`;
TRUNCATE TABLE `citizen_education`;
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
    `height_cm`, `weight_kg`, `caste`, `category`, `gotra`, `religion`, `marital_status`, `blood_group`,
    `address_line1`, `address_line2`, `pin_code`, `district`, `state`, `country`,
    `latitude`, `longitude`, `is_claimed`, `status`
) VALUES
-- Gen 1: Paternal Grandparents (Kailash Prasad Sharma & Savitri Devi Sharma)
('109284729102', 'Kailash', 'Prasad', 'Sharma', 'Male', '1948-03-12',
 168.0, 65.0, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Married', 'O+',
 '42 Heritage Enclave', 'Civil Lines', '452001', 'Indore', 'Madhya Pradesh', 'India',
 22.7196, 75.8577, TRUE, 'Active'),

('109284729103', 'Savitri', 'Devi', 'Sharma', 'Female', '1950-06-18',
 158.0, 58.0, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Married', 'A+',
 '42 Heritage Enclave', 'Civil Lines', '452001', 'Indore', 'Madhya Pradesh', 'India',
 22.7196, 75.8577, TRUE, 'Active'),

-- Gen 2: Parents & Couples (Ramesh & Sunita, Deepak & Meena, Vikram & Anita)
('510928340192', 'Ramesh', 'Chandra', 'Sharma', 'Male', '1972-07-24',
 175.5, 74.0, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Married', 'B+',
 '104 Lotus Heights', 'Vijay Nagar', '452010', 'Indore', 'Madhya Pradesh', 'India',
 22.7533, 75.8937, TRUE, 'Active'),

('510928340193', 'Sunita', NULL, 'Sharma', 'Female', '1975-11-05',
 160.0, 62.0, 'Brahmin', 'GEN', 'Kashyap', 'Hindu', 'Married', 'A+',
 '104 Lotus Heights', 'Vijay Nagar', '452010', 'Indore', 'Madhya Pradesh', 'India',
 22.7533, 75.8937, TRUE, 'Active'),

('391029485710', 'Deepak', 'Kumar', 'Sharma', 'Male', '1976-02-14',
 172.0, 68.0, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Married', 'O-',
 'Old Market Ward 4', 'Ganj', '452002', 'Indore', 'Madhya Pradesh', 'India',
 22.7150, 75.8600, FALSE, 'Missing'),

('391029485711', 'Meena', NULL, 'Sharma', 'Female', '1978-04-10',
 162.0, 59.0, 'Brahmin', 'GEN', 'Gautam', 'Hindu', 'Married', 'B+',
 'Old Market Ward 4', 'Ganj', '452002', 'Indore', 'Madhya Pradesh', 'India',
 22.7150, 75.8600, TRUE, 'Active'),

('510928340194', 'Vikram', NULL, 'Sharma', 'Male', '1980-09-12',
 176.0, 72.0, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Married', 'AB+',
 '202 Royal Palms', 'Palasia', '452001', 'Indore', 'Madhya Pradesh', 'India',
 22.7200, 75.8700, TRUE, 'Active'),

('510928340195', 'Anita', NULL, 'Sharma', 'Female', '1982-12-01',
 164.0, 57.0, 'Brahmin', 'GEN', 'Shandilya', 'Hindu', 'Married', 'O+',
 '202 Royal Palms', 'Palasia', '452001', 'Indore', 'Madhya Pradesh', 'India',
 22.7200, 75.8700, TRUE, 'Active'),

-- Gen 3: Children & Spouses
('284910293847', 'Aarav', NULL, 'Sharma', 'Male', '1998-05-18',
 178.0, 71.0, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Married', 'B+',
 'Flat 302, Green Meadows', 'HSR Layout Sector 2', '560102', 'Bengaluru Urban', 'Karnataka', 'India',
 12.9116, 77.6499, TRUE, 'Active'),

('928174019284', 'Pooja', 'Kumari', 'Sharma', 'Female', '2000-09-22',
 165.0, 56.0, 'Brahmin', 'GEN', 'Vashishta', 'Hindu', 'Married', 'AB+',
 'Flat 302, Green Meadows', 'HSR Layout Sector 2', '560102', 'Bengaluru Urban', 'Karnataka', 'India',
 12.9116, 77.6499, TRUE, 'Active'),

('710293849103', 'Ananya', NULL, 'Sharma', 'Female', '2001-08-14',
 163.0, 54.0, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Married', 'A+',
 '104 Lotus Heights', 'Vijay Nagar', '452010', 'Indore', 'Madhya Pradesh', 'India',
 22.7533, 75.8937, TRUE, 'Active'),

('710293849102', 'Rohan', NULL, 'Verma', 'Male', '1996-04-10',
 177.0, 70.0, 'Kshatriya', 'GEN', 'Vatsa', 'Hindu', 'Married', 'O+',
 '55 M.G. Road', 'Freeganj', '456001', 'Ujjain', 'Madhya Pradesh', 'India',
 23.1765, 75.7885, TRUE, 'Active'),

('284910293849', 'Ishaan', NULL, 'Sharma', 'Male', '2004-03-30',
 175.0, 68.0, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Married', 'B+',
 '104 Lotus Heights', 'Vijay Nagar', '452010', 'Indore', 'Madhya Pradesh', 'India',
 22.7533, 75.8937, TRUE, 'Active'),

('710293849104', 'Priya', NULL, 'Patel', 'Female', '1997-12-02',
 161.0, 55.0, 'Kurmi', 'OBC', 'Kashyap', 'Hindu', 'Married', 'AB-',
 '78 Navlakha Main Road', 'Navlakha', '452001', 'Indore', 'Madhya Pradesh', 'India',
 22.7000, 75.8700, TRUE, 'Active'),

('391029485712', 'Priyanshu', NULL, 'Sharma', 'Male', '2002-01-20',
 174.0, 66.0, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Single', 'O+',
 'Old Market Ward 4', 'Ganj', '452002', 'Indore', 'Madhya Pradesh', 'India',
 22.7150, 75.8600, TRUE, 'Active'),

('391029485713', 'Riya', NULL, 'Sharma', 'Female', '2005-11-15',
 160.0, 52.0, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Single', 'A+',
 'Old Market Ward 4', 'Ganj', '452002', 'Indore', 'Madhya Pradesh', 'India',
 22.7150, 75.8600, TRUE, 'Active'),

('510928340196', 'Kabir', NULL, 'Sharma', 'Male', '2006-07-04',
 172.0, 63.0, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Single', 'B+',
 '202 Royal Palms', 'Palasia', '452001', 'Indore', 'Madhya Pradesh', 'India',
 22.7200, 75.8700, TRUE, 'Active'),

('510928340197', 'Diya', NULL, 'Sharma', 'Female', '2008-05-22',
 158.0, 49.0, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Single', 'O+',
 '202 Royal Palms', 'Palasia', '452001', 'Indore', 'Madhya Pradesh', 'India',
 22.7200, 75.8700, TRUE, 'Active'),

-- Gen 4: Children (Vihaan & Advait)
('819204918274', 'Vihaan', NULL, 'Sharma', 'Male', '2024-01-15',
 54.0, 4.2, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Single', 'B+',
 'Flat 302, Green Meadows', 'HSR Layout Sector 2', '560102', 'Bengaluru Urban', 'Karnataka', 'India',
 12.9116, 77.6499, TRUE, 'Active'),

('819204918275', 'Advait', NULL, 'Sharma', 'Male', '2025-06-10',
 48.0, 3.8, 'Brahmin', 'GEN', 'Bharadwaj', 'Hindu', 'Single', 'O+',
 'Flat 302, Green Meadows', 'HSR Layout Sector 2', '560102', 'Bengaluru Urban', 'Karnataka', 'India',
 12.9116, 77.6499, TRUE, 'Active');

-- ----------------------------------------------------------------------------
-- 2. Insert Directed Kinship Relationships
-- ----------------------------------------------------------------------------
INSERT INTO `relationships` (`source_vuid`, `target_vuid`, `relationship_type`, `verification_status`) VALUES
-- Spouses
('109284729102', '109284729103', 'Spouse', 'Mutual_Confirmed'),
('109284729103', '109284729102', 'Spouse', 'Mutual_Confirmed'),

('510928340192', '510928340193', 'Spouse', 'Mutual_Confirmed'),
('510928340193', '510928340192', 'Spouse', 'Mutual_Confirmed'),

('391029485710', '391029485711', 'Spouse', 'Unverified'),
('391029485711', '391029485710', 'Spouse', 'Unverified'),

('510928340194', '510928340195', 'Spouse', 'Mutual_Confirmed'),
('510928340195', '510928340194', 'Spouse', 'Mutual_Confirmed'),

('284910293847', '928174019284', 'Spouse', 'Mutual_Confirmed'),
('928174019284', '284910293847', 'Spouse', 'Mutual_Confirmed'),

('710293849103', '710293849102', 'Spouse', 'Mutual_Confirmed'),
('710293849102', '710293849103', 'Spouse', 'Mutual_Confirmed'),

('284910293849', '710293849104', 'Spouse', 'Mutual_Confirmed'),
('710293849104', '284910293849', 'Spouse', 'Mutual_Confirmed'),

-- Gen 1 -> Gen 2 (Kailash & Savitri -> 3 Sons)
('109284729102', '510928340192', 'Father', 'Document_Backed'),
('109284729103', '510928340192', 'Mother', 'Document_Backed'),

('109284729102', '391029485710', 'Father', 'Document_Backed'),
('109284729103', '391029485710', 'Mother', 'Document_Backed'),

('109284729102', '510928340194', 'Father', 'Document_Backed'),
('109284729103', '510928340194', 'Mother', 'Document_Backed'),

-- Gen 2 -> Gen 3 (Ramesh & Sunita -> 3 Kids)
('510928340192', '284910293847', 'Father', 'Mutual_Confirmed'),
('510928340193', '284910293847', 'Mother', 'Mutual_Confirmed'),

('510928340192', '710293849103', 'Father', 'Mutual_Confirmed'),
('510928340193', '710293849103', 'Mother', 'Mutual_Confirmed'),

('510928340192', '284910293849', 'Father', 'Mutual_Confirmed'),
('510928340193', '284910293849', 'Mother', 'Mutual_Confirmed'),

-- Gen 2 -> Gen 3 (Deepak & Meena -> 2 Kids)
('391029485710', '391029485712', 'Father', 'Unverified'),
('391029485711', '391029485712', 'Mother', 'Mutual_Confirmed'),

('391029485710', '391029485713', 'Father', 'Unverified'),
('391029485711', '391029485713', 'Mother', 'Mutual_Confirmed'),

-- Gen 2 -> Gen 3 (Vikram & Anita -> 2 Kids)
('510928340194', '510928340196', 'Father', 'Mutual_Confirmed'),
('510928340195', '510928340196', 'Mother', 'Mutual_Confirmed'),

('510928340194', '510928340197', 'Father', 'Mutual_Confirmed'),
('510928340195', '510928340197', 'Mother', 'Mutual_Confirmed'),

-- Gen 3 -> Gen 4 (Aarav & Pooja -> 2 Kids)
('284910293847', '819204918274', 'Father', 'Mutual_Confirmed'),
('928174019284', '819204918274', 'Mother', 'Mutual_Confirmed'),

('284910293847', '819204918275', 'Father', 'Mutual_Confirmed'),
('928174019284', '819204918275', 'Mother', 'Mutual_Confirmed');

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

-- ----------------------------------------------------------------------------
-- 5. Indian Education & Professional Qualifications
-- ----------------------------------------------------------------------------
INSERT INTO `citizen_education` (
    `vuid`, `qualification_level`, `degree_name`, `institution`, `year_of_passing`, `occupation_sector`, `profession_title`
) VALUES
-- Aarav Sharma: Senior Software Engineer
('284910293847', 'Bachelors', 'B.Tech in Computer Science', 'Indian Institute of Technology Bombay', 2020, 'Private_IT_Corporate', 'Senior Distributed Systems Engineer'),

-- Pooja Sharma: Research Scientist
('928174019284', 'Masters', 'M.Sc in Biotechnology', 'Indian Institute of Science Bengaluru', 2022, 'Healthcare', 'Clinical Research Specialist'),

-- Ramesh Sharma: Bank Manager
('510928340192', 'Masters', 'Master of Commerce (M.Com)', 'Devi Ahilya Vishwavidyalaya Indore', 1994, 'Banking_Finance', 'Chief Branch Manager'),

-- Sunita Sharma: School Teacher
('510928340193', 'Bachelors', 'Bachelor of Arts (B.A.) in Literature', 'Government Holkar Science College', 1996, 'Education_Research', 'Senior Secondary Teacher'),

-- Kailash Sharma: Retired Civil Service Officer
('109284729102', 'Bachelors', 'Bachelor of Arts (B.A.) in Public Administration', 'Vikram University Ujjain', 1968, 'Government', 'Retired District Treasury Officer');

-- ----------------------------------------------------------------------------
-- 6. Civil Marriages Registry
-- ----------------------------------------------------------------------------
INSERT INTO `marriages` (
    `marriage_reg_number`, `husband_vuid`, `wife_vuid`, `marriage_date`, `venue`, `registrar_office`, `status`
) VALUES
('MAR-1996-0482', '510928340192', '510928340193', '1996-05-12', 'Indore, MP', 'Municipal Corporation Indore Marriage Registrar', 'Registered'),
('MAR-2023-1092', '284910293847', '928174019284', '2023-11-28', 'Bengaluru, Karnataka', 'Bruhat Bengaluru Mahanagara Palike (BBMP) Registrar', 'Registered');

-- ----------------------------------------------------------------------------
-- 7. HIPAA § 164.312(b) Immutable Genesis Audit Trail
-- ----------------------------------------------------------------------------
INSERT INTO `audit_logs` (
    `actor_vuid`, `action`, `resource_type`, `resource_id`, `ip_address`, `user_agent`, `status`, `details`, `prev_log_hash`, `log_hash`, `created_at`
) VALUES
('000000000000', 'GENESIS_BLOCK', 'SYSTEM_CORE', 'SYSTEM_INITIALIZATION', '127.0.0.1', 'VanshaSetu Provisioner', 'SUCCESS', '{"note":"System Genesis Block"}', '0000000000000000000000000000000000000000000000000000000000000000', SHA2('0000000000000000000000000000000000000000000000000000000000000000:000000000000:GENESIS_BLOCK:SYSTEM_INITIALIZATION', 256), '2026-01-01 00:00:00'),
('510928340192', 'CREATE', 'CITIZEN', '284910293847', '127.0.0.1', 'VanshaSetu Mobile', 'SUCCESS', '{"vuid":"284910293847","action":"Initial Birth Registration"}', SHA2('0000000000000000000000000000000000000000000000000000000000000000:000000000000:GENESIS_BLOCK:SYSTEM_INITIALIZATION', 256), SHA2('GENESIS:284910293847:CREATE:CITIZEN', 256), '2026-01-01 00:05:00');
