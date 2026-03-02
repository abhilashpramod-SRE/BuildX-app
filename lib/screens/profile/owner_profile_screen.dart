import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/company_profile.dart';
import '../../viewmodels/app_view_model.dart';
import '../approval/approval_screen.dart';
import '../client/client_registration_screen.dart';

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
    if (!_isEditing) return;

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

    context.read<AppViewModel>().updateOwnerProfile(profile);
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Owner profile updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final pending = vm.pendingExpenses().length;
    final approved = vm.approvedExpenses().length;
    final clients = vm.allClients().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Profile'),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _profileHeader(),
          const SizedBox(height: 12),
          _statStrip(pending: pending, approved: approved, clients: clients),
          const SizedBox(height: 12),
          _menuTile(Icons.person_outline, 'Personal Information'),
          _menuTile(
            Icons.people_outline,
            'Register / Manage Clients',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientRegistrationScreen()),
              );
            },
          ),
          _menuTile(
            Icons.approval_outlined,
            'Bills Pending Approval',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ApprovalScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Edit Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
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
          Text('Uploaded Logo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _logoPreview(),
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
            ),
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

  Widget _logoPreview() {
    final logoPath = _logoPathController.text.trim();
    final hasLogo = logoPath.isNotEmpty && File(logoPath).existsSync();

    if (!hasLogo) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.image_not_supported_outlined),
        title: Text('No logo uploaded.'),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(logoPath),
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.broken_image_outlined),
            title: Text('Unable to load uploaded logo.'),
          );
        },
      ),
    );
  }

  Widget _profileHeader() {
    final logoPath = _logoPathController.text.trim();
    final hasLogo = logoPath.isNotEmpty && File(logoPath).existsSync();

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          backgroundImage: hasLogo ? FileImage(File(logoPath)) : null,
          child: hasLogo ? null : const Icon(Icons.business, size: 36),
        ),
        const SizedBox(height: 10),
        Text(
          _nameController.text.trim().isEmpty ? 'Owner Name' : _nameController.text.trim(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          _stateNameController.text.trim().isEmpty
              ? 'Location not set'
              : _stateNameController.text.trim(),
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _statStrip({
    required int pending,
    required int approved,
    required int clients,
  }) {
    Widget statCell(String label, String value) {
      return Expanded(
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF42B994),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          statCell('Pending', '$pending'),
          Container(width: 1, height: 28, color: Colors.white38),
          statCell('Approved', '$approved'),
          Container(width: 1, height: 28, color: Colors.white38),
          statCell('Clients', '$clients'),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF42B994)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
