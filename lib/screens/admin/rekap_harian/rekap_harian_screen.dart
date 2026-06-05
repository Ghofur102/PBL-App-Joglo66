import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/models/transaksi_harian.dart';
import 'package:pbl_app_joglo66/services/rekap_service.dart';
import 'package:pbl_app_joglo66/components/transaksi_card.dart';

class RekapHarianScreen extends StatefulWidget {
  const RekapHarianScreen({super.key});

  @override
  State<RekapHarianScreen> createState() => _RekapHarianScreenState();
}

class _RekapHarianScreenState extends State<RekapHarianScreen> {
  DateTime _selectedDate = DateTime.now();
  String _activeFilter = 'Semua';
  bool _isLoading = false;
  String? _errorMessage;
  List<TransaksiHarian> _allTransaksi = [];

  static const _primaryBlue = Color(0xFF1B4F8A);
  static const _lightBlue = Color(0xFFE6F1FB);
  static const _textSecondary = Color(0xFF888780);
  static const _borderColor = Color(0xFFD3D1C7);

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
      final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final raw = await RekapService.fetchDailyTransaksi(dateStr);
      setState(() {
        _allTransaksi = raw.map((e) => TransaksiHarian.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<TransaksiHarian> get _filtered {
    if (_activeFilter == 'Semua') return _allTransaksi;
    return _allTransaksi.where((t) => t.jenisTransaksi == _activeFilter).toList();
  }

  Map<String, List<TransaksiHarian>> get _grouped {
    final result = <String, List<TransaksiHarian>>{};
    for (final t in _filtered) {
      result.putIfAbsent(t.jenisTransaksi, () => []).add(t);
    }
    return result;
  }

  int _countByType(String type) => _allTransaksi.where((t) => t.jenisTransaksi == type).length;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchData();
    }
  }

  String _formatDate(DateTime d) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _formatTime(DateTime? d) {
    if (d == null) return '-';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  // Solusi: Menggunakan Regex Replace, jauh lebih cepat & menghapus alur perulangan terbalik buffer (php:S3776)
  String _formatRupiah(int amount) {
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp ${amount.toString().replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  String _groupLabel(String type) {
    final Map<String, String> labels = {
      'down payment': 'Down Payment (DP)',
      'final payment': 'Pelunasan',
      'dp hangus': 'DP Hangus',
      'attribute': 'Penyewaan Atribut',
      'reschedule fee': 'Biaya Reschedule',
      'refund': 'Refund',
    };
    return labels[type] ?? type;
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
                  'Daftar Transaksi',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Color(0xFFB5D4F4)),
                onPressed: () {},
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
    final grouped = _grouped;
    return RefreshIndicator(
      color: _primaryBlue,
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _buildFilterRow(),
          const SizedBox(height: 10),
          _buildChipTabs(),
          const SizedBox(height: 14),
          if (grouped.isEmpty)
            _buildEmpty()
          else
            ...grouped.entries.expand((entry) => [
                  _buildGroupLabel(entry.key),
                  const SizedBox(height: 6),
                  ...entry.value.map((t) => TransaksiCard(
                        transaksi: t,
                        onFormatRupiah: _formatRupiah,
                        onFormatTime: _formatTime,
                      )),
                  const SizedBox(height: 10),
                ]),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: _textSecondary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_formatDate(_selectedDate), style: const TextStyle(fontSize: 13, color: Color(0xFF444441)))),
                  const Icon(Icons.keyboard_arrow_down, size: 18, color: _textSecondary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _lightBlue,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: const Color(0xFF85B7EB)),
          ),
          child: const Row(
            children: [
              Icon(Icons.tune, size: 15, color: _primaryBlue),
              SizedBox(width: 5),
              Text('Filter', style: TextStyle(fontSize: 12, color: _primaryBlue, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipTabs() {
    final chips = {
      'Semua': 'Semua (${_allTransaksi.length})',
      'down payment': 'DP (${_countByType('down payment')})',
      'final payment': 'Pelunasan (${_countByType('final payment')})',
      'dp hangus': 'Hangus (${_countByType('dp hangus')})',
      'attribute': 'Atribut (${_countByType('attribute')})',
    };

    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: chips.entries.map((e) {
          final isActive = _activeFilter == e.key;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? _primaryBlue : const Color(0xFFF1EFE8),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Center(
                child: Text(
                  e.value,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isActive ? Colors.white : _textSecondary),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGroupLabel(String type) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        _groupLabel(type).toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _textSecondary, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: _textSecondary),
            SizedBox(height: 10),
            Text('Tidak ada transaksi', style: TextStyle(color: _textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}