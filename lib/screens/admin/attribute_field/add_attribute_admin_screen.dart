import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/attribute_service.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class AddAttributeAdminScreen extends StatefulWidget {
  const AddAttributeAdminScreen({super.key});

  @override
  State<AddAttributeAdminScreen> createState() => _AddAttributeAdminScreenState();
}

class _AddAttributeAdminScreenState extends State<AddAttributeAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isEditMode = false;
  int? _editId;
  bool _isSaving = false;
  bool _isLoadingFields = true;
  String? _fieldsError;
  bool _extraLoaded = false;

  final List<Map<String, dynamic>> _fields = [];
  int? _selectedFieldId;
  String _selectedType = 'lainnya';

  final List<String> _types = ['sepatu', 'rompi', 'lainnya'];

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_extraLoaded) {
      _extraLoaded = true;
      final extra = GoRouterState.of(context).extra;
      if (extra != null && extra is Map<String, dynamic>) {
        _isEditMode = true;
        _editId = int.tryParse(extra['id']?.toString() ?? '0');
        _nameController.text = extra['name']?.toString() ?? '';
        _selectedType = extra['type']?.toString() ?? 'lainnya';
        _stockController.text = extra['stock']?.toString() ?? '';
        _priceController.text = extra['price_hour']?.toString() ?? '';
        _selectedFieldId = int.tryParse(extra['fk_field_id']?.toString() ?? '0');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadFields() async {
    try {
      final rawData = await FieldService.fetchListField();
      final list = rawData.map((item) => item as Map<String, dynamic>).toList();

      if (mounted) {
        setState(() {
          _fields.addAll(list);
          _isLoadingFields = false;

          if (_fields.isNotEmpty && _selectedFieldId == null) {
            _selectedFieldId = int.tryParse(_fields.first['id']?.toString() ?? '0');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFields = false;
          _fieldsError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFieldId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lapangan wajib dipilih.'), backgroundColor: AppThemeConstants.warningAmber),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final stock = int.tryParse(_stockController.text.trim()) ?? 0;
      final price = int.tryParse(_priceController.text.trim()) ?? 0;

      if (_isEditMode && _editId != null) {
        await AttributeService.updateAttribute(
          id: _editId!,
          name: name,
          type: _selectedType,
          stock: stock,
          priceHour: price,
        );
      } else {
        await AttributeService.createAttribute(
          fkFieldId: _selectedFieldId!,
          name: name,
          type: _selectedType,
          stock: stock,
          priceHour: price,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data Atribut Berhasil Disimpan.'), backgroundColor: AppThemeConstants.successGreen),
        );
        context.pop(true);
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
    final OutlineInputBorder dropdownBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
      borderSide: const BorderSide(color: AppThemeConstants.borderGrey),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary), onPressed: () => context.pop()),
        title: Text(_isEditMode ? 'Edit Atribut' : 'Tambah Atribut', style: const TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: _isLoadingFields
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : _fieldsError != null
              ? _buildErrorView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isEditMode) ...[
                          const Text('Pilih Lapangan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppThemeConstants.textPrimary)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedFieldId,
                            decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF8FAFC), border: dropdownBorder, enabledBorder: dropdownBorder),
                            items: _fields.map((f) => DropdownMenuItem(value: int.tryParse(f['id'].toString()), child: Text(f['name']?.toString() ?? ''))).toList(),
                            onChanged: (v) => setState(() => _selectedFieldId = v),
                          ),
                          const SizedBox(height: 20),
                        ],
                        AppInputField(
                          label: 'Nama Atribut',
                          hint: 'Contoh: Sepatu Futsal Specs',
                          controller: _nameController,
                          icon: Icons.inventory_2_outlined,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 20),
                        const Text('Jenis Atribut', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppThemeConstants.textPrimary)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF8FAFC), border: dropdownBorder, enabledBorder: dropdownBorder),
                          items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                          onChanged: (v) => setState(() => _selectedType = v ?? 'lainnya'),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: AppInputField(
                                label: 'Harga Sewa (per Jam)',
                                hint: '0',
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                prefixText: 'Rp ',
                                validator: (v) => v == null || int.tryParse(v.trim()) == null ? 'Wajib angka' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: AppInputField(
                                label: 'Jumlah Stok',
                                hint: '0',
                                controller: _stockController,
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || int.tryParse(v.trim()) == null ? 'Wajib angka' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        _isSaving
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppThemeConstants.accentBlue,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Simpan Atribut', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppThemeConstants.errorRed),
          const SizedBox(height: 16),
          Text(_fieldsError!, style: const TextStyle(color: AppThemeConstants.errorRed)),
          ElevatedButton(onPressed: _loadFields, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
