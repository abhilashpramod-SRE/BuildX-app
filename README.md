# BuildX

Android-first Flutter application for construction expense tracking, supervisor approvals, client registration, invoice generation, and PDF downloads.

## Implemented Scope

- Role-based login with 2 roles:
  - Contractor
  - Supervisor/Owner
- Login branding with centered **BuildX** and subtitle **Next-Gen Construction Management**
- Expense upload tied to **Client** (required) with:
  - Item description
  - Amount
  - Optional project tag (for filtering)
  - Date
  - Bill image upload
  - Notes
- Contractor Submitted Bills as a dedicated button/screen
- Contractor filters on submitted bills:
  - Client
  - Status
  - Project
- Supervisor approval workflow:
  - Approve
  - Reject (mandatory reason)
- Invoice generation from **approved expenses** by selected client with multi-select item checkbox
- Dedicated Approved Bills page with client filter
- Consolidated Client Bill page: search client, view all client bills, generate single consolidated PDF with final total
- Invoice History screen with **multiple download support** (each download creates a new timestamped PDF file)
- A4 invoice PDF with company details, invoice number, date, client details, itemized list, total amount, watermark
- Downloaded invoices are saved under `BuildX/<yyyy-MM-dd>/` using `<client_name>_<yyyy-MM-dd>.pdf` (date-wise subfolders created automatically)
- Offline queue + manual sync toggle
- Material 3 UI with modern Bottom Navigation + Card Layout (Approvals removed from bottom menu)
- Navy + Orange professional theme with large tap targets
- Role-based dashboard tabs for practical field usage
- Backend abstraction stubs (Firebase/Supabase)

## Run on Android (Step-by-Step)

1. Install Flutter SDK, Android Studio, Android SDK.
2. Verify setup:

```bash
flutter --version
flutter doctor
```

3. Install packages:

```bash
flutter pub get
```

4. Connect device/start emulator:

```bash
flutter devices
```

5. Run app:

```bash
flutter run
```

## Functional Demo (Step-by-Step)

### 1) Supervisor prep

1. Login as **Supervisor/Owner**.
2. Go to **Register / Manage Clients**.
3. Add one or more clients.

### 2) Contractor expense submission

1. Logout and login as **Contractor**.
2. Tap **Upload Expense**.
3. Select a client (required).
4. Fill item, amount, optional project, date, bill image, notes.
5. Submit.
6. Open **My Submitted Bills** button.
7. Verify list and test filters (client/status/project).

### 3) Supervisor approval and invoice

1. Logout and login as **Supervisor/Owner**.
2. Open **Bills Pending Approval**.
3. Approve/reject expenses.
4. Open **Generate Invoice**.
5. Search/select client.
6. Select one or more approved items in Generate Invoice and generate invoice.
7. Verify invoice generated confirmation.
8. Open **Approved Bills** tab and test client filter.
9. Open **Generated Bills** and download selected bills.

### 4) Consolidated client bill

1. Open **Consolidated** tab.
2. Search and select a client.
3. Verify all bills for that client are listed with each bill as an item.
4. Verify final consolidated total is shown.
5. Generate consolidated bill PDF.

### 5) Multiple downloads

1. Open **Generated Bills**.
2. Click download on an invoice multiple times.
3. Confirm each download creates a unique timestamped PDF file.

### 6) Offline + sync

1. Turn app offline using top switch.
2. Perform write actions (submit expense, etc.).
3. Turn online and tap sync icon.
4. Verify queued actions flush.

## Android build issue: `metadata.bin` / Flutter plugin loader

If Android build fails with Gradle cache `metadata.bin` errors, follow the repair guide in [`docs/android-build-troubleshooting.md`](docs/android-build-troubleshooting.md) and run the provided repair scripts (`scripts/repair_android_gradle_cache.ps1` for Windows or `scripts/repair_android_gradle_cache.sh` for macOS/Linux).
