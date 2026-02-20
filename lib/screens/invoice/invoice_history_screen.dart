import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/invoice.dart';
import '../../viewmodels/app_view_model.dart';

class InvoiceHistoryScreen extends StatelessWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _GeneratedBillsAppBar(),
      body: InvoiceHistoryContent(),
    );
  }
}

class _GeneratedBillsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _GeneratedBillsAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Generated Bills'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class InvoiceHistoryContent extends StatefulWidget {
  const InvoiceHistoryContent({super.key});

  @override
  State<InvoiceHistoryContent> createState() => _InvoiceHistoryContentState();
}

class _InvoiceHistoryContentState extends State<InvoiceHistoryContent> {
  final Set<String> _selectedInvoiceIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final invoices = vm.invoiceHistory();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (invoices.isEmpty)
          const Center(child: Text('Nothing to show.'))
        else ...[
          ...invoices.map(
            (inv) => Card(
              child: CheckboxListTile(
                value: _selectedInvoiceIds.contains(inv.id),
                onChanged: (checked) {
                  setState(() {
                    if (checked ?? false) {
                      _selectedInvoiceIds.add(inv.id);
                    } else {
                      _selectedInvoiceIds.remove(inv.id);
                    }
                  });
                },
                title: Text(inv.invoiceNumber),
                subtitle: Text(
                  '${inv.client.name} • ${DateFormat('dd MMM yyyy').format(inv.date)}\n₹${inv.totalAmount.toStringAsFixed(2)}',
                ),
                isThreeLine: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _selectedInvoiceIds.isEmpty
                ? null
                : () => _downloadSelected(context, vm, invoices),
            icon: const Icon(Icons.download),
            label: Text('Download Selected (${_selectedInvoiceIds.length})'),
          ),
        ],
      ],
    );
  }

  Future<void> _downloadSelected(
    BuildContext context,
    AppViewModel vm,
    List<Invoice> invoices,
  ) async {
    var downloaded = 0;
    for (final invoice in invoices) {
      if (_selectedInvoiceIds.contains(invoice.id)) {
        await vm.createInvoicePdf(invoice);
        downloaded++;
      }
    }

    if (!context.mounted) return;
    setState(() {
      _selectedInvoiceIds.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloaded $downloaded bill(s).')),
    );
  }
}
