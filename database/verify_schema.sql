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

-- Test 2: Verify all 4 tables exist
SELECT TABLE_NAME, ENGINE, TABLE_COLLATION, TABLE_ROWS 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'vanshasetu_db';

-- Test 3: Verify 12-digit CHECK constraint definition on citizens
SELECT 
    CONSTRAINT_NAME, 
    CHECK_CLAUSE 
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
WHERE CONSTRAINT_SCHEMA = 'vanshasetu_db';

-- Test 4: Verify indexes on citizens, relationships, citizen_documents, duplicate_conflict_logs
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
WHERE TABLE_SCHEMA = 'vanshasetu_db' AND REFERENCED_TABLE_NAME IS NOT NULL;
