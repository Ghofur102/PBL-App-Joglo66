import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/services/expense_field.dart';

class ListExpensePage extends StatefulWidget {
  const ListExpensePage({super.key});

  @override
  State<ListExpensePage> createState() => _ListExpensePageState();
}

class _ListExpensePageState extends State<ListExpensePage> {
  final TextEditingController searchController = TextEditingController();
  DateTimeRange? selectedDate;
  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> allExpenses = [];
  List<Map<String, dynamic>> filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final raw = await ExpenseService.getExpenses();
      final mapped = raw.map((e) {
        final d = e as Map<String, dynamic>;
        return {
          'id': d['id'] ?? d['expense_id'],
          'title': d['name'] ?? d['title'] ?? d['pengeluaran'] ?? '',
          'category': d['category'] ?? d['kategori'] ?? '',
          'amount': int.tryParse(d['amount']?.toString() ?? '0') ?? (d['amount'] is int ? d['amount'] as int : 0),
          'date': (d['date'] ?? d['tanggal'] ?? '').toString(),
          'note': (d['note'] ?? d['catatan'] ?? '').toString(),
          'proof': d['proof'] ?? false,
          'image': d['image'] ?? d['foto'],
        };
      }).toList();

      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (final item in mapped) {
        final dateRaw = (item['date'] ?? '').toString();
        final key = dateRaw.isEmpty ? 'Data Tanpa Tanggal' : dateRaw;
        grouped.putIfAbsent(key, () => []);
        grouped[key]!.add(item);
      }

      final groups = grouped.entries
          .map((entry) => {'date': entry.key, 'items': entry.value})
          .toList();

      setState(() {
        allExpenses = groups;
        filteredExpenses = groups;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
        allExpenses = [];
        filteredExpenses = [];
      });
    }
  }

  void searchExpense(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        filteredExpenses = allExpenses;
      });
      return;
    }

    final result = allExpenses
        .map((group) {
          final items = (group['items'] as List).where((item) {
            return item['title'].toString().toLowerCase().contains(keyword.toLowerCase());
          }).toList();
          return {"date": group['date'], "items": items};
        })
        .where((group) => (group['items'] as List).isNotEmpty)
        .toList();

    setState(() {
      filteredExpenses = result;
    });
  }

  int getTotalExpense() {
    int total = 0;
    for (var group in filteredExpenses) {
      for (var item in group['items']) {
        total += item['amount'] as int;
      }
    }
    return total;
  }

  int getDailyTotal(List items) {
    int total = 0;
    for (var item in items) {
      total += item['amount'] as int;
    }
    return total;
  }

  String _formatPrice(int? price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(price ?? 0);
  }

  DateTime? _parseExpenseDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    final parts = s.split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) return DateTime(y, m, d);
    }

    final dash = s.split('-');
    if (dash.length == 3) {
      final y = int.tryParse(dash[0]);
      final m = int.tryParse(dash[1]);
      final d = int.tryParse(dash[2]);
      if (d != null && m != null && y != null) return DateTime(y, m, d);
    }

    return DateTime.tryParse(s);
  }

  void filterByDateRange() {
    if (selectedDate == null) {
      filteredExpenses = allExpenses;
      return;
    }

    final start = DateTime(selectedDate!.start.year, selectedDate!.start.month, selectedDate!.start.day);
    final end = DateTime(selectedDate!.end.year, selectedDate!.end.month, selectedDate!.end.day);
    final result = <Map<String, dynamic>>[];

    for (final group in allExpenses) {
      final dateStr = (group['date'] ?? '').toString();
      final groupDate = _parseExpenseDate(dateStr);
      if (groupDate == null) continue;

      if (!groupDate.isBefore(start) && !groupDate.isAfter(end)) {
        result.add(group);
      }
    }
    filteredExpenses = result;
  }

  Future<void> pickDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (result != null) {
      setState(() {
        selectedDate = result;
        filterByDateRange();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Daftar Pengeluaran",
          style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await context.push('/admin/add-expense-field');
                if (result == true) {
                  _loadExpenses();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF406093),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Tambah", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
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
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: pickDateRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedDate == null
                                  ? "Pilih Filter Rentang Tanggal"
                                  : "${selectedDate!.start.day}/${selectedDate!.start.month}/${selectedDate!.start.year} - ${selectedDate!.end.day}/${selectedDate!.end.month}/${selectedDate!.end.year}",
                              style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: searchExpense,
                    decoration: InputDecoration(
                      hintText: "Cari pengeluaran...",
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
              child: Text(errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF406093),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFF406093).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Pengeluaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                    SizedBox(height: 4),
                    Text("Akumulasi rentang aktif pilihan", style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
                  ],
                ),
                Text(
                  _formatPrice(getTotalExpense()),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadExpenses,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final group = filteredExpenses[index];
                        final items = group['items'] as List;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(group['date'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                    Text("Total Hari Ini: ${_formatPrice(getDailyTotal(items))}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  children: List.generate(items.length, (i) {
                                    final item = items[i];
                                    final bool hasImage = item['proof'] == true && item['image'] != null;

                                    return InkWell(
                                      onTap: () async {
                                        await context.push('/admin/detail-expense-field', extra: item);
                                        _loadExpenses();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle),
                                              child: const Icon(Icons.arrow_outward_rounded, color: Color(0xFFEF4444), size: 20),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                                                  const SizedBox(height: 4),
                                                  Text(_formatPrice(item['amount']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    hasImage ? "Bukti Tersedia" : "Bukti Belum Ada",
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: hasImage ? Colors.green : Colors.red),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text("--- Semua Data Telah Ditampilkan ---", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}