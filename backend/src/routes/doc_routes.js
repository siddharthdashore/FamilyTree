const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');
const { isValidVUID } = require('../services/vuid_service');
const { hashDocument, maskDocument, encryptField } = require('../services/crypto_service');
const { logAuditEvent } = require('../services/audit_service');
const { sendSecureResponse } = require('../middleware/security_guard');

const VALID_DOC_TYPES = ['AADHAAR', 'PAN', 'VOTER_ID', 'DRIVING_LICENSE', 'PASSPORT', 'RATION_CARD', 'BIRTH_CERTIFICATE'];

/**
 * POST /api/v1/docs/verify-ocp
 * Ingests and verifies identity credential via zero-knowledge salted hashing.
 * Detects cross-citizen duplicate collisions for Special Investigation Registry (SIR).
 */
router.post('/verify-ocp', async (req, res) => {
    const { vuid, doc_type, doc_raw_value, issuer_authority = 'DigiLocker / API Setu', metadata = null } = req.body;

    // 1. Validate Input
    if (!isValidVUID(vuid)) {
        return res.status(400).json({ error: 'VUID must be strictly 12 numeric digits.' });
    }

    if (!doc_type || !VALID_DOC_TYPES.includes(doc_type.toUpperCase())) {
        return res.status(400).json({
            error: `Invalid doc_type. Must be one of: ${VALID_DOC_TYPES.join(', ')}`
        });
    }

    if (!doc_raw_value || String(doc_raw_value).trim().length < 4) {
        return res.status(400).json({ error: 'Valid document value required for verification.' });
    }

    // 2. Cryptographic Salted Hashing & Masking (Zero-Knowledge DPDP Standard)
    const normalizedType = doc_type.toUpperCase();
    const docHash = hashDocument(doc_raw_value);
    const maskedValue = maskDocument(doc_raw_value);

    // 3. Encrypt verification metadata payload via AES-256-GCM
    const encryptedMeta = encryptField(metadata || { verified_channel: 'OCP_DigiLocker', verified_at: new Date().toISOString() });

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // Check citizen existence
        const [citizens] = await connection.query('SELECT vuid FROM citizens WHERE vuid = ?', [vuid]);
        if (citizens.length === 0) {
            await connection.rollback();
            return res.status(404).json({ error: 'Citizen VUID not found in master registry.' });
        }

        // 4. SIR Deduplication Collision Detection
        const [duplicates] = await connection.query(
            'SELECT vuid FROM citizen_documents WHERE doc_hash = ? AND vuid != ?',
            [docHash, vuid]
        );

        let conflictDetected = false;
        let matchedVuid = null;

        if (duplicates.length > 0) {
            conflictDetected = true;
            matchedVuid = duplicates[0].vuid;

            // Log critical anomaly in duplicate_conflict_logs
            await connection.query(`
                INSERT INTO duplicate_conflict_logs 
                (flagged_vuid, matched_vuid, doc_type, conflict_reason, severity, status)
                VALUES (?, ?, ?, 'Document hash collision detected across distinct family lineages', 'Critical', 'Open')
            `, [vuid, matchedVuid, normalizedType]);

            // Record Security SIR Anomaly in Audit Log
            await logAuditEvent({
                actor_vuid: vuid,
                action: 'SIR_FLAG',
                resource_type: 'CONFLICT_LOG',
                resource_id: `${vuid}<->${matchedVuid}`,
                ip_address: req.ip || '127.0.0.1',
                user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
                status: 'FORBIDDEN',
                details: { conflict_type: 'DUPLICATE_ID', doc_type: normalizedType }
            }, connection);
        }

        // 5. Upsert Document Token into citizen_documents
        await connection.query(`
            INSERT INTO citizen_documents (
                vuid, doc_type, doc_hash, doc_masked_value,
                issuer_authority, is_ocp_verified, verified_at,
                raw_payload_encrypted, doc_iv, doc_auth_tag
            ) VALUES (?, ?, ?, ?, ?, TRUE, NOW(), ?, ?, ?)
            ON DUPLICATE KEY UPDATE 
                doc_hash = VALUES(doc_hash),
                doc_masked_value = VALUES(doc_masked_value),
                issuer_authority = VALUES(issuer_authority),
                is_ocp_verified = TRUE,
                verified_at = NOW(),
                raw_payload_encrypted = VALUES(raw_payload_encrypted),
                doc_iv = VALUES(doc_iv),
                doc_auth_tag = VALUES(doc_auth_tag)
        `, [
            vuid, normalizedType, docHash, maskedValue,
            issuer_authority, encryptedMeta.ciphertext, encryptedMeta.iv, encryptedMeta.authTag
        ]);

        // Record Audit Trail
        await logAuditEvent({
            actor_vuid: vuid,
            action: 'VERIFY_OCP',
            resource_type: 'DOCUMENT',
            resource_id: `${vuid}:${normalizedType}`,
            ip_address: req.ip || '127.0.0.1',
            user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
            status: 'SUCCESS',
            details: { doc_type: normalizedType, masked: maskedValue }
        }, connection);

        await connection.commit();

        const responsePayload = {
            success: true,
            conflict_detected: conflictDetected,
            doc_type: normalizedType,
            masked_value: maskedValue,
            is_ocp_verified: true,
            message: conflictDetected
                ? 'Document registered. Cross-lineage duplicate conflict detected and logged for SIR review.'
                : 'Document verified and encrypted in zero-knowledge vault.'
        };

        return sendSecureResponse(req, res, conflictDetected ? 409 : 200, responsePayload);
    } catch (err) {
        await connection.rollback();
        console.error('Doc Verify Error:', err);
        return res.status(500).json({ error: 'Document verification and tokenization failed.' });
    } finally {
        connection.release();
    }
});

module.exports = router;
