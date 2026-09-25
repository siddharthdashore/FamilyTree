# VanshaSetu (वन्शसेतु) — BigRock Cloud cPanel Production Deployment Runbook
## End-to-End Operational Guide: Infrastructure Provisioning, Passenger Node.js, and Flutter Web SPA

> **Specification Reference:** [`vanshasetu_master_specification.md`](vanshasetu_master_specification.md)  
> **Sovereign Constitution:** [`constitution.md`](constitution.md)  
> **Target Environment:** BigRock Cloud Linux Shared / VPS Hosting with cPanel  
> **Release Artifacts:** [`dist/public_html.tar.gz`](../dist/public_html.tar.gz) & [`dist/vanshasetu-api.tar.gz`](../dist/vanshasetu-api.tar.gz)

---

## 1. Production Architecture Overview

```
                                    Internet / DNS (Cloudflare / BigRock)
                                                  │
                                                  ▼
                        ┌──────────────────────────────────────────────────┐
                        │      BigRock Apache Reverse Proxy (cPanel)       │
                        │    - AutoSSL / Let's Encrypt (TLS 1.3 Strict)    │
                        │    - mod_rewrite, mod_headers, mod_deflate       │
                        └─────────┬───────────────────────────────┬────────┘
                                  │                               │
                Requests to /     │                               │ Requests to /api/* or
                (or vanshasetu.in)│                               │ api.vanshasetu.in
                                  ▼                               ▼
       ┌─────────────────────────────────────┐  ┌────────────────────────────────────┐
       │     ~/public_html/ (Flutter Web)    │  │ ~/vanshasetu-api/ (CloudLinux API) │
       │  - compiled CanvasKit SPA bundle    │  │  - Phusion Passenger Node.js 20    │
       │  - ServiceWorker offline cache      │  │  - Zero-Trust E2EE & HMAC Guard    │
       │  - .htaccess HTML5 SPA fallback     │  │  - CSPRNG 12-Digit VUID Generator  │
       └─────────────────────────────────────┘  └─────────────────┬──────────────────┘
                                                                  │ Localhost socket / 3306
                                                                  ▼
                                                ┌────────────────────────────────────┐
                                                │        MySQL 8.0 InnoDB Engine     │
                                                │  - Transparent Data Enc (TDE)      │
                                                │  - utf8mb4_unicode_ci collation    │
                                                │  - Immutable Audit Chain           │
                                                └────────────────────────────────────┘
```

---

## 2. Automated Production Build Preparation

Before deploying, generate the verified production bundle from the root repository:

```bash
# 1. Execute the production build pipeline (runs tests, compiles Flutter, packages archives)
./deploy/build_production.sh

# 2. Verify that release artifacts and checksums are created:
ls -lh dist/
# Output will display:
# - public_html.tar.gz
# - vanshasetu-api.tar.gz
# - checksums.sha256
```

---

## 3. Step-by-Step Deployment Runbook

### Step 3.1: MySQL Database Provisioning (phpMyAdmin / cPanel)
1. Log into your **BigRock cPanel** dashboard.
2. Navigate to **Databases** $\to$ **MySQL® Databases**.
3. Create a new database:
   - Database Name: `cpaneluser_vanshasetu` (or `vanshasetu_db`)
4. Create a dedicated database user:
   - Username: `cpaneluser_vuser`
   - Password: Generate a strong 32+ character password.
