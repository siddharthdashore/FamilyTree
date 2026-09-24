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

    test('POST /api/v1/citizen/register: Boundary validation rejects future DOB', async () => {
        const res = await fetch(`${baseUrl}/api/v1/citizen/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                first_name: 'Future',
                last_name: 'Citizen',
                gender: 'Male',
                dob: '2099-01-01',
                pin_code: '452001',
                district: 'Indore',
                state: 'Madhya Pradesh'
            })
        });

        assert.equal(res.status, 400);
        const body = await res.json();
        assert.ok(body.error.includes('Date of birth must be a valid chronological date'));
    });

    test('POST /api/v1/citizen/register: Boundary validation rejects impossible height/weight', async () => {
        const res = await fetch(`${baseUrl}/api/v1/citizen/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                first_name: 'Giant',
                last_name: 'Person',
                gender: 'Male',
                dob: '1990-01-01',
                height_cm: 999.0, // Exceeds 300 cm limit
                pin_code: '452001',
                district: 'Indore',
                state: 'Madhya Pradesh'
            })
        });

        assert.equal(res.status, 400);
        const body = await res.json();
        assert.ok(body.error.includes('Height must be a valid numeric measurement'));
    });

    test('GET /api/v1/sir/conflicts: Sanitizes negative or extreme limit and offset query parameters', async () => {
        const res = await fetch(`${baseUrl}/api/v1/sir/conflicts?limit=-50&offset=-10`);
        assert.equal(res.status, 200);
        const body = await res.json();
        assert.equal(body.success, true);
        assert.ok(Array.isArray(body.conflicts));
    });

    test('GET /api/v1/meta/civil-models: Serves Single Source of Truth with string labels and Indian & Western relationships', async () => {
        const res = await fetch(`${baseUrl}/api/v1/meta/civil-models`);
        assert.equal(res.status, 200);
        const body = await res.json();
        assert.equal(body.version, '1.2.0');
        assert.ok(Array.isArray(body.categories));
        assert.ok(Array.isArray(body.relationships));
        
        // Assert string-based label for GEN -> General
        const genCat = body.categories.find(c => c.code === 'GEN');
        assert.ok(genCat);
        assert.equal(genCat.label, 'General');
        assert.equal(genCat.hindi_label, 'सामान्य');

        // Assert Indian & Western relationship models
        const dada = body.relationships.find(r => r.code === 'Paternal_Grandfather');
        assert.ok(dada);
        assert.equal(dada.western, 'Paternal Grandfather');
        assert.equal(dada.indian, 'दादा (Dada)');

        const mama = body.relationships.find(r => r.code === 'Maternal_Uncle');
        assert.ok(mama);
        assert.equal(mama.western, 'Maternal Uncle');
        assert.equal(mama.indian, 'मामा (Mama)');

        const spouse = body.relationships.find(r => r.code === 'Spouse');
        assert.ok(spouse);
        assert.equal(spouse.western, 'Spouse');
    });

    test('GET /api/v1/meta/civil-models: Supports 4 official languages (English, Hindi, Gujarati, Marathi)', async () => {
        // Test Gujarati localization query
        const resGu = await fetch(`${baseUrl}/api/v1/meta/civil-models?lang=gu`);
        assert.equal(resGu.status, 200);
        const bodyGu = await resGu.json();
        assert.equal(bodyGu.selected_language, 'gu');
        assert.equal(bodyGu.localized_categories['GEN'], 'સામાન્ય');
        assert.equal(bodyGu.localized_relationships['Father'], 'પિતા / બાપુજી');
        assert.equal(bodyGu.localized_relationships['Paternal_Grandfather'], 'દાદા (પિતાના પિતા)');

        // Test Marathi localization query
        const resMr = await fetch(`${baseUrl}/api/v1/meta/civil-models?lang=mr`);
        assert.equal(resMr.status, 200);
        const bodyMr = await resMr.json();
        assert.equal(bodyMr.selected_language, 'mr');
        assert.equal(bodyMr.localized_categories['GEN'], 'સામાન્ય' ? 'सामान्य' : 'सामान्य');
        assert.equal(bodyMr.localized_relationships['Father'], 'वडील / बाबा');
        assert.equal(bodyMr.localized_relationships['Mother'], 'आई');

        // Test supported languages list
        assert.ok(Array.isArray(bodyGu.supported_languages));
        const codes = bodyGu.supported_languages.map(l => l.code);
        assert.deepEqual(codes, ['en', 'hi', 'gu', 'mr']);
    });

    test('Teardown: Close test server', (t, done) => {
        server.close(done);
    });

});
