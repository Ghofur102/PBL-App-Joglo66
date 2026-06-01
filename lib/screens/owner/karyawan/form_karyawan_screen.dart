import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/services/karyawan_service.dart';
import 'package:pbl_app_joglo66/components/input_field.dart';

class FormKaryawanScreen extends StatefulWidget {
  final Map<String, dynamic>? editData;
  const FormKaryawanScreen({super.key, this.editData});

  @override
  State<FormKaryawanScreen> createState() => _FormKaryawanScreenState();
}

class _FormKaryawanScreenState extends State<FormKaryawanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();

  bool _isEditMode = false;
  bool _isSaving = false;
  int? _editId;
  String _selectedRole = 'worker';

  final List<String> _roles = ['admin', 'worker', 'owner', 'treasure'];

  @override
  void initState() {
    super.initState();
    final data = widget.editData;
    if (data != null) {
      _isEditMode = true;
      _editId = int.tryParse(data['id']?.toString() ?? '0');
      _namaController.text = data['name']?.toString() ?? '';
      _emailController.text = data['email']?.toString() ?? '';
      _selectedRole = data['role']?.toString() ?? 'worker';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final data = <String, dynamic>{
        'name': _namaController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
      };

      final password = _passwordController.text.trim();
      if (password.isNotEmpty) {
        data['password'] = password;
        data['password_confirmation'] = _konfirmasiPasswordController.text.trim();
      }

      if (_isEditMode && _editId != null) {
        await KaryawanService.updateKaryawan(_editId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Karyawan berhasil diperbarui.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (password.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password wajib diisi untuk karyawan baru.'), backgroundColor: Colors.red),
            );
          }
          setState(() => _isSaving = false);
          return;
        }
        await KaryawanService.createKaryawan(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Karyawan berhasil ditambahkan.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF406093), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Karyawan' : 'Tambah Karyawan',
          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputField(
                label: 'Nama',
                hint: 'Masukkan nama karyawan',
                controller: _namaController,
                icon: Icons.person_outline,
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              InputField(
                label: 'Email',
                hint: 'Masukkan email karyawan',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                  if (!v.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
                decoration: InputDecoration(
                  hintText: _isEditMode ? 'Kosongkan jika tidak diubah' : 'Masukkan password',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF406093), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (v) {
                  if (!_isEditMode && (v == null || v.trim().isEmpty)) return 'Password wajib diisi';
                  if (v != null && v.isNotEmpty && v.length < 6) return 'Password minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Konfirmasi Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _konfirmasiPasswordController,
                obscureText: true,
                style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
                decoration: InputDecoration(
                  hintText: 'Ulangi password',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF406093), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (v) {
                  if (!_isEditMode && (v == null || v.trim().isEmpty)) return 'Konfirmasi password wajib diisi';
                  if (v != _passwordController.text) return 'Password tidak cocok';
                  if (v != null && v.isNotEmpty && v != _passwordController.text) return 'Password tidak cocok';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Role',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: _dropdownDecoration('Pilih role'),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                items: _roles.map((r) {
                  IconData icon;
                  switch (r) {
                    case 'admin':
                      icon = Icons.admin_panel_settings;
                      break;
                    case 'owner':
                      icon = Icons.star;
                      break;
                    case 'treasure':
                      icon = Icons.account_balance_wallet;
                      break;
                    default:
                      icon = Icons.person;
                  }
                  return DropdownMenuItem(
                    value: r,
                    child: Row(
                      children: [
                        Icon(icon, size: 18, color: const Color(0xFF406093)),
                        const SizedBox(width: 10),
                        Text(r[0].toUpperCase() + r.substring(1), style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedRole = v);
                },
                validator: (v) => v == null ? 'Pilih role' : null,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF406093),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          _isEditMode ? 'Simpan Perubahan' : 'Simpan',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
