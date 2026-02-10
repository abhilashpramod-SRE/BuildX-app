import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final client = await vm.registerClient(
                name: _nameController.text.trim(),
                address: _addressController.text.trim(),
                phone: _phoneController.text.trim(),
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Client created with ID: ${client.id}')),
              );
            },
            child: const Text('Submit'),
          ),
          const SizedBox(height: 20),
          Text('Clients', style: Theme.of(context).textTheme.titleMedium),
          ...vm.repository.clients.map(
            (c) => ListTile(
              title: Text(c.name),
              subtitle: Text('${c.phone}\n${c.address}'),
              trailing: Text(c.id),
            ),
          ),
        ],
      ),
    );
  }
}
