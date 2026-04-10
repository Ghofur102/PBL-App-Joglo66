import 'package:flutter/material.dart';

class ListBookingTutupPage extends StatelessWidget {
  const ListBookingTutupPage({super.key});

  Widget bookingItem({
    required String tanggal,
    required String nama,
    String? jam,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          // Tanggal
          Column(
            children: [Text(tanggal, style: const TextStyle(fontSize: 12))],
          ),
          const SizedBox(width: 12),

          // Isi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (jam != null)
                  Text(jam, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF406093),
      appBar: AppBar(
        title: const Text(
          "List Booking Tutup",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF406093),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.list_alt, size: 50),
              const SizedBox(height: 12),

              // Tab
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          "Perlu Tindakan",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(child: Text("Riwayat")),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // List
              Expanded(
                child: ListView(
                  children: [
                    bookingItem(
                      tanggal: "06 Mar 2026",
                      nama: "Putra Zeus (Danil)",
                      jam: "13.00 - 15.00",
                    ),
                    bookingItem(
                      tanggal: "06 Mar 2026",
                      nama: "Putra Zeus (Danil)",
                      jam: "13.00 - 15.00",
                    ),
                    bookingItem(
                      tanggal: "06 Mar 2026",
                      nama: "Putra Zeus (Danil)",
                    ),
                    bookingItem(
                      tanggal: "06 Mar 2026",
                      nama: "Putra Zeus (Danil)",
                      jam: "13.00 - 15.00",
                    ),
                    bookingItem(
                      tanggal: "06 Mar 2026",
                      nama: "Putra Zeus (Danil)",
                      jam: "13.00 - 15.00",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
