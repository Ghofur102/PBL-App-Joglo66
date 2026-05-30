import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/components/input_field.dart';
import 'package:pbl_app_joglo66/services/expense_field.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Wrapper")));
  }

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController customCategoryController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  File? selectedImage;
  String? selectedCategory;
  
  bool _isSaving = false;
  bool _isLoadingCategories = true;
  bool _isCustomCategory = false;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    nameController.dispose();
    nominalController.dispose();
    dateController.dispose();
    noteController.dispose();
    customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final fetched = await ExpenseService.getCategories();
      if (mounted) {
        setState(() {
          categories = fetched;
          _isLoadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    
    final categoryToSend = _isCustomCategory ? customCategoryController.text.trim() : selectedCategory;

    if (categoryToSend == null || categoryToSend.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kategori harus dipilih atau diisi manual"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final success = await ExpenseService.addExpense(
        name: nameController.text.trim(),
        category: categoryToSend,
        nominal: nominalController.text.trim(),
        date: dateController.text.trim(),
        note: noteController.text.trim(),
        imagePath: selectedImage?.path,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengeluaran berhasil disimpan"), backgroundColor: Colors.green),
        );
        context.pop(true);
      } else {
        throw Exception("Gagal menyimpan data ke server.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
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
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
        ),
        title: const Text(
          "Input Pengeluaran",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputField(
                      label: "Nama Pengeluaran",
                      hint: "Masukkan nama pengeluaran",
                      controller: nameController,
                      icon: Icons.edit_note_rounded,
                      validator: (v) => v == null || v.trim().isEmpty ? "Nama pengeluaran wajib diisi" : null,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Kategori",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _isCustomCategory ? "+ Tambah Kategori Baru" : selectedCategory,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                      decoration: InputDecoration(
                        hintText: "Pilih kategori",
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF406093), width: 1.5)),
                      ),
                      items: [
                        ...categories.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                          );
                        }),
                        const DropdownMenuItem(
                          value: "+ Tambah Kategori Baru",
                          child: Text("+ Tambah Kategori Baru", style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold)),
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value == "+ Tambah Kategori Baru") {
                            _isCustomCategory = true;
                            selectedCategory = null;
                          } else {
                            _isCustomCategory = false;
                            selectedCategory = value;
                          }
                        });
                      },
                    ),
                    if (_isCustomCategory) ...[
                      const SizedBox(height: 16),
                      InputField(
                        label: "Nama Kategori Baru",
                        hint: "Ketik kategori baru (Misal: Perbaikan AC)",
                        controller: customCategoryController,
                        icon: Icons.add_box_outlined,
                        validator: (v) => _isCustomCategory && (v == null || v.trim().isEmpty) ? "Kategori baru tidak boleh kosong" : null,
                      ),
                    ],
                    const SizedBox(height: 20),
                    InputField(
                      label: "Nominal",
                      hint: "0",
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      prefixText: "Rp ",
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Nominal wajib diisi";
                        if (int.tryParse(v.trim()) == null) return "Nominal harus angka";
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      label: "Tanggal",
                      hint: "Pilih tanggal pengeluaran",
                      controller: dateController,
                      readOnly: true,
                      icon: Icons.calendar_today_outlined,
                      onTap: pickDate,
                      validator: (v) => v == null || v.trim().isEmpty ? "Tanggal wajib diisi" : null,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Bukti Foto",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.cloud_upload_outlined, size: 20),
                        label: Text(selectedImage != null ? "Ubah File Bukti" : "Upload File Bukti"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF406093),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    if (selectedImage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          image: DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    InputField(
                      label: "Catatan Tambahan",
                      hint: "Masukkan catatan jika ada...",
                      controller: noteController,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : saveExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF406093),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text("Simpan Pengeluaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}