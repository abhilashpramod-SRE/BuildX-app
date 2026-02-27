import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../models/expense.dart';
import '../../viewmodels/app_view_model.dart';

class ConsolidatedBillScreen extends StatelessWidget {
  const ConsolidatedBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _ConsolidatedBillAppBar(),
      body: ConsolidatedBillContent(),
    );
  }
}

class _ConsolidatedBillAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ConsolidatedBillAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Consolidated Client Bill'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ConsolidatedBillContent extends StatefulWidget {
  const ConsolidatedBillContent({super.key});

  @override
  State<ConsolidatedBillContent> createState() => _ConsolidatedBillContentState();
}

class _ConsolidatedBillContentState extends State<ConsolidatedBillContent> {
  final _searchController = TextEditingController();
  Client? _selectedClient;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final clients = vm.searchClients(_searchController.text);
    final bills = _selectedClient == null
        ? <Expense>[]
        : vm.expensesByClient(_selectedClient!.id);
    final total = bills.fold<double>(0, (sum, b) => sum + b.amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search client',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                ...clients.map(
                  (c) => RadioListTile<Client>(
                    value: c,
                    groupValue: _selectedClient,
                    title: Text(c.name),
                    subtitle: Text('${c.phone} • ${c.address}'),
                    onChanged: (v) => setState(() => _selectedClient = v),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedClient != null) ...[
          Text(
            'Bills for ${_selectedClient!.name}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (bills.isEmpty)
            const Text('Nothing to show.')
          else
            ...bills.map(
              (bill) => Card(
                child: ListTile(
                  title: Text(bill.item),
                  subtitle: Text('Status: ${bill.status.name.toUpperCase()}'),
                  trailing: Text('₹${bill.amount.toStringAsFixed(2)}'),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              title: const Text('Total Amount Due'),
              subtitle: const Text('Final Consolidated Total'),
              trailing: Text(
                '₹${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: bills.isEmpty
                ? null
                : () async {
                    final invoice = vm.createInvoice(
                      client: _selectedClient!,
                      items: bills,
                      notes: 'Consolidated bill generated for all client bills.',
                    );
                    final file = await vm.createInvoicePdf(invoice);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Consolidated bill downloaded: ${file.path}'),
                      ),
                    );
                  },
            icon: const Icon(Icons.summarize),
            label: const Text('Generate Consolidated Bill PDF'),
          )
        ]
      ],
    );
  }
}
