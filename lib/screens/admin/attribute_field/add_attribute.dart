import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/components/input_field.dart';
import 'package:pbl_app_joglo66/services/attribute_field.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class AddAttributeScreens extends StatefulWidget {
  const AddAttributeScreens({super.key});

  @override
  State<AddAttributeScreens> createState() => _AddAttributeScreensState();
}

class _AddAttributeScreensState extends State<AddAttributeScreens> {
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
        const SnackBar(content: Text('Lapangan wajib dipilih.'), backgroundColor: Colors.orange),
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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data atribut berhasil diperbarui.'), backgroundColor: Colors.green),
          );
          context.pop();
        }
      } else {
        await AttributeService.createAttribute(
          fkFieldId: _selectedFieldId!,
          name: name,
          type: _selectedType,
          stock: stock,
          priceHour: price,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data atribut berhasil disimpan.'), backgroundColor: Colors.green),
          );
          context.pop();
        }
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditMode ? 'Edit Atribut' : 'Tambah Atribut',
          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _isLoadingFields
          ? const Center(child: CircularProgressIndicator())
          : _fieldsError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Gagal Memuat Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 8),
                        Text(_fieldsError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 13)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _fieldsError = null;
                              _isLoadingFields = true;
                            });
                            _loadFields();
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF406093),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isEditMode) ...[
                          const Text(
                            'Pilih Lapangan',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedFieldId,
                            decoration: _dropdownDecoration('Pilih lapangan untuk atribut ini'),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                            items: _fields.map((f) {
                              final fId = int.tryParse(f['id']?.toString() ?? '0') ?? 0;
                              return DropdownMenuItem(
                                value: fId,
                                child: Text(f['name']?.toString() ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedFieldId = v),
                            validator: (v) => v == null ? 'Pilih lapangan' : null,
                          ),
                          const SizedBox(height: 20),
                        ],
                        InputField(
                          label: 'Nama Atribut',
                          hint: 'Contoh: Sepatu Futsal Specs',
                          controller: _nameController,
                          icon: Icons.inventory_2_outlined,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nama atribut wajib diisi' : null,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Jenis Atribut',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: _dropdownDecoration('Pilih jenis atribut'),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                          items: _types.map((t) {
                            IconData icon = t == 'sepatu' ? Icons.shopping_bag_outlined : (t == 'rompi' ? Icons.checkroom_outlined : Icons.sports_tennis_outlined);
                            return DropdownMenuItem(
                              value: t,
                              child: Row(
                                children: [
                                  Icon(icon, size: 18, color: const Color(0xFF406093)),
                                  const SizedBox(width: 10),
                                  Text(t[0].toUpperCase() + t.substring(1), style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedType = v);
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: InputField(
                                label: 'Harga Sewa (per Jam)',
                                hint: '0',
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                prefixText: 'Rp ',
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                                  if (int.tryParse(v.trim()) == null) return 'Harus angka';
                                  if (int.parse(v.trim()) < 0) return 'Tidak boleh negatif';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: InputField(
                                label: 'Jumlah Stok',
                                hint: '0',
                                controller: _stockController,
                                keyboardType: TextInputType.number,
                                icon: Icons.format_list_numbered_rounded,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                                  if (int.tryParse(v.trim()) == null) return 'Harus angka';
                                  if (int.parse(v.trim()) < 0) return 'Tidak boleh negatif';
                                  return null;
                                },
                              ),
                            ),
                          ],
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
                            child: _isSubmitting()
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Simpan Atribut', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  bool _isSubmitting() => _isSaving;
}