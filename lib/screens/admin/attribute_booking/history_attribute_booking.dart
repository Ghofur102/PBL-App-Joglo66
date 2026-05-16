import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/services/attribute_booking.dart';

class HistoryAttributeBookingScreens extends StatefulWidget {
  const HistoryAttributeBookingScreens({super.key});

  @override
  State<HistoryAttributeBookingScreens> createState() =>
      _HistoryAttributeBookingScreensState();
}

class _HistoryAttributeBookingScreensState
    extends State<HistoryAttributeBookingScreens> {
  List<Map<String, dynamic>> _rentals = [];
  bool isLoading = true;
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
        search: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        startDate:
            _startDateController.text.isNotEmpty ? _startDateController.text : null,
        endDate:
            _endDateController.text.isNotEmpty ? _endDateController.text : null,
        status: _selectedStatus,
      );

      final rawData = result['data'] ?? [];
      final List<Map<String, dynamic>> list =
          (rawData is List) ? rawData.map((e) => e as Map<String, dynamic>).toList() : [];

      int revenue = 0;
      for (final r in list) {
        final total = r['total'] is int
            ? r['total'] as int
            : int.tryParse(r['total']?.toString() ?? '0') ?? 0;
        revenue += total;
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

  String _formatPrice(int? price) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(price ?? 0);
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'dipinjam':
        return Colors.blue;
      case 'dikembalikan':
        return Colors.green;
      case 'terlambat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'dipinjam':
        return 'Dipinjam';
      case 'dikembalikan':
        return 'Dikembalikan';
      case 'terlambat':
        return 'Terlambat';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Riwayat Penyewaan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari penyewa...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (_) => _loadData(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Dari tgl',
                          prefixIcon:
                              const Icon(Icons.date_range, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            _startDateController.text =
                                DateFormat('yyyy-MM-dd').format(picked);
                            _loadData();
                          }
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('-'),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Sampai tgl',
                          prefixIcon:
                              const Icon(Icons.date_range, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            _endDateController.text =
                                DateFormat('yyyy-MM-dd').format(picked);
                            _loadData();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFilterChip('Semua', null),
                    const SizedBox(width: 8),
                    _buildFilterChip('Dipinjam', 'dipinjam'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Dikembalikan', 'dikembalikan'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Terlambat', 'terlambat'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_totalRevenue != null && _rentals.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF406093), Color(0xFF5A7BB5)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Pendapatan Atribut',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _formatPrice(_totalRevenue),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(errorMessage!,
                                    style:
                                        const TextStyle(fontSize: 12)),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _loadData,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        if (_rentals.isEmpty && errorMessage == null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long,
                                      size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada transaksi penyewaan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF406093) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final attr = item['attribute'] as Map<String, dynamic>?;
    final attrName = attr?['name']?.toString() ?? '-';
    final qty = item['quantity'] is int
        ? item['quantity'] as int
        : int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
    final total = item['total'] is int
        ? item['total'] as int
        : int.tryParse(item['total']?.toString() ?? '0') ?? 0;
    final status = item['status']?.toString() ?? '';
    final customer = item['customer_name']?.toString() ?? '-';
    final date = item['transaction_date']?.toString() ?? '';
    final duration = item['duration_hours'] is int
        ? item['duration_hours'] as int
        : int.tryParse(item['duration_hours']?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: _statusColor(status).withOpacity(0.5)),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _statusColor(status),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatPrice(total),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(customer,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.sports_tennis, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$attrName x$qty',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$duration jam',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            if (date.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(date,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
