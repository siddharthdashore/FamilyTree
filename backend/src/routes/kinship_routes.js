const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');
const { isValidVUID } = require('../services/vuid_service');
const { logAuditEvent } = require('../services/audit_service');
const { sendSecureResponse } = require('../middleware/security_guard');

const VALID_RELATIONSHIPS = ['Father', 'Mother', 'Spouse', 'Son', 'Daughter', 'Sibling', 'Guardian'];

/**
 * POST /api/v1/kinship/connect
 * Maps a verified directed kinship edge between two 12-digit VUID citizens.
 */
router.post('/connect', async (req, res) => {
    const { source_vuid, target_vuid, relationship_type, verification_status = 'Mutual_Confirmed' } = req.body;

    // 1. Strict 12-digit VUID Validation
    if (!isValidVUID(source_vuid) || !isValidVUID(target_vuid)) {
        return res.status(400).json({ error: 'Both source_vuid and target_vuid must be strictly 12 numeric digits.' });
    }

    if (source_vuid === target_vuid) {
        return res.status(400).json({ error: 'Self-referential kinship links are invalid.' });
    }

    if (!VALID_RELATIONSHIPS.includes(relationship_type)) {
        return res.status(400).json({
            error: `Invalid relationship_type. Must be one of: ${VALID_RELATIONSHIPS.join(', ')}`
        });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // Verify both citizens exist in database
        const [citizens] = await connection.query(
            'SELECT vuid FROM citizens WHERE vuid IN (?, ?)',
            [source_vuid, target_vuid]
        );

        if (citizens.length < 2) {
            await connection.rollback();
            return res.status(404).json({ error: 'One or both citizen VUIDs do not exist in the master registry.' });
        }

        // Upsert primary relationship edge
        const upsertQuery = `
            INSERT INTO relationships (source_vuid, target_vuid, relationship_type, verification_status)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE verification_status = VALUES(verification_status)
        `;
        await connection.query(upsertQuery, [source_vuid, target_vuid, relationship_type, verification_status]);

        // If Spouse, automatically map reciprocal spouse edge
        if (relationship_type === 'Spouse') {
            await connection.query(upsertQuery, [target_vuid, source_vuid, 'Spouse', verification_status]);
        }

        // Record Audit Trail
        await logAuditEvent({
            actor_vuid: source_vuid,
            action: 'UPDATE',
            resource_type: 'RELATIONSHIP',
            resource_id: `${source_vuid}->${target_vuid}`,
            ip_address: req.ip || '127.0.0.1',
            user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
            status: 'SUCCESS',
            details: { relationship_type, verification_status }
        }, connection);

        await connection.commit();

        return sendSecureResponse(req, res, 200, {
            success: true,
            message: 'Kinship relationship successfully established.',
            data: {
                source_vuid,
                target_vuid,
                relationship_type,
                verification_status
            }
        });
    } catch (err) {
        await connection.rollback();
        console.error('Kinship Connect Error:', err);
        return res.status(500).json({ error: 'Failed to record kinship link.' });
    } finally {
        connection.release();
    }
});

module.exports = router;
