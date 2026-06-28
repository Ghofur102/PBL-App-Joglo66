import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/models/attributes_model.dart';
import 'package:pbl_app_joglo66/services/attribute_service.dart';
import 'package:pbl_app_joglo66/services/attribute_booking_service.dart';
import 'package:pbl_app_joglo66/models/rental_item_model.dart';

class AddAttributeBookingAdminScreen extends StatefulWidget {
  const AddAttributeBookingAdminScreen({super.key});

  @override
  State<AddAttributeBookingAdminScreen> createState() => _AddAttributeBookingAdminScreenState();
}

class _AddAttributeBookingAdminScreenState extends State<AddAttributeBookingAdminScreen> {
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _durationController = TextEditingController();
  final _dateController = TextEditingController();
  final _searchController = TextEditingController();

  bool _isLoading = true;
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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed),
        );
      }
    }
  }

  String _safeTimeFormat(String timeStr) {
    final parts = timeStr.split(':');
    final formattedTime = parts.length >= 2 ? '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}' : '00:00';
    return formattedTime;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada atribut tersedia di lapangan ini.'), backgroundColor: AppThemeConstants.warningAmber),
      );
      return;
    }
    setState(() {
      _items.add(RentalItemModel(attribute: Attribute.fromJson(_filteredAttributes.first)));
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
      if (i != index && _items[i].selectedAttributeId == newAttrId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atribut tersebut sudah ada di keranjang.'), backgroundColor: AppThemeConstants.warningAmber),
        );
        return;
      }
    }

    setState(() {
      final selectedAttr = _filteredAttributes.firstWhere((a) => a['id'] == newAttrId);
      _items[index] = RentalItemModel(
        attribute: Attribute.fromJson(selectedAttr),
        selectedAttributeId: newAttrId,
        quantity: 1,
      );
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
    if (_selectedBooking == null || _items.isEmpty) return;

    final itemsPayload = AttributeBookingService.formatRentalPayload(_items);

    context.push(
      '/admin/confirmation-rent-attribute',
      extra: {
        'fkBookingId': _selectedBooking!['booking_id'],
        'items': itemsPayload,
        'customerName': _customerNameController.text.trim(),
        'customerPhone': _customerPhoneController.text.trim(),
        'durationHours': int.tryParse(_durationController.text.trim()) ?? 1,
        'transactionDate': _dateController.text,
        'totalPrice': _totalPrice,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        title: const Text('Sewa Atribut', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedBooking == null ? '1. Cari Sesi Jadwal Booking' : '1. Sesi Jadwal Booking Terpilih',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  _buildSearchOrSelected(),
                  const SizedBox(height: 24),

                  if (_selectedBooking != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Otomatis',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 16),
                          AppInputField(
                            label: 'Nama Penyewa / Tim',
                            controller: _customerNameController,
                            readOnly: true,
                            isEnabled: false,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppInputField(
                                  label: 'Tanggal',
                                  controller: _dateController,
                                  readOnly: true,
                                  isEnabled: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppInputField(
                                  label: 'Durasi (Jam)',
                                  controller: _durationController,
                                  readOnly: true,
                                  isEnabled: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildCartHeaderSection(),
                    const SizedBox(height: 12),
                    _buildCartItemsList(formatRp),
                    if (_items.isNotEmpty) _buildFooterSummarySection(formatRp),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSearchOrSelected() {
    if (_selectedBooking != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppThemeConstants.borderGrey)),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppThemeConstants.successGreen, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_selectedBooking!['team_name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${_selectedBooking!['play_date']}'),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.close, color: AppThemeConstants.errorRed), onPressed: _clearBookingSelection),
          ],
        ),
      );
    }

    final filtered = _activeBookings.where((b) {
      final query = _searchController.text.toLowerCase();
      return (b['team_name'] ?? '').toString().toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        AppInputField(label: 'Cari Booking', hint: 'Ketik nama tim...', controller: _searchController, icon: Icons.search, onTap: () => setState(() {})),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, idx) => ListTile(
            title: Text(filtered[idx]['team_name'] ?? '-'),
            onTap: () => _onBookingSelected(filtered[idx]),
          ),
        )
      ],
    );
  }

  Widget _buildCartHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('2. Keranjang Sewa Atribut', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Tambah Item')),
      ],
    );
  }

  Widget _buildCartItemsList(NumberFormat formatRp) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: (context, idx) {
        final item = _items[idx];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  value: item.selectedAttributeId,
                  items: _filteredAttributes.map((a) => DropdownMenuItem(value: a['id'] as int, child: Text(a['name'] ?? '-'))).toList(),
                  onChanged: (v) => _onAttributeChanged(idx, v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.remove), onPressed: () => _updateItemQuantity(idx, item.quantity - 1)),
                    Text('${item.quantity}'),
                    IconButton(icon: const Icon(Icons.add), onPressed: () => _updateItemQuantity(idx, item.quantity + 1)),
                    Text(formatRp.format(item.price * item.quantity)),
                    IconButton(icon: const Icon(Icons.delete, color: AppThemeConstants.errorRed), onPressed: () => _removeItem(idx)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooterSummarySection(NumberFormat formatRp) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          color: AppThemeConstants.primaryBlue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran', style: TextStyle(color: Colors.white)),
              Text(formatRp.format(_totalPrice), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppButton(label: 'Lanjutkan Konfirmasi', onPressed: _submit),
      ],
    );
  }
}
