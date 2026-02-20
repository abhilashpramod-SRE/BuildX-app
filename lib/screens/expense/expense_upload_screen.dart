import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/client.dart';
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
  final _projectController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _imagePath;
  Client? _selectedClient;
  String? _selectedProject;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _selectedDate,
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();
    final user = vm.currentUser!;
    final clients = vm.allClients();
    final projects = _selectedClient?.projects ?? <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Expense Bill')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (clients.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Nothing to show.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          const SizedBox(height: 8),
          DropdownButtonFormField<Client>(
            value: _selectedClient,
            items: clients
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: clients.isEmpty
                ? null
                : (v) {
                    setState(() {
                      _selectedClient = v;
                      final p = v?.projects ?? <String>[];
                      if (p.length == 1) {
                        _selectedProject = p.first;
                        _projectController.text = p.first;
                      } else {
                        _selectedProject = null;
                        _projectController.clear();
                      }
                    });
                  },
            decoration: const InputDecoration(labelText: 'Client *'),
          ),
          const SizedBox(height: 12),
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
          if (projects.length > 1)
            DropdownButtonFormField<String>(
              value: _selectedProject,
              items: projects
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedProject = v),
              decoration: const InputDecoration(
                labelText: 'Project (Optional)',
              ),
            )
          else
            TextField(
              controller: _projectController,
              readOnly: projects.length == 1,
              decoration: InputDecoration(
                labelText: 'Project (Optional)',
                helperText: projects.length == 1
                    ? 'Default project selected from client'
                    : 'Used for contractor-side filtering',
              ),
            ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _pickDate,
                ),
              ),
              child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
            ),
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
            onPressed: clients.isEmpty
                ? null
                : () async {
                    if (_selectedClient == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a client.')),
                      );
                      return;
                    }

                    final resolvedProject = projects.length > 1
                        ? _selectedProject
                        : (_projectController.text.trim().isEmpty
                            ? null
                            : _projectController.text.trim());

                    final expense = Expense(
                      id: const Uuid().v4(),
                      item: _itemController.text.trim(),
                      amount: double.tryParse(_amountController.text) ?? 0,
                      date: _selectedDate,
                      clientId: _selectedClient!.id,
                      clientName: _selectedClient!.name,
                      submitter: user,
                      project: resolvedProject,
                      billImagePath: _imagePath,
                      notes: _notesController.text.trim(),
                    );

                    await vm.submitExpense(expense);
                    if (!mounted) return;
                    setState(() {
                      _selectedClient = null;
                      _selectedProject = null;
                      _itemController.clear();
                      _amountController.clear();
                      _projectController.clear();
                      _notesController.clear();
                      _imagePath = null;
                      _selectedDate = DateTime.now();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Submitted for supervisor approval. Form reset for next entry.')),
                    );
                  },
            child: const Text('Submit Expense'),
          ),
        ],
      ),
    );
  }
}
