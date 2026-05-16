import 'package:flutter/material.dart';

import '../../../services/expense_field.dart';
import 'add_expense.dart';
import 'detail_expense.dart';

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

  // hasil dari API
  List<Map<String, dynamic>> allExpenses = [];
  List<Map<String, dynamic>> filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final raw = await ExpenseService.getExpenses();

      // Bentuk API tidak kita ketahui persis, jadi kita normalisasikan.
      // Ekspektasi: List<dynamic> berisi expense objects dengan key seperti:
      // id, name/title, category, nominal/amount, date/tanggal, note/catatan, proof, image
      final mapped = raw.map((e) {
        final d = e as Map<String, dynamic>;
        return {
          'id': d['id'] ?? d['expense_id'],
          'title': d['name'] ?? d['title'] ?? d['pengeluaran'] ?? '',
          'category': d['category'] ?? d['kategori'] ?? '',
          'amount': d['nominal'] ?? d['amount'] ?? 0,
          'date': (d['date'] ?? d['tanggal'] ?? '').toString(),
          'note': (d['note'] ?? d['catatan'] ?? '').toString(),
          'proof': d['proof'] ?? false,
          'image': d['image'] ?? d['foto'],
        };
      }).toList();

      // Grouping per tanggal agar sesuai UI list per hari.
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

      // Debug: cek data tanggal yang diterima dari API
      for (final g in groups) {
        debugPrint(
          '[Expense][group] date=${g['date']} count=${(g['items'] as List).length}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
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
            return item['title'].toString().toLowerCase().contains(
              keyword.toLowerCase(),
            );
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

  String formatCurrency(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  DateTime? _parseExpenseDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    // Format yang paling sering muncul: dd/MM/yyyy
    final parts = s.split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }

    // Cadangan: yyyy-MM-dd
    final dash = s.split('-');
    if (dash.length == 3) {
      final y = int.tryParse(dash[0]);
      final m = int.tryParse(dash[1]);
      final d = int.tryParse(dash[2]);
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }

    return DateTime.tryParse(s);
  }

  void filterByDateRange() {
    if (selectedDate == null) {
      filteredExpenses = allExpenses;
      return;
    }

    final start = DateTime(
      selectedDate!.start.year,
      selectedDate!.start.month,
      selectedDate!.start.day,
    );
    final end = DateTime(
      selectedDate!.end.year,
      selectedDate!.end.month,
      selectedDate!.end.day,
    );

    final result = <Map<String, dynamic>>[];

    for (final group in allExpenses) {
      final dateStr = (group['date'] ?? '').toString();
      final groupDate = _parseExpenseDate(dateStr);
      if (groupDate == null) continue;

      final inRange = !groupDate.isBefore(start) && !groupDate.isAfter(end);

      if (inRange) {
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
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: const Text(
          "Daftar Pengeluaran",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddExpensePage()),
                );

                if (!mounted) return;
                if (result == true) {
                  await _loadExpenses();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Tambah"),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: pickDateRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedDate == null
                                  ? "20 Mei 2026 - 27 Mei 2026"
                                  : "${selectedDate!.start.day}/${selectedDate!.start.month}/${selectedDate!.start.year} - ${selectedDate!.end.day}/${selectedDate!.end.month}/${selectedDate!.end.year}",
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: searchExpense,
                    decoration: InputDecoration(
                      hintText: "Cari Pengeluaran . . .",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffE8E3E3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Pengeluaran",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Periode 20 - 27 Mei 2026",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  "Rp. ${formatCurrency(getTotalExpense())}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                final group = filteredExpenses[index];
                final items = group['items'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              group['date'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Total : Rp. ${formatCurrency(getDailyTotal(items))}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: List.generate(items.length, (i) {
                            final item = items[i];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailExpensePage(expenseData: item),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey.shade500,
                                      child: const Icon(
                                        Icons.receipt_long,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Rp. ${formatCurrency(item['amount'])}",
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['proof']
                                                ? "Bukti tersedia"
                                                : "Bukti belum ada",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: item['proof']
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Icon(Icons.chevron_right),
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

          const Padding(
            padding: EdgeInsets.only(bottom: 18),
            child: Text(
              "--- Semua Data Telah Ditampilkan ---",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
