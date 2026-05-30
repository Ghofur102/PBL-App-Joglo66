import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/services/attribute_field.dart';
import 'package:pbl_app_joglo66/services/attribute_booking.dart';
import 'package:pbl_app_joglo66/components/input_field.dart';
import 'package:pbl_app_joglo66/models/rental_item_model.dart';

class AddAttributeBookingScreens extends StatefulWidget {
  const AddAttributeBookingScreens({super.key});

  @override
  State<AddAttributeBookingScreens> createState() => _AddAttributeBookingScreensState();
}

class _AddAttributeBookingScreensState extends State<AddAttributeBookingScreens> {
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _durationController = TextEditingController();
  final _dateController = TextEditingController();
  final _searchController = TextEditingController();

  bool _isLoadingData = true;
  List<Map<String, dynamic>> _activeBookings = [];
  List<Map<String, dynamic>> _allAttributes = [];
  List<Map<String, dynamic>> _filteredAttributes = [];
  Map<String, dynamic>? _selectedBooking;

  final List<RentalItemModel> _items = [];
  int _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _durationController.dispose();
    _dateController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final bookingsData = await AttributeBookingService.fetchActiveBookings();
      final attributesData = await AttributeService.fetchListAttribute();

      final activeAttrs = attributesData
          .map((item) => item as Map<String, dynamic>)
          .where((a) => a['status']?.toString() == 'active' && (int.tryParse(a['stock']?.toString() ?? '0') ?? 0) > 0)
          .toList();

      if (mounted) {
        setState(() {
          _activeBookings = bookingsData;
          _allAttributes = activeAttrs;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _safeTimeFormat(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return '00:00';
  }

  void _onBookingSelected(Map<String, dynamic> booking) {
    int duration = 1;
    try {
      final startTime = DateFormat("HH:mm").parse(_safeTimeFormat(booking['start_time'].toString()));
      final endTime = DateFormat("HH:mm").parse(_safeTimeFormat(booking['end_time'].toString()));
      duration = endTime.hour - startTime.hour;
      if (duration < 1) duration = 1;
    } catch (_) {
      duration = 1;
    }

    setState(() {
      _selectedBooking = booking;
      _customerNameController.text = booking['team_name'] ?? booking['customer_name'] ?? '';
      _customerPhoneController.text = booking['customer_phone'] ?? '';
      _dateController.text = booking['play_date']?.toString() ?? '';
      _durationController.text = duration.toString();

      _filteredAttributes = _allAttributes.where((a) {
        final fieldId = int.tryParse(a['fk_field_id']?.toString() ?? '0') ?? 0;
        final bFieldId = int.tryParse(booking['field_id']?.toString() ?? '0') ?? 0;
        return fieldId == bFieldId;
      }).toList();
      
      _items.clear();
      _totalPrice = 0;
      _searchController.clear();
    });
  }

  void _clearBookingSelection() {
    setState(() {
      _selectedBooking = null;
      _customerNameController.clear();
      _customerPhoneController.clear();
      _dateController.clear();
      _durationController.clear();
      _filteredAttributes.clear();
      _items.clear();
      _totalPrice = 0;
    });
  }

  void _addItem() {
    if (_filteredAttributes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak ada atribut tersedia di lapangan ini.'), backgroundColor: Colors.orange));
      return;
    }
    setState(() {
      _items.add(RentalItemModel(attribute: _filteredAttributes.first));
      _calculateTotal();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _calculateTotal();
    });
  }

  void _updateItemQuantity(int index, int newQty) {
    final item = _items[index];
    if (newQty > 0 && newQty <= item.stock) {
      setState(() {
        item.quantity = newQty;
        _calculateTotal();
      });
    }
  }

  void _onAttributeChanged(int index, int? newAttrId) {
    if (newAttrId == null) return;

    for (int i = 0; i < _items.length; i++) {
      if (i == index) continue;
      if (_items[i].selectedAttributeId == newAttrId) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Atribut tersebut sudah ada di keranjang.'), backgroundColor: Colors.orange));
        return;
      }
    }

    setState(() {
      final selectedAttr = _filteredAttributes.firstWhere((a) => a['id'] == newAttrId);
      _items[index].attribute = selectedAttr;
      _items[index].selectedAttributeId = newAttrId;
      _items[index].quantity = 1; 
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    final duration = int.tryParse(_durationController.text) ?? 1;
    setState(() {
      _totalPrice = AttributeBookingService.calculateTotalPrice(_items, duration);
    });
  }

  void _submit() {
    if (_selectedBooking == null) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal satu atribut untuk disewa.'), backgroundColor: Colors.red));
      return;
    }
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].selectedAttributeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon lengkapi pilihan atribut pada semua item.'), backgroundColor: Colors.red));
        return;
      }
    }

    final itemsPayload = AttributeBookingService.formatRentalPayload(_items);

    context.push('/admin/confirmation-rent-attribute', extra: {
      'fkBookingId': _selectedBooking!['booking_id'], 
      'items': itemsPayload,
      'customerName': _customerNameController.text.trim(),
      'customerPhone': _customerPhoneController.text.trim(),
      'durationHours': int.tryParse(_durationController.text.trim()) ?? 1,
      'transactionDate': _dateController.text,
      'totalPrice': _totalPrice,
    });
  }

