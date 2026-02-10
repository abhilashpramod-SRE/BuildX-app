import 'package:uuid/uuid.dart';

import '../models/audit_log.dart';
import '../models/client.dart';
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

  List<Expense> get expenses => List<Expense>.unmodifiable(_expenses);
  List<Client> get clients => List<Client>.unmodifiable(_clients);
  List<Invoice> get invoices => List<Invoice>.unmodifiable(_invoices);
  List<AuditLog> get auditLogs => List<AuditLog>.unmodifiable(_auditLogs);

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

    // Automatic invoice generation on approval.
    final fallbackClient = _clients.firstWhere(
      (c) => c.id == 'CL-SYSTEM',
      orElse: () {
        final client = Client(
          id: 'CL-SYSTEM',
          name: 'Pending Client Assignment',
          address: 'Update client details before final dispatch',
          phone: '-',
        );
        _clients.add(client);
        return client;
      },
    );

    _invoices.add(
      Invoice(
        id: const Uuid().v4(),
        invoiceNumber: 'AUTO-${DateTime.now().millisecondsSinceEpoch}',
        client: fallbackClient,
        projectName: expense.project,
        items: [expense],
        date: DateTime.now(),
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
  }) async {
    final client = Client(
      id: 'CL-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      address: address,
      phone: phone,
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

  List<Client> searchClients(String query) {
    final q = query.toLowerCase().trim();
    return _clients
        .where((c) =>
            c.name.toLowerCase().contains(q) || c.phone.toLowerCase().contains(q))
        .toList();
  }

  Invoice createInvoice({
    required Client client,
    required String projectName,
    required List<Expense> items,
    String? notes,
  }) {
    final invoice = Invoice(
      id: const Uuid().v4(),
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      client: client,
      projectName: projectName,
      items: items,
      date: DateTime.now(),
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
