/**
 * VanshaSetu — DDL Syntax & Constraint Static Validator
 * Validates database/schema.sql and database/seed.sql against:
 * 1. HIPAA (45 CFR § 164.312) Audit Trail table existence.
 * 2. Transparent Data Encryption (TDE - ENCRYPTION='Y') directives.
 * 3. ePHI field-level encryption columns (ephi_encrypted_data, iv, auth_tag).
 * 4. 12-digit numeric constraint definition.
 * 5. Foreign key references and CASCADE definitions.
 * 6. Index coverage (vuid, name_dob, pincode, source/target, doc_hash, actor/action).
 * 7. Collation and engine (InnoDB, utf8mb4_unicode_ci).
 * 8. Validates seed data VUIDs adhere to ^[0-9]{12}$.
 */

const fs = require('fs');
const path = require('path');

const schemaPath = path.join(__dirname, 'schema.sql');
const seedPath = path.join(__dirname, 'seed.sql');

console.log('🔒 Validating VanshaSetu Security, HIPAA & Database DDL Scripts...\n');

let errors = [];
let passed = 0;

function assert(condition, message) {
    if (condition) {
        console.log(`  ✅ PASS: ${message}`);
        passed++;
    } else {
        console.error(`  ❌ FAIL: ${message}`);
        errors.push(message);
    }
}

// 1. Validate schema.sql existence and contents
if (!fs.existsSync(schemaPath)) {
    console.error('schema.sql not found!');
    process.exit(1);
}
const schemaSql = fs.readFileSync(schemaPath, 'utf8');

assert(schemaSql.includes('CREATE DATABASE IF NOT EXISTS `vanshasetu_db`'), 'Database creation statement exists');
assert(schemaSql.includes('utf8mb4_unicode_ci'), 'Collation utf8mb4_unicode_ci specified');
assert(schemaSql.includes('CREATE TABLE IF NOT EXISTS `citizens`'), 'citizens table defined');
assert(schemaSql.includes('CREATE TABLE IF NOT EXISTS `relationships`'), 'relationships table defined');
assert(schemaSql.includes('CREATE TABLE IF NOT EXISTS `citizen_documents`'), 'citizen_documents table defined');
assert(schemaSql.includes('CREATE TABLE IF NOT EXISTS `duplicate_conflict_logs`'), 'duplicate_conflict_logs table defined');
assert(schemaSql.includes('CREATE TABLE IF NOT EXISTS `audit_logs`'), 'HIPAA § 164.312(b) audit_logs table defined');

// 2. Validate HIPAA & Field-Level Encryption Columns
assert(schemaSql.includes('`ephi_encrypted_data`'), 'ephi_encrypted_data column present for medical/health data');
assert(schemaSql.includes('`ephi_iv`') && schemaSql.includes('`ephi_auth_tag`'), 'AES-256-GCM IV and Auth Tag columns present for ePHI');
assert(schemaSql.includes('`log_hash`') && schemaSql.includes('`prev_log_hash`'), 'Cryptographic hash chain present in audit_logs');

// 3. Validate TDE Encryption directives
const encryptionMatches = (schemaSql.match(/ENCRYPTION='Y'/g) || []).length;
assert(encryptionMatches >= 5, `Transparent Data Encryption (TDE ENCRYPTION='Y') configured on all 5 tables (Found ${encryptionMatches})`);

// 4. Validate VUID constraints
assert(
    schemaSql.includes("CONSTRAINT `chk_vuid_12_digits` CHECK (`vuid` REGEXP '^[0-9]{12}$')"),
    'Strict 12-digit numeric CHECK constraint enforced on citizens.vuid'
);

// 5. Validate Engine
const innoDbMatches = (schemaSql.match(/ENGINE=InnoDB/g) || []).length;
assert(innoDbMatches >= 5, `All 5 core tables configured with InnoDB engine (Found ${innoDbMatches})`);

// 6. Validate Indexes
assert(schemaSql.includes('INDEX `idx_vuid` (`vuid`)'), 'idx_vuid index present on citizens');
assert(schemaSql.includes('INDEX `idx_name_dob` (`last_name`, `dob`)'), 'idx_name_dob composite index present');
assert(schemaSql.includes('INDEX `idx_pincode` (`pin_code`)'), 'idx_pincode index present');
assert(schemaSql.includes('INDEX `idx_source` (`source_vuid`)'), 'idx_source index present on relationships');
assert(schemaSql.includes('INDEX `idx_target` (`target_vuid`)'), 'idx_target index present on relationships');
assert(schemaSql.includes('INDEX `idx_doc_hash` (`doc_hash`)'), 'idx_doc_hash index present on citizen_documents');
assert(schemaSql.includes('INDEX `idx_actor` (`actor_vuid`)'), 'idx_actor index present on audit_logs');
assert(schemaSql.includes('INDEX `idx_resource` (`resource_type`, `resource_id`)'), 'idx_resource index present on audit_logs');

// 7. Validate Foreign Keys & CASCADE rules
assert(schemaSql.includes('REFERENCES `citizens`(`vuid`) ON DELETE CASCADE'), 'Foreign keys configured with ON DELETE CASCADE');

// 8. Validate seed.sql VUID integrity
if (fs.existsSync(seedPath)) {
    const seedSql = fs.readFileSync(seedPath, 'utf8');
    const vuidMatches = seedSql.match(/'\d{10,14}'/g) || [];
    let invalidVuids = [];
    vuidMatches.forEach(v => {
        const clean = v.replace(/'/g, '');
        if (!/^[0-9]{12}$/.test(clean)) {
            invalidVuids.push(clean);
        }
    });
    assert(invalidVuids.length === 0, `All seeded VUIDs strictly match 12 digits (Found ${vuidMatches.length} valid VUIDs)`);
}

console.log(`\n=========================================`);
console.log(`Results: ${passed} passed, ${errors.length} failed`);
console.log(`=========================================`);

if (errors.length > 0) {
    process.exit(1);
} else {
    console.log('🛡️  All Security, HIPAA & Database DDL constraints verified successfully!\n');
}
