const { test, describe } = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');

process.env.NODE_ENV = 'test';
process.env.BYPASS_SIGNATURE = 'true';
const { app } = require('../server');

describe('🚀 End-to-End Operational Lifecycle & SIR Conflict Suite', () => {

    let server;
    let baseUrl;
    let registeredVuid;

    test('Setup: Start ephemeral test server', (t, done) => {
        server = http.createServer(app);
        server.listen(0, '127.0.0.1', () => {
            const address = server.address();
            baseUrl = `http://127.0.0.1:${address.port}`;
            done();
        });
    });

    test('E2E Step 1: Register citizen successfully and receive 12-digit VUID', async () => {
        const payload = {
            first_name: 'Devendra',
            last_name: 'Patel',
            gender: 'Male',
            dob: '1985-11-20',
            height_cm: 172.0,
            weight_kg: 68.5,
            category: 'OBC',
            caste: 'Patidar',
            gotra: 'Kashyap',
            religion: 'Hindu',
            marital_status: 'Married',
            blood_group: 'B+',
            address_line1: '12 Shanti Nagar',
            pin_code: '452001',
            district: 'Indore',
            state: 'Madhya Pradesh',
            country: 'India'
        };

        const res = await fetch(`${baseUrl}/api/v1/citizen/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        assert.equal(res.status, 201);
        const body = await res.json();
        assert.equal(body.success, true);
        assert.ok(body.data.vuid);
        assert.match(body.data.vuid, /^[0-9]{12}$/);
        assert.equal(body.data.full_name, 'Devendra Patel');

        registeredVuid = body.data.vuid;
    });

    test('E2E Step 2: Fetch registered citizen profile by 12-digit VUID', async () => {
        const res = await fetch(`${baseUrl}/api/v1/citizen/${registeredVuid}`);
        assert.equal(res.status, 200);

        const body = await res.json();
        assert.equal(body.success, true);
        assert.equal(body.data.vuid, registeredVuid);
        assert.equal(body.data.first_name, 'Devendra');
        assert.equal(body.data.category, 'OBC');
    });

    test('E2E Step 3: Fetch multi-generational lineage graph (Kailash Sharma)', async () => {
        const res = await fetch(`${baseUrl}/api/v1/tree/109284729102`);
        assert.equal(res.status, 200);

        const body = await res.json();
        assert.equal(body.success, true);
        assert.equal(body.root_vuid, '109284729102');
        assert.ok(Array.isArray(body.nodes));
        assert.ok(Array.isArray(body.edges));
        assert.ok(body.nodes.length >= 2);
        assert.ok(body.edges.length >= 1);
    });

    test('E2E Step 4: Connect new kinship relationship edge', async () => {
        // Connect Devendra (Son) to Kailash (Father)
        const res = await fetch(`${baseUrl}/api/v1/kinship/connect`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                source_vuid: '109284729102',
                target_vuid: registeredVuid,
                relationship_type: 'Son',
                verification_status: 'Document_Backed'
            })
        });

        assert.equal(res.status, 200);
        const body = await res.json();
        assert.equal(body.success, true);
        assert.equal(body.data.relationship_type, 'Son');
    });

    test('E2E Step 5: Verify OCP credential (Aadhaar)', async () => {
        const res = await fetch(`${baseUrl}/api/v1/docs/verify-ocp`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                vuid: registeredVuid,
                doc_type: 'AADHAAR',
                doc_raw_value: '998877665544',
                issuer_authority: 'DigiLocker / UIDAI'
            })
        });

        assert.equal(res.status, 200);
        const body = await res.json();
        assert.equal(body.success, true);
        assert.equal(body.masked_value, 'XXXXXXXX5544');
        assert.equal(body.is_ocp_verified, true);
    });

    test('E2E Step 6: SIR Deduplication detects duplicate Aadhaar on different citizen and returns 409', async () => {
        // Submit identical Aadhaar for Kailash Sharma
        const res = await fetch(`${baseUrl}/api/v1/docs/verify-ocp`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                vuid: '109284729102',
                doc_type: 'AADHAAR',
                doc_raw_value: '998877665544', // Identical raw value
                issuer_authority: 'DigiLocker / UIDAI'
            })
        });

        assert.equal(res.status, 409);
        const body = await res.json();
        assert.equal(body.conflict_detected, true);
        assert.ok(body.message.includes('Cross-lineage duplicate conflict detected'));
    });

    test('E2E Step 7: Retrieve Special Investigation Registry (SIR) conflict log list', async () => {
        const res = await fetch(`${baseUrl}/api/v1/sir/conflicts`);
        assert.equal(res.status, 200);

        const body = await res.json();
        assert.equal(body.success, true);
        assert.ok(body.count >= 1);
        assert.ok(Array.isArray(body.conflicts));
    });

    test('E2E Step 8: Retrieve HIPAA audit trail entries', async () => {
        const res = await fetch(`${baseUrl}/api/v1/sir/logs`);
        assert.equal(res.status, 200);

        const body = await res.json();
        assert.equal(body.success, true);
        assert.ok(body.count >= 1);
        assert.ok(Array.isArray(body.logs));
    });

    test('Teardown: Close test server', (t, done) => {
        server.close(done);
    });
});
