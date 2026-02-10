# BuildX

Android-first Flutter application for construction expense tracking, supervisor approvals, client registration, and invoice PDF generation.

## Implemented Scope

- Role-based login (Contractor, Engineer/Procurement, Supervisor/Owner)
- Role-based dashboard actions
- Expense upload form with:
  - Item description
  - Amount
  - Date
  - Project dropdown
  - Bill image selection
  - Notes
- Supervisor approval workflow:
  - Approve / Reject with mandatory reason
  - Auto-generated invoice draft on approval
- Client registration with auto-generated client IDs
- Invoice generation by searching clients and selecting approved expenses
- A4 PDF invoice generation with company details, invoice metadata, itemized table, total, and watermark
- Local Android file save path for generated PDF
- Offline-first queue + manual sync toggle
- Backend abstraction for Firebase/Supabase integration
- Audit logs for core actions

## Tech Notes

- UI: Flutter Material 3 with BuildX palette (navy, orange, white)
- State management: `provider` + `ChangeNotifier`
- PDF generation: `pdf` package
- Storage path: `path_provider`
- Bill image picker: `image_picker`

## Project Structure

- `lib/main.dart` — app bootstrap and DI
- `lib/models` — domain entities (user, expense, client, invoice, audit)
- `lib/services` — auth, backend interface, offline sync, PDF generation
- `lib/repositories` — business logic and local data handling
- `lib/viewmodels` — UI-facing state and actions
- `lib/screens` — role dashboards and forms

## Backend Integration

Current setup uses a pluggable backend interface:

- `FirebaseBackendService`
- `SupabaseBackendService`

Replace placeholder methods in `lib/services/backend_service.dart` with real SDK calls.

## Offline Support
.
`OfflineSyncService` queues write operations when offline and replays queued actions when back online.

## Run

1. Install Flutter SDK.
2. Run `flutter pub get`.
3. Run `flutter run` on Android emulator/device.