5. Add User to Database:
   - Assign user to the created database.
   - Grant **ALL PRIVILEGES** (or `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `CREATE`, `DROP`, `INDEX`, `ALTER`, `REFERENCES`).
6. Open **phpMyAdmin** from cPanel:
   - Select the newly created database.
   - Click on the **Import** tab.
   - Choose file: [`database/schema.sql`](../database/schema.sql).
   - Click **Import** to execute the DDL (creates all 7 tables with InnoDB TDE `ENCRYPTION='Y'` and strict CHECK constraints: `citizens`, `relationships`, `citizen_documents`, `duplicate_conflict_logs`, `audit_logs`, `citizen_education`, `marriages`).
   - Run `node database/validate_ddl.js` to assert 30/30 schema constraints.
   - *(Optional Initial Seed)*: Import [`database/seed.sql`](../database/seed.sql) to populate standard multi-generational Indian lineages with education and civil marriage records.

---

### Step 3.2: Node.js API Service Setup (CloudLinux Passenger)
1. In cPanel, navigate to **Software** $\to$ **Setup Node.js App**.
2. Click **Create Application**:
   - **Node.js Version:** `20.x` or `18.x LTS`
   - **Application Mode:** `Production`
   - **Application Root:** `vanshasetu-api`
   - **Application URL:** `api.vanshasetu.in` (or subfolder path `vanshasetu.in/api`)
   - **Application Startup File:** `app.js` (or `server.js`)
3. Click **Create**.
4. Upload Backend Code:
   - In cPanel **File Manager**, navigate to the newly created directory `~/vanshasetu-api/`.
   - Upload [`dist/vanshasetu-api.tar.gz`](../dist/vanshasetu-api.tar.gz).
   - Right-click and choose **Extract**.
5. Configure Environment Secrets:
   - In the Node.js App Manager under **Environment variables**, click **Add Variable**:
     - `DB_HOST`: `127.0.0.1`
     - `DB_USER`: `cpaneluser_vuser`
     - `DB_PASSWORD`: `YourDatabasePassword`
     - `DB_NAME`: `cpaneluser_vanshasetu`
     - `HASH_SALT`: `YourStrongProductionHashSalt_Min64Hex`
     - `NODE_ENV`: `production`
6. Install Dependencies:
   - Click **Run NPM Install** in the cPanel interface.
7. Restart Service:
   - Click **Restart Application**.

---

### Step 3.3: Flutter Web SPA Deployment (`public_html`)
1. In cPanel **File Manager**, navigate to `~/public_html/` (or the document root for `vanshasetu.in`).
2. Upload [`dist/public_html.tar.gz`](../dist/public_html.tar.gz).
3. Right-click the archive and click **Extract**.
4. Confirm the following files exist in `public_html/`:
   - `index.html`
   - `flutter.js`
   - `main.dart.js`
   - `assets/`
   - `canvaskit/`
   - `.htaccess` *(Crucial for client-side routing, HSTS headers, and HTTPS force)*
5. Remove `public_html.tar.gz` to preserve disk space.

---

### Step 3.4: DNS & SSL/TLS 1.3 Configuration
1. In BigRock Domain Management / DNS Zone Editor, ensure records point to your server IP:
   - `A` record for `vanshasetu.in` $\to$ `SERVER_IP`
   - `A` or `CNAME` record for `api.vanshasetu.in` $\to$ `SERVER_IP`
2. In cPanel, navigate to **Security** $\to$ **SSL/TLS Status**.
3. Select `vanshasetu.in` and `api.vanshasetu.in`.
4. Click **Run AutoSSL** (provisions free Let's Encrypt / Sectigo certificates with auto-renewal).
5. Verify in browser that `https://vanshasetu.in` displays a secure padlock with TLS 1.3.

---

## 4. Zero-Downtime Maintenance & Hot-Reload

CloudLinux Phusion Passenger monitors the `tmp/restart.txt` file descriptor. Whenever you push an update to the backend API without wanting downtime:

```bash
# Via cPanel Terminal or SSH:
cd ~/vanshasetu-api
touch tmp/restart.txt
```
Passenger will cleanly drain existing TCP connections and spawn new worker threads with zero dropped packets.

---

## 5. Post-Deployment Verification & Smoke Tests

Verify the deployment using the automated verification suite:

```bash
# From your local terminal, run against the production domain:
./deploy/verify_deployment.sh https://api.vanshasetu.in

# Or verify local preview:
./deploy/verify_deployment.sh http://localhost:3000
```

### Manual Health & Integrity Checklist
- [ ] **Health Endpoint:** `curl -s https://api.vanshasetu.in/health` returns `status: "healthy"`.
- [ ] **HSTS Enforced:** `curl -sI https://vanshasetu.in` returns `Strict-Transport-Security: max-age=31536000`.
- [ ] **12-Digit Routing:** `curl -sI https://api.vanshasetu.in/api/v1/tree/123` returns `400 Bad Request`.
- [ ] **Demographics Analytics:** `curl -s https://api.vanshasetu.in/api/v1/analytics/demographics` returns population pyramid and category breakdown.
- [ ] **Audit Blockchain Integrity:** `curl -s https://api.vanshasetu.in/api/v1/audit/verify-integrity` returns `chain_valid: true`.
- [ ] **Flutter SPA Canvas:** Opening `https://vanshasetu.in` loads the reactive Kinship Canvas with interactive nodes.
- [ ] **VanshaCard QR Scannability:** Generating a VanshaCard produces a valid QR code pointing to `https://vanshasetu.in/tree/:vuid`.
