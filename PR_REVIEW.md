# PR Review – Checksum Implementation

## 📌 Scope of this PR
This PR introduces a **server-side checksum generation and verification workflow** for stored files.
The goal is to ensure **file integrity**, **auditability**, and **clear separation of responsibilities** between frontend and backend.

---

## ✅ Key Architectural Decisions

### 1. Single Source of Truth (Backend)
- **All checksum operations are performed in the backend**
- The frontend never calculates, stores, or submits checksums
- The backend is the only trusted component

**Rationale**
- Prevents client-side manipulation
- Ensures consistent hashing algorithm and file source
- Enables auditability and reproducibility

---

### 2. Lifecycle of a Checksum

#### A. Checksum Creation
- Triggered explicitly by a user action (e.g. “Generate checksum”)
- Backend:
  1. Reads the file from storage
  2. Calculates the checksum (e.g. SHA-256)
  3. Persists the checksum as a reference value

**Database changes**
- `checksum`
- `checksum_type`
- `checksum_created_at`

---

#### B. Checksum Verification (“Verify” / “Re-verify”)
- Backend:
  1. Loads stored checksum from DB
  2. Re-calculates checksum from the current file
  3. Compares values
  4. Stores verification result

**Important**
- The stored checksum is **never modified** during verification
- “Verify” and “Re-verify” are technically identical (UI semantics only)

**Database changes**
- `checksum_status` (`OK` / `FAIL`)
- `checksum_last_verified_at`

---

### 3. Explicit Re-generation
If a file is intentionally replaced or regenerated:
- A **new checksum must be explicitly generated**
- The previous checksum reference is overwritten intentionally

This avoids silent or accidental reference changes.

---

## 🗄️ Database Model (Relevant Fields)

| Field | Purpose |
|---|---|
| `checksum` | Stored reference checksum |
| `checksum_type` | Hash algorithm (e.g. sha256) |
| `checksum_created_at` | When reference was generated |
| `checksum_last_verified_at` | Last verification timestamp |
| `checksum_status` | Result of last verification |

---

## 🔁 Backend Responsibility Summary

The backend is responsible for:
- Reading the authoritative file from storage
- Calculating checksums
- Comparing against stored reference
- Persisting verification results

The frontend is responsible for:
- Triggering actions
- Displaying status and timestamps
- Never handling raw checksums

---

## 🔐 Security & Integrity Considerations

- No trust in client-side data
- No checksum values sent from FE to BE
- Verification is reproducible and deterministic
- Suitable for audit logs and compliance requirements

---

## 🧠 Reviewer Checklist

Please verify:
- [ ] No checksum calculation exists in frontend code
- [ ] Backend always reads file from storage (not from request payload)
- [ ] Verification does not overwrite reference checksum
- [ ] Explicit action required to regenerate checksum
- [ ] Error handling for missing checksum is in place

---

## 📎 Notes
This implementation follows a **clear separation of concerns** and aligns with best practices for integrity checks in distributed systems.
