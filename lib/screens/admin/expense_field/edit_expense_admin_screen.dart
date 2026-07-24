import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/expense_service.dart';

class EditExpenseAdminScreen extends StatefulWidget {
  final Map<String, dynamic> expenseData;

  const EditExpenseAdminScreen({super.key, required this.expenseData});

  @override
  State<EditExpenseAdminScreen> createState() => _EditExpenseAdminScreenState();
}

class _EditExpenseAdminScreenState extends State<EditExpenseAdminScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;
  late TextEditingController _dateController;
  late TextEditingController _noteController;

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _selectedCategory;
  bool _isSaving = false;
  int _calculatedTotal = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expenseData['name'] ?? widget.expenseData['title'] ?? '');
    _quantityController = TextEditingController(text: widget.expenseData['quantity']?.toString() ?? '1');
    _unitPriceController = TextEditingController(text: widget.expenseData['unit_price']?.toString() ?? '0');
    _dateController = TextEditingController(text: widget.expenseData['date'] ?? widget.expenseData['expense_date'] ?? '');
    _noteController = TextEditingController(text: widget.expenseData['note'] == '-' ? '' : (widget.expenseData['note'] ?? ''));
    _selectedCategory = widget.expenseData['category'] ?? 'Operasional';

    _updateTotal();
    _quantityController.addListener(_updateTotal);
    _unitPriceController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    final int qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    final int price = int.tryParse(_unitPriceController.text.trim()) ?? 0;
    setState(() {
      _calculatedTotal = qty * price;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
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

  Future<void> _updateExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final int expenseId = int.tryParse(widget.expenseData['id']?.toString() ?? '0') ?? 0;
    if (expenseId == 0) return;

    setState(() => _isSaving = true);

    try {
      final success = await ExpenseService.updateExpense(
        id: expenseId,
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        quantity: int.parse(_quantityController.text.trim()),
        unitPrice: int.parse(_unitPriceController.text.trim()),
        date: _dateController.text.trim(),
        note: _noteController.text.trim(),
        imagePath: _selectedImage?.path,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data pengeluaran berhasil diperbarui"), backgroundColor: AppThemeConstants.successGreen),
        );
        context.pop(true);
      } else {
        throw const FormatException("Gagal memperbarui data.");
      }
    } catch (e) {
      if (mounted) {
        final cleanError = e.toString().replaceAll('FormatException: ', '').replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cleanError), backgroundColor: AppThemeConstants.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatPrice(int price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    final String? existingImage = widget.expenseData['image'] ?? widget.expenseData['proof_photo'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary),
        ),
        title: const Text("Edit Pengeluaran", style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInputField(
                label: "Nama Pengeluaran",
                controller: _nameController,
                icon: Icons.edit_note_rounded,
                validator: (v) => v == null || v.trim().isEmpty ? "Nama pengeluaran wajib diisi" : null,
              ),
              const SizedBox(height: 20),
              AppInputField(
                label: "Kategori",
                controller: TextEditingController(text: _selectedCategory),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppInputField(
                      label: "Kuantitas (Qty)",
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || int.tryParse(v.trim()) == null || int.parse(v.trim()) <= 0 ? "Qty valid" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppInputField(
                      label: "Harga Satuan (Rp)",
                      controller: _unitPriceController,
                      keyboardType: TextInputType.number,
                      prefixText: "Rp ",
                      validator: (v) => v == null || int.tryParse(v.trim()) == null ? "Harga valid" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppThemeConstants.lightBlue, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Kalkulasi:", style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
                    Text(_formatPrice(_calculatedTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppThemeConstants.accentBlue)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppInputField(
                label: "Tanggal",
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
                  label: Text(_selectedImage != null ? "Ubah Foto Baru" : "Ganti File Bukti"),
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
              ] else if (existingImage != null && existingImage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppThemeConstants.borderGrey),
                    image: DecorationImage(image: NetworkImage(existingImage), fit: BoxFit.cover),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              AppInputField(label: "Catatan Tambahan", controller: _noteController, maxLines: 2),
              const SizedBox(height: 36),
              _isSaving
                  ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
                  : SizedBox(width: double.infinity, child: AppButton(label: "Simpan Perubahan", onPressed: _updateExpense)),
            ],
          ),
        ),
      ),
    );
  }
}
