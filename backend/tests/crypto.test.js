const { test, describe } = require('node:test');
const assert = require('node:assert/strict');
const {
    encryptField,
    decryptField,
    hashDocument,
    maskDocument,
    encryptPayload,
    decryptPayload,
    computeSignature,
    verifySignature
} = require('../src/services/crypto_service');

describe('🔒 Cryptographic Service & E2EE Suite', () => {

    test('Field-Level AES-256-GCM: Encrypts and decrypts ePHI data accurately', () => {
        const medicalData = { height_cm: 178.5, weight_kg: 72.0, blood_group: 'O+' };
        const encrypted = encryptField(medicalData);

        assert.ok(encrypted.ciphertext, 'Ciphertext must be present');
        assert.ok(encrypted.iv, 'IV must be present');
        assert.ok(encrypted.authTag, 'Auth Tag must be present');
        assert.notEqual(encrypted.ciphertext, JSON.stringify(medicalData), 'Ciphertext must not be plaintext');

        const decryptedStr = decryptField(encrypted.ciphertext, encrypted.iv, encrypted.authTag);
        const decryptedObj = JSON.parse(decryptedStr);

        assert.deepEqual(decryptedObj, medicalData, 'Decrypted data must match original ePHI');
    });

    test('Field-Level AES-256-GCM: Throws error on tampered ciphertext', () => {
        const originalText = 'Sensitive Medical History';
        const encrypted = encryptField(originalText);

        // Tamper with ciphertext by corrupting a byte
        const tamperedCipher = 'A' + encrypted.ciphertext.substring(1);

        assert.throws(() => {
            decryptField(tamperedCipher, encrypted.iv, encrypted.authTag);
        }, /Unsupported state or unable to authenticate data/, 'Tampered ciphertext must fail authentication');
    });

    test('Document Vault: Salted SHA-256 produces deterministic 64-char hex hash', () => {
        const doc1 = '1234 5678 9012';
        const doc2 = '1234-5678-9012';
        const doc3 = '123456789012';

        const hash1 = hashDocument(doc1);
        const hash2 = hashDocument(doc2);
        const hash3 = hashDocument(doc3);

        assert.equal(hash1.length, 64, 'SHA-256 hash must be 64 characters');
        assert.equal(hash1, hash2, 'Sanitization must ensure identical hashes across formatting');
        assert.equal(hash2, hash3, 'Raw digits must match formatted hash');
    });

    test('Document Masking: Masking retains only last 4 characters or PAN standard', () => {
        assert.equal(maskDocument('123456789012'), 'XXXXXXXX9012');
        assert.equal(maskDocument('ABCDE1234F'), 'ABCDE****F');
        assert.equal(maskDocument('12'), 'XXXX-12');
    });

    test('E2EE Payload Envelope: Encrypts and decrypts full JSON envelope', () => {
        const payload = {
            vuid: '109284729102',
            first_name: 'Aarav',
            category: 'GEN'
        };

        const envelope = encryptPayload(payload);
        assert.equal(envelope.is_encrypted, true);
        assert.ok(envelope.encrypted_data);

        const decrypted = decryptPayload(envelope);
        assert.deepEqual(decrypted, payload);
    });

    test('HMAC Request Signature: Verifies matching signature and rejects invalid/tampered signature', () => {
        const timestamp = Date.now().toString();
        const nonce = 'random_nonce_12345';
        const body = { action: 'register', vuid: '109284729102' };
        const secret = 'test_secret_key_8492';

        const validSig = computeSignature(timestamp, nonce, body, secret);
        assert.equal(verifySignature(validSig, timestamp, nonce, body, secret), true);

        // Tampered body
        const tamperedBody = { action: 'register', vuid: '999999999999' };
        assert.equal(verifySignature(validSig, timestamp, nonce, tamperedBody, secret), false);

        // Modified timestamp
        const tamperedTimestamp = (parseInt(timestamp, 10) + 1000).toString();
        assert.equal(verifySignature(validSig, tamperedTimestamp, nonce, body, secret), false);
    });

});
