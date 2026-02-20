import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../models/expense.dart';
import '../../viewmodels/app_view_model.dart';

class SubmittedBillsScreen extends StatelessWidget {
  const SubmittedBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _SubmittedBillsAppBar(),
      body: SubmittedBillsContent(),
    );
  }
}

class _SubmittedBillsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SubmittedBillsAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('My Submitted Bills'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SubmittedBillsContent extends StatefulWidget {
  const SubmittedBillsContent({super.key});

  @override
  State<SubmittedBillsContent> createState() => _SubmittedBillsContentState();
}

class _SubmittedBillsContentState extends State<SubmittedBillsContent> {
  String? _clientId;
  ExpenseStatus? _status;
  String? _project;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final clients = vm.allClients();
    final projects = vm.myProjects();
    final expenses = vm.myExpenses(clientId: _clientId, status: _status, project: _project);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Filters',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _clientId = null;
                  _status = null;
                  _project = null;
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear'),
            ),
          ],
        ),
        DropdownButtonFormField<String?>(
          value: _clientId,
          decoration: const InputDecoration(labelText: 'Filter by Client'),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('All Clients')),
            ...clients.map(
              (Client c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
            ),
          ],
          onChanged: (v) => setState(() => _clientId = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ExpenseStatus?>(
          value: _status,
          decoration: const InputDecoration(labelText: 'Filter by Status'),
          items: [
            const DropdownMenuItem<ExpenseStatus?>(value: null, child: Text('All Statuses')),
            ...ExpenseStatus.values.map(
              (s) => DropdownMenuItem<ExpenseStatus?>(value: s, child: Text(s.name.toUpperCase())),
            ),
          ],
          onChanged: (v) => setState(() => _status = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          value: _project,
          decoration: const InputDecoration(labelText: 'Filter by Project'),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('All Projects')),
            ...projects.map(
              (p) => DropdownMenuItem<String?>(value: p, child: Text(p)),
            ),
          ],
          onChanged: (v) => setState(() => _project = v),
        ),
        const SizedBox(height: 16),
        Text(
          'Submitted Bills (${expenses.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (expenses.isEmpty)
          const Center(child: Text('Nothing to show.'))
        else
          ...expenses.map(
            (e) => Card(
              child: ListTile(
                title: Text('${e.item} • ₹${e.amount.toStringAsFixed(2)}'),
                subtitle: Text(
                  '${e.clientName} • ${DateFormat('dd MMM yyyy').format(e.date)}\nProject: ${e.project ?? '-'}',
                ),
                isThreeLine: true,
                trailing: Chip(label: Text(e.status.name.toUpperCase())),
              ),
            ),
          ),
      ],
    );
  }
}
