const { test, describe } = require('node:test');
const assert = require('node:assert/strict');
const { signatureGuard, e2eePayloadGuard } = require('../src/middleware/security_guard');
const { computeSignature, encryptPayload } = require('../src/services/crypto_service');

describe('🛡️ Security & Zero-Trust Middleware Suite', () => {

    test('Anti-Tampering: Rejects request with expired timestamp (>60 seconds)', () => {
        const oldTimestamp = (Date.now() - 70000).toString(); // 70 seconds ago
        const nonce = 'nonce_expired_test';
        const body = { test: true };
        const sig = computeSignature(oldTimestamp, nonce, body);

        const req = {
            method: 'POST',
            headers: {
                'x-vansha-signature': sig,
                'x-vansha-timestamp': oldTimestamp,
                'x-vansha-nonce': nonce
            },
            body
        };

        let responseCode = null;
        let responseJson = null;
        const res = {
            status: (code) => {
                responseCode = code;
                return {
                    json: (data) => { responseJson = data; }
                };
            }
        };

        signatureGuard(req, res, () => {
            assert.fail('Should not call next() for expired timestamp');
        });

        assert.equal(responseCode, 401);
        assert.ok(responseJson.message.includes('expired'));
    });

    test('Anti-Replay: Rejects duplicate nonce submission', () => {
        const now = Date.now().toString();
        const nonce = 'unique_nonce_' + Math.random();
        const body = { test: true };
        const sig = computeSignature(now, nonce, body);

        const req = {
            method: 'POST',
            headers: {
                'x-vansha-signature': sig,
                'x-vansha-timestamp': now,
                'x-vansha-nonce': nonce
            },
            body
        };

        let nextCalled = false;
        signatureGuard(req, {}, () => { nextCalled = true; });
        assert.equal(nextCalled, true, 'First invocation with fresh nonce must succeed');

        // Replay with exact same nonce
        let replayCode = null;
        let replayJson = null;
        const res = {
            status: (code) => {
                replayCode = code;
                return {
                    json: (data) => { replayJson = data; }
                };
            }
        };

        signatureGuard(req, res, () => {
            assert.fail('Should not call next() on replayed nonce');
        });

        assert.equal(replayCode, 401);
        assert.ok(replayJson.message.includes('Replay attack detected'));
    });

    test('Anti-Tampering: Rejects modified body with original signature', () => {
        const now = Date.now().toString();
        const nonce = 'tamper_test_nonce_' + Math.random();
        const originalBody = { vuid: '109284729102', role: 'Citizen' };
        const sig = computeSignature(now, nonce, originalBody);

        const req = {
            method: 'POST',
            headers: {
                'x-vansha-signature': sig,
                'x-vansha-timestamp': now,
                'x-vansha-nonce': nonce
            },
            body: { vuid: '109284729102', role: 'Admin' } // Tampered body
        };

        let tamperCode = null;
        let tamperJson = null;
        const res = {
            status: (code) => {
                tamperCode = code;
                return {
                    json: (data) => { tamperJson = data; }
                };
            }
        };

        signatureGuard(req, res, () => {
            assert.fail('Should not call next() on tampered payload');
        });

        assert.equal(tamperCode, 401);
        assert.ok(tamperJson.message.includes('Cryptographic signature mismatch'));
    });

    test('E2EE Decryption Middleware: Transparently decrypts JWE envelope into req.body', () => {
        const sensitivePayload = {
            vuid: '284910293847',
            health_history: 'Hypertension Type A'
        };
        const envelope = encryptPayload(sensitivePayload);

        const req = {
            body: envelope
        };

        let nextCalled = false;
        e2eePayloadGuard(req, {}, () => { nextCalled = true; });

        assert.equal(nextCalled, true);
        assert.deepEqual(req.body, sensitivePayload);
        assert.equal(req.wasE2EEEncrypted, true);
    });

});
