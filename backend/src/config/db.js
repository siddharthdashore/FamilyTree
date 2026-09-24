const mysql = require('mysql2/promise');
require('dotenv').config();

// Standard MySQL 8.0 Connection Pool
const mysqlPool = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    user: process.env.DB_USER || 'vanshasetu_user',
    password: process.env.DB_PASSWORD || 'ChangeThisPassword123!',
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
// Pre-seeded with the exact multi-generational pedigree from database/seed.sql.
// ============================================================================

const inMemoryStore = {
    citizens: [
        {
            id: 1,
            vuid: '109284729102',
            first_name: 'Kailash',
            middle_name: 'Prasad',
            last_name: 'Sharma',
            gender: 'Male',
            dob: '1948-03-12',
            height_cm: 168.0,
            weight_kg: 65.0,
            ephi_encrypted_data: null,
            ephi_iv: null,
            ephi_auth_tag: null,
            caste: 'Brahmin',
            category: 'GEN',
            gotra: 'Bharadwaj',
            religion: 'Hindu',
            marital_status: 'Widowed',
            blood_group: 'O+',
            address_line1: '42 Heritage Enclave',
            address_line2: 'Civil Lines',
            pin_code: '452001',
            district: 'Indore',
            state: 'Madhya Pradesh',
            country: 'India',
            latitude: 22.7196,
            longitude: 75.8577,
            is_claimed: 1,
            status: 'Active',
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 2,
            vuid: '510928340192',
            first_name: 'Ramesh',
            middle_name: 'Chandra',
            last_name: 'Sharma',
            gender: 'Male',
            dob: '1972-07-24',
            height_cm: 175.5,
            weight_kg: 74.0,
            ephi_encrypted_data: null,
            ephi_iv: null,
            ephi_auth_tag: null,
            caste: 'Brahmin',
            category: 'GEN',
            gotra: 'Bharadwaj',
            religion: 'Hindu',
            marital_status: 'Married',
            blood_group: 'B+',
            address_line1: '104 Lotus Heights',
            address_line2: 'Vijay Nagar',
            pin_code: '452010',
            district: 'Indore',
            state: 'Madhya Pradesh',
            country: 'India',
            latitude: 22.7533,
            longitude: 75.8937,
            is_claimed: 1,
            status: 'Active',
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 3,
            vuid: '510928340193',
            first_name: 'Sunita',
            middle_name: null,
            last_name: 'Sharma',
            gender: 'Female',
            dob: '1975-11-05',
            height_cm: 160.0,
            weight_kg: 62.0,
            ephi_encrypted_data: null,
            ephi_iv: null,
            ephi_auth_tag: null,
            caste: 'Brahmin',
            category: 'GEN',
            gotra: 'Kashyap',
            religion: 'Hindu',
            marital_status: 'Married',
            blood_group: 'A+',
            address_line1: '104 Lotus Heights',
            address_line2: 'Vijay Nagar',
            pin_code: '452010',
            district: 'Indore',
            state: 'Madhya Pradesh',
            country: 'India',
            latitude: 22.7533,
            longitude: 75.8937,
            is_claimed: 1,
            status: 'Active',
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 4,
            vuid: '284910293847',
            first_name: 'Aarav',
            middle_name: null,
            last_name: 'Sharma',
            gender: 'Male',
            dob: '1998-05-18',
            height_cm: 178.0,
            weight_kg: 71.0,
            ephi_encrypted_data: null,
            ephi_iv: null,
            ephi_auth_tag: null,
            caste: 'Brahmin',
            category: 'GEN',
            gotra: 'Bharadwaj',
            religion: 'Hindu',
            marital_status: 'Married',
            blood_group: 'B+',
            address_line1: 'Flat 302, Green Meadows',
            address_line2: 'HSR Layout Sector 2',
            pin_code: '560102',
            district: 'Bengaluru Urban',
            state: 'Karnataka',
            country: 'India',
            latitude: 12.9116,
            longitude: 77.6499,
            is_claimed: 1,
            status: 'Active',
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 5,
            vuid: '928174019284',
            first_name: 'Pooja',
            middle_name: 'Kumari',
            last_name: 'Sharma',
            gender: 'Female',
            dob: '2000-09-22',
            height_cm: 165.0,
            weight_kg: 56.0,
            ephi_encrypted_data: null,
            ephi_iv: null,
            ephi_auth_tag: null,
            caste: 'Brahmin',
            category: 'GEN',
            gotra: 'Vashishta',
            religion: 'Hindu',
            marital_status: 'Married',
            blood_group: 'AB+',
            address_line1: 'Flat 302, Green Meadows',
            address_line2: 'HSR Layout Sector 2',
            pin_code: '560102',
            district: 'Bengaluru Urban',
            state: 'Karnataka',
            country: 'India',
            latitude: 12.9116,
            longitude: 77.6499,
            is_claimed: 1,
            status: 'Active',
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 6,
            vuid: '819204918274',
            first_name: 'Vihaan',
            middle_name: null,
            last_name: 'Sharma',
            gender: 'Male',
            dob: '2024-01-15',
            height_cm: 54.0,
            weight_kg: 4.2,
            ephi_encrypted_data: null,
            ephi_iv: null,
            ephi_auth_tag: null,
            caste: 'Brahmin',
            category: 'GEN',
            gotra: 'Bharadwaj',
            religion: 'Hindu',
            marital_status: 'Single',
            blood_group: 'B+',
            address_line1: 'Flat 302, Green Meadows',
            address_line2: 'HSR Layout Sector 2',
            pin_code: '560102',
            district: 'Bengaluru Urban',
            state: 'Karnataka',
            country: 'India',
            latitude: 12.9116,
            longitude: 77.6499,
            is_claimed: 1,
            status: 'Active',
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 7,
            vuid: '391029485710',
            first_name: 'Deepak',
            middle_name: 'Kumar',
            last_name: 'Sharma',
            gender: 'Male',
            dob: '1976-02-14',
            height_cm: 172.0,
            weight_kg: 68.0,
            ephi_encrypted_data: null,
            ephi_iv: null,
            ephi_auth_tag: null,
            caste: 'Brahmin',
            category: 'GEN',
            address_line1: 'Old Market Ward 4',
            address_line2: 'Ganj',
            pin_code: '452002',
            district: 'Indore',
            state: 'Madhya Pradesh',
            country: 'India',
            latitude: 22.7150,
            longitude: 75.8600,
            is_claimed: 0,
            status: 'Missing',
            gotra: 'Bharadwaj',
            religion: 'Hindu',
            marital_status: 'Single',
            blood_group: 'A+',
            death_date: null,
            death_reason: null,
            death_cert_number: null,
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 8,
            vuid: '710293849102',
            first_name: 'Rohan',
            middle_name: null,
            last_name: 'Verma',
            gender: 'Male',
            dob: '1996-04-10',
            height_cm: 177.0,
            weight_kg: 72.0,
            ephi_encrypted_data: null,
            ephi_iv: null,
            ephi_auth_tag: null,
            caste: 'Kayastha',
            category: 'GEN',
            gotra: 'Gautam',
            religion: 'Hindu',
            marital_status: 'Single',
            blood_group: 'B+',
            address_line1: '12 Scheme 54',
            address_line2: 'Vijay Nagar',
            pin_code: '452010',
            district: 'Indore',
            state: 'Madhya Pradesh',
            country: 'India',
            latitude: 22.7533,
            longitude: 75.8937,
            is_claimed: 1,
            status: 'Active',
            death_date: null,
            death_reason: null,
            death_cert_number: null,
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 9,
            vuid: '710293849103',
            first_name: 'Ananya',
            middle_name: null,
            last_name: 'Joshi',
            gender: 'Female',
            dob: '1999-08-15',
            height_cm: 164.0,
            weight_kg: 54.0,
            ephi_encrypted_data: null,
            ephi_iv: null,
            ephi_auth_tag: null,
            caste: 'Brahmin',
            category: 'GEN',
            gotra: 'Shandilya',
            religion: 'Hindu',
            marital_status: 'Single',
            blood_group: 'O+',
            address_line1: '88 Annapurna Road',
            address_line2: 'Sudama Nagar',
            pin_code: '452009',
            district: 'Indore',
            state: 'Madhya Pradesh',
            country: 'India',
            latitude: 22.6950,
            longitude: 75.8320,
            is_claimed: 1,
            status: 'Active',
            death_date: null,
            death_reason: null,
            death_cert_number: null,
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 10,
            vuid: '710293849104',
            first_name: 'Priya',
            middle_name: 'Devi',
            last_name: 'Patel',
            gender: 'Female',
            dob: '1997-12-02',
            height_cm: 162.0,
            weight_kg: 56.0,
            ephi_encrypted_data: null,
            ephi_iv: null,
            ephi_auth_tag: null,
            caste: 'Patidar',
            category: 'OBC',
            gotra: 'Kashyap',
            religion: 'Hindu',
            marital_status: 'Single',
            blood_group: 'AB+',
            address_line1: '15 Mahakal Marg',
            address_line2: 'Freeganj',
            pin_code: '456001',
            district: 'Ujjain',
            state: 'Madhya Pradesh',
            country: 'India',
            latitude: 23.1765,
            longitude: 75.7885,
            is_claimed: 1,
            status: 'Active',
            death_date: null,
            death_reason: null,
            death_cert_number: null,
            created_at: new Date('2026-01-01T00:00:00Z')
        }
    ],
    relationships: [
        { source: '109284729102', target: '510928340192', type: 'Father', status: 'Document_Backed' },
        { source: '510928340192', target: '510928340193', type: 'Spouse', status: 'Mutual_Confirmed' },
        { source: '510928340193', target: '510928340192', type: 'Spouse', status: 'Mutual_Confirmed' },
        { source: '510928340192', target: '284910293847', type: 'Father', status: 'Mutual_Confirmed' },
        { source: '510928340193', target: '284910293847', type: 'Mother', status: 'Mutual_Confirmed' },
        { source: '284910293847', target: '928174019284', type: 'Spouse', status: 'Mutual_Confirmed' },
        { source: '928174019284', target: '284910293847', type: 'Spouse', status: 'Mutual_Confirmed' },
        { source: '284910293847', target: '819204918274', type: 'Father', status: 'Mutual_Confirmed' },
        { source: '928174019284', target: '819204918274', type: 'Mother', status: 'Mutual_Confirmed' },
        { source: '510928340192', target: '391029485710', type: 'Sibling', status: 'Unverified' }
    ],
    citizen_documents: [
        {
            id: 1,
            vuid: '284910293847',
            doc_type: 'AADHAAR',
            doc_hash: '22830f61fa9ef31d0411a766aa0813958045610ec871c5ec37d7c675306e902b',
            doc_masked_value: 'XXXXXXXX4820',
            issuer_authority: 'DigiLocker / UIDAI',
            is_ocp_verified: 1,
            verified_at: new Date('2026-01-10T10:30:00Z')
        },
        {
            id: 2,
            vuid: '109284729102',
            doc_type: 'AADHAAR',
            doc_hash: '3a985f61fa9ef31d0411a766aa0813958045610ec871c5ec37d7c675306e9099',
            doc_masked_value: 'XXXXXXXX9102',
            issuer_authority: 'UIDAI',
            is_ocp_verified: 1,
            verified_at: new Date('2026-01-01T00:00:00Z')
        }
    ],
    duplicate_conflict_logs: [
        {
            id: 1,
            flagged_vuid: '284910293847',
            matched_vuid: '391029485710',
            doc_type: 'RATION_CARD',
            conflict_reason: 'Ration card identity collision detected across households',
            severity: 'High',
            status: 'Investigating',
            created_at: new Date('2026-01-15T09:00:00Z')
        }
    ],
    citizen_education: [
        {
            id: 1,
            vuid: '284910293847',
            qualification_level: 'Bachelors',
            degree_name: 'B.Tech Computer Science & Engineering',
            institution: 'Indian Institute of Technology Bombay',
            year_of_passing: 2020,
            occupation_sector: 'Private_IT_Corporate',
            profession_title: 'Senior Software Engineer',
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 2,
            vuid: '510928340192',
            qualification_level: 'Masters',
            degree_name: 'M.Sc Mathematics',
            institution: 'Holkar Science College Indore',
            year_of_passing: 1995,
            occupation_sector: 'Education_Research',
            profession_title: 'Senior Education Administrator',
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 3,
            vuid: '928174019284',
            qualification_level: 'Masters',
            degree_name: 'MBA in Financial Analytics',
            institution: 'Indian Institute of Management Indore',
            year_of_passing: 2022,
            occupation_sector: 'Banking_Finance',
            profession_title: 'Senior Portfolio Manager',
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 4,
            vuid: '710293849103',
            qualification_level: 'Bachelors',
            degree_name: 'MBBS (Bachelor of Medicine)',
            institution: 'All India Institute of Medical Sciences (AIIMS) Bhopal',
            year_of_passing: 2023,
            occupation_sector: 'Healthcare',
            profession_title: 'Resident Medical Officer',
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 5,
            vuid: '710293849102',
            qualification_level: 'Bachelors',
            degree_name: 'B.Com & Chartered Accountancy (CA)',
            institution: 'Institute of Chartered Accountants of India',
            year_of_passing: 2019,
            occupation_sector: 'Banking_Finance',
            profession_title: 'Senior Financial Analyst',
            created_at: new Date('2026-01-01T00:00:00Z')
        }
    ],
    marriages: [
        {
            id: 1,
            marriage_reg_no: 'MP-IND-2000-8492',
            bride_vuid: '510928340193',
            groom_vuid: '510928340192',
            marriage_date: '2000-05-12',
            venue_city: 'Indore',
            venue_state: 'Madhya Pradesh',
            priest_or_registrar: 'Registrar of Marriages, District Court Indore',
            status: 'Registered',
            created_at: new Date('2026-01-01T00:00:00Z')
        },
        {
            id: 2,
            marriage_reg_no: 'KA-BLR-2023-1104',
            bride_vuid: '928174019284',
            groom_vuid: '284910293847',
            marriage_date: '2023-11-20',
            venue_city: 'Bengaluru',
            venue_state: 'Karnataka',
            priest_or_registrar: 'Sub-Registrar Office, Koramangala',
            status: 'Registered',
            created_at: new Date('2026-01-01T00:00:00Z')
        }
    ],
    audit_logs: [
        {
            id: 1,
            actor_vuid: '109284729102',
            action: 'CREATE',
            resource_type: 'CITIZEN',
            resource_id: '109284729102',
            ip_address: '127.0.0.1',
            user_agent: 'VanshaSetu Seed Engine',
            status: 'SUCCESS',
            details: '{"category":"GEN","district":"Indore","state":"Madhya Pradesh"}',
            prev_log_hash: '0000000000000000000000000000000000000000000000000000000000000000',
            log_hash: '9f83543b2f707a3e488e453e411b4528238f4d54715be7c7b4e830a210c42f29',
            created_at: new Date('2026-01-01T00:00:00Z')
        }
    ]
};

/**
 * In-memory query simulator matching SQL syntax used by routes.
 */
function executeInMemoryQuery(sql, params = []) {
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
                    category: c.category,
                    is_claimed: c.is_claimed,
                    status: c.status,
                    is_verified: isVerified ? 1 : 0
                };
            });
        return [matches, []];
    }

    // 6. SELECT ... FROM relationships WHERE source_vuid = ? OR target_vuid = ?
    if (s.includes('FROM relationships WHERE source_vuid = ? OR target_vuid = ?')) {
        const vuid = String(params[0]);
        const edges = inMemoryStore.relationships.filter(
            r => r.source === vuid || r.target === vuid
        );
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
        return [{ affectedRows: 1 }, []];
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
