import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/client.dart';
import '../../viewmodels/app_view_model.dart';

class ApprovedBillsScreen extends StatelessWidget {
  const ApprovedBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _ApprovedBillsAppBar(),
      body: ApprovedBillsContent(),
    );
  }
}

class _ApprovedBillsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ApprovedBillsAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Approved Bills'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ApprovedBillsContent extends StatefulWidget {
  const ApprovedBillsContent({super.key});

  @override
  State<ApprovedBillsContent> createState() => _ApprovedBillsContentState();
}

class _ApprovedBillsContentState extends State<ApprovedBillsContent> {
  String? _clientId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final clients = vm.allClients();
    final bills = vm.approvedExpensesByClient(_clientId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String?>(
          isExpanded: true,
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
        Text('Approved Bills (${bills.length})',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (bills.isEmpty)
          const Center(child: Text('Nothing to show.'))
        else
          ...bills.map(
            (e) => Card(
              child: ListTile(
                title: Text('${e.item} • ₹${e.amount.toStringAsFixed(2)}'),
                subtitle: Text('${e.clientName} • ${DateFormat('dd MMM yyyy').format(e.date)}'),
                trailing: const Icon(Icons.check_circle, color: BuildXTheme.successGreen),
              ),
            ),
          ),
      ],
    );
  }
}
