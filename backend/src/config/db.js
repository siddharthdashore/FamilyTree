const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Standard MySQL 8.0 Connection Pool
const mysqlPool = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    user: process.env.DB_USER || 'vanshasetu_user',
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'vanshasetu_db',
    waitForConnections: true,
    connectionLimit: parseInt(process.env.DB_CONNECTION_LIMIT || '15', 10),
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 10000
});

// ============================================================================
// Resilient In-Memory Storage Engine
// Automatically activates when MySQL 8.0 daemon is not reachable (local dev / offline demo).
// Seeds data from database/seed.sql (single source of truth).
// Persists runtime modifications back to seed.sql for cross-restart durability.
// ============================================================================

const inMemoryStore = {
    citizens: [],
    relationships: [],
    citizen_documents: [],
    duplicate_conflict_logs: [],
    citizen_education: [],
    marriages: [],
    audit_logs: []
};

const SEED_SQL_PATH = path.join(__dirname, '../../../database/seed.sql');

let lastMtimeMs = 0;

// ============================================================================
// SQL Parser — extracts INSERT rows from seed.sql into inMemoryStore
// ============================================================================

function parseSeedSQL(sqlContent) {
    const citizens = [];
    const relationships = [];

    // ---- Parse citizens INSERT block ----
    const citizenInsertMatch = sqlContent.match(
        /INSERT INTO `citizens`\s*\([^)]+\)\s*VALUES\s*([\s\S]*?);/
    );
    if (citizenInsertMatch) {
        const valuesBlock = citizenInsertMatch[1];
        // Match each row tuple: ('val1', 'val2', ...)
        const rowRegex = /\(([^)]+)\)/g;
        let rowMatch;
        let idCounter = 1;
        while ((rowMatch = rowRegex.exec(valuesBlock)) !== null) {
            const rawCols = rowMatch[1];
            // Parse comma-separated values, respecting quotes
            const vals = [];
            let current = '';
            let inQuote = false;
            for (let i = 0; i < rawCols.length; i++) {
                const ch = rawCols[i];
                if (ch === "'" && (i === 0 || rawCols[i - 1] !== '\\')) {
                    inQuote = !inQuote;
                } else if (ch === ',' && !inQuote) {
                    vals.push(current.trim());
                    current = '';
                } else {
                    current += ch;
                }
            }
            vals.push(current.trim()); // last value

            // Map values to citizen fields
            // Column order: vuid, first_name, middle_name, last_name, gender, dob,
            //   caste, category, gotra, religion, marital_status, blood_group,
            //   address_line1, pin_code, district, state, country, is_claimed, status
            const parseVal = (v) => {
                if (v === 'NULL' || v === 'null') return null;
                if (v === 'TRUE' || v === 'true') return 1;
                if (v === 'FALSE' || v === 'false') return 0;
                return v;
            };

            if (vals.length >= 19) {
                citizens.push({
                    id: idCounter++,
                    vuid: parseVal(vals[0]),
                    first_name: parseVal(vals[1]),
                    middle_name: parseVal(vals[2]),
                    last_name: parseVal(vals[3]),
                    gender: parseVal(vals[4]),
                    dob: parseVal(vals[5]),
                    caste: parseVal(vals[6]),
                    category: parseVal(vals[7]),
                    gotra: parseVal(vals[8]),
                    religion: parseVal(vals[9]),
                    marital_status: parseVal(vals[10]),
                    blood_group: parseVal(vals[11]),
                    address_line1: parseVal(vals[12]),
                    pin_code: parseVal(vals[13]),
                    district: parseVal(vals[14]),
                    state: parseVal(vals[15]),
                    country: parseVal(vals[16]),
                    is_claimed: parseVal(vals[17]),
                    status: parseVal(vals[18]),
                    created_at: new Date('2026-01-01T00:00:00.000Z')
                });
            }
        }
    }

    // ---- Parse relationships INSERT block ----
    const relInsertMatch = sqlContent.match(
        /INSERT INTO `relationships`\s*\([^)]+\)\s*VALUES\s*([\s\S]*?);/
    );
    if (relInsertMatch) {
        const valuesBlock = relInsertMatch[1];
        const rowRegex = /\(([^)]+)\)/g;
        let rowMatch;
        while ((rowMatch = rowRegex.exec(valuesBlock)) !== null) {
            const rawCols = rowMatch[1];
            const vals = [];
            let current = '';
            let inQuote = false;
            for (let i = 0; i < rawCols.length; i++) {
                const ch = rawCols[i];
                if (ch === "'" && (i === 0 || rawCols[i - 1] !== '\\')) {
                    inQuote = !inQuote;
                } else if (ch === ',' && !inQuote) {
                    vals.push(current.trim());
                    current = '';
                } else {
                    current += ch;
                }
            }
            vals.push(current.trim());

            // Column order: source_vuid, target_vuid, relationship_type, verification_status
            if (vals.length >= 4) {
                relationships.push({
                    source: vals[0],
                    target: vals[1],
                    type: vals[2],
                    status: vals[3]
                });
            }
        }
    }

    return { citizens, relationships };
}

