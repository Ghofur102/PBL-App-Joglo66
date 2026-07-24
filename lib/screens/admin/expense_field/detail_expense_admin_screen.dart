import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/expense_service.dart';

class DetailExpenseAdminScreen extends StatefulWidget {
  final Map<String, dynamic> expenseData;

  const DetailExpenseAdminScreen({super.key, required this.expenseData});

  @override
  State<DetailExpenseAdminScreen> createState() => _DetailExpenseAdminScreenState();
}

class _DetailExpenseAdminScreenState extends State<DetailExpenseAdminScreen> {
  bool _isDeleting = false;
  late Map<String, dynamic> _currentData;

  @override
  void initState() {
    super.initState();
    _currentData = Map<String, dynamic>.from(widget.expenseData);
  }

  String _formatPrice(int? price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(price ?? 0);
  }

  Future<void> _deleteExpense() async {
    final int id = int.tryParse(_currentData['id']?.toString() ?? '0') ?? 0;

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium)),
        title: const Text("Hapus Pengeluaran", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin menghapus data ini? Tindakan ini permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppThemeConstants.errorRed),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    setState(() => _isDeleting = true);
    try {
      final success = await ExpenseService.deleteExpense(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data pengeluaran berhasil dihapus"), backgroundColor: AppThemeConstants.successGreen),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed));
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int qty = int.tryParse(_currentData['quantity']?.toString() ?? '1') ?? 1;
    final int unitPrice = int.tryParse(_currentData['unit_price']?.toString() ?? '0') ?? 0;
    final int amount = int.tryParse(_currentData['amount']?.toString() ?? '0') ?? (qty * unitPrice);

    final String? imageUrl = _currentData['image'] ?? _currentData['proof_photo'];
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final String name = _currentData['name'] ?? _currentData['title'] ?? '-';

    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Detail Pengeluaran", style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary), onPressed: () => context.pop()),
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppThemeConstants.borderGrey)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailRow(label: "Nama Pengeluaran", value: name, isBoldValue: true),
                        DetailRow(label: "Kategori", value: _currentData['category'] ?? '-'),
                        DetailRow(label: "Kuantitas Pembelian", value: "$qty barang / unit"),
                        DetailRow(label: "Harga Satuan", value: _formatPrice(unitPrice)),
                        DetailRow(label: "Tanggal Transaksi", value: _currentData['date'] ?? _currentData['expense_date'] ?? '-'),
                        DetailRow(label: "Total Nominal", value: _formatPrice(amount), isBoldValue: true),
                        DetailRow(label: "Catatan Tambahan", value: _currentData['note'] ?? '-'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (hasImage)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppThemeConstants.borderGrey),
                        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: "Edit Pengeluaran",
                      backgroundColor: AppThemeConstants.lightAmber,
                      textColor: AppThemeConstants.warningAmber,
                      onPressed: () async {
                        final updated = await context.push<bool>(
                          '/admin/edit-expense-field',
                          extra: _currentData,
                        );
                        if (updated == true && mounted) {
                          context.pop(true);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: "Hapus Transaksi",
                      backgroundColor: AppThemeConstants.lightRed,
                      textColor: AppThemeConstants.errorRed,
                      onPressed: _deleteExpense,
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
