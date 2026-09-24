const { test, describe } = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');

// Set environment for test mode before requiring server
process.env.NODE_ENV = 'test';
process.env.BYPASS_SIGNATURE = 'true'; // Allow direct endpoint testing
const { app } = require('../server');

describe('🌐 API Route Validation & Security Headers Suite', () => {

    let server;
    let baseUrl;

    test('Setup: Start ephemeral test server', (t, done) => {
        server = http.createServer(app);
        server.listen(0, '127.0.0.1', () => {
            const address = server.address();
            baseUrl = `http://127.0.0.1:${address.port}`;
            done();
        });
    });

    test('Security Headers: Response includes HSTS, CSP, and X-Frame-Options', async () => {
        const res = await fetch(`${baseUrl}/`);
        assert.equal(res.status, 200);

        const headers = res.headers;
        assert.equal(headers.get('x-frame-options'), 'DENY');
        assert.equal(headers.get('x-content-type-options'), 'nosniff');
        assert.ok(headers.get('content-security-policy'));
        assert.ok(headers.get('strict-transport-security'));

        const body = await res.json();
        assert.equal(body.platform, 'VanshaSetu (वन्शसेतु)');
        assert.ok(body.compliance.includes('HIPAA § 164.312'));
    });

    test('GET /health: Returns service health metadata', async () => {
        const res = await fetch(`${baseUrl}/health`);
        const body = await res.json();
        assert.ok(body.service === 'VanshaSetu DPI Engine');
        assert.ok(['HEALTHY', 'DEGRADED', 'RESILIENT_STANDALONE'].includes(body.status));
    });

    test('POST /api/v1/citizen/register: Validates mandatory fields and rejects incomplete body', async () => {
        const res = await fetch(`${baseUrl}/api/v1/citizen/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ first_name: 'Aarav' }) // Missing last_name, gender, dob, pin_code
        });

        assert.equal(res.status, 400);
        const body = await res.json();
        assert.ok(body.error.includes('Missing mandatory registration fields'));
    });

    test('POST /api/v1/citizen/register: Validates 6-digit PIN code format', async () => {
        const res = await fetch(`${baseUrl}/api/v1/citizen/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                first_name: 'Aarav',
                last_name: 'Sharma',
                gender: 'Male',
                dob: '1998-05-18',
                pin_code: '123', // Invalid (3 digits)
                district: 'Indore',
                state: 'Madhya Pradesh'
            })
        });

        assert.equal(res.status, 400);
        const body = await res.json();
        assert.ok(body.error.includes('PIN Code must be strictly 6 digits'));
    });

    test('GET /api/v1/tree/:vuid: Rejects non-12-digit VUID with 400 Bad Request', async () => {
        const res = await fetch(`${baseUrl}/api/v1/tree/12345`);
        assert.equal(res.status, 400);
        const body = await res.json();
        assert.ok(body.error.includes('12 numeric digits'));
    });

    test('POST /api/v1/kinship/connect: Rejects self-referential or invalid VUID connection', async () => {
        const res = await fetch(`${baseUrl}/api/v1/kinship/connect`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                source_vuid: '109284729102',
                target_vuid: '109284729102', // Same VUID
                relationship_type: 'Spouse'
            })
        });

        assert.equal(res.status, 400);
        const body = await res.json();
        assert.ok(body.error.includes('Self-referential'));
    });

    test('POST /api/v1/docs/verify-ocp: Rejects invalid document types', async () => {
        const res = await fetch(`${baseUrl}/api/v1/docs/verify-ocp`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                vuid: '109284729102',
                doc_type: 'INVALID_CREDENTIAL',
                doc_raw_value: '123456789012'
            })
        });

        assert.equal(res.status, 400);
        const body = await res.json();
        assert.ok(body.error.includes('Invalid doc_type'));
    });

    test('Teardown: Close test server', (t, done) => {
        server.close(done);
    });

});
