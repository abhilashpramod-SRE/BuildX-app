import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/role.dart';
import '../../viewmodels/app_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identityController = TextEditingController(text: 'abhilash@buildx.com');
  final _passwordController = TextEditingController(text: 'password');
  UserRole _selectedRole = UserRole.contractor;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BuildX Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _identityController,
              decoration: const InputDecoration(
                labelText: 'Email or Phone Number',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              items: UserRole.values
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(role.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedRole = value!),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      await context.read<AppViewModel>().login(
                            _identityController.text,
                            _passwordController.text,
                            _selectedRole,
                          );
                      if (mounted) setState(() => _loading = false);
                    },
              child: Text(_loading ? 'Logging in...' : 'Login'),
            ),
          ],
        ),
      ),
    );
  }
}
