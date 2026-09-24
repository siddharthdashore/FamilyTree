const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');
const { isValidVUID, formatVUID } = require('../services/vuid_service');
const { logAuditEvent } = require('../services/audit_service');
const { sendSecureResponse } = require('../middleware/security_guard');
const {
    validateQualificationLevel,
    validateOccupationSector
} = require('../models/civil_models');

/**
 * POST /api/v1/education/add
 * Records an educational degree, certification, or occupation milestone for a citizen.
 * Constitutional Invariant: NO default values or placeholders. Fails on missing/invalid input.
 */
router.post('/add', async (req, res) => {
    const {
        vuid,
        qualification_level,
        degree_name,
        institution,
        year_of_passing,
        occupation_sector,
        profession_title
    } = req.body;

    if (!isValidVUID(vuid)) {
        return res.status(400).json({ error: 'Citizen VUID must be strictly 12 numeric digits.' });
    }

    const qualErr = validateQualificationLevel(qualification_level);
    if (qualErr) {
        return res.status(400).json({ error: qualErr });
    }

    if (!degree_name || typeof degree_name !== 'string' || !degree_name.trim()) {
        return res.status(400).json({ error: 'degree_name is mandatory and must not be empty.' });
    }

    if (!institution || typeof institution !== 'string' || !institution.trim()) {
        return res.status(400).json({ error: 'institution is mandatory and must not be empty.' });
    }

    const occErr = validateOccupationSector(occupation_sector);
    if (occErr) {
        return res.status(400).json({ error: occErr });
    }

    if (!year_of_passing || isNaN(parseInt(year_of_passing, 10))) {
        return res.status(400).json({ error: 'year_of_passing is mandatory and must be a valid integer.' });
    }

    if (!profession_title || typeof profession_title !== 'string' || !profession_title.trim()) {
        return res.status(400).json({ error: 'profession_title is mandatory and must not be empty.' });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // Check citizen exists
        const [citizens] = await connection.query('SELECT vuid FROM citizens WHERE vuid = ?', [vuid]);
        if (citizens.length === 0) {
            await connection.rollback();
            return res.status(404).json({ error: 'Citizen record not found in master registry.' });
        }

        const insertQuery = `
            INSERT INTO citizen_education (
                vuid, qualification_level, degree_name, institution,
                year_of_passing, occupation_sector, profession_title
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
        `;

        await connection.query(insertQuery, [
            vuid,
            qualification_level,
            degree_name.trim().substring(0, 120),
            institution.trim().substring(0, 180),
            year_of_passing ? parseInt(year_of_passing, 10) : null,
            occupation_sector,
            profession_title ? profession_title.trim().substring(0, 120) : null
        ]);

        // Record Audit Trail
        await logAuditEvent({
            actor_vuid: req.headers['x-actor-vuid'] || vuid,
            action: 'EDUCATION_UPDATE',
            resource_type: 'EDUCATION',
            resource_id: `${vuid}:${qualification_level}`,
            ip_address: req.ip || '127.0.0.1',
            user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
            status: 'SUCCESS',
            details: { degree_name, institution, profession_title }
        }, connection);

        await connection.commit();

        return sendSecureResponse(req, res, 201, {
            success: true,
            message: 'Education qualification and occupation details recorded successfully.',
            data: {
                vuid,
                formatted_vuid: formatVUID(vuid),
                qualification_level,
                degree_name,
                institution,
                year_of_passing,
                occupation_sector,
                profession_title
            }
        });
    } catch (err) {
        await connection.rollback();
        console.error('Education Add Error:', err);
        return res.status(500).json({ error: 'Failed to record education details.' });
    } finally {
        connection.release();
    }
});

/**
 * GET /api/v1/education/:vuid
 * Fetches all educational qualifications and occupational milestones for a citizen.
 */
router.get('/:vuid', async (req, res) => {
    const { vuid } = req.params;

    if (!isValidVUID(vuid)) {
        return res.status(400).json({ error: 'Citizen VUID must be strictly 12 digits.' });
    }

    try {
        const [records] = await pool.query(
            'SELECT * FROM citizen_education WHERE vuid = ? ORDER BY year_of_passing DESC, id DESC',
            [vuid]
        );

        // Record Audit Trail
        await logAuditEvent({
            actor_vuid: req.headers['x-actor-vuid'] || vuid,
            action: 'READ',
            resource_type: 'EDUCATION',
            resource_id: vuid,
            ip_address: req.ip || '127.0.0.1',
            user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
            status: 'SUCCESS'
        });

        return sendSecureResponse(req, res, 200, {
            success: true,
            vuid,
            formatted_vuid: formatVUID(vuid),
            count: records.length,
            education: records
        });
    } catch (err) {
        console.error('Fetch Education Error:', err);
        return res.status(500).json({ error: 'Failed to fetch education records.' });
    }
});

module.exports = router;
