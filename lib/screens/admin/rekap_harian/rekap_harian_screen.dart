import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/services/rekap_service.dart';

// DEVELOPER: HUDA

class RekapHarianScreen extends StatefulWidget {
  const RekapHarianScreen({super.key});
  @override
  State<RekapHarianScreen> createState() => _RekapHarianScreenState();
}

class _RekapHarianScreenState extends State<RekapHarianScreen> {
  // Logic UI: Menyediakan TextField kalender filter tanggal, memanggil RekapService.fetchDailyRekap,
  // menampilkan sirkular progress bar saat loading, dan menggambarkan data list rekap ke dalam widget ListView.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Halaman Rekap Transaksi Harian - Huda")));
  }
}