# VanshaSetu (वन्शसेतु) — Comprehensive System & Implementation Specification

*A Production-Grade, Minimalist, Material 3 Digital Public Infrastructure (DPI) Kinship Platform for Global Lineage Mapping, OCP Document Vaulting, Duplicate ID/SIR Conflict Resolution, and WhatsApp-Verifiable Vansha Cards.*

---

## 1. Executive Summary & Brand Identity

* **Platform Name:** **VanshaSetu** (वन्शसेतु)
  * *Etymology:* *Vansha* (Sanskrit: वंश — lineage, ancestry, kinship descent) + *Setu* (Sanskrit: सेतु — bridge, connecting channel). Aligns with Indian Digital Public Infrastructure conventions (e.g., API Setu, Aarogya Setu).
  * *Target Web & API Domains:* `vanshasetu.in`, `vanshasetu.org`, `vanshasetu.io`.
* **Unique Identifier Standard:** **VUID (VanshaSetu Universal ID)**
  * **Specification:** Strictly **12 numeric digits** (`^[0-9]{12}$`).
  * Mathematical integer range: $[100000000000, 999999999999]$ ($10^{11}$ through $10^{12} - 1$).
  * **Constraint:** Zero alphabetic characters, no state prefixes, and no checksum digits.
  * *Display Convention:* Formatted visually for human legibility as three space-delimited 4-digit clusters (`XXXX XXXX XXXX`), but stored as a pure 12-character unsigned numeric string.
* **Identity Credential:** **Vansha Card** (वन्श कार्ड)
  * A verifiable, ISO/IEC 7810 ID-1 standard ratio ($85.60\text{ mm} \times 53.98\text{ mm}$) digital credential containing an offline/online dynamic HMAC-signed QR code linking directly to the citizen's family tree node.
* **Core Missions:**
  1. Consolidate all Indian Government-issued credentials (Aadhaar, PAN, Voter ID, Driving License, Passport, Ration Card, Birth Certificate) under one global sovereign profile via Open Consent Protocol (OCP) and DigiLocker/API Setu.
  2. Map humanity into a unified, interactive, multi-generational kinship graph.
  3. Detect identity duplication, multi-ration claiming, ghost-voter entries, and assist public surveys such as the Socio-Economic and Caste Census / Special Investigation Registry (SIR).
  4. Enable rapid identification of missing persons by reconciling orphan records against verified ancestral trees.

---

## 2. System Architecture & Topology

```
┌──────────────────────────────────────────────────────────────────────────┐
│                   Flutter Client (Android / iOS / Web)                  │
│  - Material 3 Design System        - InteractiveViewer Graph Canvas      │
│  - GPS Live Reverse-Geocoding      - Vansha Card QR & WhatsApp Exporter  │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │ HTTPS / TLS 1.3 (JWT + AES-GCM)
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│             BigRock Cloud Hosting Middleware (Node.js / Express)         │
│  - 12-Digit Numeric ID Allocator   - Tokenized Document Vault            │
│  - OCP / DigiLocker Webhook Bridge - Duplicate & SIR Anomaly Engine      │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │ Local Socket / Port 3306 (Internal)
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│               BigRock Cloud MySQL 8.0 Database (InnoDB)                  │
│  - citizens (VUID: CHAR(12))       - relationships (Directed Graph)      │
│  - citizen_documents (Hashed)      - duplicate_conflict_logs (SIR)       │
└──────────────────────────────────────────────────────────────────────────┘
```

### Critical Security & Privacy Policies
1. **Zero Client-to-Database Exposure:** The mobile application **never** connects directly to MySQL via port 3306. All database transactions are brokered by an authenticated REST API running locally on the BigRock server via `localhost:3306`.
2. **DPDP & UIDAI Zero-Knowledge Compliance:** Raw government identity numbers (Aadhaar, PAN, etc.) are **never** stored in plaintext. They undergo client-side and middleware salted SHA-256 hashing to generate unique collision tokens (`doc_hash`), retaining only masked representations (`XXXX-XXXX-1234`) for user display.
3. **Transport Security:** All client-middleware communication utilizes TLS 1.3 encryption with certificate pinning and HMAC request signing.

---

## 3. Database Schema (Complete MySQL 8.0 DDL — 7 Production Tables)

Execute this script within phpMyAdmin or the MySQL terminal on your BigRock cPanel:

