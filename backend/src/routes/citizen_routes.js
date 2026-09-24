const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');
const { allocateUniqueVUID, isValidVUID, formatVUID } = require('../services/vuid_service');
const { encryptField, decryptField } = require('../services/crypto_service');
const { logAuditEvent } = require('../services/audit_service');
const { sendSecureResponse } = require('../middleware/security_guard');

/**
 * POST /api/v1/citizen/register
 * Registers citizen, allocates strictly 12-digit VUID, encrypts ePHI attributes,
 * and logs immutable audit trail per HIPAA § 164.312(b).
 */
router.post('/register', async (req, res) => {
    const {
        first_name, middle_name, last_name, gender, dob,
        height_cm, weight_kg, caste, category = 'GEN',
        address_line1, address_line2, pin_code, district, state, country = 'India',
        latitude, longitude, health_notes
    } = req.body;

    // Validate mandatory fields
    if (!first_name || !last_name || !gender || !dob || !pin_code || !district || !state) {
        return res.status(400).json({ error: 'Missing mandatory registration fields.' });
    }

    if (!/^[0-9]{6}$/.test(String(pin_code).trim())) {
        return res.status(400).json({ error: 'PIN Code must be strictly 6 digits.' });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Allocate guaranteed unique 12-digit VUID
        const vuid = await allocateUniqueVUID(connection);

        // 2. Field-Level Encryption (AES-256-GCM) for sensitive ePHI / health data
        const ephiPayload = {
            height_cm: height_cm ? parseFloat(height_cm) : null,
            weight_kg: weight_kg ? parseFloat(weight_kg) : null,
            health_notes: health_notes || null
        };
        const encryptedEphi = encryptField(ephiPayload);

        // 3. Insert into citizens table
        const insertQuery = `
            INSERT INTO citizens (
                vuid, first_name, middle_name, last_name, gender, dob,
                height_cm, weight_kg, ephi_encrypted_data, ephi_iv, ephi_auth_tag,
                caste, category,
                address_line1, address_line2, pin_code, district, state, country,
                latitude, longitude, is_claimed, status
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE, 'Active')
        `;

        await connection.query(insertQuery, [
            vuid,
            first_name.trim(),
            middle_name ? middle_name.trim() : null,
            last_name.trim(),
            gender,
            dob,
            height_cm || null,
            weight_kg || null,
            encryptedEphi.ciphertext,
            encryptedEphi.iv,
            encryptedEphi.authTag,
            caste ? caste.trim() : null,
            category,
            address_line1 || null,
            address_line2 || null,
            String(pin_code).trim(),
            district.trim(),
            state.trim(),
            country.trim(),
            latitude ? parseFloat(latitude) : null,
            longitude ? parseFloat(longitude) : null
        ]);

        // 4. Record HIPAA § 164.312(b) Immutable Audit Log
        await logAuditEvent({
            actor_vuid: vuid,
            action: 'CREATE',
            resource_type: 'CITIZEN',
            resource_id: vuid,
            ip_address: req.ip || '127.0.0.1',
            user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
            status: 'SUCCESS',
            details: { category, district, state }
        }, connection);

        await connection.commit();

        const responseData = {
            success: true,
            message: 'Citizen registered successfully with allocated 12-digit VUID.',
            data: {
                vuid,
                formatted_vuid: formatVUID(vuid),
                full_name: `${first_name} ${middle_name ? middle_name + ' ' : ''}${last_name}`.trim(),
                gender,
                category,
                registered_at: new Date().toISOString()
            }
        };

        return sendSecureResponse(req, res, 201, responseData);
    } catch (err) {
        await connection.rollback();
        console.error('Registration Error:', err);
        return res.status(500).json({ error: 'Internal Server Error during citizen registration.' });
    } finally {
        connection.release();
    }
});

/**
 * GET /api/v1/citizen/:vuid
 * Fetches citizen profile, decrypts ePHI metadata if authenticated, and logs access.
 */
router.get('/:vuid', async (req, res) => {
    const { vuid } = req.params;

    if (!isValidVUID(vuid)) {
        return res.status(400).json({ error: 'VUID must be strictly 12 numeric digits.' });
    }

    try {
        const [rows] = await pool.query(
            'SELECT * FROM citizens WHERE vuid = ? LIMIT 1',
            [vuid]
        );

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Citizen record not found.' });
        }

        const citizen = rows[0];

        // Decrypt ePHI data if present
        let decryptedEphi = null;
        if (citizen.ephi_encrypted_data && citizen.ephi_iv && citizen.ephi_auth_tag) {
            try {
                const decryptedStr = decryptField(
                    citizen.ephi_encrypted_data,
                    citizen.ephi_iv,
                    citizen.ephi_auth_tag
                );
                decryptedEphi = JSON.parse(decryptedStr);
            } catch (decErr) {
                console.warn('ePHI decryption failed for VUID:', vuid);
            }
        }

        // Log HIPAA Read Access
        await logAuditEvent({
            actor_vuid: req.headers['x-actor-vuid'] || vuid,
            action: 'READ',
            resource_type: 'CITIZEN',
            resource_id: vuid,
            ip_address: req.ip || '127.0.0.1',
            user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
            status: 'SUCCESS'
        });

        const profile = {
            vuid: citizen.vuid,
            formatted_vuid: formatVUID(citizen.vuid),
            first_name: citizen.first_name,
            middle_name: citizen.middle_name,
            last_name: citizen.last_name,
            full_name: `${citizen.first_name} ${citizen.middle_name ? citizen.middle_name + ' ' : ''}${citizen.last_name}`.trim(),
            gender: citizen.gender,
            dob: citizen.dob,
            height_cm: decryptedEphi?.height_cm ?? citizen.height_cm,
            weight_kg: decryptedEphi?.weight_kg ?? citizen.weight_kg,
            health_notes: decryptedEphi?.health_notes ?? null,
            caste: citizen.caste,
            category: citizen.category,
            address: {
                line1: citizen.address_line1,
                line2: citizen.address_line2,
                pin_code: citizen.pin_code,
                district: citizen.district,
                state: citizen.state,
                country: citizen.country
            },
            coordinates: {
                latitude: citizen.latitude,
                longitude: citizen.longitude
            },
            is_claimed: Boolean(citizen.is_claimed),
            status: citizen.status,
            created_at: citizen.created_at
        };

        return sendSecureResponse(req, res, 200, { success: true, data: profile });
    } catch (err) {
        console.error('Fetch Citizen Error:', err);
        return res.status(500).json({ error: 'Failed to retrieve citizen record.' });
    }
});

module.exports = router;