// ============================================================================
// SQL Writer — serializes inMemoryStore back to seed.sql format
// ============================================================================

function generateSeedSQL() {
    let sql = `-- ============================================================================
-- VanshaSetu (वन्शसेतु) — Multi-Generational Seed Data (10-Layer Hierarchy)
-- ============================================================================

USE \`vanshasetu_db\`;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE \`audit_logs\`;
TRUNCATE TABLE \`marriages\`;
TRUNCATE TABLE \`citizen_education\`;
TRUNCATE TABLE \`duplicate_conflict_logs\`;
TRUNCATE TABLE \`citizen_documents\`;
TRUNCATE TABLE \`relationships\`;
TRUNCATE TABLE \`citizens\`;
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- 1. Insert 10-Layer Citizens
-- ----------------------------------------------------------------------------
INSERT INTO \`citizens\` (
    \`vuid\`, \`first_name\`, \`middle_name\`, \`last_name\`, \`gender\`, \`dob\`,
    \`caste\`, \`category\`, \`gotra\`, \`religion\`, \`marital_status\`, \`blood_group\`,
    \`address_line1\`, \`pin_code\`, \`district\`, \`state\`, \`country\`,
    \`is_claimed\`, \`status\`
) VALUES
`;

    const citizenValues = inMemoryStore.citizens.map(c => {
        const mid = c.middle_name ? `'${c.middle_name}'` : 'NULL';
        const dob = typeof c.dob === 'string' ? c.dob : (c.dob ? new Date(c.dob).toISOString().split('T')[0] : '1970-01-01');
        return `('${c.vuid}', '${c.first_name}', ${mid}, '${c.last_name}', '${c.gender}', '${dob}', '${c.caste || 'Brahmin'}', '${c.category || 'GEN'}', '${c.gotra || 'Kashyap'}', '${c.religion || 'Hindu'}', '${c.marital_status || 'Single'}', '${c.blood_group || 'O+'}', '${c.address_line1 || ''}', '${c.pin_code || '452001'}', '${c.district || 'Indore'}', '${c.state || 'Madhya Pradesh'}', '${c.country || 'India'}', TRUE, '${c.status || 'Active'}')`;
    });

    sql += citizenValues.join(',\n') + ';\n\n';

    if (inMemoryStore.relationships.length > 0) {
        sql += `-- ----------------------------------------------------------------------------
-- 2. Insert Lineage Kinship Relationships
-- ----------------------------------------------------------------------------
INSERT INTO \`relationships\` (
    \`source_vuid\`, \`target_vuid\`, \`relationship_type\`, \`verification_status\`
) VALUES
`;
        const relValues = inMemoryStore.relationships.map(r => {
            const source = r.source_vuid || r.source || '';
            const target = r.target_vuid || r.target || '';
            const type = r.relationship_type || r.type || '';
            const status = r.verification_status || r.status || 'Mutual_Confirmed';
            return `('${source}', '${target}', '${type}', '${status}')`;
        });

        sql += relValues.join(',\n') + ';\n';
    }

    return sql;
}

function saveInMemoryStore() {
    try {
        const sql = generateSeedSQL();
        fs.writeFileSync(SEED_SQL_PATH, sql, 'utf8');
        if (fs.existsSync(SEED_SQL_PATH)) {
            lastMtimeMs = fs.statSync(SEED_SQL_PATH).mtimeMs;
        }
    } catch (err) {
        console.error('Failed to persist inMemoryStore to seed.sql:', err);
    }
}

