import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pbl_app_joglo66/services/pdf_service.dart';

class PreviewPdfScreen extends StatefulWidget {
  const PreviewPdfScreen({super.key});

  @override
  State<PreviewPdfScreen> createState() => _PreviewPdfScreenState();
}

class _PreviewPdfScreenState extends State<PreviewPdfScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
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
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
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
      final data = await PdfService.fetchPdfPreview(_selectedMonth, _selectedYear);
      if (mounted) setState(() => _laporanData = data);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadPdf() async {
    final downloadUrl = _laporanData?['download_url'];

    if (downloadUrl == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL Download belum tersedia. Muat ulang halaman.')));
      return;
    }

    final uri = Uri.parse(downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka browser untuk mengunduh PDF.')));
      }
    }
  }

  String _formatRupiah(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final int val = (amount is num) ? amount.toInt() : int.tryParse(amount.toString()) ?? 0;
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp ${val.toString().replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(dateStr);
      return '${dt.day} ${_bulanLabels[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
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
                ? const Center(child: CircularProgressIndicator(color: _primaryBlue))
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
                  'Preview Laporan Bulanan',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
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
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF444441), fontSize: 13)),
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
          _buildFilterRow(),
          const SizedBox(height: 14),
          if (_laporanData != null) ...[
            _buildRingkasanCards(),
            const SizedBox(height: 10),
            _buildNeracaCard(),
            const SizedBox(height: 10),
            _buildExpenseBreakdown(),
            const SizedBox(height: 16),
            _buildDailyTransactions(),
            const SizedBox(height: 16),
            _buildUnduhButton(),
            const SizedBox(height: 16),
          ]
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
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
                icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _textSecondary),
                style: const TextStyle(fontSize: 13, color: Color(0xFF2C2C2A), fontWeight: FontWeight.w500),
                items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_bulanLabels[i + 1]))),
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
                icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _textSecondary),
                style: const TextStyle(fontSize: 13, color: Color(0xFF2C2C2A), fontWeight: FontWeight.w500),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tampilkan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildRingkasanCards() {
    final totalIncome = _laporanData?['total_income'];
    final totalExpense = _laporanData?['total_expense'];
    final netProfit = _laporanData?['net_profit'];
    final isProfit = netProfit == null ? true : (netProfit as num) >= 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                label: 'Total Pemasukan',
                value: _formatRupiah(totalIncome),
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
                value: _formatRupiah(totalExpense),
                icon: Icons.trending_down_rounded,
                iconBg: _lightRed,
                iconColor: const Color(0xFFA32D2D),
                valueColor: const Color(0xFFA32D2D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _summaryCard(
          label: 'Laba Bersih',
          value: _formatRupiah(netProfit),
          icon: isProfit ? Icons.account_balance_wallet_outlined : Icons.warning_amber_rounded,
          iconBg: isProfit ? _lightBlue : _lightAmber,
          iconColor: isProfit ? _primaryBlue : const Color(0xFF854F0B),
          valueColor: isProfit ? _primaryBlue : const Color(0xFF854F0B),
          fullWidth: true,
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
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
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
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: _textSecondary)),
                const SizedBox(height: 3),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeracaCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.receipt_long_outlined, size: 16, color: _primaryBlue),
              ),
              const SizedBox(width: 8),
              const Text('Neraca Keuangan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2C2C2A))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0xFF85B7EB)),
                ),
                child: Text(
                  '${_bulanLabels[_selectedMonth]} $_selectedYear',
                  style: const TextStyle(fontSize: 11, color: _primaryBlue, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _neracaRow('Total Pemasukan', _laporanData?['total_income'], isPositive: true),
          _neracaRow('Total Pengeluaran', _laporanData?['total_expense'], isPositive: false),
          const Divider(height: 20, color: Color(0xFFF1EFE8)),
          _neracaRow('Laba Bersih', _laporanData?['net_profit'], isBold: true),
          const SizedBox(height: 4),
          Text('Dibuat: ${_laporanData?['generate_at'] ?? '-'}', style: const TextStyle(fontSize: 11, color: _textSecondary)),
        ],
      ),
    );
  }

  Widget _neracaRow(String label, dynamic amount, {bool isPositive = true, bool isBold = false}) {
    final val = amount == null ? 0 : (amount as num).toInt();
    Color valColor = const Color(0xFF2C2C2A);
    if (isBold) {
      valColor = val >= 0 ? _primaryBlue : const Color(0xFFA32D2D);
    } else {
      valColor = isPositive ? const Color(0xFF3B6D11) : const Color(0xFFA32D2D);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isBold ? const Color(0xFF2C2C2A) : _textSecondary, fontWeight: isBold ? FontWeight.w600 : FontWeight.normal)),
          Text('${isPositive || isBold ? '' : '- '}${_formatRupiah(amount)}', style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w600 : FontWeight.w500, color: valColor)),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdown() {
    final expenses = _laporanData?['expenses'] as List<dynamic>? ?? [];

    if (expenses.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: _lightRed, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.pie_chart_outline, size: 16, color: Color(0xFFA32D2D)),
              ),
              const SizedBox(width: 8),
              const Text('Rincian Pengeluaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2C2C2A))),
            ],
          ),
          const SizedBox(height: 12),
          ...expenses.map((e) {
            final item = e as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: const Color(0xFFA32D2D).withOpacity(0.6), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item['category'] as String? ?? '-', style: const TextStyle(fontSize: 12, color: Color(0xFF2C2C2A)))),
                  Text(_formatRupiah(item['amount']), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFA32D2D))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailyTransactions() {
    final transactions = _laporanData?['daily_transactions'] as List<dynamic>? ?? [];

    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          children: const [
            Icon(Icons.receipt_long_outlined, size: 40, color: _textSecondary),
            SizedBox(height: 10),
            Text('Tidak ada riwayat transaksi.', style: TextStyle(color: _textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text('Daftar Transaksi Harian', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2A))),
        ),
        ...transactions.map((trx) {
          final item = trx as Map<String, dynamic>;
          final isIncome = item['type'] == 'income';
          final iconColor = isIncome ? const Color(0xFF3B6D11) : const Color(0xFFA32D2D);
          final iconBg = isIncome ? _lightGreen : _lightRed;
          final icon = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['description'] ?? '-', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2C2C2A))),
                      const SizedBox(height: 2),
                      Text(_formatDate(item['date']), style: const TextStyle(fontSize: 11, color: _textSecondary)),
                    ],
                  ),
                ),
                Text(
                  '${isIncome ? '+' : '-'}${_formatRupiah(item['amount'])}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: iconColor),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUnduhButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _laporanData == null ? null : _downloadPdf,
        icon: const Icon(Icons.download_outlined, size: 18),
        label: const Text('Download Laporan PDF', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _borderColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }
}
