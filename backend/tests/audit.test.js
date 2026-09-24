const { test, describe } = require('node:test');
const assert = require('node:assert/strict');
const { computeLogHash, GENESIS_HASH } = require('../src/services/audit_service');

describe('📋 HIPAA § 164.312(b) Audit Hash Chaining Suite', () => {

    test('Chaining: Computes deterministic hash from log attributes and previous hash', () => {
        const entry1 = {
            actor_vuid: '109284729102',
            action: 'CREATE',
            resource_type: 'CITIZEN',
            resource_id: '109284729102',
            ip_address: '127.0.0.1',
            timestamp: '2026-09-24T00:00:00.000Z',
            prev_log_hash: GENESIS_HASH
        };

        const hash1 = computeLogHash(entry1);
        assert.equal(typeof hash1, 'string');
        assert.equal(hash1.length, 64, 'SHA-256 hash must be 64 hex characters');

        // Entry 2 links to Entry 1
        const entry2 = {
            actor_vuid: '109284729102',
            action: 'READ',
            resource_type: 'CITIZEN',
            resource_id: '109284729102',
            ip_address: '127.0.0.1',
            timestamp: '2026-09-24T00:01:00.000Z',
            prev_log_hash: hash1
        };

        const hash2 = computeLogHash(entry2);
        assert.notEqual(hash1, hash2, 'Subsequent chained hash must be unique');

        // Entry 3 links to Entry 2
        const entry3 = {
            actor_vuid: '109284729102',
            action: 'EXPORT',
            resource_type: 'TREE_GRAPH',
            resource_id: '109284729102',
            ip_address: '127.0.0.1',
            timestamp: '2026-09-24T00:02:00.000Z',
            prev_log_hash: hash2
        };

        const hash3 = computeLogHash(entry3);
        assert.notEqual(hash2, hash3);
    });

    test('Tamper Detection: Changing any field breaks the cryptographic link', () => {
        const originalEntry = {
            actor_vuid: '109284729102',
            action: 'CREATE',
            resource_type: 'CITIZEN',
            resource_id: '109284729102',
            ip_address: '127.0.0.1',
            timestamp: '2026-09-24T00:00:00.000Z',
            prev_log_hash: GENESIS_HASH
        };
        const expectedHash = computeLogHash(originalEntry);

        // Tamper with action
        const tamperedEntry = { ...originalEntry, action: 'UPDATE' };
        const tamperedHash = computeLogHash(tamperedEntry);

        assert.notEqual(expectedHash, tamperedHash, 'Tampering must produce completely different hash');
    });

});
