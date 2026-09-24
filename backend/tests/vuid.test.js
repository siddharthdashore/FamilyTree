const { test, describe } = require('node:test');
const assert = require('node:assert/strict');
const {
    generate12DigitVUID,
    isValidVUID,
    formatVUID,
    VUID_REGEX
} = require('../src/services/vuid_service');

describe('🆔 12-Digit Numeric VUID Standard Suite', () => {

    test('Generation: Produces strictly 12 numeric digits within [100000000000, 999999999999]', () => {
        for (let i = 0; i < 500; i++) {
            const vuid = generate12DigitVUID();
            assert.equal(typeof vuid, 'string');
            assert.equal(vuid.length, 12, 'VUID must be exactly 12 characters');
            assert.ok(VUID_REGEX.test(vuid), `VUID ${vuid} must match regex ^[0-9]{12}$`);
            
            const num = parseInt(vuid, 10);
            assert.ok(num >= 100000000000, 'Must be >= 10^11');
            assert.ok(num <= 999999999999, 'Must be <= 10^12 - 1');
        }
    });

    test('Validation: Correctly identifies valid and invalid VUID strings', () => {
        // Valid
        assert.equal(isValidVUID('109284729102'), true);
        assert.equal(isValidVUID('999999999999'), true);
        assert.equal(isValidVUID('100000000000'), true);

        // Invalid (short/long)
        assert.equal(isValidVUID('12345'), false);
        assert.equal(isValidVUID('12345678901'), false); // 11 digits
        assert.equal(isValidVUID('1234567890123'), false); // 13 digits

        // Invalid (alphanumeric/special)
        assert.equal(isValidVUID('10928472910A'), false);
        assert.equal(isValidVUID('1092-8472-9102'), false);
        assert.equal(isValidVUID('1092 8472 9102'), false);
        assert.equal(isValidVUID(null), false);
        assert.equal(isValidVUID(undefined), false);
    });

    test('Formatting: Formats 12 digits into 3 space-delimited 4-digit clusters', () => {
        assert.equal(formatVUID('109284729102'), '1092 8472 9102');
        assert.equal(formatVUID('510928340192'), '5109 2834 0192');
        assert.equal(formatVUID('invalid'), 'invalid');
    });

});
