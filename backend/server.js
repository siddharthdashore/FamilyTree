const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
require('dotenv').config();

const { rateLimiter, signatureGuard, e2eePayloadGuard } = require('./src/middleware/security_guard');
const { testConnection } = require('./src/config/db');

// Route Handlers
const citizenRoutes = require('./src/routes/citizen_routes');
const kinshipRoutes = require('./src/routes/kinship_routes');
const docRoutes = require('./src/routes/doc_routes');
const treeRoutes = require('./src/routes/tree_routes');
const sirRoutes = require('./src/routes/sir_routes');
const lifeEventsRoutes = require('./src/routes/life_events_routes');
const educationRoutes = require('./src/routes/education_routes');
const matrimonyRoutes = require('./src/routes/matrimony_routes');
const analyticsRoutes = require('./src/routes/analytics_routes');

const app = express();

// ============================================================================
// 1. Zero-Trust Security & Header Hardening
// ============================================================================
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            scriptSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            imgSrc: ["'self'", "data:", "https://vanshasetu.in"],
            connectSrc: ["'self'"],
            fontSrc: ["'self'"],
            objectSrc: ["'none'"],
            frameAncestors: ["'none'"]
        }
    },
    hsts: {
        maxAge: 63072000, // 2 years
        includeSubDomains: true,
        preload: true
    },
    frameguard: { action: 'deny' },
    noSniff: true,
    referrerPolicy: { policy: 'strict-origin-when-cross-origin' }
}));

// Cross-Origin Resource Sharing
app.use(cors({
    origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: [
        'Content-Type', 'Authorization', 'X-Vansha-Signature',
        'X-Vansha-Timestamp', 'X-Vansha-Nonce', 'X-Vansha-Encrypt',
        'X-Actor-VUID'
    ],
    maxAge: 86400
}));

// Body parsing with strict size limits to prevent payload exhaustion
app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: false, limit: '2mb' }));

// Apply Sliding Window Rate Limiter
app.use(rateLimiter);

// Anti-Tampering & Anti-Replay HMAC Signature Guard
app.use(signatureGuard);

// Transparent End-to-End Encryption (E2EE) Payload Decryption
app.use(e2eePayloadGuard);

// Terminal Event & API Request Logger Middleware
app.use((req, res, next) => {
    const timestamp = new Date().toISOString();
    console.log(`\n==================================================`);
    console.log(`📢 [API EVENT LOG] ${timestamp} -> ${req.method} ${req.originalUrl}`);
    if (req.body && Object.keys(req.body).length > 0) {
        console.log(`📦 [PAYLOAD]:`, JSON.stringify(req.body, null, 2));
    }
    if (req.query && Object.keys(req.query).length > 0) {
        console.log(`🔍 [QUERY]:`, JSON.stringify(req.query, null, 2));
    }
    console.log(`==================================================\n`);
    next();
});

// ============================================================================
// 2. Health Check & Root Endpoints
// ============================================================================
app.get('/health', async (req, res) => {
    const isDbConnected = await testConnection();
    return res.status(200).json({
        status: isDbConnected ? 'HEALTHY' : 'RESILIENT_STANDALONE',
        service: 'VanshaSetu DPI Engine',
        version: '1.0.0-PROD',
        database: isDbConnected ? 'CONNECTED (MySQL 8.0)' : 'STANDALONE (In-Memory Engine)',
        timestamp: new Date().toISOString()
    });
});

app.get('/', (req, res) => {
    return res.status(200).json({
        platform: 'VanshaSetu (वन्शसेतु)',
        description: 'Production-Grade Digital Public Infrastructure (DPI) Kinship & Lineage Platform',
        version: '1.0.0-PROD',
        compliance: ['HIPAA § 164.312', 'ABDM', 'DISHA', 'DPDP Act 2023'],
        security: ['E2EE', 'TDE', 'AES-256-GCM', 'HMAC-SHA256', 'Zero-Knowledge Document Vault'],
        docs: 'https://vanshasetu.in/docs'
    });
});

// ============================================================================
// 3. API Route Registration
const { RAW_CIVIL_MODELS, SUPPORTED_LANGUAGES, SUPPORTED_LANGUAGE_CODES, getLocalizedLabel } = require('./src/models/civil_models');

// Metadata & Canonical Models Route (Multilingual: en, hi, gu, mr)
app.get('/api/v1/meta/civil-models', (req, res) => {
    const lang = (req.query.lang || '').toLowerCase();
    if (SUPPORTED_LANGUAGE_CODES.includes(lang)) {
        return res.status(200).json({
            ...RAW_CIVIL_MODELS,
            selected_language: lang,
            localized_categories: Object.fromEntries(RAW_CIVIL_MODELS.categories.map(c => [c.code, getLocalizedLabel('categories', c.code, lang)])),
            localized_relationships: Object.fromEntries(RAW_CIVIL_MODELS.relationships.map(r => [r.code, getLocalizedLabel('relationships', r.code, lang)])),
        });
    }
    return res.status(200).json(RAW_CIVIL_MODELS);
});

app.use('/api/v1/citizen', citizenRoutes);
app.use('/api/v1/kinship', kinshipRoutes);
app.use('/api/v1/docs', docRoutes);
app.use('/api/v1/tree', treeRoutes);
app.use('/api/v1/sir', sirRoutes);
app.use('/api/v1/audit', sirRoutes); // Mounts /logs and /verify-integrity
app.use('/api/v1/events', lifeEventsRoutes); // Birth, Death, Marriage
app.use('/api/v1/education', educationRoutes); // Education & Occupation
app.use('/api/v1/matrimony', matrimonyRoutes); // Indian Matrimonial Matchmaking
app.use('/api/v1/analytics', analyticsRoutes); // Filtered Population & Demographics

// ============================================================================
// 4. 404 & Centralized Error Handling
// ============================================================================
app.use((req, res) => {
    return res.status(404).json({
        error: 'Not Found',
        message: `Endpoint ${req.method} ${req.originalUrl} does not exist.`
    });
});

app.use((err, req, res, next) => {
    console.error('Unhandled Server Exception:', err);
    // Never leak stack trace to client
    return res.status(500).json({
        error: 'Internal Server Error',
        message: process.env.NODE_ENV === 'production'
            ? 'An unexpected error occurred. Incident logged.'
            : err.message
    });
});

// ============================================================================
// 5. Server Lifecycle & Graceful Shutdown
// ============================================================================
const { closePool } = require('./src/config/db');
const PORT = process.env.PORT || 3000;
let serverInstance = null;

if (process.env.NODE_ENV !== 'test') {
    serverInstance = app.listen(PORT, () => {
        console.log(`🛡️  VanshaSetu DPI Engine running on port ${PORT}`);
        console.log(`🔒 Security: HIPAA § 164.312 & E2EE Active | DB: ${process.env.DB_HOST || '127.0.0.1'}`);
    });
}

const gracefulShutdown = async (signal) => {
    console.log(`Received ${signal}. Shutting down VanshaSetu gracefully...`);
    if (serverInstance) {
        serverInstance.close(async () => {
            console.log('HTTP server terminated.');
            await closePool();
            process.exit(0);
        });
        // Force process exit if teardown hangs
        setTimeout(() => {
            console.error('Forced shutdown due to timeout.');
            process.exit(1);
        }, 5000).unref();
    } else {
        await closePool();
        process.exit(0);
    }
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

module.exports = { app, serverInstance, gracefulShutdown };
