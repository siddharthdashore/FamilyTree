const crypto = require('crypto');

const VUID_REGEX = /^[0-9]{12}$/;
const MIN_VUID = 100000000000;
const MAX_VUID = 999999999999;

/**
 * Generate a cryptographically secure, strictly 12-digit numeric identifier.
 * Mathematical integer range: [100000000000, 999999999999].
 * Zero alphabetic characters, zero state prefixes, zero checksum digits.
 * @returns {string} 12 numeric digits
 */
function generate12DigitVUID() {
    return crypto.randomInt(MIN_VUID, MAX_VUID + 1).toString();
}

/**
 * Validates if an input string strictly conforms to the 12-digit VUID standard.
 * @param {string} vuid 
 * @returns {boolean}
 */
function isValidVUID(vuid) {
    if (typeof vuid !== 'string') return false;
    return VUID_REGEX.test(vuid);
}

/**
 * Format 12-digit VUID into standard space-delimited human-readable presentation.
 * Example: '109284729102' -> '1092 8472 9102'.
 * @param {string} vuid 
 * @returns {string}
 */
function formatVUID(vuid) {
    if (!isValidVUID(vuid)) return vuid;
    return `${vuid.substring(0, 4)} ${vuid.substring(4, 8)} ${vuid.substring(8, 12)}`;
}

/**
 * Allocates a guaranteed unique 12-digit VUID by checking against citizens table.
 * Uses bounded retry loop (up to 5 attempts).
 * @param {import('mysql2/promise').Connection|import('mysql2/promise').Pool} connection 
 * @returns {Promise<string>}
 */
async function allocateUniqueVUID(connection) {
    let vuid = null;
    let attempts = 0;
    const maxAttempts = 5;

    while (!vuid && attempts < maxAttempts) {
        attempts++;
        const candidate = generate12DigitVUID();
        const [rows] = await connection.query(
            'SELECT id FROM citizens WHERE vuid = ? LIMIT 1',
            [candidate]
        );
        if (rows.length === 0) {
            vuid = candidate;
        }
    }

    if (!vuid) {
        throw new Error('VUID allocation failed due to collision limit exhaustion. Retry registration.');
    }

    return vuid;
}

module.exports = {
    generate12DigitVUID,
    isValidVUID,
    formatVUID,
    allocateUniqueVUID,
    VUID_REGEX
};
