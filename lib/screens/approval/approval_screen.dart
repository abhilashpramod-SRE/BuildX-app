import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../viewmodels/app_view_model.dart';

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final pending = vm.pendingExpenses();

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Approvals')),
      body: ListView.builder(
        itemCount: pending.length,
        itemBuilder: (context, index) {
          final expense = pending[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${expense.submitter.name} • ${expense.project}',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text('${expense.item} • ₹${expense.amount.toStringAsFixed(2)}'),
                  Text(DateFormat('dd MMM yyyy').format(expense.date)),
                  if (expense.billImagePath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Bill Image: ${expense.billImagePath}'),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => vm.approveExpense(expense),
                          child: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _reject(context, vm, expense),
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _reject(
      BuildContext context, AppViewModel vm, Expense expense) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rejection Reason'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await vm.rejectExpense(expense, controller.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Reject'),
          )
        ],
      ),
    );
  }
}
