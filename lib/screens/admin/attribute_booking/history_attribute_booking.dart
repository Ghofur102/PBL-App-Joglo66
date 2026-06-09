import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/services/attribute_booking.dart';

class HistoryAttributeBookingScreens extends StatefulWidget {
  const HistoryAttributeBookingScreens({super.key});

  @override
  State<HistoryAttributeBookingScreens> createState() => _HistoryAttributeBookingScreensState();
}

class _HistoryAttributeBookingScreensState extends State<HistoryAttributeBookingScreens> {
  List<Map<String, dynamic>> _rentals = [];
  bool isLoading = true;
  bool _isActionProcessing = false;
  String? errorMessage;

  final _searchController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  String? _selectedStatus;
  int? _totalRevenue;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await AttributeBookingService.fetchHistory(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        startDate: _startDateController.text.isNotEmpty ? _startDateController.text : null,
        endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
        status: _selectedStatus,
      );

      // --- LOGIKA PARSING PAGINASI YANG JAUH LEBIH AMAN ---
      List<Map<String, dynamic>> list = [];
      if (result.containsKey('data')) {
        // Jika backend mengirimkan objek Paginator Laravel
        if (result['data'] is List) {
          list = List<Map<String, dynamic>>.from(result['data']);
        }
      } else if (result is List) {
        list = List<Map<String, dynamic>>.from(result as Iterable<dynamic>);
      }

      int revenue = 0;
      for (final r in list) {
        final total = int.tryParse(r['total']?.toString() ?? '0') ?? 0;
        final status = r['status']?.toString().toLowerCase();

        // Pemasukan dihitung hanya untuk barang yang sukses disewa
        if (status == 'dikembalikan' || status == 'dipinjam' || status == 'terlambat') {
          revenue += total;
        }
      }

      if (mounted) {
        setState(() {
          _rentals = list;
          _totalRevenue = revenue;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString().replaceAll('Exception: ', '');
          isLoading = false;
        });
      }
    }
  }

  Future<void> _processReturnItem(int rentalId, String customerName, String itemName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Pengembalian', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin atribut "$itemName" yang disewa oleh "$customerName" sudah dikembalikan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, Kembalikan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionProcessing = true);
    try {
      await AttributeBookingService.returnItem(rentalId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atribut berhasil dikembalikan, stok otomatis bertambah.'), backgroundColor: Colors.green),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionProcessing = false);
    }
  }

  String _formatPrice(int? price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(price ?? 0);
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'dipinjam':
        return const Color(0xFF3B82F6);
      case 'dikembalikan':
        return const Color(0xFF10B981);
      case 'terlambat':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _statusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'dipinjam':
        return 'DIPINJAM';
      case 'dikembalikan':
        return 'DIKEMBALIKAN';
      case 'terlambat':
        return 'TERLAMBAT';
      default:
        return status?.toUpperCase() ?? '-';
    }
  }

  InputDecoration _filterInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Riwayat Penyewaan Atribut',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama penyewa...',
                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (_) => _loadData(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration: _filterInputDecoration('Dari tgl', Icons.calendar_today_outlined),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                            _loadData();
                          }
                        },
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('s/d', style: TextStyle(color: Colors.grey))),
                    Expanded(
                      child: TextField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: _filterInputDecoration('Sampai tgl', Icons.calendar_today_outlined),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                            _loadData();
                          }
                        },
                      ),
                    ),
                    if (_startDateController.text.isNotEmpty || _endDateController.text.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.red),
                        onPressed: () {
                          _startDateController.clear();
                          _endDateController.clear();
                          _loadData();
                        },
                      )
                    ]
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', null),
                      const SizedBox(width: 6),
                      _buildFilterChip('Dipinjam', 'dipinjam'),
                      const SizedBox(width: 6),
                      _buildFilterChip('Dikembalikan', 'dikembalikan'),
                      const SizedBox(width: 6),
                      _buildFilterChip('Terlambat', 'terlambat'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading || _isActionProcessing
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_totalRevenue != null && _rentals.isNotEmpty && _selectedStatus == null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF406093), Color(0xFF2B4366)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: const Color(0xFF406093).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Omset Atribut', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                                Text(_formatPrice(_totalRevenue), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        if (errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                            child: Text(errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                          ),
                        if (_rentals.isEmpty && errorMessage == null)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 80),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
                                  child: const Icon(Icons.receipt_long_rounded, size: 40, color: Color(0xFF94A3B8)),
                                ),
                                const SizedBox(height: 16),
                                const Text('Riwayat Kosong', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                const SizedBox(height: 4),
                                const Text('Tidak ada data penyewaan yang ditemukan.', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                        ..._rentals.map((item) => _buildCard(item)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isActive = _selectedStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedStatus = value);
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF406093) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Colors.white : const Color(0xFF475569)),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final int rentalId = int.tryParse(item['id']?.toString() ?? '0') ?? 0;
    final attr = item['attribute'] as Map<String, dynamic>?;
    final attrName = attr?['name']?.toString() ?? '-';
    final int qty = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
    final int total = int.tryParse(item['total']?.toString() ?? '0') ?? 0;
    final String status = item['status']?.toString() ?? 'dipinjam';
    final String customer = item['customer_name']?.toString() ?? '-';
    final String date = item['transaction_date']?.toString() ?? '-';
    final int duration = int.tryParse(item['duration_hours']?.toString() ?? '0') ?? 0;

    final statusLower = status.toLowerCase();
    final bool showReturnButton = statusLower == 'dipinjam' || statusLower == 'terlambat';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _statusColor(status).withOpacity(0.3)),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _statusColor(status), letterSpacing: 0.5),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatPrice(total),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Color(0xFFF1F5F9))),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Text(customer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.layers_outlined, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text('$attrName ($qty Pcs)', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text('$duration Jam', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
            if (showReturnButton) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _processReturnItem(rentalId, customer, attrName),
                  icon: const Icon(Icons.assignment_return_rounded, size: 16, color: Colors.white),
                  label: const Text('Kembalikan Atribut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}