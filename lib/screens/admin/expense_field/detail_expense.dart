import 'dart:io';

import 'package:flutter/material.dart';

class DetailExpensePage extends StatefulWidget {
  final Map<String, dynamic> expenseData;

  const DetailExpensePage({super.key, required this.expenseData});

  @override
  State<DetailExpensePage> createState() => _DetailExpensePageState();
}

class _DetailExpensePageState extends State<DetailExpensePage> {
  String formatCurrency(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void deleteExpense() async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Pengeluaran"),
          content: const Text("Apakah Anda yakin ingin menghapus data ini?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data pengeluaran berhasil dihapus")),
      );

      Navigator.pop(context);
    }
  }

  // void editExpense() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => EditExpensePage(expenseData: widget.expenseData),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final data = widget.expenseData;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade300,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: const Text(
          "Detail Pengeluaran",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade600,
                        child: const Icon(Icons.payments, color: Colors.white),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? "-",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              data['category'] ?? "Pengeluaran Operasional",
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "Rp. ${formatCurrency(data['amount'] ?? 0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: buildInfoColumn(
                          title: "Tanggal",
                          value: data['date'] ?? "27 Mei 2026",
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: buildInfoColumn(
                          title: "Status Bukti",
                          value: data['proof'] == true
                              ? "Tersedia"
                              : "Belum Ada",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: buildInfoColumn(
                          title: "Kategori",
                          value: data['category'] ?? "-",
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: buildInfoColumn(
                          title: "Nominal",
                          value: "Rp. ${formatCurrency(data['amount'] ?? 0)}",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.description_outlined),
                      SizedBox(width: 8),
                      Text(
                        "Detail Transaksi",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: buildInfoColumn(
                          title: "Nama Pengeluaran",
                          value: data['title'] ?? "-",
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: buildInfoColumn(
                          title: "Jenis",
                          value: data['category'] ?? "-",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: buildInfoColumn(
                          title: "Tanggal Input",
                          value: data['date'] ?? "-",
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: buildInfoColumn(
                          title: "Admin",
                          value: "Administrator",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  buildInfoColumn(
                    title: "Catatan Tambahan",
                    value: data['note'] ?? "Tidak ada catatan tambahan",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 8),
                      Text(
                        "Bukti Pembayaran",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          image: data['image'] != null
                              ? DecorationImage(
                                  image: FileImage(File(data['image'])),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: data['image'] == null
                            ? const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              )
                            : null,
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildInfoColumn(
                              title: "Status Upload",
                              value: data['proof'] == true
                                  ? "Bukti tersedia"
                                  : "Belum upload bukti",
                            ),

                            const SizedBox(height: 16),

                            buildInfoColumn(
                              title: "Tanggal Upload",
                              value: "27 Mei 2026",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                // Expanded(
                //   child: SizedBox(
                //     height: 46,
                //     child: ElevatedButton(
                //       onPressed: editExpense,
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.grey.shade500,
                //         foregroundColor: Colors.white,
                //         elevation: 0,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(14),
                //         ),
                //       ),
                //       child: const Text("Edit Pengeluaran"),
                //     ),
                //   ),
                // ),

                const SizedBox(width: 16),

                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: deleteExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Hapus Pengeluaran"),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildInfoColumn({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),

        const SizedBox(height: 6),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 6),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black38)),
          ),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
