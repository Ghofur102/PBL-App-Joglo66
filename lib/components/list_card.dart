import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final String date;
  final String year;
  final String title;
  final String time;
  final VoidCallback onTap;

  const ListCard({
    super.key,
    required this.date,
    required this.year,
    required this.title,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50), // Memberikan efek ripple yang melengkung
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade400, // Warna garis luar
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(50), // Bentuk kapsul
          ),
          child: Row(
            children: [
              // 1. Bagian Kiri: Tanggal & Tahun
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    year,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 50), // Jarak pemisah

              // 2. Bagian Tengah: Judul & Waktu (Menggunakan Expanded agar memenuhi ruang)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Mencegah teks meluap jika terlalu panjang
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFFE57373), // Warna merah muda/salmon mirip gambar
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Bagian Kanan: Ikon Chevron
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.black87,
                size: 42,
              ),
            ],
          ),
        ),
      ),
    );
  }
}