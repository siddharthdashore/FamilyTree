const crypto = require('crypto');
require('dotenv').config();

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 12; // Standard 96-bit IV for GCM
const AUTH_TAG_LENGTH = 16; // Standard 128-bit authentication tag

// Cryptographic material is loaded exclusively from environment variables —
// no secrets are embedded in source. In production the variables are mandatory;
// otherwise an ephemeral per-boot value is generated for local development.
function requireEnvOrEphemeral(name, lengthBytes) {
    const value = process.env[name];
    if (value) return value;
    if (process.env.NODE_ENV === 'production') {
        throw new Error(`${name} environment variable is required in production`);
    }
    console.warn(`⚠️ ${name} not set — using ephemeral per-boot value (development only)`);
    return crypto.randomBytes(lengthBytes).toString('hex');
}

const rawKey = requireEnvOrEphemeral('FLE_MASTER_KEY', 32);
const FLE_MASTER_KEY = crypto.createHash('sha256').update(rawKey).digest();

const HASH_SALT = requireEnvOrEphemeral('HASH_SALT', 32);

/**
 * Encrypt sensitive ePHI/PII string using AES-256-GCM.
 * @param {string|object} plaintext 
 * @param {Buffer} [key] 
 * @returns {{ ciphertext: string, iv: string, authTag: string }}
 */
function encryptField(plaintext, key = FLE_MASTER_KEY) {
    const text = typeof plaintext === 'object' ? JSON.stringify(plaintext) : String(plaintext);
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
    
    let encrypted = cipher.update(text, 'utf8', 'base64');
    encrypted += cipher.final('base64');
    const authTag = cipher.getAuthTag();

    return {
        ciphertext: encrypted,
        iv: iv.toString('base64'),
        authTag: authTag.toString('base64')
    };
}

/**
 * Decrypt sensitive ePHI/PII string using AES-256-GCM.
 * Throws error if ciphertext or auth tag has been tampered with.
 * @param {string} ciphertextBase64 
 * @param {string} ivBase64 
 * @param {string} authTagBase64 
 * @param {Buffer} [key] 
 * @returns {string}
 */
function decryptField(ciphertextBase64, ivBase64, authTagBase64, key = FLE_MASTER_KEY) {
    const iv = Buffer.from(ivBase64, 'base64');
    const authTag = Buffer.from(authTagBase64, 'base64');
    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    decipher.setAuthTag(authTag);

    let decrypted = decipher.update(ciphertextBase64, 'base64', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
}

/**
 * Generate salted SHA-256 zero-knowledge deduplication token for government IDs.
 * Sanitizes input (strips spaces and dashes, converts to uppercase) before hashing.
 * Raw value is immediately discarded from caller scope.
 * @param {string} rawDocValue 
 * @param {string} [salt] 
 * @returns {string} 64-character hex hash
 */
function hashDocument(rawDocValue, salt = HASH_SALT) {
    if (!rawDocValue) throw new Error('Cannot hash empty document value.');
    const sanitized = String(rawDocValue).replace(/[\s-]/g, '').toUpperCase();
    return crypto.createHash('sha256').update(sanitized + salt).digest('hex');
}

/**
 * Generate masked representation for UI display (e.g. XXXX-XXXX-1234 or ABCDE****F).
 * @param {string} rawDocValue 
 * @returns {string}
 */
function maskDocument(rawDocValue) {
    if (!rawDocValue) return 'XXXX';
    const sanitized = String(rawDocValue).replace(/[\s-]/g, '').toUpperCase();
    // Indian PAN standard: 5 letters + 4 digits + 1 letter -> ABCDE****F
    if (/^[A-Z]{5}[0-9]{4}[A-Z]$/.test(sanitized)) {
        return `${sanitized.slice(0, 5)}****${sanitized.slice(-1)}`;
    }
    // 12-digit Aadhaar standard: 12 digits -> XXXXXXXX1234
    if (/^[0-9]{12}$/.test(sanitized)) {
        return `XXXXXXXX${sanitized.slice(-4)}`;
    }
    if (sanitized.length <= 4) {
        return `XXXX-${sanitized}`;
    }
    const lastFour = sanitized.slice(-4);
    return 'X'.repeat(sanitized.length - 4) + lastFour;
}

/**
 * End-to-End Encryption (E2EE) helper: Encrypts full JSON payload envelope.
 * @param {object} payload 
 * @param {Buffer|string} secretKey 
 * @returns {{ encrypted_data: string, iv: string, auth_tag: string }}
 */
function encryptPayload(payload, secretKey = FLE_MASTER_KEY) {
    const key = Buffer.isBuffer(secretKey) ? secretKey : crypto.createHash('sha256').update(String(secretKey)).digest();
    const result = encryptField(JSON.stringify(payload), key);
    return {
        is_encrypted: true,
        encrypted_data: result.ciphertext,
        iv: result.iv,
        auth_tag: result.authTag
    };
}

/**
 * End-to-End Encryption (E2EE) helper: Decrypts full JSON payload envelope.
 * @param {{ encrypted_data: string, iv: string, auth_tag: string }} envelope 
 * @param {Buffer|string} secretKey 
 * @returns {object}
 */
function decryptPayload(envelope, secretKey = FLE_MASTER_KEY) {
    const key = Buffer.isBuffer(secretKey) ? secretKey : crypto.createHash('sha256').update(String(secretKey)).digest();
    const decryptedJson = decryptField(envelope.encrypted_data, envelope.iv, envelope.auth_tag, key);
    return JSON.parse(decryptedJson);
}

/**
 * Computes HMAC-SHA256 signature for anti-tampering verification.
 * Formula: HMAC-SHA256(timestamp + nonce + body, secret)
 * @param {string} timestamp 
 * @param {string} nonce 
 * @param {string|object} body 
 * @param {string} secret 
 * @returns {string}
 */
function computeSignature(timestamp, nonce, body, secret = process.env.API_HMAC_SECRET) {
    if (!secret) {
        throw new Error('API_HMAC_SECRET environment variable is required for HMAC signing');
    }
    const bodyStr = typeof body === 'object' ? JSON.stringify(body) : String(body || '');
    const message = `${timestamp}:${nonce}:${bodyStr}`;
    return crypto.createHmac('sha256', secret).update(message).digest('hex');
}

/**
 * Validates incoming request HMAC signature with timing-safe comparison.
 * @param {string} incomingSignature 
 * @param {string} timestamp 
 * @param {string} nonce 
 * @param {string|object} body 
 * @param {string} [secret] 
 * @returns {boolean}
 */
function verifySignature(incomingSignature, timestamp, nonce, body, secret) {
    if (!incomingSignature || !timestamp || !nonce) return false;
    try {
        const expected = computeSignature(timestamp, nonce, body, secret);
        return crypto.timingSafeEqual(Buffer.from(incomingSignature, 'hex'), Buffer.from(expected, 'hex'));
    } catch {
        return false;
    }
}

module.exports = {
    encryptField,
    decryptField,
    hashDocument,
    maskDocument,
    encryptPayload,
    decryptPayload,
    computeSignature,
    verifySignature,
    FLE_MASTER_KEY,
    HASH_SALT
};
