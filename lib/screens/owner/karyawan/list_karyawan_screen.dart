import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/services/karyawan_service.dart';

// DEVELOPER: DANIL

class ListKaryawanScreen extends StatefulWidget {
  const ListKaryawanScreen({super.key});
  @override
  State<ListKaryawanScreen> createState() => _ListKaryawanScreenState();
}

class _ListKaryawanScreenState extends State<ListKaryawanScreen> {
  // Logic UI: Menampilkan ListView list akun karyawan beserta chip badge status role hak akses sistemnya.
  // Menyediakan interaksi tombol hapus dengan trigger pop-up dialog konfirmasi.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Halaman Master Data Karyawan - Danil")));
  }
}