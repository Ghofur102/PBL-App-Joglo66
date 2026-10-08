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

  // Category filter: single selection. 'all' = no filter
  String _selectedCategory = 'all';
  final Map<String, String> _categoryLabels = {
    'all': 'Semua Kategori',
    'pemasukan': 'Pemasukan',
    'pengeluaran': 'Pengeluaran',
    'penyewaan': 'Penyewaan',
    'lapangan': 'Lapangan',
  };

  // Fields (lapangan) loaded from API
  List<Map<String, dynamic>> _fields = [];
  String? _selectedFieldId;

  // Custom date range
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _fetchFields();
    _fetchReport();
  }

  Future<void> _fetchFields() async {
    try {
      final resp = await ApiClient.get(Uri.parse(ApiEndpoints.listField));
      final jsonData = json.decode(resp.body);
      final dataList = (jsonData is Map && jsonData['data'] is List)
          ? jsonData['data'] as List<dynamic>
          : <dynamic>[];
      final seenIds = <String>{};
      final fields = dataList.whereType<Map<String, dynamic>>().where((field) {
        final id =
            (field['id'] ?? field['field_id'] ?? field['uuid'] ?? field['uid'])
                ?.toString();
        return id != null && id.isNotEmpty && seenIds.add(id);
      }).toList();
      if (mounted) {
        setState(() {
          _fields = fields;
        });
      }
    } catch (_) {
      // ignore errors for fields list; not critical
    }
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final params = <String, String>{
        'bulan': _selectedMonth.toString(),
        'tahun': _selectedYear.toString(),
      };

      final uri = Uri.parse(
        ApiEndpoints.monthlyReport,
      ).replace(queryParameters: params);
      final response = await ApiClient.get(uri);
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 &&
          jsonData is Map<String, dynamic> &&
          (jsonData['success'] == true || jsonData.containsKey('data'))) {
        final dynamic reportData = jsonData.containsKey('data')
            ? jsonData['data']
            : jsonData;
        if (reportData is! Map<String, dynamic>) {
          throw const FormatException('Format data rekap laporan tidak valid.');
        }
        if (mounted) {
          setState(() {
            _reportData = reportData;
            _isLoading = false;
          });
        }
      } else {
        final message = jsonData is Map<String, dynamic>
            ? jsonData['message']
            : null;
        throw FormatException(
          message?.toString() ?? 'Gagal memuat rekap laporan.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e
              .toString()
              .replaceAll('FormatException: ', '')
              .replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _applyLocalFilter(VoidCallback update) {
    setState(() {
      update();
      if (_reportData != null) {
        _errorMessage = null;
        _isLoading = false;
      }
    });
  }

  String _formatRp(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  DateTime? _transactionDate(Map<String, dynamic> transaction) {
    final value =
        transaction['date'] ??
        transaction['transaction_date'] ??
        transaction['created_at'];
    if (value == null) return null;

    final text = value.toString();
    return DateTime.tryParse(text) ?? DateFormat('dd/MM/yyyy').tryParse(text);
  }

  bool _isRefund(Map<String, dynamic> transaction) {
    final type = (transaction['type'] ?? '').toString().toLowerCase();
    final paymentType = (transaction['payment_type'] ?? '')
        .toString()
        .toLowerCase();
    return type.contains('refund') || paymentType.contains('refund');
  }

  bool _isExpense(Map<String, dynamic> transaction) {
    if (_isRefund(transaction)) return false;

    final type = (transaction['type'] ?? '').toString().toLowerCase();
    final category = (transaction['category'] ?? '').toString().toLowerCase();
    final title = (transaction['title'] ?? '').toString().toLowerCase();
    return type.contains('expense') ||
        type.contains('pengeluaran') ||
        category.contains('pembelian') ||
        category.contains('gaji') ||
        category.contains('salary') ||
        title.contains('pembelian') ||
        title.contains('gaji') ||
        title.contains('salary');
  }

  bool _hasField(Map<String, dynamic> transaction) {
    final nestedField = transaction['field'];
    return transaction['field_id'] != null ||
        transaction['field_name'] != null ||
        (nestedField is Map && nestedField.isNotEmpty);
  }

  bool _matchesSelectedField(Map<String, dynamic> transaction) {
    if (_selectedFieldId == null) return true;

    final selectedField = _fields.firstWhere(
      (field) =>
          (field['id'] ?? field['field_id'] ?? field['uuid'] ?? field['uid'])
              ?.toString() ==
          _selectedFieldId,
      orElse: () => <String, dynamic>{},
    );
    final selectedName =
        (selectedField['name'] ?? selectedField['field_name'] ?? '')
            .toString()
            .toLowerCase();
    final nestedField = transaction['field'];
    final transactionFieldId =
        (transaction['field_id'] ??
                (nestedField is Map ? nestedField['id'] : null))
            ?.toString();
    final transactionFieldName =
        (transaction['field_name'] ??
                (nestedField is Map ? nestedField['name'] : null))
            .toString()
            .toLowerCase();

    return transactionFieldId == _selectedFieldId ||
        (selectedName.isNotEmpty && transactionFieldName == selectedName);
  }

  List<Map<String, dynamic>> _filteredTransactions(
    List<Map<String, dynamic>> transactions,
  ) {
    return transactions.where((transaction) {
      if (!_matchesSelectedField(transaction)) return false;

      final date = _transactionDate(transaction);
      if (_startDate != null && (date == null || date.isBefore(_startDate!))) {
        return false;
      }
      if (_endDate != null &&
          (date == null ||
              date.isAfter(
                DateTime(
                  _endDate!.year,
                  _endDate!.month,
                  _endDate!.day,
                  23,
                  59,
                  59,
                ),
              ))) {
        return false;
      }

      switch (_selectedCategory) {
        case 'pemasukan':
          return !_isRefund(transaction) && !_isExpense(transaction);
        case 'pengeluaran':
          return _isRefund(transaction) || _isExpense(transaction);
        case 'penyewaan':
          final searchText =
              '${transaction['type'] ?? ''} ${transaction['category'] ?? ''} '
                      '${transaction['title'] ?? ''}'
                  .toLowerCase();
          return searchText.contains('sewa') ||
              searchText.contains('rent') ||
              searchText.contains('booking');
        case 'lapangan':
          return _hasField(transaction);
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Rekap Laporan Keuangan',
          style: TextStyle(
            color: AppThemeConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppThemeConstants.textPrimary,
          ),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin/dashboard'),
        ),
      ),
      body: Column(
        children: [
          _buildFilterHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppThemeConstants.primaryBlue,
                    ),
                  )
                : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppThemeConstants.errorRed),
                    ),
                  )
                : _buildReportContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final columnCount = isCompact ? 2 : 3;
        final itemWidth =
            (constraints.maxWidth - (12 * (columnCount - 1))) / columnCount;
        final fullWidth = constraints.maxWidth;

        InputDecoration dropdownDecoration({String? hintText}) =>
            InputDecoration(
              hintText: hintText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            );

        final monthDropdown = DropdownButtonFormField<int>(
          value: _selectedMonth,
          isExpanded: true,
          decoration: dropdownDecoration(),
          items: List.generate(12, (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text(_months[index], overflow: TextOverflow.ellipsis),
            );
          }),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedMonth = val);
              _fetchReport();
            }
          },
        );

        final yearDropdown = DropdownButtonFormField<int>(
          value: _selectedYear,
          isExpanded: true,
          decoration: dropdownDecoration(),
          items: [2025, 2026, 2027, 2028, 2029, 2030].map((year) {
            return DropdownMenuItem(value: year, child: Text('$year'));
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedYear = val);
              _fetchReport();
            }
          },
        );

        final categoryDropdown = DropdownButtonFormField<String>(
          value: _selectedCategory,
          isExpanded: true,
          decoration: dropdownDecoration(),
          selectedItemBuilder: (context) => _categoryLabels.values
              .map(
                (label) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          items: _categoryLabels.entries
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              _applyLocalFilter(() => _selectedCategory = val);
            }
          },
        );

        final fieldDropdown = DropdownButtonFormField<String>(
          value: _selectedFieldId ?? '',
          isExpanded: true,
          decoration: dropdownDecoration(hintText: 'Pilih Lapangan'),
          selectedItemBuilder: (context) => [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Semua Lapangan', overflow: TextOverflow.ellipsis),
            ),
            ..._fields.map((field) {
              final name =
                  (field['name'] ?? field['field_name'] ?? field['title'] ?? '')
                      .toString();
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  name.isNotEmpty ? name : '-',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          items: [
            const DropdownMenuItem<String>(
              value: '',
              child: Text('Semua Lapangan'),
            ),
            ..._fields.map((field) {
              final name =
                  (field['name'] ?? field['field_name'] ?? field['title'] ?? '')
                      .toString();
              final id =
                  (field['id'] ??
                          field['field_id'] ??
                          field['uuid'] ??
                          field['uid'])
                      ?.toString();
              return DropdownMenuItem<String>(
                value: id ?? '',
                child: Text(
                  name.isNotEmpty ? name : (id ?? '-'),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: (val) {
            _applyLocalFilter(
              () => _selectedFieldId = val?.isEmpty == true ? null : val,
            );
          },
        );

        Widget dateFilter({
          required String label,
          required DateTime? value,
          required VoidCallback onTap,
        }) {
          return InkWell(
            onTap: onTap,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                value != null ? DateFormat('yyyy-MM-dd').format(value) : '-',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AppThemeConstants.borderGrey.withValues(alpha: 0.6),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: AppThemeConstants.accentBlue,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Filter laporan',
                      style: TextStyle(
                        color: AppThemeConstants.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _applyLocalFilter(() {
                        _selectedCategory = 'all';
                        _selectedFieldId = null;
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                    icon: const Icon(Icons.restart_alt_rounded, size: 17),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppThemeConstants.accentBlue,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(width: itemWidth, child: monthDropdown),
                  SizedBox(width: itemWidth, child: yearDropdown),
                  SizedBox(
                    width: isCompact ? fullWidth : itemWidth,
                    child: categoryDropdown,
                  ),
                  SizedBox(
                    width: isCompact ? fullWidth : itemWidth,
                    child: fieldDropdown,
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: dateFilter(
                      label: 'Dari',
                      value: _startDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              _startDate ??
                              DateTime(_selectedYear, _selectedMonth, 1),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          _applyLocalFilter(() => _startDate = picked);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: dateFilter(
                      label: 'Sampai',
                      value: _endDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              _endDate ??
                              DateTime(
                                _selectedYear,
                                _selectedMonth,
                                DateTime(
                                  _selectedYear,
                                  _selectedMonth + 1,
                                  0,
                                ).day,
                              ),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          _applyLocalFilter(() => _endDate = picked);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: isCompact ? fullWidth : 48,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: 'Muat ulang laporan',
                        icon: const Icon(
                          Icons.refresh,
                          color: AppThemeConstants.accentBlue,
                        ),
                        onPressed: _fetchReport,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportContent() {
    final summary = _reportData?['summary'] as Map<String, dynamic>? ?? {};
    final rawTransactions = _reportData?['transactions'];
    final transactions = rawTransactions is List
        ? rawTransactions.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    final filteredTransactions = _filteredTransactions(transactions);

    final hasLocalFilters =
        _selectedCategory != 'all' ||
        _selectedFieldId != null ||
        _startDate != null ||
        _endDate != null;
    final grossIncome = hasLocalFilters
        ? filteredTransactions
              .where(
                (transaction) =>
                    !_isRefund(transaction) && !_isExpense(transaction),
              )
              .fold<int>(
                0,
                (sum, transaction) => sum + _transactionAmount(transaction),
              )
        : int.tryParse(summary['gross_income']?.toString() ?? '0') ?? 0;
    final totalRefund = hasLocalFilters
        ? filteredTransactions
              .where(_isRefund)
              .fold<int>(
                0,
                (sum, transaction) => sum + _transactionAmount(transaction),
              )
        : int.tryParse(summary['total_refund']?.toString() ?? '0') ?? 0;
    final netIncome = hasLocalFilters
        ? grossIncome - totalRefund
        : int.tryParse(summary['net_income']?.toString() ?? '0') ?? 0;
    final totalExpense = hasLocalFilters
        ? filteredTransactions
              .where(_isExpense)
              .fold<int>(
                0,
                (sum, transaction) => sum + _transactionAmount(transaction),
              )
        : int.tryParse(summary['total_expense']?.toString() ?? '0') ?? 0;
    final netProfit = hasLocalFilters
        ? netIncome - totalExpense
        : int.tryParse(summary['net_profit']?.toString() ?? '0') ?? 0;

    return RefreshIndicator(
      onRefresh: _fetchReport,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(
            grossIncome,
            totalRefund,
            netIncome,
            totalExpense,
            netProfit,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rincian transaksi',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppThemeConstants.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Daftar aktivitas keuangan pada periode terpilih',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppThemeConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppThemeConstants.lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${filteredTransactions.length} transaksi',
                  style: const TextStyle(
                    color: AppThemeConstants.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (filteredTransactions.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppThemeConstants.borderGrey),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 38,
                    color: AppThemeConstants.textSecondary,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Belum ada transaksi',
                    style: TextStyle(
                      color: AppThemeConstants.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Coba ubah filter atau pilih periode lain.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppThemeConstants.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ...filteredTransactions.map((tx) => _buildTransactionCard(tx)),
        ],
      ),
    );
  }

  int _transactionAmount(Map<String, dynamic> transaction) {
    return int.tryParse(transaction['amount']?.toString() ?? '0') ?? 0;
  }

  Widget _buildSummaryCard(
    int gross,
    int refund,
    int netInc,
    int expense,
    int profit,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4F8A), Color(0xFF406093)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppThemeConstants.primaryBlue.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan keuangan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_months[_selectedMonth - 1]} $_selectedYear',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LABA BERSIH',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatRp(profit),
                    style: TextStyle(
                      color: profit >= 0
                          ? Colors.white
                          : const Color(0xFFFFD7D7),
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
            'Pemasukan kotor',
            _formatRp(gross),
            color: Colors.white,
          ),
          _buildSummaryRow(
            'Refund',
            '- ${_formatRp(refund)}',
            color: const Color(0xFFFFD7D7),
          ),
          _summaryDivider(),
          _buildSummaryRow(
            'Pemasukan bersih',
            _formatRp(netInc),
            color: Colors.white,
            isBold: true,
          ),
          _buildSummaryRow(
            'Total pengeluaran',
            '- ${_formatRp(expense)}',
            color: const Color(0xFFFFE2B8),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.22)),
  );

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize - 1,
              color: color == Colors.white
                  ? Colors.white.withValues(alpha: 0.78)
                  : color?.withValues(alpha: 0.88) ??
                        AppThemeConstants.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              color: color ?? AppThemeConstants.textPrimary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx) {
    final String type = tx['type']?.toString() ?? 'income';
    final bool isRefund = type == 'refund' || tx['payment_type'] == 'refund';
    final bool isExpense = type == 'expense';

    final int amount = int.tryParse(tx['amount']?.toString() ?? '0') ?? 0;
    final String title =
        tx['title']?.toString() ?? tx['category']?.toString() ?? '-';
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

    final fieldName = tx['field_name']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppThemeConstants.borderGrey.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: AppThemeConstants.textPrimary.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: cardColor, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeConstants.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: AppThemeConstants.textSecondary,
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppThemeConstants.textSecondary,
                        ),
                      ),
                      const Text(
                        '•',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppThemeConstants.textSecondary,
                        ),
                      ),
                      Text(
                        method,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppThemeConstants.textSecondary,
                        ),
                      ),
                      if (fieldName.isNotEmpty) ...[
                        const Text(
                          '•',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppThemeConstants.textSecondary,
                          ),
                        ),
                        Text(
                          fieldName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppThemeConstants.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$prefix${_formatRp(amount)}',
                      style: TextStyle(
                        color: cardColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 8,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w800,
                        color: cardColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
