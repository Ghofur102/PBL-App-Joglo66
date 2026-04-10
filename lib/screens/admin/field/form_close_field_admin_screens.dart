import 'package:flutter/material.dart';

import '../../../components/button.dart';

class FormTutupSementaraPage extends StatelessWidget {
  const FormTutupSementaraPage({super.key});

  Widget inputField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget textArea(String hint) {
    return TextField(
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget dateField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: const Icon(Icons.calendar_today),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF406093),
      appBar: AppBar(
        title: const Text(
          "Form Tutup Sementara Lapangan",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF406093),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.block, size: 50),
                    SizedBox(height: 8),
                    Text(
                      "Tutup Sementara Lapangan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "Tanggal Awal",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              dateField("Pilih tanggal mulai"),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: inputField("Jam Awal")),
                  const SizedBox(width: 10),
                  Expanded(child: inputField("Jam Akhir")),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                "Tanggal Akhir",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              dateField("Pilih tanggal selesai"),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: inputField("Jam Awal")),
                  const SizedBox(width: 10),
                  Expanded(child: inputField("Jam Akhir")),
                ],
              ),

              const SizedBox(height: 6),
              const Text(
                "Jika cuma satu hari, maka Tanggal akhir tidak usah di isi.",
                style: TextStyle(fontSize: 12),
              ),

              const SizedBox(height: 16),

              const Text(
                "Alasan Tutup",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              textArea(
                "Tulis alasan mengapa lapangan secara mendadak ditutup.",
              ),

              const SizedBox(height: 20),

              Center(
                child: Button(
                  label: "Simpan Perubahan",
                  onPressed: () {},
                  backgroundColor: const Color(0xFF406093),
                  textColor: Colors.white,
                  padding: 40.0,
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Button(
                  label: "Lihat Booking Tutup",
                  onPressed: () {},
                  backgroundColor: Colors.red,
                  textColor: Colors.black,
                  padding: 20.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
