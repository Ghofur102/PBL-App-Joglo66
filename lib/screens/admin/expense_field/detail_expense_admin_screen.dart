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

  String _formatPrice(int? price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(price ?? 0);
  }

  Future<void> _deleteExpense() async {
    final int id = int.tryParse(widget.expenseData['id']?.toString() ?? '0') ?? 0;

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
    final int amount = int.tryParse(widget.expenseData['amount']?.toString() ?? '0') ?? 0;
    final bool hasImage = widget.expenseData['proof_photo'] != null && widget.expenseData['proof_photo'].toString().isNotEmpty;

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
                        DetailRow(label: "Keterangan", value: widget.expenseData['category'] ?? '-'),
                        DetailRow(label: "Tanggal", value: widget.expenseData['expense_date'] ?? '-'),
                        DetailRow(label: "Total Nominal", value: _formatPrice(amount), isBoldValue: true),
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
                        image: DecorationImage(image: NetworkImage(widget.expenseData['proof_photo']), fit: BoxFit.cover),
                      ),
                    ),
                  const SizedBox(height: 24),
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