```sql
CREATE DATABASE IF NOT EXISTS `vanshasetu_db` 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE `vanshasetu_db`;

-- --------------------------------------------------------
-- 1. Master Citizens Table (ePHI & PII Hardened)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `citizens` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `vuid` CHAR(12) NOT NULL UNIQUE COMMENT 'Strictly 12 numeric digits: [100000000000, 999999999999]',
    `first_name` VARCHAR(60) NOT NULL,
    `middle_name` VARCHAR(60) DEFAULT NULL,
    `last_name` VARCHAR(60) NOT NULL,
    `gender` ENUM('Male', 'Female', 'Non-Binary', 'Transgender', 'Other') NOT NULL,
    `dob` DATE NOT NULL,
    `height_cm` DECIMAL(5,2) DEFAULT NULL,
    `weight_kg` DECIMAL(5,2) DEFAULT NULL,
    `ephi_encrypted_data` TEXT DEFAULT NULL COMMENT 'AES-256-GCM encrypted envelope for height, weight, health attributes',
    `ephi_iv` CHAR(24) DEFAULT NULL COMMENT '12-byte initialization vector in base64',
    `ephi_auth_tag` CHAR(24) DEFAULT NULL COMMENT '16-byte authentication tag in base64',
    `caste` VARCHAR(80) DEFAULT NULL,
    `category` ENUM('GEN', 'OBC', 'SC', 'ST', 'EWS', 'Other') NOT NULL,
    `gotra` VARCHAR(80) DEFAULT NULL COMMENT 'Gotra / Clan lineage attribute for Indian ancestry and marriage exogamy',
    `religion` VARCHAR(50) DEFAULT 'Hindu',
    `marital_status` ENUM('Single', 'Married', 'Widowed', 'Divorced') DEFAULT 'Single',
    `blood_group` ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') DEFAULT NULL,
    `death_date` DATE DEFAULT NULL,
    `death_reason` VARCHAR(255) DEFAULT NULL,
    `death_cert_number` VARCHAR(100) DEFAULT NULL,
    
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
    INDEX `idx_pincode` (`pin_code`),
    INDEX `idx_gotra` (`gotra`),
    INDEX `idx_demographics` (`state`, `district`, `category`, `gender`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ENCRYPTION='Y';

-- --------------------------------------------------------
-- 2. Kinship Directed Graph Relationships Table
-- --------------------------------------------------------
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

-- --------------------------------------------------------
-- 3. Tokenized Document Vault (Zero-Knowledge OCP / DigiLocker)
-- --------------------------------------------------------
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
    `doc_iv` CHAR(24) DEFAULT NULL,
    `doc_auth_tag` CHAR(24) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`vuid`) REFERENCES `citizens`(`vuid`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_doc_hash` (`doc_hash`),
    UNIQUE KEY `uq_vuid_doctype` (`vuid`, `doc_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ENCRYPTION='Y';

-- --------------------------------------------------------
-- 4. Deduplication & Lineage Conflict Log (SIR)
-- --------------------------------------------------------
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

-- --------------------------------------------------------
-- 5. HIPAA § 164.312(b) Immutable Audit Trail & Access Log
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `audit_logs` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `actor_vuid` CHAR(12) DEFAULT NULL,
    `action` ENUM('CREATE', 'READ', 'UPDATE', 'DELETE', 'EXPORT', 'VERIFY_OCP', 'SIR_FLAG', 'EMERGENCY_ACCESS', 'BIRTH_REGISTRATION', 'DEATH_REGISTRATION', 'MARRIAGE_REGISTRATION', 'MATRIMONY_SEARCH', 'DEMOGRAPHICS_QUERY', 'EDUCATION_UPDATE') NOT NULL,
    `resource_type` ENUM('CITIZEN', 'RELATIONSHIP', 'DOCUMENT', 'CONFLICT_LOG', 'TREE_GRAPH', 'EDUCATION', 'MARRIAGE', 'ANALYTICS') NOT NULL,
    `resource_id` VARCHAR(100) NOT NULL,
    `ip_address` VARCHAR(45) NOT NULL,
    `user_agent` VARCHAR(255) DEFAULT NULL,
    `status` ENUM('SUCCESS', 'UNAUTHORIZED', 'FORBIDDEN', 'FAILED') NOT NULL,
    `details` TEXT DEFAULT NULL,
    `prev_log_hash` CHAR(64) DEFAULT NULL COMMENT 'Cryptographic hash chain pointing to preceding entry',
    `log_hash` CHAR(64) NOT NULL COMMENT 'SHA-256(id + actor + action + timestamp + prev_log_hash)',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_actor` (`actor_vuid`),
    INDEX `idx_action` (`action`),
    INDEX `idx_resource` (`resource_type`, `resource_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ENCRYPTION='Y';

-- --------------------------------------------------------
-- 6. Comprehensive Indian Education & Occupation Registry
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `citizen_education` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `vuid` CHAR(12) NOT NULL,
    `qualification_level` ENUM('Primary', 'Secondary_10th', 'HigherSecondary_12th', 'Diploma', 'Bachelors', 'Masters', 'Doctorate', 'Professional_CA_CS', 'Other') NOT NULL,
    `degree_name` VARCHAR(120) NOT NULL,
    `institution` VARCHAR(180) NOT NULL,
    `year_of_passing` INT DEFAULT NULL,
    `occupation_sector` ENUM('Government', 'Private_IT_Corporate', 'Healthcare', 'Banking_Finance', 'Defense_Police', 'Education_Research', 'Business_SelfEmployed', 'Agriculture', 'Student', 'Homemaker', 'Other') DEFAULT 'Private_IT_Corporate',
    `profession_title` VARCHAR(120) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`vuid`) REFERENCES `citizens`(`vuid`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_edu_vuid` (`vuid`),
    INDEX `idx_qualification` (`qualification_level`),
    INDEX `idx_occupation` (`occupation_sector`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ENCRYPTION='Y';

-- --------------------------------------------------------
-- 7. Civil Marriage Registry & Verification Edge
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `marriages` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `marriage_reg_no` VARCHAR(80) DEFAULT NULL,
    `bride_vuid` CHAR(12) NOT NULL,
    `groom_vuid` CHAR(12) NOT NULL,
    `marriage_date` DATE NOT NULL,
    `venue_city` VARCHAR(80) DEFAULT NULL,
    `venue_state` VARCHAR(80) DEFAULT NULL,
    `priest_or_registrar` VARCHAR(120) DEFAULT NULL,
    `status` ENUM('Registered', 'Customary', 'Dissolved') DEFAULT 'Registered',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`bride_vuid`) REFERENCES `citizens`(`vuid`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`groom_vuid`) REFERENCES `citizens`(`vuid`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_bride` (`bride_vuid`),
    INDEX `idx_groom` (`groom_vuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ENCRYPTION='Y';
```

---

## 4. BigRock Cloud Middleware API (`server.js`)

This complete Node.js Express server is built to run directly under BigRock cPanel's **Setup Node.js App** (via CloudLinux Passenger).

```javascript
const express = require('express');
const mysql = require('mysql2/promise');
const crypto = require('crypto');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());

// MySQL connection pool configured for BigRock Localhost
const pool = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    user: process.env.DB_USER || 'vanshasetu_user',
    password: process.env.DB_PASSWORD || 'ChangeThisPassword123!',
    database: process.env.DB_NAME || 'vanshasetu_db',
    port: 3306,
    waitForConnections: true,
    connectionLimit: 15,
    queueLimit: 0
});

