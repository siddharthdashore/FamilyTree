const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');
const { allocateUniqueVUID, isValidVUID, formatVUID } = require('../services/vuid_service');
const { logAuditEvent } = require('../services/audit_service');
const { sendSecureResponse } = require('../middleware/security_guard');
const { encryptField } = require('../services/crypto_service');
const {
    validateReligion,
    validateCategory,
    validateGotra,
    validateCaste,
    validateGender
} = require('../models/civil_models');

/**
 * POST /api/v1/events/birth
 * Registers a newborn child with allocated 12-digit VUID, creates lineage edges to both parents,
 * and records an immutable HIPAA § 164.312(b) audit trail.
 * Constitutional Invariant: NO default values or placeholders. Fails on missing/invalid input.
 */
router.post('/birth', async (req, res) => {
    const {
        father_vuid,
        mother_vuid,
        first_name,
        middle_name,
        last_name,
        gender,
        dob,
        weight_kg,
        pin_code,
        district,
        state,
        country,
        caste,
        category,
        gotra,
        religion,
        hospital_name
    } = req.body;

    if (!first_name || !last_name || !gender || !dob) {
        return res.status(400).json({ error: 'Missing mandatory newborn registration attributes.' });
    }

    const genderErr = validateGender(gender);
    if (genderErr) {
        return res.status(400).json({ error: genderErr });
    }

    if (!father_vuid && !mother_vuid) {
        return res.status(400).json({ error: 'At least one parent VUID (father_vuid or mother_vuid) is mandatory for birth registration.' });
    }

    // Validate Father or Mother VUID if provided
    if (father_vuid && !isValidVUID(father_vuid)) {
        return res.status(400).json({ error: 'Father VUID must be strictly 12 digits.' });
    }
    if (mother_vuid && !isValidVUID(mother_vuid)) {
        return res.status(400).json({ error: 'Mother VUID must be strictly 12 digits.' });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Fetch parent metadata to inherit community and address attributes if not explicitly provided
        const parentQueryVuid = father_vuid || mother_vuid;
        const [parents] = await connection.query(
            'SELECT caste, category, gotra, religion, pin_code, district, state, country FROM citizens WHERE vuid = ?',
            [parentQueryVuid]
        );
        if (parents.length === 0) {
            await connection.rollback();
            return res.status(404).json({ error: `Parent record for VUID ${parentQueryVuid} not found.` });
        }

        const parent = parents[0];
        const finalCaste = caste || parent.caste;
        const finalCategory = category || parent.category;
        const finalGotra = gotra || parent.gotra;
        const finalReligion = religion || parent.religion;
        const finalPin = pin_code || parent.pin_code;
        const finalDistrict = district || parent.district;
        const finalState = state || parent.state;
        const finalCountry = country || parent.country;

        const casteErr = validateCaste(finalCaste);
        if (casteErr) {
            await connection.rollback();
            return res.status(400).json({ error: casteErr });
        }

        const catErr = validateCategory(finalCategory);
        if (catErr) {
            await connection.rollback();
            return res.status(400).json({ error: catErr });
        }

        const gotraErr = validateGotra(finalGotra);
        if (gotraErr) {
            await connection.rollback();
            return res.status(400).json({ error: gotraErr });
        }

        const relErr = validateReligion(finalReligion);
        if (relErr) {
            await connection.rollback();
            return res.status(400).json({ error: relErr });
        }

        if (!finalPin || !/^[0-9]{6}$/.test(String(finalPin).trim())) {
            await connection.rollback();
            return res.status(400).json({ error: 'Residential PIN Code is mandatory and must be strictly 6 digits.' });
        }

        if (!finalDistrict || !finalState || !finalCountry) {
            await connection.rollback();
            return res.status(400).json({ error: 'District, State, and Country are mandatory.' });
        }

        // 2. Allocate strictly unique 12-digit VUID for the newborn
        const childVuid = await allocateUniqueVUID(connection);

        // 3. Encrypt medical attributes
        const ephiPayload = {
            weight_kg: weight_kg ? parseFloat(weight_kg) : null,
            hospital_name: hospital_name || null,
            event_type: 'CHILD_BIRTH'
        };
        const encryptedEphi = encryptField(ephiPayload);

        // 4. Insert newborn into citizens table (Single marital status for child)
        const insertQuery = `
            INSERT INTO citizens (
                vuid, first_name, middle_name, last_name, gender, dob,
                weight_kg, ephi_encrypted_data, ephi_iv, ephi_auth_tag,
                caste, category, gotra, religion, marital_status,
                address_line1, pin_code, district, state, country,
                is_claimed, status
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Single', ?, ?, ?, ?, ?, TRUE, 'Active')
        `;

        await connection.query(insertQuery, [
            childVuid,
            first_name.trim(),
            middle_name ? middle_name.trim() : null,
            last_name.trim(),
            gender.trim(),
            dob.trim(),
            weight_kg ? parseFloat(weight_kg) : null,
            encryptedEphi.ciphertext,
            encryptedEphi.iv,
            encryptedEphi.authTag,
            finalCaste.trim(),
            finalCategory.trim(),
            finalGotra.trim(),
            finalReligion.trim(),
            hospital_name ? `Born at ${hospital_name.trim()}` : null,
            String(finalPin).trim(),
            finalDistrict.trim(),
            finalState.trim(),
            finalCountry.trim()
        ]);

        // 5. Connect Parent -> Child kinship directed edges
        const childRelType = gender === 'Female' ? 'Daughter' : 'Son';
        const relUpsertQuery = `
            INSERT INTO relationships (source_vuid, target_vuid, relationship_type, verification_status)
            VALUES (?, ?, ?, 'Document_Backed')
            ON DUPLICATE KEY UPDATE verification_status = 'Document_Backed'
        `;

        if (father_vuid) {
            await connection.query(relUpsertQuery, [father_vuid, childVuid, 'Father']);
        }
        if (mother_vuid) {
            await connection.query(relUpsertQuery, [mother_vuid, childVuid, 'Mother']);
        }

        // 6. Record Immutable Audit Trail
        await logAuditEvent({
            actor_vuid: father_vuid || mother_vuid || childVuid,
            action: 'BIRTH_REGISTRATION',
            resource_type: 'CITIZEN',
            resource_id: childVuid,
            ip_address: req.ip || '127.0.0.1',
            user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
            status: 'SUCCESS',
            details: {
                child_vuid: childVuid,
                father_vuid,
                mother_vuid,
                child_gender: gender,
                child_rel_type: childRelType
            }
        }, connection);

        await connection.commit();

        return sendSecureResponse(req, res, 201, {
            success: true,
            message: 'Child birth successfully registered with allocated 12-digit VUID and lineage edges.',
            data: {
                vuid: childVuid,
                formatted_vuid: formatVUID(childVuid),
                full_name: `${first_name} ${middle_name ? middle_name + ' ' : ''}${last_name}`.trim(),
                gender,
                dob,
                father_vuid,
                mother_vuid,
                registered_at: new Date().toISOString()
            }
        });
    } catch (err) {
        await connection.rollback();
        console.error('Birth Registration Error:', err);
        return res.status(500).json({ error: 'Internal Server Error during birth registration.' });
    } finally {
        connection.release();
    }
});

