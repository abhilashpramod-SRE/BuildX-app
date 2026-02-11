import 'dart:io';

import 'package:flutter/material.dart';

import '../models/client.dart';
import '../models/expense.dart';
import '../models/invoice.dart';
import '../models/role.dart';
import '../models/user.dart';
import '../repositories/buildx_repository.dart';
import '../services/auth_service.dart';
import '../services/pdf_service.dart';

class AppViewModel extends ChangeNotifier {
  AppViewModel({
    required this.auth,
    required this.repository,
    required this.pdfService,
  });

  final AuthService auth;
  final BuildXRepository repository;
  final PdfService pdfService;

  AppUser? get currentUser => auth.currentUser;
  bool get isOnline => repository.syncService.isOnline;
  int get pendingOfflineActions => repository.syncService.pendingActions;

  Future<void> login(String identity, String password, UserRole role) async {
    await auth.login(identity: identity, password: password, role: role);
    notifyListeners();
  }

  void logout() {
    auth.logout();
    notifyListeners();
  }

  void setOnline(bool value) {
    repository.syncService.isOnline = value;
    notifyListeners();
  }

  Future<void> syncNow() async {
    await repository.syncService.sync();
    notifyListeners();
  }

  Future<void> submitExpense(Expense expense) async {
    await repository.submitExpense(expense);
    notifyListeners();
  }

  List<Expense> myExpenses({
    String? clientId,
    ExpenseStatus? status,
    String? project,
  }) {
    final user = currentUser;
    if (user == null) return <Expense>[];

    return repository.expensesByUser(user).where((e) {
      final clientOk = clientId == null || clientId.isEmpty || e.clientId == clientId;
      final statusOk = status == null || e.status == status;
      final projectOk =
          project == null || project.isEmpty || (e.project ?? '').toLowerCase() == project.toLowerCase();
      return clientOk && statusOk && projectOk;
    }).toList(growable: false);
  }

  List<String> myProjects() {
    final user = currentUser;
    if (user == null) return <String>[];
    final set = <String>{};
    for (final e in repository.expensesByUser(user)) {
      if ((e.project ?? '').trim().isNotEmpty) {
        set.add(e.project!.trim());
      }
    }
    return set.toList()..sort();
  }

  List<Expense> pendingExpenses() => repository.pendingExpenses();

  List<Expense> approvedExpenses() => repository.expenses
      .where((e) => e.status == ExpenseStatus.approved)
      .toList(growable: false);


  List<Expense> approvedExpensesByClient(String? clientId) {
    return repository.expenses.where((e) {
      final approved = e.status == ExpenseStatus.approved;
      final clientMatch = clientId == null || clientId.isEmpty || e.clientId == clientId;
      return approved && clientMatch;
    }).toList(growable: false);
  }

  List<Expense> expensesByClient(String clientId) {
    return repository.expenses
        .where((e) => e.clientId == clientId)
        .toList(growable: false);
  }

  Future<void> approveExpense(Expense expense) async {
    await repository.approveExpense(expense, actor: currentUser?.name ?? 'Supervisor');
    notifyListeners();
  }

  Future<void> rejectExpense(Expense expense, String reason) async {
    await repository.rejectExpense(expense, reason,
        actor: currentUser?.name ?? 'Supervisor');
    notifyListeners();
  }

  Future<Client> registerClient({
    required String name,
    required String address,
    required String phone,
  }) async {
    final client =
        await repository.createClient(name: name, address: address, phone: phone);
    notifyListeners();
    return client;
  }

  List<Client> searchClients(String query) => repository.searchClients(query);

  List<Client> allClients() => repository.clients;

  Invoice createInvoice({
    required Client client,
    required List<Expense> items,
    String? notes,
  }) {
    final invoice = repository.createInvoice(
      client: client,
      items: items,
      notes: notes,
    );
    notifyListeners();
    return invoice;
  }

  List<Invoice> invoiceHistory() => repository.invoices.reversed.toList(growable: false);

  Future<File> createInvoicePdf(Invoice invoice) => pdfService.generateInvoicePdf(invoice);
}