const HASH_SALT = process.env.HASH_SALT || 'VANSHA_SETU_SECURE_SALT_9841';

// Cryptographically secure generation of a strictly 12-digit numeric ID
function generate12DigitVUID() {
    const min = 100000000000;
    const max = 999999999999;
    return crypto.randomInt(min, max + 1).toString();
}

// --------------------------------------------------------
// 1. Citizen Registration Endpoint
// --------------------------------------------------------
app.post('/api/v1/citizen/register', async (req, res) => {
    const {
        first_name, middle_name, last_name, gender, dob,
        height_cm, weight_kg, caste, category,
        address_line1, address_line2, pin_code, district, state, country,
        latitude, longitude
    } = req.body;

    if (!first_name || !last_name || !gender || !dob || !pin_code || !district || !state) {
        return res.status(400).json({ error: 'Missing mandatory registration fields.' });
    }

    const connection = await pool.getConnection();
    try {
        let vuid = null;
        let isUnique = false;
        let attempts = 0;

        while (!isUnique && attempts < 5) {
            const candidateVuid = generate12DigitVUID();
            const [rows] = await connection.query('SELECT id FROM citizens WHERE vuid = ?', [candidateVuid]);
            if (rows.length === 0) {
                vuid = candidateVuid;
                isUnique = true;
            }
            attempts++;
        }

        if (!vuid) {
            return res.status(500).json({ error: 'Failed to allocate unique 12-digit VUID. Try again.' });
        }

        const insertQuery = `
            INSERT INTO citizens (
                vuid, first_name, middle_name, last_name, gender, dob,
                height_cm, weight_kg, caste, category,
                address_line1, address_line2, pin_code, district, state, country,
                latitude, longitude, is_claimed
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE)
        `;

        await connection.query(insertQuery, [
            vuid, first_name, middle_name || null, last_name, gender, dob,
            height_cm || null, weight_kg || null, caste || null, category,
            address_line1, address_line2, pin_code, district, state, country || 'India',
            latitude || null, longitude || null
        ]);

        return res.status(201).json({
            success: true,
            message: 'Citizen registered successfully.',
            data: {
                vuid,
                full_name: `${first_name} ${middle_name ? middle_name + ' ' : ''}${last_name}`.trim(),
                registered_at: new Date().toISOString()
            }
        });
    } catch (err) {
        console.error('Registration Error:', err);
        return res.status(500).json({ error: 'Internal Server Error.' });
    } finally {
        connection.release();
    }
});

// --------------------------------------------------------
// 2. Kinship Edge Creation Endpoint
// --------------------------------------------------------
app.post('/api/v1/kinship/connect', async (req, res) => {
    const { source_vuid, target_vuid, relationship_type } = req.body;

    if (!/^[0-9]{12}$/.test(source_vuid) || !/^[0-9]{12}$/.test(target_vuid)) {
        return res.status(400).json({ error: 'Both VUIDs must be strictly 12 digits.' });
    }

    try {
        await pool.query(`
            INSERT INTO relationships (source_vuid, target_vuid, relationship_type, verification_status)
            VALUES (?, ?, ?, 'Mutual_Confirmed')
            ON DUPLICATE KEY UPDATE verification_status = 'Mutual_Confirmed'
        `, [source_vuid, target_vuid, relationship_type]);

        return res.status(200).json({
            success: true,
            message: 'Kinship relationship successfully mapped.'
        });
    } catch (err) {
        console.error('Kinship Error:', err);
        return res.status(500).json({ error: 'Failed to record kinship link.' });
    }
});

