import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../models/role.dart';
import '../../viewmodels/app_view_model.dart';
import '../approval/approval_screen.dart';
import '../approval/approved_bills_screen.dart';
import '../client/client_registration_screen.dart';
import '../expense/expense_upload_screen.dart';
import '../expense/submitted_bills_screen.dart';
import '../invoice/consolidated_bill_screen.dart';
import '../invoice/invoice_generation_screen.dart';
import '../invoice/invoice_history_screen.dart';
import '../profile/owner_profile_screen.dart';
import '../widgets/expense_list_widget.dart';

class RoleDashboardScreen extends StatefulWidget {
  const RoleDashboardScreen({super.key});

  @override
  State<RoleDashboardScreen> createState() => _RoleDashboardScreenState();
}

class _RoleDashboardScreenState extends State<RoleDashboardScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final user = vm.currentUser!;
    final hasInvoices = vm.invoiceHistory().isNotEmpty;

    final destinations = user.role == UserRole.contractor
        ? const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Submitted Bills'),
          ]
        : const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          ];

    if (_index >= destinations.length) {
      _index = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.name}'),
        actions: [
          Row(
            children: [
              const Text('Online', style: TextStyle(color: Colors.white)),
              Switch(
                value: vm.isOnline,
                onChanged: (v) async => vm.setOnline(v),
                activeColor: Colors.orange,
              ),
            ],
          ),
          IconButton(
            onPressed: vm.syncNow,
            icon: const Icon(Icons.sync),
            tooltip: 'Sync (${vm.pendingOfflineActions})',
          ),
          IconButton(
            onPressed: vm.logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: _bodyForRole(user.role, hasInvoices),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (idx) => setState(() => _index = idx),
        destinations: destinations,
      ),
    );
  }

  Widget _bodyForRole(UserRole role, [bool hasInvoices = true]) {
    final vm = context.watch<AppViewModel>();

    if (role == UserRole.contractor) {
      if (_index == 2) return const SubmittedBillsContent();
      if (_index == 1) return _contractorDashboard(vm);
      return _contractorHome();
    }

    if (_index == 1) {
      return _ownerDashboard(vm);
    }

    return _ownerHome(hasInvoices);
  }

  Widget _contractorHome() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _cardAction('Upload Expense', Icons.upload_file, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpenseUploadScreen()),
          );
        }),
        const SizedBox(height: 12),
        const ExpenseListWidget(title: 'My Recent Submitted Bills', mineOnly: true),
      ],
    );
  }

  Widget _contractorDashboard(AppViewModel vm) {
    final my = vm.myExpenses();
    final pending = my.where((e) => e.status == ExpenseStatus.pending).length;
    final approved = my.where((e) => e.status == ExpenseStatus.approved).length;
    final rejected = my.where((e) => e.status == ExpenseStatus.rejected).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _metricCard('Total Expenses', '${my.length}', Icons.receipt),
        _metricCard('Pending', '$pending', Icons.hourglass_top),
        _metricCard('Approved', '$approved', Icons.check_circle),
        _metricCard('Rejected', '$rejected', Icons.cancel),
      ],
    );
  }

  Widget _ownerHome([bool hasInvoices = true]) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _cardAction('Bills Pending Approval', Icons.approval, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApprovalScreen()),
          );
        }),
        _cardAction('Approved Bills', Icons.verified, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApprovedBillsScreen()),
          );
        }),
        _cardAction('Register / Manage Clients', Icons.people, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClientRegistrationScreen()),
          );
        }),
        _cardAction('Owner Profile', Icons.business, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OwnerProfileScreen()),
          );
        }),
        _cardAction('Generate Invoice', Icons.receipt_long, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InvoiceGenerationScreen()),
          );
        }),
        if (hasInvoices)
          _cardAction('Generated Bills', Icons.download, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InvoiceHistoryScreen()),
            );
          }),
        if (hasInvoices)
          _cardAction('Consolidated Client Bill', Icons.summarize, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConsolidatedBillScreen()),
            );
          }),
      ],
    );
  }

  Widget _ownerDashboard(AppViewModel vm) {
    final pending = vm.pendingExpenses().length;
    final approved = vm.approvedExpenses().length;
    final clients = vm.allClients().length;
    final invoicesGenerated = vm.invoiceHistory().length;
    final invoicedExpenseIds = vm
        .invoiceHistory()
        .expand((inv) => inv.items.map((e) => e.id))
        .toSet();
    final toGenerate = vm
        .approvedExpenses()
        .where((e) => !invoicedExpenseIds.contains(e.id))
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _metricCard('Bills Pending Approval', '$pending', Icons.approval),
        _metricCard('Bills Approved', '$approved', Icons.verified),
        _metricCard('Registered Clients', '$clients', Icons.people),
        _metricCard('Invoices to Generate', '$toGenerate', Icons.assignment_late),
        _metricCard('Invoices Generated', '$invoicesGenerated', Icons.receipt_long),
        const SizedBox(height: 12),
        const ExpenseListWidget(title: 'Pending Bills for Approval'),
      ],
    );
  }


  // Compatibility getters so older metric references remain valid.
  int get pending => context.read<AppViewModel>().pendingExpenses().length;
  int get approved =>
      context.read<AppViewModel>().approvedExpenses().length;
  int get clients => context.read<AppViewModel>().allClients().length;
  int get invoicesGenerated =>
      context.read<AppViewModel>().invoiceHistory().length;
  int get toGenerate {
    final vm = context.read<AppViewModel>();
    final invoicedExpenseIds =
        vm.invoiceHistory().expand((inv) => inv.items.map((e) => e.id)).toSet();
    return vm
        .approvedExpenses()
        .where((e) => !invoicedExpenseIds.contains(e.id))
        .length;
  }

  Widget _metricCard(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
    );
  }

  Widget _cardAction(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        minVerticalPadding: 14,
        leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
