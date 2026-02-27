# BuildX Functional & Technical Document

## 1) Product Overview

BuildX is an Android-first Flutter application for construction expense lifecycle management: contractor expense submission, owner/supervisor approvals, client management, invoice generation, and PDF export/download.

Primary roles:
- Contractor
- Supervisor/Owner

## 2) Functional Specification

### 2.1 Role-based Access

#### Contractor
- Log in and access contractor-specific tabs.
- Submit expenses with client, project, item, amount, date, notes, and image.
- View submitted bills and filter by client/status/project.
- Track contractor metrics (pending/approved/rejected totals).

#### Supervisor/Owner
- Access owner actions from Home:
  - Pending approvals
  - Approved bills
  - Register/manage clients
  - Owner profile
  - Generate invoice
  - Generated bills and consolidated bill views (when invoices exist)
- Approve or reject expenses (with reason on reject).
- Manage clients and per-client projects.
- Manage owner/company profile and logo path.
- Generate invoice and consolidated bill PDFs.

### 2.2 Core Flows

1. **Authentication**
   - User enters email/password/role and is routed to role dashboard.

2. **Client & Project Management**
   - Owner creates clients and optional project lists.
   - Owner can edit existing client details and projects.

3. **Expense Submission**
   - Contractor selects client.
   - Project field adapts based on client project count:
     - one project: auto-selected
     - multiple projects: dropdown
     - no projects: optional manual text
   - Contractor enters details and submits.

4. **Approval Workflow**
   - Owner approves/rejects pending expenses.
   - Reject path requires reason.

5. **Invoice & Consolidation**
   - Owner selects approved items to generate invoice.
   - Invoice history supports selection and PDF download.
   - Consolidated bill screen aggregates bills and exports a final PDF.

6. **Offline/Online Sync**
   - App has an online toggle.
   - Going online triggers queue sync.
   - Manual sync action is available.

## 3) Technical Architecture

### 3.1 Stack
- Flutter (Material 3)
- Provider for state management
- `pdf` for document generation
- `image_picker`, `intl`, `path_provider`, `uuid`

### 3.2 Layered Structure
1. **Screens / UI** (`lib/screens/...`)
2. **ViewModel** (`lib/viewmodels/app_view_model.dart`)
3. **Repository** (`lib/repositories/buildx_repository.dart`)
4. **Services** (`lib/services/...`)
5. **Models** (`lib/models/...`)

Pattern is MVVM-like with in-memory repository and backend stubs.

### 3.3 App Startup
- `main()` wires services/repository/viewmodel via Provider.
- If user is not authenticated, app shows Login.
- On successful login, app shows role dashboard.

### 3.4 Data Models
- `Expense`: lifecycle, status, amounts, links, and approval metadata.
- `Client`: identity + project list.
- `CompanyProfile`: owner/company branding and tax metadata.
- `Invoice`: client + items + company snapshot + totals.
- `AuditLog`: action tracking.

### 3.5 Repository Behavior
`BuildXRepository` currently handles in-memory data for:
- expenses
- clients
- invoices
- audit logs
- owner profile

Notable behavior:
- Approval path auto-creates invoice objects.
- Backend operations run through offline-sync enqueue/run logic.

### 3.6 Services
- `OfflineSyncService`: queue when offline, flush when online.
- `AuthService`: currently mocked.
- `BackendService`: Firebase/Supabase stubs.
- `PdfService`: builds A4 PDFs and includes owner logo when path is valid.

## 4) Non-Functional Notes
- Persistence is currently in-memory; restart resets runtime data.
- Auth and backend integrations are placeholders.
- PDF logo rendering depends on a valid local path.

## 5) Risks / Open Items
1. Add durable local storage (e.g., Drift/Hive/SQLite).
2. Add robust sync conflict resolution.
3. Strengthen validation and business rules.
4. Add automated tests and CI checks.

## 6) Suggested Next Docs
- `docs/functional-spec.md`
- `docs/technical-architecture.md`
- `docs/api-data-model.md`
- `docs/qa-uat-checklist.md`
