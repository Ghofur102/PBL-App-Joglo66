import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        _editId = extra['id'] is int
            ? extra['id'] as int
            : int.tryParse(extra['id'].toString()) ?? 0;
        _nameController.text = extra['name']?.toString() ?? '';
        _selectedType = extra['type']?.toString() ?? 'lainnya';
        _stockController.text = extra['stock']?.toString() ?? '';
        _priceController.text = extra['price_hour']?.toString() ?? '';
        _selectedFieldId = extra['fk_field_id'] is int
            ? extra['fk_field_id'] as int
            : int.tryParse(extra['fk_field_id'].toString()) ?? 0;
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
      print('[AddAttribute] Fields API response count: ${rawData.length}');
      final list = rawData.map((item) => item as Map<String, dynamic>).toList();

      if (mounted) {
        setState(() {
          _fields.addAll(list);
          _isLoadingFields = false;

          if (_fields.isNotEmpty && _selectedFieldId == null) {
            _selectedFieldId =
                _fields.first['id'] is int
                    ? _fields.first['id'] as int
                    : int.tryParse(_fields.first['id'].toString()) ?? 0;
          }
        });
      }
    } catch (e) {
      print('[AddAttribute] Error loading fields: $e');
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
        const SnackBar(
          content: Text('Lapangan wajib dipilih.'),
          backgroundColor: Colors.orange,
        ),
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
            const SnackBar(
              content: Text('Data atribut berhasil diperbarui.'),
              backgroundColor: Colors.green,
            ),
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
            const SnackBar(
              content: Text('Data atribut berhasil disimpan.'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditMode ? 'Edit Atribut' : 'Tambah Atribut';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoadingFields
          ? const Center(child: CircularProgressIndicator())
          : _fieldsError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Gagal memuat data lapangan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _fieldsError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _selectedFieldId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _fields.map((f) {
                          final fId = f['id'] is int
                              ? f['id'] as int
                              : int.tryParse(f['id'].toString()) ?? 0;
                          return DropdownMenuItem(
                            value: fId,
                            child: Text(f['name']?.toString() ?? ''),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedFieldId = v),
                        validator: (v) => v == null ? 'Pilih lapangan' : null,
                      ),
                      const SizedBox(height: 20),
                    ],
                    const Text(
                      'Nama Atribut',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Sepatu Futsal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Nama atribut wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Jenis Atribut',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: _types.map((t) {
                        final label = t[0].toUpperCase() + t.substring(1);
                        IconData icon;
                        switch (t) {
                          case 'sepatu':
                            icon = Icons.shopping_bag;
                            break;
                          case 'rompi':
                            icon = Icons.checkroom;
                            break;
                          default:
                            icon = Icons.sports_tennis;
                        }
                        return DropdownMenuItem(
                          value: t,
                          child: Row(
                            children: [
                              Icon(icon, size: 18, color: const Color(0xFF406093)),
                              const SizedBox(width: 8),
                              Text(label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedType = v);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Harga Sewa (per Jam)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 25000',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Harga sewa wajib diisi';
                        if (int.tryParse(v.trim()) == null) return 'Format input harus berupa angka';
                        if (int.parse(v.trim()) < 0) return 'Harga sewa tidak boleh negatif';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Jumlah Stok',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 10',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Jumlah stok wajib diisi';
                        if (int.tryParse(v.trim()) == null) return 'Format input harus berupa angka';
                        if (int.parse(v.trim()) < 0) return 'Stok tidak boleh negatif';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF406093),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan Data',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