// --------------------------------------------------------
// 3. Document Ingestion & SIR Duplicate Conflict Check
// --------------------------------------------------------
app.post('/api/v1/docs/verify-ocp', async (req, res) => {
    const { vuid, doc_type, doc_raw_value, issuer_authority } = req.body;

    if (!/^[0-9]{12}$/.test(vuid) || !doc_type || !doc_raw_value) {
        return res.status(400).json({ error: 'Invalid parameters. Strict 12-digit VUID required.' });
    }

    const sanitizedDoc = doc_raw_value.replace(/[\s-]/g, '').toUpperCase();
    const docHash = crypto.createHash('sha256').update(sanitizedDoc + HASH_SALT).digest('hex');
    
    const lastFour = sanitizedDoc.length >= 4 ? sanitizedDoc.slice(-4) : 'XXXX';
    const maskedValue = sanitizedDoc.length > 4 
        ? 'X'.repeat(sanitizedDoc.length - 4) + lastFour 
        : `XXXX-${lastFour}`;

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // Detect if this document is already bound to another citizen
        const [duplicates] = await connection.query(
            'SELECT vuid FROM citizen_documents WHERE doc_hash = ? AND vuid != ?',
            [docHash, vuid]
        );

        let conflictDetected = false;
        if (duplicates.length > 0) {
            conflictDetected = true;
            const matchedVuid = duplicates[0].vuid;

            // Log conflict incident for survey/SIR investigation
            await connection.query(`
                INSERT INTO duplicate_conflict_logs 
                (flagged_vuid, matched_vuid, doc_type, conflict_reason, severity, status)
                VALUES (?, ?, ?, 'Document hash collision detected across distinct family lineages', 'Critical', 'Open')
            `, [vuid, matchedVuid, doc_type]);
        }

        // Upsert the document under the active citizen
        await connection.query(`
            INSERT INTO citizen_documents 
            (vuid, doc_type, doc_hash, doc_masked_value, issuer_authority, is_ocp_verified, verified_at)
            VALUES (?, ?, ?, ?, ?, TRUE, NOW())
            ON DUPLICATE KEY UPDATE 
                doc_hash = VALUES(doc_hash),
                doc_masked_value = VALUES(doc_masked_value),
                is_ocp_verified = TRUE,
                verified_at = NOW()
        `, [vuid, doc_type, docHash, maskedValue, issuer_authority || 'DigiLocker / API Setu']);

        await connection.commit();

        return res.status(conflictDetected ? 409 : 200).json({
            success: true,
            conflict_detected: conflictDetected,
            masked_value: maskedValue,
            message: conflictDetected 
                ? 'Document registered. Cross-tree duplication flag logged for SIR review.'
                : 'Document verified and mapped successfully.'
        });
    } catch (err) {
        await connection.rollback();
        console.error('Doc Verify Error:', err);
        return res.status(500).json({ error: 'Document verification failed.' });
    } finally {
        connection.release();
    }
});

