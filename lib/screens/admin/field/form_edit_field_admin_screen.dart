import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/core/utils/currency_util.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class FormEditFieldAdminScreen extends StatefulWidget {
  final String fieldId;

  const FormEditFieldAdminScreen({super.key, required this.fieldId});

  @override
  State<FormEditFieldAdminScreen> createState() => _FormEditFieldAdminScreenState();
}

class _FormEditFieldAdminScreenState extends State<FormEditFieldAdminScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  File? _selectedImage;
  String? _existingImageUrl;
  List<Map<String, dynamic>> _pricingRules = [];

  final List<String> _daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final data = await FieldService.fetchFieldDetail(widget.fieldId);
      if (mounted) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _descController.text = data['description'] ?? '';
          _categoryController.text = data['category'] ?? '';

          final String rawImageUrl = data['image_url'] ?? '';
          if (rawImageUrl.isNotEmpty) {
            if (rawImageUrl.startsWith('http')) {
              _existingImageUrl = rawImageUrl;
            } else {
              final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
              _existingImageUrl = baseUrl.endsWith('/') ? '$baseUrl$rawImageUrl' : '$baseUrl/$rawImageUrl';
            }
          }

          if (data['field_prices'] != null) {
            _pricingRules = List<Map<String, dynamic>>.from(data['field_prices'].map((item) {
              String st = item['start_time'] ?? '08:00';
              String et = item['end_time'] ?? '22:00';
              if (st.length > 5) st = st.substring(0, 5);
              if (et.length > 5) et = et.substring(0, 5);

              return {
                'day_type': item['day_type'],
                'start_time': st,
                'end_time': et,
                'price': item['price'],
              };
            }));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: AppThemeConstants.errorRed));
        context.pop();
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null && mounted) {
        setState(() { _selectedImage = File(image.path); });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka galeri.'), backgroundColor: AppThemeConstants.errorRed));
    }
  }

  Future<void> _saveData() async {
    if (_nameController.text.isEmpty || _pricingRules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama lapangan dan minimal 1 jadwal harga wajib diisi!'), backgroundColor: AppThemeConstants.errorRed));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FieldService.updateField(
        id: int.parse(widget.fieldId),
        name: _nameController.text,
        description: _descController.text,
        category: _categoryController.text,
        pricingRules: _pricingRules,
        imagePath: _selectedImage?.path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data lapangan berhasil diperbarui!'), backgroundColor: AppThemeConstants.successGreen));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppThemeConstants.errorRed));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _removeRule(int index) {
    setState(() { _pricingRules.removeAt(index); });
  }

  void _showAddRuleDialog() {
    String selectedDay = 'monday';
    final priceCtrl = TextEditingController();
    final startCtrl = TextEditingController(text: '08:00');
    final endCtrl = TextEditingController(text: '12:00');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Jadwal Harga'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  items: _daysOfWeek.map((day) => DropdownMenuItem(value: day, child: Text(day.toUpperCase()))).toList(),
                  onChanged: (val) => setDialogState(() => selectedDay = val!),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: AppInputField(label: 'Mulai', controller: startCtrl, readOnly: true, onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
                      if (picked != null) setDialogState(() => startCtrl.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}");
                    })),
                    const SizedBox(width: 10),
                    Expanded(child: AppInputField(label: 'Selesai', controller: endCtrl, readOnly: true, onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 12, minute: 0));
                      if (picked != null) setDialogState(() => endCtrl.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}");
                    })),
                  ],
                ),
                const SizedBox(height: 10),
                AppInputField(label: 'Harga (Rp)', controller: priceCtrl, keyboardType: TextInputType.number, prefixText: 'Rp '),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (priceCtrl.text.isEmpty || startCtrl.text.compareTo(endCtrl.text) >= 0) return;
                setState(() {
                  _pricingRules.add({
                    'day_type': selectedDay,
                    'start_time': startCtrl.text,
                    'end_time': endCtrl.text,
                    'price': int.parse(priceCtrl.text),
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Tambah'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.primaryBlue,
      appBar: AppBar(title: const Text("Edit Data Lapangan", style: TextStyle(color: Colors.white)), backgroundColor: AppThemeConstants.primaryBlue, iconTheme: const IconThemeData(color: Colors.white)),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppThemeConstants.bgLight, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/admin/close-field/${widget.fieldId}'),
                      icon: const Icon(Icons.lock_clock, color: Colors.white),
                      label: const Text("Tutup Sementara Lapangan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppThemeConstants.errorRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Foto Lapangan", style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppThemeConstants.borderGrey)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                                ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                                : const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppInputField(label: 'Nama Lapangan', controller: _nameController),
                  const SizedBox(height: 16),
                  AppInputField(label: 'Kategori', controller: _categoryController),
                  const SizedBox(height: 16),
                  AppInputField(label: 'Deskripsi', controller: _descController, maxLines: 3),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Jadwal & Pengaturan Harga", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      IconButton(icon: const Icon(Icons.add_circle, color: AppThemeConstants.successGreen, size: 28), onPressed: _showAddRuleDialog)
                    ],
                  ),
                  _buildPricingRulesList(),
                  const SizedBox(height: 8),
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(width: double.infinity, child: AppButton(label: 'Simpan Perubahan', onPressed: _saveData)),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildPricingRulesList() {
    if (_pricingRules.isEmpty) return const Text("Belum ada aturan harga. Silakan tambahkan minimal satu.", style: TextStyle(color: AppThemeConstants.errorRed));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pricingRules.length,
      itemBuilder: (context, index) {
        final rule = _pricingRules[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(rule['day_type'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${rule['start_time']} - ${rule['end_time']} | ${CurrencyUtil.toRupiah(rule['price'])}'),
            trailing: IconButton(icon: const Icon(Icons.delete, color: AppThemeConstants.errorRed), onPressed: () => _removeRule(index)),
          ),
        );
      },
    );
  }
}
