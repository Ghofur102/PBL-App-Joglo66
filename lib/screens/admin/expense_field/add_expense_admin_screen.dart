import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/expense_service.dart';

class AddExpenseAdminScreen extends StatefulWidget {
  const AddExpenseAdminScreen({super.key});

  @override
  State<AddExpenseAdminScreen> createState() => _AddExpenseAdminScreenState();
}

class _AddExpenseAdminScreenState extends State<AddExpenseAdminScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _selectedCategory;

  bool _isSaving = false;
  bool _isLoadingCategories = true;
  bool _isCustomCategory = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nominalController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final fetched = await ExpenseService.getExpenses();
      if (mounted) {
        setState(() {
          _categories = List<String>.from(fetched.map((e) => e['category']?.toString() ?? 'Operasional').toSet());
          _isLoadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppThemeConstants.primaryBlue),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final categoryToSend = _isCustomCategory ? _customCategoryController.text.trim() : _selectedCategory;

    if (categoryToSend == null || categoryToSend.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kategori harus dipilih atau diisi manual"), backgroundColor: AppThemeConstants.warningAmber),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final success = await ExpenseService.addExpense(
        name: _nameController.text.trim(),
        category: categoryToSend,
        nominal: _nominalController.text.trim(),
        date: _dateController.text.trim(),
        note: _noteController.text.trim(),
        imagePath: _selectedImage?.path,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengeluaran berhasil disimpan"), backgroundColor: AppThemeConstants.successGreen),
        );
        context.pop(true);
      } else {
        throw const FormatException("Gagal menyimpan data ke server.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed),
        );
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary),
        ),
        title: const Text("Input Pengeluaran", style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInputField(
                      label: "Nama Pengeluaran",
                      hint: "Masukkan nama pengeluaran",
                      controller: _nameController,
                      icon: Icons.edit_note_rounded,
                      validator: (v) => v == null || v.trim().isEmpty ? "Nama pengeluaran wajib diisi" : null,
                    ),
                    const SizedBox(height: 20),
                    const Text("Kategori", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppThemeConstants.textPrimary)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _isCustomCategory ? "+ Tambah Kategori Baru" : _selectedCategory,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppThemeConstants.textSecondary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppThemeConstants.borderGrey)),
                      ),
                      items: [
                        ..._categories.map((item) => DropdownMenuItem(value: item, child: Text(item))),
                        const DropdownMenuItem(
                          value: "+ Tambah Kategori Baru",
                          child: Text("+ Tambah Kategori Baru", style: TextStyle(color: AppThemeConstants.accentBlue, fontWeight: FontWeight.bold)),
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value == "+ Tambah Kategori Baru") {
                            _isCustomCategory = true;
                            _selectedCategory = null;
                          } else {
                            _isCustomCategory = false;
                            _selectedCategory = value;
                          }
                        });
                      },
                    ),
                    if (_isCustomCategory) ...[
                      const SizedBox(height: 16),
                      AppInputField(
                        label: "Nama Kategori Baru",
                        hint: "Ketik kategori baru",
                        controller: _customCategoryController,
                        icon: Icons.add_box_outlined,
                        validator: (v) => _isCustomCategory && (v == null || v.trim().isEmpty) ? "Kategori baru tidak boleh kosong" : null,
                      ),
                    ],
                    const SizedBox(height: 20),
                    AppInputField(
                      label: "Nominal",
                      hint: "0",
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
                      prefixText: "Rp ",
                      validator: (v) => v == null || int.tryParse(v.trim()) == null ? "Nominal harus berupa angka" : null,
                    ),
                    const SizedBox(height: 20),
                    AppInputField(
                      label: "Tanggal",
                      hint: "Pilih tanggal",
                      controller: _dateController,
                      readOnly: true,
                      icon: Icons.calendar_today_outlined,
                      onTap: _pickDate,
                      validator: (v) => v == null || v.trim().isEmpty ? "Tanggal wajib diisi" : null,
                    ),
                    const SizedBox(height: 20),
                    const Text("Bukti Foto", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppThemeConstants.textPrimary)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: Text(_selectedImage != null ? "Ubah File Bukti" : "Upload File Bukti"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppThemeConstants.accentBlue,
                          side: const BorderSide(color: AppThemeConstants.borderGrey),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppThemeConstants.borderGrey),
                          image: DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    AppInputField(label: "Catatan Tambahan", hint: "Masukkan catatan...", controller: _noteController, maxLines: 2),
                    const SizedBox(height: 36),
                    _isSaving
                        ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
                        : SizedBox(width: double.infinity, child: AppButton(label: "Simpan Pengeluaran", onPressed: _saveExpense)),
                  ],
                ),
              ),
            ),
    );
  }
}