/**
 * POST /api/v1/events/death
 * Formally marks a citizen as deceased, records death date, certificate and causes,
 * and maintains immutable civil registry audit logging.
 * Constitutional Invariant: NO default values or placeholders. Fails on missing/invalid input.
 */
router.post('/death', async (req, res) => {
    const { vuid, death_date, death_reason, death_cert_number, informant_vuid } = req.body;

    if (!isValidVUID(vuid)) {
        return res.status(400).json({ error: 'Valid 12-digit citizen VUID required.' });
    }

    if (!death_date || typeof death_date !== 'string' || !death_date.trim()) {
        return res.status(400).json({ error: 'Date of death is mandatory.' });
    }

    if (!death_reason || typeof death_reason !== 'string' || !death_reason.trim()) {
        return res.status(400).json({ error: 'Civil death reason is mandatory and must not be empty.' });
    }

    if (!death_cert_number || typeof death_cert_number !== 'string' || !death_cert_number.trim()) {
        return res.status(400).json({ error: 'Municipal death certificate registration number is mandatory.' });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Verify citizen existence
        const [citizens] = await connection.query('SELECT vuid, dob, status FROM citizens WHERE vuid = ?', [vuid]);
        if (citizens.length === 0) {
            await connection.rollback();
            return res.status(404).json({ error: 'Citizen record not found.' });
        }

        const citizen = citizens[0];
        if (new Date(death_date) < new Date(citizen.dob)) {
            await connection.rollback();
            return res.status(400).json({ error: 'Date of death cannot be earlier than date of birth.' });
        }

        // 2. Update status and death fields
        await connection.query(`
            UPDATE citizens 
            SET status = 'Deceased', death_date = ?, death_reason = ?, death_cert_number = ?
            WHERE vuid = ?
        `, [death_date.trim(), death_reason.trim().substring(0, 255), death_cert_number.trim().substring(0, 100), vuid]);

        // 3. Record Audit Trail
        await logAuditEvent({
            actor_vuid: informant_vuid || vuid,
            action: 'DEATH_REGISTRATION',
            resource_type: 'CITIZEN',
            resource_id: vuid,
            ip_address: req.ip || '127.0.0.1',
            user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
            status: 'SUCCESS',
            details: {
                vuid,
                death_date: death_date.trim(),
                death_reason: death_reason.trim(),
                death_cert_number: death_cert_number.trim()
            }
        }, connection);

        await connection.commit();

        return sendSecureResponse(req, res, 200, {
            success: true,
            message: 'Citizen record successfully transitioned to Deceased status.',
            data: {
                vuid,
                status: 'Deceased',
                death_date: death_date.trim(),
                death_reason: death_reason.trim()
            }
        });
    } catch (err) {
        await connection.rollback();
        console.error('Death Registration Error:', err);
        return res.status(500).json({ error: 'Failed to record death certificate.' });
    } finally {
        connection.release();
    }
});

