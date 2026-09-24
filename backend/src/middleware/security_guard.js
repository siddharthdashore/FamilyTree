const { verifySignature, decryptPayload, encryptPayload } = require('../services/crypto_service');

// In-Memory Replay Nonce Cache (expires after 60 seconds)
const MAX_SEEN_NONCES = 50000;
const seenNonces = new Map();
const nonceTimer = setInterval(() => {
    const now = Date.now();
    for (const [nonce, expiry] of seenNonces.entries()) {
        if (now > expiry) {
            seenNonces.delete(nonce);
        }
    }
}, 30000);
if (nonceTimer.unref) nonceTimer.unref();

// In-Memory Sliding Window Rate Limiter
const MAX_TRACKED_IPS = 10000;
const ipRequestCounts = new Map();
const RATE_LIMIT_WINDOW_MS = 60 * 1000; // 1 minute
const MAX_REQUESTS_PER_WINDOW = 120; // 120 requests/min

// Eviction timer to prevent memory leaks from inactive/expired IP records
const ipCleanupTimer = setInterval(() => {
    const now = Date.now();
    for (const [ip, record] of ipRequestCounts.entries()) {
        if (now > record.resetTime) {
            ipRequestCounts.delete(ip);
        }
    }
}, 30000);
if (ipCleanupTimer.unref) ipCleanupTimer.unref();

function rateLimiter(req, res, next) {
    // Extract client IP (handle multi-proxy x-forwarded-for chains)
    const forwardedHeader = req.headers['x-forwarded-for'];
    const rawIp = forwardedHeader ? forwardedHeader.split(',')[0].trim() : (req.socket.remoteAddress || '127.0.0.1');
    const clientIp = rawIp.replace(/^::ffff:/, ''); // normalize IPv4-mapped IPv6
    const now = Date.now();

    // Prevent memory exhaustion under distributed IP spoofing
    if (ipRequestCounts.size >= MAX_TRACKED_IPS) {
        // Purge the oldest 20% of entries
        let countToPurge = Math.floor(MAX_TRACKED_IPS * 0.2);
        for (const key of ipRequestCounts.keys()) {
            ipRequestCounts.delete(key);
            if (--countToPurge <= 0) break;
        }
    }

    let record = ipRequestCounts.get(clientIp);
    if (!record || now > record.resetTime) {
        record = { count: 1, resetTime: now + RATE_LIMIT_WINDOW_MS };
        ipRequestCounts.set(clientIp, record);
    } else {
        record.count++;
        if (record.count > MAX_REQUESTS_PER_WINDOW) {
            return res.status(429).json({
                error: 'Too Many Requests',
                message: 'Rate limit exceeded. Please retry in a moment.',
                retryAfterSeconds: Math.max(1, Math.ceil((record.resetTime - now) / 1000))
            });
        }
    }
    next();
}

function clearRateLimiter() {
    ipRequestCounts.clear();
    seenNonces.clear();
}

/**
 * Anti-Tampering & Anti-Replay Signature Middleware.
 * Validates X-Vansha-Signature, X-Vansha-Timestamp, and X-Vansha-Nonce.
 */
function signatureGuard(req, res, next) {
    // Allow GET requests and development bypass if explicitly configured
    if (req.method === 'GET' || process.env.BYPASS_SIGNATURE === 'true') {
        return next();
    }

    const signature = req.headers['x-vansha-signature'];
    const timestampStr = req.headers['x-vansha-timestamp'];
    const nonce = req.headers['x-vansha-nonce'];

    // In optional/mixed mode, if headers are absent, allow standard secure HTTPS
    if (!signature && !timestampStr && !nonce && process.env.ENFORCE_SIGNATURE !== 'true') {
        return next();
    }

    if (!signature || !timestampStr || !nonce) {
        return res.status(401).json({
            error: 'Unauthorized',
            message: 'Missing anti-tampering security headers (X-Vansha-Signature, X-Vansha-Timestamp, X-Vansha-Nonce).'
        });
    }

    // 1. Validate Timestamp Window (< 60 seconds)
    const timestamp = parseInt(timestampStr, 10);
    const now = Date.now();
    if (isNaN(timestamp) || Math.abs(now - timestamp) > 60000) {
        return res.status(401).json({
            error: 'Unauthorized',
            message: 'Request timestamp expired or out of synchronization (60s tolerance window).'
        });
    }

    // 2. Validate Nonce (Anti-Replay)
    if (seenNonces.has(nonce)) {
        return res.status(401).json({
            error: 'Unauthorized',
            message: 'Replay attack detected: Nonce has already been consumed.'
        });
    }
    seenNonces.set(nonce, now + 65000);

    // 3. Verify HMAC Signature
    const isValid = verifySignature(signature, timestampStr, nonce, req.body);
    if (!isValid) {
        return res.status(401).json({
            error: 'Unauthorized',
            message: 'Cryptographic signature mismatch. Payload may have been tampered with in transit.'
        });
    }

    next();
}

/**
 * Transparent End-to-End Encryption (E2EE) Payload Decryption.
 * If incoming request is encrypted, decrypts it into req.body.
 */
function e2eePayloadGuard(req, res, next) {
    if (req.body && req.body.is_encrypted === true && req.body.encrypted_data) {
        try {
            const decrypted = decryptPayload(req.body);
            req.body = decrypted;
            req.wasE2EEEncrypted = true;
        } catch (err) {
            return res.status(400).json({
                error: 'Decryption Error',
                message: 'Failed to decrypt E2EE payload. Authentication tag or ciphertext corrupted.'
            });
        }
    }
    next();
}

/**
 * Transparent E2EE Response Encryption Helper.
 * Wraps outgoing response in AES-256-GCM envelope if requested.
 */
function sendSecureResponse(req, res, statusCode, payload) {
    const wantsEncryption = req.headers['x-vansha-encrypt'] === 'true' || req.wasE2EEEncrypted;
    if (wantsEncryption) {
        const encryptedEnvelope = encryptPayload(payload);
        return res.status(statusCode).json(encryptedEnvelope);
    }
    return res.status(statusCode).json(payload);
}

module.exports = {
    rateLimiter,
    signatureGuard,
    e2eePayloadGuard,
    sendSecureResponse,
    clearRateLimiter
};