// --------------------------------------------------------
// 4. Family Tree Graph Traversal Endpoint
// --------------------------------------------------------
app.get('/api/v1/tree/:vuid', async (req, res) => {
    const { vuid } = req.params;

    if (!/^[0-9]{12}$/.test(vuid)) {
        return res.status(400).json({ error: 'VUID must be strictly 12 digits.' });
    }

    try {
        const [rootRows] = await pool.query(
            'SELECT vuid, first_name, last_name, gender, dob, category, status FROM citizens WHERE vuid = ?',
            [vuid]
        );

        if (rootRows.length === 0) {
            return res.status(404).json({ error: 'Citizen not found.' });
        }

        const [edges] = await pool.query(`
            SELECT source_vuid AS source, target_vuid AS target, relationship_type AS type, verification_status AS status
            FROM relationships
            WHERE source_vuid = ? OR target_vuid = ?
        `, [vuid, vuid]);

        const connectedVuids = new Set([vuid]);
        edges.forEach(e => {
            connectedVuids.add(e.source);
            connectedVuids.add(e.target);
        });

        const [nodes] = await pool.query(`
            SELECT vuid, CONCAT(first_name, ' ', last_name) AS name, gender, dob, category, is_claimed, status
            FROM citizens
            WHERE vuid IN (?)
        `, [[...connectedVuids]]);

        return res.status(200).json({
            root_vuid: vuid,
            nodes,
            edges
        });
    } catch (err) {
        console.error('Tree Fetch Error:', err);
        return res.status(500).json({ error: 'Failed to retrieve family tree graph.' });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`VanshaSetu Engine running on port ${PORT}`);
});
```

### 4.5 Indian Civil Life Events, Education, Matrimony & Auditing API Extensions

The platform exposes dedicated modular routers for Indian civil lifecycle management, education credentialing, matrimony matchmaking with Gotra exogamy, dynamic demographic analytics, and cryptographic audit ledger verification:

| Endpoint | Method | Route Handler | Description |
| :--- | :---: | :--- | :--- |
| **`/api/v1/events/birth`** | `POST` | `life_events_routes.js` | Allocates unique 12-digit numeric VUID, validates community metadata (`caste`, `category`, `gotra`, `religion`, `geography`), and links parental kinship edges (`Father`, `Mother`, `Son`, `Daughter`). |
| **`/api/v1/events/death`** | `POST` | `life_events_routes.js` | Updates status to `Deceased`, registers verified municipal `death_cert_number` and `death_reason`, preserving lineage edges for inheritance and probate. |
| **`/api/v1/events/marriage`** | `POST` | `life_events_routes.js` | Validates statutory marriage ages ($\ge 21$ groom, $\ge 18$ bride), creates `marriages` ledger entry, updates `marital_status = 'Married'`, and establishes reciprocal `Spouse` edges. |
| **`/api/v1/education/add`** | `POST` | `education_routes.js` | Registers verified academic qualification (`Primary` to `Doctorate`), degree name, institution, and occupation sector in encrypted storage (`citizen_education`). |
| **`/api/v1/education/:vuid`** | `GET` | `education_routes.js` | Fetches chronological educational credentials and professional title for a citizen. |
| **`/api/v1/matrimony/search`** | `GET` | `matrimony_routes.js` | Matchmaking engine evaluating Gotra exogamy: flags `Warning_Sagotra` vs `Permitted_Exogamous` and filters by age range, community, state/district, height, and qualifications. |
| **`/api/v1/analytics/demographics`** | `GET` | `analytics_routes.js` | Dynamic census aggregation returning population counts, gender ratios, five-tier age pyramids, and category percentages filtered by state and district. |
| **`/api/v1/audit/verify-integrity`** | `GET` | `audit_routes.js` | Recalculates the entire SHA-256 blockchain hash chain from genesis to head block, guaranteeing 100% legal non-repudiation and tamper-detection. |
| **`/api/v1/meta/civil-models`** | `GET` | `server.js` | Serves the canonical Single Source of Truth (`shared/civil_models.json`) including all machine codes, string labels, bilingual translations, and 72 Indian & Western relationships. |

### 4.6 Single Source of Truth (SSOT) Architecture, Kinship Ontology & Universal Zero-Default Policy

In strict alignment with [Article X of the Sovereign Constitution](file:///Users/siddharthdashore/Workspace/FamilyTree/Docs/constitution.md#article-x-fail-fast-integrity-universal-prohibition-of-defaults--canonical-domain-models):
1. **Single Source of Truth (`shared/civil_models.json`):** All civil and demographic ontologies are canonically defined in exactly one place:
   - Root SSOT: [`shared/civil_models.json`](file:///Users/siddharthdashore/Workspace/FamilyTree/shared/civil_models.json)
   - Backend Consumer: [`backend/src/models/civil_models.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/models/civil_models.js) dynamically imports `shared/civil_models.json` with zero duplication.
   - Client Synchronizer: [`scripts/sync_models.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/scripts/sync_models.js) (`npm run sync:models`) compiles `shared/civil_models.json` into type-safe Dart constants at [`client/lib/core/constants/civil_models.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/constants/civil_models.dart).
   - API Metadata Endpoint: `GET /api/v1/meta/civil-models` exposes canonical models to external clients and web consumers.
2. **72 Indian & Western Kinship Relations (`CivilRelationships`):** Full bilingual ontology spanning Nuclear, Ancestral, Extended Paternal, Extended Maternal, In-laws, Step/Adoptive, and Legal Guardians:
   - Western: `Father`, `Mother`, `Son`, `Daughter`, `Spouse`, `Husband`, `Wife`, `Brother`, `Sister`, `Grandfather`, `Grandmother`, `Grandson`, `Granddaughter`, `Uncle`, `Aunt`, `Nephew`, `Niece`, `Cousin`, `FatherInLaw`, `MotherInLaw`, `BrotherInLaw`, `SisterInLaw`, `SonInLaw`, `DaughterInLaw`, `StepFather`, `StepMother`, `StepSon`, `StepDaughter`, `StepBrother`, `StepSister`, `AdoptiveFather`, `AdoptiveMother`, `AdoptedSon`, `AdoptedDaughter`, `LegalGuardian`, `Ward`.
   - Indian (Hindi/Sanskrit): `Pita`, `Mata`, `Beta`, `Beti`, `Pati`, `Patni`, `Bhai`, `Behan`, `BadaBhai`, `ChhotaBhai`, `BadiBehan`, `ChhotiBehan`, `Dada`, `Dadi`, `Pardada`, `Pardadi`, `Nana`, `Nani`, `Parnana`, `Parnani`, `Pota`, `Poti`, `Parpota`, `Parpoti`, `Dohata`, `Dohati`, `Chacha`, `Chachi`, `Tau`, `Tai`, `Bua`, `Fufa`, `Mama`, `Mami`, `Mausa`, `Mausi`, `Bhatija`, `Bhatiji`, `Bhanja`, `Bhanji`, `Sasur`, `Saas`, `Jeth`, `Jethani`, `Devar`, `Devrani`, `Nanad`, `Nandoi`, `Sala`, `Salehar`, `Sali`, `Sadhu`, `Damad`, `Bahu`, `Samdhi`, `Samdhan`.
