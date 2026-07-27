import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _reportData;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient.get(
        Uri.parse('${ApiEndpoints.monthlyReport}?bulan=$_selectedMonth&tahun=$_selectedYear'),
      );
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        if (mounted) {
          setState(() {
            _reportData = jsonData['data'];
            _isLoading = false;
          });
        }
      } else {
        throw FormatException(jsonData['message'] ?? 'Gagal memuat rekap laporan.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('FormatException: ', '').replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  String _formatRp(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Rekap Laporan Keuangan', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin/dashboard'),
        ),
      ),
      body: Column(
        children: [
          _buildFilterHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: AppThemeConstants.errorRed)))
                    : _buildReportContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedMonth,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: List.generate(12, (index) {
                return DropdownMenuItem(value: index + 1, child: Text(_months[index]));
              }),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMonth = val);
                  _fetchReport();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: [2025, 2026, 2027, 2028, 2029, 2030].map((year) {
                return DropdownMenuItem(value: year, child: Text('$year'));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedYear = val);
                  _fetchReport();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    final summary = _reportData?['summary'] as Map<String, dynamic>? ?? {};
    final transactions = (_reportData?['transactions'] as List<dynamic>?) ?? [];

    final int grossIncome = int.tryParse(summary['gross_income']?.toString() ?? '0') ?? 0;
    final int totalRefund = int.tryParse(summary['total_refund']?.toString() ?? '0') ?? 0;
    final int netIncome = int.tryParse(summary['net_income']?.toString() ?? '0') ?? 0;
    final int totalExpense = int.tryParse(summary['total_expense']?.toString() ?? '0') ?? 0;
    final int netProfit = int.tryParse(summary['net_profit']?.toString() ?? '0') ?? 0;

    return RefreshIndicator(
      onRefresh: _fetchReport,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(grossIncome, totalRefund, netIncome, totalExpense, netProfit),
          const SizedBox(height: 20),
          const Text('Rincian Transaksi Keuangan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Tidak ada transaksi pada periode ini.', style: TextStyle(color: AppThemeConstants.textSecondary))))
          else
            ...transactions.map((tx) => _buildTransactionCard(tx as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int gross, int refund, int netInc, int expense, int profit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeConstants.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Kas Bulanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
          const SizedBox(height: 16),
          _buildSummaryRow('Pemasukan Kotor (Gross)', _formatRp(gross), color: AppThemeConstants.textPrimary),
          _buildSummaryRow('Pengembalian Dana (Refund)', '- ${_formatRp(refund)}', color: AppThemeConstants.errorRed),
          const Divider(height: 20, color: AppThemeConstants.borderGrey),
          _buildSummaryRow('Pemasukan Bersih', _formatRp(netInc), color: AppThemeConstants.successGreen, isBold: true),
          _buildSummaryRow('Total Pengeluaran', '- ${_formatRp(expense)}', color: AppThemeConstants.warningAmber),
          const Divider(height: 20, color: AppThemeConstants.borderGrey),
          _buildSummaryRow('Laba Bersih (Net Profit)', _formatRp(profit), color: profit >= 0 ? AppThemeConstants.accentBlue : AppThemeConstants.errorRed, isBold: true, fontSize: 16),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color, bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize - 1, color: AppThemeConstants.textSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: fontSize, color: color ?? AppThemeConstants.textPrimary, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx) {
    final String type = tx['type']?.toString() ?? 'income';
    final bool isRefund = type == 'refund' || tx['payment_type'] == 'refund';
    final bool isExpense = type == 'expense';

    final int amount = int.tryParse(tx['amount']?.toString() ?? '0') ?? 0;
    final String title = tx['title']?.toString() ?? tx['category']?.toString() ?? '-';
    final String date = tx['date']?.toString() ?? '-';
    final String method = tx['method']?.toString() ?? 'CASH';

    Color cardColor = AppThemeConstants.successGreen;
    Color bgColor = AppThemeConstants.lightGreen;
    IconData icon = Icons.account_balance_wallet_rounded;
    String badgeLabel = 'MASUK';
    String prefix = '+ ';

    if (isRefund) {
      cardColor = AppThemeConstants.errorRed;
      bgColor = AppThemeConstants.lightRed;
      icon = Icons.money_off_rounded;
      badgeLabel = 'REFUND';
      prefix = '- ';
    } else if (isExpense) {
      cardColor = AppThemeConstants.warningAmber;
      bgColor = AppThemeConstants.lightAmber;
      icon = Icons.shopping_bag_outlined;
      badgeLabel = 'PENGELUARAN';
      prefix = '- ';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: bgColor,
          child: Icon(icon, color: cardColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('$date • $method\n${tx['field_name'] ?? ''}', style: const TextStyle(fontSize: 11, color: AppThemeConstants.textSecondary)),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$prefix${_formatRp(amount)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cardColor),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
              child: Text(
                badgeLabel,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: cardColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
