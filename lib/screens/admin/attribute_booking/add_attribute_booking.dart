import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/services/attribute_field.dart';

class AddAttributeBookingScreens extends StatefulWidget {
  const AddAttributeBookingScreens({super.key});

  @override
  State<AddAttributeBookingScreens> createState() =>
      _AddAttributeBookingScreensState();
}

class _AddAttributeBookingScreensState
    extends State<AddAttributeBookingScreens> {
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _durationController = TextEditingController(text: '1');
  final _dateController = TextEditingController();

  bool _isLoadingAttributes = true;
  List<Map<String, dynamic>> _availableAttributes = [];
  final List<_RentalItem> _items = [];
  int _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadAttributes();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _durationController.dispose();
    _dateController.dispose();
    for (final item in _items) {
      item.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAttributes() async {
    try {
      final rawData = await AttributeService.fetchListAttribute();
      final list = rawData
          .map((item) => item as Map<String, dynamic>)
          .where((a) => a['status']?.toString() == 'active')
          .where((a) {
        final stock = a['stock'] is int
            ? a['stock'] as int
            : int.tryParse(a['stock'].toString()) ?? 0;
        return stock > 0;
      }).toList();

      if (mounted) {
        setState(() {
          _availableAttributes = list;
          _isLoadingAttributes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAttributes = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data atribut: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addItem() {
    if (_availableAttributes.isEmpty) return;
    setState(() {
      _items.add(_RentalItem(
        attribute: _availableAttributes.first,
        controller: TextEditingController(text: '1'),
      ));
      _calculateTotal();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].controller.dispose();
      _items.removeAt(index);
      _calculateTotal();
    });
  }

  void _onItemChanged(int index) {
    for (int i = 0; i < _items.length; i++) {
      if (i == index) continue;
      if (_items[i].selectedAttributeId == _items[index].selectedAttributeId &&
          _items[index].selectedAttributeId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atribut sudah dipilih. Pilih atribut lain.'),
            backgroundColor: Colors.orange,
          ),
        );
        _items[index].attribute = _availableAttributes.first;
        _items[index].selectedAttributeId = null;
        setState(() {});
        return;
      }
    }
    _calculateTotal();
  }

  void _calculateTotal() {
    final duration = int.tryParse(_durationController.text) ?? 0;
    int total = 0;

    for (final item in _items) {
      if (item.selectedAttributeId == null) continue;
      final attr = item.attribute;
      final price = attr['price_hour'] is int
          ? attr['price_hour'] as int
          : int.tryParse(attr['price_hour']?.toString() ?? '0') ?? 0;
      final qty = int.tryParse(item.controller.text) ?? 1;
      total += price * qty * duration;
    }

    setState(() => _totalPrice = total);
  }

  bool _validate() {
    if (_customerNameController.text.trim().isEmpty) {
      _showError('Nama penyewa wajib diisi.');
      return false;
    }
    if (_durationController.text.trim().isEmpty ||
        int.tryParse(_durationController.text.trim()) == null ||
        int.parse(_durationController.text.trim()) < 1) {
      _showError('Durasi sewa harus berupa angka minimal 1 jam.');
      return false;
    }
    if (_items.isEmpty) {
      _showError('Pilih minimal satu atribut.');
      return false;
    }
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.selectedAttributeId == null) {
        _showError('Item ke-${i + 1}: pilih atribut.');
        return false;
      }
      final qtyStr = item.controller.text.trim();
      final qty = int.tryParse(qtyStr);
      if (qty == null || qty < 1) {
        _showError('Item ke-${i + 1}: jumlah harus berupa angka minimal 1.');
        return false;
      }
      final stock = item.attribute['stock'] is int
          ? item.attribute['stock'] as int
          : int.tryParse(item.attribute['stock']?.toString() ?? '0') ?? 0;
      if (qty > stock) {
        _showError(
            'Stok ${item.attribute['name']} tidak mencukupi. Sisa stok: $stock');
        return false;
      }
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _submit() {
    if (!_validate()) return;

    final items = _items
        .where((item) => item.selectedAttributeId != null)
        .map((item) {
      final attr = item.attribute;
      return {
        'fk_attribute_id': item.selectedAttributeId,
        'quantity': int.tryParse(item.controller.text.trim()) ?? 1,
        'name': attr['name']?.toString() ?? '',
        'price_hour': attr['price_hour'] is int
            ? attr['price_hour'] as int
            : int.tryParse(attr['price_hour']?.toString() ?? '0') ?? 0,
      };
    }).toList();

    context.push('/admin/confirmation-rent-attribute', extra: {
      'items': items,
      'customerName': _customerNameController.text.trim(),
      'customerPhone': _customerPhoneController.text.trim(),
      'durationHours': int.tryParse(_durationController.text.trim()) ?? 1,
      'transactionDate': _dateController.text,
      'totalPrice': _totalPrice,
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatRp =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Sewa Atribut',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

      ),
      body: _isLoadingAttributes
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Penyewa',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customerNameController,
                    decoration: _inputDecor('Nama Penyewa', 'Contoh: Budi'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customerPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecor(
                        'Kontak (opsional)', 'Contoh: 08123456789'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: _inputDecor('Tanggal Transaksi', ''),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        _dateController.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecor('Durasi Sewa (Jam)', 'Contoh: 2'),
                    onChanged: (_) => _calculateTotal(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Item Atribut',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: _items.length < _availableAttributes.length
                            ? _addItem
                            : null,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah Item'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_availableAttributes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Data atribut kosong. Silahkan tambahkan data di menu Master Data terlebih dahulu',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  if (_items.isEmpty && _availableAttributes.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Klik "Tambah Item" untuk memilih atribut',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ..._items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return _buildItemCard(idx, item, formatRp);
                  }),
                  if (_items.isNotEmpty) ...[
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Harga',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatRp.format(_totalPrice),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF406093),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan Transaksi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildItemCard(
      int index, _RentalItem item, NumberFormat formatRp) {
    final attr = item.attribute;
    final price = attr['price_hour'] is int
        ? attr['price_hour'] as int
        : int.tryParse(attr['price_hour']?.toString() ?? '0') ?? 0;
    final stock = attr['stock'] is int
        ? attr['stock'] as int
        : int.tryParse(attr['stock']?.toString() ?? '0') ?? 0;
    final qty = int.tryParse(item.controller.text) ?? 0;
    final duration = int.tryParse(_durationController.text) ?? 0;
    final subtotal = price * qty * duration;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Item ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon:
                    const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => _removeItem(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: item.selectedAttributeId,
            decoration: _inputDecor('Pilih Atribut', ''),
            items: _availableAttributes.map((a) {
              final aId = a['id'] is int
                  ? a['id'] as int
                  : int.tryParse(a['id'].toString()) ?? 0;
              final aStock = a['stock'] is int
                  ? a['stock'] as int
                  : int.tryParse(a['stock']?.toString() ?? '0') ?? 0;
              return DropdownMenuItem(
                value: aId,
                child: Text(
                    '${a['name']} (Stok: $aStock)'),
              );
            }).toList(),
            onChanged: (v) {
              if (v == null) return;
              final selectedAttr = _availableAttributes.firstWhere(
                  (a) => (a['id'] is int ? a['id'] as int : int.tryParse(a['id'].toString()) ?? 0) == v);
              setState(() {
                item.attribute = selectedAttr;
                item.selectedAttributeId = v;
                _onItemChanged(index);
              });
            },
            validator: (v) => v == null ? 'Pilih atribut' : null,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: item.controller,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecor('Jumlah', ''),
                  onChanged: (_) => _calculateTotal(),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatRp.format(price),
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  Text('/jam x $qty x $duration jam',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                  Text('= ${formatRp.format(subtotal)}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700])),
                ],
              ),
            ],
          ),
          if (item.selectedAttributeId != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Sisa stok: $stock',
                style: TextStyle(
                    fontSize: 11,
                    color: stock < 5 ? Colors.red : Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecor(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _RentalItem {
  Map<String, dynamic> attribute;
  int? selectedAttributeId;
  TextEditingController controller;

  _RentalItem({
    required this.attribute,
    required this.controller,
  });
}
