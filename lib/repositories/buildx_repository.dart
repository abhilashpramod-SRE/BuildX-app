import 'package:uuid/uuid.dart';

import '../models/audit_log.dart';
import '../models/client.dart';
import '../models/company_profile.dart';
import '../models/expense.dart';
import '../models/invoice.dart';
import '../models/user.dart';
import '../services/backend_service.dart';
import '../services/offline_sync_service.dart';

class BuildXRepository {
  BuildXRepository({
    required this.backend,
    required this.syncService,
  });

  final BackendService backend;
  final OfflineSyncService syncService;

  final List<Expense> _expenses = <Expense>[];
  final List<Client> _clients = <Client>[];
  final List<Invoice> _invoices = <Invoice>[];
  final List<AuditLog> _auditLogs = <AuditLog>[];

  CompanyProfile _ownerProfile = const CompanyProfile(
    name: 'VIndia',
    tagline: 'Infrasec Pvt Ltd',
    address: '42 Industrial Layout, Bengaluru',
    gstinUin: '32AAHCV5346C1ZK',
    stateName: 'Kerala',
    stateCode: '32',
    emailId: 'support.vindia@gmail.com',
  );

  List<Expense> get expenses => List<Expense>.unmodifiable(_expenses);
  List<Client> get clients => List<Client>.unmodifiable(_clients);
  List<Invoice> get invoices => List<Invoice>.unmodifiable(_invoices);
  List<AuditLog> get auditLogs => List<AuditLog>.unmodifiable(_auditLogs);
  CompanyProfile get ownerProfile => _ownerProfile;

  void updateOwnerProfile(CompanyProfile profile) {
    _ownerProfile = profile;
  }

  Future<void> submitExpense(Expense expense) async {
    _expenses.add(expense);
    _auditLogs.add(
      AuditLog(
        timestamp: DateTime.now(),
        actor: expense.submitter.name,
        action: 'SUBMIT_EXPENSE',
        entityId: expense.id,
      ),
    );
    await syncService.enqueueOrRun(() => backend.uploadExpense(expense));
  }

  List<Expense> expensesByUser(AppUser user) {
    return _expenses.where((e) => e.submitter.id == user.id).toList();
  }

  List<Expense> pendingExpenses() {
    return _expenses
        .where((e) => e.status == ExpenseStatus.pending)
        .toList(growable: false);
  }

  Future<void> approveExpense(Expense expense, {String actor = 'Supervisor'}) async {
    expense.status = ExpenseStatus.approved;
    _auditLogs.add(
      AuditLog(
        timestamp: DateTime.now(),
        actor: actor,
        action: 'APPROVE_EXPENSE',
        entityId: expense.id,
      ),
    );

    final client = _clients.firstWhere(
      (c) => c.id == expense.clientId,
      orElse: () {
        final fallback = Client(
          id: expense.clientId,
          name: expense.clientName,
          address: 'Address pending',
          phone: '-',
        );
        _clients.add(fallback);
        return fallback;
      },
    );

    _invoices.add(
      Invoice(
        id: const Uuid().v4(),
        invoiceNumber: 'AUTO-${DateTime.now().millisecondsSinceEpoch}',
        client: client,
        items: [expense],
        date: DateTime.now(),
        companyProfile: _ownerProfile,
        notes: 'Auto-generated on expense approval.',
      ),
    );

    await syncService.enqueueOrRun(() => backend.updateExpense(expense));
  }

  Future<void> rejectExpense(Expense expense, String reason,
      {String actor = 'Supervisor'}) async {
    expense.status = ExpenseStatus.rejected;
    expense.rejectionReason = reason;
    _auditLogs.add(
      AuditLog(
        timestamp: DateTime.now(),
        actor: actor,
        action: 'REJECT_EXPENSE',
        entityId: expense.id,
        metadata: reason,
      ),
    );
    await syncService.enqueueOrRun(() => backend.updateExpense(expense));
  }

  Future<Client> createClient({
    required String name,
    required String address,
    required String phone,
    List<String>? projects,
  }) async {
    final client = Client(
      id: 'CL-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      address: address,
      phone: phone,
      projects: projects,
    );
    _clients.add(client);
    _auditLogs.add(
      AuditLog(
        timestamp: DateTime.now(),
        actor: 'Supervisor',
        action: 'CREATE_CLIENT',
        entityId: client.id,
      ),
    );
    await syncService.enqueueOrRun(() => backend.createClient(client));
    return client;
  }

  void updateClient({
    required String clientId,
    required String name,
    required String address,
    required String phone,
    List<String>? projects,
  }) {
    final index = _clients.indexWhere((c) => c.id == clientId);
    if (index == -1) return;
    _clients[index] = _clients[index].copyWith(
      name: name,
      address: address,
      phone: phone,
      projects: projects,
    );
    _auditLogs.add(
      AuditLog(
        timestamp: DateTime.now(),
        actor: 'Supervisor',
        action: 'UPDATE_CLIENT',
        entityId: clientId,
      ),
    );
  }

  List<Client> searchClients(String query) {
    final q = query.toLowerCase().trim();
    return _clients
        .where((c) =>
            c.name.toLowerCase().contains(q) || c.phone.toLowerCase().contains(q))
        .toList();
  }

  Invoice createInvoice({
    required Client client,
    required List<Expense> items,
    String? notes,
  }) {
    final invoice = Invoice(
      id: const Uuid().v4(),
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      client: client,
      items: items,
      date: DateTime.now(),
      companyProfile: _ownerProfile,
      notes: notes,
    );

    _auditLogs.add(
      AuditLog(
        timestamp: DateTime.now(),
        actor: 'Supervisor',
        action: 'CREATE_INVOICE',
        entityId: invoice.id,
      ),
    );

    _invoices.add(invoice);
    return invoice;
  }
}