/**
 * POST /api/v1/events/marriage
 * Registers civil / customary marriage between two citizens, verifies exogamy,
 * creates bidirectional spouse edges, and updates marital statuses.
 * Constitutional Invariant: NO default values or placeholders. Fails on missing/invalid input.
 */
router.post('/marriage', async (req, res) => {
    const {
        groom_vuid,
        bride_vuid,
        marriage_date,
        venue_city,
        venue_state,
        marriage_reg_no,
        priest_or_registrar
    } = req.body;

    if (!isValidVUID(groom_vuid) || !isValidVUID(bride_vuid)) {
        return res.status(400).json({ error: 'Both groom_vuid and bride_vuid must be strictly 12 digits.' });
    }

    if (groom_vuid === bride_vuid) {
        return res.status(400).json({ error: 'Groom and Bride cannot be the same citizen entity.' });
    }

    if (!marriage_date || typeof marriage_date !== 'string' || !marriage_date.trim()) {
        return res.status(400).json({ error: 'Date of marriage is mandatory.' });
    }

    if (!venue_city || !venue_state) {
        return res.status(400).json({ error: 'Marriage venue city and state are mandatory.' });
    }

    if (!marriage_reg_no || typeof marriage_reg_no !== 'string' || !marriage_reg_no.trim()) {
        return res.status(400).json({ error: 'Official marriage registration certificate number is mandatory.' });
    }

    if (!priest_or_registrar || typeof priest_or_registrar !== 'string' || !priest_or_registrar.trim()) {
        return res.status(400).json({ error: 'Solemnizing registrar or authority is mandatory.' });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Fetch both citizen records
        const [citizens] = await connection.query('SELECT vuid, gender, dob, gotra, status FROM citizens WHERE vuid IN (?, ?)', [groom_vuid, bride_vuid]);
        if (citizens.length < 2) {
            await connection.rollback();
            return res.status(404).json({ error: 'One or both marriage partners not found in master registry.' });
        }

        const groom = citizens.find(c => c.vuid === groom_vuid);
        const bride = citizens.find(c => c.vuid === bride_vuid);

        if (groom.status === 'Deceased' || bride.status === 'Deceased') {
            await connection.rollback();
            return res.status(400).json({ error: 'Cannot register marriage for a deceased citizen.' });
        }

        // 2. Check for Gotra exogamy warning (traditional Indian custom)
        let gotraWarning = null;
        if (groom.gotra && bride.gotra && groom.gotra.toLowerCase() === bride.gotra.toLowerCase()) {
            gotraWarning = `Sagotra Alert: Both partners share the Gotra '${groom.gotra}'.`;
        }

        // 3. Insert into marriages registry
        const regNo = marriage_reg_no || `VANSHA-MAR-${Date.now().toString().slice(-8)}`;
        await connection.query(`
            INSERT INTO marriages (
                marriage_reg_no, bride_vuid, groom_vuid, marriage_date,
                venue_city, venue_state, priest_or_registrar, status
            ) VALUES (?, ?, ?, ?, ?, ?, ?, 'Registered')
        `, [regNo, bride_vuid, groom_vuid, marriage_date, venue_city || null, venue_state || null, priest_or_registrar || null]);

        // 4. Upsert bidirectional spouse edges
        const upsertSpouse = `
            INSERT INTO relationships (source_vuid, target_vuid, relationship_type, verification_status)
            VALUES (?, ?, 'Spouse', 'Mutual_Confirmed')
            ON DUPLICATE KEY UPDATE verification_status = 'Mutual_Confirmed'
        `;
        await connection.query(upsertSpouse, [groom_vuid, bride_vuid]);
        await connection.query(upsertSpouse, [bride_vuid, groom_vuid]);

        // 5. Update citizens marital_status to 'Married'
        await connection.query("UPDATE citizens SET marital_status = 'Married' WHERE vuid IN (?, ?)", [groom_vuid, bride_vuid]);

        // 6. Record Audit Trail
        await logAuditEvent({
            actor_vuid: groom_vuid,
            action: 'MARRIAGE_REGISTRATION',
            resource_type: 'MARRIAGE',
            resource_id: regNo,
            ip_address: req.ip || '127.0.0.1',
            user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
            status: 'SUCCESS',
            details: {
                marriage_reg_no: regNo,
                groom_vuid,
                bride_vuid,
                marriage_date,
                gotra_warning: gotraWarning
            }
        }, connection);

        await connection.commit();

        return sendSecureResponse(req, res, 201, {
            success: true,
            message: 'Marriage registered successfully with mutual spouse lineage edges established.',
            data: {
                marriage_reg_no: regNo,
                groom_vuid,
                bride_vuid,
                marriage_date,
                gotra_warning: gotraWarning
            }
        });
    } catch (err) {
        await connection.rollback();
        console.error('Marriage Registration Error:', err);
        return res.status(500).json({ error: 'Failed to register marriage record.' });
    } finally {
        connection.release();
    }
});

module.exports = router;
