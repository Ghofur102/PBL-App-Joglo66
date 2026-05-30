import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/services/expense_field.dart';

class DetailExpensePage extends StatefulWidget {
  final Map<String, dynamic> expenseData;

  const DetailExpensePage({super.key, required this.expenseData});

  @override
  State<DetailExpensePage> createState() => _DetailExpensePageState();
}

class _DetailExpensePageState extends State<DetailExpensePage> {
  bool _isDeleting = false;

  String _formatPrice(int? price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(price ?? 0);
  }

  void deleteExpense() async {
    final int id = int.tryParse(widget.expenseData['id']?.toString() ?? '0') ?? 0;

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Hapus Pengeluaran", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Apakah Anda yakin ingin menghapus data pengeluaran ini secara permanen?"),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => context.pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        final success = await ExpenseService.deleteExpense(id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data pengeluaran berhasil dihapus"), backgroundColor: Colors.green),
          );
          context.pop();
        } else {
          throw Exception("Gagal menghapus data dari server.");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.expenseData;
    final int amount = int.tryParse(data['amount']?.toString() ?? '0') ?? 0;
    final bool hasProof = data['proof'] == true && data['image'] != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
        ),
        title: const Text(
          "Detail Pengeluaran",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.outbox_rounded, color: Color(0xFFEF4444), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title'] ?? "-",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['category'] ?? "Operasional",
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatPrice(amount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFEF4444)),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF1F5F9))),
                        Row(
                          children: [
                            Expanded(child: buildInfoColumn(title: "Tanggal Pengeluaran", value: data['date'] ?? "-")),
                            const SizedBox(width: 16),
                            Expanded(child: buildInfoColumn(title: "Status Bukti", value: hasProof ? "Tersedia" : "Belum Ada")),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description_outlined, size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            const Text("Detail Transaksi", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: buildInfoColumn(title: "Nama Pengeluaran", value: data['title'] ?? "-")),
                            const SizedBox(width: 16),
                            Expanded(child: buildInfoColumn(title: "Jenis Kategori", value: data['category'] ?? "-")),
                          ],
                        ),
                        const SizedBox(height: 16),
                        buildInfoColumn(
                          title: "Catatan Tambahan", 
                          value: data['note'] != null && data['note'].toString().isNotEmpty && data['note'].toString() != '-'
                              ? data['note'] 
                              : "Tidak ada catatan tambahan"
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            const Text("Bukti Dokumen Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                image: hasProof
                                    ? DecorationImage(image: NetworkImage(data['image'].toString()), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: !hasProof
                                  ? const Icon(Icons.image_not_supported_outlined, size: 32, color: Color(0xFF94A3B8))
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildInfoColumn(title: "Status Validasi Dokumen", value: hasProof ? "Bukti Ter-upload" : "Belum Ada Dokumen"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: deleteExpense,
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                      label: const Text("Hapus Pengeluaran", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildInfoColumn({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
      ],
    );
  }
}