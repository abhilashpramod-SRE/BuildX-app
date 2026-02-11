import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    final destinations = user.role == UserRole.contractor
        ? const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Submitted Bills'),
          ]
        : const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.approval), label: 'Approvals'),
            NavigationDestination(icon: Icon(Icons.verified), label: 'Approved Bills'),
            NavigationDestination(icon: Icon(Icons.download), label: 'Generated Bills'),
            NavigationDestination(icon: Icon(Icons.summarize), label: 'Consolidated'),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.name}'),
        actions: [
          Row(
            children: [
              const Text('Offline', style: TextStyle(color: Colors.white)),
              Switch(
                value: vm.isOnline,
                onChanged: vm.setOnline,
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
      body: _bodyForRole(user.role),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (idx) => setState(() => _index = idx),
        destinations: destinations,
      ),
    );
  }

  Widget _bodyForRole(UserRole role) {
    if (role == UserRole.contractor) {
      if (_index == 1) return const SubmittedBillsContent();
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

    if (_index == 1) return const ApprovalContent();
    if (_index == 2) return const ApprovedBillsContent();
    if (_index == 3) return const InvoiceHistoryContent();
    if (_index == 4) return const ConsolidatedBillContent();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _cardAction('Bills Pending Approval', Icons.approval, () {
          setState(() => _index = 1);
        }),
        _cardAction('Approved Bills', Icons.verified, () {
          setState(() => _index = 2);
        }),
        _cardAction('Register / Manage Clients', Icons.people, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClientRegistrationScreen()),
          );
        }),
        _cardAction('Generate Invoice', Icons.receipt_long, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InvoiceGenerationScreen()),
          );
        }),
        _cardAction('Generated Bills', Icons.download, () {
          setState(() => _index = 3);
        }),
        _cardAction('Consolidated Client Bill', Icons.summarize, () {
          setState(() => _index = 4);
        }),
        const SizedBox(height: 12),
        const ExpenseListWidget(title: 'Approved Bills', approvedOnly: true),
      ],
    );
  }

  Widget _cardAction(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        minVerticalPadding: 14,
        leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
