-- ============================================================================
-- VanshaSetu (वन्शसेतु) — Database Constraint Verification Suite
-- Specification Reference: Docs/vanshasetu_master_specification.md Section 3
-- ============================================================================

USE `vanshasetu_db`;

-- Test 1: Verify collation of database
SELECT 
    DEFAULT_CHARACTER_SET_NAME, 
    DEFAULT_COLLATION_NAME 
FROM INFORMATION_SCHEMA.SCHEMATA 
WHERE SCHEMA_NAME = 'vanshasetu_db';

-- Test 2: Verify all 7 core tables exist with InnoDB engine and TDE encryption
SELECT TABLE_NAME, ENGINE, TABLE_COLLATION, TABLE_ROWS, CREATE_OPTIONS 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'vanshasetu_db'
ORDER BY TABLE_NAME;

-- Test 3: Verify 12-digit CHECK constraint definition on citizens
SELECT 
    CONSTRAINT_NAME, 
    CHECK_CLAUSE 
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
WHERE CONSTRAINT_SCHEMA = 'vanshasetu_db';

-- Test 4: Verify indexes across citizens, relationships, documents, conflicts, audit, education, marriages
SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME, NON_UNIQUE 
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'vanshasetu_db' 
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- Test 5: Verify Foreign Key Constraints with CASCADE actions
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    CONSTRAINT_NAME, 
    REFERENCED_TABLE_NAME, 
    REFERENCED_COLUMN_NAME 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'vanshasetu_db' AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- Test 6: Verify ePHI Encryption Columns & Gotra/Marital Columns on citizens
SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'vanshasetu_db' AND TABLE_NAME = 'citizens'
  AND COLUMN_NAME IN ('vuid', 'gotra', 'religion', 'marital_status', 'blood_group', 'death_date', 'ephi_encrypted_data', 'ephi_iv', 'ephi_auth_tag')
ORDER BY COLUMN_NAME;
