import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _isEditing = true;

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
    _isEditing = profile.name.trim().isEmpty;
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

  Future<void> _pickLogo() async {
    if (!_isEditing) {
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _logoPathController.text = picked.path);
    }
  }

  void _reloadFromSavedProfile() {
    final profile = context.read<AppViewModel>().ownerProfile;
    _nameController.text = profile.name;
    _taglineController.text = profile.tagline;
    _addressController.text = profile.address;
    _gstinController.text = profile.gstinUin;
    _stateNameController.text = profile.stateName;
    _stateCodeController.text = profile.stateCode;
    _emailController.text = profile.emailId;
    _logoPathController.text = profile.logoPath ?? '';
  }

  void _saveProfile() {
    final vm = context.read<AppViewModel>();
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
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Owner profile updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Profile'),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Edit', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
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
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isEditing ? _pickLogo : null,
            icon: const Icon(Icons.image),
            label: const Text('Upload Company Logo'),
          ),
          const SizedBox(height: 16),
          if (_isEditing)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _reloadFromSavedProfile();
                      setState(() => _isEditing = false);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
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
        readOnly: !_isEditing,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
