import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class OwnerFieldFormScreen extends StatefulWidget {
  final Map<String, dynamic>? editData;
  const OwnerFieldFormScreen({super.key, this.editData});

  @override
  State<OwnerFieldFormScreen> createState() => _OwnerFieldFormScreenState();
}

class _OwnerFieldFormScreenState extends State<OwnerFieldFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _minCancelDaysController = TextEditingController(text: '3');
  final _minRescheduleDaysController = TextEditingController(text: '3');
  final _maxRescheduleTimesController = TextEditingController(text: '1');

  String _selectedCategory = 'futsal';
  bool _isEditMode = false;
  bool _isSaving = false;

  final List<Map<String, String>> _categoryOptions = [
    {'value': 'futsal', 'label': 'Futsal'},
    {'value': 'mini soccer', 'label': 'Mini Soccer'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editData != null) {
      _isEditMode = true;
      final data = widget.editData!;
      _nameController.text = data['name']?.toString() ?? '';
      _descController.text = data['description']?.toString() ?? '';

      final String rawCat = (data['category']?.toString() ?? 'futsal').toLowerCase().trim();
      if (_categoryOptions.any((c) => c['value'] == rawCat)) {
        _selectedCategory = rawCat;
      } else {
        _selectedCategory = 'futsal';
      }

      if (data['min_cancel_days'] != null) {
        _minCancelDaysController.text = data['min_cancel_days'].toString();
      }
      if (data['min_reschedule_days'] != null) {
        _minRescheduleDaysController.text = data['min_reschedule_days'].toString();
      }
      if (data['max_reschedule_times'] != null) {
        _maxRescheduleTimesController.text = data['max_reschedule_times'].toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _minCancelDaysController.dispose();
    _minRescheduleDaysController.dispose();
    _maxRescheduleTimesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final int minCancel = int.tryParse(_minCancelDaysController.text.trim()) ?? 3;
      final int minResched = int.tryParse(_minRescheduleDaysController.text.trim()) ?? 3;
      final int maxResched = int.tryParse(_maxRescheduleTimesController.text.trim()) ?? 1;

      if (_isEditMode) {
        final int fieldId = widget.editData!['id'] is int
            ? widget.editData!['id'] as int
            : int.tryParse(widget.editData!['id'].toString()) ?? 0;

        await FieldService.updateOwnerField(
          id: fieldId,
          name: _nameController.text.trim(),
          category: _selectedCategory,
          description: _descController.text.trim(),
          minCancelDays: minCancel,
          minRescheduleDays: minResched,
          maxRescheduleTimes: maxResched,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data lapangan berhasil diperbarui!'),
              backgroundColor: AppThemeConstants.successGreen,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        await FieldService.createOwnerField(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          description: _descController.text.trim(),
          minCancelDays: minCancel,
          minRescheduleDays: minResched,
          maxRescheduleTimes: maxResched,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lapangan baru berhasil ditambahkan!'),
              backgroundColor: AppThemeConstants.successGreen,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', '').replaceAll('FormatException: ', ''),
            ),
            backgroundColor: AppThemeConstants.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildCategoryDropdown() {
    final OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
      borderSide: const BorderSide(color: AppThemeConstants.borderGrey),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Lapangan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppThemeConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: borderStyle,
            enabledBorder: borderStyle,
            focusedBorder: borderStyle.copyWith(
              borderSide: const BorderSide(color: AppThemeConstants.accentBlue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: _categoryOptions.map((opt) {
            return DropdownMenuItem<String>(
              value: opt['value'],
              child: Text(
                opt['label']!,
                style: const TextStyle(fontSize: 14, color: AppThemeConstants.textPrimary),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedCategory = val);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Lapangan' : 'Tambah Lapangan Baru',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppThemeConstants.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInputField(
                label: 'Nama Lapangan',
                hint: 'Contoh: Lapangan Futsal A',
                controller: _nameController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
                  if (v.trim().length > 50) return 'Nama maksimal 50 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              AppInputField(
                label: 'Deskripsi',
                hint: 'Ketik deskripsi fasilitas, ukuran, atau informasi lapangan...',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Divider(color: AppThemeConstants.borderGrey, thickness: 1),
              const SizedBox(height: 12),
              const Text(
                'Ketentuan Pembatalan & Jadwal Ulang',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppThemeConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppInputField(
                      label: 'Min. Hari Cancel',
                      hint: '3',
                      controller: _minCancelDaysController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final val = int.tryParse(v ?? '');
                        if (val == null || val < 0 || val > 30) return '0 - 30 hari';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppInputField(
                      label: 'Min. Hari Reschedule',
                      hint: '3',
                      controller: _minRescheduleDaysController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final val = int.tryParse(v ?? '');
                        if (val == null || val < 0 || val > 30) return '0 - 30 hari';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppInputField(
                label: 'Maksimal Reschedule (Kali)',
                hint: '1',
                controller: _maxRescheduleTimesController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final val = int.tryParse(v ?? '');
                  if (val == null || val < 1 || val > 10) return '1 - 10 kali';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isSaving
                  ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
                  : SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: _isEditMode ? 'Simpan Perubahan' : 'Simpan Data Lapangan',
                        onPressed: _save,
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
