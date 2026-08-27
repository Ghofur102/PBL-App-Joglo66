import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/employee_service.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

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
  bool _obscurePassword = true;
  Timer? _passwordTimer;
  int? _editId;
  String _selectedRole = 'worker';
  String _selectedStatus = 'active';

  List<Map<String, dynamic>> _availableFields = [];
  final List<int> _selectedFieldIds = [];
  bool _isLoadingFields = true;

  @override
  void initState() {
    super.initState();
    _loadFields();

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

      if (data['field_ids'] != null && data['field_ids'] is List) {
        _selectedFieldIds.clear();
        for (var item in (data['field_ids'] as List)) {
          final parsed = int.tryParse(item.toString());
          if (parsed != null) {
            _selectedFieldIds.add(parsed);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _passwordTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });

    _passwordTimer?.cancel();
    if (!_obscurePassword) {
      _passwordTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _obscurePassword = true;
          });
        }
      });
    }
  }

  Future<void> _loadFields() async {
    try {
      final rawData = await FieldService.fetchListField();
      if (mounted) {
        setState(() {
          _availableFields = rawData.map((e) => e as Map<String, dynamic>).toList();
          _isLoadingFields = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingFields = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isSystemUser && (_selectedRole == 'worker' || _selectedRole == 'treasurer') && _selectedFieldIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 lapangan untuk ditugaskan.'), backgroundColor: AppThemeConstants.warningAmber),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> payload = {
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
        if (_selectedRole == 'worker' || _selectedRole == 'treasurer') {
          payload['field_ids'] = _selectedFieldIds;
        }
      }

      if (_isEditMode && _editId != null) {
        await EmployeeService.updateEmployee(_editId!, payload);
      } else {
        await EmployeeService.createEmployee(payload);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        final cleanError = e.toString().replaceAll('FormatException: ', '').replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cleanError), backgroundColor: AppThemeConstants.errorRed));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Karyawan' : 'Tambah Karyawan', style: const TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppThemeConstants.textPrimary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppInputField(
              label: 'Nama Lengkap',
              controller: _nameController,
              icon: Icons.person_outline,
              validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            AppInputField(
              label: 'Jabatan',
              controller: _positionController,
              icon: Icons.badge_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? 'Jabatan wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            AppInputField(
              label: 'Gaji Pokok (Rp)',
              controller: _salaryController,
              keyboardType: TextInputType.number,
              prefixText: 'Rp ',
              validator: (v) => v == null || int.tryParse(v.trim()) == null ? 'Nominal gaji valid' : null,
            ),
            const SizedBox(height: 16),
            AppInputField(label: 'Nomor Telepon', controller: _phoneController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            AppInputField(label: 'Alamat Tempat Tinggal', controller: _addressController, icon: Icons.home_outlined, maxLines: 2),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: AppThemeConstants.bgLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppThemeConstants.borderGrey)),
              child: SwitchListTile(
                title: const Text('Beri Akses Login Sistem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Aktifkan jika karyawan adalah Admin Lapangan / Bendahara', style: TextStyle(fontSize: 12, color: AppThemeConstants.textSecondary)),
                value: _isSystemUser,
                activeColor: AppThemeConstants.accentBlue,
                onChanged: (b) => setState(() => _isSystemUser = b),
              ),
            ),
            if (_isSystemUser) ...[
              const SizedBox(height: 20),
              AppInputField(
                label: 'Email Akun Login',
                hint: 'contoh@joglo66.com',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => _isSystemUser && (v == null || v.trim().isEmpty || !v.contains('@')) ? 'Email login wajib diisi dan valid' : null,
              ),
              const SizedBox(height: 16),
              AppInputField(
                label: _isEditMode ? 'Password Baru (Opsional)' : 'Password Login',
                hint: 'Minimal 6 karakter',
                controller: _passwordController,
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppThemeConstants.textSecondary,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
                validator: (v) {
                  if (_isSystemUser && !_isEditMode && (v == null || v.length < 6)) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Role Akses Sistem', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppThemeConstants.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppThemeConstants.borderGrey)),
                ),
                items: const [
                  DropdownMenuItem(value: 'worker', child: Text('Worker (Admin Lapangan)')),
                  DropdownMenuItem(value: 'treasurer', child: Text('Treasurer (Bendahara)')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v ?? 'worker'),
              ),
              if (_selectedRole == 'worker' || _selectedRole == 'treasurer') ...[
                const SizedBox(height: 20),
                const Text('Penugasan Lapangan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppThemeConstants.textPrimary)),
                const SizedBox(height: 8),
                _isLoadingFields
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: _availableFields.map((field) {
                          final int fieldId = int.parse(field['id'].toString());
                          final bool isChecked = _selectedFieldIds.contains(fieldId);
                          return CheckboxListTile(
                            title: Text(field['name'] ?? 'Lapangan'),
                            subtitle: Text(field['category'] ?? '-'),
                            value: isChecked,
                            activeColor: AppThemeConstants.accentBlue,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedFieldIds.add(fieldId);
                                } else {
                                  _selectedFieldIds.remove(fieldId);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
              ],
            ],
            const SizedBox(height: 32),
            _isSaving
                ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
                : ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeConstants.accentBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Simpan Data Karyawan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}