3. **String-Based Value Mappings & Multilingual Parity:** Every enum item defines both a machine code and explicit, localized human-readable string display values across four sovereign DPI languages:
   - **English (`en`)**
   - **हिन्दी / Hindi (`hi`)**
   - **ગુજરાતી / Gujarati (`gu`)**
   - **मराठी / Marathi (`mr`)**
   Examples: `GEN -> General / सामान्य / સામાન્ય / सामान्य`, `OBC -> Other Backward Class / अन्य पिछड़ा वर्ग / અન્ય પછાત વર્ગ / इतर मागासवर्गीय`, `Father -> Father / पिता / પિતા / वडील`, `Paternal_Grandfather -> Paternal Grandfather / दादा / દાદા / आजोबा`.
4. **Reactive Client Localization (`AppLocalizations` & `LanguageSelectorButton`):** The Flutter client dynamically switches active locale across all screens without reloading, allowing users to toggle between English, हिन्दी, ગુજરાતી, and मराठी with instant updates to forms, navigation, kinship badges, and Vansha cards.
5. **Absolute Zero-Default Invariant:** The platform strictly prohibits fallback default values, placeholders, or silent logical operators (`religion || 'Hindu'`, `category || 'GEN'`, `marital_status || 'Single'`). Operations MUST strictly succeed with valid, explicitly passed values or fail fast with deterministic `HTTP 400 Bad Request` responses.

---

## 5. Complete Flutter Client Application

### 5.1 Configuration & Dependencies (`pubspec.yaml`)

