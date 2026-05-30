import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/services/laporan_service.dart';

// DEVELOPER: HUDA

class LaporanBulananScreen extends StatefulWidget {
  const LaporanBulananScreen({super.key});
  @override
  State<LaporanBulananScreen> createState() => _LaporanBulananScreenState();
}

class _LaporanBulananScreenState extends State<LaporanBulananScreen> {
  // Logic UI: Menyediakan filter combo-box Bulan & Tahun, menggambar data total pemasukan,
  // pengeluaran operasional, pengeluaran gaji, dan laba bersih ke komponen Card UI modern.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Halaman Neraca Keuangan Bulanan - Huda")));
  }
}