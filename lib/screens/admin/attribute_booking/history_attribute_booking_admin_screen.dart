import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/status_badge.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/attribute_booking_service.dart';

class HistoryAttributeBookingAdminScreen extends StatefulWidget {
  const HistoryAttributeBookingAdminScreen({super.key});

  @override
  State<HistoryAttributeBookingAdminScreen> createState() => _HistoryAttributeBookingAdminScreenState();
}

class _HistoryAttributeBookingAdminScreenState extends State<HistoryAttributeBookingAdminScreen> {
  List<Map<String, dynamic>> _rentals = [];
  bool _isLoading = true;
  bool _isActionProcessing = false;
  String? _errorMessage;
  int? _totalRevenue;

  final _searchController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  String? _selectedStatus;

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
        _isLoading = true;
        _errorMessage = null;
      });

      final dynamic result = await AttributeBookingService.fetchHistory(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        startDate: _startDateController.text.isNotEmpty ? _startDateController.text : null,
        endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
        status: _selectedStatus,
      );

      List<Map<String, dynamic>> list = [];
      if (result is Map && result.containsKey('data') && result['data'] is List) {
        list = List<Map<String, dynamic>>.from(result['data']);
      } else if (result is List) {
        list = List<Map<String, dynamic>>.from(result);
      }

      int revenue = 0;
      for (final r in list) {
        final total = int.tryParse(r['total']?.toString() ?? '0') ?? 0;
        final status = r['status']?.toString().toLowerCase() ?? '';
        if (['dikembalikan', 'dipinjam', 'terlambat'].contains(status)) {
          revenue += total;
        }
      }

      if (mounted) {
        setState(() {
          _rentals = list;
          _totalRevenue = revenue;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processReturnItem(int rentalId, String customerName, String itemName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pengembalian'),
        content: Text('Apakah Anda yakin atribut "$itemName" yang disewa oleh "$customerName" sudah dikembalikan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya, Kembalikan')),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed));
      }
    } finally {
      if (mounted) setState(() => _isActionProcessing = false);
    }
  }

  InputDecoration _filterInputDecoration(String hint, IconData icon) {
    final decoration = InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
    return decoration;
  }

  @override
  Widget build(BuildContext context) {
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
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
      ),
      body: Column(
        children: [
          _buildFilterHeaderSection(),
          Expanded(
            child: _isLoading || _isActionProcessing
                ? const Center(child: CircularProgressIndicator())
                : _buildHistoryListView(formatRp),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeaderSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(hintText: 'Cari nama penyewa...', prefixIcon: Icon(Icons.search)),
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
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2025), lastDate: DateTime(2030));
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
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2025), lastDate: DateTime(2030));
                    if (picked != null) {
                      _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                      _loadData();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFilterChip('Semua', null),
              _buildFilterChip('Dipinjam', 'dipinjam'),
              _buildFilterChip('Dikembalikan', 'dikembalikan'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isActive = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: (b) {
        setState(() => _selectedStatus = value);
        _loadData();
      },
    );
  }

  Widget _buildHistoryListView(NumberFormat formatRp) {
    if (_errorMessage != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: const TextStyle(color: AppThemeConstants.errorRed))));
    }

    if (_rentals.isEmpty) return const Center(child: Text('Riwayat data penyewaan kosong.'));

    return ListView.builder(
      itemCount: _rentals.length + 1,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, idx) {
        if (idx == 0) {
          return _totalRevenue != null && _selectedStatus == null
              ? Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AppThemeConstants.primaryBlue, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Omset Atribut', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(formatRp.format(_totalRevenue), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                )
              : const SizedBox.shrink();
        }

        final item = _rentals[idx - 1];
        final String status = item['status']?.toString() ?? 'dipinjam';
        final bool canReturn = ['dipinjam', 'terlambat'].contains(status.toLowerCase());

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['customer_name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                    StatusBadge(status: status),
                  ],
                ),
                const Divider(),
                Text('Total: ${formatRp.format(item['total'] ?? 0)}'),
                if (canReturn) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _processReturnItem(item['id'], item['customer_name'], item['attribute']?['name'] ?? ''),
                    style: ElevatedButton.styleFrom(backgroundColor: AppThemeConstants.successGreen),
                    child: const Text('Kembalikan Atribut', style: TextStyle(color: Colors.white)),
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
