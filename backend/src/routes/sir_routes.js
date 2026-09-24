const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');
const { verifyAuditChainIntegrity, logAuditEvent } = require('../services/audit_service');
const { sendSecureResponse } = require('../middleware/security_guard');

/**
 * GET /api/v1/sir/conflicts
 * Fetches duplicate conflict incidents logged for Special Investigation Registry (SIR).
 */
router.get('/conflicts', async (req, res) => {
    const { status, severity, limit = 50, offset = 0 } = req.query;

    try {
        let query = `
            SELECT 
                d.id, d.flagged_vuid, d.matched_vuid, d.doc_type,
                d.conflict_reason, d.status, d.severity, d.created_at,
                c1.first_name AS flagged_first_name, c1.last_name AS flagged_last_name, c1.district AS flagged_district,
                c2.first_name AS matched_first_name, c2.last_name AS matched_last_name, c2.district AS matched_district
            FROM duplicate_conflict_logs d
            JOIN citizens c1 ON d.flagged_vuid = c1.vuid
            JOIN citizens c2 ON d.matched_vuid = c2.vuid
            WHERE 1=1
        `;
        const params = [];

        if (status) {
            query += ' AND d.status = ?';
            params.push(status);
        }
        if (severity) {
            query += ' AND d.severity = ?';
            params.push(severity);
        }

        query += ' ORDER BY d.created_at DESC LIMIT ? OFFSET ?';
        params.push(parseInt(limit, 10), parseInt(offset, 10));

        const [rows] = await pool.query(query, params);

        return sendSecureResponse(req, res, 200, {
            success: true,
            count: rows.length,
            conflicts: rows
        });
    } catch (err) {
        console.error('Fetch Conflicts Error:', err);
        return res.status(500).json({ error: 'Failed to retrieve SIR conflict records.' });
    }
});

/**
 * GET /api/v1/audit/logs
 * Retrieves immutable HIPAA audit trail entries (Admin/Compliance Officers).
 */
router.get('/logs', async (req, res) => {
    const { limit = 100, offset = 0 } = req.query;

    try {
        const [rows] = await pool.query(
            'SELECT id, actor_vuid, action, resource_type, resource_id, ip_address, status, prev_log_hash, log_hash, created_at FROM audit_logs ORDER BY id DESC LIMIT ? OFFSET ?',
            [parseInt(limit, 10), parseInt(offset, 10)]
        );

        return sendSecureResponse(req, res, 200, {
            success: true,
            count: rows.length,
            logs: rows
        });
    } catch (err) {
        console.error('Fetch Audit Logs Error:', err);
        return res.status(500).json({ error: 'Failed to retrieve audit log records.' });
    }
});

/**
 * GET /api/v1/audit/verify-integrity
 * Verifies mathematical hash chain integrity of the entire audit_logs table.
 */
router.get('/verify-integrity', async (req, res) => {
    try {
        const result = await verifyAuditChainIntegrity();
        return res.status(result.valid ? 200 : 409).json({
            success: result.valid,
            chain_integrity: result.valid ? 'INTACT' : 'TAMPERED',
            details: result
        });
    } catch (err) {
        return res.status(500).json({ error: 'Integrity verification failed.' });
    }
});

module.exports = router;
