import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/role.dart';
import '../../viewmodels/app_view_model.dart';
import '../approval/approval_screen.dart';
import '../client/client_registration_screen.dart';
import '../expense/expense_upload_screen.dart';
import '../invoice/invoice_generation_screen.dart';
import '../widgets/expense_list_widget.dart';

class RoleDashboardScreen extends StatelessWidget {
  const RoleDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final user = vm.currentUser!;

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user.role == UserRole.contractor || user.role == UserRole.engineer) ...[
            _actionCard(
              context,
              'Upload Expense',
              Icons.upload_file,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpenseUploadScreen()),
              ),
            ),
            const SizedBox(height: 12),
            const ExpenseListWidget(title: 'My Submitted Bills', mineOnly: true),
          ],
          if (user.role == UserRole.supervisor) ...[
            _actionCard(
              context,
              'Bills Pending Approval',
              Icons.approval,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ApprovalScreen()),
              ),
            ),
            _actionCard(
              context,
              'Register / Manage Clients',
              Icons.people,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ClientRegistrationScreen()),
              ),
            ),
            _actionCard(
              context,
              'Generate Invoice',
              Icons.receipt_long,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const InvoiceGenerationScreen()),
              ),
            ),
            const SizedBox(height: 12),
            const ExpenseListWidget(title: 'Approved Bills', approvedOnly: true),
          ],
        ],
      ),
    );
  }

  Widget _actionCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
