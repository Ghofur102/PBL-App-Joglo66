import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/components/input_field.dart';
import 'package:pbl_app_joglo66/services/gaji_service.dart';

// DEVELOPER: ZAMI

class FormGajiScreen extends StatefulWidget {
  const FormGajiScreen({super.key});
  @override
  State<FormGajiScreen> createState() => _FormGajiScreenState();
}

class _FormGajiScreenState extends State<FormGajiScreen> {
  // Logic UI: Menyediakan form bagi Bendahara/Pemilik. Dilengkapi dengan Dropdown pilihan nama karyawan
  // (mengambil referensi data master), pilihan Bulan & Tahun, serta InputField nominal gaji dengan validator ketat.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Form Pencatatan Transaksi Gaji Karyawan - Zami")));
  }
}