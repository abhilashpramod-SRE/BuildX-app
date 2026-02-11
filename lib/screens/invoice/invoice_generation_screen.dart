import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../models/expense.dart';
import '../../viewmodels/app_view_model.dart';

class InvoiceGenerationScreen extends StatefulWidget {
  const InvoiceGenerationScreen({super.key});

  @override
  State<InvoiceGenerationScreen> createState() => _InvoiceGenerationScreenState();
}

class _InvoiceGenerationScreenState extends State<InvoiceGenerationScreen> {
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();
  final Set<String> _selectedExpenseIds = <String>{};

  Client? _selectedClient;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final clients = vm.searchClients(_searchController.text);
    final approved = vm
        .approvedExpenses()
        .where((e) => _selectedClient == null || e.clientId == _selectedClient!.id)
        .toList(growable: false);

    final selectedItems = approved
        .where((e) => _selectedExpenseIds.contains(e.id))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Invoice')),
      body: ListView(
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
                      labelText: 'Search client by name or phone',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  if (clients.isNotEmpty)
                    ...clients.map(
                      (c) => RadioListTile<Client>(
                        value: c,
                        groupValue: _selectedClient,
                        title: Text(c.name),
                        subtitle: Text('${c.phone} • ${c.address}'),
                        onChanged: (v) => setState(() {
                          _selectedClient = v;
                          _selectedExpenseIds.clear();
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Optional Notes'),
          ),
          const SizedBox(height: 12),
          Text('Approved Items (Select one or more)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...approved.map((Expense e) {
            final selected = _selectedExpenseIds.contains(e.id);
            return Card(
              child: CheckboxListTile(
                value: selected,
                title: Text(e.item),
                subtitle: Text('₹${e.amount.toStringAsFixed(2)} • ${e.clientName}'),
                onChanged: (checked) {
                  setState(() {
                    if (checked ?? false) {
                      _selectedExpenseIds.add(e.id);
                    } else {
                      _selectedExpenseIds.remove(e.id);
                    }
                  });
                },
              ),
            );
          }),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('Selected Total'),
              trailing: Text(
                '₹${selectedItems.fold<double>(0, (s, e) => s + e.amount).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _selectedClient == null || selectedItems.isEmpty
                ? null
                : () async {
                    final invoice = vm.createInvoice(
                      client: _selectedClient!,
                      items: selectedItems,
                      notes: _notesController.text.trim(),
                    );

                    if (!mounted) return;
                    setState(() {
                      _selectedClient = null;
                      _selectedExpenseIds.clear();
                      _searchController.clear();
                      _notesController.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Invoice ${invoice.invoiceNumber} generated. Open Generated Bills to download.',
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.receipt_long),
            label: const Text('Generate Invoice'),
          ),
        ],
      ),
    );
  }
}
