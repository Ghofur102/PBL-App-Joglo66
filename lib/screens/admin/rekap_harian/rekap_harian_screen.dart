import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/services/rekap_service.dart';

// DEVELOPER: HUDA

// ─────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────

/// Merepresentasikan satu baris transaksi pembayaran yang dikombinasikan
/// dengan data booking dan booking_detail dari API.
class TransaksiHarian {
  final int id;
  final String namaCustomer; // dari bookings.team_name
  final String jenisTransaksi; // payments.payment_type
  final String status; // payments.status
  final int nominal; // payments.amount
  final DateTime? waktu; // payments.paid_at
  final String? referenceId; // payments.reference_id
  final String? fieldName; // dari relasi field

  const TransaksiHarian({
    required this.id,
    required this.namaCustomer,
    required this.jenisTransaksi,
    required this.status,
    required this.nominal,
    this.waktu,
    this.referenceId,
    this.fieldName,
  });

  factory TransaksiHarian.fromJson(Map<String, dynamic> json) {
    return TransaksiHarian(
      id: json['id'] as int,
      namaCustomer: json['team_name'] as String? ?? '-',
      jenisTransaksi: json['payment_type'] as String? ?? '-',
      status: json['status'] as String? ?? 'pending',
      nominal: (json['amount'] as num?)?.toInt() ?? 0,
      waktu: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'] as String)
          : null,
      referenceId: json['reference_id'] as String?,
      fieldName: json['field_name'] as String?,
    );
  }
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class RekapHarianScreen extends StatefulWidget {
  const RekapHarianScreen({super.key});

  @override
  State<RekapHarianScreen> createState() => _RekapHarianScreenState();
}

class _RekapHarianScreenState extends State<RekapHarianScreen> {
  // Logic UI: Menyediakan TextField kalender filter tanggal, memanggil RekapService.fetchDailyRekap,
  // menampilkan sirkular progress bar saat loading, dan menggambarkan data list rekap ke dalam widget ListView.

  DateTime _selectedDate = DateTime.now();
  String _activeFilter = 'Semua';
  bool _isLoading = false;
  String? _errorMessage;
  List<TransaksiHarian> _allTransaksi = [];

  static const _primaryBlue = Color(0xFF1B4F8A);
  static const _lightBlue = Color(0xFFE6F1FB);
  static const _lightGreen = Color(0xFFEAF3DE);
  static const _lightRed = Color(0xFFFCEBEB);
  static const _lightAmber = Color(0xFFFAEEDA);
  static const _textSecondary = Color(0xFF888780);
  static const _borderColor = Color(0xFFD3D1C7);

  final Map<String, String> _filterLabels = {
    'Semua': 'Semua',
    'down payment': 'DP',
    'final payment': 'Pelunasan',
    'dp hangus': 'Hangus',
    'attribute': 'Penyewaan Atribut',
  };

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
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final raw = await RekapService.fetchDailyTransaksi(dateStr);
      setState(() {
        _allTransaksi =
            raw.map((e) => TransaksiHarian.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<TransaksiHarian> get _filtered {
    if (_activeFilter == 'Semua') return _allTransaksi;
    return _allTransaksi
        .where((t) => t.jenisTransaksi == _activeFilter)
        .toList();
  }

  Map<String, List<TransaksiHarian>> get _grouped {
    final result = <String, List<TransaksiHarian>>{};
    for (final t in _filtered) {
      result.putIfAbsent(t.jenisTransaksi, () => []).add(t);
    }
    return result;
  }

  int _countByType(String type) =>
      _allTransaksi.where((t) => t.jenisTransaksi == type).length;

  // ── Date Picker ──────────────────────────────
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

  // ── Helpers ──────────────────────────────────
  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _formatTime(DateTime? d) {
    if (d == null) return '-';
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatRupiah(int amount) {
    final s = amount.toString();
    final buf = StringBuffer('Rp ');
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }

  String _groupLabel(String type) {
    switch (type) {
      case 'down payment':
        return 'Down Payment (DP)';
      case 'final payment':
        return 'Pelunasan';
      case 'dp hangus':
        return 'DP Hangus';
      case 'attribute':
        return 'Penyewaan Atribut';
      case 'reschedule fee':
        return 'Biaya Reschedule';
      case 'refund':
        return 'Refund';
      default:
        return type;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'down payment':
        return _primaryBlue;
      case 'final payment':
        return const Color(0xFF3B6D11);
      case 'dp hangus':
        return const Color(0xFFA32D2D);
      case 'attribute':
        return const Color(0xFF854F0B);
      default:
        return _textSecondary;
    }
  }

  Color _typeBg(String type) {
    switch (type) {
      case 'down payment':
        return _lightBlue;
      case 'final payment':
        return _lightGreen;
      case 'dp hangus':
        return _lightRed;
      case 'attribute':
        return _lightAmber;
      default:
        return const Color(0xFFF1EFE8);
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'down payment':
        return Icons.monetization_on_outlined;
      case 'final payment':
        return Icons.check_circle_outline;
      case 'dp hangus':
        return Icons.local_fire_department_outlined;
      case 'attribute':
        return Icons.style_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  String _avatarText(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

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

  // ── Top Bar ──────────────────────────────────
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Color(0xFFB5D4F4)),
                onPressed: () {/* TODO: search */},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error ────────────────────────────────────
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

  // ── Main Content ─────────────────────────────
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
                  ...entry.value.map(_buildTransaksiCard),
                  const SizedBox(height: 10),
                ]),
        ],
      ),
    );
  }

  // ── Filter Row (date + filter btn) ───────────
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
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: _textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF444441)),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 18, color: _textSecondary),
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
              Text('Filter',
                  style: TextStyle(
                      fontSize: 12,
                      color: _primaryBlue,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Chip Tabs ────────────────────────────────
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
                color: isActive ? _primaryBlue : _typeBg(e.key),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isActive
                      ? _primaryBlue
                      : _typeColor(e.key).withOpacity(0.4),
                ),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : _typeColor(e.key),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Group Label ───────────────────────────────
  Widget _buildGroupLabel(String type) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 0),
      child: Text(
        _groupLabel(type).toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Transaksi Card ────────────────────────────
  Widget _buildTransaksiCard(TransaksiHarian t) {
    final isHangus = t.jenisTransaksi == 'dp hangus';
    final color = _typeColor(t.jenisTransaksi);
    final bg = _typeBg(t.jenisTransaksi);

    return GestureDetector(
      onTap: () {/* TODO: navigate to DetailTransaksiScreen */},
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Center(
                child: t.jenisTransaksi == 'dp hangus'
                    ? Icon(_typeIcon(t.jenisTransaksi), size: 18, color: color)
                    : Text(
                        _avatarText(t.namaCustomer),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.namaCustomer,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C2C2A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.fieldName ?? '-',
                    style: const TextStyle(
                        fontSize: 11, color: _textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Nominal + waktu
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isHangus ? '- ' : ''}${_formatRupiah(t.nominal)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(t.waktu),
                  style: const TextStyle(fontSize: 10, color: _textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: const [
            Icon(Icons.receipt_long_outlined, size: 48, color: _textSecondary),
            SizedBox(height: 10),
            Text(
              'Tidak ada transaksi',
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}