import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/expense.dart';
import '../../viewmodels/app_view_model.dart';

class ExpenseUploadScreen extends StatefulWidget {
  const ExpenseUploadScreen({super.key});

  @override
  State<ExpenseUploadScreen> createState() => _ExpenseUploadScreenState();
}

class _ExpenseUploadScreenState extends State<ExpenseUploadScreen> {
  final _itemController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedProject = 'Tower A';
  String? _imagePath;

  final _projects = ['Tower A', 'Tower B', 'Road Expansion', 'Warehouse'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();
    final user = vm.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Expense Bill')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _itemController,
            decoration: const InputDecoration(labelText: 'Item / Description'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Date: ${_selectedDate.toLocal().toString().split(' ').first}'),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDate: _selectedDate,
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
          DropdownButtonFormField<String>(
            value: _selectedProject,
            items: _projects
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) => setState(() => _selectedProject = v!),
            decoration: const InputDecoration(labelText: 'Project'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: Text(_imagePath == null ? 'Upload Bill Image' : 'Image Selected'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Optional Notes / Remarks'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final expense = Expense(
                id: const Uuid().v4(),
                item: _itemController.text.trim(),
                amount: double.tryParse(_amountController.text) ?? 0,
                date: _selectedDate,
                project: _selectedProject,
                submitter: user,
                billImagePath: _imagePath,
                notes: _notesController.text.trim(),
              );

              await vm.submitExpense(expense);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Submitted for supervisor approval.')),
              );
              Navigator.pop(context);
            },
            child: const Text('Submit Expense'),
          ),
        ],
      ),
    );
  }
}
