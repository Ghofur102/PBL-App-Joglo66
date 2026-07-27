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
  final _customTypeController = TextEditingController();

  bool _isEditMode = false;
  int? _editId;
  bool _isSaving = false;
  bool _isLoadingData = true;
  String? _dataError;
  bool _extraLoaded = false;

  final List<Map<String, dynamic>> _fields = [];
  int? _selectedFieldId;
  String? _selectedType;
  List<String> _types = [];
  bool _isCustomType = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_extraLoaded) {
      _extraLoaded = true;
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic>) {
        _isEditMode = true;
        _editId = int.tryParse(extra['id']?.toString() ?? '0');
        _nameController.text = extra['name']?.toString() ?? '';
        _selectedType = extra['type']?.toString();
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
    _customTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        FieldService.fetchListField(),
        AttributeService.fetchAttributeTypes(),
      ]);

      final List<dynamic> rawFields = results[0];
      final List<String> rawTypes = List<String>.from(results[1]);

      final fieldList = rawFields.whereType<Map<String, dynamic>>().toList();

      if (mounted) {
        setState(() {
          _fields.addAll(fieldList);
          _types = rawTypes;

          if (_fields.isNotEmpty && _selectedFieldId == null) {
            _selectedFieldId = int.tryParse(_fields.first['id']?.toString() ?? '0');
          }

          if (_selectedType != null && _selectedType!.isNotEmpty && !_types.contains(_selectedType)) {
            _types.add(_selectedType!);
          }

          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
          _dataError = e.toString().replaceAll('FormatException: ', '').replaceAll('Exception: ', '');
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

    final String? finalType = _isCustomType ? _customTypeController.text.trim().toLowerCase() : _selectedType;

    if (finalType == null || finalType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jenis atribut wajib dipilih atau diisi.'), backgroundColor: AppThemeConstants.warningAmber),
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
          type: finalType,
          stock: stock,
          priceHour: price,
        );
      } else {
        await AttributeService.createAttribute(
          fkFieldId: _selectedFieldId!,
          name: name,
          type: finalType,
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
        final cleanError = e.toString().replaceAll('FormatException: ', '').replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cleanError), backgroundColor: AppThemeConstants.errorRed),
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
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : _dataError != null
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
                          value: _isCustomType ? '+ Tambah Jenis Baru' : _selectedType,
                          hint: const Text('Pilih Jenis Atribut'),
                          decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF8FAFC), border: dropdownBorder, enabledBorder: dropdownBorder),
                          items: [
                            ..._types.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))),
                            const DropdownMenuItem(
                              value: '+ Tambah Jenis Baru',
                              child: Text('+ Tambah Jenis Baru', style: TextStyle(color: AppThemeConstants.accentBlue, fontWeight: FontWeight.bold)),
                            ),
                          ],
                          validator: (v) {
                            if (!_isCustomType && (_selectedType == null || _selectedType!.isEmpty)) {
                              return 'Jenis atribut wajib dipilih';
                            }
                            return null;
                          },
                          onChanged: (v) {
                            setState(() {
                              if (v == '+ Tambah Jenis Baru') {
                                _isCustomType = true;
                                _selectedType = null;
                              } else {
                                _isCustomType = false;
                                _selectedType = v;
                              }
                            });
                          },
                        ),
                        if (_isCustomType) ...[
                          const SizedBox(height: 16),
                          AppInputField(
                            label: 'Nama Jenis Baru',
                            hint: 'Ketik jenis atribut baru',
                            controller: _customTypeController,
                            icon: Icons.add_box_outlined,
                            validator: (v) => _isCustomType && (v == null || v.trim().isEmpty) ? 'Jenis baru wajib diisi' : null,
                          ),
                        ],
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
          Text(_dataError!, style: const TextStyle(color: AppThemeConstants.errorRed)),
          ElevatedButton(onPressed: _loadInitialData, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
