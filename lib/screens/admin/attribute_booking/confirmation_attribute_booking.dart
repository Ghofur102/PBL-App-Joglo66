import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/services/attribute_booking.dart';

class ConfirmationAttributeBookingScreens extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String customerName;
  final String customerPhone;
  final int durationHours;
  final String transactionDate;
  final int totalPrice;

  const ConfirmationAttributeBookingScreens({
    super.key,
    required this.items,
    required this.customerName,
    required this.customerPhone,
    required this.durationHours,
    required this.transactionDate,
    required this.totalPrice,
  });

  @override
  State<ConfirmationAttributeBookingScreens> createState() =>
      _ConfirmationAttributeBookingScreensState();
}

class _ConfirmationAttributeBookingScreensState
    extends State<ConfirmationAttributeBookingScreens> {
  bool _isProcessing = false;

  Future<void> _confirm() async {
    setState(() => _isProcessing = true);

    try {
      await AttributeBookingService.rentAttribute(
        items: widget.items.map((item) => {
          'fk_attribute_id': item['fk_attribute_id'],
          'quantity': item['quantity'],
        }).toList(),
        customerName: widget.customerName,
        customerPhone: widget.customerPhone,
        durationHours: widget.durationHours,
        transactionDate: widget.transactionDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi penyewaan berhasil disimpan.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/admin/history-rent-attribute');
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
      if (mounted) setState(() => _isProcessing = false);
    }
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
          'Konfirmasi Penyewaan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Penyewa',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _infoRow('Nama', widget.customerName),
                  _infoRow('Kontak',
                      widget.customerPhone.isEmpty ? '-' : widget.customerPhone),
                  _infoRow('Tanggal', widget.transactionDate),
                  _infoRow('Durasi', '${widget.durationHours} Jam'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Detail Barang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final qty = item['quantity'] as int;
              final price = item['price_hour'] as int;
              final subtotal = price * qty * widget.durationHours;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF406093).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF406093),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name']?.toString() ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$qty x ${formatRp.format(price)}/jam',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatRp.format(subtotal),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Biaya Penyewaan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  formatRp.format(widget.totalPrice),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batalkan',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF406093),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Konfirmasi Penyewaan',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black54)),
          ),
          const Text(': '),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
