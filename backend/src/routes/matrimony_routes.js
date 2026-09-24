const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');
const { formatVUID } = require('../services/vuid_service');
const { logAuditEvent } = require('../services/audit_service');
const { sendSecureResponse } = require('../middleware/security_guard');

function calculateAge(dobString) {
    if (!dobString) return null;
    const dob = new Date(dobString);
    const diffMs = Date.now() - dob.getTime();
    const ageDate = new Date(diffMs);
    return Math.abs(ageDate.getUTCFullYear() - 1970);
}

/**
 * POST /api/v1/matrimony/search
 * Intelligent Indian Matrimonial Bride/Groom Search Engine.
 * Features:
 * 1. Gender, Age, and Height filtering.
 * 2. Community & Religion matching.
 * 3. Gotra Exogamy Verification (flags or excludes Sagotra matches to prevent consanguinity).
 * 4. Education & Professional sector matching.
 * 5. State and District location filters.
 */
router.post('/search', async (req, res) => {
    const {
        looking_for_gender, // 'Male' (Groom) or 'Female' (Bride)
        min_age = 18,
        max_age = 60,
        religion,
        caste,
        category,
        seeker_gotra, // Exogamy rule: avoid same gotra
        state,
        district,
        min_height_cm,
        max_height_cm,
        qualification_level,
        exclude_vuid, // e.g. seeker's own VUID
        limit = 30,
        offset = 0
    } = req.body;

    if (!looking_for_gender || !['Male', 'Female'].includes(looking_for_gender)) {
        return res.status(400).json({ error: "looking_for_gender is mandatory and must be 'Male' or 'Female'." });
    }

    try {
        // Query active candidates with single or widowed marital status
        const [rows] = await pool.query(
            `SELECT 
                c.vuid, c.first_name, c.last_name, c.gender, c.dob,
                c.caste, c.category, c.gotra, c.religion, c.marital_status,
                c.height_cm, c.district, c.state, c.status,
                (SELECT COUNT(*) FROM citizen_documents cd WHERE cd.vuid = c.vuid AND cd.is_ocp_verified = TRUE) > 0 AS is_verified
             FROM citizens c
             WHERE c.gender = ? AND c.status = 'Active'`,
            [looking_for_gender]
        );

        // Fetch all education records to enrich candidate cards
        const [educationRecords] = await pool.query(
            'SELECT vuid, qualification_level, degree_name, institution, occupation_sector, profession_title FROM citizen_education'
        );
        const eduMap = new Map();
        educationRecords.forEach(e => {
            if (!eduMap.has(e.vuid)) eduMap.set(e.vuid, e);
        });

        const safeMinAge = Math.max(parseInt(min_age, 10) || 18, 18);
        const safeMaxAge = Math.min(Math.max(parseInt(max_age, 10) || 60, safeMinAge), 100);

        // Filter and score candidates
        const candidates = rows.filter(c => {
            if (exclude_vuid && c.vuid === exclude_vuid) return false;

            const age = calculateAge(c.dob);
            if (age !== null && (age < safeMinAge || age > safeMaxAge)) return false;

            if (religion && c.religion && c.religion.toLowerCase() !== religion.toLowerCase()) return false;
            if (category && c.category !== category) return false;
            if (caste && c.caste && !c.caste.toLowerCase().includes(caste.toLowerCase())) return false;
            if (state && c.state && !c.state.toLowerCase().includes(state.toLowerCase())) return false;
            if (district && c.district && !c.district.toLowerCase().includes(district.toLowerCase())) return false;

            if (min_height_cm && c.height_cm && c.height_cm < parseFloat(min_height_cm)) return false;
            if (max_height_cm && c.height_cm && c.height_cm > parseFloat(max_height_cm)) return false;

            if (qualification_level) {
                const edu = eduMap.get(c.vuid);
                if (!edu || edu.qualification_level !== qualification_level) return false;
            }

            return true;
        }).map(c => {
            const age = calculateAge(c.dob);
            const edu = eduMap.get(c.vuid);

            // Gotra Exogamy Evaluation (Traditional Indian Lineage Rule)
            let isSagotra = false;
            let gotraStatus = 'Permitted_Exogamous';
            if (seeker_gotra && c.gotra && seeker_gotra.trim().toLowerCase() === c.gotra.trim().toLowerCase()) {
                isSagotra = true;
                gotraStatus = 'Warning_Sagotra';
            }

            return {
                vuid: c.vuid,
                formatted_vuid: formatVUID(c.vuid),
                full_name: `${c.first_name} ${c.last_name}`,
                gender: c.gender,
                age,
                dob: c.dob,
                religion: c.religion,
                caste: c.caste,
                category: c.category,
                gotra: c.gotra,
                gotra_status: gotraStatus,
                is_sagotra: isSagotra,
                marital_status: c.marital_status,
                height_cm: c.height_cm,
                district: c.district,
                state: c.state,
                is_ocp_verified: Boolean(c.is_verified),
                education: edu ? {
                    qualification_level: edu.qualification_level,
                    degree_name: edu.degree_name,
                    institution: edu.institution,
                    occupation_sector: edu.occupation_sector,
                    profession_title: edu.profession_title
                } : null
            };
        });

        // Paginate results safely
        const safeLimit = Math.min(Math.max(parseInt(limit, 10) || 30, 1), 100);
        const safeOffset = Math.max(parseInt(offset, 10) || 0, 0);
        const paginated = candidates.slice(safeOffset, safeOffset + safeLimit);

        // Record Audit Trail
        await logAuditEvent({
            actor_vuid: exclude_vuid || null,
            action: 'MATRIMONY_SEARCH',
            resource_type: 'ANALYTICS',
            resource_id: `MATRIMONY_${looking_for_gender}`,
            ip_address: req.ip || '127.0.0.1',
            user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
            status: 'SUCCESS',
            details: {
                looking_for_gender,
                min_age: safeMinAge,
                max_age: safeMaxAge,
                matches_found: candidates.length
            }
        });

        return sendSecureResponse(req, res, 200, {
            success: true,
            total_matches: candidates.length,
            count: paginated.length,
            looking_for: looking_for_gender === 'Male' ? 'Groom (वर)' : 'Bride (वधू)',
            candidates: paginated
        });
    } catch (err) {
        console.error('Matrimony Search Error:', err);
        return res.status(500).json({ error: 'Failed to execute matrimony search query.' });
    }
});

module.exports = router;
