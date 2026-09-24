const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');
const { isValidVUID, formatVUID } = require('../services/vuid_service');
const { logAuditEvent } = require('../services/audit_service');
const { sendSecureResponse } = require('../middleware/security_guard');

/**
 * GET /api/v1/tree/:vuid
 * Retrieves 2-degree kinship ego-network graph for visualization canvas.
 */
router.get('/:vuid', async (req, res) => {
    const { vuid } = req.params;

    if (!isValidVUID(vuid)) {
        return res.status(400).json({ error: 'VUID must be strictly 12 numeric digits.' });
    }

    try {
        // 1. Fetch Root Citizen
        const [rootRows] = await pool.query(
            `SELECT vuid, first_name, middle_name, last_name, gender, dob, category, is_claimed, status 
             FROM citizens WHERE vuid = ? LIMIT 1`,
            [vuid]
        );

        if (rootRows.length === 0) {
            return res.status(404).json({ error: 'Citizen record not found in lineage graph.' });
        }

        const root = rootRows[0];

        // 2. Fetch Directed Kinship Edges
        const [edges] = await pool.query(`
            SELECT 
                source_vuid AS source, 
                target_vuid AS target, 
                relationship_type AS type, 
                verification_status AS status
            FROM relationships
            WHERE source_vuid = ? OR target_vuid = ?
        `, [vuid, vuid]);

        // 3. Collect Connected VUIDs
        const connectedVuids = new Set([vuid]);
        edges.forEach(e => {
            connectedVuids.add(e.source);
            connectedVuids.add(e.target);
        });

        // 4. Fetch All Connected Citizen Nodes
        let nodes = [];
        if (connectedVuids.size > 0) {
            const [rows] = await pool.query(`
                SELECT 
                    c.vuid, 
                    CONCAT(c.first_name, IF(c.middle_name IS NOT NULL AND c.middle_name != '', CONCAT(' ', c.middle_name), ''), ' ', c.last_name) AS name,
                    c.gender, 
                    c.dob, 
                    c.category, 
                    c.is_claimed, 
                    c.status,
                    (SELECT COUNT(*) FROM citizen_documents cd WHERE cd.vuid = c.vuid AND cd.is_ocp_verified = TRUE) > 0 AS is_verified
                FROM citizens c
                WHERE c.vuid IN (?)
            `, [[...connectedVuids]]);
            nodes = rows;
        }

        // Format VUIDs for display
        const formattedNodes = nodes.map(n => ({
            ...n,
            formatted_vuid: formatVUID(n.vuid),
            is_verified: Boolean(n.is_verified)
        }));

        // 5. Log HIPAA § 164.312(b) Graph Access
        await logAuditEvent({
            actor_vuid: req.headers['x-actor-vuid'] || vuid,
            action: 'READ',
            resource_type: 'TREE_GRAPH',
            resource_id: vuid,
            ip_address: req.ip || '127.0.0.1',
            user_agent: req.headers['user-agent'] || 'VanshaSetu Client',
            status: 'SUCCESS',
            details: { connected_count: connectedVuids.size, edge_count: edges.length }
        });

        const graphData = {
            success: true,
            root_vuid: vuid,
            formatted_root_vuid: formatVUID(vuid),
            nodes: formattedNodes,
            edges
        };

        return sendSecureResponse(req, res, 200, graphData);
    } catch (err) {
        console.error('Tree Fetch Error:', err);
        return res.status(500).json({ error: 'Failed to retrieve kinship graph nodes and edges.' });
    }
});

module.exports = router;