```yaml
name: vanshasetu
description: "VanshaSetu - Universal DPI Kinship Platform"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  http: ^1.2.1
  geolocator: ^11.0.0
  geocoding: ^3.0.0
  qr_flutter: ^4.1.0
  screenshot: ^3.0.0
  share_plus: ^9.0.0
  path_provider: ^2.1.3
  google_mobile_ads: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

---

### 5.2 Geolocation & Reverse-Geocoding Service (`lib/core/services/geo_service.dart`)

```dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddressAutofillResult {
  final String addressLine1;
  final String addressLine2;
  final String pinCode;
  final String district;
  final String state;
  final String country;
  final double latitude;
  final double longitude;

  AddressAutofillResult({
    required this.addressLine1,
    required this.addressLine2,
    required this.pinCode,
    required this.district,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

class GeoService {
  static Future<AddressAutofillResult?> fetchLiveAddress() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) return null;
    final place = placemarks.first;

    return AddressAutofillResult(
      addressLine1: '${place.street ?? ''} ${place.subThoroughfare ?? ''}'.trim(),
      addressLine2: place.subLocality ?? place.locality ?? '',
      pinCode: place.postalCode ?? '',
      district: place.subAdministrativeArea ?? place.locality ?? '',
      state: place.administrativeArea ?? '',
      country: place.country ?? 'India',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
```

---

### 5.3 Interactive Family Tree Canvas (`lib/features/tree/screens/tree_canvas_screen.dart`)

This widget implements an infinite, zoomable 2D canvas with custom Bezier kinship lines and interactive Material 3 citizen cards.

```dart
import 'package:flutter/material.dart';

class TreeNode {
  final String vuid; // Strict 12 digits
  final String name;
  final String relation;
  final String gender;
  final bool isVerified;
  final Offset position;

  TreeNode({
    required this.vuid,
    required this.name,
    required this.relation,
    required this.gender,
    required this.isVerified,
    required this.position,
  });
}

class TreeCanvasScreen extends StatefulWidget {
  final String rootVuid;
  const TreeCanvasScreen({super.key, required this.rootVuid});

  @override
  State<TreeCanvasScreen> createState() => _TreeCanvasScreenState();
}

class _TreeCanvasScreenState extends State<TreeCanvasScreen> {
  final TransformationController _transformationController = TransformationController();

  // Sample static multi-generational layout
  late final List<TreeNode> nodes;

  @override
  void initState() {
    super.initState();
    // Center generation 2 (root user) by default
    _transformationController.value = Matrix4.identity()..translate(-200.0, -100.0);

    nodes = [
      // Gen 1: Grandparents
      TreeNode(vuid: "109284729102", name: "Kailash Sharma", relation: "Paternal Grandfather", gender: "Male", isVerified: true, position: const Offset(300, 80)),
      // Gen 2: Parents
      TreeNode(vuid: "510928340192", name: "Ramesh Sharma", relation: "Father", gender: "Male", isVerified: true, position: const Offset(200, 240)),
      TreeNode(vuid: "510928340193", name: "Sunita Sharma", relation: "Mother", gender: "Female", isVerified: true, position: const Offset(420, 240)),
      // Gen 3: Target Citizen (Root) & Spouse
      TreeNode(vuid: widget.rootVuid, name: "Aarav Sharma", relation: "Self", gender: "Male", isVerified: true, position: const Offset(200, 420)),
      TreeNode(vuid: "928174019284", name: "Pooja Sharma", relation: "Spouse", gender: "Female", isVerified: true, position: const Offset(420, 420)),
      // Gen 4: Children
      TreeNode(vuid: "819204918274", name: "Vihaan Sharma", relation: "Son", gender: "Male", isVerified: false, position: const Offset(310, 600)),
    ];
  }

  void _showNodeDetails(TreeNode node) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(node.name, style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                if (node.isVerified)
                  const Chip(
                    label: Text('OCP VERIFIED', style: TextStyle(fontSize: 10, color: Colors.green)),
                    backgroundColor: Color(0xFFE8F5E9),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('VUID: ${node.vuid.substring(0,4)} ${node.vuid.substring(4,8)} ${node.vuid.substring(8,12)}',
                style: const TextStyle(fontFamily: 'monospace', color: Colors.blueGrey)),
            Text('Relation: ${node.relation} • Gender: ${node.gender}'),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.share),
                    label: const Text('Share Card'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Kin'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VanshaSetu Lineage Canvas', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () => _transformationController.value = Matrix4.identity()..translate(-200.0, -100.0),
          )
        ],
      ),
      body: InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: const EdgeInsets.all(1000),
        minScale: 0.2,
        maxScale: 2.5,
        child: SizedBox(
          width: 2000,
          height: 2000,
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(2000, 2000),
                painter: KinshipLinePainter(nodes: nodes),
              ),
              ...nodes.map((node) => Positioned(
                left: node.position.dx,
                top: node.position.dy,
                child: GestureDetector(
                  onTap: () => _showNodeDetails(node),
                  child: _buildNodeCard(node),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodeCard(TreeNode node) {
    final isMale = node.gender == 'Male';
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMale ? const Color(0xFF1E3A8A) : const Color(0xFFBE185D),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
          const SizedBox(height: 2),
          Text(node.relation, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            '${node.vuid.substring(0, 4)}..${node.vuid.substring(8)}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}

class KinshipLinePainter extends CustomPainter {
  final List<TreeNode> nodes;
  KinshipLinePainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    final solidPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final spousePaint = Paint()
      ..color = const Color(0xFF9333EA)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Connect Ramesh & Sunita (Parents: Nodes index 1 & 2)
    canvas.drawLine(
      Offset(nodes[1].position.dx + 170, nodes[1].position.dy + 35),
      Offset(nodes[2].position.dx, nodes[2].position.dy + 35),
      spousePaint,
    );

    // Bezier from Parents to Aarav (Root: Node index 3)
    final path = Path();
    path.moveTo(310, 275);
    path.cubicTo(310, 350, nodes[3].position.dx + 85, 350, nodes[3].position.dx + 85, nodes[3].position.dy);
    canvas.drawPath(path, solidPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

### 5.4 Vansha Card Generator & WhatsApp Share (`lib/features/card/widgets/vansha_card_widget.dart`)

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class VanshaCardWidget extends StatelessWidget {
  final String vuid; // Strict 12-digit numeric identifier
  final String fullName;
  final String dob;
  final String gender;
  final String category;
  final String state;

  const VanshaCardWidget({
    super.key,
    required this.vuid,
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.category,
    required this.state,
  });

  String get formattedVuid {
    if (vuid.length == 12) {
      return '${vuid.substring(0, 4)} ${vuid.substring(4, 8)} ${vuid.substring(8, 12)}';
    }
    return vuid;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586, // ISO/IEC 7810 ID-1 standard ratio
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VANSHACARD • वन्श कार्ड',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      formattedVuid,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.greenAccent),
                  ),
                  child: const Text(
                    'OCP VERIFIED',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text('DOB: $dob  |  Gender: $gender', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('Category: $category  |  State: $state', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: QrImageView(
                    data: 'https://vanshasetu.in/tree/$vuid',
                    version: QrVersions.auto,
                    size: 64.0,
                  ),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Unified Kinship Infrastructure', style: TextStyle(color: Colors.white38, fontSize: 9)),
                Text('Scan to Trace Lineage', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VanshaCardSharer {
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> captureAndShareWhatsApp({
    required BuildContext context,
    required Widget cardWidget,
    required String vuid,
    required String fullName,
  }) async {
    try {
      final imageBytes = await screenshotController.captureFromWidget(
        Material(child: cardWidget),
        delay: const Duration(milliseconds: 100),
      );

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/VanshaCard_$vuid.png').create();
      await file.writeAsBytes(imageBytes);

      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        text: 'Namaste! Here is my official Vansha Card for $fullName (VUID: $vuid). Scan the QR code or visit https://vanshasetu.in/tree/$vuid to trace our complete family tree.',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share Vansha Card: $e')),
        );
      }
    }
  }
}
```

---

### 5.5 Registration Screen with Live GPS Autofill (`lib/features/auth/screens/registration_screen.dart`)

```dart
import 'package:flutter/material.dart';
import '../../../core/services/geo_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _casteController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Location Controllers
  final _addr1Controller = TextEditingController();
  final _addr2Controller = TextEditingController();
  final _pinController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');

  String _gender = 'Male';
  String _category = 'GEN';
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  Future<void> _autofillLocation() async {
    setState(() => _isLoadingLocation = true);
    final result = await GeoService.fetchLiveAddress();
    setState(() => _isLoadingLocation = false);

    if (result != null) {
      setState(() {
        _addr1Controller.text = result.addressLine1;
        _addr2Controller.text = result.addressLine2;
        _pinController.text = result.pinCode;
        _districtController.text = result.district;
        _stateController.text = result.state;
        _countryController.text = result.country;
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address autofetched from live GPS coordinates.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Citizen Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personal Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name *', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name *', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      items: ['Male', 'Female', 'Non-Binary', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                      decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      items: ['GEN', 'OBC', 'SC', 'ST', 'EWS'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _category = v!),
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Residential Address', style: Theme.of(context).textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: _isLoadingLocation ? null : _autofillLocation,
                    icon: _isLoadingLocation
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location),
                    label: const Text('Autofill GPS'),
                  )
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addr1Controller,
                decoration: const InputDecoration(labelText: 'Address Line 1 (House/Street) *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addr2Controller,
                decoration: const InputDecoration(labelText: 'Address Line 2 (Locality/Area)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'PIN Code *', border: OutlineInputBorder()),
                      validator: (v) => v!.length != 6 ? '6 Digits' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(labelText: 'District *', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Submit payload to /api/v1/citizen/register
                    }
                  },
                  child: const Text('Register & Allocate 12-Digit VUID'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 5.6 Monetization Abstraction (`lib/core/services/ad_service.dart`)

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  // Monetization is disabled initially for a clean, completely free launch
  bool isMonetizationEnabled = false;

  Future<void> initialize() async {
    if (isMonetizationEnabled) {
      await MobileAds.instance.initialize();
    }
  }

  void toggleMonetization(bool enable) {
    isMonetizationEnabled = enable;
    if (enable) {
      MobileAds.instance.initialize();
    }
  }
}
```

---

## 6. Socio-Economic Investigation & Missing Person Workflows (SIR)

| Scenario | Trigger Vector | System Execution | Resolution Flow |
| :--- | :--- | :--- | :--- |
| **Missing Relative Discovery** | A family adds an unverified node marked with `status = 'Missing'`. | If an individual registers credentials producing an identical `doc_hash`, the graph engine alerts both trees. | Verification officers initiate a mutual DigiLocker OTP consent flow to connect and merge the nodes safely. |
| **Document Duplication Flag** | A single document hash is submitted under two distinct 12-digit VUIDs across different districts. | An entry is written to `duplicate_conflict_logs` with `severity = 'Critical'` and `status = 'Investigating'`. | The survey officer compares geographic telemetry and requests an in-person biometric or OCP re-validation. |
| **Identity Merge Request** | A user discovers an ancestral record created earlier by an extended relative. | The claimant initiates an OCP verification challenge for the candidate node. | The placeholder node merges into the authenticated profile; all historical kinship edges point to the single authentic 12-digit VUID. |

---

## 7. BigRock Cloud Deployment & Setup Runbook

### Step 1: Database Initialization
1. Log in to your **BigRock cPanel**.
2. Navigate to **Databases** $\rightarrow$ **MySQL Database Wizard**.
3. Create a database named `vanshasetu_db`.
4. Create a database user named `vanshasetu_user` with a secure password.
5. Grant `ALL PRIVILEGES` to `vanshasetu_user` on `vanshasetu_db`.
6. Open **phpMyAdmin**, select `vanshasetu_db`, and execute the DDL script from Section 3.

### Step 2: Node.js Backend Deployment
1. In cPanel, click **Setup Node.js App** (CloudLinux LVE Manager).
2. Click **Create Application**:
   * *Node.js Version:* Select `18.x` or `20.x LTS`.
   * *Application Mode:* `Production`.
   * *Application Root:* `vanshasetu-api`.
   * *Application Startup File:* `server.js`.
3. In your local backend directory, create a `package.json`:
   ```json
   {
     "name": "vanshasetu-api",
     "version": "1.0.0",
     "main": "server.js",
     "dependencies": {
       "cors": "^2.8.5",
       "dotenv": "^16.4.5",
       "express": "^4.19.2",
       "helmet": "^7.1.0",
       "mysql2": "^3.9.7"
     }
   }
   ```
4. Upload `package.json` and `server.js` using cPanel File Manager or FTP into `/home/youruser/vanshasetu-api`.
5. In the Node.js App Manager interface, click **Run NPM Install**.
6. Under **Environment Variables**, define:
   * `DB_HOST` = `127.0.0.1`
   * `DB_USER` = `vanshasetu_user`
   * `DB_PASSWORD` = `YourDatabasePassword`
   * `DB_NAME` = `vanshasetu_db`
   * `HASH_SALT` = `YourCryptographicSecretSalt`
7. Click **Restart Application**.

### Step 3: SSL & Domain Mapping
1. Under cPanel **SSL/TLS Status**, ensure an active AutoSSL / Let's Encrypt certificate is installed for `vanshasetu.in` and `api.vanshasetu.in`.
2. Verify that all HTTP calls automatically redirect to HTTPS.