import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/services/pdf_service.dart';

// DEVELOPER: ZAMI

class PreviewPdfScreen extends StatefulWidget {
  const PreviewPdfScreen({super.key});
  @override
  State<PreviewPdfScreen> createState() => _PreviewPdfScreenState();
}

class _PreviewPdfScreenState extends State<PreviewPdfScreen> {
  // Logic UI: Menampilkan visualisasi data review performa neraca bulanan eksklusif untuk role Pemilik.
  // Menyediakan FloatingActionButton/Tombol cetak laporan untuk mengunduh dokumen PDF secara fisik dari server.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Layar Preview Laporan & Trigger Unduh PDF - Zami")));
  }
}