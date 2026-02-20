import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/company_profile.dart';
import '../../viewmodels/app_view_model.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _taglineController;
  late final TextEditingController _addressController;
  late final TextEditingController _gstinController;
  late final TextEditingController _stateNameController;
  late final TextEditingController _stateCodeController;
  late final TextEditingController _emailController;
  late final TextEditingController _logoPathController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppViewModel>().ownerProfile;
    _nameController = TextEditingController(text: profile.name);
    _taglineController = TextEditingController(text: profile.tagline);
    _addressController = TextEditingController(text: profile.address);
    _gstinController = TextEditingController(text: profile.gstinUin);
    _stateNameController = TextEditingController(text: profile.stateName);
    _stateCodeController = TextEditingController(text: profile.stateCode);
    _emailController = TextEditingController(text: profile.emailId);
    _logoPathController = TextEditingController(text: profile.logoPath ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _stateNameController.dispose();
    _stateCodeController.dispose();
    _emailController.dispose();
    _logoPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Owner Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_nameController, 'Company Name'),
          _field(_taglineController, 'Company Tagline / Legal Suffix'),
          _field(_addressController, 'Company Address', maxLines: 2),
          _field(_gstinController, 'GSTIN/UIN'),
          _field(_stateNameController, 'State Name'),
          _field(_stateCodeController, 'State Code'),
          _field(_emailController, 'Company Email Id'),
          _field(_logoPathController, 'Logo Path on Device (optional)'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final profile = CompanyProfile(
                name: _nameController.text.trim(),
                tagline: _taglineController.text.trim(),
                address: _addressController.text.trim(),
                gstinUin: _gstinController.text.trim(),
                stateName: _stateNameController.text.trim(),
                stateCode: _stateCodeController.text.trim(),
                emailId: _emailController.text.trim(),
                logoPath: _logoPathController.text.trim().isEmpty
                    ? null
                    : _logoPathController.text.trim(),
              );

              vm.updateOwnerProfile(profile);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Owner profile updated for new invoices.')),
              );
            },
            child: const Text('Save Profile'),
          )
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
