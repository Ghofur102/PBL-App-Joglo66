import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/employee_service.dart';

class EmployeeFormOwnerScreen extends StatefulWidget {
  final Map<String, dynamic>? editData;
  const EmployeeFormOwnerScreen({super.key, this.editData});

  @override
  State<EmployeeFormOwnerScreen> createState() => _EmployeeFormOwnerScreenState();
}

class _EmployeeFormOwnerScreenState extends State<EmployeeFormOwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _positionController = TextEditingController();
  final _salaryController = TextEditingController();

  bool _isEditMode = false;
  bool _isSaving = false;
  bool _isSystemUser = false;
  int? _editId;
  String _selectedRole = 'worker';
  String _selectedStatus = 'active';

  @override
  void initState() {
    super.initState();
    if (widget.editData != null) {
      _isEditMode = true;
      final data = widget.editData!;
      _editId = int.tryParse(data['id']?.toString() ?? '0');
      _isSystemUser = data['is_system'] == true;
      _nameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['phone_number'] ?? '';
      _addressController.text = data['address'] ?? '';
      _positionController.text = data['position'] ?? '';
      _salaryController.text = data['base_salary']?.toString() ?? '';
      _selectedRole = data['role'] ?? 'worker';
      _selectedStatus = data['status'] ?? 'active';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final payload = {
        'name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'position': _positionController.text.trim(),
        'base_salary': int.tryParse(_salaryController.text) ?? 0,
        'status': _selectedStatus,
        'is_system': _isSystemUser,
        'role': _selectedRole,
      };

      if (_isSystemUser) {
        payload['email'] = _emailController.text.trim();
        if (_passwordController.text.isNotEmpty) {
          payload['password'] = _passwordController.text;
        }
      }

      if (_isEditMode && _editId != null) {
        await EmployeeService.updateEmployee(_editId!, payload);
      } else {
        await EmployeeService.createEmployee(payload);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Karyawan' : 'Tambah Karyawan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Beri Akses Sistem'),
              value: _isSystemUser,
              activeColor: AppThemeConstants.primaryBlue,
              onChanged: (b) => setState(() => _isSystemUser = b),
            ),
            AppInputField(label: 'Nama Lengkap', controller: _nameController),
            const SizedBox(height: 12),
            AppInputField(label: 'Jabatan', controller: _positionController),
            const SizedBox(height: 12),
            AppInputField(label: 'Gaji Pokok', controller: _salaryController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            if (_isSystemUser) ...[
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'worker', child: Text('Worker')),
                  DropdownMenuItem(value: 'treasurer', child: Text('Treasurer')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v ?? 'worker'),
                decoration: const InputDecoration(labelText: 'Role Sistem'),
              ),
            ],
            const SizedBox(height: 24),
            _isSaving ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _save, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
