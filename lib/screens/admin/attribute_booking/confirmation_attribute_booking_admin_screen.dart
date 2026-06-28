import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/attribute_booking_service.dart';

class ConfirmationAttributeBookingAdminScreen extends StatefulWidget {
  final int fkBookingId;
  final List<Map<String, dynamic>> items;
  final String customerName;
  final String customerPhone;
  final int durationHours;
  final String transactionDate;
  final int totalPrice;

  const ConfirmationAttributeBookingAdminScreen({
    super.key,
    required this.fkBookingId,
    required this.items,
    required this.customerName,
    required this.customerPhone,
    required this.durationHours,
    required this.transactionDate,
    required this.totalPrice,
  });

  @override
  State<ConfirmationAttributeBookingAdminScreen> createState() => _ConfirmationAttributeBookingAdminScreenState();
}

class _ConfirmationAttributeBookingAdminScreenState extends State<ConfirmationAttributeBookingAdminScreen> {
  bool _isProcessing = false;

  Future<void> _confirm() async {
    setState(() => _isProcessing = true);
    try {
      await AttributeBookingService.rentAttribute(
        fkBookingId: widget.fkBookingId,
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
          const SnackBar(content: Text('Transaksi penyewaan berhasil disimpan.'), backgroundColor: AppThemeConstants.successGreen),
        );
        context.go('/admin/history-rent-attribute');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Konfirmasi Penyewaan', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Penyewa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppThemeConstants.borderGrey)),
              child: Column(
                children: [
                  DetailRow(label: 'Nama', value: widget.customerName),
                  DetailRow(label: 'Kontak', value: widget.customerPhone.isEmpty ? '-' : widget.customerPhone),
                  DetailRow(label: 'Tanggal', value: widget.transactionDate),
                  DetailRow(label: 'Durasi', value: '${widget.durationHours} Jam'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Detail Atribut Disewa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildItemsSummaryList(formatRp),
            const SizedBox(height: 24),
            _buildActionFooterSection(formatRp),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSummaryList(NumberFormat formatRp) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      itemBuilder: (context, idx) {
        final item = widget.items[idx];
        final int qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
        final int price = int.tryParse(item['price_hour']?.toString() ?? '0') ?? 0;
        final int subtotal = price * qty * widget.durationHours;

        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${idx + 1}')),
            title: Text(item['name']?.toString() ?? '-'),
            subtitle: Text('$qty Pcs x ${formatRp.format(price)}'),
            trailing: Text(formatRp.format(subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildActionFooterSection(NumberFormat formatRp) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppThemeConstants.accentBlue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran', style: TextStyle(color: Colors.white)),
              Text(formatRp.format(widget.totalPrice), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _isProcessing
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  Expanded(child: AppButton(label: 'Batal', backgroundColor: AppThemeConstants.lightRed, textColor: AppThemeConstants.errorRed, onPressed: () => context.pop())),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: AppButton(label: 'Simpan Transaksi', backgroundColor: AppThemeConstants.successGreen, onPressed: _confirm)),
                ],
              )
      ],
    );
  }
}
