import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/report_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  int _selectedTab = 0;
  String _selectedCategory = 'Semua';
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _reportData;

  static const _monthLabels = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ReportService.fetchMonthlyReport(_selectedMonth, _selectedYear);
      setState(() {
        _reportData = data;
        _selectedCategory = 'Semua';
        _startDate = null;
        _endDate = null;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatRupiah(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final int val = (amount is num) ? amount.toInt() : int.tryParse(amount.toString()) ?? 0;
    final int absVal = val.abs();
    final String sign = val < 0 ? '-' : '';

    // Kurung kurawal {} pada ${sign} wajib digunakan agar compiler tidak mengiranya sebagai variabel signRp
    if (absVal >= 1000000000) {
      final double billion = absVal / 1000000000;
      return '${sign}Rp ${billion.toStringAsFixed(billion % 1 == 0 ? 0 : 1).replaceAll('.', ',')} Miliar';
    }

    if (absVal >= 1000000) {
      final double million = absVal / 1000000;
      return '${sign}Rp ${million.toStringAsFixed(million % 1 == 0 ? 0 : 1).replaceAll('.', ',')} Juta';
    }

    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '${sign}Rp ${absVal.toString().replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(_selectedYear, _selectedMonth, 1),
      lastDate: DateTime(_selectedYear, _selectedMonth + 1, 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppThemeConstants.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        title: const Text('Laporan Keuangan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppThemeConstants.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : _errorMessage != null
              ? _buildErrorView()
              : _buildContentView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppThemeConstants.errorRed, size: 48),
          const SizedBox(height: 12),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchData, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _buildFilterRow(),
          const SizedBox(height: 14),
          _buildSummaryCards(),
          const SizedBox(height: 14),
          _buildDailySection(),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<int>(
              value: _selectedMonth,
              items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_monthLabels[i + 1]))),
              onChanged: (v) => setState(() => _selectedMonth = v ?? 1),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<int>(
              value: _selectedYear,
              items: List.generate(5, (i) {
                final y = DateTime.now().year - i;
                return DropdownMenuItem(value: y, child: Text('$y'));
              }),
              onChanged: (v) => setState(() => _selectedYear = v ?? 2026),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _fetchData,
          style: ElevatedButton.styleFrom(backgroundColor: AppThemeConstants.primaryBlue),
          child: const Text('Cari', style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }

  Widget _buildSummaryCards() {
    final netProfit = _reportData?['net_profit'] ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Laba Bersih: ${_formatRupiah(netProfit)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Masuk: ${_formatRupiah(_reportData?['total_income'])}', style: const TextStyle(color: AppThemeConstants.successGreen)),
                Text('Keluar: ${_formatRupiah(_reportData?['total_expense'])}', style: const TextStyle(color: AppThemeConstants.errorRed)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDailySection() {
    final transactions = _reportData?['daily_transactions'] as List<dynamic>? ?? [];
    final targetType = _selectedTab == 0 ? 'income' : 'expense';

    final List<String> availableCategories = ['Semua', ...transactions.where((t) => t['type'] == targetType).map((t) => t['category']?.toString() ?? 'Lainnya').toSet()];

    // Menggunakan variabel state lokal untuk menyaring data yang ditampilkan ke UI halaman depan
    final filteredList = transactions.where((t) {
      if (t['type'] != targetType) return false;
      if (_selectedCategory != 'Semua' && t['category'] != _selectedCategory) return false;
      if (_startDate != null && _endDate != null) {
        final txDate = DateTime.tryParse(t['date'] ?? '');
        if (txDate != null) {
          final normTx = DateTime(txDate.year, txDate.month, txDate.day);
          final normStart = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
          final normEnd = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
          if (normTx.isBefore(normStart) || normTx.isAfter(normEnd)) return false;
        }
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ChoiceChip(label: const Text('Pemasukan'), selected: _selectedTab == 0, onSelected: (b) => setState(() => _selectedTab = 0)),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('Pengeluaran'), selected: _selectedTab == 1, onSelected: (b) => setState(() => _selectedTab = 1)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.date_range), onPressed: _pickDateRange),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: availableCategories.contains(_selectedCategory) ? _selectedCategory : 'Semua',
          items: availableCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v ?? 'Semua'),
          decoration: const InputDecoration(labelText: 'Filter Kategori'),
        ),
        const SizedBox(height: 12),
        if (filteredList.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Tidak ada riwayat transaksi harian.')))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredList.length,
            itemBuilder: (context, i) {
              final tx = filteredList[i];
              return ListTile(
                title: Text(tx['description'] ?? '-'),
                subtitle: Text(tx['date']?.toString().split(' ')[0] ?? '-'),
                trailing: Text(_formatRupiah(tx['amount']), style: TextStyle(fontWeight: FontWeight.bold, color: _selectedTab == 0 ? AppThemeConstants.successGreen : AppThemeConstants.errorRed)),
              );
            },
          )
      ],
    );
  }
}
