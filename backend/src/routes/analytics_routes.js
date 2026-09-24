const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');
const { logAuditEvent } = require('../services/audit_service');
const { sendSecureResponse } = require('../middleware/security_guard');
const {
    validateReligion,
    validateMaritalStatus,
    validateCategory,
    validateGender
} = require('../models/civil_models');

function calculateAge(dobString) {
    if (!dobString) return null;
    const dob = new Date(dobString);
    const diffMs = Date.now() - dob.getTime();
    const ageDate = new Date(diffMs);
    return Math.abs(ageDate.getUTCFullYear() - 1970);
}

/**
 * GET /api/v1/analytics/demographics
 * Returns real-time population count and multi-dimensional demographic analytics
 * filtered by state, district, category, caste, religion, gender, age, and marital status.
 * Constitutional Invariant: Validates query parameters against canonical models.
 */
router.get('/demographics', async (req, res) => {
    const {
        state,
        district,
        category,
        caste,
        religion,
        gender,
        marital_status,
        min_age,
        max_age,
        include_deceased = 'false'
    } = req.query;

    if (gender) {
        const err = validateGender(gender);
        if (err) return res.status(400).json({ error: err });
    }
    if (category) {
        const err = validateCategory(category);
        if (err) return res.status(400).json({ error: err });
    }
    if (religion) {
        const err = validateReligion(religion);
        if (err) return res.status(400).json({ error: err });
    }
    if (marital_status) {
        const err = validateMaritalStatus(marital_status);
        if (err) return res.status(400).json({ error: err });
    }

    try {
        const [citizens] = await pool.query('SELECT vuid, gender, dob, category, caste, gotra, religion, marital_status, district, state, is_claimed, status FROM citizens');

        const filtered = citizens.filter(c => {
            if (include_deceased !== 'true' && c.status === 'Deceased') return false;
            if (state && c.state && !c.state.toLowerCase().includes(state.toLowerCase())) return false;
            if (district && c.district && !c.district.toLowerCase().includes(district.toLowerCase())) return false;
            if (category && c.category !== category) return false;
            if (caste && c.caste && !c.caste.toLowerCase().includes(caste.toLowerCase())) return false;
            if (religion && c.religion && c.religion.toLowerCase() !== religion.toLowerCase()) return false;
            if (gender && c.gender !== gender) return false;
            if (marital_status && c.marital_status !== marital_status) return false;

            const age = calculateAge(c.dob);
            if (min_age && age !== null && age < parseInt(min_age, 10)) return false;
            if (max_age && age !== null && age > parseInt(max_age, 10)) return false;

            return true;
        });

        const total = filtered.length;

        // 1. Gender Breakdown
        const genderStats = {
            male: filtered.filter(c => c.gender === 'Male').length,
            female: filtered.filter(c => c.gender === 'Female').length,
            other: filtered.filter(c => !['Male', 'Female'].includes(c.gender)).length
        };

        // 2. Age Distribution Pyramid
        const agePyramid = {
            children_0_14: 0,
            youth_15_24: 0,
            adults_25_59: 0,
            seniors_60_plus: 0
        };

        filtered.forEach(c => {
            const age = calculateAge(c.dob);
            if (age !== null) {
                if (age <= 14) agePyramid.children_0_14++;
                else if (age <= 24) agePyramid.youth_15_24++;
                else if (age <= 59) agePyramid.adults_25_59++;
                else agePyramid.seniors_60_plus++;
            }
        });

        // 3. Category Breakdown (GEN, OBC, SC, ST, EWS)
        const categoryStats = {
            GEN: filtered.filter(c => c.category === 'GEN').length,
            OBC: filtered.filter(c => c.category === 'OBC').length,
            SC: filtered.filter(c => c.category === 'SC').length,
            ST: filtered.filter(c => c.category === 'ST').length,
            EWS: filtered.filter(c => c.category === 'EWS').length
        };

        // 4. Marital Status Breakdown
        const maritalStats = {
            Single: filtered.filter(c => c.marital_status === 'Single').length,
            Married: filtered.filter(c => c.marital_status === 'Married').length,
            Widowed: filtered.filter(c => c.marital_status === 'Widowed').length,
            Divorced: filtered.filter(c => c.marital_status === 'Divorced').length
        };

        // 5. Verification & Claiming Metrics
        const claimedCount = filtered.filter(c => Boolean(c.is_claimed)).length;
        const unclaimedCount = total - claimedCount;

        // Record Audit Trail
        await logAuditEvent({
            actor_vuid: req.headers['x-actor-vuid'] || null,
            action: 'DEMOGRAPHICS_QUERY',
            resource_type: 'ANALYTICS',
            resource_id: `${state || 'ALL'}_${district || 'ALL'}`,
            ip_address: req.ip || '127.0.0.1',
            user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
            status: 'SUCCESS',
            details: { state, district, category, total_returned: total }
        });

        const analyticsData = {
            success: true,
            filter_applied: {
                state: state || 'All India',
                district: district || 'All Districts',
                category: category || 'All Categories',
                caste: caste || 'All Castes',
                religion: religion || 'All Religions',
                gender: gender || 'All Genders',
                marital_status: marital_status || 'All Statuses'
            },
            total_population: total,
            gender_distribution: genderStats,
            age_distribution: agePyramid,
            social_categories: categoryStats,
            marital_status_distribution: maritalStats,
            digital_adoption: {
                claimed_citizens: claimedCount,
                unclaimed_citizens: unclaimedCount,
                claimed_percentage: total > 0 ? parseFloat(((claimedCount / total) * 100).toFixed(1)) : 0.0
            }
        };

        return sendSecureResponse(req, res, 200, analyticsData);
    } catch (err) {
        console.error('Demographics Analytics Error:', err);
        return res.status(500).json({ error: 'Failed to generate demographic population report.' });
    }
});

module.exports = router;
