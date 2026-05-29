# Week 9 Security Audit — cis410-deploy-sa
**Project:** cis410-btamer
**Date:** 2026-05-28
**Auditor:** Sam Tamer

---

## 1. IAM Audit Results

### Before — Week 8 Configuration (over-permissioned)
| Role | Scope | Problem |
|---|---|---|
| roles/run.admin | Project | Overly broad — grants ability to delete services and modify IAM, not just deploy |
| roles/storage.admin | Project | Overly broad — grants access to ALL GCS buckets in the project |
| roles/artifactregistry.writer | Project | Acceptable — scoped to push images only |
| roles/viewer | Project | Acceptable — read-only project metadata |
| roles/iam.serviceAccountUser | Compute SA | Required — needed to act as Compute Engine default SA |

### After — Week 9 Least-Privilege Fix
| Role | Scope | Why Sufficient |
|---|---|---|
| roles/run.developer | Project | Deploy only — cannot delete services or modify IAM |
| roles/storage.admin | tfstate bucket only | Scoped to one bucket — not all storage |
| roles/artifactregistry.writer | Project | Unchanged — push images only |
| roles/viewer | Project | Unchanged — read project metadata |
| roles/iam.serviceAccountUser | Compute SA | Unchanged — required for Cloud Run deployment |

---

## 2. Secret Manager Migration
- **Secret created:** `flask-app-secret`
- **Replication:** automatic
- **Access granted to:** `cis410-deploy-sa@cis410-btamer.iam.gserviceaccount.com` — roles/secretmanager.secretAccessor on this secret only
- **Access granted to:** `924105047271-compute@developer.gserviceaccount.com` — roles/secretmanager.secretAccessor on this secret only (required for Cloud Run runtime access)
- **Cloud Run update:** APP_SECRET environment variable mounted from Secret Manager at runtime

---

## 3. Monitoring Configuration
- **Log-based alert:** `cis410-flask-app-alert` — fires on severity>=WARNING for cis410-flask-app
- **Notification channel:** samtamer360@gmail.com
- **Billing budget:** `cis410-monthly-budget` — $20 limit, alerts at 50% / 90% / 100%

---

## 4. Reflection

**Q1: Why is roles/run.admin inappropriate for a CI/CD pipeline service account?**
roles/run.admin can delete services and change IAM which is way more than a pipeline needs. roles/run.developer does the job with way less risk.

---

**Q2: What is the security difference between storing a secret in GitHub Secrets vs. Google Secret Manager?**
GitHub Secrets are hard to track and rotate if something goes wrong. Secret Manager logs every access and fetches the secret at runtime instead of storing it in the pipeline.

---

**Q3: A coworker says "I will clean up IAM permissions after the project launches. For now I need everything to work fast." What is the risk of this approach?**
Temporary permissions almost never get cleaned up once the project launches. If the account gets compromised in the meantime, an attacker has way more access than they should.