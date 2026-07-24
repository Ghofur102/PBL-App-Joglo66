import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/expense_service.dart';

class ListExpenseAdminScreen extends StatefulWidget {
  const ListExpenseAdminScreen({super.key});

  @override
  State<ListExpenseAdminScreen> createState() => _ListExpenseAdminScreenState();
}

class _ListExpenseAdminScreenState extends State<ListExpenseAdminScreen> {
  List<dynamic> _expenses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final data = await ExpenseService.getExpenses();
      setState(() {
        _expenses = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('FormatException: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatPrice(int price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  int _calculateTotal() {
    return _expenses.fold(0, (sum, item) {
      final int qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
      final int unitPrice = int.tryParse(item['unit_price']?.toString() ?? '0') ?? 0;
      final int amount = int.tryParse(item['amount']?.toString() ?? '0') ?? (qty * unitPrice);
      return sum + amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Daftar Pengeluaran", style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary), onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box, color: AppThemeConstants.accentBlue),
            onPressed: () => context.push('/admin/add-expense-field').then((_) => _loadExpenses()),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppThemeConstants.accentBlue, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Pengeluaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(_formatPrice(_calculateTotal()), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          if (_errorMessage != null)
            Padding(padding: const EdgeInsets.all(16), child: Text(_errorMessage!, style: const TextStyle(color: AppThemeConstants.errorRed))),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
                : _expenses.isEmpty
                    ? const Center(child: Text("Belum ada data pengeluaran.", style: TextStyle(color: AppThemeConstants.textSecondary)))
                    : ListView.builder(
                        itemCount: _expenses.length,
                        itemBuilder: (context, i) {
                          final item = _expenses[i];
                          final int qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
                          final int unitPrice = int.tryParse(item['unit_price']?.toString() ?? '0') ?? 0;
                          final int total = int.tryParse(item['amount']?.toString() ?? '0') ?? (qty * unitPrice);
                          final String title = item['name'] ?? item['title'] ?? item['category'] ?? '-';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: ListTile(
                              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("${item['category']} • ${item['date'] ?? '-'} \n$qty x ${_formatPrice(unitPrice)}"),
                              isThreeLine: true,
                              trailing: Text(_formatPrice(total), style: const TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.errorRed)),
                              onTap: () => context.push('/admin/detail-expense-field', extra: item).then((_) => _loadExpenses()),
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }
}