function loadInMemoryStore() {
    try {
        if (fs.existsSync(SEED_SQL_PATH)) {
            const stat = fs.statSync(SEED_SQL_PATH);
            if (lastMtimeMs > 0 && Math.abs(stat.mtimeMs - lastMtimeMs) < 50) return;
            lastMtimeMs = stat.mtimeMs;
            const sqlContent = fs.readFileSync(SEED_SQL_PATH, 'utf8');
            const parsed = parseSeedSQL(sqlContent);

            if (parsed.citizens.length > 0) {
                inMemoryStore.citizens = parsed.citizens;
            }
            if (parsed.relationships.length > 0) {
                inMemoryStore.relationships = parsed.relationships;
            }
            // citizen_documents, audit_logs, etc. are runtime-only (not in seed.sql)
            // They start empty each session unless we add SQL sections for them later
        }
    } catch (err) {
        console.error('Failed to load inMemoryStore from seed.sql:', err);
    }
}

loadInMemoryStore();

/**
 * In-memory query simulator matching SQL syntax used by routes.
 */
function executeInMemoryQuery(sql, params = []) {
    loadInMemoryStore();
    const s = sql.trim().replace(/\s+/g, ' ');

    // 1. SELECT id FROM citizens WHERE vuid = ? LIMIT 1
    if (s.includes('FROM citizens WHERE vuid = ?')) {
        const vuid = String(params[0]);
        const match = inMemoryStore.citizens.filter(c => c.vuid === vuid);
        return [match, []];
    }

    // 2. INSERT INTO citizens (...) VALUES (...)
    if (s.startsWith('INSERT INTO citizens')) {
        const colMatch = s.match(/INSERT INTO citizens\s*\(([^)]+)\)/i);
        const newCitizen = {
            id: inMemoryStore.citizens.length + 1,
            category: 'GEN',
            religion: 'Hindu',
            marital_status: 'Single',
            country: 'India',
            is_claimed: 1,
            status: 'Active',
            created_at: new Date()
        };

        if (colMatch) {
            const cols = colMatch[1].split(',').map(c => c.trim().toLowerCase());
            cols.forEach((col, idx) => {
                newCitizen[col] = params[idx];
            });
        }
        if (newCitizen.vuid) newCitizen.vuid = String(newCitizen.vuid);

        inMemoryStore.citizens.push(newCitizen);
        saveInMemoryStore();
        return [{ insertId: newCitizen.id, affectedRows: 1 }, []];
    }

    // 3. SELECT ... FROM citizens WHERE vuid = ?
    if (s.includes('FROM citizens') && s.includes('WHERE vuid = ?')) {
        const vuid = String(params[0]);
        const match = inMemoryStore.citizens.filter(c => c.vuid === vuid);
        return [match, []];
    }

    // 3b. SELECT ... FROM citizens (all records or demographics)
    if (s.includes('FROM citizens') && !s.includes('WHERE')) {
        return [inMemoryStore.citizens.slice(), []];
    }

    // 4. SELECT vuid FROM citizens WHERE vuid IN (?, ?)
    if (s.includes('FROM citizens WHERE vuid IN')) {
        const vuids = Array.isArray(params[0]) ? params[0] : params;
        const matches = inMemoryStore.citizens
            .filter(c => vuids.map(String).includes(String(c.vuid)))
            .map(c => ({ vuid: c.vuid }));
        return [matches, []];
    }

    // 5. SELECT ... FROM citizens c WHERE c.vuid IN (?)
    if (s.includes('FROM citizens c WHERE c.vuid IN') || (s.includes('FROM citizens') && s.includes('IN (?)'))) {
        const vuids = Array.isArray(params[0]) ? params[0] : params;
        const matches = inMemoryStore.citizens
            .filter(c => vuids.map(String).includes(String(c.vuid)))
            .map(c => {
                const isVerified = inMemoryStore.citizen_documents.some(d => d.vuid === c.vuid && d.is_ocp_verified);
                return {
                    vuid: c.vuid,
                    name: `${c.first_name} ${c.middle_name ? c.middle_name + ' ' : ''}${c.last_name}`.trim(),
                    gender: c.gender,
                    dob: c.dob,
                    caste: c.caste,
                    category: c.category,
                    gotra: c.gotra,
                    religion: c.religion,
                    marital_status: c.marital_status,
                    blood_group: c.blood_group,
                    district: c.district,
                    state: c.state,
                    is_claimed: c.is_claimed,
                    status: c.status,
                    is_verified: isVerified ? 1 : 0
                };
            });
        return [matches, []];
    }

    // 6. SELECT ... FROM relationships
    if (s.includes('FROM relationships')) {
        let edges = inMemoryStore.relationships.map(r => ({
            source: String(r.source_vuid || r.source || ''),
            target: String(r.target_vuid || r.target || ''),
            type: r.relationship_type || r.type || '',
            status: r.verification_status || r.status || 'Mutual_Confirmed'
        }));
        if (s.includes('WHERE source_vuid = ? OR target_vuid = ?')) {
            const vuid = String(params[0]);
            edges = edges.filter(r => r.source === vuid || r.target === vuid);
        }
        return [edges, []];
    }

    // 7. INSERT INTO relationships (...) ON DUPLICATE KEY UPDATE ...
    if (s.startsWith('INSERT INTO relationships')) {
        const [source, target, type, status] = params;
        const existingIdx = inMemoryStore.relationships.findIndex(
            r => r.source === String(source) && r.target === String(target) && r.type === type
        );
        if (existingIdx >= 0) {
            inMemoryStore.relationships[existingIdx].status = status;
        } else {
            inMemoryStore.relationships.push({
                source: String(source),
                target: String(target),
                type,
                status
            });
        }
        saveInMemoryStore();
        return [{ affectedRows: 1 }, []];
    }

    // 7b. UPDATE relationships SET verification_status = ...
    if (s.startsWith('UPDATE relationships')) {
        const v1 = String(params[0]);
        const v2 = String(params[1]);
        const v3 = params[2] ? String(params[2]) : v1;
        const v4 = params[3] ? String(params[3]) : v2;
        let affected = 0;
        inMemoryStore.relationships.forEach(r => {
            const isPair = (r.source === v1 && r.target === v2) ||
                           (r.source === v2 && r.target === v1) ||
                           (r.source === v3 && r.target === v4) ||
                           (r.source === v4 && r.target === v3);
            if (isPair && r.type === 'Spouse') {
                r.status = 'Divorced';
                affected++;
            }
        });
        saveInMemoryStore();
        return [{ affectedRows: affected }, []];
    }

    // 8. SELECT vuid FROM citizen_documents WHERE doc_hash = ? AND vuid != ?
    if (s.includes('FROM citizen_documents WHERE doc_hash = ? AND vuid != ?')) {
        const [hash, vuid] = params;
        const dups = inMemoryStore.citizen_documents.filter(
            d => d.doc_hash === hash && d.vuid !== String(vuid)
        );
        return [dups, []];
    }

    // 9. INSERT INTO duplicate_conflict_logs
    if (s.startsWith('INSERT INTO duplicate_conflict_logs')) {
        const [flagged_vuid, matched_vuid, doc_type, conflict_reason, severity, status] = params;
        const entry = {
            id: inMemoryStore.duplicate_conflict_logs.length + 1,
            flagged_vuid: String(flagged_vuid),
            matched_vuid: String(matched_vuid),
            doc_type,
            conflict_reason: conflict_reason || 'Document hash collision detected across distinct family lineages',
            severity: severity || 'Critical',
            status: status || 'Open',
            created_at: new Date()
        };
        inMemoryStore.duplicate_conflict_logs.push(entry);
        return [{ insertId: entry.id, affectedRows: 1 }, []];
    }

    // 10. INSERT INTO citizen_documents
    if (s.startsWith('INSERT INTO citizen_documents')) {
        const [vuid, doc_type, doc_hash, doc_masked_value, issuer_authority, payload] = params;
        const entry = {
            id: inMemoryStore.citizen_documents.length + 1,
            vuid: String(vuid),
            doc_type,
            doc_hash,
            doc_masked_value,
            issuer_authority,
            raw_payload_encrypted: payload,
            is_ocp_verified: 1,
            verified_at: new Date()
        };
        inMemoryStore.citizen_documents.push(entry);
        return [{ insertId: entry.id, affectedRows: 1 }, []];
    }

    // 11. SELECT * FROM duplicate_conflict_logs
    if (s.includes('FROM duplicate_conflict_logs')) {
        const rows = inMemoryStore.duplicate_conflict_logs.map(d => {
            const c1 = inMemoryStore.citizens.find(c => c.vuid === d.flagged_vuid) || {};
            const c2 = inMemoryStore.citizens.find(c => c.vuid === d.matched_vuid) || {};
            return {
                ...d,
                flagged_first_name: c1.first_name || 'Citizen',
                flagged_last_name: c1.last_name || d.flagged_vuid,
                flagged_district: c1.district || 'National',
                matched_first_name: c2.first_name || 'Citizen',
                matched_last_name: c2.last_name || d.matched_vuid,
                matched_district: c2.district || 'National'
            };
        });
        return [rows, []];
    }

    // 12. SELECT log_hash FROM audit_logs ORDER BY id DESC LIMIT 1
    if (s.includes('FROM audit_logs ORDER BY id DESC LIMIT 1')) {
        const last = inMemoryStore.audit_logs[inMemoryStore.audit_logs.length - 1];
        return [last ? [{ log_hash: last.log_hash }] : [], []];
    }

    // 13. INSERT INTO audit_logs
    if (s.startsWith('INSERT INTO audit_logs')) {
        const [actor_vuid, action, resource_type, resource_id, ip_address, user_agent, status, details, prev_log_hash, log_hash] = params;
        const entry = {
            id: inMemoryStore.audit_logs.length + 1,
            actor_vuid,
            action,
            resource_type,
            resource_id,
            ip_address,
            user_agent,
            status,
            details,
            prev_log_hash,
            log_hash,
            created_at: new Date()
        };
        inMemoryStore.audit_logs.push(entry);
        return [{ insertId: entry.id, affectedRows: 1 }, []];
    }

    // 14. SELECT ... FROM audit_logs
    if (s.includes('FROM audit_logs')) {
        return [inMemoryStore.audit_logs.slice().reverse(), []];
    }

    // 15. INSERT INTO citizen_education
    if (s.startsWith('INSERT INTO citizen_education')) {
        const [vuid, qualification_level, degree_name, institution, year_of_passing, occupation_sector, profession_title] = params;
        const entry = {
            id: inMemoryStore.citizen_education.length + 1,
            vuid: String(vuid),
            qualification_level,
            degree_name,
            institution,
            year_of_passing: year_of_passing ? parseInt(year_of_passing, 10) : null,
            occupation_sector: occupation_sector || 'Private_IT_Corporate',
            profession_title: profession_title || null,
            created_at: new Date()
        };
        inMemoryStore.citizen_education.push(entry);
        return [{ insertId: entry.id, affectedRows: 1 }, []];
    }

    // 16. SELECT ... FROM citizen_education WHERE vuid = ?
    if (s.includes('FROM citizen_education WHERE vuid = ?')) {
        const vuid = String(params[0]);
        const records = inMemoryStore.citizen_education.filter(e => e.vuid === vuid);
        return [records, []];
    }

    // 17. INSERT INTO marriages
    if (s.startsWith('INSERT INTO marriages')) {
        const [marriage_reg_no, bride_vuid, groom_vuid, marriage_date, venue_city, venue_state, priest_or_registrar, status] = params;
        const entry = {
            id: inMemoryStore.marriages.length + 1,
            marriage_reg_no,
            bride_vuid: String(bride_vuid),
            groom_vuid: String(groom_vuid),
            marriage_date,
            venue_city: venue_city || null,
            venue_state: venue_state || null,
            priest_or_registrar: priest_or_registrar || null,
            status: status || 'Registered',
            created_at: new Date()
        };
        inMemoryStore.marriages.push(entry);
        return [{ insertId: entry.id, affectedRows: 1 }, []];
    }

    // 18. UPDATE citizens SET status = 'Deceased' ...
    if (s.includes("UPDATE citizens SET status = 'Deceased'") || s.includes('SET status = ?, death_date = ?')) {
        const vuid = String(params[params.length - 1]);
        const citizen = inMemoryStore.citizens.find(c => c.vuid === vuid);
        if (citizen) {
            citizen.status = 'Deceased';
            citizen.death_date = params[0] || new Date().toISOString().split('T')[0];
            citizen.death_reason = params[1] || 'Natural';
            citizen.death_cert_number = params[2] || 'D-REC-VALID';
        }
        saveInMemoryStore();
        return [{ affectedRows: 1 }, []];
    }

    // 19. UPDATE citizens SET marital_status = ? ...
    if (s.includes('UPDATE citizens SET marital_status = ?')) {
        const status = params[0];
        const v1 = String(params[1]);
        const v2 = params[2] ? String(params[2]) : null;
        inMemoryStore.citizens.forEach(c => {
            if (c.vuid === v1 || c.vuid === v2) {
                c.marital_status = status;
            }
        });
        saveInMemoryStore();
        return [{ affectedRows: v2 ? 2 : 1 }, []];
    }

    // 20. Matrimony Candidates Search Query
    if (s.includes('c.marital_status') || s.includes('c.gender = ?') || s.includes('FROM citizens c') && s.includes('candidate')) {
        const lookingForGender = params[0];
        let candidates = inMemoryStore.citizens.filter(c => {
            if (c.status === 'Deceased' || c.status === 'Missing') return false;
            if (lookingForGender && c.gender !== lookingForGender) return false;
            return true;
        });

        // Enrich candidates with education
        const enriched = candidates.map(c => {
            const edu = inMemoryStore.citizen_education.find(e => e.vuid === c.vuid);
            return {
                vuid: c.vuid,
                first_name: c.first_name,
                last_name: c.last_name,
                gender: c.gender,
                dob: c.dob,
                caste: c.caste,
                category: c.category,
                gotra: c.gotra || 'Kashyap',
                religion: c.religion || 'Hindu',
                marital_status: c.marital_status || 'Single',
                height_cm: c.height_cm,
                district: c.district,
                state: c.state,
                qualification_level: edu ? edu.qualification_level : 'Graduation',
                degree_name: edu ? edu.degree_name : 'Graduate',
                institution: edu ? edu.institution : 'University',
                profession_title: edu ? edu.profession_title : 'Professional',
                occupation_sector: edu ? edu.occupation_sector : 'Corporate'
            };
        });
        return [enriched, []];
    }

    // Generic fallback
    return [[], []];
}

