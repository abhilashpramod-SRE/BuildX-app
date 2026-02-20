import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../viewmodels/app_view_model.dart';

class ClientRegistrationScreen extends StatefulWidget {
  const ClientRegistrationScreen({super.key});

  @override
  State<ClientRegistrationScreen> createState() => _ClientRegistrationScreenState();
}

class _ClientRegistrationScreenState extends State<ClientRegistrationScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _projectInputController = TextEditingController();
  final List<String> _projects = <String>[];

  void _addProject() {
    final value = _projectInputController.text.trim();
    if (value.isEmpty) return;
    if (_projects.contains(value)) return;
    setState(() {
      _projects.add(value);
      _projectInputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Register Client')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Client Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Client Address'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Client Phone Number'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _projectInputController,
                  decoration: const InputDecoration(
                    labelText: 'Project (Optional)',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addProject,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_projects.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _projects
                  .map(
                    (p) => Chip(
                      label: Text(p),
                      onDeleted: () => setState(() => _projects.remove(p)),
                    ),
                  )
                  .toList(growable: false),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final client = await vm.registerClient(
                name: _nameController.text.trim(),
                address: _addressController.text.trim(),
                phone: _phoneController.text.trim(),
                projects: _projects,
              );
              if (!mounted) return;
              _nameController.clear();
              _addressController.clear();
              _phoneController.clear();
              _projectInputController.clear();
              setState(() => _projects.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Client created with ID: ${client.id}')),
              );
            },
            child: const Text('Submit'),
          ),
          const SizedBox(height: 20),
          Text('Clients', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (vm.repository.clients.isEmpty)
            const Text('Nothing to show.')
          else
            ...vm.repository.clients.map(
              (c) => Card(
                child: ListTile(
                  title: Text(c.name),
                  subtitle: Text(
                    '${c.phone}\n${c.address}\n${c.projects.isEmpty ? '-' : c.projects.join(', ')}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editClient(context, vm, c),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _editClient(BuildContext context, AppViewModel vm, Client client) async {
    final nameController = TextEditingController(text: client.name);
    final addressController = TextEditingController(text: client.address);
    final phoneController = TextEditingController(text: client.phone);
    final projectController = TextEditingController();
    final projects = List<String>.from(client.projects);

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Edit Client'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Client Name')),
                const SizedBox(height: 10),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Client Address')),
                const SizedBox(height: 10),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Client Phone Number')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: projectController,
                        decoration: const InputDecoration(labelText: 'Project (Optional)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final value = projectController.text.trim();
                        if (value.isEmpty || projects.contains(value)) return;
                        setStateDialog(() {
                          projects.add(value);
                          projectController.clear();
                        });
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (projects.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: projects
                        .map(
                          (p) => Chip(
                            label: Text(p),
                            onDeleted: () => setStateDialog(() => projects.remove(p)),
                          ),
                        )
                        .toList(growable: false),
                  ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                vm.updateClient(
                  clientId: client.id,
                  name: nameController.text.trim(),
                  address: addressController.text.trim(),
                  phone: phoneController.text.trim(),
                  projects: projects,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}
