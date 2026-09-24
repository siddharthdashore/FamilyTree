# VanshaSetu (वन्शसेतु) — Comprehensive Security, HIPAA & Cryptographic Specification

> **Compliance Standards:** HIPAA Security & Privacy Rules (45 CFR § 164.308, § 164.312), ABDM, DISHA, DPDP Act 2023  
> **Security Posture:** Zero-Trust, 100% Defense-in-Depth, End-to-End Encrypted (E2EE), Transparent Data Encryption (TDE)

---

## 1. Compliance Architecture Overview

| Regulation / Standard | Jurisdiction | Specific Requirement | VanshaSetu Technical Implementation |
| :--- | :--- | :--- | :--- |
| **HIPAA § 164.312(a)(1)** | USA / Healthcare | Access Control & Unique User ID | 12-digit numeric VUID + Ephemeral JWTs + Role-Based Access Control (RBAC). |
| **HIPAA § 164.312(b)** | USA / Healthcare | Audit Controls | Cryptographically chained immutable `audit_logs` recording all ePHI/PII accesses with SHA-256 blockchain hashing. |
| **HIPAA § 164.312(c)(1)** | USA / Healthcare | Data Integrity Controls | HMAC-SHA256 request signatures and database cryptographic hashes preventing tampering. |
| **HIPAA § 164.312(e)(1)** | USA / Healthcare | Transmission Security | Mandatory dual-layer encryption: TLS 1.3 with Certificate Pinning + JWE (AES-256-GCM) payload encryption. |
| **ABDM & DISHA** | India / Health DPI | Consent Artifacts & Health Data Confidentiality | Explicit OCP consent verification before linking nodes or health attributes; strict data minimization. |
| **DPDP Act 2023** | India / Data Protection | Purpose Limitation & Zero Plaintext Gov IDs | Zero-knowledge salted hashing (`SHA-256(ID + HASH_SALT)`) for all Indian national identity credentials (Aadhaar, PAN, etc.). |

---

## 2. End-to-End Encryption (E2EE) Flow

```
[Flutter Client Device]
  │  1. Generates 12-byte cryptographic IV + 256-bit AES session key.
  │  2. Encrypts sensitive fields (height, weight, medical notes, GPS coords) via AES-256-GCM.
  │  3. Wraps payload into JWE envelope with 16-byte authentication tag.
  │  4. Computes X-Vansha-Signature = HMAC-SHA256(timestamp + nonce + encrypted_body).
  ▼
[TLS 1.3 Transport Channel] (Enforced PFS & HSTS max-age=63072000)
  │  5. Proxies and CDNs inspect only opaque ciphertexts.
  ▼
[Node.js Hardened API Core]
  │  6. Validates timestamp (< 60s) and non-repeating nonce (anti-replay guard).
  │  7. Verifies HMAC-SHA256 request signature.
  │  8. Decrypts JWE envelope and validates auth tag integrity.
  │  9. Re-encrypts ePHI fields using server-side master KMS key (AES-256-GCM).
  │ 10. Appends tamper-evident audit record to audit_logs table with SHA-256 hash chaining.
  ▼
[MySQL 8.0 InnoDB Storage Engine]
  │ 11. Stored in InnoDB Tablespaces with Transparent Data Encryption (ENCRYPTION='Y').
  │ 12. Direct external port 3306 blocked at OS level (127.0.0.1 internal socket only).
```

---

## 3. Cryptographic Primitives & Specifications

### 3.1 Field-Level Encryption (FLE) for ePHI & PII
- **Algorithm:** AES-256-GCM (Galois/Counter Mode).
- **Key Derivation:** PBKDF2 with HMAC-SHA512 (100,000 iterations) or hardware HSM/KMS.
- **Initialization Vector (IV):** 12 bytes generated per-record via CSPRNG (`crypto.randomBytes(12)`). Reusing an IV with the same key is strictly prohibited.
- **Authentication Tag:** 16 bytes (128 bits) appended to ciphertext to detect tampering.

### 3.2 Document Vault Zero-Knowledge Tokenization
- **Algorithm:** Salted SHA-256.
- **Formula:** `doc_hash = SHA256(Sanitize(raw_id) + SERVER_SALT)`.
- **Retention Policy:** The sanitized raw government identifier is **never written to disk or logs** and is discarded from memory immediately after computing `doc_hash` and `doc_masked_value`.

### 3.3 Blockchain-Chained Immutable Audit Trail (`audit_logs`)
- Every access, update, deletion, verification, or export operation writes an immutable row.
- **Hash Chaining Formula:**
  $$\text{log\_hash}_n = \text{SHA-256}(\text{id}_n \parallel \text{actor\_vuid} \parallel \text{action} \parallel \text{timestamp} \parallel \text{prev\_log\_hash}_{n-1})$$
- Any retroactive tampering or deletion breaks the mathematical hash chain and is immediately flagged by the compliance integrity scanner.

---

## 4. Zero-Trust & "Hacker-Proof" Defense-in-Depth Matrix

| Threat Vector | Severity | Architectural Countermeasure |
| :--- | :--- | :--- |
| **SQL Injection (SQLi)** | Critical | 100% Parameterized prepared statements (`mysql2/promise`). Zero raw SQL concatenation anywhere in codebase. |
| **Man-in-the-Middle (MITM)** | Critical | Strict TLS 1.3 only, Certificate Pinning in Flutter client, HSTS preload, JWE application-layer payload encryption. |
| **Replay Attacks** | High | Every request requires `X-Vansha-Timestamp` (strict 60s window) and single-use `X-Vansha-Nonce` cached in memory. |
| **Data Breach / Database Theft** | Critical | Dual-layer: MySQL InnoDB TDE (`ENCRYPTION='Y'`) + Field-level AES-256-GCM. Stolen database dump reveals only encrypted blobs. |
| **Gov ID Plaintext Exposure** | Critical | Salted SHA-256 hashing. Raw Aadhaar/PAN never reaches persistent storage (DPDP/UIDAI compliant). |
| **DDoS & Brute-Force** | High | Rate limiting middleware (100 req/min global, 5 req/15 min on sensitive endpoints) with IP/VUID blacklisting. |
| **Cross-Site Scripting (XSS)** | High | Helmet CSP (`default-src 'self'`), strict JSON content-type enforcement, HTML sanitization on all text inputs. |
| **Server Port Exposure** | Critical | Port 3306 is bound exclusively to `127.0.0.1`. CloudLinux LVE/cPanel firewall blocks all external direct DB connection attempts. |
| **Emergency Break-Glass Abuse** | High | `audit_logs` logs action `EMERGENCY_ACCESS` with immediate automated alert notifications to security officers. |
