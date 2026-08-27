import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';

class OwnerFieldFormScreen extends StatefulWidget {
  final Map<String, dynamic>? editData;
  const OwnerFieldFormScreen({super.key, this.editData});

  @override
  State<OwnerFieldFormScreen> createState() => _OwnerFieldFormScreenState();
}

class _OwnerFieldFormScreenState extends State<OwnerFieldFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descController = TextEditingController();

  bool _isEditMode = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editData != null) {
      _isEditMode = true;
      final data = widget.editData!;
      _nameController.text = data['name'] ?? '';
      _categoryController.text = data['category'] ?? '';
      _descController.text = data['description'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Lapangan' : 'Tambah Lapangan Baru', style: const TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppThemeConstants.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppInputField(
                label: 'Nama Lapangan',
                hint: 'Contoh: Lapangan Futsal A',
                controller: _nameController,
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              AppInputField(
                label: 'Kategori Lapangan',
                hint: 'Contoh: Futsal, Badminton',
                controller: _categoryController,
                validator: (v) => v == null || v.trim().isEmpty ? 'Kategori wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              AppInputField(
                label: 'Deskripsi',
                hint: 'Ketik deskripsi...',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: AppButton(label: 'Simpan Data Lapangan', onPressed: _save),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