/**
 * Resilient In-Memory Connection Wrapper
 */
class InMemoryConnection {
    async query(sql, params) {
        return executeInMemoryQuery(sql, params);
    }
    async beginTransaction() {
        return;
    }
    async commit() {
        return;
    }
    async rollback() {
        return;
    }
    release() {
        return;
    }
    async ping() {
        return true;
    }
}

// Global state tracking whether MySQL is online
let isMysqlOnline = false;

async function checkMysqlLiveness() {
    try {
        const connection = await mysqlPool.getConnection();
        await connection.ping();
        connection.release();
        isMysqlOnline = true;
        return true;
    } catch (_) {
        isMysqlOnline = false;
        return false;
    }
}

// Initial liveness probe (non-blocking)
checkMysqlLiveness();

/**
 * Unified Resilient Pool
 * Transparently delegates to live MySQL when online, or inMemoryStore when offline.
 */
const pool = {
    async query(sql, params) {
        if (isMysqlOnline) {
            try {
                return await mysqlPool.query(sql, params);
            } catch (err) {
                // If MySQL unexpectedly drops, fall back to memory
                isMysqlOnline = false;
                return executeInMemoryQuery(sql, params);
            }
        }
        return executeInMemoryQuery(sql, params);
    },

    async getConnection() {
        if (isMysqlOnline) {
            try {
                return await mysqlPool.getConnection();
            } catch (err) {
                isMysqlOnline = false;
                return new InMemoryConnection();
            }
        }
        return new InMemoryConnection();
    }
};

/**
 * Health check utility to verify database connectivity.
 */
async function testConnection() {
    return await checkMysqlLiveness();
}

/**
 * Gracefully close MySQL pool connections during application shutdown.
 */
async function closePool() {
    try {
        await mysqlPool.end();
    } catch (_) {
        // Suppress errors during offline mode teardown
    }
}

module.exports = {
    pool,
    testConnection,
    inMemoryStore,
    closePool
};