  Widget _buildSearchOrSelected() {
    if (_selectedBooking != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedBooking!['team_name']} (${_selectedBooking!['customer_name']})',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedBooking!['play_date']} | ${_safeTimeFormat(_selectedBooking!['start_time'].toString())} - ${_safeTimeFormat(_selectedBooking!['end_time'].toString())}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: _clearBookingSelection,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    }

    final filtered = _activeBookings.where((b) {
      final searchLower = _searchController.text.toLowerCase();
      final team = (b['team_name'] ?? '').toString().toLowerCase();
      final cust = (b['customer_name'] ?? '').toString().toLowerCase();
      final date = (b['play_date'] ?? '').toString().toLowerCase();
      return team.contains(searchLower) || cust.contains(searchLower) || date.contains(searchLower);
    }).toList();

    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Ketik nama tim / penyewa...',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20, color: Color(0xFF94A3B8)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF406093), width: 1.5)),
          ),
          onChanged: (text) => setState(() {}),
        ),
        if (filtered.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final b = filtered[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text('${b['team_name']} (${b['customer_name']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${b['play_date']} | ${_safeTimeFormat(b['start_time'].toString())} - ${_safeTimeFormat(b['end_time'].toString())}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ),
                  onTap: () => _onBookingSelected(b),
                );
              },
            ),
          )
        ] else ...[
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Text('Data tidak ditemukan.', style: TextStyle(color: Color(0xFF94A3B8))),
          )
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)), onPressed: () => context.pop()),
        title: const Text('Sewa Atribut', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: const Color(0xFFE2E8F0), height: 1)),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedBooking == null ? '1. Cari Sesi Jadwal Booking' : '1. Sesi Jadwal Booking Terpilih', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 12),
                  _buildSearchOrSelected(),
                  const SizedBox(height: 24),

                  if (_selectedBooking != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Informasi Otomatis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(height: 16),
                          InputField(label: 'Nama Penyewa / Tim', controller: _customerNameController, readOnly: true, isEnabled: false),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: InputField(label: 'Tanggal', controller: _dateController, readOnly: true, isEnabled: false)),
                              const SizedBox(width: 12),
                              Expanded(child: InputField(label: 'Durasi (Jam)', controller: _durationController, readOnly: true, isEnabled: false)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('2. Keranjang Sewa Atribut', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        TextButton.icon(
                          onPressed: _items.length < _filteredAttributes.length ? _addItem : null,
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF406093)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_items.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: const Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 40, color: Color(0xFFCBD5E1)),
                            SizedBox(height: 8),
                            Text('Belum ada atribut yang dipilih', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    
                    ..._items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final duration = int.tryParse(_durationController.text) ?? 1;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Item ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                InkWell(
                                  onTap: () => _removeItem(index),
                                  child: const Icon(Icons.close_rounded, size: 20, color: Colors.red),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: item.selectedAttributeId,
                              decoration: InputDecoration(
                                hintText: 'Pilih Atribut',
                                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              ),
                              items: _filteredAttributes.map((a) {
                                final aId = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
                                final aStock = int.tryParse(a['stock']?.toString() ?? '0') ?? 0;
                                return DropdownMenuItem(value: aId, child: Text('${a['name']} (Sisa: $aStock)', style: const TextStyle(fontSize: 14)));
                              }).toList(),
                              onChanged: (v) => _onAttributeChanged(index, v),
                            ),
                            if (item.selectedAttributeId != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove, size: 18),
                                          color: const Color(0xFF406093),
                                          onPressed: item.quantity > 1 ? () => _updateItemQuantity(index, item.quantity - 1) : null,
                                        ),
                                        Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 18),
                                          color: const Color(0xFF406093),
                                          onPressed: item.quantity < item.stock ? () => _updateItemQuantity(index, item.quantity + 1) : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${formatRp.format(item.price)} /jam x $duration jam', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                      Text(formatRp.format(item.price * item.quantity * duration), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }),

                    if (_items.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: const Color(0xFF406093), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Pembayaran', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                            Text(formatRp.format(_totalPrice), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Lanjutkan Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]
                  ],
                ],
              ),
            ),
    );
  }
}