import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/services/laporan_service.dart';

class LaporanBulananScreen extends StatefulWidget {
  const LaporanBulananScreen({super.key});

  @override
  State<LaporanBulananScreen> createState() => _LaporanBulananScreenState();
}

class _LaporanBulananScreenState extends State<LaporanBulananScreen> {
  // State API Fetch (Global)
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // State Filter Lokal (UI Only)
  int _selectedTab = 0; // 0 = Pemasukan, 1 = Pengeluaran
  String _selectedCategory = 'Semua';
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _laporanData;

  static const _primaryBlue = Color(0xFF1B4F8A);
  static const _lightBlue = Color(0xFFE6F1FB);
  static const _lightGreen = Color(0xFFEAF3DE);
  static const _lightRed = Color(0xFFFCEBEB);
  static const _lightAmber = Color(0xFFFAEEDA);
  static const _textSecondary = Color(0xFF888780);
  static const _borderColor = Color(0xFFD3D1C7);

  static const _bulanLabels = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

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
      final data = await LaporanService.fetchMonthlyLaporan(
        _selectedMonth,
        _selectedYear,
      );
      setState(() {
        _laporanData = data;
        // Reset filter lokal setiap kali mengambil data bulan baru
        _selectedCategory = 'Semua';
        _startDate = null;
        _endDate = null;
      });
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatRupiah(dynamic amount) {
    if (amount == null) return 'Rp 0';

    final int val = (amount is num)
        ? amount.toInt()
        : int.tryParse(amount.toString()) ?? 0;
    final int absVal = val.abs();
    final String sign = val < 0 ? '-' : '';

    if (absVal >= 1000000000000) {
      double triliun = val / 1000000000000;
      return '${sign}Rp ${triliun.toStringAsFixed(triliun % 1 == 0 ? 0 : 1).replaceAll('.', ',')} Triliun';
    } else if (absVal >= 1000000000) {
      double miliar = val / 1000000000;
      return '${sign}Rp ${miliar.toStringAsFixed(miliar % 1 == 0 ? 0 : 1).replaceAll('.', ',')} Miliar';
    } else if (absVal >= 1000000) {
      double juta = val / 1000000;
      return '${sign}Rp ${juta.toStringAsFixed(juta % 1 == 0 ? 0 : 1).replaceAll('.', ',')} Juta';
    }

    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '${sign}Rp ${absVal.toString().replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  String _formatDateOnly(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(dateStr);
      return '${dt.day} ${_bulanLabels[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr.split(' ')[0];
    }
  }

  String _formatTimeOnly(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime dt = DateTime.parse(dateStr);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _pickDateRange() async {
    // Membatasi kalender hanya pada bulan yang sedang aktif
    final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
    final lastDayOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: firstDayOfMonth,
      lastDate: lastDayOfMonth,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _primaryBlue),
                  )
                : _errorMessage != null
                ? _buildError()
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: _primaryBlue,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFB5D4F4)),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Laporan Keuangan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFA32D2D), size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF444441), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: TextButton.styleFrom(foregroundColor: _primaryBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      color: _primaryBlue,
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _buildFilterBulanRow(),
          const SizedBox(height: 14),
          _buildRingkasanCards(),
          const SizedBox(height: 10),
          _buildRincianPemasukanCard(),
          const SizedBox(height: 10),
          _buildRincianPengeluaranCard(),
          const SizedBox(height: 24),
          _buildDailyTransactionsSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterBulanRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedMonth,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: _textSecondary,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2C2C2A),
                  fontWeight: FontWeight.w500,
                ),
                items: List.generate(
                  12,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(_bulanLabels[i + 1]),
                  ),
                ),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMonth = val);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedYear,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: _textSecondary,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2C2C2A),
                  fontWeight: FontWeight.w500,
                ),
                items: List.generate(5, (i) {
                  final y = DateTime.now().year - i;
                  return DropdownMenuItem(value: y, child: Text('$y'));
                }),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedYear = val);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _fetchData,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Tampilkan',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRingkasanCards() {
    final netProfit = _laporanData?['net_profit'];
    final isProfit = netProfit == null ? true : (netProfit as num) >= 0;

    return Column(
      children: [
        _summaryCard(
          label: 'Laba Bersih Bulan Ini',
          value: _formatRupiah(netProfit),
          icon: isProfit
              ? Icons.account_balance_wallet_outlined
              : Icons.warning_amber_rounded,
          iconBg: isProfit ? _lightBlue : _lightAmber,
          iconColor: isProfit ? _primaryBlue : const Color(0xFF854F0B),
          valueColor: isProfit ? _primaryBlue : const Color(0xFF854F0B),
          fullWidth: true,
          isLarge: true,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                label: 'Total Pemasukan',
                value: _formatRupiah(_laporanData?['total_income']),
                icon: Icons.trending_up_rounded,
                iconBg: _lightGreen,
                iconColor: const Color(0xFF3B6D11),
                valueColor: const Color(0xFF3B6D11),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _summaryCard(
                label: 'Total Pengeluaran',
                value: _formatRupiah(_laporanData?['total_expense']),
                icon: Icons.trending_down_rounded,
                iconBg: _lightRed,
                iconColor: const Color(0xFFA32D2D),
                valueColor: const Color(0xFFA32D2D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color valueColor,
    bool fullWidth = false,
    bool isLarge = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(isLarge ? 18 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: isLarge ? 42 : 36,
            height: isLarge ? 42 : 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: isLarge ? 22 : 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: _textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isLarge ? 18 : 14,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRincianPemasukanCard() {
    final incomeDetails = _laporanData?['details']?['income'] ?? {};

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribusi Pemasukan Lapangan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2A),
            ),
          ),
          const SizedBox(height: 12),
          _detailRow(
            'Uang Muka (DP)',
            incomeDetails['down_payment'],
            Colors.blue,
          ),
          _detailRow(
            'Pelunasan (Selesai)',
            incomeDetails['final_payment'],
            Colors.green,
          ),
          _detailRow(
            'DP Hangus (Batal)',
            incomeDetails['forsaken_downpayment'],
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildRincianPengeluaranCard() {
    final expenseDetails = _laporanData?['details']?['expense'] ?? {};
    final customExpenses = _laporanData?['expenses'] as List<dynamic>? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribusi Pengeluaran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2A),
            ),
          ),
          const SizedBox(height: 12),
          _detailRow(
            'Total Gaji Karyawan',
            expenseDetails['salary'],
            Colors.purple,
          ),
          const Divider(height: 24, color: Color(0xFFF1EFE8)),
          const Text(
            'Rincian Operasional:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (customExpenses.isEmpty)
            const Text(
              'Tidak ada pengeluaran operasional bulan ini.',
              style: TextStyle(fontSize: 12, color: _textSecondary),
            ),
          ...customExpenses.map((e) {
            final item = e as Map<String, dynamic>;
            return _detailRow(
              item['category'] as String? ?? '-',
              item['amount'],
              const Color(0xFFA32D2D),
            );
          }),
        ],
      ),
    );
  }

  Widget _detailRow(String label, dynamic amount, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF444441)),
            ),
          ),
          Text(
            _formatRupiah(amount),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2A),
            ),
          ),
        ],
      ),
    );
  }

  // --- BAGIAN TAB & FILTER TRANSAKSI HARIAN ---

  Widget _buildDailyTransactionsSection() {
    final transactions =
        _laporanData?['daily_transactions'] as List<dynamic>? ?? [];
    final targetType = _selectedTab == 0 ? 'income' : 'expense';

    // Ekstraksi kategori unik berdasarkan tab
    final availableCategories = transactions
        .where((t) => t['type'] == targetType)
        .map((t) => t['category']?.toString() ?? 'Lainnya')
        .toSet()
        .toList();
    availableCategories.insert(0, 'Semua');

    if (!availableCategories.contains(_selectedCategory)) {
      _selectedCategory = 'Semua';
    }

    // Algoritma Filtering Lokal (Tab, Kategori, & Rentang Tanggal)
    final filteredTxs = transactions.where((t) {
      if (t['type'] != targetType) return false;
      if (_selectedCategory != 'Semua' && t['category'] != _selectedCategory)
        return false;

      if (_startDate != null && _endDate != null) {
        try {
          final txDate = DateTime.parse(t['date']);
          final normalizedTx = DateTime(txDate.year, txDate.month, txDate.day);
          final normalizedStart = DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
          );
          final normalizedEnd = DateTime(
            _endDate!.year,
            _endDate!.month,
            _endDate!.day,
          );

          if (normalizedTx.isBefore(normalizedStart) ||
              normalizedTx.isAfter(normalizedEnd)) {
            return false;
          }
        } catch (_) {}
      }
      return true;
    }).toList();

    // Grouping berdasarkan tanggal
    final Map<String, List<dynamic>> groupedTxs = {};
    for (var tx in filteredTxs) {
      final dateKey = _formatDateOnly(tx['date']);
      if (!groupedTxs.containsKey(dateKey)) {
        groupedTxs[dateKey] = [];
      }
      groupedTxs[dateKey]!.add(tx);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Transaksi Harian',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2A),
          ),
        ),
        const SizedBox(height: 12),

        // Custom Tab Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  'Pemasukan',
                  0,
                  _lightGreen,
                  const Color(0xFF3B6D11),
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  'Pengeluaran',
                  1,
                  _lightRed,
                  const Color(0xFFA32D2D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Baris Filter Lokal (Rentang Tanggal & Kategori)
        Row(
          children: [
            _buildDateRangeButton(),
            if (availableCategories.length > 1) ...[
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.filter_list,
                        size: 16,
                        color: _primaryBlue,
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2C2C2A),
                        fontWeight: FontWeight.w600,
                      ),
                      items: availableCategories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null)
                          setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // Rendering Transaksi Grouped
        if (groupedTxs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  _selectedTab == 0
                      ? Icons.account_balance_wallet_outlined
                      : Icons.receipt_long_outlined,
                  size: 40,
                  color: _textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tidak ada riwayat ${_selectedTab == 0 ? "pemasukan" : "pengeluaran"}.',
                  style: const TextStyle(color: _textSecondary, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...groupedTxs.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 12, bottom: 8),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _primaryBlue,
                    ),
                  ),
                ),
                ...entry.value.map((tx) {
                  final item = tx as Map<String, dynamic>;
                  final isIncome = item['type'] == 'income';
                  final iconColor = isIncome
                      ? const Color(0xFF3B6D11)
                      : const Color(0xFFA32D2D);
                  final iconBg = isIncome ? _lightGreen : _lightRed;
                  final icon = isIncome
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: iconBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 18, color: iconColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['description'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C2C2A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item['category']} • ${_formatTimeOnly(item['date'])}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isIncome ? '+' : '-'}${_formatRupiah(item['amount'])}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildTabButton(
    String title,
    int tabIndex,
    Color activeBg,
    Color activeText,
  ) {
    final isActive = _selectedTab == tabIndex;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? activeText : _textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeButton() {
    String dateText = 'Pilih Tanggal';
    if (_startDate != null && _endDate != null) {
      if (_startDate == _endDate) {
        dateText = '${_startDate!.day} ${_bulanLabels[_startDate!.month]}';
      } else {
        dateText =
            '${_startDate!.day} - ${_endDate!.day} ${_bulanLabels[_endDate!.month]}';
      }
    }

    return Expanded(
      flex: 3,
      child: InkWell(
        onTap: _pickDateRange,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            children: [
              const Icon(Icons.date_range, size: 16, color: _primaryBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2C2C2A),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_startDate != null)
                GestureDetector(
                  onTap: () => setState(() {
                    _startDate = null;
                    _endDate = null;
                  }),
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
