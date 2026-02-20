import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/expense.dart';
import '../../viewmodels/app_view_model.dart';

class ExpenseListWidget extends StatelessWidget {
  const ExpenseListWidget({
    super.key,
    required this.title,
    this.mineOnly = false,
    this.approvedOnly = false,
  });

  final String title;
  final bool mineOnly;
  final bool approvedOnly;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    List<Expense> expenses;

    if (mineOnly) {
      expenses = vm.myExpenses();
    } else if (approvedOnly) {
      expenses = vm.approvedExpenses();
    } else {
      expenses = vm.pendingExpenses();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (expenses.isEmpty)
              const Text('Nothing to show.')
            else
              ...expenses.map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${e.item} • ₹${e.amount.toStringAsFixed(2)}'),
                  subtitle:
                      Text('${e.clientName} • ${DateFormat('dd MMM yyyy').format(e.date)}'),
                  trailing: _statusChip(e.status),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(ExpenseStatus status) {
    final color = switch (status) {
      ExpenseStatus.pending => BuildXTheme.accentOrange,
      ExpenseStatus.approved => BuildXTheme.successGreen,
      ExpenseStatus.rejected => Colors.red,
    };
    return Chip(
      label: Text(status.name.toUpperCase()),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
