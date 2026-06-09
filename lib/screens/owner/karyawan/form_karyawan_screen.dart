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
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _positionController = TextEditingController();
  final _baseSalaryController = TextEditingController();

  bool _isEditMode = false;
  bool _isSaving = false;
  bool _isSystemUser = false; // State pengontrol tipe karyawan
  int? _editId;
  String _selectedRole = 'worker';
  String _selectedStatus = 'active';

  final List<String> _roles = ['worker', 'treasurer'];
  final List<String> _statusOptions = ['active', 'inactive'];

  @override
  void initState() {
    super.initState();
    final data = widget.editData;
    if (data != null) {
      _isEditMode = true;
      _editId = int.tryParse(data['id']?.toString() ?? '0');
      _isSystemUser = data['is_system'] == true; // Membaca flag dari backend
      _namaController.text = data['name']?.toString() ?? '';
      _emailController.text = data['email']?.toString() ?? '';
      _phoneController.text = data['phone_number']?.toString() ?? '';
      _addressController.text = data['address']?.toString() ?? '';
      _positionController.text = data['position']?.toString() ?? '';
      _baseSalaryController.text = data['base_salary']?.toString() ?? '';
      _selectedRole = data['role']?.toString() ?? 'worker';
      _selectedStatus = data['status']?.toString() ?? 'active';
      if (!_roles.contains(_selectedRole)) _selectedRole = 'worker';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _positionController.dispose();
    _baseSalaryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final data = <String, dynamic>{
        'is_system': _isSystemUser,
        'name': _namaController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'position': _positionController.text.trim(),
        'base_salary': int.tryParse(_baseSalaryController.text.trim()) ?? 0,
        'status': _selectedStatus,
      };

      // Hanya kirim kredensial jika tipe karyawan adalah Sistem
      if (_isSystemUser) {
        data['email'] = _emailController.text.trim();
        data['role'] = _selectedRole;
        final password = _passwordController.text.trim();

        if (password.isNotEmpty) {
          data['password'] = password;
          data['password_confirmation'] = _konfirmasiPasswordController.text.trim();
        } else if (!_isEditMode || (_isEditMode && widget.editData?['is_system'] == false)) {
          // Jika bikin baru atau transisi dari Non-Sistem ke Sistem, password wajib
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password wajib diisi untuk akun sistem.'), backgroundColor: Colors.red));
          setState(() => _isSaving = false);
          return;
        }
      }

      if (_isEditMode && _editId != null) {
        await KaryawanService.updateKaryawan(_editId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Karyawan berhasil diperbarui.'), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      } else {
        data['join_date'] = DateTime.now().toIso8601String().split('T').first;
        await KaryawanService.createKaryawan(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Karyawan berhasil ditambahkan.'), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF406093), width: 1.5)),
    );
  }

  // Widget informatif pemisah tipe karyawan
  Widget _buildSystemUserToggle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: _isSystemUser ? Colors.blue.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        border: Border.all(color: _isSystemUser ? Colors.blue.shade200 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: const Text('Beri Akses Sistem (Karyawan Sistem)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
          _isSystemUser
              ? 'Karyawan ini akan dibuatkan akun untuk login ke aplikasi.'
              : 'Karyawan biasa. Hanya dicatat untuk keperluan penggajian.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        value: _isSystemUser,
        activeColor: const Color(0xFF406093),
        onChanged: (bool value) {
          setState(() {
            _isSystemUser = value;
          });
        },
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
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)), onPressed: () => Navigator.pop(context)),
        title: Text(_isEditMode ? 'Edit Karyawan' : 'Tambah Karyawan', style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: const Color(0xFFE2E8F0), height: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSystemUserToggle(),

              const Text('Profil Pekerjaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              InputField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama karyawan',
                controller: _namaController,
                icon: Icons.person_outline,
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      label: 'Posisi / Jabatan',
                      hint: 'Misal: Staff',
                      controller: _positionController,
                      icon: Icons.work_outline,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Posisi wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: _dropdownDecoration('Pilih status'),
                          items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s == 'active' ? 'Aktif' : 'Nonaktif'))).toList(),
                          onChanged: (v) => setState(() => _selectedStatus = v ?? 'active'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InputField(
                label: 'Gaji Pokok (Base Salary)',
                hint: '0',
                controller: _baseSalaryController,
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.trim().isEmpty ? 'Gaji pokok wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              InputField(
                label: 'Nomor Telepon',
                hint: '0812xxxx',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              const Text('Alamat Domisili', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: _dropdownDecoration('Masukkan alamat lengkap'),
              ),

              // Bagian Akun akan merender dan memvalidasi jika Switch aktif
              if (_isSystemUser) ...[
                const Divider(height: 48, thickness: 1, color: Color(0xFFE2E8F0)),
                const Text('Kredensial Akun Sistem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 16),
                InputField(
                  label: 'Email Login',
                  hint: 'Masukkan email',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Hak Akses (Role)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: _dropdownDecoration('Pilih role'),
                  items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r[0].toUpperCase() + r.substring(1)))).toList(),
                  onChanged: (v) => setState(() => _selectedRole = v ?? 'worker'),
                ),
                const SizedBox(height: 16),
                const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _dropdownDecoration(_isEditMode && widget.editData?['is_system'] == true ? 'Kosongkan jika tidak diubah' : 'Masukkan password').copyWith(prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF64748B))),
                  validator: (v) {
                    bool isNewAccount = !_isEditMode || (_isEditMode && widget.editData?['is_system'] == false);
                    if (isNewAccount && (v == null || v.trim().isEmpty)) return 'Password wajib diisi';
                    if (v != null && v.isNotEmpty && v.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Konfirmasi Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _konfirmasiPasswordController,
                  obscureText: true,
                  decoration: _dropdownDecoration('Ulangi password').copyWith(prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF64748B))),
                  validator: (v) {
                    bool isNewAccount = !_isEditMode || (_isEditMode && widget.editData?['is_system'] == false);
                    if (isNewAccount && (v == null || v.trim().isEmpty)) return 'Konfirmasi password wajib diisi';
                    if (v != _passwordController.text) return 'Password tidak cocok';
                    return null;
                  },
                ),
              ],

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
                      : Text(_isEditMode ? 'Simpan Perubahan' : 'Simpan Data', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
