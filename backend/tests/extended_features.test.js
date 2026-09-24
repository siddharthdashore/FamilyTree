const { test, describe, before, after } = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');

process.env.NODE_ENV = 'test';
process.env.BYPASS_SIGNATURE = 'true';
const { app } = require('../server');

describe('🇮🇳 Indian Civil Events, Education, Matrimony & Demographic Analytics Suite', () => {
    let server;
    let baseUrl;

    before((t, done) => {
        server = http.createServer(app);
        server.listen(0, '127.0.0.1', () => {
            const address = server.address();
            baseUrl = `http://127.0.0.1:${address.port}`;
            done();
        });
    });

    after((t, done) => {
        server.close(done);
    });

    test('1. Child Birth Registration: Allocates 12-digit VUID and establishes parental kinship edges', async () => {
        const payload = {
            father_vuid: '284910293847', // Aarav Sharma
            mother_vuid: '928174019284', // Pooja Sharma
            first_name: 'Ananya',
            last_name: 'Sharma',
            gender: 'Female',
            dob: '2026-02-10',
            weight_kg: 3.4,
            hospital_name: 'Apollo Cradle Hospital Indore'
        };

        const res = await fetch(`${baseUrl}/api/v1/events/birth`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        assert.equal(res.status, 201);
        const body = await res.json();
        assert.equal(body.success, true);
        assert.equal(body.data.vuid.length, 12);
        assert.equal(body.data.gender, 'Female');
        assert.equal(body.data.father_vuid, '284910293847');
        assert.ok(body.data.formatted_vuid.includes(' '));
    });

    test('2. Death Registration: Updates status to Deceased and records civil death certificate', async () => {
        const payload = {
            vuid: '391029485710', // Deepak Sharma
            death_date: '2026-01-20',
            death_reason: 'Cardiorespiratory Arrest',
            death_cert_number: 'MP-MNC-DTH-2026-9941',
            informant_vuid: '510928340192'
        };

        const res = await fetch(`${baseUrl}/api/v1/events/death`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        assert.equal(res.status, 200);
        const body = await res.json();
        assert.equal(body.success, true);
        assert.equal(body.data.status, 'Deceased');
        assert.equal(body.data.death_date, '2026-01-20');
    });

    test('3. Marriage Registration: Establishes reciprocal spouse edges and updates marital status', async () => {
        const payload = {
            groom_vuid: '710293849102', // Rohan Verma
            bride_vuid: '710293849103', // Ananya Joshi
            marriage_date: '2026-03-15',
            venue_city: 'Indore',
            venue_state: 'Madhya Pradesh',
            marriage_reg_no: 'MP-IND-MAR-2026-0042',
            priest_or_registrar: 'Sub-Registrar District Court Indore'
        };

        const res = await fetch(`${baseUrl}/api/v1/events/marriage`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        assert.equal(res.status, 201);
        const body = await res.json();
        assert.equal(body.success, true);
        assert.equal(body.data.marriage_reg_no, 'MP-IND-MAR-2026-0042');
        assert.equal(body.data.groom_vuid, '710293849102');
        assert.equal(body.data.bride_vuid, '710293849103');
    });

    test('4. Education & Occupation Details: Records and retrieves qualifications for citizen', async () => {
        const addPayload = {
            vuid: '284910293847', // Aarav Sharma
            qualification_level: 'Masters',
            degree_name: 'M.S. in Artificial Intelligence Systems',
            institution: 'Carnegie Mellon & IIT Bombay Joint Program',
            year_of_passing: 2024,
            occupation_sector: 'Private_IT_Corporate',
            profession_title: 'Lead AI Infrastructure Engineer'
        };

        const postRes = await fetch(`${baseUrl}/api/v1/education/add`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(addPayload)
        });

        assert.equal(postRes.status, 201);
        const postBody = await postRes.json();
        assert.equal(postBody.success, true);
        assert.equal(postBody.data.degree_name, 'M.S. in Artificial Intelligence Systems');

        // Fetch education history
        const getRes = await fetch(`${baseUrl}/api/v1/education/284910293847`);
        assert.equal(getRes.status, 200);
        const getBody = await getRes.json();
        assert.equal(getBody.success, true);
        assert.ok(getBody.count >= 1);
        assert.ok(Array.isArray(getBody.education));
    });

    test('5. Matrimony Bride-Groom Search: Filters eligible candidates with Gotra exogamy analysis', async () => {
        const searchPayload = {
            looking_for_gender: 'Female',
            min_age: 20,
            max_age: 35,
            religion: 'Hindu',
            seeker_gotra: 'Bharadwaj', // Exogamy rule check
            state: 'Madhya Pradesh'
        };

        const res = await fetch(`${baseUrl}/api/v1/matrimony/search`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(searchPayload)
        });

        assert.equal(res.status, 200);
        const body = await res.json();
        assert.equal(body.success, true);
        assert.ok(body.candidates.length > 0);
        assert.ok(body.candidates.every(c => c.gender === 'Female'));

        // Verify that Gotra status is evaluated
        const sampleCandidate = body.candidates[0];
        assert.ok(sampleCandidate.gotra_status !== undefined);
        assert.ok(sampleCandidate.formatted_vuid.length > 12);
    });

    test('6. Population Count & Demographic Analytics: Returns filtered census pyramid', async () => {
        const res = await fetch(`${baseUrl}/api/v1/analytics/demographics?state=Madhya%20Pradesh`);
        assert.equal(res.status, 200);
        const body = await res.json();

        assert.equal(body.success, true);
        assert.ok(body.total_population > 0);
        assert.ok(body.gender_distribution.male !== undefined);
        assert.ok(body.gender_distribution.female !== undefined);
        assert.ok(body.age_distribution.children_0_14 !== undefined);
        assert.ok(body.social_categories.GEN !== undefined);
        assert.ok(body.digital_adoption.claimed_percentage >= 0);
    });

    test('7. Comprehensive Audit Log: Verifies immutable audit records for life events and queries', async () => {
        const res = await fetch(`${baseUrl}/api/v1/audit/logs?limit=50`);
        assert.equal(res.status, 200);
        const body = await res.json();

        assert.equal(body.success, true);
        assert.ok(body.logs.length > 0);
        
        // Check that new action types exist in the immutable log
        const actions = body.logs.map(l => l.action);
        assert.ok(actions.includes('BIRTH_REGISTRATION') || actions.includes('DEATH_REGISTRATION') || actions.includes('CREATE'));
    });

    test('8. Full Citizen Registration with Indian Lineage & Gotra: Verifies registration and profile retrieval with gotra, religion, marital_status, and blood_group', async () => {
        const payload = {
            first_name: 'Devendra',
            last_name: 'Pandey',
            gender: 'Male',
            dob: '1995-08-15',
            caste: 'Brahmin',
            category: 'GEN',
            gotra: 'Shandilya',
            religion: 'Hindu',
            marital_status: 'Single',
            blood_group: 'O+',
            pin_code: '452001',
            district: 'Indore',
            state: 'Madhya Pradesh',
            country: 'India'
        };

        const regRes = await fetch(`${baseUrl}/api/v1/citizen/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        assert.equal(regRes.status, 201);
        const regBody = await regRes.json();
        assert.equal(regBody.success, true);
        const newVuid = regBody.data.vuid;
        assert.equal(newVuid.length, 12);

        // Fetch profile and verify all Indian lineage details are present
        const fetchRes = await fetch(`${baseUrl}/api/v1/citizen/${newVuid}`);
        assert.equal(fetchRes.status, 200);
        const fetchBody = await fetchRes.json();
        assert.equal(fetchBody.success, true);
        assert.equal(fetchBody.data.gotra, 'Shandilya');
        assert.equal(fetchBody.data.religion, 'Hindu');
        assert.equal(fetchBody.data.marital_status, 'Single');
        assert.equal(fetchBody.data.blood_group, 'O+');
    });
});
